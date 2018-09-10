
## Support for mathematical formulas

(Future feature for `tei2html`)

### Requirements

Use the suggested TEI notation: `<formula id=f1 notation="TeX">$$E = mc^2$$</formula>` (see [TEI guidelines](http://www.tei-c.org/release/doc/tei-p5-doc/en/html/FT.html#FTFOR))

* Meet Project Gutenberg rules, that is convert to HTML and ePub without any dynamic content (that is, no javascript, no external fonts or dependencies on non-standard software, etc.)
* Look as good as normal (dynamic) MathJax output.
* Fully automated processing on command line (that is, it can be integrated in a build process)

### Implementation

The Project Gutenberg prohibition on active content make the direct use of MathJax impossible, so we need to follow a more complicated way to include mathematical formulas in text intended for PG.

The process consists of three steps:

1. Use XSLT to export all formulas into separate files. This is done during normal processing.
2. Use a tool to convert all these files to SVG files (Perl, node.js, etc)
3. Use XSLT to include the SVG files as images (or inline) in the resulting file.

The resulting output files are placed in a folder `formulas`, and named according to the following naming scheme `(inline|display)-<ID>.tex`.

A (to be developed script) will convert these files to files named `(inline|display)-<ID>.svg`. This script will use node.js with mathjax-node-cli to produce SVG files from the exported formulas.

### Configuration.

The following configuration options have been added:

* `math.mathJax.enable` if set to true, the MathJax JavaScript is dynamically loaded, and used to render math on-the-fly. If set to false, no JavaScript is loaded, and an `img` tag with a reference to an .SVG file is produced instead.
* `math.mathJax.configuration` determines the MathJax configuration to use.

### Installation of tools

1. install [Node.js](https://nodejs.org/en/). Make sure to install both node.js and npm.
2. install [Mathjax-node](https://github.com/mathjax/mathjax-node) using `npm install -g mathjax-node`.
3. install [Mathjax-node-cli](https://github.com/mathjax/mathjax-node-cli) using `npm install -g mathjax-node-cli`.

### Issues

Baseline alignment issue, various approaches

1. https://tex.stackexchange.com/questions/44486/pixel-perfect-vertical-alignment-of-image-rendered-tex-snippets/45621
2. https://www.princexml.com/forum/topic/2971/using-mathjax-with-princexml

For now, the easiest approach seems to be to create the HTML output with MathJax enabled with SVG output, then extract the CSS setting `vertical-align` on the generated elements, and use those in a `@rend` attribute. Far from ideal until an automated process can be programmed.

