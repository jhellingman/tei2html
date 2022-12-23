# Introduction #

TEI P5 contains a [facsimile element](http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-facsimile.html) to represent scanned documents, as well as some other features to better support facsimiles. These features can be used to link to the original scans.

Often scans are already available at some place on the web, and we may wish to point to them, sometimes, we wish to include them with our ebook, so we have two types of facsimiles: external images and internal images.

TEI offers two ways of referring to scanned facsimile images, one is using the `@facs` attribute on the `pb` element, the other is using `graphic` elements in a separate `facsimile` section. When using the latter option, the `@facs` attributes on the `pb` elements can also (and should) refer to those `graphic` elements.

The facsimile files themselves can be either hosted locally (on a file-system under our control) or remotely (with a third party). In the former case, we can generate self-contained ePubs with all the files on-board, in the later case, we have to make do with external references.

Finally, we can refer directly to the facsimiles, or generate an HTML wrapper that includes the facsimile (assumed to be an image in a supported format here). The HTML wrapper will be required if we include the facsimile images in an ePub file.

All combined, this gives a number of options to take into account when dealing with facsimile editions.

# Facsimile Element #

The `facsimile` element is a top-level element, that describes a series of page images, and can stand independently of the transcribed text. This allows to specify just the metadata (in the Header) and the scans, to produce a digital facsimile.

```xml
   <facsimile>
      <graphic id="facs123" url="p123.png"/>
   </facsimile>
```

# `@facs` Attribute #

The `@facs` attribute on `pb` elements can be used to point to scanned images of transcribed pages. This can be used to either link to some external source of page images (for example in the Internet Archive), or to link to an internal set of images (kept in a page-images sub-directory, for example).

```xml
  <pb n="123" facs="p123.png"/>
```

Let's call this "direct" facsimile links.

Alternatively, it can link to an element in the `facsimile` element, for example:

```xml
  <pb n="123" facs="#facs123"/>
```

Let's call this "indirect" facsimile links.

This later case also allows to point to zones within a page, but that is currently out-of-scope for `tei2html`.

The two ways should not be combined. Currently, the code only allows the "direct" way of linking to page images.

## Comparison of direct and indirect linking to facsimiles ##

### Direct ###

Generate output wrapper file for each `pb`-element. `[DONE]`

Generate links from HTML output to wrapper file. `[DONE]`

Use location in text version defined by that `pb`-element to generate structural navigation aid (breadcrumbs) `[DONE]`

Non-transcribed pages cannot be included (or we should encode additional `pb`-elements for those pages).

### Indirect ###

Generate output wrapper file for each `graphic`-element. `[DONE]`

Look-up referring `pb`-element to find location in text version to generate structural navigation aid. This may not be present, in which case we cannot use structural navigation guides (or use the next `graphic` element that does have a matching `pb`) `[DONE]`

Generate links from HTML output to wrapper file, taking this into account. `[DONE]`

Not all `graphic`-elements might be referred to by a `pb`-element. Need to decide what to do in this case, but probably using the next `graphic`-element that does have a matching `pb`-element is a good default strategy for producing navigational aids on those pages. `[TODO]`

Need to deal with case that no text is present at all (that is, we have a TEI file with just a teiHeader and a facsimile element) `[TODO]`

# Generated Output #

## HTML ##

The output consists of a series of HTML pages, one per page, with some metadata in the heading of the page, and some navigational aids to conveniently jump to another page.

By convention, the facsimile images and wrapper pages will go into a directory `page-images`, and will look like this:

```html
  <html>
    <head>
      <title>Document title, page x</title>
    </head>
    <body>
      <div class="facsimile-header">
         <h1>Document Title, by Document Author, Page x</hi1>
      </div>
      <div class="facsimile-navigation">
         <!-- Buttons to go to previous and next page, and back to text -->
      </div>
      <div class="facsimile-page>
         <img src="\images\pages\p123.gif"/>
      </div>
    </body>
  </html>
```

For each `pb`-element for which a `@facs` attribute is present, a link will be generated to the wrapper file, decorated with a facsimile page-image icon.

### Things to show ###

In header

  * Title of document
  * Name of author
  * Page number (if encoded in `@n` attribute)
  * Title(s) of current division at bottom of page.

Titles are indicated as follows as bread-crumbs:

```
(Front | Body | Back |) > Title Level 1 > Title Level 2 > ... > Page 123
```

Each of these elements are active links, and will link back to those pages (content or facsimile view, to be decided)

Issue: current code removes unused anchors in HTML post-XSLT-transform, using a Perl script, that needs to be modified, as anchors used by those 'external' HTML files are not recognized.

Issue: our current conventions put the `pb` just before the `div#`s. This will lead to the wrong header above the page-image for the first page of a section. Need to add check for case that `pb` element is (almost) last element of a `div#`.

In Navigation

  * Link to Previous Page. `[DONE]`
  * Link to Next Page. `[DONE]`
  * (Optional) Links to all pages. `[TODO]`
  * Link back to location in transcribed text. `[DONE]`

## ePub ##

Similar to HTML, taking into account additions to Spine, metadata, etc.

  * Add generated wrapper files to spine `[TODO]`
  * Add page-images to spine `[TODO]`

If no text element is present, the page-images should become the primary structure of the text.
