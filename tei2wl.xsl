<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="f fn xd xs"
    >

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to produce a word frequency list (per language) from any XML document</xd:short>
        <xd:detail> </xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>

<xsl:output omit-xml-declaration="yes" indent="yes"/>


<xsl:template match="/">

    <!-- Collect all words with their language in a variable -->
    <xsl:variable name="words">
        <xsl:apply-templates mode="words"/>
    </xsl:variable>

    <usage>
        <xsl:for-each-group select="$words/w" group-by="@xml:lang">
            <words xml:lang="{(current-group()[1])/@xml:lang}">
                <xsl:for-each-group select="current-group()" group-by="@form">
                    <xsl:sort select="(current-group()[1])/@form" order="ascending"/>
                    <group>
                        <xsl:for-each-group select="current-group()" group-by=".">
                            <xsl:sort select="(current-group()[1])" order="ascending"/>
                            <word count="{count(current-group())}">
                                <xsl:value-of select="current-group()[1]"/>
                            </word>
                        </xsl:for-each-group>
                    </group>
                </xsl:for-each-group>
            </words>
        </xsl:for-each-group>
    </usage>

</xsl:template>


<xsl:function name="f:words" as="xs:string*">
    <xsl:param name="string" as="xs:string"/>
    <xsl:analyze-string select="$string" regex="{'[\p{L}\p{N}\p{M}-]+'}">
        <xsl:matching-substring>
            <xsl:sequence select="."/>
        </xsl:matching-substring>
    </xsl:analyze-string>
</xsl:function>


<xsl:function name="f:strip_diacritics" as="xs:string">
    <xsl:param name="string" as="xs:string"/>
    <xsl:value-of select="fn:replace(fn:normalize-unicode($string, 'NFD'), '\p{M}', '')"/>
</xsl:function>


<xsl:template mode="words" match="text()">
    <xsl:variable name="lang" select="(ancestor-or-self::*/@lang|ancestor-or-self::*/@xml:lang)[last()]"/>

    <xsl:for-each select="f:words(.)">
        <xsl:if test=". != ''">
            <w>
                <xsl:attribute name="xml:lang" select="$lang"/>
                <xsl:attribute name="form" select="fn:lower-case(f:strip_diacritics(.))"/>
                <xsl:value-of select="."/>
            </w>
        </xsl:if>
    </xsl:for-each>
</xsl:template>




</xsl:stylesheet>
