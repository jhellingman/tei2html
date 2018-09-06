
## Support for mathematical formulas

(Future feature for `tei2html`)

### Requirements

Use the suggested TEI notation: `<formula id=f1 notation="TeX">$$E = mc^2$$</formula>` (see [TEI guidelines](http://www.tei-c.org/release/doc/tei-p5-doc/en/html/FT.html#FTFOR))

Meet Project Gutenberg rules, that is convert to HTML and ePub without any dynamic content (that is, no javascript, no external fonts or dependencies on non-standard software, etc.)

Look as good as normal (dynamic) MathJax output.

Fully automated processing on command line (that is, it can be integrated in a build process)

### Implementation

Processing:

1. Use pre-processing script to extract all formula contents to separate files (XSLT can do the trick).
2. Use another script to convert all these files to SVG files (Perl, node.js, etc)
3. Use main XSLT transform to include the SVG files as images (or inline)

Naming scheme `formula-<ID>.tex`, etc. and `formula-<ID>.svg`.

Tooling:

1. install [Node.js](https://nodejs.org/en/). Make sure to install both node.js and npm.
2. install [Mathjax-node](https://github.com/mathjax/mathjax-node) using `npm install -g mathjax-node`.
3. install [Mathjax-node-cli](https://github.com/mathjax/mathjax-node-cli) using `npm install -g mathjax-node-cli`.

### Issues

Baseline alignment issue, various approaches

1. https://tex.stackexchange.com/questions/44486/pixel-perfect-vertical-alignment-of-image-rendered-tex-snippets/45621
2. https://www.princexml.com/forum/topic/2971/using-mathjax-with-princexml


