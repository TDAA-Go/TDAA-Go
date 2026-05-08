// Copy to weekN/N.validation.typ — edit all lines marked ← EDIT
// Defines the test boundary: test.typ must not exceed this scope
// Must parallel test.typ: same structure, same points, different questions

#import "../templates/test.typ": *

#show: test-template.with(
  week: 0,                  // ← EDIT: week number
  title: "TOPIC TITLE",     // ← EDIT: topic title
  variant: "validation",
  references: "§X.Y-§X.Z",  // ← EDIT: textbook section refs
)

// Total: 130 pts — must match test.typ point distribution

== Part A: Multiple Choice [15 points]

// Same concepts as test.typ, different specific questions

#question(5)[  // ← EDIT
  #enum(numbering: "a)", [Option a], [Option b], [Option c], [Option d])
  Answer: #underscore(30pt)
  #solution[#mark([*X)*]) — Explanation.]
]

#question(5)[  // ← EDIT
  #enum(numbering: "a)", [Option a], [Option b], [Option c], [Option d])
  Answer: #underscore(30pt)
  #solution[#mark([*X)*]) — Explanation.]
]

#question(5)[  // ← EDIT
  #enum(numbering: "a)", [Option a], [Option b], [Option c], [Option d])
  Answer: #underscore(30pt)
  #solution[#mark([*X)*]) — Explanation.]
]

== Part B: Formal Definitions [15 points]

#question(15)[  // ← EDIT
  #solution(height: 8em)[#mark([Answer])]
]

== Part C: Basic Skills [15 points]

#question(7)[  // ← EDIT
  #solution(height: 6em)[#mark([Answer])]
]

#question(8)[  // ← EDIT
  #solution(height: 5em)[#mark([Answer])]
]

== Part D: Design [35 points]

#question(17)[  // ← EDIT
  #solution(height: 18em)[#mark([Answer])]
]

#question(18)[  // ← EDIT
  #solution(height: 14em)[#mark([Answer])]
]

== Part E: Theory [25 points]

#question(25)[  // ← EDIT
  #solution(height: 12em)[#mark([Answer])]
]

== Part F: Additional Topics [25 points]

#question(25)[  // ← EDIT
  #solution(height: 22em)[#mark([Answer])]
]

#validation-footer()
