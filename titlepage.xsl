<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to format a titlepage, to be imported in tei2html.xsl.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="f xd"
    version="2.0"
    >

    <xd:doc type="stylesheet">
        <xd:short>Format titlepages.</xd:short>
        <xd:detail>This stylesheet is used by tei2html and tei2epub to format the <code>titlePage</code>-element.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <!--====================================================================-->
    <!-- Title Page -->

    <xsl:template match="titlePage">
        <div>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:copy-of select="f:generate-class-attribute-with(., 'titlePage')"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>

    <xsl:template match="docTitle" mode="titlePage">
        <div>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:copy-of select="f:generate-class-attribute-with(., 'docTitle')"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>

    <xsl:template match="titlePart" mode="titlePage">
        <div>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:copy-of select="f:generate-class-attribute-with(., 'mainTitle')"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>

    <xsl:template match="titlePart[@type='sub']" mode="titlePage">
        <div>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:copy-of select="f:generate-class-attribute-with(., 'subTitle')"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>

    <xsl:template match="titlePart[@type='series' or @type='Series']" mode="titlePage">
        <div>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:copy-of select="f:generate-class-attribute-with(., 'seriesTitle')"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>

    <xsl:template match="titlePart[@type='volume' or @type='Volume']" mode="titlePage">
        <div>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:copy-of select="f:generate-class-attribute-with(., 'volumeTitle')"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>

    <xsl:template match="byline" mode="titlePage">
        <div>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:copy-of select="f:generate-class-attribute-with(., 'byline')"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>

    <xsl:template match="docAuthor" mode="titlePage">
        <span>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:copy-of select="f:generate-class-attribute-with(., 'docAuthor')"/>
            <xsl:apply-templates mode="titlePage"/>
        </span>
    </xsl:template>

    <xsl:template match="docImprint" mode="titlePage">
        <div>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:copy-of select="f:generate-class-attribute-with(., 'docImprint')"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>

    <xsl:template match="docDate" mode="titlePage">
        <span>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:copy-of select="f:generate-class-attribute-with(., 'docDate')"/>
            <xsl:apply-templates mode="titlePage"/>
        </span>
    </xsl:template>

    <xsl:template match="epigraph" mode="titlePage">
        <div>
            <!-- Wrap epigraph in extra layer for formatting -->
            <xsl:copy-of select="f:generate-class-attribute-with(., 'docImprint')"/>
            <xsl:apply-templates select="."/>
        </div>
    </xsl:template>

    <xsl:template match="figure" mode="titlePage">
        <xsl:apply-templates select="."/>
    </xsl:template>

    <xsl:template match="lb" mode="titlePage">
        <br/>
    </xsl:template>

    <xsl:template match="hi" mode="titlePage">
        <i><xsl:apply-templates mode="titlePage"/></i>
    </xsl:template>

    <xsl:template match="hi[@rend='sc']" mode="titlePage">
        <span class="sc"><xsl:apply-templates/></span>
    </xsl:template>

    <xsl:template match="hi[@rend='sup']" mode="titlePage">
        <sup><xsl:apply-templates/></sup>
    </xsl:template>

    <xsl:template match="seg" mode="titlePage">
        <span class="seg">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

</xsl:stylesheet>
