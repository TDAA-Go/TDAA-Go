// =============================================================================
// INTRO TEMPLATE — Week N Introduction Slides
// =============================================================================
// Copy this file to weekN/N.intro.typ and fill in the content.
// =============================================================================

#import "@preview/touying:0.6.1": *
#import "@preview/cetz:0.4.1": *
#import "@preview/touying-simpl-hkustgz:0.1.2": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "../config.typ": course-code, course-name, instructor, institution

// Time counter — tracks cumulative minutes for pacing
#let globalvars = state("t", 0)
#let timecounter(minutes) = [
  #globalvars.update(t => t + minutes)
  #place(dx: 100%, dy: -5%, align(right, text(16pt, red)[#context globalvars.get() min]))
]

// Style code blocks
#show raw.where(block: true): it => box(
  fill: rgb("#f5f5f5"),
  inset: 10pt,
  radius: 4pt,
  width: 100%,
  text(size: 11pt, it)
)

#show: hkustgz-theme.with(
  config-info(
    title: [Week N: TOPIC TITLE],            // ← EDIT: Week number and topic
    subtitle: [§X.Y, X.Z],                    // ← EDIT: Textbook sections covered
    author: [#course-code (#course-name), #instructor],
    date: datetime.today(),
    institution: [#institution],
  ),
)

#let twocol(left, right, gutter: 20pt) = grid(columns: (1fr, 1fr), gutter: gutter, left, right)

#title-slide()

= Introduction

// -----------------------------------------------------------------------------
// SECTION: Opening Hook (1-2 slides)
// Purpose: Motivate the topic with a real-world problem or surprising question
// -----------------------------------------------------------------------------

== The Problem
#timecounter(1)

#align(center)[
  #box(stroke: 2pt + rgb("#1565c0"), width: 85%, inset: 20pt, radius: 10pt, fill: rgb("#e3f2fd"))[
    #text(size: 20pt)[
      // ← EDIT: State the motivating problem or surprising fact
      *Key insight or question that hooks students*
    ]
  ]
]

// -----------------------------------------------------------------------------
// SECTION: Concrete Example (1-2 slides)
// Purpose: Connect abstract concept to daily life
// -----------------------------------------------------------------------------

== Example: REAL-WORLD SYSTEM
#timecounter(1)

#twocol[
  // ← EDIT: Visual representation (diagram, state machine, etc.)
][
  *Key vocabulary:*
  - *Term 1*: Definition
  - *Term 2*: Definition
  - *Term 3*: Definition
]

// -----------------------------------------------------------------------------
// SECTION: Formal Definition Preview (1 slide)
// -----------------------------------------------------------------------------

== Formal Definition (Preview)
#timecounter(1)

#twocol[
  #box(fill: rgb("#fff3e0"), inset: 12pt, radius: 5pt, width: 100%)[
    // ← EDIT: Formal definition tuple or structure
    $M = (...)$
  ]
][
  // ← EDIT: Table mapping symbols to example values
  #table(
    columns: (auto, 1fr),
    inset: 8pt,
    stroke: 0.5pt + gray,
    [*Symbol*], [*Meaning*],
    [$X$], [Description],
  )
]

// -----------------------------------------------------------------------------
// SECTION: Practical Applications (1 slide)
// -----------------------------------------------------------------------------

== Practical Applications
#timecounter(1)

#twocol[
  *Every time you:*
  - Action 1
  - Action 2
  - Action 3

  ...you're using CONCEPT!
][
  #table(
    columns: (auto, 1fr),
    inset: 8pt,
    stroke: 0.5pt + gray,
    fill: (x, y) => if y == 0 { rgb("#e8f5e9") } else { white },
    [*Tool*], [*Uses CONCEPT*],
    [Tool 1], [Application],
    [Tool 2], [Application],
  )
]

= Learn

// -----------------------------------------------------------------------------
// SECTION: AI-assisted Learning Session
// -----------------------------------------------------------------------------

== AI-assisted Learning (50min) - Live Demo

- 4 members each group, set up an AI tool (e.g., DeepSeek, Qwen, ChatGPT).
- Learning sheet: link to the published PDF for this week.
- Download the PDF and send it to the AI tool. Then start with:
  ```
  prompt> Summarize the lecture note.
  prompt> Show Part 1.
  ```
- *Share*:
  - Share the most "beneficial" question your group asked the AI.
  - Discuss your group's attempt at the task.

Note: raise your hand to ask for help.

== Task description

#box(stroke: 1pt + rgb("#1565c0"), inset: 12pt, radius: 5pt, fill: rgb("#e3f2fd"), width: 100%)[
  // ← EDIT: The main task for group work
  *Task:* Description of what students should accomplish.
]

// ← EDIT: Show a naive attempt and its problems (motivates the formal approach)

= Discussion

== Discussion ($<= 20min$)
Each group shares:
- their attempt at the task.

= Self Test

== Session 3: Self-test (30min)

- Try not using AI at first.
- *Goal*: Solve the questions in the validation sheet.
  - Raise your hand to get help from the instructor.
  - Use AI to check your answers.

Note: next week, the first 30min will be a test (closed book, no AI). The questions will be similar to the questions in the validation sheet.
