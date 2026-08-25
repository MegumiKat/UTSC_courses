# 缩写、作用与 Pintos 默认值
# Abbreviations, Roles, and Pintos Defaults

> 考试默写用。数值以本仓库 `projects/pintos` starter 为准；课上 inode 计算题常用 **Unix 风格 12 直接 + 间接**，和 starter 的连续分配不同，文中分开标注。  
> For exam recall. Numbers match this repo’s Pintos starter. Lecture inode-size questions often use **Unix-style 12 direct + indirect pointers**, which is **not** the starter’s contiguous inode — marked separately below.

---

## 1. Pintos 默认数值 / Default Numbers

### 1.1 内存与地址翻译 / Memory and Translation

| 符号 / Name | 值 / Value | 作用 / Role |
| --- | --- | --- |
| `PGBITS` | **12** | 页内偏移位数 / bits in the page offset |
| `PGSIZE` | **4 KB = 4096 B** | 一页大小；一帧大小 / page = frame size |
| `PHYS_BASE` | **`0xC0000000` (3 GB)** | 用户 VA 上限；内核 1:1 映射起点。合法用户指针必须 **`< PHYS_BASE`** / top of user VA; kernel mapping base; user pointers must be **`< PHYS_BASE`** |
| VA 切分（32-bit） | **10 + 10 + 12** | PDE index + PTE index + offset |
| PDE / PTE 项数 | 各 **1024** | `4 KB / 4 B = 1024` |
| 一张页表覆盖 | **4 MB** | `1024 × 4 KB` |
| PTE / PDE 大小 | **4 B** | 硬件页表项 / hardware table entry |
| `PTE_P` | bit 0 | present：0 → page fault |
| `PTE_W` | bit 1 | writable |
| `PTE_U` | bit 2 | user 可访问 / user-accessible |
| `PTE_A` | bit 5 | accessed（clock / second chance） |
| `PTE_D` | bit 6 | dirty（PTE；换出时要不要写回） |
| `%cr3` | 页目录物理地址 | `pagedir_activate()` 装它 / holds the page-directory PA |
| `%cr2` | 缺页 VA | `page_fault` 从这里读 fault address |
| `%cr0` | 打开分页 | paging enable bit |
| 一页对应 swap | **8 个 512 B 扇区** | `4096 / 512 = 8` |

**派生公式 / derived：**

```text
offset = VA & 0xFFF
VPN    = VA >> 12
PDE    = VA >> 22
PTE    = (VA >> 12) & 0x3FF
PA     = (PPN << 12) | offset
```

### 1.2 线程与调度 / Threads and Scheduling

| 符号 / Name | 值 / Value | 作用 / Role |
| --- | --- | --- |
| `PRI_MIN` | **0** | 最低优先级（`idle`） / lowest priority |
| `PRI_DEFAULT` | **31** | 用户/普通线程默认优先级 / default |
| `PRI_MAX` | **63** | 最高优先级 / highest |
| `TIME_SLICE` | **4 ticks** | RR 时间片；用完 `thread_yield` |
| `TIMER_FREQ` | **100 Hz** | 每秒 100 次时钟中断；1 tick = 10 ms |
| 模型 | **单核、1:1** | 一个用户进程 = **一个内核线程**；没有 `pthread` / one user process = **one kernel thread** |

### 1.3 系统调用 / System Calls

| 符号 / Name | 值 / Value | 作用 / Role |
| --- | --- | --- |
| 陷入指令 | **`int $0x30`** | Pintos syscall trap（Linux 才是 `int $0x80`） |
| DPL | **3** | 用户态允许触发该向量 / user may invoke it |
| `SYS_HALT` … `SYS_WRITE` | **0 … 9** | enum 从 0 起；**`SYS_WRITE = 9`** |
| `STDIN_FILENO` | **0** | 键盘 / keyboard |
| `STDOUT_FILENO` | **1** | 控制台；内核走 **`putbuf`** / console via **`putbuf`** |
| 用户 fd 起点 | **≥ 2** | `open` 分配的文件描述符 / file fds |
| 参数位置 | **`f->esp`** | 用户栈：号, arg0, arg1, …（**不是**内核 `%esp`） |
| 返回值 | **`f->eax`** | 回用户态靠 **`iret`**，不是 `ret` |
| 非法指针 | **`exit(-1)`** | 禁止 kernel panic / never panic the kernel |

