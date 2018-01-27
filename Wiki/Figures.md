# Figures #

## Figures according to TEI P3 ##

Currently, `tei2html` supports figures following the TEI P3 model, with some modifications.

A `figure` element describes a single image, and optional some heading, legenda text and a description.

The way the image itself was left somewhat implementation dependent. Within the structure of SGML, it could be specified as an entity, which was hardly supported anywhere. `tei2html` worked around this by deriving the image file from the `@id`, using an additional attribute `@url`, or placing the image file name in a rendition ladder in the `@rend` attribute.

## Figures according to TEI P5 ##

TEI P5 revised the figure model, introducing a graphic element, and allowing multiple graphics to be part of a single figure. This better matches with practices in books, but requires a revision of the code.

The new model allows multiple graphics in a figure and specifies the attribute `@url` as the way to specify the image.


## Adjustments to Code ##

The current code should remain functional for exsisting texts.

* When a single `graphic` element appears in a figure, behavior should be the same as an P3 style `figure` with an attribbute, that is, the width of the block is the width of the image. (DONE)
* When multiple `graphic` elements appear, the images should be rendered under each other; the width of the entire block being the widest of these images.
