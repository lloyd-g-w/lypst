#import "lypst.typ": *
#import "@preview/cetz:0.4.2": canvas, draw
#import "@preview/cetz-plot:0.1.3": plot

#show: lypst_conf.with(header_right: "2025, Term 3")

#show: lypst_title(
  title: "MATH2621 Notes",
  subtitle: "Higher Complex Analysis",
  authors: ("Lloyd-G-W",),
  img: "images/unsw.png",
)


#show: make_lypst_header("Section 2 -- Higher Complex Analysis")
#theorem()[
  colour
]
= This is interesting


#theorem(nonum)[
  test
]#theorem()[
  test
]
#theorem()[
  test
]
#theorem()[
  test
] <label>

@label
#code(title: "this is code")[
  ```cpp
  for (int i = 0; i < N; ++i){
    for(int j = 0; j < N; ++j){

    }
  }
  ```
]

= this is a test

@label
#theorem()[
  test
] <label2>


#theorem(nonum)[
]

#generic(title: "Hello", nonum)[
  ```cpp
  for (int i = 0; i < N; ++i){
    for(int j = 0; j < N; ++j){

    }
  }
  ```
]

#generic()[

  ```cpp
  for (int i = 0; i < N; ++i){
    for(int j = 0; j < N; ++j){

    }
  }
  ```
]

@label2

