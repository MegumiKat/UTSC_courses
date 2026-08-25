# Tutorial 03：Synchronization

题目里的测试：`src/tests/threads/alarm-wait.c`、`priority-sema.c`。同步原语在 `src/threads/synch.c`。

---

## 1. What is a critical section? What is the critical section in `alarm-wait.c`?

**临界区**是访问**共享数据**、必须互斥执行的那段代码。同一时刻只能有一个线程进入，否则会出现 race。

在 `alarm-wait.c` 里，共享数据是测试结构里的输出缓冲区和写指针 `output_pos`。每个 sleeper 醒来后要做：

```c
*test->output_pos++ = t->id;
```

这就是临界区：读 `output_pos`、写一个 slot、再把指针往后移。Starter 用 `output_lock` 包住这段（见 `sleeper` 函数）。`test->output` 数组本身也是共享的，必须和指针一起保护。

注意：`timer_sleep` 本身不是这段测试的临界区；临界区是**写共享输出**。

---

## 2. Could you explain in details how this critical section could lead to a race condition bug and how that bug would affect the value of the variable `output_pos`?

原题要你具体讲 **`output_pos` 会怎么坏**，不只是「输出乱了」。

`*test->output_pos++ = t->id` 在 C 里等价于：读指针 → 写入 `*p` → 指针 `+1`。这几步不是原子的。两个 sleeper 都被唤醒、交错执行时：

**交错 1（最常见，lost update）：**

1. T1 读到 `output_pos == p`
2. T2 也读到 `output_pos == p`
3. T1 写 `*p = id1`，再把 `output_pos` 设成 `p+1`
4. T2 写 `*p = id2`（**覆盖** id1），再把 `output_pos` 设成 `p+1`

结果：`output_pos` 只前进了 **1**，但发生了两次唤醒。后写覆盖先写，缓冲区少一个 id。测试后半段会发现某个线程的 `iterations` 不够，或顺序检查失败。

**交错 2（指针多加）：** T1 写完但还没更新指针，T2 读到旧值并完成 `p+1`，然后 T1 也做 `p+1`，可能变成 `p+2`。于是 `output_pos` **跳过一个 slot**（里面是未初始化垃圾），测试读到非法 id 直接 `ASSERT` 失败。

无论哪种，**`output_pos` 不再等于「真实唤醒次数」**，它和实际写入次数脱节。这就是必须用 `output_lock` 的原因。

---

## 3. What is a mutex? What is a lock?

**Mutex（mutual exclusion）** 是保证临界区互斥的同步原语：同一时刻最多一个线程持有。

**Lock** 在操作系统课里通常就是 mutex 的实现：

- 有 **owner**：谁 `acquire` 谁必须 `release`。
- 二进制：locked / unlocked。
- 一般**不可重入**（Pintos lock 明确禁止同一线程再 acquire）。

Pintos 的 `struct lock`（`synch.h`）内部就是一个初值为 1 的 semaphore，外加 `holder` 字段用来检查所有权和禁止递归。

---

## 4. What is the difference between a semaphore and a lock?

| | Semaphore | Lock |
| --- | --- | --- |
| 本质 | 非负整数 + P(`down`)/V(`up`) | 互斥锁 |
| 初值 | 可以是 0、1、或更大（计数信号量） | 只能是 unlocked |
| Owner | **没有**。A 可以 down，B 可以 up | **有**。必须同一线程 acquire/release |
| 用途 | 计数资源、sleep/wakeup、生产者消费者 | 保护临界区 |
| Pintos | `sema_down` 在 `value==0` 时阻塞；`sema_up` 总是 `value++` 并可能唤醒一人 | `lock_acquire` = `sema_down` + 设 holder |

可以把 lock 看成「带所有权检查的 binary semaphore」，但不能把 semaphore 当 lock 用（没有 holder，无法做优先级捐赠）。

---

## 5. In `priority-sema.c`, could you give three scenarios in which the maximum value of the semaphore is either 1, 2 or 10?

测试结构：`sema_init(&sema, 0)`；创建 10 个比 main 更高优先级的线程，每个先 `sema_down`（全部阻塞，`value` 仍为 0）；main 被设成 `PRI_MIN`，然后循环 10 次 `sema_up`。

`sema_up`：若有 waiter 则 unblock 一个，然后 **`value++`**。`sema_down` 被唤醒后若 `value > 0` 则 **`value--`**。因此 **value 的峰值 = 连续多少次 V 发生在下一次 P 完成之前**。

**最大值 = 1**

每次 `sema_up` 之后立刻调度被唤醒的那个 waiter（优先级调度 + 抢占，或 `sema_up` 末尾 `thread_yield`）。waiter 马上跑完 `sema_down` 里的 `value--`。路径是 `0 → 1 → 0`，再 up 下一个人。峰值永远是 1。这是实现 Project 1 优先级之后这个测试**应当**出现的交错（高优先级先醒）。

