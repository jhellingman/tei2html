

Support for mathematical formulas

Notation: `<formula id=f1 notation="TeX">$$E = mc^2$$</formula>`

Processing:

1. Use pre-processing script to extract all formula contents to separate files (XSLT can do the trick).
2. Use another script to convert all these files to SVG files (Perl, node.js, etc)
3. Use main XSLT transform to include the SVG files as images (or inline)

Naming scheme `formula-<ID>.tex`, etc. and `formula-<ID>.svg`.

Resources:

1. https://www.npmjs.com/package/tex-equation-to-svg
2. https://dvisvgm.de/
3. https://tex.stackexchange.com/questions/255470/compile-tex-directly-into-svg-using-the-command-line

Solution depends on MathJax library (https://www.mathjax.org/), run locally in node.js.