`syscall3` 从右往左 push，因此从 `f->esp` 往高地址：

```text
f->esp+0  = syscall number
f->esp+4  = arg0   (write: fd)
f->esp+8  = arg1   (write: buffer)
f->esp+12 = arg2   (write: size)
```

### 1.4 文件系统 / File System（starter）

| 符号 / Name | 值 / Value | 作用 / Role |
| --- | --- | --- |
| `BLOCK_SECTOR_SIZE` | **512 B** | 磁盘扇区 = FS 逻辑块（Pintos 里两者相同） / sector = FS block |
| `block_sector_t` | **`uint32_t` = 4 B** | 扇区号 / 块指针大小 / sector number = pointer size |
| `off_t` | **`int32_t` = 4 B** | 文件内字节偏移 / file offset |
| `inode_disk` | **正好 512 B** | 一个 inode 占 1 扇区：`start` + `length` + `magic` + `unused[125]` |
| 每块指针数 | **512 / 4 = 128** | 间接块里能装多少个块号 / pointers per index block |
| `NAME_MAX` | **14** | 目录项文件名长度（加 `'\0'` 共 15） / file-name length |
| `FREE_MAP_SECTOR` | **0** | free-map 文件的 inode 扇区 |
| `ROOT_DIR_SECTOR` | **1** | 根目录 inode 扇区 |
| 根目录初始项 | **16** | `dir_create(ROOT_DIR_SECTOR, 16)` |
| `PAL_USER` | `004` | 从 **user pool** 分配帧 / allocate from user pool |
| `PAL_ZERO` | `002` | 分配时清零 / zero the page |
| `PAL_ASSERT` | `001` | 失败则 panic（内核分配用，用户缺页不要用） |

**Starter inode 是连续分配（`start` + `length`），不是 12 个直接指针。**  
The starter inode is **contiguous** (`start` + `length`), not Unix multi-level index.

### 1.5 课上 / 样卷常用的 inode 数字（不是 starter 布局）

Lecture / sample-exam convention unless the problem says otherwise:

| 项 / Item | 值 / Value |
| --- | --- |
| 块大小 B | **512 B**（有时改成 4 KB） |
| 指针 P | **4 B** |
| `ptrs = B / P` | **128**（4 KB 块则 **1024**） |
| inode | **12 直接 + 1 单间接 + 1 双重间接** |
| 单间接覆盖 | `128` 块 = **64 KB** |
| 双重间接覆盖 | `128²` 块 = **8 MB** |
| 三重间接覆盖 | `128³` 块 = **1 GB** |
| 完整最大（12+单+双） | `12 + 128 + 16384 = 16524` 块 ≈ **8.07 MB** |
| 双重间接一次随机读 | **3 次盘**（顶层 → 间接 → 数据；inode 已缓存） |

```text
max_double_only = (B/P)² × B     →  128×128×512 = 8 MB
index blocks for n data blocks:
  n ≤ 12            → 0
  13 ≤ n ≤ 140      → 1          (single)
  n > 140           → 1+1+⌈(n-140)/128⌉
```

---

## 2. 硬件与执行 / Hardware and Execution

