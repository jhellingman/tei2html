<!DOCTYPE stylesheet [
<!ENTITY nbsp  "&#160;" >
<!ENTITY lf    "&#x0a;" >
]>


<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="f fn xd xs"
    >

  <xsl:output 
    method="text"
    indent="no"/>


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


<xsl:template mode="text" match="l">
    <xsl:variable name="line">
        <xsl:apply-templates mode="text"/>
    </xsl:variable>

    <xsl:variable name="indent" select="4"/>

    <xsl:variable name="lines">
        <xsl:apply-templates select="f:lines($line, $lineWidth - $indent)"/>
    </xsl:variable>

    <xsl:for-each select="$lines">
        <!--<xsl:text>&lf;</xsl:text>-->
        <xsl:value-of select="f:spaces($indent)"/>
        <xsl:value-of select="."/>
    </xsl:for-each>
</xsl:template>



<xsl:template mode="text" match="head">
    <xsl:variable name="head">
        <xsl:apply-templates mode="text"/>
    </xsl:variable>

    <!-- Assume heads fit on a single line (certainly not always valid!) -->

    <xsl:value-of select="f:underline($head)"/>
</xsl:template>








<xsl:template mode="text" match="p">
    <xsl:call-template name="wordwrap"/>
</xsl:template>



<xsl:template name="wordwrap">
    <xsl:variable name="text">
        <xsl:apply-templates mode="text"/>
    </xsl:variable>

    <xsl:text>&lf;</xsl:text>
    <xsl:apply-templates select="f:wordwrap2($text, $lineWidth)"/>
</xsl:template>




<xsl:template mode="text" match="hi">
    <xsl:value-of select="$italicStart"/>
    <xsl:apply-templates mode="text"/>
    <xsl:value-of select="$italicEnd"/>
</xsl:template>


<xsl:template mode="text" match="note">
    <xsl:text> [</xsl:text>
    <xsl:number count="note" level="any"/>
    <!-- <xsl:value-of select="@n"/> -->
    <xsl:text>] </xsl:text>
</xsl:template>


<!-- MODE: notes -->

<xsl:template mode="notes" match="note">
    <xsl:text>&lf;[Footnote </xsl:text>
    <xsl:number count="note" level="any"/>
    <!-- <xsl:value-of select="@n"/> -->
    <xsl:text>: </xsl:text>

    <xsl:choose>
        <xsl:when test="p">
            <xsl:apply-templates mode="text"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="wordwrap"/>
        </xsl:otherwise>
    </xsl:choose>

    <xsl:text>]&lf;</xsl:text>
</xsl:template>



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


<xsl:function name="f:lines">
    <xsl:param name="paragraph" as="xs:string"/>
    <xsl:param name="width" as="xs:integer"/>

    <!-- Insert <lb> milestone tags -->
    <xsl:variable name="result" select="f:wordwrap2($paragraph, $width)"/>

    <!-- wrap each line in a <line> tag -->
    <xsl:for-each-group select="$result" group-ending-with="lb">
      <line>
      <xsl:for-each select="current-group()">
        <xsl:copy>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:for-each>
      </line>
    </xsl:for-each-group>
</xsl:function>


<xsl:function name="f:wordwrap" as="node()*">
    <xsl:param name="text" as="xs:string"/>
    <xsl:param name="width" as="xs:integer"/>

    <xsl:value-of select="f:wordwrap($text, $width, 0)"/>
</xsl:function>


<xsl:function name="f:wordwrap" as="node()*">
    <xsl:param name="text" as="xs:string"/>
    <xsl:param name="width" as="xs:integer"/>
    <xsl:param name="used" as="xs:integer"/>

    <xsl:variable name="word" select="substring-before($text, ' ')"/>
    <xsl:variable name="length" select="string-length($word) + (if ($used = 0) then 0 else 1)"/>

    <xsl:choose>
        <!-- Paragraph ended, output final <lb> -->
        <xsl:when test="string-length($text) = 0">
            <xsl:text>&lf;</xsl:text>
        </xsl:when>
        <!-- Word is longer than line width, put on its own line, tolerate it sticking out -->
        <xsl:when test="$length &gt; $width">
            <xsl:if test="$used != 0"><xsl:text>&lf;</xsl:text></xsl:if>
            <xsl:value-of select="$word"/>
            <xsl:text>&lf;</xsl:text>
            <xsl:value-of select="f:wordwrap(substring-after($text, ' '), $width, $used + $length)"/>
        </xsl:when>
        <!-- Word doesn't fit on line-so-far; start a new one -->
        <xsl:when test="$used + $length &gt; $width">
            <xsl:text>&lf;</xsl:text>
            <xsl:value-of select="f:wordwrap($text, $width, 0)"/>
        </xsl:when>
        <!-- Word fits on line-so-far -->
        <xsl:otherwise>
            <xsl:if test="$used != 0"><xsl:text> </xsl:text></xsl:if>
            <xsl:value-of select="$word"/>
            <xsl:value-of select="f:wordwrap(substring-after($text, ' '), $width, $used + $length)"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:function>


<xsl:function name="f:head" as="xs:string">
    <xsl:param name="text" as="xs:string"/>

    <xsl:variable name="head" select="substring-before($text, ' ')"/>

    <xsl:value-of select="$head"/>
</xsl:function>



<xsl:function name="f:wordwrap2" as="node()*">
    <xsl:param name="text" as="xs:string"/>
    <xsl:param name="maxwidth" as="xs:integer"/>

    <xsl:value-of select="f:wordwrap2(tokenize($text, ' '), $maxwidth, 0)"/>
</xsl:function>



<xsl:function name="f:wordwrap2" as="node()*">
    <xsl:param name="words" as="xs:string*"/>
    <xsl:param name="maxwidth" as="xs:integer"/>
    <xsl:param name="used" as="xs:integer"/>

    <xsl:variable name="word" select="$words[1]"/>
    <xsl:variable name="tail" select="$words[position() &gt; 1]"/>
    <xsl:variable name="length" select="string-length($word) + (if ($used = 0) then 0 else 1)"/>

    <xsl:choose>
        <!-- Paragraph ended, output final <lb> -->
        <xsl:when test="not($word)">
            <xsl:text>&lf;</xsl:text>
        </xsl:when>
        <!-- Word is longer than line width, put on its own line, tolerate it sticking out -->
        <xsl:when test="$length &gt; $maxwidth">
            <xsl:if test="$used != 0"><xsl:text>&lf;</xsl:text></xsl:if>
            <xsl:value-of select="$word"/>
            <xsl:text>&lf;</xsl:text>
            <xsl:value-of select="f:wordwrap2($tail, $maxwidth, $used + $length)"/>
        </xsl:when>
        <!-- Word doesn't fit on line-so-far; start a new one -->
        <xsl:when test="$used + $length &gt; $maxwidth">
            <xsl:text>&lf;</xsl:text>
            <xsl:value-of select="f:wordwrap2($words, $maxwidth, 0)"/>
        </xsl:when>
        <!-- Word fits on line-so-far -->
        <xsl:otherwise>
            <xsl:if test="$used != 0"><xsl:text> </xsl:text></xsl:if>
            <xsl:value-of select="$word"/>
            <xsl:value-of select="f:wordwrap2($tail, $maxwidth, $used + $length)"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:function>




</xsl:stylesheet>
