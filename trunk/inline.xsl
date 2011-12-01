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

    Requires: 
        localization.xsl    : templates for localizing strings.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:f="urn:stylesheet-functions"
    exclude-result-prefixes="f"
    version="2.0"
    >


    <!--====================================================================-->
    <!-- Text styles -->

    <xsl:template match="emph">
        <i><xsl:call-template name="set-lang-id-attributes"/><xsl:apply-templates/></i>
    </xsl:template>


    <!-- Mapped to HTML elements: it = italic; b = bold; sup = superscrip; sub = subscript -->
    <xsl:template match="hi[@rend='it' or @rend='italic']">
        <i><xsl:call-template name="set-lang-id-attributes"/><xsl:apply-templates/></i>
    </xsl:template>

    <xsl:template match="hi[@rend='b' or @rend='bold']">
        <b><xsl:call-template name="set-lang-id-attributes"/><xsl:apply-templates/></b>
    </xsl:template>

    <xsl:template match="hi[@rend='sup']">
        <sup><xsl:apply-templates/></sup>
    </xsl:template>

    <xsl:template match="hi[@rend='sub']">
        <sub><xsl:apply-templates/></sub>
    </xsl:template>

    <!-- Mapped to defined CSS classes: sc = small caps; uc = upper case; ex = letterspaced; rm = roman -->
    <xsl:template match="hi[@rend='sc']">
        <span class="sc"><xsl:call-template name="set-lang-id-attributes"/><xsl:apply-templates/></span>
    </xsl:template>

    <xsl:template match="hi[@rend='uc']">
        <span class="uc"><xsl:call-template name="set-lang-id-attributes"/><xsl:apply-templates/></span>
    </xsl:template>

    <xsl:template match="hi[@rend='ex']">
        <span class="ex"><xsl:call-template name="set-lang-id-attributes"/><xsl:apply-templates/></span>
    </xsl:template>

    <xsl:template match="hi[@rend='rm']">
        <span class="rm"><xsl:call-template name="set-lang-id-attributes"/><xsl:apply-templates/></span>
    </xsl:template>

    <xsl:template match="hi[@rend='overline']">
        <span class="overline"><xsl:apply-templates/></span>
    </xsl:template>

    <xsl:template match="hi[@rend='overtilde']">
        <span class="overtilde"><xsl:apply-templates/></span>
    </xsl:template>

    <xsl:template match="hi">
        <xsl:choose>
            <xsl:when test="contains(@rend, '(')">
                <span>
                    <xsl:call-template name="set-lang-id-attributes"/>
                    <!-- Actual style is put in stylesheet, rendered in CSS mode -->
                    <xsl:call-template name="generate-rend-class-attribute-if-needed"/>
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <i>
                    <xsl:call-template name="set-lang-id-attributes"/>
                    <xsl:apply-templates/>
                </i>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- Use other font for Greek passages -->
    <xsl:template match="foreign[@lang='el' or @lang='grc']">
        <span class="Greek"><xsl:call-template name="set-lang-id-attributes"/><xsl:apply-templates/></span>
    </xsl:template>

    <!-- Use other font for Arabic passages -->
    <xsl:template match="foreign[@lang='ar']">
        <span class="Arabic"><xsl:call-template name="set-lang-id-attributes"/><xsl:apply-templates/></span>
    </xsl:template>

    <!-- Foreign phrases are not styled by default, but we do set the language on them -->
    <xsl:template match="foreign">
        <span><xsl:call-template name="set-lang-id-attributes"/><xsl:apply-templates/></span>
    </xsl:template>


    <!--====================================================================-->
    <!-- Anchors -->


    <xsl:template match="anchor">
        <a><xsl:call-template name="generate-id-attribute"/><xsl:apply-templates/></a>
    </xsl:template>


    <!--====================================================================-->
    <!-- Corrections -->

    <xsl:template match="corr">
        <xsl:call-template name="do-corr"/>
    </xsl:template>

    <xsl:template match="corr" mode="titlePage">
        <xsl:call-template name="do-corr"/>
    </xsl:template>

    <xsl:template name="do-corr">
        <xsl:choose>
            <xsl:when test="@resp = 'm' or @resp = 'p'">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not(@sic) or @sic=''">
                <span class="corr">
                    <xsl:call-template name="generate-id-attribute"/>
                    <xsl:attribute name="title">
                        <xsl:value-of select="f:message('msgNotInSource')"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test=". = ''">
                <a>
                    <xsl:call-template name="generate-id-attribute"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <span class="corr">
                    <xsl:call-template name="generate-id-attribute"/>
                    <xsl:attribute name="title">
                        <xsl:value-of select="f:message('msgSource')"/><xsl:text>: </xsl:text><xsl:value-of select="@sic"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--====================================================================-->
    <!-- Gaps -->

    <xsl:template match="gap">
        <xsl:variable name="params">
            <params>
                <param name="extent"><xsl:value-of select="@extent"/></param>
                <param name="unit"><xsl:value-of select="@unit"/></param>
                <param name="reason"><xsl:value-of select="@reason"/></param>
            </params>
        </xsl:variable>

        <span class="gap">
            <xsl:attribute name="title">
                <xsl:call-template name="FormatMessage">
                    <xsl:with-param name="name" select="'msgMissingTextWithExtentReason'"/>
                    <xsl:with-param name="params" select="$params"/>
                </xsl:call-template>
            </xsl:attribute>
            [<i><xsl:value-of select="f:message('msgMissingText')"/></i>]
        </span>
    </xsl:template>


    <!--====================================================================-->
    <!-- Abbreviations -->

    <xsl:template match="abbr">
        <span class="abbr">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:attribute name="title">
                <xsl:value-of select="@expan"/>
            </xsl:attribute>
            <abbr>
                <xsl:attribute name="title">
                    <xsl:value-of select="@expan"/>
                </xsl:attribute>
                <xsl:apply-templates/>
            </abbr>
        </span>
    </xsl:template>


    <!--====================================================================-->
    <!-- Numbers -->

    <xsl:template match="num">
        <span class="abbr">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:attribute name="title">
                <xsl:value-of select="@value"/>
            </xsl:attribute>
            <abbr>
                <xsl:attribute name="title">
                    <xsl:value-of select="@value"/>
                </xsl:attribute>
                <xsl:apply-templates/>
            </abbr>
        </span>
    </xsl:template>


    <!--====================================================================-->
    <!-- Transcriptions (see also choice element) -->

    <xsl:template match="trans">
        <span class="abbr">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:attribute name="title">
                <xsl:value-of select="f:message('msgTranscription')"/><xsl:text>: </xsl:text><xsl:value-of select="@trans"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <!--====================================================================-->
    <!-- Code -->

    <xsl:template match="gi|tag|att">
        <code>
            <xsl:apply-templates/>
        </code>
    </xsl:template>


    <!--====================================================================-->
    <!-- Choice element (borrowed from P5) -->

    <xsl:template match="choice[reg/@type='trans']">
        <span class="trans">
            <xsl:attribute name="title">
                <xsl:value-of select="reg"/>
            </xsl:attribute>
            <xsl:apply-templates select="orig"/>
        </span>
    </xsl:template>


    <!--====================================================================-->
    <!-- Measurements with metric equivalent -->

    <xsl:template match="measure">
        <span class="measure">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:attribute name="title">
                <xsl:value-of select="./@reg"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!--====================================================================-->
    <!-- Currency amounts (in future with modern PPP equivalent) -->

    <xsl:template match="amount">
        <span class="measure">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:attribute name="title">
                <xsl:value-of select="./@unit"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="./@amount"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <!--====================================================================-->
    <!-- Arbitrary Blocks (special hooks for rendering) -->

    <xsl:template match="ab[@type='tocPagenum' or @type='tocPageNum']">
        <xsl:text>&nbsp;&nbsp;&nbsp;&nbsp; </xsl:text>
        <span class="tocPagenum">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="ab[@type='flushright']">
        <span class="flushright">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="ab[@type='versenum']">
        <span class="versenum">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="ab[@type='lineNum']">
        <xsl:if test="not(@rend='hide')">
            <span class="linenum">
                <xsl:apply-templates/>
            </span>
        </xsl:if>
    </xsl:template>

    <!-- Heatmap attributes -->
    <xsl:template match="ab[@type='q1' or @type='q2' or @type='q3' or @type='q4' or @type='q5' or @type='p1' or @type='p2' or @type='p3' or @type='h1' or @type='h2' or @type='h3']">
        <span>
            <xsl:attribute name="class"><xsl:value-of select="@type"/></xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- ab as id placeholders -->
    <xsl:template match="ab">
        <span>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:call-template name="generate-rend-class-attribute-if-needed"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>


</xsl:stylesheet>
