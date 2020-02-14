<!DOCTYPE stylesheet [
<!ENTITY nbsp  "&#160;" >
<!ENTITY cr    "&#x0d;" >
<!ENTITY lf    "&#x0a;" >
]>

<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:f="urn:stylesheet-functions"
    xmlns:tmp="urn:temporary-items"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="f fn xd xs tmp">

<!--
  <xsl:output 
    method="text"
    indent="no"/>
-->

<!-- tei2txt.xslt - stylesheet to convert TEI files to plain text format -->

<xsl:param name="lineWidth" select="72"/>
<xsl:param name="italicStart" select="_"/>
<xsl:param name="italicEnd" select="_"/>


<xsl:template match="text">
    <xsl:apply-templates select="." mode="text"/>

    <xsl:value-of select="f:underline('NOTES')"/>
    <xsl:apply-templates select="." mode="notes"/>
</xsl:template>


<xsl:template match="lb" mode="text">
    <xsl:text>&lf;</xsl:text>
</xsl:template>





<!-- MODE: text -->

<xsl:template mode="text" match="div0 | div1">
    <xsl:value-of select="f:repeat('&lf;', 5)"/>
    <xsl:apply-templates mode="text"/>
</xsl:template>

<xsl:template mode="text" match="div2 | div3 | div4 | div5">
    <xsl:value-of select="f:repeat('&lf;', 3)"/>
    <xsl:apply-templates mode="text"/>
</xsl:template>

<xsl:template mode="text" match="table">
    <xsl:apply-templates mode="text"/>
</xsl:template>

<xsl:template mode="text" match="row">
    <xsl:text>&lf;</xsl:text>
    <xsl:apply-templates mode="text"/>
</xsl:template>

<xsl:template mode="text" match="cell">
    <xsl:apply-templates mode="text"/>
    <xsl:text> </xsl:text>
</xsl:template>

<xsl:template mode="text" match="lg">
    <xsl:text>&lf;</xsl:text>
    <xsl:apply-templates mode="text"/>
    <xsl:text>&lf;</xsl:text>
</xsl:template>






<xsl:template mode="text" match="head">
    <xsl:variable name="head">
        <xsl:apply-templates mode="text"/>
    </xsl:variable>

    <!-- Assume heads fit on a single line (certainly not always valid!) -->

    <xsl:value-of select="f:underline($head)"/>
</xsl:template>






<xsl:template mode="text" match="hi">
    <xsl:value-of select="$italicStart"/>
    <xsl:apply-templates mode="text"/>
    <xsl:value-of select="$italicEnd"/>
</xsl:template>






<xsl:template match="p">
    <xsl:variable name="text">
        <xsl:apply-templates/>
    </xsl:variable>
    <xsl:copy-of select="f:break-into-lines($text, $lineWidth)"/>
</xsl:template>


<xsl:template match="note">
    <xsl:text>[</xsl:text>
    <xsl:number count="note" level="any"/>
    <!-- <xsl:value-of select="@n"/> -->
    <xsl:text>]</xsl:text>
</xsl:template>

<xsl:template match="choice/corr">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="choice/sic"/>


<!-- FUNCTIONS -->


<xsl:function name="f:underline">
    <xsl:param name="string" as="xs:string"/>

    <xsl:value-of select="f:underline($string, '-')"/>
</xsl:function>

<xsl:function name="f:underline">
    <xsl:param name="string" as="xs:string"/>
    <xsl:param name="with" as="xs:string"/>

    <xsl:value-of select="$string"/>
    <xsl:text>&lf;</xsl:text>
    <xsl:value-of select="f:repeat($with, string-length($string))"/>
    <xsl:text>&lf;</xsl:text>
</xsl:function>


<xsl:function name="f:spaces">
    <xsl:param name="count" as="xs:integer"/>

    <xsl:value-of select="f:repeat(' ', $count)"/>
</xsl:function>


<xsl:function name="f:repeat">
    <xsl:param name="character" as="xs:string"/>
    <xsl:param name="count" as="xs:integer"/>

    <xsl:if test="$count &gt; 0">
        <xsl:value-of select="$character"/>
        <xsl:value-of select="f:repeat($character, $count - 1)"/>
    </xsl:if>
</xsl:function>



