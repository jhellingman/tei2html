<?xml version="1.0" encoding="iso-8859-1" ?>
<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="2.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="xd">

    <xd:doc type="stylesheet">
        <xd:short>TEI stylesheet to convert a TEI document to HTML.</xd:short>
        <xd:detail>This stylesheet is the main entry point for the TEI to HTML conversion. It contains no
        templates itself, but collects all stylesheets, and sets a number of global variables.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011-2018, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:include href="utils.xsl"/>
    <xsl:include href="utils.html.xsl"/>
    <xsl:include href="configuration.xsl"/>
    <xsl:include href="log.xsl"/>
    <xsl:include href="localization.xsl"/>
    <xsl:include href="header.xsl"/>
    <xsl:include href="inline.xsl"/>
    <xsl:include href="rend.xsl"/>
    <xsl:include href="css.xsl"/>
    <xsl:include href="references.xsl"/>
    <xsl:include href="titlepage.xsl"/>
    <xsl:include href="block.xsl"/>
    <xsl:include href="notes.xsl"/>
    <xsl:include href="drama.xsl"/>
    <xsl:include href="contents.xsl"/>
    <xsl:include href="index.xsl"/>
    <xsl:include href="divisions.xsl"/>
    <xsl:include href="tables.xsl"/>
    <xsl:include href="lists.xsl"/>
    <xsl:include href="figures.xsl"/>
    <xsl:include href="colophon.xsl"/>
    <xsl:include href="gutenberg.xsl"/>
    <xsl:include href="facsimile.xsl"/>
    <xsl:include href="stripns.xsl"/>

    <xsl:output
        doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
        doctype-system="http://www.w3.org/TR/html4/loose.dtd"
        method="html"
        encoding="iso-8859-1"/> <!-- iso-8859-1; utf-8 -->

    <!--<xsl:output
        doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
        method="xml"
        encoding="iso-8859-1"/>-->


    <!--====================================================================-->

    <xd:doc type="string">Name used as prefix for generated file names.</xd:doc>
    <xsl:param name="basename" select="'book'"/>

    <xd:doc type="string">Path in which generated files will be placed.</xd:doc>
    <xsl:param name="path" select="'.'"/>

    <xd:doc type="string">Generate special markup used by PrinceXML to generate PDF files (Yes or No).</xd:doc>
    <xsl:param name="optionPrinceMarkup" select="'No'"/>

    <!--====================================================================-->

    <xsl:variable name="mimeType" select="'text/html'"/>   <!-- 'text/html' or 'application/xhtml+xml'. -->
    <xsl:variable name="encoding" select="document('')/xsl:stylesheet/xsl:output/@encoding"/>
    <xsl:variable name="outputmethod" select="document('')/xsl:stylesheet/xsl:output/@method"/>
    <xsl:variable name="outputformat" select="'html'"/>

    <xsl:variable name="title" select="/*[self::TEI.2 or self::*:TEI]/*:teiHeader/*:fileDesc/*:titleStmt/*:title[not(@type) or @type='main']"/>
    <xsl:variable name="author" select="/*[self::TEI.2 or self::*:TEI]/*:teiHeader/*:fileDesc/*:titleStmt/*:author"/>
    <xsl:variable name="publisher" select="/*[self::TEI.2 or self::*:TEI]/*:teiHeader/*:fileDesc/*:publicationStmt/*:publisher"/>
    <xsl:variable name="pubdate" select="/*[self::TEI.2 or self::*:TEI]/*:teiHeader/*:fileDesc/*:publicationStmt/*:date"/>

    <xsl:variable name="p.element" select="if ($optionPrinceMarkup = 'Yes') then 'div' else 'p'"/>

    <!--====================================================================-->

</xsl:stylesheet>
