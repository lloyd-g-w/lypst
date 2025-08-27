#import "lypst.typ": *

#show: lypst_conf
#show: lypst_title(
  title: "COMP4128",
  subtitle: "Topic Notes",
  authors: ("Lloyd G W",),
)

= This is a main heading
== this is a sub heading
=== this is a theorem

#theorem("Python")[
  this is a test. I don't know if this is good or not.
]
#theorem("Python")[
  this is a test. I don't know if this is good or not.
]
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

#lemma("test")[
  this is a test. I don't know if this is good or not.
]

#generic("Hello.")[
  test
]

This is quite interesting. In fact this is
$i mod 3 = 2, x -2+3 interleave 3 divides 3$
$ integral_3^(4) f(x) (d y)/(d x) $

