<?xml version="1.0" encoding="iso-8859-1" ?>
<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="xd">

    <xd:doc type="stylesheet">
        <xd:short>TEI stylesheet to convert a TEI document to HTML.</xd:short>
        <xd:detail>This stylesheet is the main entry point for the TEI to HTML conversion. It contains no
        templates itself, but collects all stylesheets, and sets several global variables.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011-2018, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:include href="modules/functions.xsl"/>
    <xsl:include href="modules/utils.xsl"/>
    <xsl:include href="modules/utils.html.xsl"/>
    <xsl:include href="modules/betacode.xsl"/>
    <xsl:include href="modules/configuration.xsl"/>
    <xsl:include href="modules/log.xsl"/>
    <xsl:include href="modules/localization.xsl"/>
    <xsl:include href="modules/header.xsl"/>
    <xsl:include href="modules/inline.xsl"/>
    <xsl:include href="modules/rend.xsl"/>
    <xsl:include href="modules/css.xsl"/>
    <xsl:include href="modules/references.xsl"/>
    <xsl:include href="modules/titlepage.xsl"/>
    <xsl:include href="modules/block.xsl"/>
    <xsl:include href="modules/notes.xsl"/>
    <xsl:include href="modules/numbers.xsl"/>
    <xsl:include href="modules/drama.xsl"/>
    <xsl:include href="modules/contents.xsl"/>
    <xsl:include href="modules/index.xsl"/>
    <xsl:include href="modules/divisions.xsl"/>
    <xsl:include href="modules/tables.xsl"/>
    <xsl:include href="modules/lists.xsl"/>
    <xsl:include href="modules/formulas.xsl"/>
    <xsl:include href="modules/figures.xsl"/>
    <xsl:include href="modules/colophon.xsl"/>
    <xsl:include href="modules/gutenberg.xsl"/>
    <xsl:include href="modules/facsimile.xsl"/>
    <xsl:include href="modules/stripns.xsl"/>
    <xsl:include href="modules/variables.xsl"/>

    <xsl:output
        doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
        doctype-system="http://www.w3.org/TR/html4/loose.dtd"
        method="html"
        encoding="utf-8"/> <!-- iso-8859-1; utf-8 -->

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
    <xsl:variable name="outputMethod" select="document('')/xsl:stylesheet/xsl:output/@method"/>
    <xsl:variable name="outputFormat" select="'html5'"/>

    <xsl:variable name="p.element" select="if ($optionPrinceMarkup = 'Yes') then 'div' else 'p'"/>

    <!--====================================================================-->

    <xd:doc>
        <xd:short>Main stylesheet for HTML generation.</xd:short>
    </xd:doc>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>
