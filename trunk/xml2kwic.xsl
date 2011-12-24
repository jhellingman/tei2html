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
<xsl:param name="contextSize" select="15"/>

<xsl:template match="/">
    <head>

    <style>

        .tag
        {
            font-size: xx-small;
            color: grey;
        }

        .pre
        {
            text-align: right;
        }

        .match
        {
            font-weight: bold;
        }

    </style>

    </head>
    <html>
        <h1>KWIC</h1>

        <xsl:call-template name="build-kwic"/>
    </html>
</xsl:template>


<xsl:template name="build-kwic">

    <!-- Collect all words with their language in a variable -->
    <xsl:variable name="words">
        <words>
            <xsl:apply-templates mode="words"/>
        </words>
    </xsl:variable>

    <!--
    <xsl:call-template name="report-matches">
        <xsl:with-param name="words" select="$words"/>
        <xsl:with-param name="keyword" select="$keyword"/>
    </xsl:call-template>
    -->

    <xsl:for-each-group select="$words/words/w" group-by="@form">
        <xsl:sort select="(current-group()[1])/@form" order="ascending"/>

        <xsl:if test="fn:matches(@form, '^[\p{L}-]+$')">

            <xsl:variable name="keyword" select="(current-group()[1])/@form"/>
            <h2><xsl:value-of select="$keyword"/></h2>

            <xsl:call-template name="report-matches">
                <xsl:with-param name="words" select="$words"/>
                <xsl:with-param name="keyword" select="$keyword"/>
            </xsl:call-template>

        </xsl:if>
    </xsl:for-each-group>

</xsl:template>



<xsl:template name="report-matches">
    <xsl:param name="words"/>
    <xsl:param name="keyword"/>

    <xsl:variable name="matches">
        <matches>
            <xsl:apply-templates mode="kwic" select="$words/words/w">
                <xsl:with-param name="keyword" select="$keyword"/>
            </xsl:apply-templates>
        </matches>
    </xsl:variable>

    <!-- <xsl:copy-of select="$matches"/> -->

    <xsl:apply-templates mode="output" select="$matches"/>


</xsl:template>






<xsl:template mode="output" match="matches">
    <table>
        <xsl:apply-templates mode="output">
            <xsl:sort select="fn:lower-case(f:strip_diacritics(following))" order="ascending"/>
        </xsl:apply-templates>
    </table>
</xsl:template>

<xsl:template mode="output" match="match">
    <tr>
        <td class="pre">
            <xsl:apply-templates mode="output" select="preceding"/>
        </td>
        <td class="match">
            <xsl:apply-templates mode="output" select="word"/>
        </td>
        <td class="post">
            <xsl:apply-templates mode="output" select="following"/>
        </td>
        <td>
            <xsl:value-of select="word/w/@page"/>
        </td>
    </tr>
</xsl:template>


<xsl:template mode="output" match="w">
    <xsl:value-of select="."/>
</xsl:template>

<xsl:template mode="output" match="nw">
    <xsl:value-of select="."/>
</xsl:template>

<xsl:template mode="output" match="t">
    <span class="tag"><xsl:value-of select="@name"/></span>
</xsl:template>


<xsl:template mode="kwic" match="w">
    <xsl:param name="keyword" required="yes"/>

    <xsl:if test="$keyword = @form">
        <match>
            <preceding><xsl:apply-templates mode="context" select="preceding-sibling::*[position() &lt; $contextSize]"/></preceding>
            <word><xsl:apply-templates mode="context" select="."/></word>
            <following><xsl:apply-templates mode="context" select="following-sibling::*[position() &lt; $contextSize]"/></following>
        </match>
    </xsl:if>
</xsl:template>


<xsl:template mode="words" match="p">
    <t name="&#182;"/>
    <xsl:apply-templates mode="words"/>
</xsl:template>

<xsl:template mode="words" match="pb | hi | index">
    <xsl:apply-templates mode="words"/>
</xsl:template>

<xsl:template mode="words" match="*">
    <xsl:choose>
        <xsl:when test="normalize-space(.) = ''">
            <t name="&lt;{name()}/&gt;"/>
        </xsl:when>
        <xsl:otherwise>
            <t name="&lt;{name()}&gt;"/>
            <xsl:apply-templates mode="words"/>
            <t name="&lt;/{name()}&gt;"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>




<xsl:template mode="context" match="w|nw|t">
    <xsl:copy-of select="."/>
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
    <xsl:variable name="parent" select="name(ancestor-or-self::*[1])"/>
    <xsl:variable name="page" select="preceding::pb[1]/@n"/>

    <xsl:analyze-string select="." regex="{'[\p{L}\p{N}\p{M}-]+'}">
        <xsl:matching-substring>
            <w>
                <xsl:attribute name="xml:lang" select="$lang"/>
                <xsl:attribute name="parent" select="$parent"/>
                <xsl:attribute name="page" select="$page"/>
                <xsl:attribute name="form" select="fn:lower-case(f:strip_diacritics(.))"/>
                <xsl:value-of select="."/>
            </w>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
            <nw>
                <xsl:value-of select="."/>
            </nw>
        </xsl:non-matching-substring>
    </xsl:analyze-string>
</xsl:template>


</xsl:stylesheet>

