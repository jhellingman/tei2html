<xsl:stylesheet 
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="f fn xd xs"
    >

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to produce a KWIC from any XML document</xd:short>
        <xd:detail> </xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>

<xsl:output omit-xml-declaration="yes" indent="yes"/>

<xsl:param name="keyword" select="'paragraph'"/>
<xsl:param name="language" select="'en'"/>
<xsl:param name="contextSize" select="5"/>

<xsl:template match="/">

    <!-- Collect all words with their language in a variable -->
    <xsl:variable name="words">
        <words>
            <xsl:apply-templates mode="words"/>
        </words>
    </xsl:variable>

    <!-- <xsl:variable name="matches"> -->
        <matches>
            <xsl:apply-templates select="$words/words/w" mode="kwic">
                <xsl:with-param name="keyword" select="$keyword"/>
            </xsl:apply-templates>
        </matches>
    <!-- </xsl:variable> -->

    
</xsl:template>


<xsl:template match="w" mode="kwic">
    <xsl:param name="keyword" required="yes"/>

    <xsl:if test="$keyword = .">
        <match>
            <preceding><xsl:apply-templates mode="context" select="preceding-sibling::w[position() &lt; $contextSize]"/></preceding>
            <word><xsl:value-of select="."/></word>
            <following><xsl:apply-templates mode="context" select="following-sibling::w[position() &lt; $contextSize]"/></following>
        </match>
    </xsl:if>
</xsl:template>


<xsl:template mode="context" match="w">
    <xsl:value-of select="."/><xsl:text> </xsl:text>
</xsl:template>


<xsl:template name="report-usage">
    <xsl:param name="words" as="element()"/>

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


<xd:doc>
    <xd:short>Split a string into words.</xd:short>
    <xd:detail>Split a string into words, using a regular expression syntax.</xd:detail>
    <xd:param name="string">The string to be split in words.</xd:param>
</xd:doc>

<xsl:function name="f:words" as="xs:string*">
    <xsl:param name="string" as="xs:string"/>
    <xsl:analyze-string select="$string" regex="{'[\p{L}\p{N}\p{M}-]+'}">
        <xsl:matching-substring>
            <xsl:sequence select="."/>
        </xsl:matching-substring>
    </xsl:analyze-string>
</xsl:function>


<xsl:function name="f:words-and-separators" as="xs:string*">
    <xsl:param name="string" as="xs:string"/>
    <xsl:param name="lang" as="xs:string"/>

    <xsl:analyze-string select="$string" regex="{'[\p{L}\p{N}\p{M}-]+'}">
        <xsl:matching-substring>
            <xsl:value-of select="."/>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
            <xsl:sequence select="."/>
        </xsl:non-matching-substring>
    </xsl:analyze-string>
</xsl:function>


<xd:doc>
    <xd:short>Remove diacritics from a string.</xd:short>
    <xd:detail>Remove diacritics form a string to produce a string suitable for sorting purposes. This function
    use the Unicode NFD normalization form to separate diacritics from the letters carrying them, and might
    result too much being removed in some scripts (in particular Indic scripts).</xd:detail>
    <xd:param name="string">The string to processed.</xd:param>
</xd:doc>

<xsl:function name="f:strip_diacritics" as="xs:string">
    <xsl:param name="string" as="xs:string"/>
    <xsl:value-of select="fn:replace(fn:normalize-unicode($string, 'NFD'), '\p{M}', '')"/>
</xsl:function>


<xd:doc>
    <xd:short>Collect words in <code>w</code> elements.</xd:short>
    <xd:detail>Collect words in <code>w</code> elements. In this element, the normalized version is kept
    in the <code>@form</code> attribute, and the current language in the <code>@xml:lang</code> attribute.</xd:detail>
</xd:doc>

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

