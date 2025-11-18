#let lypst_conf(doc) = [
  #set page(
    columns: 2,
    margin: (top: 1.8cm, left: 1.5cm, right: 1.5cm, bottom: 1.8cm),
  )
  #set text(size: 11pt, font: "New Computer Modern")
  #set par(justify: true)
  #set heading(numbering: "1.1")

  #doc
]

// Returns a lambda that takes in doc as an argument
#let lypst_title(
  title: "LYPST",
  subtitle: none,
  authors: (none,),
  img: none,
) = doc => [
  #page(columns: 1, margin: 3cm)[
    #align(center)[

      #if (img != none) {
        [#image(img, height: 30%)]
      }
      #v(10%)
      #text(size: 30pt)[#smallcaps(title)]\ \
      #if (subtitle != none) {
        [
          #smallcaps(text(size: 30pt)[#subtitle])\ \
        ]
      }

      #if (authors.len() == 1) {
        smallcaps(authors.at(0))
      } else if (authors.len() == 2) {
        smallcaps(authors.at(0) + " and " + authors.at(1))
      } else if (authors != none) {
        for (i, author) in authors.enumerate() {
          if (i == authors.len() - 1) {
            smallcaps("and " + author)
          } else {
            smallcaps(author + ", ")
          }
        }
      }
    ]

    #pagebreak(weak: true)
    #outline()
  ]
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


