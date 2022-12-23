# Using the `@rend` attribute #

The `@rend` attribute is a simple hook into the TEI structure to document or specify how features are rendered. Within `tei2html` they can be used to achieve certain formatting effects. This feature should be used with moderation. A number of different ways of using the `@rend` attribute can be distinguished.

Note that according to the TEI Guidelines, the rendering attributes are intended to describe the presentation of the source material, and are not to prescribe any presentation of the output. Since the intention here is to faithfully reproduce text, this distinction is not really important for `tei2html`.

## Simple ##

Simple rendering attribute values provide single keywords to provide a rendering hint. This type of usage is sufficient most of the time. The pre-defined rendering keywords are often element specific, and should be considered as hints only, that is, ignoring the rend attribute should not render the document illegible.

| **Element** | **Recognized `@rend` values**                                                      |
|:------------|:-----------------------------------------------------------------------------------|
| `hi`        | `italic` (_default_) `bold` `bi` `sc` `asc` `sup` `sub` `ex`                       |
| `figure`    | `center` (_default_) `left` `right` `inline`                                       |
| `p`         | `block` `center` `left` (_default_) `right` `indent` `noindent`                    |
| `q`         | `block`                                                                            |
| `list`      | `number` `bullet` `none` (_default_)                                               |
| _Any_       | _Any_ (_these will be added to the class attribute of the output element in HTML_) |

## Rendition Ladders ##

A slightly more powerful mechanism is provided by so called 'rendering ladders', in which a number of key-value pairs are provided. These take the form `key(value)`, and multiple can be present in a `@rend` attribute. They are either translated to CSS, or given a specific meaning, sometimes depending on the element they are applied to.

### CSS equivalents ###

In most cases, rendition ladders are one-on-one translated to equivalent CSS rules. For example, the following snippet of TEI:

```
<p rend="font-style(italic) text-align(left)">A left-aligned paragraph in italics.</p>
```

Will be translated to the following HTML:

```
<p class="x12345">A left-aligned paragraph in italics.
```

And the following CSS rule:

```
.x12345 { font-style: italic; text-align: left; }
```

Note that if the same value for the `@rend` attribute is used multiple times, only one CSS rule will be generated matching all occurrences (and the same class attribute will be used on each of them).

### Special interpretations ###

In a number of places, rendition ladders are interpreted by `tei2html` directly.

The following keys and values are supported: (Note that this list is not exhaustive, and the full list of options will be indicated with each element.)

| **Element**              | **Key**         | **Value**                                                                                                                                                                                                                                                                                               | **Example**                                                                                |
|:-------------------------|:----------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-------------------------------------------------------------------------------------------|
| `text`                   | `stylesheet`    | name of CSS stylesheet                                                                                                                                                                                                                                                                                  | `style/classic.css`                                                                        |
| _Any_                    | `font`          | `italic`, `bold`, `fsc` (full caps and smallcaps), `smallcaps`, `underlined`, `gothic` (note the difference from fall-through CSS)                                                                                                                                                                      | `<hi rend="font(bold)">`                                                                   |
| `p`, `q`                 | `align`         | `right`, `left`, `center`, `block` (that is, justified)                                                                                                                                                                                                                                                 | `<p rend="align(block)">`                                                                  |
| `p`, `l`                 | `indent`        | The number characters to indent. The size of a character is not fixed, but is roughly the size of the letter m.                                                                                                                                                                                         | `<l rend="indent(2)">`                                                                     |
| _Any_                    | `link`          | any url, rendered as link to the indicated url.                                                                                                                                                                                                                                                         | `<figure rend="link(images/a.jpg)">`                                                       |
| `figure`, `head`, `cell` | `image`         | any url, rendered as in-line image, obtained from the indicated url. When used on a `head` element, the image appears above the head, when used on a `cell` element, the image appears in the table-cell (typically used to pull in large braces spanning cells).                                       | `<figure rend="image(images/a.jpg)">`                                                      |
| `figure`                 | `float`         | The place to float in image, table, etc. Possible values: left, right.                                                                                                                                                                                                                                  | `<figure rend="float(left)">`                                                              |
| `figure`                 | `hover-overlay` | In HTML output, when the mouse hovers over the image, the alternative image is shown (using CSS only).                                                                                                                                                                                                  | `<figure rend="hover-overlay(images/overlay.jpg)">`                                        |
| `table`, `list`          | `columns`       | Set the element in multiple columns. May be applied to tables and lists.                                                                                                                                                                                                                                | `<list rend="columns(2)">...</list>`                                                       |
| _Any_                    | `class`         | Sets a class attribute in the corresponding HTML output. This can be used in combination with custom CSS stylesheets to achieve special effects.                                                                                                                                                        | `<p rend="class(myClass)">`                                                                |
| `l`                      | `hemistich`     | Indents the current line with a certain space. When the value starts with a `^` followed by a number _n_, the content of the line _n_ lines before is used, when the value starts with a `#` followed by an id, the content of the element with the id is used, otherwise, the literal content is used. | `<l rend="hemistich(^1)">`, `<l rend="hemistich(#vs21)">`, `<l rend="hemistich(Content)">` |

### Using `@style` and `@rendition` ###

As an alternative to the `@rend` attribute, the current TEI guidelines also provide `@style` and `@rendition` to define presentation in a formally defined language. `tei2html` assumes that is CSS. See the [TEI guidelines on rendition attributes](http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-att.global.rendition.html). Unlike the values of `@rend`, the specified CSS values are not interpreted at all, but passed to the output CSS directly.

Implementation notes:

1. Handle the `@style` attribute, and output it as a CSS rule.
   - generate a unique class name for the CSS fragment.
   - output the value of the `@style` attribute verbatim.
   - remove duplicates, such that identical `@style` attributes are only output once.
   - apply the generated class-name to the relevant output element in HTML.
2. Handle the `@rendition` attribute.
   - apply the given class name(s) to the relevant output element in HTML.
   - verify `<rendition>` elements for the given class names are present in the `<tagsDecl>` of the TEI file.
   - warn if this is not the case.
3. Handle the `<rendition>` tags in the `<tagsDecl>`.
   - verify the rendition id is actually used in the file.
   - output the corresponding CSS verbatim.

