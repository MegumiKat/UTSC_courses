# Tutorial 02：Interrupts and Threads

题目要求：在 debugger 里跟过 Pintos 线程切换后，回答下面问题。

---

## 1. What variable stores all information about the threads? Where is it defined in the code?

分两层看：

- **每个线程自己的全部状态**在 **TCB：`struct thread`** 里，定义在 `src/threads/thread.h` 第 83 行。字段包括 `tid`、`status`、`name`、`stack`（保存的内核 `%esp`）、`priority`、`allelem`、`elem`、`magic`，以及 userprog 下的 `pagedir`。每个线程独占 4 KB 一页：页底是这个结构，页顶向下长内核栈。
- **「所有线程」这一集合**存在 `src/threads/thread.c` 的静态变量 **`all_list`** 上（`thread_foreach` 遍历它）。就绪队列是另一个变量 **`ready_list`**。当前线程没有单独的全局指针，而是 `running_thread()`：把 `%esp` 对齐到页边界，页底就是当前 `struct thread`。

题目问的 variable，最直接的答案是 **`all_list`（外加每个节点上的 `struct thread`）**。

---

## 2. When are the different threads created?

有三类创建时机：

1. **启动时把正在跑的代码变成线程。** `thread_init()` 调用 `running_thread()` + `init_thread(..., "main", PRI_DEFAULT)`，得到最初的 `main` 线程。它不是 `palloc` 出来的。
2. **idle 线程。** `thread_start()` 里 `thread_create("idle", PRI_MIN, idle, ...)`，然后才 `intr_enable()` 打开抢占。
3. **之后所有线程。** 一律走 `thread_create()`：分配一页、填三个伪造栈帧（`kernel_thread` / `switch_entry` / `switch_threads`）、`thread_unblock` 放进 ready 队列。Project 2 里用户程序也是 `process_execute()` → `thread_create(..., start_process, ...)`。

---

## 3. What are the different status of a thread?

`enum thread_status`（`thread.h`）：

| 状态 | 含义 |
| --- | --- |
| `THREAD_RUNNING` | 正在占用 CPU |
| `THREAD_READY` | 可跑，在 `ready_list` 里等调度 |
| `THREAD_BLOCKED` | 等事件（锁、信号量、timer sleep 等），必须 `thread_unblock` 才能再跑 |
| `THREAD_DYING` | `thread_exit` 之后、被 `thread_schedule_tail` 回收之前 |

注意：课件状态图里的 waiting 在 Pintos 里就是 `THREAD_BLOCKED`。

---

## 4. When you print the stack in gdb (`backtrace` / `bt`), the stack shown belongs to which thread?

属于 **当前正在 CPU 上运行的那个线程**。

GDB 看到的是当前 `%esp` / `%eip`。Pintos 单核，任意时刻只有一个 `THREAD_RUNNING`。`bt` 走的就是这个线程的内核栈（若停在用户程序里，则是用户栈；若停在内核处理中断/系统调用，则是该线程的内核栈）。要看别的线程，必须切到那个线程的 `t->stack` 再手动解析，默认 `bt` 做不到。

---

## 5. When the scheduler is called (`schedule`, `thread.c:553`), how is the next thread selected?

当前树里 `schedule` 在 `thread.c:553`。它调用 `next_thread_to_run()`（约 491 行）：

- `ready_list` 非空：`list_pop_front` 取出队头，**FIFO**。
- 否则：跑 `idle_thread`。

Starter 代码里 `struct thread` 有 `priority` 字段，但 **`next_thread_to_run` 完全不用它**。默认策略是 **round-robin**：时间片用完 `thread_yield`，把自己 `list_push_back` 到队尾，再 pop 队头。`TIME_SLICE` 是 4 个 timer tick（`thread.c:54`）。

---

## 6. When (i.e. where in the code) is the scheduler called?

`schedule()` 是 static 的，只从这三处直接调用：

1. **`thread_block()`**（214）：把当前线程标 `THREAD_BLOCKED` 后调度。`sema_down`、`lock_acquire`、以后的 `timer_sleep` 最终都会走到这里。
2. **`thread_exit()`**（281）：标 `THREAD_DYING` 后调度，一去不回。
3. **`thread_yield()`**（302）：当前线程回到 ready 队列后调度。

