# Internal Cross References #

Internal cross-references are to be encoded using the `<ref>` element, with the `@target` attribute carrying the id of the target element referenced to.

## Special types of references ##

**Footnotes:** Sometimes footnotes markers appear multiple times on a page, each referring to the same note. When these are encoded as follows:

`<ref target="n123.1" type="noteref">1</note>`

They will be rendered as a superscript number with the actual number replacing the content.

**Page numbers:** When a reference is made to a page-number, you can encode these as follows:

`See page <ref target="pb123" type="pageref">123</note> for details.`

When this is rendered on page media, the content will be replaced with the actual page number of the page the reference appears on.

# External Cross References #

External cross-references are to be encoded using the `<xref>` element, with the `@url` attribute carrying the url of the resource referenced.

## Shorthand notations ##

**Project Gutenberg text:** Use `pg:<`_ebook number_`>` as url.

This will link to the catalog page of the given book on [Project Gutenberg](http://www.gutenberg.org).

**WorldCat catalog page:** Use `oclc:<`_number_`>` as url.

**Open Library catalog page:** Use `oln:<`_number_`>` as url (when referring tot the published edition used as source).

**Open Library catalog page:** Use `olw:<`_number_`>` as url (when referring to the abstract 'work').

**WikiPedia article:** Use `wp:<`_title_`>` as url.

**Bible citation:** Use `bib:<`_book chapter:verse_`>` as url.

This will link to a page at the [BibleGateway](http://www.biblegateway.com/passage/?search=job%201:21&version=NIV) in the same language as the text. Alternatively, it could use the [Skeptics Annotated Bible](http://skepticsannotatedbible.com/job/1.html#21). 

**Custom Shorthand notations:** Use `prefixDef` elements in the TeiHeader.

Also supported are [`prefixDef` definitions](https://tei-c.org/release/doc/tei-p5-doc/en/html/ref-prefixDef.html) from TEI P5, which allows you to define your own prefix and replacement pattern for external links.

# External Link Locations #

Depending on the output format and configuration, the external links will be handled in different ways. In some output formats (print paper) hyperlinks do not work, in others (ePub) they may or may not work, depending on the reader being used. In that case it is desirable to collect all external references in an appendix, and present the full URL, so they can be accessed manually if so desired. This is the current default behavior when generating ePubs.

## A generated section with external links ##

  * Collect all external links in a table.
  * Show the link URL in this table, and make it active if technically possible.
  * From each original link, link from the original link location to the location in the table.
  * From each entry in the table, link back to the location of the original link.
  * The table contains the actual links.

# Future extensions #

Currently, a shorthand link pg:40429 will be translated to a link to the Project Gutenberg page for that book.

When an HTML version is available, it should also be possible to directly link into that book, e.g. pg:40429#ch6 should be automatically translated to:

> http://www.gutenberg.org/files/40429/40429-h/40429-h.htm#ch6

So the reader can consult the referred text with a single action (except that Project Gutenberg redirects such deep links on the first attempt).

It would even be better if we could link into all books, even if they are not yet digitized, using their OpenLibrary work id and some generic vocabulary to access locations inside works. Ultimately resolving such links requires some kind of resolving server with access to a database that can find copies of the work. Think urls that looks like these

> book:olw:123456/chapter/xvi
> book:olw:123456/appendix/a
> book:olw:123456/page/123
> book:olw:123456/page/ix

# Standard Schemes #

Currently, there is a standard scheme for the Bible; it would be nice to have these for many widely cited works as well, e.q. the Koran, the Vedas, works by Shakespeare, Milton, etc. Basically, anything that in the past editors found it beneficial to define schemes for in reference works.
