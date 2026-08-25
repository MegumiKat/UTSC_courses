# course

Personal archive of UTSC course materials, organized by **course code**. Course folder names are not renamed.

## Layout

Each course folder contains only the directories it actually uses. Empty folders are not pre-created.

| Folder | Contents |
|---|---|
| `lectures/` | Instructor slides / original lecture PDFs |
| `notes/` | Processed study notes (English going forward). Multiple note sets live in subfolders, e.g. CSCC69 `notes/lectures/`, `notes/online/`, `notes/tutorials/` |
| `tutorials/` | Tutorial handouts |
| `labs/` | Labs |
| `assignments/` | Homework |
| `quizzes/` | Quizzes |
| `exams/` | Midterms, finals, samples, past papers |
| `readings/` / `reading-notes/` | Assigned readings and notes on them |
| `videos/` / `video-notes/` | Course videos and notes |
| `projects/` | Term projects |
| `papers/` | Essays |
| `presentations/` | Talks / debates |
| `textbooks/` | Textbooks |
| `resources/` | Screenshots, data, tools, misc. |

Every course has a `README.md` with the official [UTSC Academic Calendar](https://utsc.calendar.utoronto.ca/) description and the folders that exist for that course.

## Courses

- **CSC**: `CSCA08`, `CSCA67`, `CSCB07`, `CSCB09`, `CSCB36`, `CSCB48` (CSCA48 materials), `CSCB58`, `CSCB63`, `CSCC01`, `CSCC09`, `CSCC10`, `CSCC24`, `CSCC37`, `CSCC43`, `CSCC63`, `CSCC69`, `CSCC73`, `CSCD03`
- **Other**: `CITA01`, `EESA06&11`, `LINA01`, `MATA 31 & 37`, `MATA22`, `MATB41`, `MDSA01`, `MGEA02`, `PSYA02`, `STAA57`, `STAB52`

Open the course folder and read its README for what the course covers and which subfolders exist.

## How to use

- After cloning or pulling, open the relevant course folder.
- For projects with build/run steps (Node, Java, Haskell, Pintos), `cd` into `projects/` or `labs/` and follow the local documentation.

## Git notes

- `.gitignore` excludes system cruft (e.g. `.DS_Store`) and very large local assets that exceed GitHub’s per-file limit. If those paths exist only on your machine, they are intentionally not pushed—this is expected.

## Copyright and academic integrity

Course materials remain the property of the institution and instructors. Do not use this repo in ways that violate your program’s academic-integrity rules. This archive is for personal study only.