外部中断里不能直接 `thread_yield`（idle/timer 上下文例外有限制）。时钟中断在 `thread_tick` 里若 `thread_ticks >= TIME_SLICE`，只设 `intr_yield_on_return()`；真正的 `thread_yield()` 发生在 `intr_handler` 处理完外部中断之后（`interrupt.c:386-387`）。

---

## 7. Could you give two situations when `thread_yield` is called?

Starter 里已经存在、而且课堂上跟调试最常见的两处：

**情况 A：时间片用完。** `TIME_SLICE = 4`。Timer IRQ → `thread_tick` 发现 `thread_ticks >= 4` → `intr_yield_on_return()` → `intr_handler` 在外部中断收尾处调用 `thread_yield()`（`interrupt.c:387`）。这是 round-robin 抢占。

**情况 B：starter 的 `timer_sleep` 忙等。** `devices/timer.c:97-98`：只要还没睡够，就反复 `thread_yield()`，把 CPU 让给别人。Project 1 要把这改成真正的 `thread_block`，但「yield 被调用」这件事在改之前就已经发生。

另外：测试代码（如 `priority-fifo.c`）也会主动 `thread_yield()`；实现优先级后，`sema_up` / `thread_create` 若发现更高优先级 ready，通常也要 yield。

---

## 8. When the scheduler switches to the next thread, where are eip and esp recorded and replaced?

精确位置在 **`src/threads/switch.S` 的 `switch_threads`**：

1. 把 `%ebx, %ebp, %esi, %edi` 压栈（ABI 要求保存的寄存器）。返回地址 **eip 已经由 `call` 压在栈上**。
2. `movl %esp, (cur + thread_stack_ofs)`  
   把当前 `%esp` 写进 **`cur->stack`**。这就是保存旧线程的栈指针；eip 跟着躺在这块栈上。
3. `movl (next + thread_stack_ofs), %esp`  
   换成 **`next->stack`**。
4. `popl` 恢复 next 的寄存器，最后 **`ret`**：从 next 的栈上弹出保存的 eip，跳过去。

新线程第一次跑时，`thread_create` 预先造好了 `switch_threads` 栈帧，里面的 eip 是 `switch_entry`。

---

## 9. When the CPU receives an interrupt, where are eip and esp saved and later restored?

**保存（硬件 + stub）：**

- CPU 自动把 `eip, cs, eflags` 压栈；若发生特权级切换（用户态进内核），还会压 `esp, ss`。
- `intrNN_stub`（`intr-stubs.S`）再压 `vec_no` 等，跳到 `intr_entry`。
- `intr_entry` 用 `pushal` 等保存通用寄存器，组装完整的 `struct intr_frame`（见 `interrupt.h`：`eip` 在约 51 行，`esp` 在 54 行）。

**恢复：**

- `intr_exit`：`popal` 恢复寄存器，丢掉 `vec_no/error_code/frame_pointer`，最后 **`iret`** 一次性恢复 `eip, cs, eflags`（以及用户态的 `esp, ss`）。

这和线程切换的 `switch.S` 是两套机制：中断保存的是被打断现场；`switch_threads` 保存的是内核线程之间的栈。

---

## 10. When the CPU receives an interrupt, how does the interrupt handler know which interrupt has been triggered?

每个向量有自己的 stub：`STUB(NUMBER, TYPE)` 里 **`push $0x##NUMBER`**，把向量号压进 `struct intr_frame` 的 **`vec_no`**。

`intr_handler(frame)` 用 `frame->vec_no` 查表：

```c
handler = intr_handlers[frame->vec_no];
```

外部设备中断还要经过 PIC：IRQ 被映射到向量 `0x20–0x2f`（`vec_no >= 0x20 && vec_no < 0x30` 视为 external）。例如 timer 通常是 IRQ0 → 向量 `0x20`。系统调用则是软件中断 **`int $0x30`**，向量就是 `0x30`。
