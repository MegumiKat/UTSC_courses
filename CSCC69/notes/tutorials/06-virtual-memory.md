# Tutorial 06：Virtual Memory

`PHYS_BASE = 0xc0000000`（3 GB）。用户虚拟地址 `< PHYS_BASE`，内核虚拟地址 `>= PHYS_BASE`。用户栈从 `PHYS_BASE` 向下长。

Tutorial 开头的几条事实（答题时要用到）：

- 汇编里出现的地址**全部是虚拟地址**；物理地址只给 MMU/页表用。
- VA→PA 由 MMU 按页目录翻译；页目录位置在 **`%cr3`**。
- 内核页目录覆盖全部物理内存，所以内核 VA 几乎都合法；用户页表是稀疏的，没映射的地址非法。
- **同一个页号在内核页表和用户页表里可以指向不同物理页。** 因此用户栈顶 `PHYS_BASE` 作为用户 VA 是栈，作为内核 VA 却是物理地址 0 的映射。

Handout 里有一张压栈示意图（`media/example.png`）：字符串在高地址，然后是对齐、`NULL`、`argv[]` 指针、`argv`、`argc`、假返回地址，`esp` 最低。

---

## 1. Where are the command line arguments stored initially?

`process_execute(const char *file_name)` 里，内核把整串命令行（例如 `"args-single onearg"`）**拷到一页内核内存** `fn_copy = palloc_get_page(0)`，再把这个指针当 `aux` 传给 `start_process`。

这页在内核地址空间，用户程序看不见。`load()` / `setup_stack()` 必须把参数**再拷到用户栈**上，然后 `palloc_free_page(fn_copy)`。若只把内核指针当 `argv` 交给用户，用户一解引用就会 page fault（或你必须拒绝非法指针）。

---

## 2. In what order should they be pushed onto the stack of the thread?

Pintos 文档规定，栈从高地址向低地址压。最终布局（高地址在上）：

```
PHYS_BASE
  word-aligned 参数字符串（最后的参数在更高地址）
  0–3 字节填充，使接下来的指针 4 字节对齐
  NULL          /* argv[argc] */
  argv[argc-1]
  ...
  argv[0]       /* 指向各自字符串 */
  argv          /* 指向 argv[0] 这个指针 */
  argc
  fake return address  (0)
  <--- 最终 esp
```

约定：

- 字符串本身按参数顺序放，但因为栈向下长，**先拷最后一个参数字符串**更方便。
- `argv[i]` 是用户虚拟地址，不是内核地址。
- `argc` 是整数；`argv` 是 `char**`。
- fake return 是因为 `_start` 用 C 调用约定调 `main`，`main` 若 ret 会弹这个值；随后 `_start` 再 `exit`。

`args-none`：`argc=0`，`argv` 指向一个只有 NULL 的指针数组。`args-single onearg`：`argc=1`，`argv[0]` 指向 `"onearg"`。可执行文件名是 `argv[0]`。

---

## 3. Who sets up the stack? How are the pages allocated?

**`setup_stack(void **esp)`**（`process.c`），由 **`load()`** 在装完 ELF segment 之后调用，再由 **`start_process`** 间接调用。

Starter 只做：

```c
kpage = palloc_get_page(PAL_USER | PAL_ZERO);
install_page(((uint8_t *) PHYS_BASE) - PGSIZE, kpage, true);
*esp = PHYS_BASE;
```

- `PAL_USER`：从 **user pool** 拿物理页。  
- `PAL_ZERO`：清零。  
- `install_page`：在**当前进程的 page directory** 里把用户 VA `PHYS_BASE-PGSIZE` 映射到该帧，可写。

你要在这页上（必要时再扩展）按第 2 题把参数压好，最后把 `*esp` 设成 fake return 的地址。一页 4 KB 通常够命令行；参数极长时应失败而不是溢出到内核。

---

## 4. In user mode, what is the virtual address at which the stack of a thread starts?

**`PHYS_BASE`，即 `0xc0000000`。** 栈向低地址增长。第一页覆盖 `[0xbffff000, 0xc0000000)`。用户能合法使用的最高字节是 `PHYS_BASE-1`。`*esp = PHYS_BASE` 表示「空栈」，第一次 `push` 会先减 esp 再写，写在 `0xbffffffc` 这类地址上。

