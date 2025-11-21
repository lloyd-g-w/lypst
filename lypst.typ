// Packages

#import "@preview/chic-hdr:0.5.0": *
#import "@preview/zebraw:0.6.0": *

#let lypst_boxes = (
  (name: "Generic", colour: rgb("#e76f51")), // Generic
  (name: "Note", colour: rgb("#264653")),
  (name: "Definition", colour: rgb("#2a9d8f")),
  (name: "Proof", colour: rgb("#5E548E")),
  (name: "Lemma", colour: rgb("#f4a261")),
  (name: "Theorem", colour: rgb("#e9c46a")),
  (name: "Corollary", colour: rgb("#006400")),
  (name: "Example", colour: rgb("#277da1")),
  (name: "Exercise", colour: rgb("#4a8f97")),
  (name: "Problem", colour: rgb("#1b4965")),
  (name: "Code", colour: rgb("#adadad")),
)


// Useful variables
#let parspace = 1.2em


#let lypst_state = state("lypst_state", (header_right: "2025, Term 3"))
#let lypst_conf(header_right: "2025, Term 2", doc) = [

  #lypst_state.update(old => (header_right: header_right))

  // Custom code blocks (mainly for line numbers)
  #show: zebraw.with(lang: false, background-color: 0)

  #set page(
    columns: 2,
    margin: (top: 1.8cm, left: 1.5cm, right: 1.5cm, bottom: 1.8cm),
    numbering: "1",
  )


  #set text(size: 12pt, font: "New Computer Modern", lang: "en", region: "AU")
  #set par(justify: true, spacing: parspace)
  #set heading(numbering: "1.1")

  // Set a rule where each new depth == 1 heading resets counter
  // of each lypst box
  #show heading: it => {
    if (it.depth == 1) {
      for box in lypst_boxes {
        counter(box.name).update(0)
        counter(figure.where(kind: box.name)).update(0)
      }
    }
    it
  }

  #show ref: it => {
    let el = it.element
    if el != none and el.func() == figure {
      // Check if the figure kind matches one of our defined boxes
      let is_lypst = lypst_boxes.any(b => b.name == el.kind)

      if is_lypst {
        let loc = el.location()
        // Get Chapter number AT THE LOCATION of the theorem
        let ch_count = counter(heading).at(loc)
        let ch_num = if ch_count.len() > 0 { ch_count.first() } else { 0 }

        // Get Theorem number AT THE LOCATION of the theorem
        let thm_num = counter(figure.where(kind: el.kind)).at(loc).first()

        // Generate the link text
        link(loc)[#el.supplement #ch_num.#thm_num]
      } else {
        it
      }
    } else {
      it
    }
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
  #page(columns: 1, margin: 2cm, numbering: none)[
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

  ]
  #page(columns: 1, margin: 2cm, numbering: "i")[
    #outline()
  ]
  #doc
]


