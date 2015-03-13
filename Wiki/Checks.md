# Introduction #

XSLT style-sheet to check various TEI conventions and textual issues.


# Metadata #

Verify metadata is present and correct.

# Rendering #

Verify valid rendering attributes are used

  * valid CSS-based rendition ladders
  * valid tei2html extensions.

# Types #

Verify types for elements are valid according to the conventions.

# Numbering #

Verify whether numbered items are in sequence.

  * page-breaks `<pb>`
  * divisions `<div#>`

# Spacing and Punctuation #

Verify punctuation marks are properly spaced.

# Quotation Marks #

Verify whether quotation marks are applied correctly.

Quotation marks need to be nested correctly, and for each
opening mark, there should be a corresponding closing mark.

This is slightly complicated by several facts:

  * different types of usage
    * US: outer double, inner single quotation marks
    * UK: outer single, inner double quotation marks
  * different conventions for languages and countries.
  * usage around other punctuation might vary.
  * non-closed marks are to be re-opened in next paragraph.