<xsl:function name="f:break-into-lines" as="element(line)*">
    <xsl:param name="text" as="xs:string"/>
    <xsl:param name="max-width" as="xs:integer"/>

    <!-- break string up in words and spaces -->
    <xsl:variable name="words">
        <xsl:analyze-string select="$text" regex="\s">
            <xsl:matching-substring>
                <tmp:space text="{.}" width="{f:unicode-character-count(.)}"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <tmp:word text="{.}" width="{f:unicode-character-count(.)}"/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:variable>

    <!-- greedily output words and spaces as long as they fit -->
    <xsl:iterate select="$words/*">
        <xsl:param name="text" select="''" as="xs:string"/>
        <xsl:param name="width" select="0" as="xs:integer"/>

        <xsl:on-completion>
            <line><xsl:value-of select="$text"/></line>
        </xsl:on-completion> 

        <xsl:variable name="pos" select="position()"/>

        <xsl:if test="f:word-wrap-break($words, $width, $pos, $max-width)">
            <line><xsl:value-of select="$text"/></line>
        </xsl:if>

        <xsl:variable name="newWidth" select="if (f:word-wrap-break($words, $width, $pos, $max-width))
            then 0
            else xs:integer($width + @width)" as="xs:integer"/>

        <xsl:variable name="newText" select="if (f:word-wrap-break($words, $width, $pos, $max-width))
            then ''
            else $text || @text" as="xs:string"/>

        <xsl:next-iteration>
            <xsl:with-param name="text" select="$newText"/>
            <xsl:with-param name="width" select="$newWidth"/>
        </xsl:next-iteration>
    </xsl:iterate>
</xsl:function>




<xsl:function name="f:word-wrap" as="xs:string">
    <xsl:param name="text" as="xs:string"/>
    <xsl:param name="max-width" as="xs:integer"/>

    <!-- break string up in words and spaces -->
    <xsl:variable name="words">
        <xsl:analyze-string select="$text" regex="\s">
            <xsl:matching-substring>
                <tmp:space text="{.}" width="{f:unicode-character-count(.)}"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <tmp:word text="{.}" width="{f:unicode-character-count(.)}"/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:variable>

    <!-- greedily output words and spaces as long as they fit -->
    <xsl:iterate select="$words/*">
        <xsl:param name="text" select="''" as="xs:string"/>
        <xsl:param name="width" select="0" as="xs:integer"/>

        <xsl:on-completion>
            <xsl:sequence select="$text"/>
        </xsl:on-completion> 

        <xsl:variable name="pos" select="position()"/>

        <xsl:variable name="newWidth" select="if (f:word-wrap-break($words, $width, $pos, $max-width))
            then 0
            else xs:integer($width + @width)" as="xs:integer"/>

        <xsl:variable name="newText" select="if (f:word-wrap-break($words, $width, $pos, $max-width))
            then $text || '&#x0a;'
            else $text || @text" as="xs:string"/>

        <xsl:next-iteration>
            <xsl:with-param name="text" select="$newText"/>
            <xsl:with-param name="width" select="$newWidth"/>
        </xsl:next-iteration>
    </xsl:iterate>
</xsl:function>

<xsl:function name="f:word-wrap-break" as="xs:boolean">
    <xsl:param name="words"/>
    <xsl:param name="width" as="xs:integer"/>
    <xsl:param name="pos" as="xs:integer"/>
    <xsl:param name="max-width" as="xs:integer"/>

    <xsl:sequence select="$width > 0 
        and local-name($words/*[$pos]) = 'space'
        and $words/*[$pos + 1]
        and $width + $words/*[$pos]/@width + $words/*[$pos + 1]/@width > $max-width"/>
</xsl:function>

<xsl:function name="f:unicode-character-count" as="xs:integer">
    <xsl:param name="string" as="xs:string"/>
    <xsl:sequence select="string-length(f:strip-diacritics($string))"/>
</xsl:function>

<xsl:function name="f:strip-diacritics" as="xs:string">
    <xsl:param name="string" as="xs:string"/>
    <xsl:sequence select="replace(normalize-unicode($string, 'NFD'), '\p{M}', '')"/>
</xsl:function>






<xsl:function name="f:head" as="xs:string">
    <xsl:param name="text" as="xs:string"/>

    <xsl:variable name="head" select="substring-before($text, ' ')"/>

    <xsl:value-of select="$head"/>
</xsl:function>





</xsl:stylesheet>
