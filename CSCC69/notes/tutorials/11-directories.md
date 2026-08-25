# Tutorial 11：Directories

对应 Project 4 的层次目录。Starter 只有一个根目录，目录就是「名字 → inode 号」的文件。

---

## 1. What is a directory?

**目录是一种特殊文件**，内容是目录项列表。每项至少：

- 文件名（Pintos 里 14 字节左右，见 `struct dir_entry`）；
- inode 序号（`inumber`）；
- in-use 标志。

打开路径 `/a/b` 的过程就是：从某个起始目录 inode 起，按名字查下一级 inode。目录也占数据块，也有 inode，所以才能嵌套。`.` 指向自己，`..` 指向父目录（根的 `..` 指向自己）。

---

## 2. What is a subdirectory?

出现在另一个目录的目录项里、且类型为目录的那个 inode，叫做**子目录**。例如 `/usr/bin` 里 `bin` 是 `usr` 的 subdirectory。层次文件系统 = 目录树（有 `..` 时严格说是有向图，但通常当树用）。

---

## 3. What is a path?

**路径**是用分隔符 `'/'` 串起来的一串目录/文件名，用来从起点走到目标。Pintos 与 Unix 一样：空分量或多余 `/` 的处理要在实现里定义清楚；`/` 本身表示根。

分两种：

- **绝对路径：** 以 `/` 开头，从根目录走；
- **相对路径：** 不以 `/` 开头，从**当前工作目录**走。

---

## 4. Where does `/a/b/c` point to?

**绝对路径。** 从根目录找名字 `a`（必须是目录），再在其中找 `b`，再找 `c`。`c` 可以是文件或目录。任一分量不存在、或中间分量不是目录，路径非法。

---

## 5. Where does `./d/e/f` (or `d/e/f`) point to?

**相对路径，相对于当前工作目录（cwd）。**

- `d/e/f`：cwd 下的 `d` → `e` → `f`；
- `./d/e/f`：`.` 就是 cwd，结果相同。

若 cwd 是 `/home/user`，则两者都指 `/home/user/d/e/f`。

---

## 6. Where does `../g/h/i` point to?

`..` 是 cwd 的**父目录**。从父目录再走 `g/h/i`。

若 cwd = `/home/user`，则 `../g/h/i` = `/home/g/h/i`。若 cwd 已经是根，`..` 仍是根，结果是 `/g/h/i`。

---

## 7. Where is the information about the current directory stored?

必须**按进程（线程）存**，不能是全局变量，否则所有进程共享一个 cwd。

Pintos Project 4：加在 **`struct thread`**（或你的 PCB）里，典型是：

- `struct dir *cwd`，或
- cwd 的 `inumber`，用时再 `dir_open`。

内核启动时 `main` 的 cwd 是根。注意：cwd 也占一次 inode/dir open，进程退出要 `dir_close`，否则 inode 引用计数泄漏。

---

## 8. What should it be set to for a newly created thread?

**继承父进程的 cwd。** `process_execute` / `thread_create` 子用户进程时，把父的目录再 `dir_reopen`（或拷 inumber 再打开）给子进程。不要所有新线程都回到根——否则相对路径没意义，也不符合 Unix。

内核里非用户的测试线程没有用户 cwd；这题针对用户进程。

---

## 9. When can you remove a directory?

可以 `remove` 一个目录，当且仅当：

1. 它存在并且**是目录**；
2. **为空**（除 `.`、`..` 外没有目录项）；
3. 不是 `.` / `..` 本身；
4. **不是根目录**。

关于 **cwd**：Pintos 官方测试 `dir-rm-cwd` **两种实现都给分**——

- **拒绝删除 cwd**（更常见、也更好讲）：`remove` 返回 false，之后仍可 `open(".")`；
- **允许删除 cwd**：之后 `open("/a")`、`open(".")`、`create` 都必须失败。

课堂简答通常写：**空目录、非根、且不是任何进程的当前工作目录。** 若允许删 cwd，必须保证名字已经从父目录消失，且不能再通过 `.` 创建新文件。

正在被 `open` 的目录：`dir-rm-cwd` 在「拒绝」分支里要求 `remove` 在仍有 fd 打开时失败。实现上用 inode `open_cnt` 即可。
