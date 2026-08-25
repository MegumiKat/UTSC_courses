# course

按课号归档的 UTSC 课程材料。**课程文件夹名称不改。**

## 目录约定

每门课只建实际用到的文件夹，不预建空目录：

| 文件夹 | 内容 |
|---|---|
| `lectures/` | 老师原始讲义 / slides |
| `notes/` | 整理后的笔记（之后新写用英文）。多套笔记放在子目录，例如 CSCC69 的 `notes/lectures/`、`notes/online/`、`notes/tutorials/` |
| `tutorials/` | Tutorial 原始讲义 |
| `labs/` | 实验 |
| `assignments/` | 作业 |
| `quizzes/` | 小测 |
| `exams/` | 期中、期末、样卷、真题 |
| `readings/` / `reading-notes/` | 课程阅读原文与阅读笔记 |
| `videos/` / `video-notes/` | 视频材料与笔记 |
| `projects/` | 学期项目 |
| `papers/` | Essay |
| `presentations/` | 展示 / 辩论 |
| `textbooks/` | 教材 |
| `resources/` | 截图、数据、工具、杂项 |

每门课都有 `README.md`，内含 [UTSC Academic Calendar](https://utsc.calendar.utoronto.ca/) 的官方课程说明和本课实际目录。

## 课程列表

- **CSC**：`CSCA08`、`CSCA67`、`CSCB07`、`CSCB09`、`CSCB36`、`CSCB48`（材料为 CSCA48）、`CSCB58`、`CSCB63`、`CSCC01`、`CSCC09`、`CSCC10`、`CSCC24`、`CSCC37`、`CSCC43`、`CSCC63`、`CSCC69`、`CSCC73`、`CSCD03`
- **其他**：`CITA01`、`EESA06&11`、`LINA01`、`MATA 31 & 37`、`MATA22`、`MATB41`、`MDSA01`、`MGEA02`、`PSYA02`、`STAA57`、`STAB52`

打开对应课程文件夹，先看该课的 README。

## 使用

- clone / pull 之后进入相关课程文件夹。
- 有独立构建步骤的项目（Node、Java、Haskell、Pintos）进入 `projects/` 或 `labs/`，按当地文档运行。

## Git

- `.gitignore` 排除系统垃圾（如 `.DS_Store`）以及超过 GitHub 单文件限制的本地大文件。这些路径若只存在于本机、未推送，是预期行为。

## 版权与学术诚信

课程材料仍属于学校与授课教师。请勿以违反学术诚信规定的方式使用本仓库。本归档仅供个人复习。
