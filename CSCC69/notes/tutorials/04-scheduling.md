# Tutorial 04：Scheduling

相关测试：`src/tests/threads/priority-donate-one.c`、`priority-donate-multiple.c`。优先级常量在 `thread.h`：`PRI_MIN = 0`，`PRI_DEFAULT = 31`，`PRI_MAX = 63`。

---

## 1. What is the current scheduling strategy of Pintos? Where is it implemented?

**时间片轮转（round-robin）+ FIFO 就绪队列。**

- 就绪线程放在 `ready_list`。`next_thread_to_run()` 永远 `list_pop_front`；空则跑 idle。
- `thread_yield()` 把当前线程 `list_push_back` 再 `schedule()`。
- 时钟：`TIME_SLICE = 4` tick。`thread_tick()` 里 `thread_ticks >= TIME_SLICE` 则 `intr_yield_on_return()`。

实现位置：`thread.c` 的 `next_thread_to_run`、`schedule`、`thread_yield`、`thread_tick`；中断返回路径在 `interrupt.c` 的 `intr_handler`。

这是 **不看优先级的 RR**。Project 1 要改成严格优先级，必要时 round-robin 只发生在同优先级之间。

---

## 2. How is the `priority` variable used?

Starter 里 `priority` **只被存起来、几乎不被调度器读**。

会用到它的地方：

- `init_thread` / `thread_create` 写入；
- `thread_get_priority()` / `thread_set_priority()` 读写；
- 测试打印 `thread_get_priority()`。

**不会用到的地方：** `next_thread_to_run()`、`sema_up` 选哪个 waiter、ready 队列插入位置。所以高优先级线程可以在 ready 队列里排在低优先级后面，一直等时间片轮转。这就是你要改的核心。

---

## 3. How many priority levels are there? Which one is the highest and which one is the lowest?

一共 **64 级：0 到 63**。

- 最低：`PRI_MIN = 0`
- 默认：`PRI_DEFAULT = 31`
- 最高：`PRI_MAX = 63`

数字越大越优先。这和 Unix nice 值相反。

---

## 4. Could you think of a scenario where a thread H with a high priority would starve, even though it is the highest-priority thread in the system?

**优先级反转（priority inversion）。**

1. 低优先级 L 拿到 lock A，在临界区里运行。
2. 高优先级 H 需要 A，`lock_acquire` 失败，阻塞。
3. 中优先级 M **不需要这把锁**，但优先级比 L 高。调度器总跑 M（以及任何其他中优先级线程）。
4. L 得不到 CPU，无法 `lock_release`，H 就一直阻塞。

此时系统里「真正最高优先级的可运行线程」看起来像是 M，但 H 才是最高，它却在等一把被 L 拿着、L 又跑不了的锁。H **饥饿**。即使没有 M，RR 下 L 也可能很慢才轮到；有 M 时则可能几乎永远等不到。

---

## 5. How can we fix this problem?

**优先级捐赠（priority donation）。**

H 阻塞在 L 持有的锁上时，把 H 的优先级「借」给 L（以及 L 正等着的锁的持有者，要**嵌套/链式**捐赠）。L 的 **effective priority** 变成 max(自己的 base，所有捐赠)。于是 L 能抢过 M，尽快跑完临界区、放锁。锁释放后 L 收回捐赠，优先级回到 base；H 被唤醒并以高优先级运行。

还需要：

- 一把锁多个 waiter 时，捐赠的是其中最高的那个；
- 持有多把锁时，effective = max(所有 waiter 的捐赠, base)；
- `lock_release` 只丢掉那一把锁带来的捐赠。

这正是 `priority-donate-one`、`priority-donate-multiple`、`priority-donate-nest`、`priority-donate-chain` 在测的东西。

---

## 6. What should `priority_donate_one.c:35` print?

时间线（main 初始优先级 31，先 `lock_acquire(&lock)`）：

1. 创建 `acquire1`，优先级 `PRI_DEFAULT+1 = 32`。它立即想拿同一把锁，阻塞，并向 main **捐赠 32**。
2. 第 35 行：

```c
msg ("This thread should have priority %d.  Actual priority: %d.",
     PRI_DEFAULT + 1, thread_get_priority ());
```

应打印：**This thread should have priority 32.  Actual priority: 32.**

`thread_get_priority()` 必须返回 **effective** 优先级 32，不是 base 31。若仍打印 31，说明还没做捐赠。

---

## 7. After the `lock_release` (`priority_donate_one.c:40`), which thread should get the lock? What should the priority of the main thread be?

第 40 行 `lock_release` 之前，main 还创建了 `acquire2`（优先级 33）。两人都等这把锁。释放时必须把锁给 **优先级最高的 waiter = acquire2（33）**。

Main 不再持锁，来自 acquire1/acquire2 的捐赠消失，**main 的优先级回到 31**（`PRI_DEFAULT`）。

测试期望的输出顺序（见 `.ck`）：acquire2 先跑完并打印它拿到了锁，然后 acquire1，然后 main 继续打印「acquire2 应已结束」以及 priority 31。

若 `sema_up` 仍 FIFO，会先唤醒 acquire1（先等的那个），测试失败。

---

## 8. (Multiple donations) What should line `priority_donate_multiple.c:39` and line `42` print out and why?

当前文件对应代码：

```c
thread_create ("a", PRI_DEFAULT + 1, a_thread_func, &a);  /* 32, 约第 38 行 */
msg ("Main thread should have priority %d.  Actual priority: %d.",
     PRI_DEFAULT + 1, thread_get_priority ());            /* 第 39–40 行 */

thread_create ("b", PRI_DEFAULT + 2, b_thread_func, &b);  /* 33, 第 42 行 */
msg ("Main thread should have priority %d.  Actual priority: %d.",
     PRI_DEFAULT + 2, thread_get_priority ());            /* 第 43–44 行 */
```

第 42 行本身是 `thread_create`，不打印。Handout 的 “line 39 and line 42” 指的是 **创建 a 之后那句 msg，以及创建 b 之后那句 msg**（有的版本第二句 msg 就在 42 行附近）。

- **第 39 行那句：** Main 已持有锁 a 和 b。线程 a（32）一创建就会去 `lock_acquire(&a)`，失败并阻塞，向 main 捐赠 32。  
  应打印：`Main thread should have priority 32.  Actual priority: 32.`
- **创建 b 之后那句：** 线程 b（33）阻塞在锁 b 上。effective = max(32, 33) = 33。  
  应打印：`Main thread should have priority 33.  Actual priority: 33.`

若第二句仍是 32，说明多把锁的捐赠没有取 max。

---

## 9. What about line 48?

```c
lock_release (&b);
msg ("Thread b should have just finished.");
msg ("Main thread should have priority %d.  Actual priority: %d.",
     PRI_DEFAULT + 1, thread_get_priority ());
```

释放锁 b 后：线程 b 拿到 b、跑完（优先级 33，会立刻抢过 main）。b 结束。Main 仍持有锁 a，线程 a 仍在等 a，所以捐赠 **32 还在**。

第 48 行应打印：**priority 32 / actual 32**（`PRI_DEFAULT+1`）。

若释放 b 后误把优先级直接打回 31，说明多把锁的捐赠没有分开记账。
