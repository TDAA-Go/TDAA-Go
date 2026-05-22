# Zulip-Based Homework Submission & Marking — Design Spec

**Status:** Approved design, awaiting implementation plan.
**Date:** 2026-05-23.
**Owner:** GiggleLiu / TDAA-Go.

## Problem

TDAA-Go currently grades homework through `/grade-homework`, which reads a local folder of files named `<student>_..._<original>.<ext>`. There is no submission channel — students email or hand in files, and the instructor manually places them into the folder. We want:

- A frictionless mobile submission path: students photograph their work and submit from their phone.
- A way to deliver per-question feedback back to each student.
- A grading workflow that reuses the existing `/grade-homework` and `/homework-report` skills unchanged.

## Solution overview

Use Zulip as the transport. Each student DMs a course-specific bot with photo attachments. A new orchestration skill pulls those DMs, drops files into the format the existing grader expects, runs grading + reporting, and DMs the feedback back.

**No website.** No backend service. Two new skills, neither of which modifies existing skills.

```
                                 ┌──────────────────────┐
   student phone ──DM photos──▶  │  Zulip realm         │  ◀──DM feedback── instructor (via bot)
                                 │  (private 1:1 w/bot) │
                                 └──────────┬───────────┘
                                            │ zulip Python pkg + .zuliprc
                                            ▼
   ┌──────────────────────────────────────────────────────────────────────────┐
   │  Instructor's local repo                                                 │
   │                                                                          │
   │  (1) /setup-zulip-grading        ───▶  .zuliprc      (gitignored)        │
   │      (one-time)                  ───▶  coursedesign/roster.csv (commit)  │
   │                                                                          │
   │  (2) /zulip-mark-feedback N      ───▶  weekN/submissions/                │
   │      (per homework: pull,              <sid>_<msgid>_<n>_<orig>.<ext>    │
   │       delegate /grade-homework,        weekN/grades/grades.csv           │
   │       delegate /homework-report,       weekN/grades/feedback/<sid>.md    │
   │       DM feedback back)          ◀──── weekN/zulip-pull.json (state)     │
   │                                  ◀──── weekN/zulip-feedback-sent.json    │
   └──────────────────────────────────────────────────────────────────────────┘
```

## Non-goals

- A website or hosted UI of any kind.
- Replacing `/grade-homework` or `/homework-report` (they stay unchanged).
- Anonymous submission, plagiarism detection, or grade appeals workflow.
- Multi-course bot reuse — each course gets its own bot.
- Coupling to `zlp-harness` / `zlp-cli` (use the official `zulip` Python package directly).

## Skills

### Skill 1 — `/setup-zulip-grading` (one-time)

**Trigger phrases:** "set up zulip submissions", "configure zulip grading bot", "/setup-zulip-grading".

**Inputs:** none — interactive.

**Flow:**

1. **Prereq check** — verify `uv` is available, `config.toml` exists (i.e., `/bootstrap` has been run), and the official `zulip` package is in `pyproject.toml` (add it if missing; run `uv sync`).
2. **Get instructor's personal Zulip API key** — inline walk-through (no `zlp-*` dependency):
   > Open `<your Zulip realm URL>` in a browser → click your avatar → **Personal settings** → **Account & privacy** → next to **API key**, click **Show/change your API key** → enter password → copy the key.
   Prompt for: realm URL, login email, the API key.
3. **Create the grading bot programmatically** —
   ```python
   import zulip
   client = zulip.Client(email=<instructor_email>, api_key=<instructor_key>, site=<realm_url>)
   result = client.add_bot(
       full_name=f"{course_code} grading bot",
       short_name=f"{course_code.lower()}-grading",
       bot_type=1,  # Generic
   )
   ```
   Response yields `email`, `api_key`, `user_id`. On HTTP error mentioning `realm_bot_creation_policy`, fall back to manual UI walk-through (create bot in browser → Download zuliprc → paste path).
4. **Write `.zuliprc`** at repo root with the bot's credentials:
   ```ini
   [api]
   email=<bot_email>
   key=<bot_api_key>
   site=<realm_url>
   ```
   Add `.zuliprc` to `.gitignore` if not already present.
5. **Verify** — `zulip.Client(config_file=".zuliprc").get_profile()` and print bot name/email.
6. **Build `coursedesign/roster.csv`** — ask via `AskUserQuestion`:
   - **A:** Paste a CSV/TSV block with columns `zulip_email,student_id,student_name`. Validate, write file.
   - **B:** Start empty (header-only). Future `/zulip-mark-feedback` runs will prompt to append unknown senders interactively.
7. **No `config.toml` changes.** Convention-over-configuration: `.zuliprc` at repo root and `coursedesign/roster.csv` are the only knobs. Bot identity is read from `.zuliprc` (via stdlib `configparser`) or via `client.get_profile()` at runtime. The existing top-level `zulip-stream` field (used by `release-materials.yml` for the unrelated release drip workflow) is untouched.
8. **Print student-facing onboarding text** the instructor can paste into the course Zulip channel:
   > "Submit homework by DMing **@<bot full name>** on Zulip — just attach your photos before the deadline. Make sure the email on your Zulip account matches the one on the class roster."

