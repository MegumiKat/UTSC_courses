# Tutorial 09：Memory Mapped Files

对应 `mmap` / `munmap` 系统调用（Project 3）。Pintos 规范见官方 VM 文档；下面按该语义解答。

---

## 1. What does the `mmap` function do?

`mapid_t mmap(int fd, void *addr)` 把一个**已经打开的文件**映射进调用进程的用户地址空间：

- 从 **`addr` 开始**，连续若干虚拟页对应文件字节 `[0, filesize)`；
- 最后一页超出文件的部分读作 0；写那部分不写回文件；
- 返回 **mapid**（之后 `munmap` 用）；失败返回 `-1`。

失败条件（必须检查）：

- `addr == 0` 或不是页对齐；
- `fd` 是控制台（0/1）或无效；
- 文件长度为 0；
- 映射区间与已有页（代码、数据、栈、其它 mmap）重叠。

成功时**不必**立刻读磁盘：只在 SPT 里记下「这些 VPN 是 file-backed」。之后用 load/store 当普通内存访问。

---

## 2. When is the file read into memory?

**按需、在 page fault 时读（demand paging），不是 `mmap` 当时整文件读入。**

第一次访问某页 → 缺页 → SPT 说这页属于这个 mmap → 分配帧 → `file_read_at` 读对应偏移 → 装 PTE。从未访问的页可以一直不占 RAM。

这和加载 ELF 的 lazy load 是同一套机制；mmap 只是 SPT 条目的另一种来源。

---

## 3. When should you write data back to the file system?

（原题有的版本写成 written back to memory，意思是 **写回文件系统/磁盘**。）

只写 **dirty** 页（PTE dirty 或你软件记的脏位）。时机：

1. **被 eviction 踢出内存时**（若该页可写且脏）；
2. **`munmap` 时**，该映射里仍在内存的脏页；
3. **进程退出时**，等价于对所有 mapping 做 munmap。

只读映射或从未改过的页直接丢弃，再需要时从文件重读。不要在每次 store 时同步写盘（那会极慢）；也不要写「文件长度之外」的填充区。

---

## 4. What happens if two processes map the same file?

Pintos **不要求共享物理页**。标准做法：

- 每个进程自己的页表和 SPT 各有一份映射；
- 各自 fault in 各自的帧；
- A 的写入在 A munmap/evict 时写回文件；B 何时看到取决于它是否已缓存旧页——**没有 POSIX 共享 mmap 的一致性保证**。

若你额外做 page sharing，必须处理写时复制或共享脏页，作业不强制。目录项/inode 仍是同一个文件；`remove` 的语义见下一题。

---

## 5. What happens if the file is deleted while it is mapped?

Unix/Pintos：**`remove` 只删目录项，inode 在仍有 opener/mapping 时继续活着。**

- 已建立的 mmap 继续有效，fault 仍能读到文件数据；
- 新的 `open` 找不到这个名字；
- 最后一个 `close`/`munmap`/进程退出后 inode 才真正释放数据块。

所以「映射期间删除」不应让之后的访问变成非法地址；也不应在 `remove` 时立刻把映射拆掉。

---

## 6. What happens if a page is currently being read/written by DMA and that page gets evicted?

**会损坏数据。** 磁盘控制器 DMA 直接读写那块物理内存。若 eviction 在传输中途把该帧改派给另一个虚拟页：

- 设备仍往旧物理地址写 → 写进**别人的页**；
- 或读到的是新主人的垃圾，文件内容被毁掉。

这和 mmap 无关，任何 `block_read`/`file_read` 进 frame 的路径都有这个问题。

**做法：I/O 期间 pin 该帧。** 开始传输前 `pinned = true`，clock/evict 跳过它；完成后取消 pin。Page fault 装页、以及把用户缓冲区直接交给文件系统时都要 pin。Pin 只包住 I/O 窗口，不是永远锁定。
