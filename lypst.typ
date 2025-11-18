#let lypst_boxes = (
  (name: "Theorem", colour: rgb(42, 157, 143)),
  (name: "Lemma", colour: rgb(39, 125, 161)),
  (name: "Proof", colour: rgb(231, 111, 81)),
  (name: "", colour: rgb(38, 70, 83)),
)

#let lypst_conf(doc) = [
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
  let block_counter = counter(block_name)
  let bg_colour = colour.lighten(90%)
  
  // Border thickness defined via inset of the outer container
  let border_widths = (left: 3pt, rest: 1pt)

  // We define the title content once so we can use it twice (hidden & visible)
  let title_content = block(
    fill: white, // White background masks the border behind it
    inset: 5pt,
    radius: 3pt,
    stroke: 1pt + colour,
  )[
    #text(weight: "bold")[
      #context {
        let h_count = counter(heading).get()
        if h_count.len() > 0 {
          [#block_name #h_count.first().#block_counter.display() (#title)]
        } else {
          [#block_name #block_counter.display() (#title)]
        }
      }
    ]
  ]

  block(breakable: false, width: 100%)[
    #block_counter.step()

    // 1. SPACE RESERVATION (Hidden Title)
    // This pushes the content box down based on the title's actual height.
    // We use 'pad' to match the indentation of the placed title below.
    #pad(left: 8pt, hide(title_content))

    // 2. OVERLAP ADJUSTMENT
    // Pull the content box up so its top border sits 'inside' the title area.
    // Adjust this value to change where the border intersects the title.
    #v(-2em)

    // 3. MAIN CONTENT (Border + Background)
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

    // 4. VISIBLE TITLE
    // We place this at top-left (0,0) of the wrapper.
    // Since we reserved space with the hidden block at (0,0), this aligns perfectly.
    // It is drawn last, so it sits ON TOP of the content box border.
    #place(top + left, dx: 8pt, title_content)
  ]
}


#let make_block(box) = {
  let block_name = box.name
  let block_colour = box.colour
  (title, body, display_count: true, sub: false) => {
    __template_block(
      title,
      body,
      block_name,
      block_colour,
    )
  }
}

#let theorem = make_block(lypst_boxes.at(0))
#let lemma = make_block(lypst_boxes.at(1))
#let proof = make_block(lypst_boxes.at(2))
#let generic = make_block(lypst_boxes.at(3))


