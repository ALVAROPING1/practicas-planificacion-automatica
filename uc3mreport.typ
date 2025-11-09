// "THE BEER-WARE LICENSE" (Revision 42):
// L. Daniel Casais <@rajayonin> wrote this file. As long as you retain this
// notice you can do whatever you want with this stuff. If we meet some day, and
// you think this stuff is worth it, you can buy me a beer in return.


#let azuluc3m = rgb("#000e78")

#let cover(
  degree,
  subject,
  project,
  title,
  year,
  logo,
  group: none,
  authors: (),
  professor: none,
  team: none,
  language: "en",
) = {
  set align(center)

  v(1.4cm)
  text(size: 14pt, weight: "bold", title)
  parbreak()

  v(1cm)

  // authors
  for author in authors [
    #text(size: 11pt, weight: "bold")[#author.name #author.surname (#author.nia)]
    #linebreak()
  ]

  [
    Departamento de Informática, Universidad Carlos III de Madrid
    #linebreak()
    Avda. de la Universidad, 30. 28911 Leganés (Madrid). España
  ]

  v(1.8cm)
}


/**
 * Writes authors in the short format
 */
#let shortauthors(authors: ()) = {
  for (i, author) in authors.enumerate() {
    // name
    for name in author.name.split(" ") {
      name.at(0) + ". "
    }

    // surname
    if "surname_length" in author {
      author.surname.split(" ").slice(0, count: author.surname_length).join(" ")
    } else {
      author.surname.split(" ").at(0)
    }

    // connector
    if i < authors.len() - 2 {
      ", "
    } else if i == authors.len() - 2 {
      " & "
    }
  }
}


#let conf(
  degree: "",
  subject: "",
  year: (),
  authors: (),
  project: "",
  title: "",
  group: none,
  professor: none,
  team: none,
  language: "en",
  toc: true,
  logo: "new",
  bibliography_file: none,
  chapter_on_new_page: true,
  abstract: [],
  doc,
) = {
  /* CONFIG */
  set document(
    title: title,
    author: authors.map(x => x.name + " " + x.surname),
    description: [#project, #subject #year.at(0)/#year.at(1). Universidad Carlos III de Madrid],
  )

  /* TEXT */

  // set text(size: 10pt, lang: language, font: "New Computer Modern")
  set text(size: 10pt, lang: language, font: "Nimbus Roman")

  set par(
    leading: 0.55em,
    spacing: 1em,
    first-line-indent: (amount: 10pt, all: true),
    justify: true,
  )

  /* HEADINGS */

  set heading(numbering: "1.")
  show heading: set block(above: 1.4em, below: 1em)
  show heading.where(level: 1): set text(size: 11pt)
  show heading.where(level: 2): set text(size: 10pt)
  show heading.where(level: 1): it => { align(center, it) }
  // allow to set headings with selector `<nonumber` to prevent numbering
  show selector(<nonumber>): set heading(numbering: none)

  /* FIGURES */

  // figure captions w/ blue
  show figure.caption: it => {
    [
      // #set text(azuluc3m, weight: "semibold")
      #set text(weight: "semibold")
      #it.supplement #context it.counter.display(it.numbering):
    ]
    it.body
  }

  // more space around figures
  // https://github.com/typst/typst/issues/6095#issuecomment-2755785839
  show figure: it => {
    let figure_spacing = 0.75em

    if it.placement == none {
      block(it, inset: (y: figure_spacing))
    } else if it.placement == top {
      place(
        it.placement,
        float: true,
        block(width: 100%, inset: (bottom: figure_spacing), align(center, it)),
      )
    } else if it.placement == bottom {
      place(
        it.placement,
        float: true,
        block(width: 100%, inset: (top: figure_spacing), align(center, it)),
      )
    }
  }

  /* REFERENCES & LINKS */

  show ref: set text(azuluc3m)
  show link: set text(azuluc3m)

  /* FOOTNOTES */

  /*
  // change line color
  set footnote.entry(separator: line(
    length: 30% + 0pt,
    stroke: 0.5pt + azuluc3m,
  ))

  // change footnote number color
  show footnote: set text(azuluc3m) // in text
  show footnote.entry: it => {
    // in footnote
    h(1em) // indent
    {
      set text(azuluc3m)
      super(str(counter(footnote).at(it.note.location()).at(0))) // number
    }
    h(.05em) // mini-space in between number and body (same as default)
    it.note.body
  }
  */

  /* PAGE LAYOUT */

  set page(
    columns: 2,
    paper: "a4",
    margin: (
      y: 2cm,
      x: 2.5cm,
    ),
  )

  /* COVER */

  place(
    top + center,
    float: true,
    scope: "parent",
    cover(
      degree,
      subject,
      project,
      title,
      year,
      logo,
      authors: authors,
      professor: professor,
      group: group,
      team: team,
      language: language,
    ))


  /* TOC */

  {
    align(center, [*Abstract*])
    set par(first-line-indent: 0em)
    text(size: 9pt, abstract)
  }
  doc

  /* BIBLIOGRAPHY */

  if bibliography_file != none {
    pagebreak()
    bibliography(bibliography_file, style: "ieee")
  }
}


