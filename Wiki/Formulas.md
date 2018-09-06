

## Support for mathematical formulas

(Future feature for `tei2html`)

TEI notation: `<formula id=f1 notation="TeX">$$E = mc^2$$</formula>` (see [TEI guidelines](http://www.tei-c.org/release/doc/tei-p5-doc/en/html/FT.html#FTFOR))

Processing:

1. Use pre-processing script to extract all formula contents to separate files (XSLT can do the trick).
2. Use another script to convert all these files to SVG files (Perl, node.js, etc)
3. Use main XSLT transform to include the SVG files as images (or inline)

Naming scheme `formula-<ID>.tex`, etc. and `formula-<ID>.svg`.

Tooling:

1. install [Node.js](https://nodejs.org/en/). Make sure to install both node.js and npm.
2. install [Mathjax-node](https://github.com/mathjax/mathjax-node) using `npm install -g mathjax-node`.
3. install [Mathjax-node-cli](https://github.com/mathjax/mathjax-node-cli) using `npm install -g mathjax-node-cli`.


