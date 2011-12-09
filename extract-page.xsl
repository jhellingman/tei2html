<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="xd"
    version="2.0">

    <xd:doc type="stylesheet">
        <xd:short>Extract page from a TEI document.</xd:short>
        <xd:detail>This stylesheet extracts a page from a TEI document, that is, all content between two pb-elements.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:output 
        method="xml" 
        indent="yes"
        encoding="UTF-8"/>

    <xd:doc type="string">Number of page to extract.</xd:doc>

    <xsl:param name="n" select="12"/>

    <xd:doc type="string">Number of page following the page to extract, determined in code.</xd:doc>

    <xsl:variable name="m">
        <xsl:value-of select="//pb[@n=$n]/following::pb[1]/@n"/>
    </xsl:variable>

    <xsl:template match="node()" priority="1"/>

    <xsl:template match="*[descendant-or-self::pb/@n=$n] | node()[preceding::pb/@n=$n]" priority="2">
         <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="node()[preceding::pb/@n=$m or self::pb/@n=$m]" priority="3"/>



    <xsl:template name="sample">

Extracting a fragment between milestones from a complex structure.

I am looking for a template which allows me to extract a single page, as marked by milestone
elements <pb n="12"/> from a complex structure. Note that the milestone elements may occur in 
different parents. I want all the parent nodes, and everything between the <pb n="12"/> and the next 
<pb/> element

For example, when applying the extract method with as parameter "12" on the following sample

<TEI>
    <front>...</front>
    <body>
        <div1>
            <head>Blah</head>
            Blah blah <pb n="12"/> blah blah.
        </div1>
        <div1>
            Blah blah blah blah.
        </div1>
        <div1>
            Blah <hi>blah <pb n="13"/> blah</hi> blah.
        </div1>
    </body>
    <back>...</back>
</TEI>

It should return:

<TEI.2>
    <body>
        <div1>
            <pb n="12"/> blah blah.
        </div1>
        <div1>
            Blah blah blah blah.
        </div1>
        <div1>
            Blah <hi>blah <pb n="13"/></hi>
        </div1>
    </body>
</TEI.2>

The idea is that it will copy only elements that are a ancestor of either <pb/> and follow
the first <pb/> and precede the second <pb/>. The problem I face is formulating a nice XPath to select
those elements.



    </xsl:template>

</xsl:stylesheet>
