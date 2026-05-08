// Example weekly schedule. Bootstrap will create the real coursedesign/schedule.typ.
//
// Each row maps a week number to (a) textbook sections, (b) the topic name,
// and (c) supporting resources (videos, lecture notes, etc.).

#show link: set text(blue)

= Course schedule

#align(center, text(10pt)[#table(columns: 4, inset: 7pt,
  table.header(
    table.cell(fill: gray.lighten(50%))[*Week*],
    table.cell(fill: gray.lighten(50%))[*Sections*],
    table.cell(fill: gray.lighten(50%))[*Topics*],
    table.cell(fill: gray.lighten(50%))[*Resources*],
  ),
  [1], [§1.1, §1.2], [Foundations],
  align(left)[- #link("https://example.com/lec1", [Lecture 1])
- #link("https://example.com/lec2", [Lecture 2])],

  [2], [§1.3, §1.4], [Building blocks],
  align(left)[- #link("https://example.com/lec3", [Lecture 3])],

  // ... add more weeks
)])
