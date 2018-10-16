<!DOCTYPE xsl:stylesheet [

    <!ENTITY tab        "&#x09;">
    <!ENTITY lf         "&#x0A;">
    <!ENTITY cr         "&#x0D;">
    <!ENTITY deg        "&#176;">
    <!ENTITY lsquo      "&#x2018;">
    <!ENTITY rsquo      "&#x2019;">
    <!ENTITY ldquo      "&#x201C;">
    <!ENTITY rdquo      "&#x201D;">
    <!ENTITY nbsp       "&#160;">
    <!ENTITY zwsp       "&#x200B;">
    <!ENTITY hairsp     "&#x200A;">
    <!ENTITY hellip     "&#x2026;">
    <!ENTITY mdash      "&#x2014;">
    <!ENTITY prime      "&#x2032;">
    <!ENTITY Prime      "&#x2033;">
    <!ENTITY plusmn     "&#x00B1;">
    <!ENTITY frac14     "&#x00BC;">
    <!ENTITY frac12     "&#x00BD;">
    <!ENTITY frac34     "&#x00BE;">

]>

<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f xd xhtml xs">

    <xd:doc type="stylesheet">
        <xd:short>Templates for inline text elements</xd:short>
        <xd:detail>This stylesheet contains templates for inline text elements.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <!--====================================================================-->
    <!-- Plain Text -->

    <xsl:template match="text()">
        <xsl:value-of select="f:process-text(.)"/>
    </xsl:template>


    <xsl:function name="f:process-text" as="xs:string">
        <xsl:param name="text" as="xs:string"/>
        <xsl:variable name="text" select="if (f:isSet('text.spaceQuotes')) then f:handle-quotes($text) else $text"/>
        <xsl:variable name="text" select="if (f:isSet('text.useEllipses')) then f:handle-ellipses($text) else $text"/>
        <xsl:value-of select="$text"/>
    </xsl:function>


    <xsl:function name="f:handle-quotes" as="xs:string">
        <xsl:param name="text" as="xs:string"/>
    
        <xsl:variable name="text" as="xs:string" select="replace($text, '&lsquo;&ldquo;', '&lsquo;&hairsp;&ldquo;')"/>
        <xsl:variable name="text" as="xs:string" select="replace($text, '&rsquo;&rdquo;', '&rsquo;&hairsp;&rdquo;')"/>
        <xsl:variable name="text" as="xs:string" select="replace($text, '&ldquo;&lsquo;', '&ldquo;&hairsp;&lsquo;')"/>
        <xsl:variable name="text" as="xs:string" select="replace($text, '&rdquo;&rsquo;', '&rdquo;&hairsp;&rsquo;')"/>

        <xsl:value-of select="$text"/>
    </xsl:function>


    <xsl:function name="f:handle-ellipses" as="xs:string">
        <xsl:param name="text" as="xs:string"/>
    
        <xsl:variable name="text" as="xs:string" select="replace($text, '\.\.\.', '&hellip;')"/>
        <xsl:variable name="text" as="xs:string" select="replace($text, '(\w)&hellip;', '$1&hairsp;&hellip;')"/>
        <xsl:variable name="text" as="xs:string" select="replace($text, '&hellip;(\w)', '&hellip;&hairsp;$1')"/>

        <xsl:value-of select="$text"/>
    </xsl:function>



    <!--====================================================================-->
    <!-- Text styles -->

    <xd:doc>
        <xd:short>Emphasized text.</xd:short>
        <xd:detail>Emphasized text rendered as italics.</xd:detail>
    </xd:doc>

    <xsl:template match="emph">
        <i>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </i>
    </xsl:template>

    <!-- Mapped to HTML elements: it = italic; b = bold; sup = superscript; sub = subscript -->

    <xd:doc>
        <xd:short>Italic text.</xd:short>
        <xd:detail>Italic text, indicated with the <code>@rend</code> attribute value <code>it</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='it' or @rend='italic'] | i" mode="#default remove-initial titlePage">
        <i>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates mode="#current"/>
        </i>
    </xsl:template>

    <xd:doc>
        <xd:short>Bold text.</xd:short>
        <xd:detail>Bold text, indicated with the <code>@rend</code> attribute value <code>b</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='b' or @rend='bold'] | b" mode="#default remove-initial titlePage">
        <b>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates mode="#current"/>
        </b>
    </xsl:template>

    <xd:doc>
        <xd:short>Superscript text.</xd:short>
        <xd:detail>Superscript text, indicated with the <code>@rend</code> attribute value <code>sup</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='sup'] | sup" mode="#default remove-initial titlePage">
        <sup>
            <xsl:apply-templates mode="#current"/>
        </sup>
    </xsl:template>

    <xd:doc>
        <xd:short>Subscript text.</xd:short>
        <xd:detail>Subscript text, indicated with the <code>@rend</code> attribute value <code>sub</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='sub'] | sub" mode="#default remove-initial titlePage">
        <sub>
            <xsl:apply-templates mode="#current"/>
        </sub>
    </xsl:template>

    <!-- Mapped to defined CSS classes: sc = small caps; uc = upper case; ex = letterspaced; rm = roman; tt = typewriter type -->

    <xd:doc>
        <xd:short>Caps and small-caps text.</xd:short>
        <xd:detail>Caps and small-caps text, indicated with the <code>@rend</code> attribute value <code>sc</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='sc'] | sc" mode="#default remove-initial titlePage">
        <span class="sc">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xd:doc>
        <xd:short>Uppercase text.</xd:short>
        <xd:detail>Uppercase text, indicated with the <code>@rend</code> attribute value <code>uc</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='uc']" mode="#default remove-initial titlePage">
        <span class="uc">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xd:doc>
        <xd:short>Letterspaced text.</xd:short>
        <xd:detail>Letterspace (gesperrd) text, indicated with the <code>@rend</code> attribute value <code>ex</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='ex'] | g" mode="#default remove-initial titlePage">
        <span class="ex">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates mode="#current"/>
         </span>
    </xsl:template>

    <xd:doc>
        <xd:short>Upright text.</xd:short>
        <xd:detail>Upright (in an italic context) text, indicated with the <code>@rend</code> attribute value <code>rm</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='rm'] | rm" mode="#default remove-initial titlePage">
        <span class="rm">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xd:doc>
        <xd:short>Type-writer text.</xd:short>
        <xd:detail>Type-writer (monospaced) text, indicated with the <code>@rend</code> attribute value <code>tt</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='tt'] | tt" mode="#default remove-initial titlePage">
        <span class="tt">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xd:doc>
        <xd:short>Underlined text.</xd:short>
        <xd:detail>Underlined text, indicated with the <code>@rend</code> attribute value <code>underline</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='underline'] | u" mode="#default remove-initial titlePage">
        <span class="underline">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xd:doc>
        <xd:short>Overlined text.</xd:short>
        <xd:detail>Overlined text, indicated with the <code>@rend</code> attribute value <code>overline</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='overline']" mode="#default remove-initial titlePage">
        <span class="overline">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xd:doc>
        <xd:short>Text spanned with a wide tilde.</xd:short>
        <xd:detail>Text spanned with a wide tilde, indicated with the <code>@rend</code> attribute value <code>overtilde</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='overtilde']" mode="#default remove-initial titlePage">
        <span class="overtilde">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xd:doc>
        <xd:short>Highlighted text.</xd:short>
        <xd:detail>Highlighted text with other values for the <code>@rend</code> attribute.</xd:detail>
    </xd:doc>

    <xsl:template match="hi" mode="#default remove-initial titlePage">
        <xsl:choose>
            <!-- Test covers any potential rendition ladder -->
            <xsl:when test="contains(@rend, '(') or @style or @rendition">
                <span>
                    <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                    <!-- Actual style is put in stylesheet, rendered in CSS mode -->
                    <xsl:copy-of select="f:set-class-attribute(.)"/>
                    <xsl:apply-templates mode="#current"/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <i>
                    <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                    <xsl:apply-templates mode="#current"/>
                </i>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:short>Greek passages.</xd:short>
        <xd:detail>Use another font for Greek script passages.</xd:detail>
    </xd:doc>

    <xsl:template match="foreign[@lang='el' or @lang='grc']" mode="#default remove-initial titlePage">
        <span>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'Greek')"/>
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xd:doc>
        <xd:short>Arabic passages.</xd:short>
        <xd:detail>Use another font for Arabic script passages.</xd:detail>
    </xd:doc>

    <xsl:template match="foreign[@lang='ar']" mode="#default remove-initial titlePage">
        <span>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'Arabic')"/>
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xd:doc>
        <xd:short>Foreign phrases.</xd:short>
        <xd:detail>Foreign phrases are not styled by default, but we do set the language on them.</xd:detail>
    </xd:doc>

    <xsl:template match="foreign" mode="#default remove-initial titlePage">
        <span>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute(.)"/>
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>


    <!--====================================================================-->
    <!-- Anchors -->

    <xd:doc>
        <xd:short>Anchors.</xd:short>
        <xd:detail>Anchors are empty placeholders and are translated to HTML anchors.</xd:detail>
    </xd:doc>

    <xsl:template match="anchor">
        <a id="{f:generate-id(.)}"><xsl:apply-templates/></a>
    </xsl:template>


    <!--====================================================================-->
    <!-- Corrections -->

    <xd:doc>
        <xd:short>Corrections.</xd:short>
        <xd:detail>Corrections are rendered as red-dash-underline spans with a pop-up that
        will show the original text.</xd:detail>
    </xd:doc>

    <xsl:template match="corr">
        <xsl:call-template name="handle-correction">
            <xsl:with-param name="sic" select="@sic"/>
            <xsl:with-param name="corr" select="./node()"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="corr" mode="titlePage">
        <xsl:call-template name="handle-correction">
            <xsl:with-param name="sic" select="@sic"/>
            <xsl:with-param name="corr" select="./node()"/>
        </xsl:call-template>
    </xsl:template>

    <xd:doc>
        <xd:short>Handle Corrections.</xd:short>
        <xd:detail>In this template, we filter out the minor and punctuation corrections (marked with the <code>@resp</code>
        attribute with value <code>n</code> or <code>p</code>). Furthermore, the span will be given an id, such that
        the list of corrections in the colophon can link to it.</xd:detail>
    </xd:doc>

    <xsl:template name="handle-correction">
        <xsl:param name="sic" xs:as="node()*"/>
        <xsl:param name="corr" xs:as="node()*"/>

        <xsl:variable name="msgSource" select="if (@resp = 'errata') then f:message('msgAuthorCorrection') else f:message('msgSource')"/>
        <xsl:variable name="msgNotInSource" select="if (@resp = 'errata') then f:message('msgAuthorAddition') else f:message('msgNotInSource')"/>

        <!-- Concatenate string values ourselves to prevent the XSLT processor from inserting spaces when concatenating nodes
             (Tennison, Beginning XSLT 2.0, p. 358). -->
        <xsl:variable name="sicString">
            <xsl:for-each select="$sic">
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:choose>
            <!-- Don't report minor or punctuation corrections; also don't report if we do not use mouse-over popups. -->
            <xsl:when test="@resp = 'm' or @resp = 'p' or not(f:isSet('useMouseOverPopups'))">
                <span>
                    <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                    <xsl:apply-templates select="$corr"/>
                </span>
            </xsl:when>
            <xsl:when test="not($sic) or $sic = ''">
                <span class="corr">
                    <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                    <xsl:attribute name="title">
                        <xsl:value-of select="$msgNotInSource"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="$corr"/>
                </span>
            </xsl:when>
            <!-- Don't generate an empty span, as that will be purged by some HTML tools -->
            <xsl:when test="not($corr) or $corr = ''">
                <a id="{f:generate-id(.)}"/>
            </xsl:when>
            <xsl:otherwise>
                <span class="corr">
                    <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                    <xsl:attribute name="title">
                        <xsl:value-of select="$msgSource"/><xsl:text>: </xsl:text><xsl:value-of select="$sicString"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="$corr"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!--====================================================================-->
    <!-- Gaps -->

    <xd:doc>
        <xd:short>Handle a gap.</xd:short>
        <xd:detail><p>The <code>gap</code> element indicated that some text has been omitted. The
        <code>@reason</code> attribute can be used to give a reason; the <code>@unit</code> and <code>@extent</code>
        attributes can be used to give an estimate of the size of the omitted material.</p>

        <p>In HTML, a gap is rendered with the localized words [<i>missing text</i>], and a pop-up giving the reason
        and extent.</p></xd:detail>
    </xd:doc>

    <xsl:template match="gap">
        <xsl:variable name="params">
            <params>
                <param name="extent"><xsl:value-of select="@extent"/></param>
                <param name="unit"><xsl:value-of select="@unit"/></param>
                <param name="reason"><xsl:value-of select="@reason"/></param>
            </params>
        </xsl:variable>

        <span class="gap">
            <xsl:if test="f:isSet('useMouseOverPopups')">
                <xsl:attribute name="title" select="if (@extent) 
                                                    then f:formatMessage('msgMissingTextWithExtentReason', $params) 
                                                    else f:formatMessage('msgMissingTextWithReason', $params)"/>
            </xsl:if>
            <xsl:text>[</xsl:text><i><xsl:value-of select="f:message('msgMissingText')"/></i><xsl:text>]</xsl:text>
        </span>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle a space.</xd:short>
        <xd:detail><p>The <code>space</code> element indicated that some (extra-wide) space has been inserted. The
        <code>@unit</code> and <code>@quantity</code> attributes can be used to give an indication of the size of the 
        space.</p>

        <p>In HTML, a space is rendered with a zero-width space and appropriately sized padding, applied via CSS.</p></xd:detail>
    </xd:doc>

    <xsl:template match="space">
        <xsl:variable name="quantity" select="if (@quantity) then @quantity else 1"/>
        <span>
            <xsl:attribute name="class">
                <xsl:text>space </xsl:text>
                <xsl:value-of select="f:generate-id(.)"/><xsl:text>space</xsl:text>
            </xsl:attribute>
            <!-- Insert a zero-width space to prevent tidy from removing up this span. -->
            <xsl:text>&zwsp;</xsl:text>
        </span>
    </xsl:template>


    <xsl:template match="space" mode="css">
        <xsl:variable name="quantity" select="if (@quantity) then @quantity else 1"/>
        <xsl:variable name="unit" select="if (@unit) then @unit else 'em'"/>

        <!-- Assume a character is 0.5em. -->
        <xsl:variable name="quantity" select="if ($unit = ('char', 'chars')) then $quantity div 2.0 else $quantity"/>
        <xsl:variable name="unit" select="if ($unit = ('char', 'chars')) then 'em' else $unit"/>

        <!-- Cannot set width of span, so set padding-left -->
