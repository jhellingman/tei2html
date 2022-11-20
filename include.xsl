<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="urn:stylesheet-functions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="f xs">

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


    <xsl:template match="*[self::div || self::div0 || self::div1 || self::div2 || self::lg]
                          [f:has-rend-value(@rend, 'align-with-document')]">
        <xsl:variable name="url" select="f:rend-value(@rend, 'align-with-document')"/>
        <xsl:variable name="document" select="substring-before($url, '#')"/>
        <xsl:variable name="fragmentId" select="substring-after($url, '#')"/>

        <xsl:variable name="content"
            select="if ($fragmentId)
                then document($document, .)//*[@id=$fragmentId]
                else document($url, .)/*"/>

        <!-- handle the original content -->
        <xsl:variable name="element" select="local-name()"/>
        <xsl:variable name="newId" select="@id || '_' || $fragmentId"/>
        <xsl:variable name="newRend" select="f:remove-rend-value(@rend, 'align-with-document')"/>
        <xsl:variable name="newRend" select="f:add-rend-value($newRend, 'align-with', $newId)"/>

        <xsl:copy>
            <xsl:attribute name="rend" select="$newRend"/>
            <xsl:apply-templates select="@*[not(name()='rend')]|node()"/>
        </xsl:copy>

        <!-- pull in the 'align-with' content, giving its top-level node the new id, and (TODO) adjusting ids on the fly -->
        <xsl:apply-templates select="$content" mode="new-id">
            <xsl:with-param name="newId" select="$newId"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="*" mode="new-id">
        <xsl:param name="newId"/>
        <xsl:copy>
            <xsl:attribute name="id" select="$newId"/>
            <xsl:attribute name="rend" select="f:add-rend-value(@rend, 'display', 'none')"/>
            <xsl:apply-templates select="@*[not(name()=('rend', 'id'))]|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