| 缩写 | 全称 | 作用 |
| --- | --- | --- |
| **CPU** | Central Processing Unit | 执行指令。一个 **core** 同时只能跑 **一条** 内核线程。 / Executes instructions. One **core** runs **one** kernel thread at a time. |
| **core** | CPU 核 | CPU 里真正取指执行的单元；多核才能真并行。 / The unit that fetches/executes; only multicore is true parallelism. |
| **RAM** | Random Access Memory | **物理内存 / 运行内存**；掉电丢失。 / Physical / working memory; volatile. |
| **I/O** | Input / Output | 磁盘、键盘、网卡等设备。 / Disk, keyboard, NIC, … |
| **ISA** | Instruction Set Architecture | CPU 能执行的指令集（算术、访存、跳转、`int`）。 / The instruction set the CPU implements. |
| **EIP / RIP** | Instruction Pointer | 下一条指令地址；存在 TCB / `intr_frame`。 / Next instruction; saved in the TCB / `intr_frame`. |
| **ESP / RSP** | Stack Pointer | 当前栈顶；用户栈 vs 内核栈是两套。 / Stack top; user stack and kernel stack are separate. |
| **LDE** | Limited Direct Execution | 线程直接在 CPU 上跑一小段，再因 yield / 时钟中断被切走。 / Run directly on the CPU for a while, then yield or be preempted. |
| **DMA** | Direct Memory Access | 设备**按物理地址**自己搬 RAM，CPU 只下单。传输期间该帧必须 **pin**，否则 eviction 会写进别人的页。 / Device copies RAM at a **physical address**; **pin** the frame for the I/O window. |
| **PIO** | Programmed I/O | 无 DMA：CPU 逐字搬数据，浪费。 / CPU copies every word; wasteful. |
| **IRQ** | Interrupt Request | 设备的中断请求线。 / A device’s interrupt request line. |
| **PIC** | Programmable Interrupt Controller | 设备 → PIC → CPU 的 **INTR**；可屏蔽、可设优先级。 / Devices go through the PIC to CPU **INTR**. |
| **INTR** | Interrupt pin | CPU 上接收 PIC 通知的引脚。 / CPU pin that receives the PIC. |
| **IDT** | Interrupt Descriptor Table | 向量号 → 处理函数。`int $0x30` 查这里。 / Vector → handler; `int $0x30` indexes it. |
| **CPL** | Current Privilege Level | 0 = 内核，3 = 用户。Pintos 用户程序 CPL=3。 / 0 = kernel, 3 = user. |
| **CS / SS** | Code / Stack Segment | 中断时硬件连同 EIP/ESP/EFLAGS 一起压栈。 / Pushed by hardware on a trap. |
| **EFLAGS** | Flags register | 含中断允许位；`iret` 一并恢复。 / Includes IF; restored by `iret`. |
| **GDT** | Global Descriptor Table | x86 段选择子表（用户/内核代码段、数据段）。 / Segment selectors. |
| **TSS** | Task State Segment | 特权级切换时内核栈在哪。 / Kernel stack for privilege change. |
| **ELF** | Executable and Linkable Format | 可执行文件格式；`load()` 读它。 / Executable format that `load()` reads. |

---

## 3. 进程、线程、中断 / Processes, Threads, Interrupts

| 缩写 | 全称 | 作用 |
| --- | --- | --- |
| **TCB** | Thread Control Block | 内核里一条线程：`tid`、`priority`、`stack`（内核 `%esp`）、状态。Pintos 即 `struct thread`。 / One kernel thread: tid, priority, saved kernel `%esp`, status. |
| **PCB** | Process Control Block | 进程：地址空间、打开文件、cwd、pid。Pintos 用户进程的 PCB 字段加在 `struct thread` 上。 / Process: AS, fds, cwd, pid. |
| **tid / pid** | thread / process id | Pintos 里用户进程的 pid 通常就是 tid。 / In Pintos the user pid is typically the tid. |
| **cwd** | current working directory | **每进程一份**，相对路径的起点；退出要 `dir_close`。 / **Per-process**; start of relative lookup. |
| **UT / user thread** | 用户级线程 | **库**调度，内核看不见。 / Scheduled by a **library**; kernel does not see it. |
| **KT / kernel thread** | 内核线程 | **OS** 调度，有内核 TCB。Pintos 用户程序 = KT 跑在 user mode。 / OS-scheduled; user code runs **on** a KT. |
| **1:1 / N:1 / N:M** | 线程映射 | 1:1 能多核；N:1 一个阻塞可能全停。Pintos = **1:1 且每进程通常 1 条 KT**。 / 1:1 uses cores; N:1 one block can stall all. |
| **trap** | 故意陷入 | 程序员执行 `int`（syscall）。 / Intentional `int` (syscall). |
| **fault** | 故障 | 指令失败、可重试：缺页、除零。**iret 重执行同一条**。 / Retryable: page fault, #DE. **Re-execute the same instruction.** |
| **abort** | 不可恢复异常 | 通常杀进程。 / Usually kill the process. |
| **syscall** | system call | 用户要内核服务的陷阱。Pintos：`int $0x30`。 / User trap for kernel services. |
| **`intr_frame`** | interrupt frame | 内核栈上保存的用户/被中断现场；`eip`/`esp`/`eax` 都在这。 / Saved trap frame on the **kernel** stack. |
| **`iret`** | interrupt return | 一次恢复 `eip,cs,eflags[,esp,ss]`，回用户态。 / Restores those registers at once. |
| **`ret`** | near return | 只弹 EIP；用于 `switch_threads`，**不是**出中断。 / Pops EIP only; used by `switch_threads`, **not** to leave a trap. |