.<xsl:value-of select="f:generate-id(.)"/>space {
   padding-left: <xsl:value-of select="$quantity"/><xsl:value-of select="$unit"/>
}
    </xsl:template>


    <!--====================================================================-->
    <!-- Abbreviations -->

    <xd:doc>
        <xd:short>Abbreviations.</xd:short>
        <xd:detail>Abbreviations are rendered as dash-underline spans with a pop-up that
        will show the expanded text taken from the <code>@expan</code> attribute (if available).</xd:detail>
    </xd:doc>

    <xsl:template match="abbr">
        <abbr>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:if test="@type">
                <xsl:attribute name="class" select="@type"/>
            </xsl:if>
            <xsl:if test="f:isSet('useMouseOverPopups')">
                <xsl:variable name="expan" select="f:findExpansion(.)" as="xs:string"/>
                <xsl:if test="$expan != ''">
                    <xsl:attribute name="title">
                        <xsl:value-of select="$expan"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates/>
        </abbr>
    </xsl:template>

    <xd:doc>
        <xd:short>Find the expansion of an abbreviation.</xd:short>
        <xd:detail>Find the expansion of an abbreviation, by first looking for the value of the <code>@expan</code> attribute
        on the abbreviation itself, or, if that is not available, look for other occurrences of the same abbreviation, that
        might provide the expansion.</xd:detail>
    </xd:doc>

    <xsl:function name="f:findExpansion" as="xs:string">
        <xsl:param name="abbr" as="element()"/>

        <xsl:value-of select="if ($abbr/@expan != '') 
            then $abbr/@expan
            else if (root($abbr)//abbr[. = $abbr and ./@expan != ''])
                 then (root($abbr)//abbr[. = $abbr and ./@expan != '']/@expan)[1]
                 else if (root($abbr)//choice[abbr = $abbr and expan != ''])
                      then (root($abbr)//choice[abbr = $abbr and expan != '']/expan)[1]
                      else ''"/>
    </xsl:function>


    <!--====================================================================-->
    <!-- Numbers -->

    <xsl:template match="num">
        <span class="num">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:if test="f:isSet('useMouseOverPopups')">
                <xsl:attribute name="title">
                    <xsl:value-of select="@value"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <!--====================================================================-->
    <!-- Transcriptions (see also choice element) -->

    <xd:doc>
        <xd:short>Transcriptions.</xd:short>
        <xd:detail>Transcriptions are rendered as spans with a pop-up that
        will show the transcribed text taken from the <code>@trans</code> attribute (if available).</xd:detail>
    </xd:doc>

    <xsl:template match="trans">
        <span class="trans">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:if test="f:isSet('useMouseOverPopups')">
                <xsl:attribute name="title">
                    <xsl:value-of select="f:message('msgTranscription')"/><xsl:text>: </xsl:text><xsl:value-of select="@trans"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <!--====================================================================-->
    <!-- Code -->

    <xd:doc>
        <xd:short>Code samples.</xd:short>
        <xd:detail>Code samples are rendered in a typewriter font (using the <code>code</code> element in HTML).</xd:detail>
    </xd:doc>

    <xsl:template match="gi|tag|att">
        <code>
            <xsl:apply-templates/>
        </code>
    </xsl:template>


    <!--====================================================================-->
    <!-- Choice element (TEI P5) -->

    <xd:doc>
        <xd:short>Handle a choice (for transcription).</xd:short>
        <xd:detail>A <code>choice</code> element containing a <code>reg</code> and an <code>orig</code> element, with <code>@type="trans"</code> are used
        to represent transcriptions, and translated to HTML pop-ups. These <code>choice</code>-elements are typically introduced by a script automatically
        adding transcriptions to Greek fragments.</xd:detail>
    </xd:doc>

    <xsl:template match="choice[reg/@type='trans']">
        <span class="trans">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:if test="f:isSet('useMouseOverPopups')">
                <xsl:attribute name="title">
                    <xsl:value-of select="reg"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="orig"/>
        </span>
    </xsl:template>

    <xd:doc>
        <xd:short>Handle a choice (for corrections).</xd:short>
        <xd:detail>A <code>choice</code> element containing a <code>sic</code> and a <code>corr</code> element are used
        to represent corrections, and translated to HTML pop-ups.</xd:detail>
    </xd:doc>

    <xsl:template match="choice[corr]">
        <xsl:call-template name="handle-correction">
            <xsl:with-param name="sic" select="sic/node()"/>
            <xsl:with-param name="corr" select="corr/node()"/>
        </xsl:call-template>
    </xsl:template>


    <!--====================================================================-->
    <!-- Measurements with metric equivalent -->

    <xsl:template match="measure">
        <xsl:choose>
            <xsl:when test="f:isSet('useRegularizedUnits')">
                <span class="measure">
                    <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                    <xsl:if test="f:isSet('useMouseOverPopups')">
                        <xsl:attribute name="title">
                            <xsl:value-of select="."/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="./@reg"/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="measure">
                    <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                    <xsl:if test="f:isSet('useMouseOverPopups')">
                        <xsl:attribute name="title">
                            <xsl:value-of select="./@reg"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!--====================================================================-->
    <!-- Currency amounts (in future with modern PPP equivalent) -->

    <xsl:template match="amount">
        <span class="measure">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:if test="f:isSet('useMouseOverPopups')">
                <xsl:attribute name="title">
                    <xsl:value-of select="./@unit"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="./@amount"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <!--====================================================================-->
    <!-- Arbitrary Blocks (special hooks for rendering) -->

    <xsl:template match="ab">
        <xsl:if test="not(@rend='hide')">
            <!-- If the item is to go flush right, add some space to avoid a colission in HTML. -->
            <xsl:if test="@type='tocPageNum' or @type='flushright' or @type='adPrice'">
                <xsl:text>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </xsl:text>
            </xsl:if>
            <span>
                <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                <xsl:variable name="class">
                    <xsl:value-of select="@type"/>
                </xsl:variable>
                <xsl:copy-of select="f:set-class-attribute-with(., $class)"/>
                <xsl:apply-templates/>
            </span>
        </xsl:if>
    </xsl:template>


    <!--====================================================================-->
    <!-- Bibliographic elements -->

    <xsl:template match="bibl">
        <span class="bibl">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="cit">
        <span class="cit">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!--====================================================================-->
    <!-- Segments (sentences or phrases.) -->

    <xd:doc>
        <xd:short>Segments.</xd:short>
        <xd:detail>Segments are used in text-analysis. We also use them for synchronizing
        audio with the text.</xd:detail>
    </xd:doc>

    <xsl:template match="seg">
        <span class="seg">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <xd:doc>
        <xd:short>Segments with ditto marks.</xd:short>
        <xd:detail>When ditto marks are used in the source text, they are marked as a segment, and
        the attribute <code>@copyOf</code> is used to point to the segment that contains the full
        text. Tei2html will emulate the appearance of the ditto marks, or replace them with the 
        full text depending on the value of the setting <code>useDittoMarks</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="seg[@copyOf]">
        <span class="seg">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:variable name="copyOf" select="if (starts-with(@copyOf, '#')) then substring(@copyOf, 2) else @copyOf"/>
            <xsl:variable name="copy" select="//seg[@id = $copyOf]"/>
            <xsl:choose>
                <xsl:when test="not($copy)">
                    <xsl:copy-of select="f:logError('Segment with @id=''{1}'' not found', ($copyOf))"/>
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:when test="f:isSet('useDittoMarks')">
                    <xsl:variable name="copy" select="if ($copy//corr) then f:stripCorrElements($copy) else $copy"/>
                    <xsl:apply-templates select="$copy" mode="ditto"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="$copy"/>
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>


    <!--====================================================================-->
    <!-- Ditto marks in tables and lists -->

    <xd:doc>
        <xd:short>Use ditto marks in tables and lists.</xd:short>
        <xd:detail>To set ditto-marks in tables, we need a number of HTML formatting tricks. Basically, when a phrase is in a ditto element,
        we want to replace the individual words with pairs of commas, neatly centered under each word. To achieve this, we create a small table
        of one column and two rows. We place the word in the first row, but then make it invisible and reduce its height to zero (using CSS),
        and place the ditto-mark centered in the second row. Some further trickery is needed to handle the most common formatting that
        can occur in contexts where ditto-marks are used. Note that this code is quite fragile, and will fail if unexpected tagging is encountered
        inside the ditto element, or outside a table or list (such as a plain paragraph).</xd:detail>
    </xd:doc>

    <xsl:template match="ditto">
        <xsl:copy-of select="f:logWarning('Depricated element ditto used (please use seg).', ())"/>
        <xsl:choose>
            <xsl:when test="f:isSet('useDittoMarks')">
                <xsl:variable name="node" select="if (.//corr) then f:stripCorrElements(.) else ."/>
                <xsl:apply-templates select="$node" mode="ditto"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template mode="ditto" match="text()">
        <xsl:copy-of select="f:useDittoMarks(.)"/>
    </xsl:template>


    <xsl:function name="f:useDittoMarks">
        <xsl:param name="node" as="node()*"/>

        <!-- Split the text-content of the ditto on space boundaries -->
        <xsl:for-each select="tokenize($node, '\s+')">
            <xsl:choose>
                <xsl:when test="matches(., '^[.,:;!]$')">
                    <xsl:copy-of select="f:logWarning('Stand-alone punctuation mark ({1}) in ditto (will not use ditto mark).', (.))"/>
                    <span class="ditto">
                        <span class="s"><xsl:value-of select="."/></span>
                    </span>
                </xsl:when>
                <xsl:otherwise>
                    <span class="ditto">
                        <span class="s">
                            <!-- Handle most common in-line style elements. -->
                            <xsl:choose>
                                <xsl:when test="$node/parent::hi[@rend='b' or @rend='bold']">
                                    <b><xsl:value-of select="."/></b>
                                </xsl:when>
                                <xsl:when test="$node/parent::hi[@rend='sup']">
                                    <sup><xsl:value-of select="."/></sup>
                                </xsl:when>
                                <xsl:when test="$node/parent::hi[@rend='sub']">
                                    <sub><xsl:value-of select="."/></sub>
                                </xsl:when>
                                <xsl:when test="$node/parent::hi[@rend='sc']">
                                    <span class="sc"><xsl:value-of select="."/></span>
                                </xsl:when>
                                <xsl:when test="$node/parent::hi">
                                    <i><xsl:value-of select="."/></i>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </span>
                        <!-- No ditto marks for parts that are superscripted or subscripted -->
                        <xsl:if test="not($node/parent::hi[@rend='sub' or @rend='sup'])">
                            <!-- Nest two levels of span to enable CSS to get alignment right -->
                            <span class="d"><span class="i">
                                <xsl:value-of select="f:determineDittoMark($node)"/>
                            </span></span>
                        </xsl:if>
                    </span>
                    <!-- Don't forget to reinsert the space we split on -->
                    <xsl:text> </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>


    <xsl:function name="f:determineDittoMark" as="xs:string">
        <xsl:param name="node" as="node()"/>

        <xsl:value-of select="if ($node/ancestor::ditto/@mark) 
            then $node/ancestor::ditto/@mark 
            else if ($node/ancestor::*[f:has-rend-value(./@rend, 'ditto-mark')])
                 then f:rend-value($node/ancestor::*[f:has-rend-value(./@rend, 'ditto-mark')][1]/@rend, 'ditto-mark')
                 else f:getSetting('dittoMark')"/>
    </xsl:function>


    <xsl:function name="f:stripCorrElements">
        <xsl:param name="node" as="node()"/>

        <xsl:apply-templates select="$node" mode="stripCorrElements"/>
    </xsl:function>

    <xsl:template match="@*|node()" mode="stripCorrElements">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="stripCorrElements"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="corr" mode="stripCorrElements">
        <xsl:apply-templates select="@*|node()" mode="stripCorrElements"/>
    </xsl:template>

    <xsl:template match="choice[corr]" mode="stripCorrElements">
        <xsl:apply-templates select="corr" mode="stripCorrElements"/>
    </xsl:template>


</xsl:stylesheet>
