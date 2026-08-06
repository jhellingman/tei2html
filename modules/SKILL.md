# SKILL: Modules quick-reference

Purpose: where to look and what to change when modifying output generation or behavior.

Primary entry points
- tei2html.xsl, tei2html5.xsl — HTML outputs
- tei2epub.xsl, tei2opf.xsl, tei2epubnav.xsl, tei2ncx.xsl — ePub packaging and navigation
- preprocess.xsl — pre-processing pipeline for raw TEI before main transforms

Shared utilities
- modules/utils.xsl, modules/functions.xsl, modules/utils.html.xsl, modules/utils.epub.xsl — common helper templates & functions
- modules/variables.xsl, modules/configuration.xsl — global variables and configuration points

Feature-specific modules (where to edit for common tasks)
- CSS linking & output styles: modules/css.xsl and style/ (layout.css, epub.css, etc.)
- Footnotes / notes: modules/notes.xsl, modules/references.xsl, modules/references-func.xsl
- Division / segmentation: modules/divisions.xsl, modules/splitter.xsl, modules/segmentize.xsl
- Tables: modules/tables.xsl, modules/normalize-table.xsl
- Figures / images: modules/figures.xsl, modules/facsimile.xsl, tei2imageinfo.xsl
- TOC / navigation / packaging: modules/contents.xsl, modules/tei2epubnav.xsl, modules/tei2ncx.xsl, modules/tei2opf.xsl
- Localization: modules/localization.xsl + locale/

Debugging tips
- Turn on Saxon warnings/outval when investigating transform oddities (pom currently sets warnings=silent, outval=recover in xspec config).
- Use XSpec tests in xspec/ to add regression coverage for module changes.

If you need to change a global behavior, start in modules/variables.xsl and modules/configuration.xsl — these are consumed by most modules.