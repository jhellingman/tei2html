# Introduction #

The ePub 3 standard is a broad overhaul of ePub, and adds a lot of important features to ePub, including support for HTML5 and CSS3, better support for multilingual documents, etc.

  * The standard is here: [ePub 3.0](http://idpf.org/epub/30).
  * More details on the [epub-revision project page](http://code.google.com/p/epub-revision/).
  * An extensive [blog post here](http://sigildev.blogspot.com/).

To be able to use the new features introduced in ePub 3.0, we will need to make a number of changes to `tei2html`. The driving forces for this effort from the `tei2html` perspective are:

  * Better support for HTML5 and CSS3
  * Better support for metadata (including reliable way to specify cover images, etc.)
  * Better way to specify a table of contents.
  * Better ability to embed fonts
  * SVG and MathML support.

All such new features of course need support from readers. Such support can be expected quickly on PC-based viewers, but may take considerable time to trickle down to dedicated reader hardware.

For proper development, we also need to be able to test the resulting ePub3 with a number of supporting readers, which are not available at the time.

Features not within current scope are Javascript support (we like to keep our books passive) and media overlays.

## Things to do ##

For `tei2html` to support ePub 3.0 we need to do add some new information to our ePub files. In most cases, that information can easily be derived from the existing TEI files, so no changes to data-files will be required.

Also see [ePub3 changes](http://idpf.org/epub/30/spec/epub30-changes.html).

Many of the things to-do can be aligned with over-all support for HTML5/CSS3. Specific for ePub3 are:

  * NCX replaced by [EPUB Navigation Documents](http://idpf.org/epub/30/spec/epub30-contentdocs.html#sec-xhtml-nav).
  * Page-lists now part of standard.
  * Page [headers and footers](http://idpf.org/epub/30/spec/epub30-contentdocs.html#sec-css-oeb-head-foot)
  * Improved meta-data in `.opf` file.
    * See [Metadata transition](http://idpf.org/epub/30/spec/epub30-publications.html#sec-package-metadata-dcmi-transition).

# Changes to the .OPF file #

## Metadata ##

New metadata uses the `<meta>` tag (samples taken from draft ePub 3.0 specification).

`<meta>` elements with the `@about` attribute give further information on the metadata.

```xml
<metadata>
    <meta property="dcterms:identifier" id="dcterms-id">urn:uuid:54dc9f06-3174-4b6b-a29a-0dd1fa0969e4</meta>
    <meta about="#pub-id" property="scheme">uuid</meta>
    
    <meta property="dcterms:identifier" id="isbn-id">urn:isbn:9780101010101</meta>
    <meta about="#isbn-id" property="scheme">isbn</meta>
    
    <meta property="source-identifier" id="src-id">urn:isbn:9780375704024</meta>
    <meta about="#src-id" property="scheme">isbn</meta>
    
    <meta property="dcterms:title" id="title">Norwegian Wood</meta>
    <meta about="#title" property="alternate-script" xml:lang="ja">ノルウェイの森</meta>
    <meta about="#title" property="title-type">primary</meta>
    
    <meta property="dcterms:modified">2011-01-01T12:00:00Z</meta>
    <meta property="dcterms:language">en</meta>
    <meta property="page-progression-direction">ltr</meta>
    
    <meta property="dcterms:creator" id="creator">Haruki Murakami</meta>
    <meta about="#creator" property="alternate-script" xml:lang="ja">村上 春樹</meta>
    <meta about="#creator" property="file-as">Murakami, Haruki</meta>
    <meta about="#creator" property="role">aut</meta>
</metadata>
```

Old-fashioned metadata can be linked to their 3.0 equivalents using the `@prefer` attribute. (I think it is unlikely readers will actually use this; library management software might do so.)

```xml
<metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:identifier id="pub-id" prefer="uuid">urn:uuid:54dc9f06-3174-4b6b-a29a-0dd1fa0969e4</dc:identifier>
    <meta property="dcterms:identifier" id="uuid">urn:uuid:54dc9f06-3174-4b6b-a29a-0dd1fa0969e4</meta>
</metadata>
```

Note that the identifier indicated by the `@unique-identifier` attribute on the `<package>` element combined with the last modification date is used to generate a package id.

```xml
<metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:identifier id="pub-id">urn:uuid:A1B0D67E-2E81-4DF5-9E67-A64CBE366809</dc:identifier>
    
    <meta property="dcterms:identifier" id="dcterms-id">urn:uuid:A1B0D67E-2E81-4DF5-9E67-A64CBE366809</meta>
    <meta about="#pub-id" property="scheme">uuid</meta>

    <meta property="dcterms:modified">2011-01-01T12:00:00Z</meta>
</metadata>
```

Results in a Package ID: `urn:uuid:A1B0D67E-2E81-4DF5-9E67-A64CBE366809@2011-01-01T12:00:00Z`.

## Manifest ##

The manifest now has [manifest item properties](http://idpf.org/epub/30/spec/epub30-publications.html#sec-item-property-values), to specify specific roles of the items listed. This can be used to indicate what is the navigation document, and cover-images. This is also required if certain features are used in an element (e.g. mathml, scripted, remove-content, SVG).

```xml
<item properties="nav" id="toc" href="contents.xhtml" media-type="application/xhtml+xml"/>
...
<item properties="cover-image" id="cover" href="cover.svg" media-type="image/svg+xml"/>
```

# Navigation Document #

The navigation document is now a valid `XHTML` page, wrapped in the `<nav>` element.

# Validation #

See this [short article on threepress](http://blog.threepress.org/2011/06/13/validating-epub-3-today/).

# XHTML #

Will need to generate valid XHTML, which means:

  * Removal of some attributes, such as summary, valign, align, width, etc. from elements.