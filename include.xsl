<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f xd xi xhtml xs">

    <xsl:output indent="no" method="xml" encoding="utf-8"/>

    <!-- stub function used by log.xsl -->
    <xsl:function name="f:is-set" as="xs:boolean">
        <xsl:param name="value" as="xs:string"/>
        <xsl:sequence select="true()"/>
    </xsl:function>


    <xsl:include href="modules/log.xsl"/>
    <xsl:include href="modules/rend.xsl"/>


    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="divGen[@type='Inclusion']">

        <xsl:variable name="url" select="if (@url) then @url else f:rend-value(@rend, 'include')"/>

        <xsl:if test="$url">
            <xsl:variable name="document" select="substring-before($url, '#')"/>
            <xsl:variable name="fragmentId" select="substring-after($url, '#')"/>
            <xsl:variable name="content"
                select="if ($fragmentId)
                    then document($document, .)//*[@id=$fragmentId]
                    else document($url, .)/*"/>
            <xsl:copy-of select="$content"/>
        </xsl:if>
    </xsl:template>


</xsl:stylesheet>