**Unix vs Pintos 创建进程：**

| | Unix | Pintos |
| --- | --- | --- |
| `fork` | 新进程 + **新 KT**（只复制调用线程） | **没有** |
| `exec` | **不**新 KT，换地址空间 | `exec` ≈ `process_execute`：**再 `thread_create` 一个子进程** |

---

## 4. 同步与调度 / Sync and Scheduling

| 缩写 | 全称 | 作用 |
| --- | --- | --- |
| **CS** | Critical Section | 访问共享数据、必须互斥的那段代码。 / Code that must run mutually exclusively. |
| **race** | race condition | 交错导致结果依赖时序。 / Result depends on interleaving. |
| **atomic** | 原子 | 中间不可被打断；`x++` 在 C 里**不是**原子。 / Indivisible; `x++` is **not** atomic. |
| **mutex / lock** | mutual exclusion | 同时只一人进 CS；Pintos `struct lock` 底层是 `sema=1`。 / One holder; Pintos lock is a binary semaphore. |
| **CV** | Condition Variable | 等**条件**；`cond_wait` 先放锁再睡，醒来再抢锁。信号**不记住**。 / Wait for a **condition**; wait drops the lock; signal is **not remembered**. |
| **P / down / wait** | Dijkstra P | 信号量减 1，不够则阻塞。 / Decrement; block if empty. |
| **V / up / signal** | Dijkstra V | 加 1；有等待者则唤醒。**信号会被记住**（值可先涨）。 / Increment; wake a waiter. **Remembered.** |
| **TOCTOU** | Time-Of-Check to Time-Of-Use | 检查与使用之间被打断（所以 `thread_block` 要关中断）。 / Gap between check and use. |
| **deadlock** | 死锁 | 循环等待 + 互斥 + 持有并等待 + 不可抢占。**反序拿锁**才会。 / Circular wait on locks. |
| **starvation** | 饥饿 | 系统还在推进，某线程无限等。 / System progresses; one thread waits forever. |
| **priority inversion** | 优先级反转 | High 等 Low 的锁，Medium 饿死 Low 的 CPU。**不是死锁**。 / High waits on Low; Medium starves Low. **Not deadlock.** |
| **donation** | 优先级捐赠 | 持锁者 effective = max(自己, 等待者)。多把锁取 **max**。 / Holder’s effective priority = max of waiters. |
| **FCFS** | First Come First Served | 非抢占 FIFO；可能 convoy。 / Non-preemptive FIFO. |
| **SJF** | Shortest Job First | 非抢占，最短 CPU burst 先。 / Non-preemptive shortest burst. |
| **SRTF** | Shortest Remaining Time First | 抢占版 SJF。 / Preemptive SJF. |
| **RR** | Round Robin | 时间片用完到队尾。 / Quantum then tail of FIFO. |
| **MLQ** | Multi-Level Queue | 固定优先级多队列。 / Static priority queues. |
| **MLFQ** | Multi-Level Feedback Queue | 用完配额降级；周期 S 升回顶，防饥饿。 / Drop after allotment; boost every S. |
| **convoy effect** | 护航效应 | 短作业排在长作业后面，平均等待被拉爆（典型 FCFS）。 / Short jobs stuck behind a long one. |
| **quantum** | 时间片 | 必须 ≫ 上下文切换代价。 / Must be ≫ context-switch cost. |

---

## 5. 虚存三张表 / Virtual Memory Tables

