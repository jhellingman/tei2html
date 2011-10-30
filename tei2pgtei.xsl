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
        <xd:short>TEI stylesheet to convert a TEI document with numberd div elements to unnumbered div elements.</xd:short>
        <xd:detail> </xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Replace a numbered div element with an unnumbered div element.</xd:short>
        <xd:detail> </xd:detail>
    </xd:doc>

    <xsl:template match="div0|div1|div2|div3|div4|div5|div6">
        <div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <xd:doc>
        <xd:short>Rewrite the @rend attributes in CSS syntax.</xd:short>
        <xd:detail>Source format: "property(value)" Target format: "property: value;" (TODO: handle special exceptions)</xd:detail>
    </xd:doc>

    <xsl:template match="@rend">
        <xsl:attribute name="rend"><xsl:value-of select="replace(., '([a-z-][a-z0-9-])\(([^;]*)\)', '$1: $2;')"/></xsl:attribute>
    </xsl:template>

    <xsl:template match="@rend[.='sc']">
        <xsl:attribute name="rend">smallcaps</xsl:attribute>
    </xsl:template>

    <xsl:template match="hi[not(@rend)]">
        <hi rend="italic">
            <xsl:apply-templates/>
        </hi>
    </xsl:template>


    <xd:doc>
        <xd:short>Add an anchor element after each pb element. Give the anchor the id of the pd.</xd:short>
        <xd:detail> </xd:detail>
    </xd:doc>

    <xsl:template match="pb">
        <pb>
            <xsl:if test="@n">
                <xsl:attribute name="n">
                    <xsl:value-of select="@n"/>
                </xsl:attribute>
            </xsl:if>
        </pb>
        <xsl:if test="@id">
            <anchor>
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </anchor>
        </xsl:if>
    </xsl:template>


    <xsl:template match="q[@rend='block']">
        <quote rend='display'>
            <xsl:apply-templates/>
        </quote>
    </xsl:template>


    <xd:doc>
        <xd:short>Rename the relevant idno for Project Gutenberg.</xd:short>
        <xd:detail> </xd:detail>
    </xd:doc>

    <xsl:template match="idno[@type='PGnum']">
        <idno type='etext-no'>
            <xsl:apply-templates/>
        </idno>
    </xsl:template>


    <!-- FURTHER MODIFY FROM HERE -->

    <xd:doc>
        <xd:short>Adjust the divGen types to generate headings.</xd:short>
        <xd:detail> </xd:detail>
    </xd:doc>

    <xsl:template match="divGen[@type='toc']">
        <divGen type="tocBody">
            <xsl:apply-templates select="@*[name() != 'type']"/>
        </divGen>
    </xsl:template>

    <xsl:template match="divGen[@type='Footnotes' or @type='footnotes']">
        <divGen type="footnotesBody">
            <xsl:apply-templates select="@*[name() != 'type']"/>
        </divGen>
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
