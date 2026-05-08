---
name: homework-report
description: Use after grade-homework to produce a teacher-facing Typst PDF report that shows each student's submission images side-by-side with their per-question marks, feedback, and flags. Triggers on phrases like "generate the grading report", "build a report from the marks", "make a PDF with the marked homework".
---

# homework-report

## When to use

- After `grade-homework` has written `grades/grades.csv` and `grades/feedback/*.md`.
- User wants a single shareable PDF (for review, return to students, or archive) that shows the original submission next to the grading decisions.

Do NOT use for:

- Grading itself (use `grade-homework`).
- Individual student feedback only (the markdown in `grades/feedback/<student>.md` is already that).

## What this skill produces

- `report/images/<student>-N.jpg` — one image per submission page, converted / copied from the student's original files.
- `report/grading_report.typ` — the Typst source, overwritable and hand-editable.
- `report/grading_report.pdf` — compiled report, one page per student.

## Prerequisites

- `typst` on PATH (via `cargo install typst-cli` or the Typst releases).
- `pdftoppm` (poppler-utils) for PDF→image.
- Optional: `libreoffice`/`soffice` OR `pandoc + google-chrome/chromium` for DOCX submissions (shared toolchain with `grade-homework`).

## Workflow

Skill root: `~/.claude/skills/homework-report/`.

### Step 1 — Run the builder

```bash
python ~/.claude/skills/homework-report/scripts/build_report.py "$PWD"
```

The script:

1. Reads `grades/grades.csv` and each `grades/feedback/<student>.md`.
2. Recursively discovers each student's submission files under `$PWD` (reusing `grade-homework`'s `discover.py`).
3. For each student, converts submission files to page images via `grade-homework`'s `to_images.py`, and copies them into `report/images/`.
4. Emits `report/grading_report.typ` with a per-student spread: submission images on the left, score table + feedback markdown + flags on the right.
5. Compiles `grading_report.pdf` if `typst` is on PATH; otherwise leaves the `.typ` file and prints the compile command.

### Step 2 — Inspect and hand off

Open `report/grading_report.pdf`, spot-check a few students' rendering (especially any with rotated phone photos or DOCX originals), and send to the teacher.

If the rendering is off for a particular student (images rotated wrong, pages missing), delete their entry from `report/images/` and re-run — the script is idempotent.

## Flags / failure modes

- **`grades/grades.csv` missing** → stop and tell the user to run `grade-homework` first.
- **Feedback file missing for a student in the CSV** → include the student with scores only; note in output that feedback was missing.
- **DOCX submission and no conversion toolchain** → that student's section shows a placeholder instead of images; the score table and feedback still render.
- **`typst` not installed** → script writes the `.typ` source and exits cleanly with instructions.

## Customization

The Typst template is inlined in `build_report.py` (function `render_typst`). Edit that function to change layout, colors, per-part weights display, or to add a class-level score histogram. The template uses only the Typst standard library — no external packages — so compilation is offline.