| 缩写 | 全称 | 几张 | 作用 |
| --- | --- | --- | --- |
| **VA / PA** | Virtual / Physical Address | — | 程序看见的 vs 内存条上的。 / What the program sees vs RAM. |
| **VPN / PPN** | Virtual / Physical Page Number | — | `VA`/`PA` 去掉 offset。 / Address without the offset. |
| **PTE** | Page Table Entry | 硬件页表里一项 | VPN→PPN + present/rw/u/s/accessed/dirty。`present=0` 后**不知道数据在哪**。 / Maps VPN→PPN + flags; **cannot** locate data once not-present. |
| **PDE** | Page Directory Entry | 页目录里一项 | 指向一张页表。格式与 PTE 几乎相同，只是指向的对象不同。 / Points at a page table; same format, different target. |
| **PD** | Page Directory | **每进程 1 张** | `%cr3` 指向它。 / Pointed to by `%cr3`. |
| **TLB** | Translation Lookaside Buffer | 每 CPU 一份 | 缓存 VPN→PPN；miss ≠ page fault。切进程常要 flush。 / Caches VPN→PPN; a miss is not a fault. |
| **SPT** | Supplemental Page Table | **每进程 1 张** | 软件页表：该 VPN 是 file/offset、swap slot、全零还是栈增长。缺页时查它。 / Software: file+offset / swap slot / zero / stack. |
| **frame table** | 帧表 | **全局 1 张** | 物理帧 → 属于谁（进程+VPN）、是否 **pinned**。evict 靠它反向查。 / Frame → owner + pin; needed to evict. |
| **swap table** | 交换表 | **全局 1 张** | 哪些 swap 槽空闲（bitmap）。**不**记录槽属于谁（那是 SPT）。 / Free swap slots only; owner is in the SPT. |
| **mmap** | memory-map | — | 把文件映射进 VA；脏页写回**文件**不是 swap。 / Map a file into VA; dirty pages go back to the **file**. |
| **CoW** | Copy-on-Write | — | 只读共享，写时才拷帧。 / Share read-only; copy on write. |
| **evict** | 换出 | — | **缺页且 user pool 空**时偷一帧。不是定时清，也不是进程退出（退出是 **free**）。 / Steal a frame when a user fault has no free frame. |
| **pin** | 钉住 | — | I/O/DMA 期间禁止 evict。 / Forbid eviction during I/O. |
| **anon page** | anonymous page | — | 无文件后备（栈/堆/BSS）；脏了换出进 **swap**。 / No file backing; dirty eviction goes to **swap**. |

**缺页装入记忆链：**  
`present=0` → CR2 → 查 SPT → 拿帧（不够 evict）→ pin → 从 swap/文件/零 填 → `install_page` → unpin → **重执行**。

---

## 6. 文件系统 / File System

| 缩写 | 全称 | 作用 |
| --- | --- | --- |
| **FS** | File System | 把磁盘组织成文件/目录。 / Organizes the disk into files and directories. |
| **S / superblock** | 超级块 | magic、块数、inode 数、各区起点。 / Magic, sizes, layout offsets. |
| **i-bmap** | inode bitmap | 哪个 inode 空闲。 / Which inodes are free. |
| **d-bmap / free-map** | data bitmap | 哪个数据块空闲。Pintos `FREE_MAP_SECTOR`。 / Which data blocks are free. |
| **inode** | index node | 文件**本体**元数据：长度、类型、块指针、link count。**不含名字**。 / File metadata; **no name**. |
| **inumber** | inode number | 标识一个 inode；Pintos 里常等于 inode 所在扇区号。 / Identifies the inode; often the inode’s sector. |
| **dirent** | directory entry | **name → inumber + in_use**。目录本身也是文件。 / name → inumber; a directory is a file. |
| **`.` / `..`** | 自身 / 父目录 | 根的 `..` 指向自己。 / Root’s `..` points at itself. |
| **hard link** | 硬链接 | 多个名字指向**同一 inode**；`remove` 只减 link count。 / Several names, one inode. |
| **symlink** | 软链接 | 内容是另一条路径字符串。 / Stores a path string. |
| **FAT** | File Allocation Table | 链表分配：表项指向下一块。 / Linked allocation via a table. |
| **LFS** | Log-structured File System | 追加写，不覆盖；靠 imap + checkpoint。 / Append-only; imap + checkpoint. |
| **WAL** | Write-Ahead Logging | 先写日志再改真正 FS = journaling。 / Log first, then the real FS. |
| **fsck** | file-system check | 启动时扫不一致并修；大盘很慢。 / Scan/fix on boot. |
| **TxBegin / TxEnd** | journal 事务 | 无 TxEnd → 忽略；有 TxEnd 未 checkpoint → redo。 / No commit → ignore; committed → redo. |
| **write-back** | 回写缓存 | `write` 只改 cache 打 **dirty**；落盘在 **置换 / 周期 flush / `filesys_done()`**。**`close` 不刷盘**。 / `write` dirties cache; **`close` does not flush**. |
| **RMW** | read-modify-write | 改 4 B 必须先把 512 B 整块读进 cache。 / A 4 B write still reads the whole 512 B block. |

