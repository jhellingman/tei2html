<!DOCTYPE xsl:stylesheet [

    <!ENTITY tab        "&#x09;">
    <!ENTITY lf         "&#x0A;">
    <!ENTITY cr         "&#x0D;">
    <!ENTITY deg        "&#176;">
    <!ENTITY ldquo      "&#x201C;">
    <!ENTITY nbsp       "&#160;">
    <!ENTITY mdash      "&#x2014;">
    <!ENTITY prime      "&#x2032;">
    <!ENTITY Prime      "&#x2033;">
    <!ENTITY plusmn     "&#x00B1;">
    <!ENTITY frac14     "&#x00BC;">
    <!ENTITY frac12     "&#x00BD;">
    <!ENTITY frac34     "&#x00BE;">

]>
<!--

    Stylesheet to format inline elements, to be imported in tei2html.xsl.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"
    >

    <!--====================================================================-->
    <!-- Poetry -->

    <!-- top-level gets class=lgouter, nested get class=lg. This we use to 
         center the entire poem on the screen, and still keep the left side 
         of all stanzas aligned. -->
    <xsl:template match="lg">
        <xsl:call-template name="closepar"/>
        <div>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:attribute name="class">
                <xsl:if test="not(parent::lg) and not(parent::sp)">lgouter<xsl:text> </xsl:text></xsl:if>
                <xsl:if test="parent::lg or parent::sp">lg<xsl:text> </xsl:text></xsl:if>
                <xsl:if test="ancestor::note[@place='foot' or @place='undefined' or not(@place)]">footnote<xsl:text> </xsl:text></xsl:if>
                <xsl:call-template name="generate-rend-class-name-if-needed"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </div>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>

    <xsl:template match="lg/head">
        <h4>
            <xsl:call-template name="generate-rend-class-attribute-if-needed"/>
            <xsl:apply-templates/>
        </h4>
    </xsl:template>

    <xsl:template match="l">
        <p>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:attribute name="class">line <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>

            <xsl:if test="@n">
                <span class="linenum"><xsl:value-of select="@n"/></span>
            </xsl:if>

            <xsl:if test="contains(@rend, 'hemistich(')">
                <span class="hemistich">
                    <xsl:value-of select="substring-before(substring-after(@rend, 'hemistich('), ')')"/>
                    <xsl:text> </xsl:text>
                </span>
            </xsl:if>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- linebreaks specific to an edition are not represented in the output -->
    <xsl:template match="lb[@ed]">
        <a>
            <xsl:call-template name="generate-id-attribute"/>
        </a>
    </xsl:template>

    <!-- linebreaks not linked to a specific edition are to be output -->
    <xsl:template match="lb">
        <br>
            <xsl:call-template name="generate-id-attribute"/>
        </br>
    </xsl:template>


    <!--====================================================================-->
    <!-- Drama -->

    <xsl:template match="sp">
        <div>
            <xsl:attribute name="class">sp <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- Speaker -->
    <xsl:template match="speaker">
        <p>
            <xsl:attribute name="class">speaker <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- Stage directions -->
    <xsl:template match="stage">
        <p>
            <xsl:attribute name="class">stage <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="stage[@type='exit']">
        <p>
            <xsl:attribute name="class">stage alignright <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="stage[@rend='inline' or contains(@rend, 'position(inline)')]">
        <span>
            <xsl:attribute name="class">stage <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- Cast lists -->
    <xsl:template match="castList">
        <ul>
            <xsl:attribute name="class">castlist <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </ul>
    </xsl:template>

    <xsl:template match="castList/head">
        <li>
            <xsl:attribute name="class">castlist <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="set-lang-id-attributes"/>
            <h4><xsl:apply-templates/></h4>
        </li>
    </xsl:template>

    <xsl:template match="castGroup">
        <li>
            <xsl:attribute name="class">castlist <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates select="head"/>
            <ul class="castGroup">
                <xsl:apply-templates select="castItem"/>
            </ul>
        </li>
    </xsl:template>

    <xsl:template match="castGroup/head">
        <b>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </b>
    </xsl:template>

    <xsl:template match="castItem">
        <li class="castitem">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

</xsl:stylesheet>
