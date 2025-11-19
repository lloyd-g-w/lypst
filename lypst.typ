#let lypst_boxes = (
  (name: "", colour: rgb(38, 70, 83)),
  (name: "Theorem", colour: rgb(42, 157, 143)),
  (name: "Lemma", colour: rgb(39, 125, 161)),
  (name: "Proof", colour: rgb(231, 111, 81)),
  (name: "Code", colour: rgb(184, 184, 184)),
)

#let lypst_conf(doc) = [

  // Packages
  #import "@preview/zebraw:0.6.0": *
  #show: zebraw.with(lang: false, background-color: 0)


  #set page(
    columns: 2,
    margin: (top: 1.8cm, left: 1.5cm, right: 1.5cm, bottom: 1.8cm),
  )
  #set text(size: 11pt, font: "New Computer Modern")
  #set par(justify: true)
  #set heading(numbering: "1.1")


  // Set a rule where each new depth == 1 heading resets counter
  // of each lypst box
  #show heading: it => {
    if (it.depth == 1) {
      for box in lypst_boxes {
        counter(box.name).update(0)
      }
    }
    it
  }

  #doc
]


// Returns a lambda that takes in doc as an argument
#let lypst_title(
  title: "Lypst",
  subtitle: none,
  authors: (none,),
  img: none,
) = doc => [
  #page(columns: 1, margin: 2cm)[
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



#let __template_block(title, body, block_name, colour, nonum) = {
  let block_counter = counter(block_name)
  let bg_colour = colour.lighten(90%)

  let border_widths = (left: 3pt, rest: 1pt)

  let title_content = block(width: 80%)[
    #let optional_title = if (
      title != none and title != ""
    ) { [(#title)] } else {}

    #block(
      fill: white,
      inset: 5pt,
      radius: 3pt,
      stroke: 1pt + colour,
    )[
      #text(weight: "bold")[
        #if nonum {
          [#block_name #optional_title]
        } else {
          context {
            let h_count = counter(heading).get()
            if h_count.len() > 0 {
              [#block_name #h_count.first().#block_counter.display()
                #optional_title
              ]
            } else {
              [#block_name #block_counter.display() #optional_title]
            }
          }
        }
      ]
    ]
  ]


  block(breakable: false, width: 100%)[
    #if (not nonum) { block_counter.step() }

    #pad(left: 8pt, hide(title_content))
    #v(-2em)

    #block(
      width: 100%,
      fill: colour,
      radius: 5pt,
      inset: border_widths,
    )[
      #block(
        width: 100%,
        fill: bg_colour,
        radius: 4pt,
        inset: (top: 13pt, rest: 10pt),
      )[
        #body
      ]
    ]

    #place(top + left, dx: 8pt, title_content)
  ]
}

#let nonum = "lypst_nonum_flag"

#let make_block(box) = {
  let block_name = box.name
  let block_colour = box.colour

  (..args) => {
    let pos = args.pos()
    let named = args.named()
    let body = pos.last()
    let flags = if pos.len() > 1 { pos.slice(0, -1) } else { () }
    let is_nonum = named.at("nonum", default: false) or flags.contains(nonum)

    let title = named.at("title", default: none)

    __template_block(
      title,
      body,
      block_name,
      block_colour,
      is_nonum,
    )
  }
}

#let generic = make_block(lypst_boxes.at(0))
#let theorem = make_block(lypst_boxes.at(1))
#let lemma = make_block(lypst_boxes.at(2))
#let proof = make_block(lypst_boxes.at(3))
#let code = make_block(lypst_boxes.at(4))


