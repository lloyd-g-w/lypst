// Packages

#import "@preview/chic-hdr:0.5.0": *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import "@preview/cetz:0.5.1"
#import "@preview/cetz:0.5.1": canvas, draw
#import "@preview/itemize:0.2.0" as el
#import "@preview/intextual:0.1.1": *
#import "@preview/theorion:0.5.0": make-frame, richer-counter

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

// Boxes
//
// Numbering, counters and references are handled by theorion; the drawing is
// ours. Each box kind has its own counter, prefixed by the level-1 heading.
//
// Usage:
//   #theorem[body]                     Theorem 1.2
//   #theorem(title: "Euclid")[body]    Theorem 1.2 (Euclid)
//   #theorem(nonum)[body]              unnumbered
//   #theorem(nobox)[body]              bold "Theorem 1.2." inline, no box
//   #theorem(nonum, nobox)[body]       bold "Theorem." inline, no box
//   (named `nonum: true` / `nobox: true` also work)

#let nonum = "lypst_nonum_flag"
#let nobox = "lypst_nobox_flag"

#let __lypst_has_title(title) = (
  (type(title) == str and title != "")
    or (type(title) == content and title != [] and title != [#""])
)

// Render function handed to theorion. `prefix` is none for unnumbered boxes.
#let __lypst_render(
  name,
  colour,
  ctr,
  prefix: none,
  title: "",
  full-title: "",
  nobox: false,
  body,
) = {
  let is_generic = name == "Generic"
  let has_title = __lypst_has_title(title)
  let numbered = prefix != none
  let num = if numbered { context (ctr.display)("1.1") } else { none }

  // Header text, e.g. "Theorem 1.2 (title)" or for generic "title 1.2"
  let header = if is_generic {
    let parts = ()
    if has_title { parts.push(title) }
    if numbered { parts.push(num) }
    if parts.len() > 0 { parts.join(" ") } else { none }
  } else {
    [#name#if numbered [ #num]#if has_title [ (#title)]]
  }

  if nobox {
    return block(width: 100%, breakable: true)[
      #if header != none [*#header.* ]#body
    ]
  }

  layout(size => {
    let bg_colour = colour.lighten(90%)
    let border_widths = (left: 3.5pt, rest: 1.5pt)

    let title_content = box(width: 0.8 * size.width + 2pt)[
      #block(
        fill: white,
        inset: 0.6em,
        radius: 3pt,
        stroke: 1pt + colour,
      )[#text(weight: "bold", header)]
    ]

    // Title overlaps the top of the coloured box by `overlap`.
    let overlap = 0.9em
    let title_height = measure(title_content).height
    let headroom = title_height - overlap

    let rest_inset = 1.0em
    let top_inset = if header != none { 1.5em } else { rest_inset }

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
      )[#body]
    ]

    block(breakable: false, width: 100%)[
      #if header != none { v(headroom) }
      #main
      #if header != none {
        place(top + left, dx: 8pt, title_content)
      }
    ]
  })
}

// Returns (env-function, show-rule) for one box kind.
#let __lypst_make(box) = {
  let id = "lypst-" + lower(box.name)
  let ctr = richer-counter(identifier: id, inherited-levels: 1)
  let (_, frame-box, frame, show-frame) = make-frame(
    id,
    box.name,
    counter: ctr,
    render: __lypst_render.with(box.name, box.colour, ctr),
  )

  let env = (..args) => {
    let pos = args.pos()
    let named = args.named()
    let body = pos.last()
    let flags = pos.slice(0, -1)

    let is_nonum = named.remove("nonum", default: false) or flags.contains(nonum)
    let is_nobox = named.remove("nobox", default: false) or flags.contains(nobox)
    let title = named.remove("title", default: "")
    if title == none { title = "" }

    let f = if is_nonum { frame-box } else { frame }
    f(title: title, nobox: is_nobox, ..named, body)
  }

  (env, show-frame)
}

#let __lypst_envs = lypst_boxes.map(__lypst_make)

// Applies every box's show rule (figure styling + references).
#let __lypst_box_rules(doc) = __lypst_envs.fold(doc, (d, e) => (e.at(1))(d))

#let generic = __lypst_envs.at(0).at(0)
#let note = __lypst_envs.at(1).at(0)
#let definition = __lypst_envs.at(2).at(0)
#let def = definition
#let proof = __lypst_envs.at(3).at(0)
#let lemma = __lypst_envs.at(4).at(0)
#let theorem = __lypst_envs.at(5).at(0)
#let corollary = __lypst_envs.at(6).at(0)
#let coro = corollary
#let example = __lypst_envs.at(7).at(0)
#let exercise = __lypst_envs.at(8).at(0)
#let problem = __lypst_envs.at(9).at(0)
#let code = __lypst_envs.at(10).at(0)


// Useful variables
#let parspace = 0.55em
#let varnothing = math.diameter

#let implies = math.arrow.r.double
#let implied = (
  by: math.arrow.l.double,
)

// Useful functions in math mode
#let inv(x) = $#x^(-1)$

#let lypst_state = state("lypst_state", (
  header_right: "2025, Term 3",
  section_label: "Section",
  wrap_inline_eqs: false,
))
#let lypst_conf(
  header_right: "2025, Term 2",
  section_label: "Section",
  wrap_inline_eqs: false,
  doc,
) = [
  #lypst_state.update(old => (
    header_right: header_right,
    section_label: section_label,
    wrap_inline_eqs: wrap_inline_eqs,
  ))

  // Use horizontal in inline math but regular in display
  // If no wrap inline eqs then put it in a box
  #show math.equation.where(block: false): it => {
    set math.frac(style: "horizontal")
    if wrap_inline_eqs {
      it
    } else {
      box(it)
    }
  }

  #show: codly-init
  #show: intertext-rule
  #show: el.default-enum-list
  #show ref: el.ref-enum.with(full: true)

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


  // Box styling, numbering and references (theorion)
  #show: __lypst_box_rules

  #doc
]

// Returns a lambda that takes in doc as an argument
#let lypst_title(
  title: "Lypst",
  subtitle: none,
  authors: (none,),
  img: none,
  img-height: 35%,
  no-contents: false,
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
  #doc
]


#let lypst_contents() = doc => [
  #page(columns: 1, margin: 2cm, numbering: "i")[
    #outline()
  ]
  #doc
]



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

