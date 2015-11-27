

# Use of the `@type` attribute #

The `@type` attribute can indicate a sub-class or special use of a certain element.

## Special values ##

The following table gives special values for the `@type` attribute in various contexts. These are
handled in a special way when processing the TEI file.

**TODO** use lower camel case convention for these names.

**TODO** merge divNum and headDivNum (adjust files and stylesheets).


| **TEI element**       | **`@type` value**      | **Notes**                  |
|:----------------------|:-----------------------|:---------------------------|
| `ab`                  | `divNum`               | Indicates a division number (typically within a `head` element). |
| `ab`                  | `flushright`           | Indicates the `ab` should be set flush right. |
| `ab`                  | `headDivNum`           | Indicates a division number (typically within a `head` element). |
| `ab`                  | `lineNum`              | Indicates a line number (typically within a `p` or `l` element). |
| `ab`                  | `lineNumRef`           | Indicates a reference to a line number. |
| `ab`                  | `tocDivNum`            | Indicates a division number within a toc. |
| `ab`                  | `tocPageNum`           | Indicates a page number within a toc. |
| `div1`                | `TranscriberNote`      | The division is a note by the transcriber (rendered in a different color). |
| `div2`                | `SubToc`               | The division is a toc for the div1 it appears in (content will be replaced by generated content). |
| `divGen`              | `apparatus`            | Generate a section with apparatus notes (can be used multiple times, all apparatus notes between this and the previous instance will be included). |
| `divGen`              | `Colophon`             | Generate a colophon (based on information in the TEI header). |
| `divGen`              | `ColophonBody`         | Generate the body of a colophon (based on information in the TEI header). |
| `divGen`              | `Footnotes`            | Generate a section with footnotes. |
| `divGen`              | `FootnotesBody`        | Just the body. |
| `divGen`              | `gallery`              | Generate a gallery of illustrations (requires availability of thumbnail images). |
| `divGen`              | `Inclusion`            | Include an external file here; using `@url` attribute. |
| `divGen`              | `index`                | Generate an index. |
| `divGen`              | `IndexToc`             | Generate a one-line toc for an Index (displaying one-letter links). |
| `divGen`              | `LanguageFragments`    | Generate a list of fragments in foreign languages (i.e., not the main langauge of the text). |
| `divGen`              | `loi`                  | Generate a table of illustrations. |
| `divGen`              | `pgfooter`             | Generate the Project Gutenberg boilerplate footer. |
| `divGen`              | `pgheader`             | Generate the Project Gutenberg header. |
| `divGen`              | `toc`                  | Generate a table of contents. Additional `@rend` attribute value tocMaxLevel(n) can be used to control the depth.|
| `divGen`              | `toca`                 | Generate a table of contents (including chapter arguments). |
| `divGen`              | `tocBody`              | Just the body. |
| `head`                | `label`                | The (division) heading is a label indicating its type and number. (Typically 'Chapter IX'). |
| `head`                | `sub`                  | The (division) heading is a sub-title. |
| `head`                | `super`                | The (division) heading is the title of a higher level division. |
| `idno`                | `epub-id`              | The `idno` gives a unique identifier for the generated ePub file. |
| `idno`                | `ISBN`                 | The `idno` gives the ISBN for the edition. |
| `idno`                | `LCCN`                 | The `idno` gives the Library of Congress call number. |
| `idno`                | `LibThing`             | The `idno` gives the Library Thing catalog number for the edition. |
| `idno`                | `OCLC`                 | The `idno` gives the WorldCat catalog number for the edition. |
| `idno`                | `OLN`                  | The `idno` gives the Open Library catalog number for the (source) edition. |
| `idno`                | `OLW`                  | The `idno` gives the Open Library catalog number for the work. |
| `idno`                | `PGnum`                | The `idno` gives the Project Gutenberg ebook number. |
| `list`                | `determinationTable`   | Convert the list to a (potentially nested) table as used for determination in biological works. |
| `list`                | `tocList`              | Convert the list to a (potentially nested) table of contents. |
| `p`                   | `figBottom`            | The paragraph will be placed on the bottom-center of a figure. |
| `p`                   | `figBottomLeft`        | The paragraph will be placed on the bottom-left of a figure. |
| `p`                   | `figBottomRight`       | The paragraph will be placed on the bottom-right of a figure. |
| `p`                   | `figTop`               | The paragraph will be placed on the top-center of a figure. |
| `p`                   | `figTopLeft`           | The paragraph will be placed on the top-left of a figure. |
| `p`                   | `figTopRight`          | The paragraph will be placed on the top-right of a figure. |
| `ref`                 | `endnoteref`           | The reference refers to an end foot-note. |
| `ref`                 | `noteref`              | The reference refers to a foot-note (The generated foot-note number of the note referred to is used in the output). |
| `ref`                 | `pageref`              | The reference refers to a page (by number; the ref is supposed to only include the actual number referred to). |
| `title`               | `pgshort`              | The title is a short title for Project Gutenberg purposes. |
| `titlePart`           | `main`                 | The title part is the main title. |
| `titlePart`           | `series`               | The title part is a series title. |
| `titlePart`           | `sub`                  | The title part is a sub-title. |


| **TEI element**       | **`@place` value**     | **Notes**                  |
|:----------------------|:-----------------------|:---------------------------|
| `note`                | `apparatus`            | The note is part of a critical apparatus. |
| `note`                | `foot`                 | The note is a footnote (*default*). |
| `note`                | `margin`               | The note is a marginal note. |


| **TEI element**       | **`@unit` value**      | **Notes**                  |
|:----------------------|:-----------------------|:---------------------------|
| `milestone`           | `tb`                   | The milestone is a thematic break. |