每个用户线程/进程在 Pintos Project 2 里其实是单线程进程，所以「线程的用户栈」就是这个进程的用户栈。内核栈是另一回事：在 TCB 那一页的顶端，和 `PHYS_BASE` 无关。

---

## 5. What is the (virtual) address of the beginning of the stack when the kernel is setting/accessing that stack in kernel mode?

**不是 `PHYS_BASE`。** Hint 说的就是这件事：用户页表里页号 `x` 和内核页表里的页号 `x` 可以对应不同物理页。

- 用户栈那一页的**用户 VA** 是 `PHYS_BASE - PGSIZE`（`0xbffff000`）。
- 该页的物理地址是某帧 `P`。内核把**全部物理内存**线性映射在 `PHYS_BASE + P`。所以内核要读写这页内容，用的是 **`kpage = pagedir_get_page(pd, user_va)`**，其值等于 `ptov(P) = PHYS_BASE + P`，例如 `0xc00xxxxx`，**绝不是**把 `0xc0000000` 当指针解引用（那是 PA 0）。

两种实际场景：

1. **`setup_stack` 正在搭栈：** `palloc_get_page` 返回的就是这个 `kpage`。通过 `kpage` 写参数字节，同时把用户 `*esp` 设成用户 VA。
2. **syscall 里访问用户栈：** 当前 `%cr3` 虽是该进程页目录，直接解引用用户指针在 mapped 时偶尔能工作，但 Pintos 要求用 `pagedir_get_page` 转成内核 VA，并先做合法性检查。Project 3 还要 pin，防止访问中途被换出。

所以答案：内核模式下，这页栈的虚拟地址是 **该物理帧的内核别名**（`pagedir_get_page` / `kpage`），与用户模式下的 `PHYS_BASE` 不是同一个 VA。

---

## 6. Where is the page directory stored?

每个进程一份，挂在 **`struct thread` 的 `pagedir` 字段**（`thread.h`，userprog 打开时编译进来）。类型是 `uint32_t *`，指向该进程页目录的内核地址。

硬件当前用的页目录在 **`%cr3`**。切换进程时 `process_activate()` → `pagedir_activate(t->pagedir)` 把 `cr3` 换成这个目录的物理地址。内核页（`>= PHYS_BASE`）在所有进程的页目录里共享同一套映射，所以内核代码在进程切换后仍可执行。

---

## 7. Which function do you use to translate a user address into a kernel address?

**`pagedir_get_page(uint32_t *pd, const void *uaddr)`**（`userprog/pagedir.c`）。

```c
void *kva = pagedir_get_page(thread_current()->pagedir, user_vaddr);
if (kva == NULL) /* 未映射或非用户地址 */
```

`pagedir_get_page` 内部：走页目录/页表，若 PTE present，把物理地址 `pte_get_page(pte)` 再 **`ptov`** 成内核 VA。

注意：

- 只转换 **一页内的一个地址**；跨页缓冲区要对每个页做一次。
- `is_user_vaddr(u)` 必须先成立（`u < PHYS_BASE`），否则用户把内核地址塞进来会绕过保护。
- 转换后的 `kva` 仅当该页仍映射时有效；之后若有 eviction（Project 3）还要 pin。

---

## 8. How can we tell if a user virtual address is valid?

必须**全部**满足，缺一不可：

1. 指针非 NULL（Pintos 文档要求拒绝 `addr == 0` 一类）。
2. **`is_user_vaddr(u)`**：`u < PHYS_BASE`。高于等于 `PHYS_BASE` 是内核空间，用户永远不合法。
3. **当前进程页表里有映射**：`pagedir_get_page(pd, u) != NULL`。未映射 → page fault。Project 3 还要查 supplemental page table：可能合法但尚未装入，应 fault in 而不是杀进程。
4. 若访问长度为 `size` 的缓冲区，检查 **`[u, u+size)` 覆盖的每一页**，不能只查第一个字节。
5. 写操作还要看 PTE/SPT 的 writable 位。

实现上常见两种：访问前主动 `pagedir_get_page` 扫描；或依赖 page fault，在 fault 里若地址非法则 `exit(-1)`。无论哪种，**绝不能让内核因用户指针而 kernel panic**。