**Idempotency:** if `.zuliprc` already exists, the skill verifies it still works (step 5) and only re-runs steps 6 and 8 (roster + onboarding text). Step 7 is a no-op since there's no `config.toml` to update.

### Skill 2 — `/zulip-mark-feedback N` (per homework)

**Trigger phrases:** "grade homework via zulip", "pull and mark week N from zulip", "/zulip-mark-feedback 3".

**Inputs:** homework number `N` (required); optional `--since YYYY-MM-DD[THH:MM]`, `--until ...`, `--resend`.

**Flow:**

#### Phase 1 — Pull from Zulip

1. Read `.zuliprc` (at repo root), `coursedesign/roster.csv`, and `weekN/zulip-pull.json` (if exists). Bot's own email is read from `[api] email` in `.zuliprc` so we can filter out self-DMs.
2. Resolve active window:
   - Default: `last_pull_at` (from state file) → now.
   - First run (no state): prompt instructor for `--since` and `--until`.
   - Flags override.
3. Fetch DMs in window:
   ```python
   messages = client.get_messages({
       "narrow": [{"operator": "is", "operand": "private"}],
       "anchor": <last_seen_id_or_timestamp>,
       "num_after": 5000,
       "apply_markdown": False,
   })["messages"]
   ```
4. For each message with attachments matching `\.(png|jpg|jpeg|pdf|heic|webp)$`:
   - Map `message.sender_email` → `student_id` via roster.
   - **Unknown sender:** interactive prompt — (A) paste `<student_id>,<display_name>` to append to roster.csv and continue; (B) skip — save to `weekN/submissions/_unknown/`; (C) cancel.
   - Download each attachment to `weekN/submissions/<student_id>_<message_id>_<n>_<orig>.<ext>`.
5. Persist new `weekN/zulip-pull.json`: `{"last_pull_at": <window_end_iso>, "fetched_message_ids": [...]}`.
6. **Checkpoint:** print pull summary (`N students, M files; K unknown senders`); ask "proceed to grading? (y/n)".

#### Phase 2 — Grade (delegate to existing skill)

7. With `weekN/submissions/` populated, invoke `/grade-homework` via the Skill tool against that directory. Produces `weekN/grades/grades.csv` and `weekN/grades/feedback/<student_id>.md`.
8. **Checkpoint:** show score summary; ask "build PDF report? (y/n)".

#### Phase 3 — Report (delegate, optional)

9. If yes, invoke `/homework-report` — produces the teacher-facing PDF.
10. **Checkpoint:** ask "DM feedback to students? (y/n)". Default no, since instructor should review locally first.

#### Phase 4 — Send feedback

11. Glob `weekN/grades/feedback/*.md`. For each:
    - Look up `student_id → zulip_email` via roster.
    - First message: show full preview to instructor and ask "Send? [y/n/skip/send-all-remaining]". If "send-all-remaining", skip prompts for subsequent.
    - Send via `client.send_message({"type": "private", "to": [zulip_email], "content": <markdown_with_header>})`. Prepend a one-line header:
      ```
      **Homework {N} feedback** — reply here with questions.

      <feedback content>
      ```
    - If content >10K chars, split on paragraph boundaries into multiple messages.
    - Update `weekN/zulip-feedback-sent.json`: `{"sent": [<sid>, ...], "last_sent_at": "..."}`.
12. Skip students already in `sent` unless `--resend` flag.
13. Print final summary: sent / skipped / failed counts.

**Re-running** — each phase is idempotent. Re-running the whole skill resumes at the first incomplete phase. Instructor can stop at any checkpoint without corrupting state.

## Data formats

### `coursedesign/roster.csv` (committed)
```csv
zulip_email,student_id,student_name
alice@university.edu,20240001,Alice Wang
bob@university.edu,20240002,Bob Chen
```
- `student_id` is the canonical key matching `grades.csv` rows and `<student_id>_...` filenames.
- `zulip_email` is the unique join key.
- No grades or PII beyond what's needed for joining identity. Safe to commit.

### `config.toml`
No changes. Convention-over-configuration: presence of `.zuliprc` at repo root is the "Zulip mode is set up" marker. Bot identity is read from `.zuliprc` at runtime. (The existing top-level `zulip-stream` field used by `release-materials.yml` is unrelated and untouched.)

### `.zuliprc` (gitignored)
```ini
[api]
email=<bot_email>
key=<bot_api_key>
site=https://<realm>.zulipchat.com
```

### Per-week state files (gitignored)
- `weekN/zulip-pull.json` — `{"last_pull_at": "2026-05-22T23:59:00+08:00", "fetched_message_ids": [12345, 12346, ...]}`
- `weekN/zulip-feedback-sent.json` — `{"sent": ["20240001", ...], "last_sent_at": "..."}`

