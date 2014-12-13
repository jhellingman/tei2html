<!DOCTYPE xsl:stylesheet [

    <!ENTITY tab        "&#x09;">
    <!ENTITY lf         "&#x0A;">
    <!ENTITY cr         "&#x0D;">
    <!ENTITY deg        "&#176;">
    <!ENTITY ldquo      "&#x201C;">
    <!ENTITY lsquo      "&#x2018;">
    <!ENTITY rsquo      "&#x2019;">
    <!ENTITY nbsp       "&#160;">
    <!ENTITY mdash      "&#x2014;">
    <!ENTITY prime      "&#x2032;">
    <!ENTITY Prime      "&#x2033;">
    <!ENTITY plusmn     "&#x00B1;">
    <!ENTITY frac14     "&#x00BC;">
    <!ENTITY frac12     "&#x00BD;">
    <!ENTITY frac34     "&#x00BE;">
    <!ENTITY asterism   "&#x2042;">

]>

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="f xd xs"
    version="2.0"
    >

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to format block-level elements, to be imported in tei2html.xsl.</xd:short>
        <xd:detail>This stylesheet formats block-level elements from TEI.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <!--====================================================================-->
    <!-- Page Breaks -->

    <xd:doc>
        <xd:short>Handle a page-break.</xd:short>
        <xd:detail>Handle a page-break. Generate an HTML anchor with an <code>id</code> attribute.
        Depending on the element we find the pb in, we may need to wrap the generated content in
        a wrapping HTML p-element.</xd:detail>
    </xd:doc>

    <xsl:template match="pb">
        <xsl:choose>
            <!-- In HTML, we do not allow a span element at the top-level. -->
            <xsl:when test="parent::front | parent::body | parent::back | parent::div1 | parent::div2 | parent::div3 | parent::div4 | parent::div5">
                <p><xsl:call-template name="pb"/></p>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="pb"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate an anchor for a page-break.</xd:short>
        <xd:detail>Generate a marginal note for a page-break if the page-break has a number (<code>@n</code>-attribute).
        Otherwise, just generate an anchor element.</xd:detail>
    </xd:doc>

    <xsl:template name="pb">
        <xsl:choose>
            <xsl:when test="@n and f:isSet('showPageNumbers')">
                <xsl:call-template name="pb-margin"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="pb-anchor"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="pb-margin">
        <span class="pagenum">
            <xsl:text>[</xsl:text>
            <a>
                <xsl:call-template name="generate-id-attribute"/>
                <xsl:call-template name="generate-href-attribute"/>
                <xsl:value-of select="@n"/>
            </a>
            <xsl:text>]</xsl:text>
            <xsl:if test="f:isSet('generateFacsimile') and ./@facs">
                <xsl:text>&nbsp;</xsl:text>
                <xsl:choose>
                    <xsl:when test="starts-with(@facs, '#')">
                        <xsl:variable name="id" select="substring(@facs, 2)"/>
                        <xsl:variable name="graphic" select="//graphic[@id = $id]"/>
                        <xsl:if test="$graphic">
                            <a href="{f:facsimile-path()}/{f:facsimile-filename($graphic)}" class="facslink" title="{f:message('msgPageImage')}"></a>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <a href="{f:facsimile-path()}/{f:facsimile-filename(.)}" class="facslink" title="{f:message('msgPageImage')}"></a>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
         </span>
    </xsl:template>

    <xd:doc>
        <xd:short>Generate anchor for <code>pb</code>-element.</xd:short>
        <xd:detail>Generate an anchors for a <code>pb</code>-element. Since, in HTML, we do not
        allow a span element at the top-level, so wrap into a <code>p</code>-element, unless we are in a block
        element already.</xd:detail>
    </xd:doc>

    <xsl:template name="pb-anchor">
        <xsl:choose>
            <xsl:when test="ancestor::p | ancestor::list | ancestor::table | ancestor::l">
                <xsl:call-template name="generate-anchor"/>
            </xsl:when>
            <xsl:otherwise>
                <p><xsl:call-template name="generate-anchor"/></p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!--====================================================================-->
    <!-- Thematic Breaks -->

    <xd:doc>
        <xd:short>Handle a milestone.</xd:short>
        <xd:detail>Handle a document milestone. This is mostly used to encode thematic breaks. Generates
        slightly different outputs, depending on the <code>@type</code> and <code>@rend</code>-attributes.</xd:detail>
    </xd:doc>

    <xsl:template match="milestone[@unit='theme' or @unit='tb']">
        <xsl:call-template name="closepar"/>
        <xsl:choose>
            <xsl:when test="contains(@rend, 'dots')">
                <xsl:call-template name="generate-tb-par">
                    <xsl:with-param name="string" select="'. . . . . . . . . . . . . . . . . . . . .'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains(@rend, 'stars')">
                <xsl:call-template name="generate-tb-par">
                    <xsl:with-param name="string" select="'*&nbsp;&nbsp;&nbsp;*&nbsp;&nbsp;&nbsp;*'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains(@rend, 'star')">
                <xsl:call-template name="generate-tb-par">
                    <xsl:with-param name="string" select="'*'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains(@rend, 'asterism')">
                <xsl:call-template name="generate-tb-par">
                    <xsl:with-param name="string" select="'&asterism;'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains(@rend, 'space')">
                <xsl:call-template name="generate-tb-par">
                    <xsl:with-param name="string" select="''"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <hr class="tb">
                    <xsl:call-template name="generate-id-attribute"/>
                </hr>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>


    <xsl:template name="generate-tb-par">
        <xsl:param name="string" as="xs:string"/>
        <xsl:element name="{$p.element}">
            <xsl:attribute name="class">tb</xsl:attribute>
            <xsl:call-template name="generate-id-attribute"/><xsl:value-of select="$string"/>
        </xsl:element>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle a milestone-element.</xd:short>
        <xd:detail>Handle a milestone-element. Just generate a milestone if the <code>@type</code> and
        <code>@rend</code>-attributes are missing.</xd:detail>
    </xd:doc>

    <xsl:template match="milestone">
        <xsl:call-template name="generate-anchor"/>
    </xsl:template>


    <!--====================================================================-->
    <!-- Arguments -->

    <xd:doc>
        <xd:short>Handle an argument.</xd:short>
        <xd:detail>Handle an argument (a short summary of contents at the start of a chapter).</xd:detail>
    </xd:doc>

    <xsl:template match="argument">
        <div class="argument">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <!--====================================================================-->
    <!-- Epigraphs -->

    <xd:doc>
        <xd:short>Handle an epigraph.</xd:short>
        <xd:detail>Handle an epigraph (a short citation at the start of a chapter or book).</xd:detail>
    </xd:doc>

    <xsl:template match="epigraph">
        <div class="epigraph">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle an epigraph on the title page.</xd:short>
        <xd:detail>When an epigraph appears on the title page, do not to use a <code>div</code> element to enclose it.</xd:detail>
    </xd:doc>

    <xsl:template match="epigraph[parent::titlePage]">
        <span class="epigraph">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- Trailers -->

    <xd:doc>
        <xd:short>Handle an trailer.</xd:short>
        <xd:detail>Handle an trailer (a short phrase at the end of a chapter or book).</xd:detail>
    </xd:doc>

    <xsl:template match="trailer">
        <xsl:element name="{$p.element}">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:attribute name="class">trailer <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>


    <!--====================================================================-->
    <!-- Blockquotes -->

    <xd:doc>
        <xd:short>Handle an block-quote.</xd:short>
        <xd:detail>Handle a block-quote (a quote normally set off from the text by some extra space and identation).</xd:detail>
    </xd:doc>

    <xsl:template match="q">
        <xsl:call-template name="closepar"/>
        <div>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:variable name="class">
                <xsl:choose>
                    <xsl:when test="@rend='block'"><xsl:text>blockquote </xsl:text></xsl:when>
                    <xsl:otherwise><xsl:text>q </xsl:text></xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="generate-rend-class-name-if-needed"/>
            </xsl:variable>
            <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>
            <xsl:apply-templates/>
        </div>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle an quote in a citation.</xd:short>
        <xd:detail>Quotes inside a <code>cit</code> element should not be output as a <code>div</code> element in HTML.</xd:detail>
    </xd:doc>

    <xsl:template match="q[parent::cit]">
        <span>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:variable name="class">
                <xsl:text>epigraph </xsl:text>
                <xsl:call-template name="generate-rend-class-name-if-needed"/>
            </xsl:variable>
            <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle <code>q</code> and <code>lg</code> elements within a footnote.</xd:short>
        <xd:detail>Quotes and lines of verse within a footnote are (due to the required structure of a TEI document), nested
        within a <code>text/body/div1</code> structure. In the generated output, we need to ignore this
        superflous structure.</xd:detail>
    </xd:doc>

    <xsl:template match="note[@type='foot' or not(@type)]//q/text">
        <div class="nestedtext">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="note[@type='foot' or not(@type)]//q/text/body">
        <div class="nestedbody">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="note[@type='foot' or not(@type)]//q/text/body/div1">
        <div class="nesteddiv1">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <!--====================================================================-->
    <!-- Letters, with openers, closers, etc. -->


    <xd:doc>
        <xd:short>Handle a cited letter.</xd:short>
        <xd:detail>Handle a cited letter. This is a non-TEI shortcut for <code>&lt;q&gt;&lt;text&gt;&lt;body&gt;&lt;div1 type="Letter"&gt;</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="letter">
        <xsl:call-template name="closepar"/>
        <div class="blockquote letter">
            <xsl:call-template name="set-lang-id-attributes"/>
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


    <xd:doc>
        <xd:short>Handle a paragraph.</xd:short>
        <xd:detail>Handle a paragraph. All action is delegated to a named template.</xd:detail>
    </xd:doc>

    <xsl:template match="p">
        <xsl:call-template name="handle-paragraph"/>
    </xsl:template>


    <xsl:template name="handle-paragraph">
        <xsl:if test="not(contains(@rend, 'display(none)'))">
            <xsl:element name="{$p.element}">
                <xsl:call-template name="set-lang-id-attributes"/>

                <xsl:variable name="class">
                    <xsl:text>par </xsl:text>
                    <!-- in a few cases, we have paragraphs in quoted material in footnotes, which need to be set in a smaller font: apply the proper class for that. -->
                    <xsl:if test="ancestor::note[@place='foot' or @place='undefined' or not(@place)]">footnote<xsl:text> </xsl:text></xsl:if>
                    <!-- propagate the @type attribute to the class -->
                    <xsl:if test="@type"><xsl:value-of select="@type"/><xsl:text> </xsl:text></xsl:if>
                    <xsl:if test="f:isFirstParagraph(.)">first </xsl:if>
                    <xsl:value-of select="f:hangingPunctuationClass(.)"/><xsl:text> </xsl:text>
                    <xsl:call-template name="generate-rend-class-name-if-needed"/>
                </xsl:variable>

                <xsl:if test="normalize-space($class) != ''">
                    <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>
                </xsl:if>

                <xsl:if test="@n and f:isSet('showParagraphNumbers')">
                    <span class="parnum"><xsl:value-of select="@n"/>.<xsl:text> </xsl:text></span>
                </xsl:if>

                <xsl:apply-templates/>
                <!--
                    <xsl:choose>
                        <xsl:when test="f:startsWithPunctuation(.)">
                            <xsl:call-template name="hangOpenPunctuation"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates/>
                        </xsl:otherwise>
                    </xsl:choose>
                -->
            </xsl:element>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Determine whether a paragraph is first.</xd:short>
        <xd:detail>Determine whether a paragraph is first in a division. This can be used to determine whether
        extra or no-indentation is required in some cases.</xd:detail>
    </xd:doc>

    <xsl:function name="f:isFirstParagraph" as="xs:boolean">
        <xsl:param name="node" as="node()"/>

        <xsl:variable name="preceding">
            <xsl:value-of select="name($node/preceding-sibling::*[1])"/>
        </xsl:variable>

        <xsl:value-of select="count($node/preceding-sibling::*) = 0
            or $preceding = 'head'
            or $preceding = 'byline'
            or $preceding = 'lg'
            or $preceding = 'tb'
            or $preceding = 'epigraph'
            or $preceding = 'argument'
            or $preceding = 'opener'"/>
    </xsl:function>

    <!-- Hanging punctuation -->

    <xd:doc>
        <xd:short>Determine a class for a paragraph if it starts with quotation marks.</xd:short>
        <xd:detail>Determine a class for a paragraph if it starts with quotation marks. This can be used
        to &lsquo;hang&rsquo; the quotation marks using CSS.</xd:detail>
    </xd:doc>

    <xsl:function name="f:hangingPunctuationClass" as="xs:string">
        <xsl:param name="text" as="xs:string"/>

        <xsl:choose>
            <xsl:when test="not(f:isSet('useHangingPunctuation'))"><xsl:text> </xsl:text></xsl:when>

            <!-- Longer sequences should go first! -->
            <xsl:when test="starts-with($text, '&ldquo;&lsquo;')">indent-hang-large</xsl:when>
            <xsl:when test="starts-with($text, '&lsquo;&ldquo;')">indent-hang-large</xsl:when>

            <xsl:when test="starts-with($text, '&ldquo;')">indent-hang-medium</xsl:when>
            <xsl:when test="starts-with($text, '&lsquo;')">indent-hang-small</xsl:when>
            <xsl:when test="starts-with($text, '&rsquo;')">indent-hang-small</xsl:when>

            <xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xsl:function name="f:startsWithPunctuation" as="xs:boolean">
        <xsl:param name="node" as="node()"/>

        <xsl:variable name="first" select="$node/(*|text())[1]"/>

        <!-- First child node should be text node -->
        <xsl:value-of select="not(name($first)) and matches($first, '^[&ldquo;&lsquo;&rsquo;]')"/>
    </xsl:function>


    <xsl:template name="hangOpenPunctuation">
        <!-- First child node is a text node that starts with punctuation -->
        <xsl:variable name="first" select="text()[1]"/>

        <xsl:analyze-string select="$first" regex="^[&ldquo;&lsquo;&rsquo;]+">
            <xsl:matching-substring>
                <span class="hanging-punctuation-start">
                    <xsl:value-of select="." />
                </span>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="." />
            </xsl:non-matching-substring>
        </xsl:analyze-string>

        <!-- process remainder of the current node in the normal fashion. -->
        <xsl:apply-templates select="*|text()[position() > 1]"/>
    </xsl:template>


    <!--====================================================================-->
    <!-- Decorative Initials -->

    <xd:doc>
        <xd:short>Start a paragraph with a decorative initial.</xd:short>
        <xd:detail>
            <p>Start a paragraph with a decorative initial. Decorative initials are encoded
            within the <code>rend</code> attribute on the paragraph level, using the value
            <code>initial-image()</code>.</p>

            <p>To properly show an initial in HTML that may stick over the text, we need
            to use a number of tricks in CSS.</p>

            <ol>
                <li>We set the initial as background picture on the paragraph.</li>
                <li>We create a small div which we let float to the left, to give the initial
                the space it needs.</li>
                <li>We set the padding-top to a value such that the initial actually appears
                to stick over the paragraph.</li>
                <li>We set the initial as background picture to the float, such that if the
                paragraph is to small to contain the entire initial, the float will. We
                need to take care to adjust the background position to match the
                padding-top, such that the two background images will align exactly.</li>
                <li>We need to remove the initial letter from the paragraph, and render it in
                the float in white, such that it re-appears when no CSS is available.</li>
                <li>We need to remove opening quotation marks when they appear before
                the initial letter.</li>
            </ol>

            <p>The following rendition-ladder values are used in this process:</p>

            <table>
                <tr><td>initial-image</td><td>Name of the image file to use as initial.</td></tr>
                <tr><td>initial-width</td><td>The width to reserve for the initial.</td></tr>
                <tr><td>initial-height</td><td>The height to reserve for the initial.</td></tr>
                <tr><td>initial-offset</td><td>The distance the initial will stick out above the paragraph.</td></tr>
            </table>

            <p>In some rendering engines, these tricks do not yield the desired results,
            so we fall-back to a more robust method, using an floating image.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="p[contains(@rend, 'initial-image')]">
        <xsl:choose>
            <xsl:when test="$optionPrinceMarkup = 'Yes' or $outputformat = 'epub'">
                <xsl:call-template name="initial-image-with-float"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="initial-image-with-css"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="initial-image-with-css">
        <xsl:element name="{$p.element}">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:attribute name="class">par <xsl:call-template name="generate-rend-class-name"/></xsl:attribute>
            <span>
                <xsl:attribute name="class"><xsl:call-template name="generate-rend-class-name"/>init</xsl:attribute>
                <xsl:choose>
                    <xsl:when test="substring(.,1,1) = '&ldquo;' or substring(.,1,1) = '&lsquo;' or substring(.,1,1) = '&rsquo;'">
                        <xsl:value-of select="substring(.,1,2)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring(.,1,1)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </span>
            <xsl:apply-templates mode="eat-initial"/>
        </xsl:element>
    </xsl:template>


    <xsl:template name="initial-image-with-float">
        <div class="figure floatLeft">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:call-template name="insertimage2">
                <xsl:with-param name="filename" select="substring-before(substring-after(@rend, 'initial-image('), ')')"/>
            </xsl:call-template>
        </div>
        <xsl:element name="{$p.element}">
            <xsl:attribute name="class">par first</xsl:attribute>
            <xsl:apply-templates mode="eat-initial"/>
        </xsl:element>
    </xsl:template>


    <xd:doc mode="css">
        <xd:short>Mode to generate CSS.</xd:short>
    </xd:doc>

    <xsl:template match="p[contains(@rend, 'initial-image')]" mode="css">
        <xsl:if test="generate-id() = generate-id(key('rend', concat(name(), ':', @rend))[1])">

            <xsl:variable name="properties"><xsl:call-template name="translate-rend-attribute"/></xsl:variable>