**最大值 = 2**

两次 `sema_up` 之间没有任何 waiter 跑完 `down`。例如：第一次 up 把一个线程放进 ready，但还不抢占（starter 的 `thread_unblock` **明确不抢占**）；main 继续第二次 up，`value` 变成 2；然后一次时钟中断 / 一次 yield，某个 waiter 才跑并 `value--`。峰值是 2。本质是「部分延迟的调度」：V 比 P 多做了两次。

**最大值 = 10**

Main 把 10 次 `sema_up` **全部做完**，10 个 waiter 都只是进了 `ready_list`，谁也还没得到 CPU。每次 up 都 `value++`，所以 `value` 从 0 涨到 **10**。这是 **未改的 Pintos** 的真实行为：`sema_up` 不 yield，main 虽然优先级最低，却能连续跑完整个循环。之后 waiter 才一个个 `down`，把 value 减回去。

三种场景的差别不在 semaphore 的数学定义，而在 **被唤醒的线程何时真正运行**。

---

## 6. Why does disabling interrupts while holding the lock seem to be a good idea at first?

题目给的 naive lock：

```
struct lock { }
void acquire (lock) { disable_interrupts(); }
void release (lock) { enable_interrupts(); }
```

在**单核、可抢占内核**里：

- 时钟中断是抢占的来源。关中断 → 当前线程不会被 timer 切走。
- 因此临界区里不会有别的线程交错访问同一数据结构。
- Pintos 自己的 `sema_down`/`sema_up` 正是用 `intr_disable()` 保护 wait list 和 `value` 的更新。短临界区这样又正确又简单。

看起来像「一把覆盖全机的大锁」。

---

## 7. Why is disabling interrupts actually a bad way of implementing locks?

1. **设备中断被推迟。** 锁持有期间磁盘/键盘/定时器 IRQ 进不来，延迟抖动大，长时间关中断会丢事件。
2. **临界区不能做任何可能阻塞或耗时的事。** 不能 `sema_down`，不能磁盘 I/O。用户级临界区若关中断，整机停摆。
3. **多核无效。** 关的是本 CPU 的中断，另一核仍可跑、仍可改共享数据。
4. **粒度太粗。** 不相关的临界区也被串行化。
5. **不能在用户态用。** 用户程序不该关中断。

所以：关中断只适合内核里**极短**的数据结构更新；真正给线程用的锁要用 semaphore/wait list，让等锁的人睡眠，而不是关掉全世界。

---

## 8. How are locks implemented in Pintos?

`struct lock { struct thread *holder; struct semaphore semaphore; }`。

- `lock_init`：`holder = NULL`，`sema_init(&semaphore, 1)`。
- `lock_acquire`：断言当前不是 holder（不可重入），然后 `sema_down`。成功后 `holder = thread_current()`。
- `lock_release`：断言当前是 holder，`holder = NULL`，再 `sema_up`。

Semaphore 内部：关中断，`down` 时若 `value==0` 就把当前线程放进 `waiters` 并 `thread_block`；`up` 时 `value++`，若有 waiter 则 `thread_unblock(list_pop_front)`。Starter 的 waiter 队列是 FIFO，不是按优先级——Project 1 要改这里。

---

## 9. How is the atomicity of P and V operations guaranteed?

P = `sema_down`，V = `sema_up`。两者都：

```c
old_level = intr_disable();
/* 读/改 value，操作 waiters 链表，可能 thread_block */
intr_set_level(old_level);
```

关中断保证：

- 不会在改 `value` 和 wait list 的中途被时钟中断切走；
- 外部中断处理函数也不会同时 `sema_up`（Pintos 允许中断里 `sema_up`，但不允许 `sema_down`）。

单核下这就足够原子。多核还需要 spinlock；Pintos 作业按单核模型。

`thread_block` 必须在中断关闭时调用（注释写得很清楚），否则 TOCTOU：刚看完「该睡了」就被 unblock，然后错误地睡死。

---

## 10. What is a deadlock? Give an example.

**死锁**：一组线程永远等下去，因为每个都占着别人需要的资源、又在等对方占着的资源。经典四个必要条件：互斥、持有并等待、不可抢占、**循环等待**。

Pintos 例子：

- 线程 T1：`lock_acquire(&A)` 然后 `lock_acquire(&B)`
- 线程 T2：`lock_acquire(&B)` 然后 `lock_acquire(&A)`

若 T1 已持有 A、T2 已持有 B，两人分别在 B 和 A 上 `sema_down` 阻塞，谁也不会 `lock_release`，死锁。

`priority-donate-nest` 一类测试处理的是嵌套锁 + 捐赠，不是死锁；死锁是锁顺序不一致才会出现。避免办法：全局锁顺序、try-lock、或不要同时持两把锁。
