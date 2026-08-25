# CSCC69 Tutorial 解答

题目来自 [CSCC69_Course_info](https://github.com/MegumiKat/CSCC69_Course_info) 的 `tutorials/`（原 handout 只有题，没有答案）。解答已对照本仓库 `projects/pintos` 的 starter 源码核对：`thread.c` / `synch.c` / `syscall.c` / `process.c` / `inode.c`，以及 `priority-donate-*.c`、`priority-sema.c`、`args.c` 等测试。

每个文件保留**原题英文**，下面是完整解答。

| 编号 | 主题 | 文件 |
| --- | --- | --- |
| 02 | Interrupts and Threads | [02-interrupts-and-threads.md](02-interrupts-and-threads.md) |
| 03 | Synchronization | [03-synchronization.md](03-synchronization.md) |
| 04 | Scheduling | [04-scheduling.md](04-scheduling.md) |
| 05 | System Calls | [05-system-calls.md](05-system-calls.md) |
| 06 | Virtual Memory | [06-virtual-memory.md](06-virtual-memory.md) |
| 08 | Memory Management | [08-memory-management.md](08-memory-management.md) |
| 09 | Memory Mapped Files | [09-memory-mapped-files.md](09-memory-mapped-files.md) |
| 10 | Indexed Files | [10-indexed-files.md](10-indexed-files.md) |
| 11 | Directories | [11-directories.md](11-directories.md) |

课表里标了 No tutorial 的周（01、07 等）没有 handout。

核对过的易错点：`SYS_WRITE = 9`；捐赠后的优先级是 32/33/31 而不是 base；未改的 `sema_up` 不抢占所以 `priority-sema` 的 value 可以到 10；双重间接上限是 \(128 \times 128 \times 512 = 8\) MB；`process_wait` 的桩直接 `return -1`。

