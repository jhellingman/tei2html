<!DOCTYPE xsl:stylesheet [

    <!ENTITY tab        "&#x0009;">
    <!ENTITY lf         "&#x000A;">
    <!ENTITY cr         "&#x000D;">
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

    <!ENTITY boKa       "&#x0F40;">
    <!ENTITY boRra      "&#x0F6C;">
    <!ENTITY boTsheg    "&#x0F0B;">

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
        <xsl:variable name="text" select="if (f:is-set('lb.hyphen.remove')) 
                                        then f:remove-eol-hyphens(.) 
                                        else ."/>

        <xsl:variable name="lang" select="f:get-current-lang(.)"/>
        <xsl:variable name="text" select="f:process-text($text, $lang)"/>

        <xsl:copy-of select="if ($lang = 'bo') then f:tweak-tibetan-line-breaks-wbr($text) else $text"/>
    </xsl:template>


    <xsl:function name="f:process-text" as="xs:string">
        <xsl:param name="text" as="xs:string"/>
        <xsl:param name="lang" as="xs:string"/>

        <xsl:variable name="text" select="if (f:is-set('beta.convert') and $lang = 'grc')
                                            then f:beta-to-unicode($text, f:is-set('beta.caseSensitive')) 
                                            else $text"/>
        <!-- <xsl:variable name="text" select="if ($lang = 'bo') 
                                            then f:tweak-tibetan-line-breaks-zwsp($text) 
                                            else $text"/> -->
        <xsl:variable name="text" select="if ($lang != 'xx' and f:is-set('text.curlyApos')) then f:curly-apos($text) else $text"/>
        <xsl:variable name="text" select="if (f:is-set('text.spaceQuotes')) then f:handle-quotes($text) else $text"/>
        <xsl:variable name="text" select="if (f:is-set('text.useEllipses')) then f:handle-ellipses($text) else $text"/>

        <xsl:variable name="text" select="f:no-break-initials($text)"/>

        <xsl:value-of select="$text"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Tweak Tibetan line-breaks (ZWSP).</xd:short>
        <xd:detail><p>Since most browsers do not handle Tibetan line-breaking correctly, we need to help them a 
            little to avoid unacceptable results. To do so, we 1. Insert a zero-width space after tshegs in Tibetan. 
            2. Convert spaces to non-breaking spaces. (High-quality line-breaking will require a dedicated algorithm, 
            this is the best we can do in generic HTML for current browsers.)</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:tweak-tibetan-line-breaks-zwsp" as="xs:string">
        <xsl:param name="text" as="xs:string"/>

        <xsl:variable name="text" as="xs:string" select="replace($text, '&boTsheg;([&boKa;-&boRra;])', '&boTsheg;&zwsp;$1')"/>
        <xsl:variable name="text" as="xs:string" select="replace($text, ' ', '&nbsp;')"/>

        <xsl:value-of select="$text"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Tweak Tibetan line-breaks (WBR).</xd:short>
        <xd:detail><p>Since most browsers do not handle Tibetan line-breaking correctly, we need to help them a 
            little to avoid unacceptable results. To do so, we 1. Insert a &lt;wbr&gt; after tshegs in Tibetan. 
            2. Convert spaces to non-breaking spaces. (High-quality line-breaking will require a dedicated algorithm, 
            this is the best we can do in generic HTML for current browsers.)</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:tweak-tibetan-line-breaks-wbr">
        <xsl:param name="text" as="xs:string"/>

        <xsl:variable name="text" as="xs:string" select="replace($text, ' ', '&nbsp;')"/>
        <xsl:analyze-string select="$text" regex="(&boTsheg;)([&boKa;-&boRra;])">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/><wbr/><xsl:value-of select="regex-group(2)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>

    <xd:doc>
        <xd:short>Remove end-of-line hyphens.</xd:short>
        <xd:detail><p>Remove end-of-line hyphens. This function works when the eol-hyphens are encoded
        following the DFA conventions, that is, <code>lb</code>-elements are placed directly
        at the end of each line, and <code>pb</code>-elements follow these; furthermore, for hyphens
        to be removed, a special character is used (in the case of DTA texts, the not-sign).</p>

        <p>With end-of-line hyphens we have three options. (In the examples below, | stands for the line-break.)</p>

        <ol>
            <li>The hyphen should be removed and any white-space closed up to form a single word (e.g. re-|moved becomes removed).</li>
            <li>The hyphen should stay but white-space closed up to form a word with a hyphen (e.g. well-|known person becomes well-known person).</li>
            <li>The hyphen should stay as well as the white-space, to form a word of which a part is ellided (e.g. three-|or fourfold becomes three- or fourfold).</li>
        </ol>

        <p>This code handles the first three cases. For the last case, you need to take care to keep a space, e.g. three- |or fourfold.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:remove-eol-hyphens" as="xs:string">
        <xsl:param name="node" as="text()"/>

        <!-- Establish the previous and next text nodes, separated by a line-break. Page-breaks and empty text nodes may come in-between, but nothing else. -->

        <xsl:variable name="previous" select="
            ($node/preceding-sibling::node()
                [not(self::pb)]
                [not(self::text()[normalize-space(.) = ''])]
                [1]
                [self::lb])/preceding-sibling::node()[1][self::text()]"/>
        <xsl:variable name="next" select="
            ($node/following-sibling::node()[1][self::lb])/following-sibling::node()
                [not(self::pb)]
                [not(self::text()[normalize-space(.) = ''])]
                [1]
                [self::text()]"/>

        <!-- Strip initial space when preceding line ends with hyphen -->
        <xsl:variable name="result" as="xs:string">
            <xsl:choose>
                <xsl:when test="$previous and (f:ends-with-removable-hyphen($previous) or f:ends-with-hyphen($previous)) and normalize-space($node) = ''">
                    <!-- text-node before lb ended with a (removable) hyphen: remove empty text node -->
                    <xsl:value-of select="''"/>
                </xsl:when>
                <xsl:when test="$previous and (f:ends-with-removable-hyphen($previous) or f:ends-with-hyphen($previous))">
                    <!-- text-node before lb ended with a (removable) hyphen: remove any initial spaces present -->
                    <xsl:value-of select="replace($node, '^\s+', '')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$node"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Strip hyphen at end of line -->
        <xsl:choose>
            <xsl:when test="$next and f:ends-with-removable-hyphen($node)">
                <!-- we have a text-node after the lb: remove the removable hyphen -->
                <!-- <xsl:message expand-text="yes">EOL: {$node}</xsl:message> -->
                <xsl:value-of select="substring($result, 1, string-length($result) - 1)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$result"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xsl:function name="f:ends-with-removable-hyphen" as="xs:boolean">
        <xsl:param name="node" as="text()"/>

        <xsl:sequence select="$node
                      and $node/following-sibling::node()[1][self::lb]
                      and ends-with($node, f:get-setting('lb.removable.hyphen'))"/>
    </xsl:function>

    <xsl:function name="f:ends-with-hyphen" as="xs:boolean">
        <xsl:param name="node" as="text()"/>

        <xsl:sequence select="$node
                      and $node/following-sibling::node()[1][self::lb]
                      and ends-with($node, f:get-setting('lb.hyphen'))"/>
    </xsl:function>


    <xsl:function name="f:no-break-initials" as="xs:string">
        <xsl:param name="text" as="xs:string"/>

        <xsl:variable name="result" as="xs:string*">
            <xsl:analyze-string select="$text" regex="(\p{{Lu}}\p{{M}}?\. ){{2,}}">
                <xsl:matching-substring>
                    <!-- Do not replace the final space -->
                    <xsl:value-of select="replace(replace(., ' ', '&nbsp;'), '&nbsp;$', ' ')"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                  <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>

        <xsl:value-of select="string-join($result, '')"/>
    </xsl:function>


    <xsl:function name="f:curly-apos" as="xs:string">
        <xsl:param name="text" as="xs:string"/>

        <xsl:variable name="text" as="xs:string" select="replace($text, '''', '&rsquo;')"/>

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

        <!-- Four periods become a period followed by an ellipsis. -->
        <xsl:variable name="text" as="xs:string" select="replace($text, '\.\.\.\.', '.&hellip;')"/>
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

    <xsl:template match="emph" mode="#default remove-initial titlePage toc-head">
        <i>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates mode="#current"/>
        </i>
    </xsl:template>

    <!-- Mapped to HTML elements: it = italic; b = bold; sup = superscript; sub = subscript; others handled as CSS class on span element. -->

    <xd:doc>
        <xd:short>Italic text.</xd:short>
        <xd:detail>Italic text, indicated with the <code>@rend</code> attribute value <code>it</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='it' or @rend='italic'] | i | em" mode="#default remove-initial titlePage toc-head">
        <i>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates mode="#current"/>
        </i>
    </xsl:template>

    <xd:doc>
        <xd:short>Bold text.</xd:short>
        <xd:detail>Bold text, indicated with the <code>@rend</code> attribute value <code>b</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='b' or @rend='bold'] | b | strong" mode="#default remove-initial titlePage toc-head">
        <b>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates mode="#current"/>
        </b>
    </xsl:template>

    <xd:doc>
        <xd:short>Bold-italic text.</xd:short>
        <xd:detail>Bold-italic text, indicated with the <code>@rend</code> attribute value <code>bi</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='bi' or @rend='bold-italic'] | bi" mode="#default remove-initial titlePage toc-head">
        <b><i>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates mode="#current"/>
        </i></b>
    </xsl:template>

    <xd:doc>
        <xd:short>Superscript text.</xd:short>
        <xd:detail>Superscript text, indicated with the <code>@rend</code> attribute value <code>sup</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='sup'] | sup" mode="#default remove-initial titlePage toc-head">
        <sup>
            <xsl:apply-templates mode="#current"/>
        </sup>
    </xsl:template>

    <xd:doc>
        <xd:short>Subscript text.</xd:short>
        <xd:detail>Subscript text, indicated with the <code>@rend</code> attribute value <code>sub</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='sub'] | sub" mode="#default remove-initial titlePage toc-head">
        <sub>
            <xsl:apply-templates mode="#current"/>
        </sub>
    </xsl:template>

    <!-- Mapped to defined CSS classes: sc = small caps; asc = all small caps; uc = upper case; ex = letterspaced; rm = roman; tt = typewriter type -->

    <xd:doc>
        <xd:short>Caps and small-caps text.</xd:short>
        <xd:detail>Caps and small-caps text, indicated with the <code>@rend</code> attribute value <code>sc</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='sc'] | sc" mode="#default remove-initial titlePage toc-head">
        <span class="sc">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xd:doc>
        <xd:short>All small-caps text.</xd:short>
        <xd:detail>All small-caps text, indicated with the <code>@rend</code> attribute value <code>asc</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='asc'] | asc" mode="#default remove-initial titlePage toc-head">
        <span class="asc">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xd:doc>
        <xd:short>Uppercase text.</xd:short>
        <xd:detail>Uppercase text, indicated with the <code>@rend</code> attribute value <code>uc</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='uc']" mode="#default remove-initial titlePage toc-head">
        <span class="uc">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xd:doc>
        <xd:short>Letterspaced text.</xd:short>
        <xd:detail>Letterspace (gesperrd) text, indicated with the <code>@rend</code> attribute value <code>ex</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='ex'] | g" mode="#default remove-initial titlePage toc-head">
        <span class="ex">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates mode="#current"/>
         </span>
    </xsl:template>

    <xd:doc>
        <xd:short>Upright text.</xd:short>
        <xd:detail>Upright (in an italic context) text, indicated with the <code>@rend</code> attribute value <code>rm</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='rm'] | rm" mode="#default remove-initial titlePage toc-head">
        <span class="rm">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xd:doc>
        <xd:short>Type-writer text.</xd:short>
        <xd:detail>Type-writer (monospaced) text, indicated with the <code>@rend</code> attribute value <code>tt</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='tt'] | tt" mode="#default remove-initial titlePage toc-head">
        <span class="tt">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xd:doc>
        <xd:short>Underlined text.</xd:short>
        <xd:detail>Underlined text, indicated with the <code>@rend</code> attribute value <code>underline</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='underline'] | u" mode="#default remove-initial titlePage toc-head">
        <span class="underline">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xd:doc>
        <xd:short>Overlined text.</xd:short>
        <xd:detail>Overlined text, indicated with the <code>@rend</code> attribute value <code>overline</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='overline']" mode="#default remove-initial titlePage toc-head">
        <span class="overline">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xd:doc>
        <xd:short>Text spanned with a wide tilde.</xd:short>
        <xd:detail>Text spanned with a wide tilde, indicated with the <code>@rend</code> attribute value <code>overtilde</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="hi[@rend='overtilde']" mode="#default remove-initial titlePage toc-head">
        <span class="overtilde">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xd:doc>
        <xd:short>Highlighted text.</xd:short>
        <xd:detail>Highlighted text with other values for the <code>@rend</code> attribute.</xd:detail>
    </xd:doc>

    <xsl:template match="hi" mode="#default remove-initial titlePage toc-head">
        <xsl:choose>
            <!-- Does this hi contain an explicit rendering or style value -->
            <xsl:when test="contains(@rend, '(') or @style or @rendition or f:extract-class-from-rend-ladder(@rend, 'hi') != ''">
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
        <xd:short>Foreign phrases.</xd:short>
        <xd:detail>Foreign phrases are not styled by default, but we do set the language (and script) on them.
        See <a href="https://en.wikipedia.org/wiki/ISO_15924">ISO-15924</a> for script codes.</xd:detail>
    </xd:doc>

    <xsl:template match="foreign" mode="#default remove-initial titlePage toc-head">
        <span>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:variable name="script" select="f:map-language-to-script(@lang)"/>
            <xsl:copy-of select="if ($script) 
                                 then f:set-class-attribute-with(., $script) 
                                 else f:set-class-attribute(.)"/>
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>


    <xsl:function name="f:map-language-to-script" as="xs:string?">
        <xsl:param name="lang" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$lang=('ar')">arab</xsl:when>
            <xsl:when test="$lang=('fa', 'ps', 'ur')">aran</xsl:when>
            <xsl:when test="$lang=('as', 'bn')">beng</xsl:when>
            <xsl:when test="$lang=('be', 'bg', 'mk', 'ru', 'rue', 'sr', 'uk')">cyrl</xsl:when>
            <xsl:when test="$lang=('hi', 'ma', 'sa')">deva</xsl:when>
            <xsl:when test="$lang=('el', 'grc')">grek</xsl:when>
            <xsl:when test="$lang=('he', 'yi')">hebr</xsl:when>
            <xsl:when test="$lang=('syc')">syrc</xsl:when>
            <xsl:when test="$lang=('tm')">taml</xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:function>


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

    <xsl:template match="corr" mode="#default titlePage">
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
            <xsl:when test="@resp = 'm' or @resp = 'p' or not(f:is-set('useMouseOverPopups'))">
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
            <!-- An empty span will be purged by some HTML tools; however, an anchor element is not allowed inside other anchors. -->
            <xsl:when test="not($corr) or $corr = ''">
                <span id="{f:generate-id(.)}"/>
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
    <!-- Regularization -->

    <xd:doc>
        <xd:short>Handle Regularisations.</xd:short>
        <xd:detail>Regularisation of spelling or not corrections, but editorial interventions, that
        might help to make a text more readable or searchable.</xd:detail>
    </xd:doc>

    <xsl:template match="reg" mode="#default titlePage">
        <xsl:apply-templates/>
    </xsl:template>

    <!--====================================================================-->
    <!-- Gaps and spaces -->

    <xd:doc>
        <xd:short>Handle a gap.</xd:short>
        <xd:detail><p>The <code>gap</code> element indicated that some text has been omitted. The
        <code>@reason</code> attribute can be used to give a reason; the <code>@unit</code> and <code>@extent</code>
        attributes can be used to give an estimate of the size of the omitted material.</p>

        <p>In HTML, a gap is rendered with the localized words [<i>missing text</i>], and a pop-up giving the reason
        and extent.</p></xd:detail>
    </xd:doc>

    <xsl:template match="gap">
        <xsl:variable name="params" select="map{'extent': @extent, 'unit': @unit, 'reason': @reason}"/>
        <span class="gap">
            <xsl:if test="f:is-set('useMouseOverPopups')">
                <xsl:attribute name="title" select="if (@extent)
                                                    then f:format-message('msgMissingTextWithExtentReason', $params)
                                                    else f:format-message('msgMissingTextWithReason', $params)"/>
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


    <xsl:template match="abbr" mode="#default titlePage">
        <xsl:call-template name="handle-abbreviation">
            <xsl:with-param name="abbr" select="./node()"/>
            <xsl:with-param name="expan" select="@expan"/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="choice[abbr]">
        <xsl:call-template name="handle-abbreviation">
            <xsl:with-param name="abbr" select="abbr/node()"/>
            <xsl:with-param name="expan" select="expan/node()"/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="handle-abbreviation">
        <xsl:param name="abbr" xs:as="node()*"/>
        <xsl:param name="expan" xs:as="node()*"/>

        <xsl:variable name="expanString" as="xs:string?">
            <xsl:for-each select="$expan">
                <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="expanString" select="if (not($expanString) or $expanString = '') then f:find-expansion($abbr[1]) else $expanString"/>

        <abbr>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:if test="@type">
                <xsl:attribute name="class" select="@type"/>
            </xsl:if>
            <xsl:if test="f:is-set('useMouseOverPopups')">
                <xsl:if test="$expanString != ''">
                    <xsl:attribute name="title">
                        <xsl:value-of select="$expanString"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates select="$abbr"/>
        </abbr>
    </xsl:template>


    <xd:doc>
        <xd:short>Find the expansion of an abbreviation.</xd:short>
        <xd:detail>Find the expansion of an abbreviation, by first looking for the value of the <code>@expan</code> attribute
        on the abbreviation itself, or, if that is not available, look for other occurrences of the same abbreviation, that
        might provide the expansion.</xd:detail>
    </xd:doc>

    <xsl:function name="f:find-expansion" as="xs:string">
        <xsl:param name="abbr" as="node()"/>

        <xsl:value-of select="if ($abbr/@expan != '')
            then $abbr/@expan
            else if (root($abbr)//abbr[. = $abbr and ./@expan != ''])
                 then (root($abbr)//abbr[. = $abbr and ./@expan != '']/@expan)[1]
                 else if (root($abbr)//choice[abbr = $abbr and expan != ''])
                      then (root($abbr)//choice[abbr = $abbr and expan != '']/expan)[1]
                      else 'XX'"/>
    </xsl:function>


    <!--====================================================================-->
    <!-- Numbers -->

    <xsl:template match="num">
        <span class="num">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:if test="f:is-set('useMouseOverPopups')">
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
            <xsl:if test="f:is-set('useMouseOverPopups')">
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
        adding transcriptions to Greek or Cyrillic fragments.</xd:detail>
    </xd:doc>

    <xsl:template match="choice[reg/@type='trans']">
        <span class="trans">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:if test="f:is-set('useMouseOverPopups')">
                <xsl:attribute name="title">
                    <xsl:apply-templates select="reg" mode="remove-nested-choice"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="orig"/>
        </span>
    </xsl:template>


    <xd:doc>
        <xd:short>Remove nested choice elements from regularized text.</xd:short>
    </xd:doc>

    <xsl:template match="choice[corr]" mode="remove-nested-choice">
        <xsl:apply-templates select="corr" mode="remove-nested-choice"/>
    </xsl:template>

    <xsl:template match="choice[abbr]" mode="remove-nested-choice">
        <xsl:apply-templates select="abbr" mode="remove-nested-choice"/>
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
            <xsl:when test="f:is-set('useRegularizedUnits')">
                <span class="measure">
                    <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                    <xsl:if test="f:is-set('useMouseOverPopups')">
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
                    <xsl:if test="f:is-set('useMouseOverPopups')">
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
            <xsl:if test="f:is-set('useMouseOverPopups')">
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
        audio with the text and for indicating texts repeated by ditto-marks in tables, etc.</xd:detail>
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
        full text depending on the value of the setting <code>ditto.enable</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="seg[@copyOf]">
        <span class="seg">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:variable name="copyOf" select="if (starts-with(@copyOf, '#')) then substring(@copyOf, 2) else @copyOf"/>
            <xsl:variable name="source" select="$root//seg[@id = $copyOf]"/>
            <xsl:choose>
                <xsl:when test="not($source)">
                    <xsl:copy-of select="f:log-error('Segment with @id=''{1}'' not found', ($copyOf))"/>
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:when test="f:is-set('ditto.enable') and f:determine-ditto-repeat(.) = 'segment'">
                    <span class="ditto">
                        <span class="s">
                            <xsl:apply-templates select="$source/*|$source/text()"/>
                        </span>
                        <span class="d">
                            <span class="i">
                                <xsl:copy-of select="f:convert-markdown(f:determine-ditto-mark(.))"/>
                            </span>
                        </span>
                    </span>
                </xsl:when>
                <xsl:when test="f:is-set('ditto.enable')">
                    <!-- TODO: Handle the case where this is in a doubled-up table or list, and the row appears on the top line -->
                    <xsl:variable name="source" select="if ($source//corr) then f:strip-corr-elements($source) else $source"/>
                    <xsl:apply-templates select="$source" mode="ditto">
                        <xsl:with-param name="context" select="." tunnel="yes"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="$source"/>
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
        <xsl:copy-of select="f:log-warning('Deprecated element ditto used (please use seg).', ())"/>
        <xsl:choose>
            <xsl:when test="f:is-set('ditto.enable') and f:determine-ditto-repeat(.) = 'segment'">
                <span class="ditto">
                    <span class="s">
                        <xsl:apply-templates/>
                    </span>
                    <span class="d">
                        <span class="i">
                            <xsl:copy-of select="f:convert-markdown(f:determine-ditto-mark(.))"/>
                        </span>
                    </span>
                </span>
            </xsl:when>
            <xsl:when test="f:is-set('ditto.enable')">
                <xsl:variable name="node" select="if (.//corr) then f:strip-corr-elements(.) else ."/>
                <xsl:apply-templates select="$node" mode="ditto">
                    <xsl:with-param name="context" select="." as="node()" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template mode="ditto" match="text()">
        <xsl:param name="context" as="node()" tunnel="yes"/>
        <xsl:copy-of select="f:generate-ditto-marks(., $context)"/>
    </xsl:template>


    <xsl:function name="f:generate-ditto-marks">
        <xsl:param name="node" as="node()*"/>
        <xsl:param name="context" as="node()"/>

        <!-- Split the text-content of the segment on space boundaries -->
        <xsl:for-each select="tokenize($node, '\s+')">
            <xsl:choose>
                <xsl:when test=". = ''">
                    <xsl:copy-of select="f:log-warning('Ignoring empty node while generating ditto marks.', ())"/>
                </xsl:when>
                <xsl:when test="matches(., '^[.,:;!]$')">
                    <xsl:copy-of select="f:log-warning('Stand-alone punctuation mark ({1}) in ditto (will not use ditto mark).', (.))"/>
                    <span class="ditto">
                        <span class="s"><xsl:value-of select="."/></span>
                    </span>
                </xsl:when>
                <xsl:otherwise>
                    <span class="ditto">
                        <span class="s">
                            <!-- Handle most common in-line style elements. -->
                            <!-- TODO: replace with straightforward processing of the respective elements in the ditto-mode. -->
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
                                <xsl:when test="$node/parent::hi[@rend='ex']">
                                    <span class="ex"><xsl:value-of select="."/></span>
                                </xsl:when>
                                <xsl:when test="$node/parent::hi[@rend='bi']">
                                    <b><i><xsl:value-of select="."/></i></b>
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
                            <span class="d">
                                <span class="i">
                                    <xsl:copy-of select="f:convert-markdown(f:determine-ditto-mark($context))"/>
                                </span>
                            </span>
                        </xsl:if>
                    </span>
                    <!-- Don't forget to reinsert the space we split on -->
                    <xsl:text> </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>


    <xsl:function name="f:determine-ditto-repeat" as="xs:string">
        <xsl:param name="node" as="node()"/>

        <xsl:value-of select="if ($node/ancestor-or-self::ditto/@repeat)
            then $node/ancestor-or-self::ditto/@repeat
            else if ($node/ancestor-or-self::*[f:has-rend-value(./@rend, 'ditto-repeat')])
                 then f:rend-value($node/ancestor-or-self::*[f:has-rend-value(./@rend, 'ditto-repeat')][1]/@rend, 'ditto-repeat')
                 else f:get-setting('ditto.repeat')"/>
    </xsl:function>


    <xsl:function name="f:determine-ditto-mark" as="xs:string">
        <xsl:param name="node" as="node()"/>

        <xsl:value-of select="if ($node/ancestor-or-self::ditto/@mark)
            then $node/ancestor-or-self::ditto/@mark
            else if ($node/ancestor-or-self::*[f:has-rend-value(./@rend, 'ditto-mark')])
                 then f:rend-value($node/ancestor-or-self::*[f:has-rend-value(./@rend, 'ditto-mark')][1]/@rend, 'ditto-mark')
                 else f:get-setting('ditto.mark')"/>
    </xsl:function>


    <xsl:function name="f:strip-corr-elements">
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
