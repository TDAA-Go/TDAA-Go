// Weekly Test/Validation Template
//
// Usage (Test):
//   #import "../templates/test.typ": *
//   #show: test-template.with(week: 1, title: "Topic Title")
//   // ... questions ...
//   #test-footer()
//
// Usage (Variant B):
//   #show: test-template.with(week: 1, title: "...", variant: "B")
//
// Usage (Validation Set):
//   #show: test-template.with(week: 1, title: "...", variant: "validation", references: "§1.1-§1.3")
//   // ... questions ...
//   #validation-footer()

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import "../config.typ": course-code, textbook-short

// Helper function for blank lines
#let underscore(l) = box(width: l, stroke: (bottom: 0.5pt), none)

// Solution visibility control (override with: typst compile --input hide-solution=false)
#let hide-solution = {
  let val = sys.inputs.at("hide-solution", default: "true")
  val == "true"
}
#let solution(it, height: none) = if not hide-solution {
  block(
    width: 100%,
    fill: rgb("#f5efe3"),
    stroke: (
      left: 4pt + rgb("#a55d1a"),
      top: 0.5pt + luma(200),
      right: 0.5pt + luma(200),
      bottom: 0.5pt + luma(200),
    ),
    inset: (left: 10pt, top: 6pt, bottom: 6pt, right: 6pt),
    radius: 2pt,
  )[
    #text(size: 9pt, weight: "bold", fill: luma(55))[Solution]
    #v(2pt)
    #it
  ]
} else if height != none { v(height) }

// Mark answers in red (for solution key)
#let mark(it) = text(red)[#it]

// Question counter and formatting
#let qcounter = counter("question")
#let question(pts, body) = block(breakable: false)[
  #qcounter.step()
  *Question #context qcounter.display().* (#pts pts) #body
]

// Unified state node for diagrams (used by some courses)
#let state(pos, label, name: none, accept: false, fill: none) = node(
  pos, label, shape: circle, name: name, radius: 1.5em,
  extrude: if accept { (0, -4) } else { (0, 0) },
  fill: fill
)

// Main template function
#let test-template(
  week: 1,
  title: "Test Title",
  time: "30min",
  points: 130,
  variant: none,       // "B" for variant B; "validation" for validation set
  references: none,    // textbook section refs for validation, e.g. "§4.1-§4.2"
  body
) = {
  // Page setup
  set page(
    paper: "a4",
    margin: (x: 2cm, y: 2cm),
    numbering: "1",
    header: align(center)[Name: #underscore(100pt)  #h(10pt) Student ID: #underscore(100pt) #h(10pt) Grade: #underscore(100pt)],
    footer: context align(center)[Page #counter(page).display() of #counter(page).final().first()]
  )

  set text(font: "New Computer Modern", size: 11pt)
  set par(justify: true, leading: 0.65em)

  // Determine document type
  let is-validation = variant == "validation"
  let doc-type = if is-validation { "Validation Set" } else { "Test" }
  let variant-label = if variant != none and not is-validation { " (Variant " + variant + ")" } else { "" }

  // Title
  align(center)[
    #text(size: 17pt, weight: "bold")[#course-code Week #week #doc-type#variant-label]

    #text(size: 12pt)[#title]
  ]

  v(10pt)

  // Instructions box
  if is-validation {
    box(stroke: 1pt + gray, inset: 10pt, radius: 5pt, width: 100%)[
      === Instructions
      - Purpose: Self-assessment during group discussion
      - Time: ~#time | Total: #points pts
      - Open book, AI allowed
      #if references != none [- References: #textbook-short #references]
    ]
  } else {
    box(stroke: 1pt + gray, inset: 10pt, radius: 5pt, width: 100%)[
      === Instructions
      - Test time: *(#time)*
      - Total points: #points pts
    ]
  }

  v(10pt)

  body
}

// End-of-test footer
#let test-footer(message: "End of test, please submit your answers to the instructor") = {
  v(1em)
  align(center, box(width: 280pt, inset: 3pt, stroke: (top: 0.5pt + gray), text(gray)[*#message*]))
}

// End-of-validation footer
#let validation-footer() = {
  v(1em)
  align(center, box(width: 340pt, inset: 3pt, stroke: (top: 0.5pt + gray), text(gray)[*End of Validation Set — Check answers with AI and discuss with group*]))
}
