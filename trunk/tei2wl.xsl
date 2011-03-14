<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    >

<!-- Stylesheet to produce a word frequency list from any XML document -->

<xsl:output omit-xml-declaration="yes" indent="yes"/>


<xsl:template match="/">

    <!-- Collect all words with language in a variable -->
    <xsl:variable name="words">
        <xsl:apply-templates mode="words"/>
    </xsl:variable>

    <!-- TODO: group by language first -->
    <words>
        <xsl:for-each-group select="$words/w" group-by=".">
            <xsl:sort select="lower-case(current-group()[1])" order="ascending"/>
            <w>
                <xsl:attribute name="count">
                    <xsl:value-of select="count(current-group())"/>
                </xsl:attribute>
                <xsl:value-of select="current-group()[1]"/>
            </w>
        </xsl:for-each-group>
    </words>

    <!-- <xsl:copy-of select="$words"/> -->

</xsl:template>


<xsl:template mode="words" match="text()">
    <xsl:variable name="lang" select="(ancestor-or-self::*/@lang)[last()]"/>

    <xsl:for-each select="tokenize(., '[^\w]+')">
        <w>
            <xsl:attribute name="xml:lang" select="$lang"/>
            <xsl:value-of select="."/>
        </w>
    </xsl:for-each>
</xsl:template>




</xsl:stylesheet>
