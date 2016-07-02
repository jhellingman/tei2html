<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="f xs xd"
    version="2.0">

    <xd:doc type="stylesheet">
        <xd:short>Extract segments from a TEI document.</xd:short>
        <xd:detail>
            <p>This stylesheet extracts segments from an XHTML document.</p>
        </xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2014, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:output 
        method="text" 
        indent="no"
        encoding="utf-8"/>

    <xsl:template match="/">
        <xsl:apply-templates select="//html:span[@class='seg']" />
    </xsl:template>

    <xsl:template match="html:span[@class='seg']">
        <xsl:value-of select="@id"/>
        <xsl:text>|</xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text>&#x0A;</xsl:text>
    </xsl:template>

</xsl:stylesheet>