.<xsl:call-template name="generate-rend-class-name"/>
{
    background: url(<xsl:value-of select="substring-before(substring-after(@rend, 'initial-image('), ')')"/>) no-repeat top left;
    <xsl:if test="contains(@rend, 'initial-offset(')">
        padding-top: <xsl:value-of select="substring-before(substring-after(@rend, 'initial-offset('), ')')"/>;
    </xsl:if>

    <xsl:if test="normalize-space($properties) != ''">
        <xsl:value-of select="normalize-space($properties)"/>
    </xsl:if>
}

.<xsl:call-template name="generate-rend-class-name"/>init
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

        </xsl:if>
        <xsl:apply-templates mode="css"/>
    </xsl:template>


    <xd:doc mode="css-handheld">
        <xd:short>Mode to generate CSS for hand-held devices.</xd:short>
    </xd:doc>

    <!-- Override decorative initials for handheld devices. -->
    <xsl:template match="p[contains(@rend, 'initial-image')]" mode="css-handheld">
        <xsl:if test="generate-id() = generate-id(key('rend', concat(name(), ':', @rend))[1])">

.<xsl:call-template name="generate-rend-class-name"/>
{
    background-image: none;
    padding-top: 0;
}

.<xsl:call-template name="generate-rend-class-name"/>init
{
    float: none;
    width: auto;
    height: auto;
    background-image: none;
    text-align: right;
    color: inherit;
    font-size: inherit;
}

        </xsl:if>
        <xsl:apply-templates mode="css-handheld"/>
    </xsl:template>


    <xd:doc mode="eat-initial">
        <xd:short>Mode to remove the first letter (and any preceding quotation marks) from a paragraph.</xd:short>
    </xd:doc>

    <!-- We need to adjust the text() matching template to remove the first character from the paragraph -->
    <xsl:template match="text()" mode="eat-initial">
        <xsl:choose>
            <xsl:when test="position() = 1 and (substring(.,1,1) = '&ldquo;' or substring(.,1,1) = '&lsquo;' or substring(.,1,1) = '&rsquo;')">
                <xsl:value-of select="substring(.,3)"/>
            </xsl:when>
            <xsl:when test="position() = 1">
                <xsl:value-of select="substring(.,2)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="*" mode="eat-initial">
        <xsl:choose>
            <xsl:when test="position() > 1">
                <xsl:apply-templates select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="eat-initial"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc mode="eat-initial">
        <xd:short>Use a simple drop-cap at the start of a paragraph.</xd:short>
        <xd:detail>Use a simple drop-cap at the start of a paragraph. Provide a unique class name for the drop-cap, as well as a generic one.
        Some CSS implementations do not handle the <code>:first-letter</code> psuedo-selector correctly, so we provide a span for this.</xd:detail>
    </xd:doc>

    <xsl:template match="p[contains(@rend, 'dropcap(')]">
        <xsl:element name="{$p.element}">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:attribute name="class">par <xsl:call-template name="generate-rend-class-name"/></xsl:attribute>
            <span>
                <xsl:attribute name="class"><xsl:call-template name="generate-rend-class-name"/>dc initdropcap</xsl:attribute>
                <xsl:choose>
                    <!-- Handle opening quotation marks and apostrophes as part of the drop cap -->
                    <xsl:when test="substring(.,1,1) = '&ldquo;' or substring(.,1,1) = '&lsquo;' or substring(.,1,1) = '&rsquo;'">
                        <xsl:value-of select="substring(.,1,2)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring(.,1,1)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </span>
            <span>
                <xsl:attribute name="class"><xsl:call-template name="generate-rend-class-name"/>adc afterdropcap</xsl:attribute>
                <xsl:apply-templates mode="eat-initial"/>
            </span>
        </xsl:element>
    </xsl:template>


    <xd:doc mode="eat-initial">
        <xd:short>Generate CSS for drop-cap.</xd:short>
        <xd:detail>Generate CSS for drop-cap. Note that the exact size to be used for a drop-cap depends on the specific
        font being used, and the number of lines desired to be occupied by the drop-cap. This needs to be tweaked when the
        choice for a font, font-size, and line-spacing has been made.</xd:detail>
    </xd:doc>

    <xsl:template match="p[contains(@rend, 'dropcap(')]" mode="css">

        <xsl:variable name="properties"><xsl:call-template name="translate-rend-attribute"/></xsl:variable>

.<xsl:call-template name="generate-rend-class-name"/>
{
    text-indent: 0;

    <xsl:if test="normalize-space($properties) != ''">
        <xsl:value-of select="normalize-space($properties)"/>
    </xsl:if>
}

.<xsl:call-template name="generate-rend-class-name"/>dc
{
    float: left;
    <xsl:if test="contains(@rend, 'dropcap-offset(')">
        padding-top: <xsl:value-of select="substring-before(substring-after(@rend, 'dropcap-offset('), ')')"/>;
    </xsl:if>
    font-size: <xsl:value-of select="substring-before(substring-after(@rend, 'dropcap('), ')')"/>;
    margin-left: 0;
    margin-bottom: 5px;
    margin-right: 3px;
}

.<xsl:call-template name="generate-rend-class-name"/>adc
{
    /* empty */
}

    </xsl:template>


</xsl:stylesheet>