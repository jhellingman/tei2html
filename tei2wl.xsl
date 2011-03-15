<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    >

<!-- Stylesheet to produce a word frequency list from any XML document -->

<xsl:output omit-xml-declaration="yes" indent="yes"/>


<xsl:template match="/">

    <!-- Collect all words with their language in a variable -->
    <xsl:variable name="words">
        <xsl:apply-templates mode="words"/>
    </xsl:variable>

    <usage>
        <xsl:for-each-group select="$words/w" group-by="@xml:lang">
            <words xml:lang="{(current-group()[1])/@xml:lang}">
                <xsl:for-each-group select="current-group()" group-by=".">
                    <xsl:sort select="lower-case(current-group()[1])" order="ascending"/>
                    <word count="{count(current-group())}">
                        <xsl:value-of select="current-group()[1]"/>
                    </word>
                </xsl:for-each-group>
            </words>
        </xsl:for-each-group>
    </usage>

</xsl:template>


<xsl:template mode="words" match="text()">
    <xsl:variable name="lang" select="(ancestor-or-self::*/@lang)[last()]"/>

    <xsl:for-each select="tokenize(., '[^\w]+')">
        <xsl:if test=". != ''">
            <w>
                <xsl:attribute name="xml:lang" select="$lang"/>
                <xsl:value-of select="."/>
            </w>
        </xsl:if>
    </xsl:for-each>
</xsl:template>




</xsl:stylesheet>
