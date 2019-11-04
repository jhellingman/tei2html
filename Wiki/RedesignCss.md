
# CSS stylesheet redesign #

The CSS stylesheets with tei2html have grown over time, and as a result are not very consistent or easy to maintain. To rememdy this, I will redesign them using a more structured approach.

This will involve the following

1. `reset.css` -- reset all browser dependent settings, to achieve better consistency across browsers.
2. use the BEM philosophy, to make the stylesheets easier to maintain.


## BEM for ePub ##

BEM (Block Element Modifier) was developed to make the maintenance of CSS for websites easier. This does not always translate one-on-one to ebooks, but most of the principles can be applied without much trouble.

The main blocks that can easily be identified:

* __Cover__ (either newly designed or original, or both)
* __Title page__ (either newly designed or original, or both)
* __Text__ (no distinction made between front matter, main body, and back matter, as they are normally typographically treated the same.)
* __Advertisements__ (reproduced advertisements from the original book)
* __Colophon__ (our own metadata regarding the book)

Common elements in books:

* Figures and plates
* Tables of Contents
* Tables
* Lists
* Index

