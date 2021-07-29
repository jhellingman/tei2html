<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:f="urn:stylesheet-functions"
    exclude-result-prefixes="f xs xd">


    <xd:doc type="stylesheet">
        <xd:short>Utility functions, used by tei2html</xd:short>
        <xd:detail>This stylesheet contains a number of utility functions, used by tei2html and tei2epub.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2021, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Normalize a file name received as a parameter.</xd:short>
    </xd:doc>

    <xsl:function name="f:normalizeFilename" as="xs:string?">
        <xsl:param name="filename" as="xs:string?"/>
        <xsl:value-of select="replace(normalize-space($filename), '^file:/', '')"/>
    </xsl:function>

</xsl:stylesheet>