### `.gitignore` additions
```
.zuliprc
week*/submissions/
week*/grades/
week*/zulip-pull.json
week*/zulip-feedback-sent.json
```

### `pyproject.toml` additions
Add `zulip` (the official Zulip Python package) to the project's dependency list. `uv sync` brings it in.

## Error handling

| Failure | Handling |
|---------|----------|
| `.zuliprc` missing | Tell user to run `/setup-zulip-grading`; do not auto-trigger |
| Zulip API auth fails | Print clear error; suggest re-running setup; do not retry silently |
| Realm forbids bot creation | Catch error in setup; fall back to manual UI walk-through (create bot in browser → Download zuliprc → paste path) |
| Unknown sender during pull | Interactive prompt — add roster entry / skip to `_unknown/` / cancel grading. Never silently group |
| Attachment download fails (transient) | Retry once with backoff, then log and continue; flag in summary |
| Student DM contains text only (no attachment) | Skip silently (text DMs are normal — students may ask questions); count in summary |
| Same photo re-sent by student | Filename includes `message_id`; new message → new file; grader sees both as student's pages |
| Feedback message >10K chars (Zulip limit) | Split on paragraph boundaries into multiple messages, preserve order |
| `send-feedback` interrupted mid-batch | `zulip-feedback-sent.json` records progress; re-run resumes from where it stopped |
| Roster has duplicate email | Reject at setup; on first detection during pull, prompt to dedupe |
| Bot DMs the bot itself | Filter by sender — ignore messages where `sender_email == bot-email` |

## Trade-offs and decisions made

| Decision | Why | Alternative considered |
|----------|-----|------------------------|
| No website at all | Forks already get a static Pages site; uploads would require a backend nobody wants to host. Zulip is already in use. | Static site + form relay (Formspree, GitHub Action commit); rejected as more moving parts |
| DM-to-bot instead of public stream | Privacy by default; identity = sender; no cross-student leakage | Public stream with one topic per HW (rejected — exposes student work) |
| Active-window model for HW number | Lowest student friction; instructor controls the gate | Student labels HW number in message (rejected — students forget/mistype) |
| Roster as committed CSV | Joining Zulip identity → student_id is the one place we need stable mapping; emails + IDs aren't secrets | Pure auto-discovery (rejected — leaves grading flow non-deterministic) |
| Official `zulip` Python pkg, not `zlp-cli` or `zlp-harness` | TDAA-Go is forkable and shouldn't take a hard dep on instructor-owned infrastructure | `zlp-harness:zlp-onboard` (rejected — assumes `make zulip-config` Makefile contract TDAA-Go doesn't have; couples to research-harness conventions) |
| New orchestrator skill, leave existing skills untouched | Zero regression risk for non-Zulip users; matches `/generate-week` orchestration pattern | Extending `/grade-homework` with a Zulip branch (rejected — couples two unrelated concerns into one skill) |
| Programmatic bot creation via `add_bot` API | Skips three manual UI clicks during setup | Pure manual UI walk-through (kept as fallback for restricted realms) |
| `.zuliprc` in repo (gitignored), not in `~/.local/share/zlp-harness/...` | Bot is course-specific and belongs with course materials | Shared workspace dir (rejected — implies zlp-harness coupling and per-instructor convention) |
| No `[zulip]` block in `config.toml` | `.zuliprc` already has `email`, `key`, `site`; paths can be hardcoded; presence of `.zuliprc` itself is the "enabled" marker | Adding a `[zulip]` block (rejected — duplicates `.zuliprc` content; adds another file to keep in sync) |

## Open questions resolved during brainstorming

- *Should there be an instructor marking dashboard?* No — instructor uses the existing `/grade-homework` locally; the bot handles transport on both ends.
- *Should grading be auto-triggered when student submits?* No — instructor explicitly runs `/zulip-mark-feedback N` after the deadline; gives a clean gate.
- *Should we support submission editing or deletion by the student?* No — students re-DM to "edit"; latest message wins per the grader's multi-page aggregation. Out of scope for v1.

## Implementation surface

New files:
- `.claude/skills/setup-zulip-grading/SKILL.md`
- `.claude/skills/setup-zulip-grading/scripts/create_bot.py`
- `.claude/skills/setup-zulip-grading/scripts/verify.py`
- `.claude/skills/zulip-mark-feedback/SKILL.md`
- `.claude/skills/zulip-mark-feedback/scripts/pull_submissions.py`
- `.claude/skills/zulip-mark-feedback/scripts/send_feedback.py`

Modified files:
- `pyproject.toml` — add `zulip` to dependencies
- `.gitignore` — add the entries listed above
- `README.md` — add a "Zulip submission (optional)" subsection alongside the existing grading section
- `CLAUDE.md` — add `/setup-zulip-grading` and `/zulip-mark-feedback` to the Skills list
- `config.toml` — **no changes**

Untouched:
- `.claude/skills/grade-homework/*`
- `.claude/skills/homework-report/*`
- All other existing skills
- All Typst templates and weekly materials
