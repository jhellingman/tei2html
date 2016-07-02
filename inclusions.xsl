<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="http://example.com/"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="f xd xs"
    >

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to include external files into TEI documents.</xd:short>
        <xd:detail><p>Stylesheet to include external files into TEI documents.</p>
        </xd:detail>
    </xd:doc>


    <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>


    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="@TEIform" mode="#all"/>


    <xsl:template match="divGen[@type='Inclusion']">
        <!-- Material to be included should be rendered here; material is given on an url parameter -->
        <xsl:if test="@url">
            <xsl:variable name="target" select="@url"/>
            <xsl:variable name="document" select="substring-before($target, '#')"/>
            <xsl:variable name="otherid" select="substring-after($target, '#')"/>

            <xsl:apply-templates select="document($document, .)//*[@id=$otherid]"/>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>