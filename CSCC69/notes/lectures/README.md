# CSCC69 期末复习笔记｜Final Exam Review Notes

> **写法：** 中英对照写在同一份文档里，不是两个版本。  
> **Style:** Chinese and English sit together in the same file — not two separate versions.

来源 / Source：[CSCC69_Course_info](https://github.com/MegumiKat/CSCC69_Course_info) 的 `lectures/` 与 `_data/lectures.yml`。

本学期实际开出的 lecture 如下。I/O、高级文件系统、虚拟化、分布式、移动 OS 已在课表里注释掉，不在本套笔记范围。  
These are the lectures actually offered this term. I/O, advanced file systems, virtualization, distributed systems, and mobile OS are commented out in the schedule and are out of scope here.

课件路径 / Slide path：`lectures/0X/slides/CSCC69-*.pdf`。

---

## 本学期 Lecture 对照 / Lecture Map

| 周 Week | 主题 Topic | 课件 Slides | 笔记 Notes | Pintos |
| --- | --- | --- | --- | --- |
| 1 | The Big Picture | Introduction, The Big Picture | [01](01-introduction-and-big-picture.md) | 全项目总览 / overview |
| 2 | Multithreading | Multithreading | [02](02-multithreading.md) | Project 1 Threads |
| 3 | Scheduling | Scheduling | [03](03-scheduling.md) | Project 1 调度 / donation |
| 4 | User Programs | User Programs | [04](04-user-programs.md) | Project 2 |
| 5–6 | Virtual Memory | Virtual Memory, Paging | [05](05-virtual-memory-and-paging.md) | Project 3 |
| 7 | Memory Management | Memory Management | [06](06-memory-management.md) | Project 3 置换 / replacement |
| 8–9 | File Systems | File Systems | [08](08-file-systems.md) | Project 4 |

---

## 建议复习顺序 / Suggested Order

1. 进程/线程状态机、中断、上下文切换、同步原语（周 1–2）。  
   Process/thread state machine, interrupts, context switching, synchronization (weeks 1–2).

2. 调度指标与算法、priority inversion / donation、MLFQ（周 3）。  
   Scheduling metrics and algorithms, priority inversion/donation, MLFQ (week 3).

3. 系统调用、fork/exec、用户线程模型（周 4）。  
   System calls, fork/exec, user-thread models (week 4).

4. 地址翻译：base/bound → 分段 → 分页 → 两级页表 → TLB → page fault（周 5–6）。  
   Address translation: base/bound → segmentation → paging → two-level page tables → TLB → page fault (weeks 5–6).

5. 置换算法与 Belady 异常，会算 reference string（周 7）。  
   Replacement algorithms and Belady’s anomaly; be able to walk a reference string (week 7).

6. inode / FAT / FFS、目录与链接、崩溃一致性（周 8–9）。  
   inode/FAT/FFS, directories and links, crash consistency (weeks 8–9).

样卷 / Sample exam：`exams/Final_Exam_Sample.pdf`（Winter 2022）。

---

## 高频对比（考试最爱考）/ High-Yield Contrasts

- **进程 vs 内核线程 vs 用户线程**：隔离单位、调度单位、共享什么。  
  **Process vs kernel thread vs user thread:** unit of isolation, unit of scheduling, what is shared.

- **Lock vs Semaphore vs Condition Variable**：谁能记住信号、wait 会不会放锁。  
  **Lock vs semaphore vs CV:** who remembers a signal; whether wait drops the lock.

- **Spinlock vs Sleeping lock**：忙等 vs 关中断 + 阻塞队列。  
  **Spinlock vs sleeping lock:** busy-wait vs disable interrupts + wait queue.

- **非抢占 vs 抢占；FCFS / SJF / SRTF / RR / MLQ / MLFQ**。  
  **Non-preemptive vs preemptive; FCFS / SJF / SRTF / RR / MLQ / MLFQ.**

- **Priority inversion vs Priority donation**。

- **fork+exec vs Windows CreateProcess**。

- **1:1 / N:1 / N:M 线程模型**。  
  **1:1 / N:1 / N:M threading models.**

- **外部碎片 vs 内部碎片**；**分段 vs 分页**。  
  **External vs internal fragmentation; segmentation vs paging.**

- **单级页表 vs 两级页表 vs TLB**；TLB miss ≠ page fault。  
  **Single-level vs two-level page tables vs TLB;** a TLB miss is not a page fault.

- **FIFO Belady 异常 vs LRU / Clock / OPT**。

- **CoW、共享内存、mmap**。

- **连续分配 / 链表 / FAT / 多级 inode 索引**。  
  **Contiguous / linked / FAT / multi-level inode indexing.**

- **硬链接 vs 软链接**。  
  **Hard link vs soft/symbolic link.**

- **fsck vs LFS vs journaling（data / metadata / ordered）**。

---

## 指定阅读（OSTEP）/ Assigned Readings

课件配套章节，概念题常直接来自这些章。  
Concept questions often come straight from these chapters.

- Chap 2, 4, 13, 36：OS 全景、进程、地址空间、I/O  
  Overview, processes, address spaces, I/O
- Chap 26, 28, 31, 32：并发、锁、信号量、并发 bug  
  Concurrency, locks, semaphores, concurrency bugs
- Chap 6–8：LDE、调度、MLFQ  
  Limited Direct Execution, scheduling, MLFQ
- Chap 5, 27：Process API、Thread API
- Chap 15–20：地址翻译、分段、分页、TLB、小页表  
  Address translation, segmentation, paging, TLBs, smaller tables
- Chap 21–23：超出物理内存的机制与策略  
  Beyond physical memory: mechanisms and policies
- Chap 39–40：文件与目录、文件系统实现  
  Files and directories, file-system implementation
