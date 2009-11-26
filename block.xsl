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

    Stylesheet to format block level elements, to be imported in tei2html.xsl.

    Requires: 
        localization.xsl    : templates for localizing strings.
        messages.xsl        : stores localized messages in variables.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"
    >


    <!--====================================================================-->
    <!-- Title Page -->

    <xsl:template match="titlePage">
        <div class="titlePage">
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>

    <xsl:template match="docTitle" mode="titlePage">
        <xsl:apply-templates mode="titlePage"/>
    </xsl:template>

    <xsl:template match="titlePart" mode="titlePage">
        <h1 class="docTitle">
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates mode="titlePage"/>
        </h1>
    </xsl:template>

    <xsl:template match="titlePart[@type='sub']" mode="titlePage">
        <h2 class="docTitle">
            <xsl:apply-templates mode="titlePage"/>
        </h2>
    </xsl:template>

    <xsl:template match="byline" mode="titlePage">
        <h2 class="byline">
            <xsl:apply-templates mode="titlePage"/>
        </h2>
    </xsl:template>

    <xsl:template match="docAuthor" mode="titlePage">
        <span class="docAuthor">
            <xsl:apply-templates mode="titlePage"/>
        </span>
    </xsl:template>

    <xsl:template match="lb" mode="titlePage">
        <br/>
    </xsl:template>

    <xsl:template match="docImprint" mode="titlePage">
        <h2 class="docImprint">
            <xsl:apply-templates/>
        </h2>
    </xsl:template>

    <xsl:template match="epigraph" mode="titlePage">
        <h2 class="docImprint">
            <xsl:apply-templates/>
        </h2>
    </xsl:template>

    <xsl:template match="figure" mode="titlePage">
        <xsl:apply-templates select="."/>
    </xsl:template>


    <!--====================================================================-->
    <!-- Page Breaks -->

    <xsl:template match="pb">
        <xsl:choose>
            <!-- In HTML, we do not allow a span element at the top-level. -->
            <xsl:when test="ancestor::p | ancestor::list | ancestor::table">
                <xsl:call-template name="pb"/>
            </xsl:when>
            <xsl:otherwise>
                <p><xsl:call-template name="pb"/></p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="pb">
        <xsl:choose>
            <xsl:when test="@n">
                <span class="pagenum">[<a>
                    <xsl:call-template name="generate-id-attribute"/>
                    <xsl:call-template name="generate-href-attribute"/>
                    <xsl:value-of select="@n"/></a>]</span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="generate-anchor"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!--====================================================================-->
    <!-- Thematic Breaks -->

    <xsl:template match="milestone[@unit='theme' or @unit='tb']">
        <xsl:call-template name="closepar"/>
        <xsl:choose>
            <xsl:when test="contains(@rend, 'stars')">
                <p class="tb">*&nbsp;&nbsp;&nbsp;*&nbsp;&nbsp;&nbsp;*</p>
            </xsl:when>
            <xsl:when test="contains(@rend, 'star')">
                <p class="tb">*</p>
            </xsl:when>
            <xsl:when test="contains(@rend, 'space')">
                <p class="tb"/>
            </xsl:when>
            <xsl:otherwise>
                <hr class="tb"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>


    <xsl:template match="milestone">
        <xsl:call-template name="generate-anchor"/>
    </xsl:template>



    <!--====================================================================-->
    <!-- Arguments (short summary of contents at start of chapter) -->

    <xsl:template match="argument">
        <div class="argument">
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <!--====================================================================-->
    <!-- Epigraphs -->

    <xsl:template match="epigraph">
        <div class="epigraph">
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="bibl">
        <span class="bibl">
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <!-- trailers -->

    <xsl:template match="trailer">
        <p>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:attribute name="class">trailer
                <xsl:if test="contains(@rend, 'align(center)')"><xsl:text> </xsl:text>aligncenter</xsl:if>
            </xsl:attribute>
            <xsl:apply-templates/>
        </p>
    </xsl:template>


    <!--====================================================================-->
    <!-- Blockquotes -->

    <xsl:template match="q[@rend='block']">
        <xsl:call-template name="closepar"/>
        <div class="blockquote">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>

    <xsl:template match="q">
        <xsl:call-template name="closepar"/>
        <div class="q">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>

    <!-- Other uses of q should be ignored, as it is typically used to nest elements that otherwise could not appear at a certain location, such as verse in footnotes. -->


    <!--====================================================================-->
    <!-- Letters, with openers, closers, etc. -->

    <!-- non-TEI shortcut for <q><text><body><div1 type="Letter"> -->
    <xsl:template match="letter">
        <xsl:call-template name="closepar"/>
        <div class="blockquote letter">
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>

    <xsl:template match="opener">
        <div class="opener">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="salute">
        <div class="salute">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="closer">
        <div class="closer">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="signed">
        <div class="signed">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="dateline">
        <div class="dateline">
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <!--====================================================================-->
    <!-- Paragraphs -->

    <xsl:template match="p">
        <xsl:if test="not(contains(@rend, 'display(none)'))">
            <p>
                <xsl:call-template name="generate-id-attribute"/>
                <xsl:call-template name="setLangAttribute"/>
                <xsl:call-template name="setCssClassAttribute"/>  <!-- TODO: handle alignment differently below -->

                <!-- in a few cases, we have paragraphs in quoted material in footnotes, which need to be set in a smaller font: apply the proper class for that. -->
                <xsl:if test="ancestor::note[place='foot' or not(@place)]">
                    <xsl:attribute name="class">footnote</xsl:attribute>
                </xsl:if>

                <xsl:if test="contains(@rend, 'indent(') or contains(@rend, 'align(')">
                    <xsl:attribute name="style">
                        <xsl:if test="contains(@rend, 'indent(')">text-indent:<xsl:value-of select="substring-before(substring-after(@rend, 'indent('), ')')"/>em;</xsl:if>
                        <xsl:if test="contains(@rend, 'align(')">text-align:<xsl:value-of select="substring-before(substring-after(@rend, 'align('), ')')"/>;</xsl:if>
                    </xsl:attribute>
                </xsl:if>

                <xsl:if test="@n">
                    <span class="parnum"><xsl:value-of select="@n"/>.<xsl:text> </xsl:text></span>
                </xsl:if>
                <xsl:apply-templates/>
            </p>
        </xsl:if>
    </xsl:template>


    <!--====================================================================-->
    <!-- Decorative Initials

    Decorative initials are encoded with the rend attribute on the paragraph 
    level.

    To properly show an initial in HTML that may stick over the text, we need 
    to use a number of tricks in CSS.

    1. We set the initial as background picture on the paragraph.
    2. We create a small div which we let float to the left, to give the initial 
       the space it needs.
    3. We set the padding-top to a value such that the initial actually appears 
       to stick over the paragraph.
    4. We set the initial as background picture to the float, such that if the 
       paragraph is to small to contain the entire initial, the float will. We 
       need to take care to adjust the background position to match the 
       padding-top, such that the two background images will align exactly.
    5. We need to take the first letter from the Paragraph, and render it in the 
       float in white, such that it re-appears when no CSS is available.

    -->

    <xsl:template match="p[contains(@rend, 'initial-image')]">
        <p>
            <xsl:call-template name="generate-id-attribute"/>
            <span>
                <xsl:attribute name="id"><xsl:call-template name="generate-id"/>init</xsl:attribute>
                <xsl:choose>
                    <xsl:when test="substring(.,1,1) = '&ldquo;'">
                        <xsl:value-of select="substring(.,1,2)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring(.,1,1)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </span>
            <xsl:apply-templates mode="eat-initial"/>
        </p>
    </xsl:template>


    <xsl:template match="p[contains(@rend, 'initial-image')]" mode="css">
        <xsl:variable name="properties"><xsl:call-template name="translate-rend-attribute"/></xsl:variable>
        
        #<xsl:call-template name="generate-id"/>
        {
            background: url(<xsl:value-of select="substring-before(substring-after(@rend, 'initial-image('), ')')"/>) no-repeat top left;
            <xsl:if test="contains(@rend, 'initial-offset(')">
                padding-top: <xsl:value-of select="substring-before(substring-after(@rend, 'initial-offset('), ')')"/>;
            </xsl:if>

            <xsl:if test="normalize-space($properties) != ''">
                <xsl:value-of select="$properties"/>
            </xsl:if>
        }

        #<xsl:call-template name="generate-id"/>init
        {
            float: left;
            width: <xsl:value-of select="substring-before(substring-after(@rend, 'initial-width('), ')')"/>;
            height: <xsl:value-of select="substring-before(substring-after(@rend, 'initial-height('), ')')"/>;
            background: url(<xsl:value-of select="substring-before(substring-after(@rend, 'initial-image('), ')')"/>) no-repeat;
            <xsl:if test="contains(@rend, 'initial-offset(')">
                background-position: 0px -<xsl:value-of select="substring-before(substring-after(@rend, 'initial-offset('), ')')"/>;
            </xsl:if>
            text-align: right;
            color: white;
            font-size: 1px;
        }

    </xsl:template>


    <!-- We need to adjust the text() matching template to remove the first character from the paragraph -->
    <xsl:template match="text()" mode="eat-initial">
        <xsl:choose>
            <xsl:when test="position()=1 and substring(.,1,1) = '&ldquo;'">
                <xsl:value-of select="substring(.,3)"/>
            </xsl:when>
            <xsl:when test="position()=1">
                <xsl:value-of select="substring(.,2)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="*" mode="eat-initial">
        <xsl:if test="position()>1">
            <xsl:apply-templates select="."/>
        </xsl:if>
    </xsl:template>


</xsl:stylesheet>
