
# Support for footnotes, etc. #

`tei2html` supports various types of notes, that is:

* footnotes
* marginal notes
* endnotes
* notes to tables
* apparatus notes

Each of these types is handled in a slightly different way.

## Footnotes ##

Notes, given in the element `<note>` are, by default, considered footnotes. That can be made explicit by adding `@place="foot"`

Footnotes appear at the bottom (or foot) of the page. Since HTML does not have the concept of a page, `tei2html` collects all footnotes at the end of the `div0` or `div1` element they appear in.

If this is undesired, you can also explicity call for the footnotes to be rendered, by inserting a `<divGen type="footnotes">`, which will generate the footnotes in a generate section. If only the body of that section is desired, use `<divGen type="footnotebody">`.

Footnotes will be automatically numbered per division. In the text, a small superscript number will link to the actual footnote. This same number is rendered in front of the footnote, and will link back to the location in the text. A small up-arrow at the end of the footnote will also link back to the text.

Sometimes, multiple footnote references on a page refer to the same footnote. This can be encoded using the `@sameAs` attribute, linking it to the `@id` of the other footnote. This way, multiple references can be made to the same footnote (using the same number). The up-arrow after such a duplicated note will be followed lower-case letters, each linking back to an occurance in the text.

If you want to override the automatically assigned note number, you can provide an alternative marker with `@rend="note-marker(*)"`. Note that this will _not_ change the generated number of other notes, that is, the note will still be counted [TODO: fix this].

## Marginal notes. ##

`tei2html` support various types of marginal notes. The way they are placed in the margin in the HTML output is defined by various CSS rules. To indicate a note is a marginal note, use the `@place` attribute. This can have the following values:

* `margin`
* `left`
* `right`
* `cut-in-left`
* `cut-in-right`

The top three options will place the note outside the text-block. The cut-in variants will place the note as a floating box inside the text-block of the main text.

Some care is need to prefent marginal notes to overlap each other. Simply don't place them too close to each other. It may help to widen the margin if needed.

## Table notes. ##

Notes that appear inside a table can be marked with `@place="table"`. In that case, the notes will be rendered directly below the table, and numbered with lower-case letters, starting anew for each table.

Notes in tables not marked as table notes will be treated as footnotes to the division the table appears in.

## Apparatus notes. ##

Text-critical works often include numerous notes linked to words or lines in the source text, indicating variant readings of the text in one or more editions being compared.

You can indicate apparatus notes with `@place="apparatus"`. Notes marked thus will not be automatically rendered in the output, but require you request their rendering using `<divGen type="apparatus">`. At that location, all apparatus notes preceding this `divGen` will be rendered in a single paragraph (unless an apparatus notes contains multiple paragraphs itself).

All apparatus notes will be given the same reference symbol (by default a degree sign), which will be used to link the notes with their point of reference.

If you use multiple instances of `<divGen type="apparatus">`, multiple blocks of apparatus notes will be generated, each containing the notes before the block, but after the previously generated block.

