# GDB Notes

GDB = GNU Debugger，支持 C/C++。编译必须加 `-g`：

```bash
gcc -g program.c -o program
gdb ./program
```

**Breakpoint** 像代码里的停车牌：碰到就停，方便检查状态。

## 命令速查

| 类别 | 命令 | 作用 |
| --- | --- | --- |
| 帮助 | `help` | 列出命令主题 |
| | `help class` | 列出某类命令 |
| | `help command` | 某条命令的说明 |
| 运行 | `run` / `r` | 从头跑程序 |
| | `run args` | 带命令行参数跑 |
| | `run < file` | 从文件重定向输入 |
| | `q` / `quit` | 退出 GDB |
| | `kill` | 停掉当前被调试进程 |
| 断点 | `break line` / `break func` | 在行号或函数处停下 |
| | `delete N` | 删指定断点 |
| | `delete` / `d` | 删全部断点 |
| | `clear func` / `clear line` | 清该函数/行上的断点 |
| 单步 | `continue` / `c` | 跑到下一个断点 |
| | `next` / `n` | 下一行，**不进入**函数 |
| | `step` / `s` | 下一行，**进入**函数 |
| | `until N` | 跑到指定行。循环末尾用 `until` 会跳出循环，`next` 只会回到循环头 |
| | `finish` | 跑到当前函数返回 |
| 查看 | `where` | 当前行号和所在函数 |
| | `print var` | 打印变量 |
| 栈 | `up` / `down` | 在调用栈上移/下移一帧 |
| | `up N` / `down N` | 移动 N 帧 |

Pintos 里还常用 `backtrace` / `bt`（看当前线程内核栈）和 `x/Nw addr`（按 word 看内存）。
