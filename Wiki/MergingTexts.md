# Introduction #

Larger works where often issued in multi-volume sets, and as a result also encoded as separate TEI files. However, in files do not have the restrictions of physical bound volumes, and it is often beneficial to merge two or more TEI files into a single TEI file. This will help in particular when there are a lot of internal cross-references between the volumes, such as will happen with an index (which often appears in the last volume).


# Steps #

## 1. Create an XSLT 'galley' file ##

The idea is to create an XSLT stylesheet that will merge the individual volumes, and provide them with a new TEI-header (which in turn can also be put together from elements pulled from the TEI-header of one or more of the source TEI files. Some things to consider:

* Combined TEI-header. Often the contents of the first TEI-header, with some changes will be sufficient.
* Combined tables-of-contents. Here, we may need to have some smart xpath queries to extract the various fragments of the table-of-contents from the various volumes (or simply generate the entire thing anew).
* Combined body content, which may require the introduction of a new level of divisions ("parts" or "volumes"), which in turn may require adjusting the numbering of numbered `div` elements (e.g. `div` should become `div2`, etc.).
* Combined material in the front- or back-matter (such as Appendices), which may require some re-numbering.

## 2. Run the XSLT galley file ##

Here we run XSLT over the galley file to create a new TEI file. In this step we will collect the content, and put it together to form a new single TEI file.

## 3. Use the combined file as source ##

Here we run XSLT again to perform the conversion to the final output format, on the output of step 2 above.

# Galley File Support Functions #

Most of the hard work happens in the creation of the galley file. For this a number of support functions are needed.

_Change Ids_ To prevent id-clashes, the ids in both source TEI files need to be changed. This is done best by prefixing them with a unique string for each volume.

However, not all ids should be treated as such, as that would break inter-volume cross-references. To prevent this, such inter-volume cross-references should already have the prefix when they are referred to in other volumes, and the software should be smart enough not to add the prefix once more.

Further more, a number of ids have special value to the rendering process, and should be kept verbatim as well. The ids should be preserved (at most once) as-is in one of the source volumes.

Finally, some elements might no longer be needed in the combined volume (such as textual references to another volume, or labels giving the volume number.) They should be filtered out.

To make this easy, we will need to supplement the standard XSLT import function with a smart import that will take care of those changes. See the function `f:import-document` in `merge-documents.xsl` for the implementation.

