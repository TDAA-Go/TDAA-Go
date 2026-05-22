# TDAA-Go

A forkable, ready-to-launch skeleton for **Test-Driven, AI-Assisted (TDAA)**
courses. Weekly learning sheets, closed-book tests, validation sets, and a
static website — all written in Typst, built by `make`, deployed to GitHub
Pages, and driven by Claude Code skills.

> **TDAA in one sentence.** Students may use AI to *prepare*, but frequent
> closed-book tests require them to think *unaided*. TDAA-Go is the
> course-materials harness that makes the gate livable for students and the
> production tractable for instructors.

## Quick start

```bash
gh repo create my-course --private --template GiggleLiu/TDAA-Go --clone
cd my-course
claude              # then in Claude Code:
> /bootstrap        # asks a few questions, writes config.toml, extracts the textbook
> /generate-week 1
```

Need anything else installed (Typst, `uv`, `gh`)? `/bootstrap` probes and
offers the right install command for your platform.

## Documentation

The full instructor guide lives in the deployed site. After `make build`,
open `_site/instructor-guide.html` (or `make serve` and visit
<http://localhost:8000/instructor-guide.html>). It covers install, fork,
bootstrap, generate, the review habit, publish, the weekly classroom rhythm,
and grading. Students get a parallel `student-guide.html`; the method itself
is on `about.html`.

## Skills

| Skill | When to use |
|-------|-------------|
| `/bootstrap` | Once, right after forking |
| `/generate-week N` | Full week pipeline (learning sheet + tests, with reviewer debate) |
| `/write-learning-sheet N` | Just the learning sheet |
| `/review-learning-sheet N` | Audit against pedagogical criteria |
| `/revise N` | Interactive chunk-by-chunk polish + test audit |
| `/write-tests N` | Generate tests from a finalized learning sheet |
| `/review-tests N` | Audit tests for scope and correctness |
| `/grade-homework` | Grade a folder of student submissions |
| `/homework-report` | PDF report from grading output |
| `/learn N` | Student-side: walk through a learning sheet interactively |
| `/pivot N` | Re-skin a learning sheet's task to a new context |

## Build commands

```bash
make build              # PDFs + HTML viewers + guides
make serve              # build, then http://localhost:8000
make compile-tests      # test/validation PDFs
make dump-solutions     # same, solutions visible
make clean              # remove _site/
```

Single file: `typst compile --root . weekN/N.learning-sheet.typ`.

## Layout

```
config.toml.example                  # Edit (or run /bootstrap) → config.toml
config.typ                           # Shim that loads config.toml for templates
Makefile                             # make build / make serve
templates/                           # Shared Typst libs (learning-sheet, test, week-template/)
coursedesign/
├── weekly-materials-guide.md        # Pedagogical principles & checklists
├── schedule.example.typ             # Example schedule (bootstrap fills the real one)
└── release-schedule.example.json    # Example Zulip release schedule
.github/
├── templates/                       # index, viewer, about, instructor-guide, student-guide, styles.css
└── workflows/                       # deploy-pages.yml, release-materials.yml (Zulip drip, optional)
.claude/                             # CLAUDE.md, rules/, skills/
```

After bootstrap, you'll also have `config.toml`, `textbook/NN.md` (extracted
chapters), `coursedesign/schedule.typ`, and `weekN/` (per-week materials).

## Citing TDAA

If TDAA-Go shapes a course you teach or a paper you write, please cite:

> Jin-Guo Liu, Shang-Qi Lu, Xin-Ran Shi, Long-Li Zheng and Wei Wang.
> *High-Frequency Test-Driven Learning with AI: Making Strict Quality Gates
> Acceptable and Scalable.* DSAA 3071, HKUST(GZ), Spring 2026.
