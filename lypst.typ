// Packages

#import "@preview/chic-hdr:0.5.0": *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import "@preview/cetz:0.5.1"

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
#let parspace = 0.55em
#let varnothing = $diameter$

#let lypst_state = state("lypst_state", (
  header_right: "2025, Term 3",
  section_label: "Section",
))
#let lypst_conf(header_right: "2025, Term 2", section_label: "Section", doc) = [

  #lypst_state.update(old => (
    header_right: header_right,
    section_label: section_label,
  ))

  #show: codly-init
  #codly(zebra-fill: none, stroke: none, display-name: false)

  #set page(
    columns: 2,
    margin: (top: 1.8cm, left: 1.5cm, right: 1.5cm, bottom: 1.8cm),
    numbering: "1",
  )


  #set text(size: 12pt, font: "New Computer Modern", lang: "en", region: "AU")
  #set heading(numbering: "1.1")

  #set par(
    leading: 0.55em,
    spacing: parspace,
    // first-line-indent: 1.8em,
    first-line-indent: 0pt,
    justify: true,
  )

  #show heading: set block(above: 1.4em, below: 1em)


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
  img-height: 35%,
) = doc => [
  #page(columns: 1, margin: 2cm, numbering: none)[
    #align(center)[

      #if (img != none) {
        [#image(img, height: img-height)]
      }
      #v(5%)
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


#let __template_block(title, body, block_name, colour, nonum) = {
  let inner = context {
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

      content
      //
      // // Wrap in a figure for refs if numbered
      // if nonum {
      //   content
      // } else {
      //   figure(
      //     kind: block_name,
      //     supplement: block_name,
      //     outlined: false,
      //     placement: none,
      //     caption: none,
      //     numbering: "1",
      //   )[ #align(left)[#content] ]
      // }
    })
  }

  if nonum {
    inner
  } else {
    figure(
      kind: block_name,
      supplement: block_name,
      outlined: false,
      placement: none,
      caption: none,
      numbering: "1",
    )[ #align(left)[#inner] ]
  }
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
#let def = definition
#let proof = make_block(lypst_boxes.at(3))
#let lemma = make_block(lypst_boxes.at(4))
#let theorem = make_block(lypst_boxes.at(5))
#let corollary = make_block(lypst_boxes.at(6))
#let coro = corollary
#let example = make_block(lypst_boxes.at(7))
#let exercise = make_block(lypst_boxes.at(8))
#let problem = make_block(lypst_boxes.at(9))
#let code = make_block(lypst_boxes.at(10))

// CHIC

#let lypst-section-num(section-level: 1) = context {
  let loc = here()
  let page = loc.page()

  // All headings after the header location
  let after = query(selector(heading).after(loc))

  // Restrict to headings that are on the same page as the header
  let on_page = after.filter(h => h.location().page() == page)

  // Base location for searching the parent:
  // - if we have a heading on this page, use the first one's location
  // - otherwise, fall back to the header's own location
  let base_loc = if on_page.len() > 0 {
    on_page.first().location()
  } else {
    loc
  }

  // Find the parent heading before base_loc
  let all_prev = query(selector(heading).before(base_loc))
  let parent = none
  for h in all_prev.rev() {
    if h.level <= section-level {
      parent = h
      break
    }
  }

  // Return that parent’s heading counter value
  if parent != none {
    let arr = counter(heading).at(parent.location())
    if arr.len() > 0 {
      return arr.first()
    }
  }
  none
}

#let lypst-section-name(section-level: 1) = context {
  let loc = here()
  let page = loc.page()

  let after = query(selector(heading).after(loc))
  let on_page = after.filter(h => h.location().page() == page)

  let base_loc = if on_page.len() > 0 {
    on_page.first().location()
  } else {
    loc
  }

  let all_prev = query(selector(heading).before(base_loc))
  let parent = none
  for h in all_prev.rev() {
    if h.level <= section-level {
      parent = h
      break
    }
  }

  if parent != none {
    parent.body
  } else {
    none
  }
}


#let make_lypst_auto_header = chic.with(
  chic-header(
    side-width: (1fr, 0pt, -20pt),
    left-side: grid(
      columns: (1fr, auto),
      // 1fr for title, auto for the date
      // this is so the left text can extend beyond the middl
      align: (bottom + left, bottom + right),

      // The actual Left content
      smallcaps([#context lypst_state.get().section_label #lypst-section-num()
        --
        #lypst-section-name()]),

      // The actual Right content
      smallcaps(context lypst_state.get().header_right),
    ),
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
    side-width: (1fr, 0pt, -20pt),
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
