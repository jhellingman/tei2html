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
<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:f="urn:stylesheet-functions"
    exclude-result-prefixes="f xd"
    version="2.0"
    >

    <xd:doc type="stylesheet">
        <xd:short>Templates for inline text elements</xd:short>
        <xd:detail>This stylesheet contains templates for inline text elements.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <!--====================================================================-->
    <!-- Text styles -->

    <xd:doc>
        <xd:short>Emphasized text.</xd:short>
        <xd:detail>Emphasized text rendered as italics.</xd:detail>
    </xd:doc>

    <xsl:template match="emph">
        <i><xsl:call-template name="set-lang-id-attributes"/><xsl:apply-templates/></i>
    </xsl:template>

    <!-- Mapped to HTML elements: it = italic; b = bold; sup = superscrip; sub = subscript -->

    <xd:doc>
        <xd:short>Italic text.</xd:short>
        <xd:detail>Italic text, indicated with the <code>@rend</code> attribute value <code>it</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='it' or @rend='italic'] | i">
        <i><xsl:call-template name="set-lang-id-attributes"/><xsl:apply-templates/></i>
    </xsl:template>

    <xd:doc>
        <xd:short>Bold text.</xd:short>
        <xd:detail>Bold text, indicated with the <code>@rend</code> attribute value <code>b</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='b' or @rend='bold'] | b">
        <b><xsl:call-template name="set-lang-id-attributes"/><xsl:apply-templates/></b>
    </xsl:template>

    <xd:doc>
        <xd:short>Superscript text.</xd:short>
        <xd:detail>Superscript text, indicated with the <code>@rend</code> attribute value <code>sup</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='sup'] | sup">
        <sup><xsl:apply-templates/></sup>
    </xsl:template>

    <xd:doc>
        <xd:short>Subscript text.</xd:short>
        <xd:detail>Subscript text, indicated with the <code>@rend</code> attribute value <code>sub</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='sub'] | sub">
        <sub><xsl:apply-templates/></sub>
    </xsl:template>

    <!-- Mapped to defined CSS classes: sc = small caps; uc = upper case; ex = letterspaced; rm = roman; tt = typewriter type -->

    <xd:doc>
        <xd:short>Caps and small-caps text.</xd:short>
        <xd:detail>Caps and small-caps text, indicated with the <code>@rend</code> attribute value <code>sc</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='sc'] | sc">
        <span class="sc"><xsl:call-template name="set-lang-id-attributes"/><xsl:apply-templates/></span>
    </xsl:template>

    <xd:doc>
        <xd:short>Uppercase text.</xd:short>
        <xd:detail>Uppercase text, indicated with the <code>@rend</code> attribute value <code>uc</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='uc']">
        <span class="uc"><xsl:call-template name="set-lang-id-attributes"/><xsl:apply-templates/></span>
    </xsl:template>

    <xd:doc>
        <xd:short>Letterspaced text.</xd:short>
        <xd:detail>Letterspace (gesperrd) text, indicated with the <code>@rend</code> attribute value <code>ex</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='ex'] | g ">
        <span class="ex"><xsl:call-template name="set-lang-id-attributes"/><xsl:apply-templates/></span>
    </xsl:template>

    <xd:doc>
        <xd:short>Upright text.</xd:short>
        <xd:detail>Upright (in an italic context) text, indicated with the <code>@rend</code> attribute value <code>rm</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='rm']">
        <span class="rm"><xsl:call-template name="set-lang-id-attributes"/><xsl:apply-templates/></span>
    </xsl:template>

    <xd:doc>
        <xd:short>Type-writer text.</xd:short>
        <xd:detail>Type-writer (monospaced) text, indicated with the <code>@rend</code> attribute value <code>tt</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='tt'] | tt">
        <span class="tt"><xsl:call-template name="set-lang-id-attributes"/><xsl:apply-templates/></span>
    </xsl:template>

    <xd:doc>
        <xd:short>Underlined text.</xd:short>
        <xd:detail>Underlined text, indicated with the <code>@rend</code> attribute value <code>underline</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='underline'] | u">
        <span class="underline"><xsl:apply-templates/></span>
    </xsl:template>

    <xd:doc>
        <xd:short>Overlined text.</xd:short>
        <xd:detail>Overlined text, indicated with the <code>@rend</code> attribute value <code>overline</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='overline']">
        <span class="overline"><xsl:apply-templates/></span>
    </xsl:template>

    <xd:doc>
        <xd:short>Text spanned with a wide tilde.</xd:short>
        <xd:detail>Text spanned with a wide tilde, indicated with the <code>@rend</code> attribute value <code>overtilde</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='overtilde']">
        <span class="overtilde"><xsl:apply-templates/></span>
    </xsl:template>

    <xd:doc>
        <xd:short>Hi-lighted text.</xd:short>
        <xd:detail>Hi-lighted text with other values for the <code>@rend</code> attribute.</xd:detail>
    </xd:doc>

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

    <xd:doc>
        <xd:short>Greek passages.</xd:short>
        <xd:detail>Use another font for Greek script passages.</xd:detail>
    </xd:doc>

    <xsl:template match="foreign[@lang='el' or @lang='grc']">
        <span class="Greek"><xsl:call-template name="set-lang-id-attributes"/><xsl:apply-templates/></span>
    </xsl:template>

    <xd:doc>
        <xd:short>Arabic passages.</xd:short>
        <xd:detail>Use another font for Arabic script passages.</xd:detail>
    </xd:doc>

    <xsl:template match="foreign[@lang='ar']">
        <span class="Arabic"><xsl:call-template name="set-lang-id-attributes"/><xsl:apply-templates/></span>
    </xsl:template>

    <xd:doc>
        <xd:short>Foreign phrases.</xd:short>
        <xd:detail>Foreign phrases are not styled by default, but we do set the language on them.</xd:detail>
    </xd:doc>

    <xsl:template match="foreign">
        <span><xsl:call-template name="set-lang-id-attributes"/><xsl:apply-templates/></span>
    </xsl:template>


    <!--====================================================================-->
    <!-- Anchors -->

    <xd:doc>
        <xd:short>Anchors.</xd:short>
        <xd:detail>Anchors are empty placeholders and are translated to HTML anchors.</xd:detail>
    </xd:doc>

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
            <!-- Don't report minor or punctuation corrections -->
            <xsl:when test="@resp = 'm' or @resp = 'p'">
                <span>
                    <xsl:call-template name="generate-id-attribute"/>
                    <xsl:apply-templates/>
                </span>
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
            <!-- Don't generate an empty span, as that will be purged by some HTML tools -->
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
        <span class="tocPageNum">
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


    <!--====================================================================-->
    <!-- Bibliographic elements -->

    <xsl:template match="bibl">
        <span class="bibl">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="cit">
        <span class="cit">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <!--====================================================================-->
    <!-- Ditto marks in tables and lists -->

    <xd:doc>
        <xd:short>Use ditto marks in tables and lists.</xd:short>
        <xd:detail>To set ditto-marks in tables, we need a number of HTML formatting tricks. Basically, when a phrase is in a ditto element,
        we want to replace the individual words with pairs of commas, neatly centered under each word. To achieve this, we create a small table
        of one column and two rows. We place the word in the first row, but then make it invisible and reduce its size to zero (using CSS),
        and place the ditto-mark centered in the second row. Some further trickery is needed to handle the most common formatting that
        can occur in contexts where ditto-marks are used. Note that this code is quite fragile, and will fail if unexpected tagging is encountered
        inside the ditto element, or outside a table or list (such as a plain paragraph).</xd:detail>
    </xd:doc>

    <xsl:template match="ditto">
        <xsl:choose>
            <xsl:when test="f:getConfigurationBoolean('useDittoMarks')">
                <xsl:apply-templates mode="ditto"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template mode="ditto" match="text()">
        <xsl:call-template name="use_ditto_marks"/>
    </xsl:template>


    <xsl:template name="use_ditto_marks">
        <!-- Split the text-content of the ditto on space boundaries -->
        <xsl:variable name="context" select="."/>
        <xsl:for-each select="tokenize(., '\s+')">
            <xsl:choose>
                <xsl:when test="matches(., '^[.,:;!]$')">
                    <xsl:message terminate="no">WARNING: stand-alone punctionation mark '<xsl:value-of select="."/>' in ditto (will not use ditto mark).</xsl:message>
                    <table class="ditto">
                        <tr class="s"><td><xsl:value-of select="."/></td></tr>
                    </table>
                </xsl:when>
                <xsl:otherwise>
                    <table class="ditto">
                        <tr class="s">
                            <td>
                            <!-- Handle most common in-line style elements. -->
                                <xsl:choose>
                                    <xsl:when test="$context/parent::hi[@rend='b' or @rend='bold']">
                                        <b><xsl:value-of select="."/></b>
                                    </xsl:when>
                                    <xsl:when test="$context/parent::hi[@rend='sup']">
                                        <sup><xsl:value-of select="."/></sup>
                                    </xsl:when>
                                    <xsl:when test="$context/parent::hi[@rend='sub']">
                                        <sub><xsl:value-of select="."/></sub>
                                    </xsl:when>
                                    <xsl:when test="$context/parent::hi[@rend='sc']">
                                        <span class="sc"><xsl:value-of select="."/></span>
                                    </xsl:when>
                                    <xsl:when test="$context/parent::hi">
                                        <i><xsl:value-of select="."/></i>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                        <!-- No ditto marks for parts that are superscripted or subscripted -->
                        <xsl:if test="not($context/parent::hi[@rend='sub' or @rend='sup'])">
                            <tr class="d">
                                <td>
                                    <xsl:value-of select="if ($context/ancestor::ditto/@mark) then $context/ancestor::ditto/@mark else ',,'"/>
                                </td>
                            </tr>
                        </xsl:if>
                    </table>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>


</xsl:stylesheet>