#let __template_block(title, body, block_name, colour, nonum) = context {
  layout(size => {
    let block_counter = counter(block_name)
    let bg_colour = colour.lighten(90%)
    let border_widths = (left: 3.5pt, rest: 1.5pt)

    let is_generic = block_name == "Generic"

    let optional_title_text = if (title != none and title != "") {
      if (not is_generic) { [(#title)] } else { [#title] }
    } else { none }

    let has_title_content = (
      not is_generic or optional_title_text != none or nonum == false
    )

    let final_title_text = text(weight: "bold")[
      #if nonum {
        if (is_generic) {
          [#optional_title_text]
        } else {
          [#block_name #optional_title_text]
        }
      } else {
        context {
          let h_count = counter(heading).get()
          if (is_generic) {
            [#optional_title_text #h_count.first().#block_counter.display()]
          } else {
            [#block_name #h_count.first().#block_counter.display()
              #optional_title_text
            ]
          }
        }
      }
    ]

    // Use actual layout width here:
    let title_width = 0.8 * size.width + 2pt

    let title_content = box(width: title_width)[
      #block(
        fill: white,
        inset: 0.6em,
        radius: 3pt,
        stroke: 1pt + colour,
      )[ #final_title_text ]
    ]

    // Measure in the *current* layout context
    let title_height = measure(title_content).height

    // How much blank space we always reserve above the body box.
    // Needs to be >= (max expected title height) - gap.
    let gap = -0.9em // gap between title and coloured box
    let headroom = title_height + gap

    let rest_inset = 1.0em
    let top_inset = if has_title_content { 1.5em } else { rest_inset }

    let main = block(
      width: 100%,
      fill: colour,
      radius: 5pt,
      inset: border_widths,
    )[
      #block(
        width: 100%,
        fill: bg_colour,
        radius: 4pt,
        inset: (top: top_inset, rest: rest_inset),
      )[ #body ]
    ]

    let content = block(breakable: false, width: 100%)[
      #if (not nonum) { block_counter.step() }

      // Reserve the space above the body box (independent of title height)
      #if has_title_content {
        v(headroom)
      }

      // The coloured theorem box itself
      #main

      // Draw the title: its *bottom* is (gap) above the top of `main`.
      #if has_title_content {
        place(
          top + left,
          dx: 8pt,
          dy: headroom - gap - title_height,
          title_content,
        )
      }
    ]

    // Wrap in a figure for refs if numbered
    if nonum {
      content
    } else {
      figure(
        kind: block_name,
        supplement: block_name,
        outlined: false,
        placement: none,
        caption: none,
        numbering: "1",
      )[ #align(left)[#content] ]
    }
  })
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
#let note = make_block(lypst_boxes.at(1))
#let definition = make_block(lypst_boxes.at(2))
#let proof = make_block(lypst_boxes.at(3))
#let lemma = make_block(lypst_boxes.at(4))
#let theorem = make_block(lypst_boxes.at(5))
#let corollary = make_block(lypst_boxes.at(6))
#let example = make_block(lypst_boxes.at(7))
#let exercise = make_block(lypst_boxes.at(8))
#let problem = make_block(lypst_boxes.at(9))
#let code = make_block(lypst_boxes.at(10))

// CHIC

// Custom chic function for finding heading num
#let chic-heading-num(dir: "next", fill: false, level: 2) = context {
  let loc = here()
  let headings = array(()) // Array for storing headings

  // Get all the headings in the given direction
  if dir == "next" {
    headings = query(
      selector(heading).after(loc),
    ).rev()
  } else if dir == "prev" {
    headings = query(
      selector(heading).before(loc),
    )
  }

  // If no headings were found, try the other direction if `fill` is true
  if headings.len() == 0 and fill {
    if dir == "next" {
      headings = query(
        selector(heading).before(loc),
      )
    } else if dir == "prev" {
      headings = query(
        selector(heading).after(loc),
      ).rev()
    }
  }

  // Now, get the proper heading (i.e. right ``level`` value)
  // until the headings array is empty
  let found = false
  let return-heading = none
  while not found and headings.len() > 0 {
    return-heading = headings.pop()

    // Check the level of the fetched heading
    if return-heading.level <= level {
      found = true
    }
  }


  if found {
    let count_arr = counter(heading).at(return-heading.location())
    let pattern = return-heading.numbering

    if pattern != none {
      return numbering(pattern, ..count_arr)
    } else {
      return count_arr.map(str).join(".")
    }
  } else {
    return none
  }
}

#let make_lypst_auto_header = chic.with(
  chic-header(
    left-side: grid(
      columns: (1fr, auto),
      // 1fr for title, auto for the date
      // this is so the left text can extend beyond the middl
      align: (bottom + left, bottom + right),

      // The actual Left content
      smallcaps([Section #chic-heading-num(level: 1) -- #chic-heading-name(
          fill: true,
          level: 1,
        )]),

      // The actual Right content
      smallcaps(context lypst_state.get().header_right),
    ),
    // right-side = none for zero width
    right-side: none,
  ),
  chic-footer(
    right-side: chic-page-number(),
  ),

  chic-separator(
    0.5pt,
    on: "header",
  ),
  chic-offset(18pt),
  chic-height(2cm),
)

#let make_lypst_header = header => chic.with(
  chic-header(
    left-side: grid(
      columns: (1fr, auto),
      // 1fr for title, auto for the date
      // this is so the left text can extend beyond the middl
      align: (bottom + left, bottom + right),

      // The actual Left content
      smallcaps(header),

      // The actual Right content
      smallcaps(context lypst_state.get().header_right),
    ),
    // right-side = none for zero width
    right-side: none,
  ),
  chic-footer(
    right-side: chic-page-number(),
  ),
  chic-separator(
    0.5pt,
    on: "header",
  ),
  chic-offset(18pt),
  chic-height(2cm),
)
