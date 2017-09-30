# Introduction #

Since many details of the layout of the output (For both HTML and PDF) are defined in CSS, it is very well possible to define custom CSS to customize the layout of your output.

Rules in custom CSS files take precedence over those used by default, but will be overridden by the generated CSS derived from `@rend` attributes in the source document.

Order of precendence of renditions:

1. CSS derived from `@style` attribute on element.
2. CSS derived from `@style` attribute on row (for table cells only).
3. CSS derived from `@style` attribute on column (for table cells only).
4. CSS derived from `@rend` attribute on element.
5. CSS derived from `@rend` attribute on row (for table cells only).
6. CSS derived from `@rend` attribute on column (for table cells only).
7. CSS in `<rendition>` elements in document.
8. Custom CSS stylesheet.
9. Default CSS stylesheets.
10. Browser defaults.

# Steps for Custom Layout #

The following steps need to be taken to define custom layout.

  * Define a custom layout CSS file.
  * Tell the transformation process about the CSS file.
  * Define the points of attachments (selectors) for the CSS rules.

## Custom CSS files ##

The custom layout CSS file can simply be added by creating a file `custom.css` If this file is present, the Perl script will pick it up and signal it to the XSLT processor for inclusion in the output.

If you give it any other name, you can tell the perl script about it, using the `-c <filename>` option.

## CCS Selectors ##

To indicate on what elements in your TEI file your CSS rules should apply to, you can use a number of techniques.

  * Based on ID attributes.
  * Based on `tei2html` generated class attributes.
  * Based on custom class attributes, specified in `class(...)` in the `@rend` attribute.
  * Based on IDs used in the `@rendition` attribute.

Since `tei2html` in most cases lifts the ids used in the source to the output, your ids in TEI will also be present in the output document, so you can simply use those ids for one-off effects in the output. This can be used to tweak output, using `#id` selectors.

Care need to be taken that ids used in this fashion meet both the syntax rules for CSS and XML.

Second, `tei2html` generates class attributes on its output that correspondent to the element type in TEI from which the output element was generated. These can be used as a convenient way to use `.class` selectors. In addition, `tei2html` also generates additional class attributes for some types of elements. A complete overview will be given in the following table.

| **TEI element**                    | **HTML Output**        | **Notes**                  |
|:-----------------------------------|:-----------------------|:---------------------------|
| _XPath_                          | _CSS Selector_       |                          |
| `//front`                        | `.front`             | Front matter             |
| `//back`                         | `.back`              | Back matter              |
| `//div1`                         | `.div1`              | Similar for all `div`s   |
| `//div1/*[not(preceding-sibling::p)]` | `.divHead`       | Typical heading material of a division |
| `//div1/*[preceding-sibling-or-self::p]` | `.divBody`      | Typical body of a division |
| `//p`                            | `p`                  | Paragraph                |
| `//p[position() = 1]`            | `p.first`            | First paragraph (actual XPath more complex) |
| `//figure`                       | `.figure`            | The actual `img` tag is nested in various `div`s |
| `//lg[not(ancestor::lg)]`        | `.lgouter`           | Top level `lg` elements  |
| `//lg[ancestor::lg]`             | `.lg`                | Nested `lg` elements     |
| `//l`                            | `.line`              | Lines of verse           |
| `//hi`                           | `i`                  | Default without `@rend`  |
| `//hi[@rend='sc']`               | `.sc`                | On `span`                |
| `//hi[@rend='bold']`             | `b`                  |                          |
| `//hi[@rend='sup']`              | `sup`                | Superior text            |
| `//pb`                           | `.pagenum`           | Value of `@n` placed in a `span` |

(_to be completed..._)

### Tables ###

Tables pose some peculiar problems for rendering. By default, tables are rendered without any borders or special spacing, but due to their nature, you often want to manipulate the rendering of tables or cells, and thus use `@rend` attributes.

When a TEI table is converted to HTML, it is surrounded by a `<div>` element, and the `<head>`, if present, is lifted from the table, as support for the HTML caption element in browsers is limited. The table proper is converted to a HTML table.

Rendering attributes on tables can be applied in four ways: on the table as a whole, and on column, row, or cell level.

Rendering on the whole table is handled the normal way.

Rendering on the column level is attached to (non-TEI) `<column>` elements, and is applied before rows or individual cells are considered.

Since HTML support for several CSS attributes on the row level is limited, those rendering attributes will instead be applied to each individual cell in the row. Rendering specified in an `@rend` attribute at the row level overrides those set at the column level.

Finally, rendering set at the cell level will override both column and row rendering.

| **TEI Element**| **HTML Output** | **Notes** |
|:---------------|:----------------|:----------|
| `table`      | `<div class="table">` | Wrapper div, which will contain the caption and the table proper. |
|              | `<table>`             | Actual table, `@rend` applied on this. |
| `table/head` | `<h4 class="tablecaption">` | Header, inside wrapper div, outside table |
| `row`        | `<tr>` |  |
| `cell[@role='label']` | `<td>` | Even though this is a header, still a `<td>`. |
| `cell`       | `<td>` |  |

Furthermore, cells get attributes to indicate whether they are the topmost, rightmost, bottommost or leftmost cell in a table. These can be used to set borders. (Note that those attributes take into account spans).

| **position**  | **Cell in Head** | **Cell in Body** |
|:--------------|:-----------------|:-----------------|
| top | `cellHeadTop` | `cellTop` |
| right | `cellHeadRight` | `cellRight` |
| bottom | `cellHeadBottom` | `cellBottom` |
| left | `cellHeadLeft` | `cellLeft` |


### Footnotes ###

Footnotes can generate a range of elements in the output, depending on the output settings and format.

| **HTML Output** | **Notes** |
|:----------------|:----------|
| _CSS Selector_|         |
| `.noteref`    | The reference marker placed in the text and before the footnote |
| `.displayfootnote` | An inline `span` containing the contents of the footnote (for PDF output) |
| `.footnotes`  | A `div` containing all footnotes for a piece of text |
| `.fnsep`      | A `hr` to separate the footnotes from the text |
| `.footnote`   | A `div` containing a single footnote |

Finally, you can always define a custom class attribute, using `rend="class(myClass)"` on your element, and use that in your custom CSS.
