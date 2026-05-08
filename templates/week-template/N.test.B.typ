// Copy to weekN/N.test.B.typ — edit all lines marked ← EDIT
// Must mirror N.test.typ: same structure, same points, same difficulty, DIFFERENT questions

#import "../templates/test.typ": *

#show: test-template.with(
  week: 0,                  // ← EDIT: week number
  title: "TOPIC TITLE",     // ← EDIT: topic title
  variant: "B",
)

// Total: 130 pts — must match test.typ point distribution exactly

== Part A: Multiple Choice [20 points]

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

#question(5)[  // ← EDIT
  #enum(numbering: "a)", [Option a], [Option b], [Option c], [Option d])
  Answer: #underscore(30pt)
  #solution[#mark([*X)*]) — Explanation.]
]

== Part B: Formal Definitions [20 points]

#question(20)[  // ← EDIT
  #solution(height: 10em)[#mark([Answer])]
]

== Part C: Basic Skills [15 points]

#question(7)[  // ← EDIT
  #solution(height: 4em)[#mark([Answer])]
]

#question(8)[  // ← EDIT
  #solution(height: 5em)[#mark([Answer])]
]

== Part D: Design [35 points]

#question(17)[  // ← EDIT
  #solution(height: 16em)[#mark([Answer])]
]

#question(18)[  // ← EDIT
  #solution(height: 14em)[#mark([Answer])]
]

== Part E: Proofs [25 points]

#question(25)[  // ← EDIT

  _Hint: ..._

  #solution(height: 12em)[*Proof:* #mark([Answer])]
]

== Part F: Additional Topics [15 points]

#question(15)[  // ← EDIT
  #solution(height: 12em)[#mark([Answer])]
]

#test-footer()
