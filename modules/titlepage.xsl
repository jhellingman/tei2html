<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="urn:stylesheet-functions"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="f xd">

    <xd:doc type="stylesheet">
        <xd:short>Format title pages.</xd:short>
        <xd:detail>This stylesheet is used by tei2html and tei2epub to format the <code>titlePage</code>-element.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xd:doc mode="titlePage">
        <xd:short>Mode used for processing elements on a title-page.</xd:short>
    </xd:doc>

    <xd:doc>
        <xd:short>Format the title page.</xd:short>
    </xd:doc>

    <xsl:template match="titlePage">
        <div>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'titlePage')"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>

    <xsl:template match="docTitle" mode="titlePage">
        <div>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'docTitle')"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>

    <xsl:template match="titlePart" mode="titlePage">
        <h1>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'mainTitle')"/>
            <xsl:apply-templates mode="titlePage"/>
        </h1>
    </xsl:template>

    <xsl:template match="titlePart[@type='sub']" mode="titlePage">
        <h1>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'subTitle')"/>
            <xsl:apply-templates mode="titlePage"/>
        </h1>
    </xsl:template>

    <xsl:template match="titlePart[@type=('series', 'Series')]" mode="titlePage">
        <h1>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'seriesTitle')"/>
            <xsl:apply-templates mode="titlePage"/>
        </h1>
    </xsl:template>

    <xsl:template match="titlePart[@type=('volume', 'Volume')]" mode="titlePage">
        <h1>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'volumeTitle')"/>
            <xsl:apply-templates mode="titlePage"/>
        </h1>
    </xsl:template>

    <xsl:template match="byline" mode="titlePage">
        <div>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'byline')"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>

    <xsl:template match="docAuthor" mode="titlePage">
        <span>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'docAuthor')"/>
            <xsl:apply-templates mode="titlePage"/>
        </span>
    </xsl:template>

    <xsl:template match="docImprint" mode="titlePage">
        <div>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'docImprint')"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>

    <xsl:template match="docDate" mode="titlePage">
        <span>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'docDate')"/>
            <xsl:apply-templates mode="titlePage"/>
        </span>
    </xsl:template>

    <xsl:template match="epigraph" mode="titlePage">
        <div>
            <!-- Wrap epigraph in extra layer for formatting -->
            <xsl:copy-of select="f:set-class-attribute-with(., 'epigraph')"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="figure" mode="titlePage">
        <xsl:apply-templates select="."/>
    </xsl:template>

    <xsl:template match="choice" mode="titlePage">
        <xsl:apply-templates select="."/>
    </xsl:template>

    <xsl:template match="lb" mode="titlePage">
        <br/>
    </xsl:template>

    <xsl:template match="seg" mode="titlePage">
        <span class="seg">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

</xsl:stylesheet>
