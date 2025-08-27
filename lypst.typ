#let lypst_conf(doc) = [
  #set page(
    columns: 2,
    margin: (top: 1.8cm, left: 1.5cm, right: 1.5cm, bottom: 1.8cm),
  )
  #set text(size: 11pt)
  #set par(justify: true)
  #set heading(numbering: "1.1")

  #doc
]

// Returns a lambda that takes in doc as an argument
#let lypst_title(
  title: "LYPST",
  subtitle: "",
  authors: (none,),
) = doc => [
  #page(columns: 1, margin: 3cm)[
    #v(30%)
    #text(size: 60pt, weight: 800)[#title]\ \
    #text(size: 30pt)[#subtitle]\ \
    #for (i, author) in authors.enumerate() {
      if (author == none) { continue }
      if (i == authors.len() - 1) { [#author.] } else { [#author, ] }
    }

    #pagebreak(weak: true)
  ]
  #outline()
  #doc
]


#let __template_block(title, body, block_name, colour) = {
  block(
    width: 100%,
    stroke: (left: 2pt + colour),
    inset: 10pt,
    fill: colour.lighten(70%),
  )[
    #heading(
      [#block_name#(if block_name != "" { [. ] })#title],
      level: 3,
      outlined: false,
      numbering: none,
    )
    #body
  ]
}

#let make_block(block_name, block_colour) = {
  (title, body, display_count: true, sub: false) => {
    __template_block(
      title,
      body,
      block_name,
      block_colour,
    )
  }
}

#let theorem = make_block("Theorem", rgb(42, 157, 143))
#let proof = make_block("Proof", rgb(39, 125, 161))
#let lemma = make_block("Lemma", rgb(231, 111, 81))
#let generic = make_block("", rgb(38, 70, 83))


