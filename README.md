# Course Template

A forkable skeleton for AI-assisted course materials: weekly learning sheets,
tests, validation sets, and a static website. Built on Typst + GitHub Pages,
designed to be driven by Claude Code skills.

## What you get

- **Weekly materials pipeline** — learning sheet, test, test variant B, and
  validation set per week; intro slides; optional research-track advanced
  learning sheet
- **Claude Code skills** — `/bootstrap`, `/generate-week`, `/write-learning-sheet`,
  `/review-learning-sheet`, `/write-tests`, `/review-tests`, `/revise`,
  `/grade-homework`, `/homework-report`, `/learn`, `/pivot`
- **Build infrastructure** — `make build` compiles every `.typ` to PDF and a
  GitHub Pages viewer; `make serve` previews locally
- **Optional Zulip release workflow** — drip-release materials by date/time
- **Optional GitHub Pages deployment** on push to `main`

## Forking

```bash
# 1. Copy this directory to a new repo
cp -r course-template/ ~/my-course
cd ~/my-course
git init && git add -A && git commit -m "fork from course-template"

# 2. Open in Claude Code and run the bootstrap skill
claude
> /bootstrap
```

Bootstrap will:
1. Ask for course code, name, textbook, week count, instructor, institution
2. Write `config.typ` (course metadata read by every Typst template)
3. Substitute placeholders (`{{COURSE_CODE}}` etc.) in HTML and workflow files
4. Ingest your textbook PDF(s) into `textbook/*.md`
5. Propose and write a weekly schedule to `coursedesign/schedule.typ`

After bootstrap, generate week 1:

```
> /generate-week 1
```

## Layout

```
config.typ.example                   # Edit (or run /bootstrap) → config.typ
Makefile                             # `make build` / `make serve`
templates/                           # Typst libraries (do not edit per-week)
├── learning-sheet.typ               # Shared lib: theorem envs, prompt blocks
├── advanced-learning-sheet.typ      # Research-track lib (deep dives, gedanken)
├── test.typ                         # Shared lib: question counter, solution toggle
├── intro.template.typ               # Intro slides skeleton (copy per-week)
└── week-template/                   # Copy to weekN/ to start a week
coursedesign/
├── weekly-materials-guide.md        # Pedagogical principles & checklists
├── schedule.example.typ             # Example schedule (bootstrap fills in real one)
└── release-schedule.example.json    # Example Zulip release schedule
.github/
├── templates/{index,viewer,setup-guide}.html, styles.css
└── workflows/
    ├── deploy-pages.yml             # Build PDFs + viewer; deploy to Pages
    └── release-materials.yml        # Hourly Zulip drip release (optional)
.claude/
├── CLAUDE.md                        # Project instructions for Claude Code
├── rules/typst.md                   # Typst writing conventions
└── skills/                          # Slash commands
```

After bootstrap, you'll also have:

```
config.typ                           # Course metadata
textbook/NN.md                       # Extracted textbook chapters
coursedesign/schedule.typ            # Weekly section assignments
weekN/                               # Per-week materials (created by /generate-week)
```

## Design principles

1. **Flatten the learning curve** — break content into weekly chunks with clear
   objectives
2. **Remove uncertainty** — pair every test with a validation set that defines
   the test boundary
3. **Enable AI-assisted study** — every learning sheet ships with copy-paste
   prompts students run against any LLM

## Build commands

```bash
make build              # Build entire site (PDFs + HTML viewers)
make compile-tests      # Compile all test and validation files
make compile-intro      # Compile all intro files
make dump-solutions     # Compile tests/validations with solutions visible
make serve              # Build then serve locally at http://localhost:8000
make serve-only         # Serve without rebuilding
make clean              # Remove _site/
```

Single-file compile:

```bash
typst compile weekN/N.learning-sheet.typ
```

## Requirements

- [Typst](https://typst.app) (latest)
- Python 3 (for `make serve`)
- Optional: [`entr`](https://github.com/eradman/entr) for `make watch`
