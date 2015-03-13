# Introduction #

Larger works where often issued in multi-volume sets, and as a result also encoded as separate TEI files. However, in files do not have the restrictions of physical bound volumes, and it is often beneficial to merge two TEI files into a single TEI file. This will help in particular when there are a lot of internal cross-references between the volumes, such as will happen with an index.


# Steps #

## 1. Create an XSLT 'galley' file ##

The idea is to create an XSLT stylesheet that will merge the individual volumes, and provide them with a new TEI-header (which in turn can also be put together from elements pulled from one or more of the source TEI files.

## 2. Run the XSLT galley file ##

This will collect the content, and put it together into a single TEI file.

## 3. Use the combined file as source ##

# Galley File Support Functions #

Most of the hard work happens in the creation of the galley file. For this a number of support functions will be needed.

_Change Ids_ To prefent id-clashes, the ids in both source TEI files need to be changed. This is done best by prefixing them with a unique string for each volume.

However, not all ids should be treated as such, as that would break inter-volume cross references. To prevent this, such inter-volume cross references should already have the prefix when they are referred to in other volumes, and the software should be smart enough not to add the prefix once more.

Further more, a number of ids have special value to the rendering process, and should be kept verbatim as well. The ids should be preserved (at most once) as-is in one of the source volumes.

Finally, some elements might no longer be needed in the combined volume (such as textual references to another volume, or labels giving the volume number.) They should be filtered out.

To make this easy, we will need to supplement the standard XSLT import function with a smart import that will take care of those changes.

```
	<xsl:function name="f:import-document">
		<xsl:param name="location" as="xs:string"/>
		<xsl:param name="prefix" as="xs:string"/>
		<xsl:param name="keepPrefix" as="xs:string"/>

		<xsl:apply-templates select="document($location)" mode="import-document">
			<xsl:with-param name="prefix" select="$prefix"/>
			<xsl:with-param name="keepPrefix" select="$keepPrefix"/>
		</xsl:apply-templates>
	</xsl:function>

```