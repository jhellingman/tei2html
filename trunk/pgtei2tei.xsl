<!DOCTYPE xsl:stylesheet [

    <!ENTITY tab        "&#x09;">
    <!ENTITY lf         "&#x0A;">
    <!ENTITY cr         "&#x0D;">
    <!ENTITY deg        "&#176;">
    <!ENTITY ldquo      "&#x201C;">
    <!ENTITY lsquo      "&#x2018;">
    <!ENTITY rdquo      "&#x201D;">
    <!ENTITY rsquo      "&#x2019;">
    <!ENTITY nbsp       "&#160;">
    <!ENTITY mdash      "&#x2014;">
    <!ENTITY prime      "&#x2032;">
    <!ENTITY Prime      "&#x2033;">
    <!ENTITY plusmn     "&#x00B1;">
    <!ENTITY frac14     "&#x00BC;">
    <!ENTITY frac12     "&#x00BD;">
    <!ENTITY frac34     "&#x00BE;">

]>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="xd"
    version="2.0">

    <xd:doc type="stylesheet">
        <xd:short>TEI stylesheet to convert a TEI document with unnumberd div elements to numbered div elements.</xd:short>
        <xd:detail> </xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Replace a div element with a numbered div element, based on its nesting depth.</xd:short>
        <xd:detail> Preconditions:
        document does not mix numbered and unnumbered div elements.
        document does not use nested documents (in q elements), restarting the counting.</xd:detail>
    </xd:doc>

    <xsl:template match="div">
        <xsl:variable name="depth" select="count(ancestor::div) + 1"/>
        <xsl:element name="{concat('div', $depth)}">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>


    <xd:doc>
        <xd:short>Rewrite the @rend attributes in rendering ladder syntax.</xd:short>
        <xd:detail>Source format: "property: value;" Target format: "property(value)"</xd:detail>
    </xd:doc>

    <xsl:template match="@rend">
        <xsl:attribute name="rend"><xsl:value-of select="replace(., '([a-z-][a-z0-9-])\s*:\s*([^;]*);?', '$1($2)')"/></xsl:attribute>
    </xsl:template>

    <xsl:template match="@rend[.='smallcaps']">
        <xsl:attribute name="rend">sc</xsl:attribute>
    </xsl:template>


    <xsl:template match="hi[@rend='italic'] | emph[@rend='italic'] | emph[not(@rend)]">
        <hi>
            <xsl:apply-templates/>
        </hi>
    </xsl:template>


    <xd:doc>
        <xd:short>Join the pb element with the following anchor element, taking the id of the latter.</xd:short>
        <xd:detail> </xd:detail>
    </xd:doc>

    <xsl:template match="pb[following-sibling::*[1]/self::anchor]">
        <pb>
            <xsl:attribute name="id">
                <xsl:value-of select="following-sibling::*[1]/self::anchor/@id"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*"/>
        </pb>
    </xsl:template>

    <xsl:template match="anchor[preceding-sibling::*[1]/self::pb]"/>


    <xd:doc>
        <xd:short>Supply omitted quotation marks.</xd:short>
        <xd:detail>TODO: needs more fine-control to supply them conditionally in case of quotations that stretch over multiple paragraphs.</xd:detail>
    </xd:doc>

    <xsl:template match="q">
        <xsl:variable name="n" select="count(ancestor::q) mod 2 + 1"/>
        <xsl:value-of select="substring('&ldquo;&lsquo;', $n, 1)"/>
        <xsl:apply-templates/>
        <xsl:value-of select="substring('&rdquo;&rsquo;', $n, 1)"/>
    </xsl:template>


    <!-- Cleanup DTD artifacts -->
    <xsl:template match="@TEIform"/>


    <!-- Copy templates -->
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*|processing-instruction()|comment()">
        <xsl:copy/>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:value-of select="."/> <!-- could normalize() here -->
    </xsl:template>


</xsl:stylesheet>
