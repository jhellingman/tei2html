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
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="f xd"
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
        <xd:detail>Generate an anchor for a page-break if the page-break has a number (<code>@n</code>-attribute). Otherwise,
        just generate an anchor element.</xd:detail>
    </xd:doc>

    <xsl:template name="pb">
        <xsl:choose>
            <xsl:when test="@n">
                <span class="pagenum">
                    <xsl:text>[</xsl:text>
                    <a>
                        <xsl:call-template name="generate-id-attribute"/>
                        <xsl:call-template name="generate-href-attribute"/>
                        <xsl:value-of select="@n"/>
                    </a>
                    <xsl:text>]</xsl:text>
                    <xsl:if test="$optionGenerateFacsimile = 'Yes' and ./@facs">
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
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="generate-anchor"/>
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
                <p class="tb"><xsl:call-template name="generate-id-attribute"/>. . . . . . . . . . . . . . . . . . . . .</p>
            </xsl:when>
            <xsl:when test="contains(@rend, 'stars')">
                <p class="tb"><xsl:call-template name="generate-id-attribute"/>*&nbsp;&nbsp;&nbsp;*&nbsp;&nbsp;&nbsp;*</p>
            </xsl:when>
            <xsl:when test="contains(@rend, 'star')">
                <p class="tb"><xsl:call-template name="generate-id-attribute"/>*</p>
            </xsl:when>
            <xsl:when test="contains(@rend, 'asterism')">
                <p class="tb"><xsl:call-template name="generate-id-attribute"/>&asterism;</p>
            </xsl:when>
            <xsl:when test="contains(@rend, 'space')">
                <p class="tb">
                    <xsl:call-template name="generate-id-attribute"/>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <hr class="tb">
                    <xsl:call-template name="generate-id-attribute"/>
                </hr>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="reopenpar"/>
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

    <!-- Trailers -->

    <xd:doc>
        <xd:short>Handle an trailer.</xd:short>
        <xd:detail>Handle an trailer (a short phrase at the end of a chapter or book).</xd:detail>
    </xd:doc>

    <xsl:template match="trailer">
        <p>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:attribute name="class">trailer <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:apply-templates/>
        </p>
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


    <!--====================================================================-->
    <!-- Letters, with openers, closers, etc. -->

    <!-- non-TEI shortcut for <q><text><body><div1 type="Letter"> -->
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

    <xsl:template match="p">
        <xsl:call-template name="handle-paragraph"/>
    </xsl:template>


    <xsl:template name="handle-paragraph">
        <xsl:if test="not(contains(@rend, 'display(none)'))">
            <p>
                <xsl:call-template name="set-lang-id-attributes"/>

                <xsl:variable name="class">
                    <!-- in a few cases, we have paragraphs in quoted material in footnotes, which need to be set in a smaller font: apply the proper class for that. -->
                    <xsl:if test="ancestor::note[@place='foot' or @place='undefined' or not(@place)]">footnote<xsl:text> </xsl:text></xsl:if>
                    <!-- propagate the @type attribute to the class -->
                    <xsl:if test="@type"><xsl:value-of select="@type"/><xsl:text> </xsl:text></xsl:if>
                    <xsl:call-template name="first-paragraph-class"/>
                    <xsl:call-template name="generate-rend-class-name-if-needed"/>
                </xsl:variable>

                <xsl:if test="normalize-space($class) != ''">
                    <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>
                </xsl:if>

                <xsl:if test="@n and ($optionParagraphNumbers = 'Yes')">
                    <span class="parnum"><xsl:value-of select="@n"/>.<xsl:text> </xsl:text></span>
                </xsl:if>
                <xsl:apply-templates/>
            </p>
        </xsl:if>
    </xsl:template>


    <!-- Determine whether a paragraph is the first of a set (used to determine
         whether an indentation is required in some cases -->
    <xsl:template name="first-paragraph-class">
        <xsl:variable name="preceding">
            <xsl:value-of select="name(preceding-sibling::*[1])"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="position() = 1">first </xsl:when>
            <xsl:when test="$preceding = 'head' or $preceding = 'byline' or $preceding = 'lg' or $preceding = 'tb' or $preceding = 'epigraph' or $preceding = 'argument'">first </xsl:when>
        </xsl:choose>
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
    5. We need to remove the first letter from the Paragraph, and render it in 
       the float in white, such that it re-appears when no CSS is available.

    In some rendering engines, these tricks do not yield the desired results,
    so we fall-back to a more robust method, using an floating image.

    -->

    <xsl:template match="p[contains(@rend, 'initial-image')]">
        <xsl:choose>
            <xsl:when test="$optionPrinceMarkup = 'Yes' or $optionEPubMarkup = 'Yes'">
                <xsl:call-template name="initial-image-with-float"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="initial-image-with-css"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="initial-image-with-css">
        <p>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:attribute name="class"><xsl:call-template name="generate-rend-class-name"/></xsl:attribute>
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
        </p>
    </xsl:template>


    <xsl:template name="initial-image-with-float">
        <div class="figure floatLeft">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:call-template name="insertimage2">
                <xsl:with-param name="filename" select="substring-before(substring-after(@rend, 'initial-image('), ')')"/>
            </xsl:call-template>
        </div>
        <p class="first">
            <xsl:apply-templates mode="eat-initial"/>
        </p>
    </xsl:template>


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


    <!-- We need to adjust the text() matching template to remove the first character from the paragraph -->
    <xsl:template match="text()" mode="eat-initial">
        <xsl:choose>
            <xsl:when test="position()=1 and (substring(.,1,1) = '&ldquo;' or substring(.,1,1) = '&lsquo;' or substring(.,1,1) = '&rsquo;')">
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


    <!-- simple drop-caps -->
    <!-- some CSS implementations do not handle the ::first-letter selector correctly, so we provide a span for this -->

    <xsl:template match="p[contains(@rend, 'dropcap(')]">
        <p>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:attribute name="class"><xsl:call-template name="generate-rend-class-name"/></xsl:attribute>
            <span>
                <xsl:attribute name="class"><xsl:call-template name="generate-rend-class-name"/>dropcap</xsl:attribute>
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
                <xsl:attribute name="class"><xsl:call-template name="generate-rend-class-name"/>afterdropcap</xsl:attribute>
                <xsl:apply-templates mode="eat-initial"/>
            </span>
        </p>
    </xsl:template>


    <xsl:template match="p[contains(@rend, 'dropcap(')]" mode="css">

        <xsl:variable name="properties"><xsl:call-template name="translate-rend-attribute"/></xsl:variable>

.<xsl:call-template name="generate-rend-class-name"/>
{
    text-indent: 0;

    <xsl:if test="normalize-space($properties) != ''">
        <xsl:value-of select="normalize-space($properties)"/>
    </xsl:if>
}

.<xsl:call-template name="generate-rend-class-name"/>dropcap
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

.<xsl:call-template name="generate-rend-class-name"/>afterdropcap
{
    /* empty */
}

    </xsl:template>


</xsl:stylesheet>
