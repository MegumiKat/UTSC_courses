# Tutorial 05：System Calls

相关代码：`src/userprog/process.c`、`syscall.c`，用户库 `src/lib/user/syscall.c`，测试 `src/tests/userprog/args.c`、`src/tests/lib.c`。系统调用号在 `src/lib/syscall-nr.h`。

---

## 1. What is the difference between the programs that we ran in Project 1 and those in Project 2?

| | Project 1 | Project 2 |
| --- | --- | --- |
| 跑在哪 | 内核线程，全程 kernel mode | **用户程序**（ELF），user mode |
| 从哪来 | `thread_create` 的 C 函数 | 文件系统里的可执行文件 |
| 地址空间 | 共用内核页表 | 每进程自己的 page directory；用户 VA 在 `PHYS_BASE` 以下 |
| 能做什么 | 直接调内核函数 | **不能**直接碰内核；必须 **syscall**（`int $0x30`） |
| 崩溃 | 可能弄坏整个内核 | 应只杀死该进程（需校验用户指针） |

Project 1 的 `alarm-*`、`priority-*` 是内核测试线程。Project 2 的 `args-*`、`halt`、`exit` 是 `pintos -p ... -q run 'args-none'` 加载的用户 ELF。

---

## 2. How does a file become a thread?

路径：

1. `process_execute(file_name)`（`process.c`）把命令行拷到一页 `fn_copy`，然后  
   `thread_create(file_name, PRI_DEFAULT, start_process, fn_copy)`。  
   此时只有一个内核线程，用户程序还没 load。
2. 新线程从 `start_process` 开始：`load(file_name, &if_)`  
   - 打开 ELF，读文件头；  
   - `pagedir_create`；  
   - 按 program header `load_segment` 把代码/数据装进用户页；  
   - `setup_stack` 映射一页用户栈。
3. 成功则把 `if_.eip` 设成 ELF entry，`if_.esp` 设成用户栈顶，然后  
   `asm("movl %0, %%esp; jmp intr_exit" :: "g"(&if_))`。  
   假装从中断返回，**`iret` 进用户态**，从 `_start` → `main` 执行。

所以「文件变成线程」= **新内核线程 + 加载 ELF + 伪造中断帧跳进用户入口**。文件本身不是线程；线程是 TCB，文件是可执行镜像。

---

## 3. Why does `args-none` not print anything?

两个独立原因叠在一起，starter 几乎必然没输出。

**原因 A：`syscall_handler` 是桩。**  
用户 `main` 里第一句常用 `msg("begin")` → `write(STDOUT_FILENO, ...)` → `int $0x30`。桩函数打印 `"system call!\n"` 然后 **`thread_exit()`**，用户 `printf` 的字符串根本不会被写到控制台。你若连 `"system call!"` 都看不到，通常是原因 B。

**原因 B：`process_wait` 立刻返回 -1。**  
`main` 线程（`init.c`）`run_task` 里 `process_execute` 之后马上 `process_wait(tid)`。Starter 的 `process_wait` **直接 `return -1`**，不等子进程。内核接着收尾并 **`shutdown`/halt**，子进程可能还没跑到 `msg`，机器已经停了。所以屏幕上经常是空的，或只有内核启动日志。

修好 wait（父进程阻塞到子进程 `exit`）之后，至少能稳定看到 `"system call!"`。再实现 `write`，才能看到 `args-none` 的 `begin/end`。

---

## 4. Change `*esp` to `PHYS_BASE - 12` and add an infinite loop to `process_wait`. What is the output now and why?

当前树里这句在 `process.c` 的 `setup_stack`：**第 440 行** `*esp = PHYS_BASE;`（handout 写 441，同一处赋值）。改成 `PHYS_BASE - 12` 等于在已清零的用户栈上留出 12 字节的 **0**。

`_start` 的 C 调用约定：`esp` 处是 `argc`，`esp+4` 是 `argv`。于是 `argc = 0`，`argv = NULL`。

父进程若在 `process_wait` 里死循环，就不会 halt，子进程能一直跑到 `main`。`args.c` **第 15 行** `msg("begin")` 仍会执行（它不依赖 argc）。`msg` → `write` → `int $0x30`。Starter 的 `syscall_handler` 于是打印：

```
system call!
```

然后 `thread_exit()`。你**不会**看到 `(args) begin` 或 argc/argv 列表，因为第一次 syscall 就被桩杀掉了。和上一题的差别是：现在至少能稳定看到这行内核打印，证明用户程序确实跑起来并陷入了 syscall。

这 12 字节的实验意义：Project 2 要求你把 `argc`、`argv` 指针、假返回地址三个 word 压进用户栈；`-12` 只是占位。真正实现还要把参数字符串和指针按文档顺序压进去。

---

## 5. Trace `args.c` and identify how the code reached `syscall_handler`.

### 5.1 Which line in `args.c` calls functions that make a syscall?

**第 15 行 `msg("begin");`** 是第一次 syscall。`msg` 在 `tests/lib.c` 里格式化后调用 `write(STDOUT_FILENO, buf, strlen(buf))`。后面的 `msg("argc = ...")`、循环里的 `msg`、以及 `main` 返回后 `_start` 里的 `exit()` 也会 syscall，但要到达 `syscall.c:18` 的断点，`args-none` 通常就停在这一次 `write` 上。

### 5.2 Where is the user-side code that invokes the syscall using an interrupt (trap)?

**`src/lib/user/syscall.c`。** `write` 调用宏 `syscall3(SYS_WRITE, fd, buffer, size)`，内联汇编：

```
push size; push buffer; push fd; push SYS_WRITE; int $0x30; addl $16, %esp
```

陷阱向量是 **`0x30`**。内核在 `syscall_init` 里注册：`intr_register_int(0x30, 3, INTR_ON, syscall_handler, "syscall")`。硬件压栈 → `intr48_stub` → `intr_entry` → `intr_handler` 查表 → **`syscall_handler(struct intr_frame *f)`**。此时 `f->esp` 指向用户栈上的 syscall 号。

---

## 6. GDB breakpoint at `syscall.c:18`. Using `x`, what is on the stack for `write`?

`syscall.c:18` 是 `printf("system call!\n");`。对 `args-none` 的第一次 syscall，这是 `write(1, buffer, size)`。

`SYS_WRITE` 在 `syscall-nr.h` 的 enum 里是第 10 项（从 0 起）：**值为 9**。

参数在**用户栈**上，指针是 `f->esp`（不要看内核 `%esp`）。GDB：

```
p f->esp
x/4xw f->esp
```

从低地址到高地址应看到：

| 地址 | 内容 | 含义 |
| --- | --- | --- |
| `f->esp + 0` | `9` | `SYS_WRITE` |
| `f->esp + 4` | `1` | `fd = STDOUT_FILENO` |
| `f->esp + 8` | 某个 `< PHYS_BASE` 的指针 | `buffer`，指向 `"(args) begin\n"` 那块用户缓冲 |
| `f->esp + 12` | 长度 | `size`（`strlen`，含换行，不含 `'\0'`） |

这与 Project 2 文档里 `write(int fd, const void *buffer, unsigned size)` 的栈布局一致：号在最下面，参数按从左到右依次往高地址放（因为 `syscall3` 是从右往左 `push`）。

若误用 `x/16xw $esp`，看到的是**内核栈**上的 `struct intr_frame`（保存的寄存器、`eip`、用户 `esp` 等），不是 syscall 参数。参数必须从 `f->esp` 读，并且先验证那是合法用户地址。
