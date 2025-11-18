#import "lypst.typ": *

#show: lypst_conf
#show: lypst_title(
  title: "MATH2621 Notes",
  subtitle: "Higher Complex Analysis",
  authors: ("Lloyd-G-W",),
  img: "images/unsw.png",
)

#theorem("Python", sub: true)[
  this is a test. I don't know if this is good or not.
]

= This is a main heading
#theorem("Python")[
  this is a test. I don't know if this is good or not.
]
== this is a sub heading
=== this is a theorem

#theorem("Python")[
  this is a test. I don't know if this is good or not.
]

= test

#theorem("Python", sub: true)[
  this is a test. I don't know if this is good or not.
]
#theorem("Python", sub: true)[
  this is a test. I don't know if this is good or not.
]
#theorem("Python", display_count: false)[
  this is a test. I don't know if this is good or not.
]
#theorem("Python", sub: true)[
  this is a test. I don't know if this is good or not.
]

#proof("test")[
  this is a test. I don't know if this is good or not.

  #lemma("another proof")[
    hello.
  ]
]

```cpp
for(int i = 0; i < 23; ++i){
  x = 23 + 5
}
```

#lemma("test")[
  this is a test on lypst
]



#generic("Hello this is going to be really quite long now.")[
  test among 
]

#block(
  width: 100%,
  height: 2cm,
  fill: blue,
  place(top + left, dx: 10pt, dy: -10pt, block(
    width: 80%,
    height: 30pt,
    fill: green,
  )),
)
\
#block(
  width: 100%,
  height: 2cm,
  fill: blue,
)[
  test
]
#place(
  top + left,
  dx: 10pt,
  dy: 5pt,
  block(
    width: 80%,
    height: 1cm,
    fill: red,
  ),
)



This is bad!
this is quite 

This is quite interesting. In fact this is
$i mod 3 = 2, x -2+3 interleave 3 divides 3$
$ integral_3^(4) f(x) (d y)/(d x) $

$ "Log"(x+2) = 3 log(x+2=3) infinity infinity integral.cont bb(R) bold(r) phi $