**盘上布局（课上典型）：**

```text
[ boot ][ S ][ i-bmap ][ d-bmap ][ inode table ][ data blocks ]
```

Pintos starter 更简单：扇区 0 = free-map inode，扇区 1 = 根目录 inode，其余按需分配。

---

## 7. 其他考试缩写 / Other Exam Abbreviations

| 缩写 | 全称 | 作用 |
| --- | --- | --- |
| **RPC** | Remote Procedure Call | 远程调用看起来像本地函数。 / Make a remote call look local. |
| **stub / skeleton** | 客户端 / 服务端桩 | 客户端 marshal+发送+等回复；服务端 unmarshal+调用本地+回包。 / Client marshals; server unmarshals and dispatches. |
| **marshal** | 打包序列化 | 参数变成网络字节流（无指针）。 / Serialize args (no raw pointers). |
| **at-most-once** | 至多一次 | 请求带 **唯一 ID**；重复 ID **不重做**，重发已存回复。 / Unique ID; duplicates replay the saved reply. |
| **FIFO** | First In First Out | 置换：踢进来最早的页。 / Evict the oldest loaded page. |
| **LRU** | Least Recently Used | 踢最久没访问的；hit 也更新时间。 / Evict least recently used. |
| **clock / second chance** | 时钟 / 二次机会 | 用 `PTE_A` 近似 LRU；ref=1 清 0 并跳过。 / Approximate LRU with the accessed bit. |
| **OPT / MIN** | 最优置换 | 踢最久以后才用的（离线，对照用）。 / Evict the page used farthest in the future. |
| **Belady** | Belady’s anomaly | FIFO 帧变多缺页**可能更多**。LRU 不会。 / More frames can **increase** FIFO faults. |
| **AS** | Address Space | 一个进程的 VA 范围 + 页表。 / A process’s VA range + page tables. |
| **BSS** | Block Started by Symbol | 未初始化全局数据；第一次访问常当 **全零页**。 / Uninitialized globals; first touch is often a zero page. |

---

## 8. 一张「别写错」对照 / Do-Not-Mix-Up

| 别写成 | 应写成 |
| --- | --- |
| Linux `int $0x80` | Pintos **`int $0x30`** |
| 内核 `%esp` 上的参数 | **`f->esp`**（用户栈） |
| `file_write` 打到 stdout | fd=1 走 **`putbuf`** |
| `ret` 回用户态 | **`iret`** |
| PTE 知道 swap 槽号 | **SPT** 知道 |
| swap table 记录属于谁 | 只记录 **空闲槽** |
| 每进程一张 frame table | **全局一张** |
| `close` 会写盘 | **write-back：关机 / evict / flush 才写** |
| `exec` 在 Unix 再造线程 | Unix **不**造；Pintos `exec` **会**造子进程 |
| 优先级反转 = 死锁 | **饥饿 + 反转**，Low 只要能跑就会放锁 |

---

## 9. 源码锚点 / Source Anchors

| 内容 | 文件 |
| --- | --- |
| `PGSIZE`, `PHYS_BASE` | `src/threads/vaddr.h`, `src/threads/loader.h` |
| PDE/PTE 位 | `src/threads/pte.h` |
| `PRI_*`, `TIME_SLICE` | `src/threads/thread.h`, `thread.c` |
| `TIMER_FREQ` | `src/devices/timer.h` |
| `int $0x30` | `src/userprog/syscall.c`, `src/lib/user/syscall.c` |
| syscall 号 | `src/lib/syscall-nr.h` |
| 扇区 512 B、4 B 指针 | `src/devices/block.h` |
| `inode_disk` | `src/filesys/inode.c` |
| `NAME_MAX=14` | `src/filesys/directory.h` |
| 根 / free-map 扇区 | `src/filesys/filesys.h` |
| `PAL_*` | `src/threads/palloc.h` |
