<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to format a titlepage, to be imported in tei2html.xsl.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"
    >


    <!--====================================================================-->
    <!-- Title Page -->

    <xsl:template match="titlePage">
        <div>
            <xsl:attribute name="class">titlePage <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>


    <xsl:template match="docTitle" mode="titlePage">
        <div>
            <xsl:attribute name="class">docTitle <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>

    <xsl:template match="titlePart" mode="titlePage">
        <div>
            <xsl:attribute name="class">mainTitle <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>

    <xsl:template match="titlePart[@type='sub']" mode="titlePage">
        <div>
            <xsl:attribute name="class">subTitle <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>

    <xsl:template match="titlePart[@type='series' or @type='Series']" mode="titlePage">
        <div>
            <xsl:attribute name="class">seriesTitle <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>

    <xsl:template match="titlePart[@type='volume' or @type='Volume']" mode="titlePage">
        <div>
            <xsl:attribute name="class">volumeTitle <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>


    <xsl:template match="byline" mode="titlePage">
        <div>
            <xsl:attribute name="class">byline <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>

    <xsl:template match="docAuthor" mode="titlePage">
        <span>
            <xsl:attribute name="class">docAuthor <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates mode="titlePage"/>
        </span>
    </xsl:template>


    <xsl:template match="docImprint" mode="titlePage">
        <div>
            <xsl:attribute name="class">docImprint <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>

    <xsl:template match="docDate" mode="titlePage">
        <span>
            <xsl:attribute name="class">docDate <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates mode="titlePage"/>
        </span>
    </xsl:template>


    <xsl:template match="epigraph" mode="titlePage">
        <div>
            <xsl:attribute name="class">docImprint <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
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

    <xsl:template match="hi[@rend='sup']" mode="titlePage">
        <sup><xsl:apply-templates/></sup>
    </xsl:template>

</xsl:stylesheet>
