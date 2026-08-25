# Tutorial 10：Indexed Files

对应 Project 4 文件系统。Pintos：**1 disk sector = 1 block = 512 bytes**。块指针是 4 字节，因此一个索引块能装 **512/4 = 128** 个指针。

Starter inode（`inode.c` 的 `struct inode_disk`）几乎是连续分配：`start` + `length`，中间一堆 `unused`。作业要改成索引分配。

---

## 1. What is an inode?

**Inode（index node）** 是文件的元数据对象，**不含文件名**（名字在目录项里）。磁盘上的 inode 通常记录：

- 文件长度；
- 类型（普通文件 / 目录）；
- 指向数据块的指针（直接、间接、…）；
- 可选：时间戳、硬链接计数。

Pintos 内存里还有 `struct inode`（打开计数、锁、指向 `inode_disk` 的缓存）。`inode_read_at` / `inode_write_at` 靠 inode 把文件偏移换成扇区号。

---

## 2. How can we find the data blocks of a file?

**Starter（连续分配）：** 数据从 `inode_disk.start` 起连续 `bytes_to_sectors(length)` 个扇区。第 `pos` 字节在扇区 `start + pos/512`。简单，但文件不能在中间插入空闲洞，也很难增长。

**索引分配（作业目标）：** inode 里存指针：

- 直接指针：立刻给出数据扇区号；
- 间接：指向一个全是数据指针的块；
- 双重间接：指向一个全是间接块指针的块。

查找偏移 `pos`：算出第几个逻辑块 `pos/512`，再按「直接 / 间接 / 双重间接」的编号范围走路。块按需 `free_map_allocate`，文件才能稀疏增长。

---

## 3. What are bitmaps? How are they implemented in Pintos?

**Bitmap** 用每位 0/1 表示集合中第 n 个元素空闲/占用。文件系统用它跟踪空闲扇区、有时也跟踪 inode。

Pintos：`src/lib/kernel/bitmap.{h,c}`。`struct bitmap` 含 `bit_cnt` 和 `elem_type *bits`（每个 elem 是一串机器字）。文件系统 **`free-map.c`** 用一张 bitmap 表示整个磁盘哪些扇区已分配；文件 `bitmap` 存在 `FREE_MAP_SECTOR`。

常用接口：`bitmap_mark` / `reset` / `flip` / `test` / `scan_and_flip`（找连续 k 个 0 并置 1）。

---

## 4. How can we set the nth bit in a bitmap?

按字节理解（教学常用）：`byte = n / 8`，`off = n % 8`（LSB 为 bit 0）：

```c
map[n / 8] |= (1u << (n % 8));
```

Pintos 实际用 `unsigned long` 作元素：`bits[n / ELEM_BITS] |= 1ul << (n % ELEM_BITS)`，封装为 **`bitmap_mark(b, n)`**。已经是 1 再 set 仍是 1。

---

## 5. How can we unset the nth bit in a bitmap?

```c
map[n / 8] &= ~(1u << (n % 8));
```

Pintos：**`bitmap_reset(b, n)`**。释放扇区时用这个。

---

## 6. How can we toggle the nth bit in a bitmap?

```c
map[n / 8] ^= (1u << (n % 8));
```

Pintos：**`bitmap_flip(b, n)`**。`scan_and_flip` 找到空闲位后也会 flip 成占用。

---

## 7. What is a bitmask?

**Bitmask** 是用来挑选或过滤某些位的二进制模式。上面的 `(1u << (n % 8))` 就是「只影响第 n%8 位」的 mask。更一般地：`flags & MASK` 取出一组标志，`flags | MASK` 打开，`flags & ~MASK` 关闭。Inode 权限位、PTE 的 present/rw 位都是 bitmask。

---

## 8. In the original Pintos design, data is stored in contiguous blocks. What are the two major drawbacks?

Starter inode 只存 `start`（第一扇区）和 `length`，数据必须占一段连续扇区。两大缺陷：

1. **外部碎片：** 空闲扇区总量够，但没有连续的足够大的洞，大文件创建失败。删除文件会留下不规则空洞，之后更难匹配。
2. **文件难以增长：** 紧挨着的后面一块若已被占用，无法 append；创建时又不知道最终大小，预留过大则浪费，预留过小则无法扩展（除非整文件搬迁）。

顺序读很快是唯一优点，但过不了 Project 4 的 grow 类测试。

---

## 9. According to the Pintos documentation, what is the solution to the problems in question 6?

Handout 写 “question 6” 是笔误，对应的是 **第 8 题（连续分配）**。文档要求改成 **索引 inode**：

- inode 里放若干 **direct** 指针、一个 **indirect**、一个 **doubly-indirect**；
- 逻辑块号 → 走路得到数据扇区；缺失指针为 0 表示尚未分配；
- 写入超出 EOF 时按需 `free_map_allocate`，文件可以稀疏增长；
- 删除时沿指针树释放数据块和索引块。

这直接消灭外部碎片（块不必相邻）和增长问题（不必预留连续区间）。

---

## 10. What is the maximum size of a file that can be represented by an inode if we only use a single doubly-indirect pointer in the inode?

只有 **一个双重间接指针**，没有直接/单间接：

- 双重间接块里有 **128** 个指针，每个指向一个间接块；
- 每个间接块再有 **128** 个数据块指针；
- 每数据块 **512 B**。

\[
128 \times 128 \times 512 = 8\,388\,608 \text{ 字节} = 8 \text{ MB}
\]

这是「仅一棵两层索引树、块大小 512、指针 4 字节」的上限。若再加直接指针，最大文件会更大；本题故意只算双重间接那一部分。

---

## 11. Why do we also need direct and indirect pointers?

**大多数文件很小。** 若只有双重间接：即使读第 1 个字节也要 **3 次磁盘访问**（双重间接块 → 间接块 → 数据块），延迟差。

加上：

- **直接指针：** 小文件一次读 inode 就能拿到数据块号（inode 通常已在内存）；
- **单间接：** 中等文件多一次索引读取，仍远小于双重间接。

这是空间/速度折中：inode 里用几十个字节换来小文件的快路径。Unix FFS、ext2 都是 12 direct + 1 indirect + 1 double（+ 有的有 triple）。Pintos 作业同样建议这种形状。
