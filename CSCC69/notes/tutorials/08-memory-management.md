# Tutorial 08：Memory Management

对应 Project 3（虚拟内存）。Pintos 一页 = 一帧 = 4 KB。物理页分 **kernel pool** 和 **user pool**（`palloc.c`）。

---

## 1. What is the difference between a page and a frame?

| | Page（页） | Frame（帧） |
| --- | --- | --- |
| 空间 | **虚拟**地址空间里的 4 KB 对齐区域 | **物理**内存里的 4 KB 槽 |
| 编号 | VPN（virtual page number） | PPN / 物理帧号 |
| 寿命 | 属于某进程的地址空间，可换出 | 机器上真实 RAM，数量固定 |
| 映射 | 页表：VPN → PPN（或 not present） | 一帧同一时刻通常只映射给一个用户页（共享页除外） |

口语里常混用，但设计 VM 时必须分开：缺页是「这个 **page** 此刻没有 **frame**」。

---

## 2. What is swapping?

**把一页的内容在 RAM 和磁盘（swap 分区/文件）之间搬动**，让虚拟地址空间可以大于物理内存。

- **Swap out（换出）**：选一个受害帧，若脏则把内容写到 swap slot，清掉 PTE present 位，释放帧。
- **Swap in（换入）**：缺页时从对应 swap slot 读回一个新帧，填 PTE。

Pintos 用单独的 swap block device。没有 swap 时，内存耗尽只能杀进程或 panic。

---

## 3. When do you swap frames?

在 **必须给某个用户页分配帧，但 user pool 已经没有空闲帧** 的时候。典型触发：

- 用户 page fault（第一次碰栈、bss、mmap 区、或访问已被换出的页）；
- `palloc_get_page(PAL_USER)` 失败。

不是「定期把所有页换出去」。也不是内核一启动就 swap。应先找空闲帧；没有再 **evict** 一页（可能写回 swap 或文件），腾出帧给当前 fault。

若连 swap 也满了，通常退出当前进程（不要 kernel panic）。

---

## 4. Which pages should be swapped?

**可以换的：用户页**（user pool 里的帧：进程代码/数据/栈/mmap）。

**不应换的：**

- **内核页**（kernel pool）。内核必须始终可运行；中断处理、页表本身、TCB 不能 page fault 到磁盘。
- 正在做 I/O 的页（见 Tutorial 09 的 pin）。
- 有的实现也不换页表页。

Pintos 建议：eviction 只从 **user pool** 挑受害者。只读文件页（代码、mmap 未改）可以丢弃再从文件读，不必占 swap；匿名页（栈、零页、已写脏的）才需要 swap。

---

## 5. What is the frame table used for?

**用途：** 从「物理帧」反查「现在被哪个用户页占用」，以便分配空闲帧、以及在内存不够时选出受害者并改页表。硬件页表是按进程分的，没有这张全局表就不知道踢哪一帧、踢完怎么清 PTE。

每条记录至少要能回答：

- 这个帧空闲还是占用；
- 被哪个进程的哪个虚拟页占用（方便清 PTE、更新 SPT）；
- **内核虚拟地址**（`palloc` 返回的 kva）；
- 是否 **pinned**（I/O 进行中禁止踢）；
- eviction 算法状态（clock 的访问位、dirty）；
- 可选：来自文件还是 swap。

没有 frame table，就不知道踢哪一帧、踢完怎么改页表。硬件页表是按进程分的，反向查询「这帧属于谁」需要这张全局表。

---

## 6. What is the supplemental page table used for?

硬件 PTE 只能说 present / rw / u/s / 物理页号。一旦 present=0，硬件不知道数据在文件哪里、在哪个 swap slot、是不是全零页。

**Supplemental page table（SPT）** 是**每个进程**的软件页表，按用户 VPN 索引，在 page fault 时告诉你怎么把页装回来。每条记录通常包括：

- 页类型：file-backed / swap / all-zero / 栈增长；
- 文件、偏移、读多少字节、剩余是否补零；
- swap slot 号（若已换出）；
- writable？是否 mmap？对应的 mapid；
- 当前是否在内存、对应哪个 frame。

Fault 处理：查 SPT → 若非法则杀进程；若合法则拿一帧（可能 evict）→ 填数据 → 装 PTE。

---

## 7. What is the swap table used for?

**用途：** 管理 swap 磁盘上哪些槽空闲、分配/释放槽，并提供 `swap_out` / `swap_in`。一槽通常一页（8 个 512 B 扇区）。SPT 记住「这个 VPN 在几号槽」；swap table 本身只管理空闲集合。

需要跟踪：

- 哪些 slot **空闲**（常用 bitmap，和 filesystem free-map 同类）；
- 分配：换出时 `bitmap_scan_and_flip` 得到 slot 号，写入 SPT；
- 释放：页被销毁或写回文件后，把 slot 标空闲；
- 读写接口：`swap_in(slot, frame)` / `swap_out(frame) → slot`。

它**不**需要记住「这槽属于哪个进程」——那是 SPT 的事。Swap table 只管理空闲集合。满了就无法再 evict 匿名页。
