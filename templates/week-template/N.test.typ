// Copy to weekN/N.test.typ — edit all lines marked ← EDIT
// Canonical reference: week1/1.test.typ (after you have one)

#import "../templates/test.typ": *

#show: test-template.with(
  week: 0,                  // ← EDIT: week number
  title: "TOPIC TITLE",     // ← EDIT: topic title
)

// Total: 130 pts
// Part A: 20  |  Part B: 20  |  Part C: 15  |  Part D: 35  |  Part E: 25  |  Part F: 15

== Part A: Multiple Choice [20 points]

// 3-4 questions testing understanding, not recall

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
