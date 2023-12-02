<!DOCTYPE xsl:stylesheet [

    <!ENTITY tab        "&#x09;">
    <!ENTITY lf         "&#x0A;">
    <!ENTITY cr         "&#x0D;">
    <!ENTITY deg        "&#176;">
    <!ENTITY ldquo      "&#x201C;">
    <!ENTITY lsquo      "&#x2018;">
    <!ENTITY rsquo      "&#x2019;">
    <!ENTITY bdquo      "&#x201E;">
    <!ENTITY laquo      "&#xAB;">
    <!ENTITY raquo      "&#xBB;">
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

<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="urn:stylesheet-functions"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:tmp="urn:temporary"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="f map tmp xd xs">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to format block-level elements, to be imported in tei2html.xsl.</xd:short>
        <xd:detail>This stylesheet formats block-level elements from TEI.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2015, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xd:doc mode="#default">
        <xd:short>Default mode; generates HTML output.</xd:short>
    </xd:doc>


    <!--=== Page Breaks ====================================================-->

    <xd:doc>
        <xd:short>Handle a page-break.</xd:short>
        <xd:detail>Handle a page-break. Generate an HTML anchor with an <code>id</code> attribute.
        Depending on the element that contains the <code>pb</code>-element, we may need to wrap the generated content in
        a wrapping HTML <code>p</code>-element.</xd:detail>
    </xd:doc>

    <xsl:template match="pb">
        <xsl:choose>
            <!-- Don't show page breaks when they appear in a marginal note. -->
            <xsl:when test="ancestor::note[@place = ('margin', 'left', 'right')]">
                <xsl:call-template name="pb-anchor"/>
            </xsl:when>
            <!-- HTML does not allow a span element at the top-level, so wrap it in a paragraph. -->
            <xsl:when test="parent::front | parent::body | parent::back | parent::div1 | parent::div2 | parent::div3 | parent::div4 | parent::div5">
                <p><xsl:call-template name="pb"/></p>
            </xsl:when>
            <!-- In some odd cases, you can have a parent::front and an ancestor::p, this is why those tests are separate. -->
            <xsl:when test="ancestor::p | ancestor::list | ancestor::table | ancestor::head | ancestor::l | ancestor::tmp:span | ancestor::stage | ancestor::castList">
                <xsl:call-template name="pb"/>
            </xsl:when>
            <xsl:otherwise>
                <p><xsl:call-template name="pb"/></p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate an anchor for a page-break.</xd:short>
        <xd:detail>Generate a marginal note for a page-break if the page-break has a number (<code>@n</code>-attribute).
        Otherwise, just generate an anchor element.</xd:detail>
    </xd:doc>

    <xsl:template name="pb">
        <xsl:context-item as="element(pb)" use="required"/>
        <xsl:choose>
            <xsl:when test="@n and f:is-set('pageNumbers.show') or (@facs and f:is-set('facsimile.enable'))">
                <xsl:call-template name="pb-margin"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="pb-anchor"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate a marginal note with an anchor for a page-break.</xd:short>
        <xd:detail>Generate a marginal note for a page-break if the page-break has a number (<code>@n</code>-attribute), or,
        if available, a link to the facsimile.</xd:detail>
    </xd:doc>

    <xsl:template name="pb-margin">
        <xsl:context-item as="element(pb)" use="required"/>
        <span class="pageNum" id="{f:generate-id(.)}">
            <xsl:if test="@n and f:is-set('pageNumbers.show')">
                <xsl:value-of select="f:get-setting('pageNumbers.before')"/>
                <a href="{f:generate-href(.)}">
                    <xsl:copy-of select="f:convert-markdown(@n)"/>
                </a>
                <xsl:value-of select="f:get-setting('pageNumbers.after')"/>
            </xsl:if>

            <xsl:if test="@facs and f:is-set('facsimile.enable')">
                <xsl:call-template name="pb-facsimile-link"/>
            </xsl:if>

            <xsl:if test="not(@facs) and f:is-set('debug.facsimile')">
                <xsl:text> </xsl:text>
                <xsl:variable name="page" select="substring(string(1000 + @n), 2)"/>
                <a href="https://www.pgdp.net/c/tools/page_browser.php?project={//idno[@type='PGDPProjectId']}&amp;imagefile={$page}.png">DP</a>
            </xsl:if>
         </span>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate a link to the page-image with a page-break.</xd:short>
        <xd:detail>Generate a link to the page-image with a page-break if the page-break indicates a
        facsimile (<code>@facs</code>-attribute).</xd:detail>
    </xd:doc>

    <xsl:template name="pb-facsimile-link">
        <xsl:context-item as="element(pb)" use="required"/>
        <xsl:variable name="target" select="f:get-setting('facsimile.target')"/>

        <xsl:text>&nbsp;</xsl:text>
        <xsl:choose>
            <xsl:when test="starts-with(@facs, '#')">
                <xsl:variable name="id" select="substring(@facs, 2)"/>
                <xsl:variable name="graphic" select="//graphic[@id = $id]"/>
                <xsl:if test="$graphic">
                    <xsl:copy-of select="if (f:is-set('facsimile.wrapper.enable')) then f:facsimile-wrapper-link($graphic) else f:facsimile-direct-link($graphic/@url)"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="if (f:is-set('facsimile.wrapper.enable')) then f:facsimile-wrapper-link(.) else f:facsimile-direct-link(@facs)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:function name="f:facsimile-wrapper-link">
        <!-- Parameter node can be either a pb or a graphic element. -->
        <xsl:param name="node" as="node()"/>
        <xsl:variable name="target" select="f:get-setting('facsimile.target')"/>

        <a href="{f:facsimile-wrapper-full-filename($node)}" class="facslink" title="{f:message('msgPageImage')}">
            <xsl:if test="$target">
                <xsl:attribute name="target" select="$target"/>
            </xsl:if>
        </a>
    </xsl:function>


    <xsl:function name="f:facsimile-direct-link">
        <xsl:param name="url" as="xs:string"/>
        <xsl:variable name="url" select="f:translate-xref-url($url, substring(f:get-document-lang(), 1, 2))"/>
        <xsl:variable name="target" select="f:get-setting('facsimile.target')"/>

        <a href="{$url}" class="facslink" title="{f:message('msgPageImage')}">
            <xsl:if test="$target">
                <xsl:attribute name="target" select="$target"/>
            </xsl:if>
        </a>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate anchor for a <code>pb</code>-element.</xd:short>
        <xd:detail>Generate an anchor for a <code>pb</code>-element.</xd:detail>
    </xd:doc>

    <xsl:template name="pb-anchor">
        <xsl:context-item as="element(pb)" use="required"/>
        <a id="{f:generate-id(.)}"/>
    </xsl:template>


    <!--=== Formswork ======================================================-->

    <xd:doc>
        <xd:short>Formswork, for now just ignore, except if is to be placed in the margin.</xd:short>
    </xd:doc>

    <xsl:template match="fw">
        <xsl:copy-of select="f:log-debug('Ignoring fw element on page {1}.', (./preceding::pb[1]/@n))"/>
    </xsl:template>

    <xsl:template match="fw[@place=('margin', 'left', 'right')]">
        <xsl:copy-of select="f:log-debug('Placing fw element in margin on page {1}.', (./preceding::pb[1]/@n))"/>
        <span class="fwMargin">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="fw[@place=('margin', 'left', 'right')]/list">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="fw[@place=('margin', 'left', 'right')]/list/item" priority="2">
        <br/><xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="fw[@place=('margin', 'left', 'right')]/list/item[1]" priority="1">
        <b><xsl:apply-templates/><br/>&mdash;</b>
    </xsl:template>

    <xsl:template match="fw[@place=('margin', 'left', 'right')]/list/item[2]" priority="1">
        <br/><b><xsl:apply-templates/></b>
    </xsl:template>


    <!--=== Thematic Breaks ================================================-->

    <xd:doc>
        <xd:short>Handle a milestone (thematic break).</xd:short>
        <xd:detail>Handle a document milestone. This is mostly used to encode thematic breaks. Generates
        slightly different outputs, depending on the <code>@type</code> and <code>@rend</code>-attributes.</xd:detail>
    </xd:doc>

    <xsl:variable name="milestone-markers" select="
        map {
            'dots'     : '. . . . . . . . . . . . . . . . . . . . .',
            'dashes'   : '- - - - - - - - - - - - - - - - - - - - -',
            'mdashes'  : '&mdash;&nbsp;&mdash;&nbsp;&mdash;&nbsp;&mdash;&nbsp;&mdash;',
            'star'     : '*',
            'stars'    : '*&nbsp;&nbsp;&nbsp;*&nbsp;&nbsp;&nbsp;*',
            'asterism' : '&asterism;',
            'space'    : ''
        }">
    </xsl:variable>

    <xsl:template match="milestone[@unit='theme' or @unit='tb']">
        <xsl:call-template name="closepar"/>
        <xsl:choose>
            <xsl:when test="@rend = ('dotted', 'dashed')">
                <hr id="{f:generate-id(.)}" class="tb {@rend}"/>
            </xsl:when>
            <xsl:when test="f:has-rend-value(@rend, 'stars')">
                <xsl:call-template name="generate-milestone-paragraph">
                    <xsl:with-param name="string" select="f:repeat('*', '&nbsp;&nbsp;&nbsp;', xs:integer(f:rend-value(@rend, 'stars')))"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@rend = map:keys($milestone-markers)">
                <xsl:call-template name="generate-milestone-paragraph">
                    <xsl:with-param name="string" select="$milestone-markers(@rend)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="f:has-rend-value(@rend, 'image')">
                <div class="figure">
                    <xsl:variable name="alt">
                        <xsl:choose>
                            <xsl:when test="f:has-rend-value(@rend, 'image-alt')"><xsl:value-of select="f:rend-value(@rend, 'image-alt')"/></xsl:when>
                            <xsl:when test=". != ''"><xsl:value-of select="."/></xsl:when>
                            <xsl:otherwise><xsl:value-of select="f:message('msgOrnament')"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:copy-of select="f:output-image(f:rend-value(@rend, 'image'), $alt)"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <hr id="{f:generate-id(.)}">
                    <xsl:copy-of select="f:set-class-attribute-with(., 'tb')"/>
                </hr>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>


    <xsl:template name="generate-milestone-paragraph">
        <xsl:context-item as="element(milestone)" use="required"/>
        <xsl:param name="string" as="xs:string"/>
        <xsl:element name="{$p.element}">
            <xsl:attribute name="class">tb</xsl:attribute>
            <xsl:attribute name="id"><xsl:value-of select="f:generate-id(.)"/></xsl:attribute>
            <xsl:value-of select="$string"/>
        </xsl:element>
    </xsl:template>


    <xsl:function name="f:repeat">
        <xsl:param name="input" as="xs:string"/>
        <xsl:param name="separator" as="xs:string"/>
        <xsl:param name="count" as="xs:integer"/>
        <xsl:sequence select="string-join(for $i in 1 to $count return $input, $separator)"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Handle a milestone-element.</xd:short>
        <xd:detail>Handle a milestone-element. Just generate an anchor if the <code>@type</code> and
        <code>@rend</code>-attributes are missing.</xd:detail>
    </xd:doc>

    <xsl:template match="milestone">
        <a id="{f:generate-id(.)}"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle an argument.</xd:short>
        <xd:detail>Handle an argument (a summary of the contents at the start of a chapter).</xd:detail>
    </xd:doc>

    <xsl:template match="argument">
        <div class="argument">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle an epigraph.</xd:short>
        <xd:detail>Handle an epigraph (a short citation at the start of a chapter or book).</xd:detail>
    </xd:doc>

    <xsl:template match="epigraph">
        <div class="epigraph">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle a trailer.</xd:short>
        <xd:detail>Handle a trailer (a short phrase at the end of a chapter or book).</xd:detail>
    </xd:doc>

    <xsl:template match="trailer">
        <xsl:element name="{$p.element}">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'trailer')"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle quotations.</xd:short>
        <xd:detail><p>Handle quotations (a quotation is normally set off from the text by some extra space and indentation).</p>

            <p>Note that TEI has several closely related elements for encoding quotations, that is, <code>q</code>,
            <code>quote</code> and <code>said</code>, and a some related elements like <code>cit</code>,
            <code>mentioned</code> and <code>soCalled</code>. Since these elements regard interpretation of the text
            and have little impact on its rendering, in combination with the fact that by default these stylesheets
            assume that all characters are encoded (instead of replaced by mark-up), we do little with those elements.</p>

            <p>In my convention, I often use <code>q</code>-element to set off content that wouldn't fit in the TEI content-model
            otherwise. Typically, these are lines of verse in footnotes. In that case it makes sense to use an HTML
            <code>div</code>.</p>
            
            <p>Other conventions use the <code>q</code>-element to replace quotation marks, in which case it makes sense to 
            use an HTML <code>span</code>, and restore the quotation marks on output. The behavior can be controlled via the 
            settings <code>q.asDiv</code> and <code>q.insertQuotes</code>.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="q">
        <xsl:if test="f:is-set('q.asDiv')">
            <xsl:call-template name="closepar"/>
        </xsl:if>

        <xsl:element name="{if (f:is-set('q.asDiv')) then 'div' else 'span'}">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'q')"/>

            <xsl:variable name="quotes" select="f:get-setting('text.quotes')"/>
            <xsl:if test="f:is-set('q.insertQuotes')">
                <xsl:value-of select="if (f:quote-nesting-level(.) mod 2 = 1) then substring($quotes, 1, 1) else substring($quotes, 3, 1)"/>
            </xsl:if>

            <xsl:apply-templates/>

            <xsl:if test="f:is-set('q.insertQuotes')">
                <xsl:value-of select="if (f:quote-nesting-level(.) mod 2 = 1) then substring($quotes, 2, 1) else substring($quotes, 4, 1)"/>
            </xsl:if>
        </xsl:element>

        <xsl:if test="f:is-set('q.asDiv')">
            <xsl:call-template name="reopenpar"/>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Determine the nesting level of a quotation in a paragraph.</xd:short>
        <xd:detail>Count from the most direct ancestor that is a block element, for now consider p, note, cell, item, and q[f:is-block(.)];
             count the number of q ancestors between that and self.</xd:detail>
    </xd:doc>

    <xsl:function name="f:quote-nesting-level">
        <xsl:param name="q" as="element(q)"/>
        <xsl:sequence select="count($q/ancestor::q[ancestor::*[name() = ('p', 'note', 'cell', 'item') or f:is-block(.)]]) + 1"/>
    </xsl:function>


    <xsl:template match="q[f:is-block(.)]">
        <xsl:call-template name="closepar"/>
        <blockquote>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute(.)"/>
            <xsl:apply-templates/>
        </blockquote>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle an quote in a citation.</xd:short>
        <xd:detail>Quotes inside a <code>cit</code> element should not be output as a <code>div</code> element in HTML.</xd:detail>
    </xd:doc>

    <xsl:template match="q[parent::cit]">
        <span>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'epigraph')"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle <code>q</code> and <code>lg</code> elements within a footnote.</xd:short>
        <xd:detail>Quotes and lines of verse within a footnote are (due to the required structure of a TEI document), nested
        within a <code>text/body/div1</code> structure. In the generated output, we need to ignore this
        superfluous structure.</xd:detail>
    </xd:doc>

    <xsl:template match="note[f:is-footnote(.)]//q/text">
        <div class="nestedtext">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="note[f:is-footnote(.)]//q/text/body">
        <div class="nestedbody">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="note[f:is-footnote(.)]//q/text/body/div1">
        <div class="nesteddiv1">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <!--=== Letters, with openers, closers, etc. ===========================-->

    <xd:doc>
        <xd:short>Handle a cited letter.</xd:short>
        <xd:detail>Handle a cited letter. This is a non-TEI shortcut for <code>&lt;q&gt;&lt;text&gt;&lt;body&gt;&lt;div1 type="Letter"&gt;</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="letter">
        <xsl:call-template name="closepar"/>
        <blockquote class="letter">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </blockquote>
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


    <!--=== Paragraphs =====================================================-->

    <xd:doc>
        <xd:short>Handle a paragraph.</xd:short>
        <xd:detail>Handle a paragraph. All action is delegated to a named template.</xd:detail>
    </xd:doc>

    <xsl:template match="p">
        <xsl:call-template name="handle-paragraph"/>
    </xsl:template>


    <xsl:template name="handle-paragraph">
        <xsl:context-item as="element(p)" use="required"/>
        <xsl:if test="f:rend-value(@rend, 'display') != 'none'">
            <xsl:element name="{$p.element}">
                <xsl:copy-of select="f:set-lang-id-attributes(.)"/>

                <xsl:variable name="class">
                    <!-- When not using the p element to represent paragraphs, set an appropriate class. -->
                    <xsl:if test="$p.element != 'p'"><xsl:text>par </xsl:text></xsl:if>
                    <!-- in a few cases, we have paragraphs in quoted material in footnotes, which need to be set in a smaller font: apply the proper class for that. -->
                    <xsl:if test="ancestor::note[@place='foot' or @place='undefined' or not(@place)]"><xsl:text>footnote </xsl:text></xsl:if>
                    <!-- propagate the @type attribute to the class -->
                    <xsl:if test="@type"><xsl:value-of select="@type"/><xsl:text> </xsl:text></xsl:if>
                    <xsl:if test="f:is-first-paragraph(.)">first </xsl:if>
                    <xsl:value-of select="f:hanging-punctuation-class(.)"/>
                </xsl:variable>
                <xsl:copy-of select="f:log-debug('Generate paragraph with class {1}.', ($class))"/>
                <xsl:copy-of select="f:set-class-attribute-with(., $class)"/>

                <xsl:if test="@n and f:is-set('showParagraphNumbers')">
                    <span class="parnum"><xsl:value-of select="@n"/>.<xsl:text> </xsl:text></span>
                </xsl:if>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Determine whether a paragraph is first.</xd:short>
        <xd:detail>Determine whether a paragraph is first in a division. This can be used to determine whether
        extra or no-indentation is required in these cases.</xd:detail>
        <xd:param name="node">The (<code>p</code>) element of which the position needs to be determined.</xd:param>
    </xd:doc>

    <xsl:function name="f:is-first-paragraph" as="xs:boolean">
        <xsl:param name="node" as="element(p)"/>

        <xsl:variable name="preceding">
            <xsl:value-of select="name($node/preceding-sibling::*[not(self::pb)][1])"/>
        </xsl:variable>

        <xsl:value-of select="count($node/preceding-sibling::*[not(self::pb)]) = 0
            or $preceding = 'head'
            or $preceding = 'byline'
            or $preceding = 'lg'
            or $preceding = 'sp'
            or $preceding = 'tb'
            or $preceding = 'epigraph'
            or $preceding = 'argument'
            or $preceding = 'opener'"/>
    </xsl:function>


    <!--=== Hanging punctuation ============================================-->

    <xd:doc>
        <xd:short>Determine a class for a paragraph if it starts with quotation marks.</xd:short>
        <xd:detail>Determine a class for a paragraph if it starts with quotation marks. This can be used
        to &lsquo;hang&rsquo; the quotation marks using CSS.</xd:detail>
        <xd:param name="text">The string of which the starting punctuation is to be determined.</xd:param>
    </xd:doc>

    <xsl:function name="f:hanging-punctuation-class" as="xs:string">
        <xsl:param name="text" as="xs:string"/>

        <xsl:choose>
            <xsl:when test="not(f:is-set('punctuation.hanging'))"><xsl:text> </xsl:text></xsl:when>

            <!-- Longer sequences should go first! -->
            <xsl:when test="starts-with($text, '&ldquo;&lsquo;')">indent-hang-large</xsl:when>
            <xsl:when test="starts-with($text, '&lsquo;&ldquo;')">indent-hang-large</xsl:when>

            <xsl:when test="starts-with($text, '&ldquo;')">indent-hang-medium</xsl:when>
            <xsl:when test="starts-with($text, '&lsquo;')">indent-hang-small</xsl:when>
            <xsl:when test="starts-with($text, '&rsquo;')">indent-hang-small</xsl:when>

            <xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine whether a node starts with punctuation.</xd:short>
        <xd:param name="node">The element of which the existence of starting punctuation is to be determined.</xd:param>
    </xd:doc>

    <xsl:function name="f:starts-with-punctuation" as="xs:boolean">
        <xsl:param name="node" as="node()"/>

        <xsl:variable name="first" select="$node/(*|text())[1]"/>

        <!-- First child node should be text node -->
        <xsl:value-of select="not(name($first)) and matches($first, '^[&ldquo;&lsquo;&rsquo;]')"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Handle hanging punctuation at the start of a paragraph.</xd:short>
    </xd:doc>

    <xsl:template name="hangOpenPunctuation">
        <xsl:context-item as="element(p)" use="required"/>
        <!-- First child node is a text node that starts with punctuation. -->
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


    <!--=== Decorative Initials ============================================-->

    <xd:doc>
        <xd:short>Start a paragraph with a decorative initial.</xd:short>
        <xd:detail>
            <p>Start a paragraph with a decorative initial. Decorative initials are encoded
            within the <code>rend</code> attribute on the paragraph level, using the value
            <code>initial-image()</code>.</p>

            <p>To properly show an initial in HTML that may stick over the text, we need
            to use several tricks in CSS.</p>

            <ol>
                <li>We set the initial as background picture on the paragraph.</li>
                <li>We create a small div, which we float to the left, to give the initial
                the space it needs.</li>
                <li>We set the padding-top to a value such that the initial actually appears
                to stick over the paragraph.</li>
                <li>We set the initial as background picture to the float, such that if the
                paragraph is too small to contain the entire initial, the float will. We
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
            so we fall back to a more robust method, using a floating image.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="p[f:has-rend-value(@rend, 'initial-image')]">
        <xsl:call-template name="handle-initial-image"/>
    </xsl:template>


    <!-- Can also be called for lines of verse, see drama.xsl. -->
    <xsl:template name="handle-initial-image">
        <xsl:context-item as="element()" use="required"/>
        <xsl:choose>
            <xsl:when test="$optionPrinceMarkup = 'Yes' or f:is-epub()">
                <xsl:call-template name="initial-image-with-float"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="initial-image-with-css"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="initial-image-with-css">
        <xsl:context-item as="element()" use="required"/>
        <xsl:element name="{$p.element}">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:attribute name="class">
                <xsl:if test="$p.element != 'p'"><xsl:text>par </xsl:text></xsl:if>
                <xsl:if test="self::l"><xsl:text>line </xsl:text></xsl:if>
                <xsl:value-of select="f:generate-class-name(.)"/>
            </xsl:attribute>
            <span>
                <xsl:attribute name="class"><xsl:value-of select="f:generate-class-name(.)"/>init</xsl:attribute>
                <xsl:value-of select="f:replaced-initial(.)"/>
            </span>
            <xsl:apply-templates select="node()[1]" mode="remove-initial"/>
            <xsl:apply-templates select="node()[position() > 1]"/>
        </xsl:element>
    </xsl:template>


    <xsl:function name="f:replaced-initial" as="xs:string">
        <xsl:param name="text" as="xs:string"/>

        <xsl:value-of select="if (substring($text, 1, 1) = ('&ldquo;', '&lsquo;', '&rsquo;', '&bdquo;', '&laquo;', '&raquo;')) then substring($text, 1, 2) else substring($text, 1, 1)"/>
    </xsl:function>

    <xsl:function name="f:remove-initial" as="xs:string">
        <xsl:param name="text" as="xs:string"/>

        <xsl:value-of select="if (substring($text, 1, 1) = ('&ldquo;', '&lsquo;', '&rsquo;', '&bdquo;', '&laquo;', '&raquo;')) then substring($text, 3) else substring($text, 2)"/>
    </xsl:function>


    <xsl:template name="initial-image-with-float">
        <xsl:context-item as="element()" use="required"/>

        <div class="figure floatLeft">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:output-image(f:rend-value(@rend, 'initial-image'), f:replaced-initial(.))"/>
        </div>
        <xsl:element name="{$p.element}">
            <xsl:attribute name="class">
                <xsl:if test="$p.element != 'p'"><xsl:text>par </xsl:text></xsl:if>
                <xsl:if test="self::l"><xsl:text>line </xsl:text></xsl:if>
                <xsl:text>first</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates select="node()[1]" mode="remove-initial"/>
            <xsl:apply-templates select="node()[position() > 1]"/>
        </xsl:element>
    </xsl:template>


    <xd:doc mode="css">
        <xd:short>Mode to generate CSS.</xd:short>
    </xd:doc>

    <xd:doc>
        <xd:short>Generate the CSS related to a decorative initial.</xd:short>
    </xd:doc>

    <xsl:template match="p[f:has-rend-value(@rend, 'initial-image')]" mode="css">
        <xsl:call-template name="handle-initial-image-css"/>
    </xsl:template>

    <xsl:template name="handle-initial-image-css">
        <xsl:context-item as="element()" use="required"/>
        <xsl:if test="generate-id() = generate-id(key('rend', name() || ':' || @rend)[1])">

            <xsl:variable name="css-properties" select="f:translate-rend-ladder(@rend, name())"/>
            <xsl:variable name="scale-factor" select="xs:decimal(f:get-setting('images.scale'))" as="xs:decimal"/>

            <xsl:text>&lf;.</xsl:text><xsl:value-of select="f:generate-css-class-selector(.)"/><xsl:text> {&lf;</xsl:text>
            <xsl:text>background: url(</xsl:text><xsl:value-of select="f:rend-value(@rend, 'initial-image')"/><xsl:text>) no-repeat top left;&lf;</xsl:text>
            <xsl:if test="f:has-rend-value(@rend, 'initial-offset')">
                <xsl:text>padding-top: </xsl:text><xsl:value-of select="f:rend-value(@rend, 'initial-offset')"/><xsl:text>;&lf;</xsl:text>
            </xsl:if>
            <xsl:if test="$scale-factor != 1.0">
                <xsl:text>background-size: </xsl:text><xsl:value-of select="f:rend-value(@rend, 'initial-width')"/><xsl:text>;&lf;</xsl:text>
            </xsl:if>

            <xsl:if test="normalize-space($css-properties) != ''">
                <xsl:value-of select="normalize-space($css-properties)"/>
            </xsl:if>
            <xsl:text>}&lf;</xsl:text>

            <xsl:text>&lf;.</xsl:text><xsl:value-of select="f:generate-css-class-selector(.)"/><xsl:text>init {&lf;</xsl:text>
            <xsl:text>float: left;&lf;</xsl:text>
            <xsl:text>width: </xsl:text><xsl:value-of select="f:rend-value(@rend, 'initial-width')"/><xsl:text>;&lf;</xsl:text>
            <xsl:text>height: </xsl:text><xsl:value-of select="f:rend-value(@rend, 'initial-height')"/><xsl:text>;&lf;</xsl:text>
            <xsl:text>background: url(</xsl:text><xsl:value-of select="f:rend-value(@rend, 'initial-image')"/><xsl:text>) no-repeat;&lf;</xsl:text>
            <xsl:if test="f:has-rend-value(@rend, 'initial-offset')">
                <xsl:text>background-position: 0 -</xsl:text><xsl:value-of select="f:rend-value(@rend, 'initial-offset')"/><xsl:text>;&lf;</xsl:text>
            </xsl:if>
            <xsl:if test="$scale-factor != 1.0">
                <xsl:text>background-size: </xsl:text><xsl:value-of select="f:rend-value(@rend, 'initial-width')"/><xsl:text>;&lf;</xsl:text>
            </xsl:if>
            <xsl:text>text-align: right;&lf;</xsl:text>
            <xsl:text>color: white;&lf;</xsl:text>
            <xsl:text>font-size: 1px;&lf;</xsl:text>
            <xsl:text>}&lf;</xsl:text>

        </xsl:if>
        <xsl:apply-templates mode="css"/>
    </xsl:template>


    <xd:doc mode="css-handheld">
        <xd:short>Mode to generate CSS for hand-held devices.</xd:short>
    </xd:doc>

    <xd:doc>
        <xd:short>Generate the CSS related to a decorative initial (for use on hand-held devices).</xd:short>
    </xd:doc>

    <!-- Override decorative initials for handheld devices. -->
    <xsl:template match="p[f:has-rend-value(@rend, 'initial-image')]" mode="css-handheld">
        <xsl:if test="generate-id() = generate-id(key('rend', name() || ':' || @rend)[1])">

            <xsl:text>&lf;.</xsl:text><xsl:value-of select="f:generate-css-class-selector(.)"/><xsl:text> {&lf;</xsl:text>
            <xsl:text>background-image: none;&lf;</xsl:text>
            <xsl:text>padding-top: 0;&lf;</xsl:text>
            <xsl:text>}&lf;</xsl:text>

            <xsl:text>&lf;.</xsl:text><xsl:value-of select="f:generate-css-class-selector(.)"/><xsl:text>init {&lf;</xsl:text>
            <xsl:text>float: none;&lf;</xsl:text>
            <xsl:text>width: auto;&lf;</xsl:text>
            <xsl:text>height: auto;&lf;</xsl:text>
            <xsl:text>background-image: none;&lf;</xsl:text>
            <xsl:text>text-align: right;&lf;</xsl:text>
            <xsl:text>color: inherit;&lf;</xsl:text>
            <xsl:text>font-size: inherit;&lf;</xsl:text>
            <xsl:text>}&lf;</xsl:text>

        </xsl:if>
        <xsl:apply-templates mode="css-handheld"/>
    </xsl:template>


    <xd:doc mode="remove-initial">
        <xd:short>Mode to remove the first letter (and any preceding quotation marks) from a paragraph.</xd:short>
        <xd:detail>This mode is also used with the <code>hi</code> element in <code>inline.xsl</code>, where it
        is used as an additional possible mode. This code is tricky, as it wants to deal with text nodes that
        may be embedded in multiple surrounding elements, but only the first one.</xd:detail>
    </xd:doc>

    <xd:doc>
        <xd:short>Remove the first letter of a paragraph.</xd:short>
        <xd:detail>Remove the first letter of a paragraph. Mind, this means we want to remove the first letter
        of this text node only if it is the first text node in a paragraph. To verify this, it is not enough
        to just look at the <code>position()</code> (as it may be nested several levels deep), But actually will
        have to determine what text is part of the current paragraph and before the current node.</xd:detail>
    </xd:doc>

    <xsl:template match="text()" mode="remove-initial">
        <!-- Get text of the current paragraph before the current node: we only want to remove the initial if this is empty. -->
        <xsl:variable name="paragraph-so-far" select="(./preceding::node()[./ancestor::p[1] is current()/ancestor::p[1]])[1]"/>
        <xsl:copy-of select="f:log-debug('paragraph so-far: {1}', ($paragraph-so-far))"/>

        <xsl:choose>
            <xsl:when test="string-length($paragraph-so-far) = 0 and position() = 1">
                <xsl:copy-of select="f:log-debug('removing initial letter from: {1}', (.))"/>
                <xsl:value-of select="f:process-text(f:remove-initial(.), f:get-current-lang(.))"/>
             </xsl:when>
            <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Remove the first letter of a paragraph (intermediate element).</xd:short>
        <xd:detail>While removing the first letter of a paragraph, we may encounter an
        intermediate element. We currently do handle <code>hi</code> and <code>foreign</code> elements;
        warn for all other types of elements when we encounter them.</xd:detail>
    </xd:doc>

    <xsl:template match="*" mode="remove-initial">
        <xsl:choose>
            <xsl:when test="position() = 1">
                <xsl:copy-of select="f:log-warning('Skipping processing of {1} element while removing initial from paragraph with decorative initial.', (name(.)))"/>
                <xsl:apply-templates mode="remove-initial"/>
            </xsl:when>
            <xsl:otherwise><xsl:apply-templates select="."/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Use a simple drop-cap at the start of a paragraph.</xd:short>
        <xd:detail>Use a simple drop-cap at the start of a paragraph. Provide a unique class name for the drop-cap, as well as a generic one.
        Some CSS implementations do not handle the <code>:first-letter</code> pseudo-selector correctly, so we provide a span for this.</xd:detail>
    </xd:doc>

    <xsl:template match="p[f:has-rend-value(@rend, 'dropcap')]">
        <xsl:element name="{$p.element}">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:attribute name="class">
                <xsl:if test="$p.element != 'p'"><xsl:text>par </xsl:text></xsl:if>
                <xsl:value-of select="f:generate-class-name(.)"/>
            </xsl:attribute>
            <span>
                <xsl:attribute name="class"><xsl:value-of select="f:generate-class-name(.)"/>dc initdropcap</xsl:attribute>
                <xsl:value-of select="f:replaced-initial(.)"/>
            </span>
            <span>
                <xsl:attribute name="class"><xsl:value-of select="f:generate-class-name(.)"/>adc afterdropcap</xsl:attribute>
                <xsl:apply-templates select="node()[1]" mode="remove-initial"/>
                <xsl:apply-templates select="node()[position() > 1]"/>
            </span>
        </xsl:element>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate CSS for drop-cap.</xd:short>
        <xd:detail>Generate CSS for drop-cap. Note that the exact size to be used for a drop-cap depends on the specific
        font being used, and the number of lines desired to be occupied by the drop-cap. This needs to be tweaked when the
        choice for a font, font-size, and line-spacing has been made.</xd:detail>
    </xd:doc>

    <xsl:template match="p[f:has-rend-value(@rend, 'dropcap')]" mode="css">

        <!-- Only generate the CSS-class once if multiple paragraphs have the same @rend value. -->
        <xsl:if test="not(preceding::p[@rend = current()/@rend])">
            <xsl:variable name="css-properties" select="f:translate-rend-ladder(@rend, name())"/>
            <xsl:variable name="ccs-selector" select="f:generate-css-class-selector(.)"/>

            <xsl:text>&lf;.</xsl:text><xsl:value-of select="$ccs-selector"/><xsl:text> {&lf;</xsl:text>
            <xsl:text>text-indent: 0;&lf;</xsl:text>

            <xsl:if test="normalize-space($css-properties) != ''">
                <xsl:value-of select="normalize-space($css-properties)"/>
            </xsl:if>
            <xsl:text>}&lf;</xsl:text>

            <xsl:text>&lf;.</xsl:text><xsl:value-of select="$ccs-selector"/><xsl:text>dc {&lf;</xsl:text>
            <xsl:text>float: left;&lf;</xsl:text>
            <xsl:if test="f:has-rend-value(@rend, 'dropcap-offset')">
                <xsl:text>margin-top: -</xsl:text><xsl:value-of select="f:rend-value(@rend, 'dropcap-offset')"/><xsl:text>;&lf;</xsl:text>
            </xsl:if>
            <xsl:if test="f:has-rend-value(@rend, 'dropcap-height')">
                <xsl:text>height: </xsl:text><xsl:value-of select="f:rend-value(@rend, 'dropcap-height')"/><xsl:text>;&lf;</xsl:text>
            </xsl:if>
            <xsl:text>font-size: </xsl:text><xsl:value-of select="f:rend-value(@rend, 'dropcap')"/><xsl:text>;&lf;</xsl:text>
            <xsl:text>margin-left: 0;&lf;</xsl:text>
            <xsl:text>margin-bottom: 5px;&lf;</xsl:text>
            <xsl:text>margin-right: 3px;&lf;</xsl:text>
            <xsl:text>}&lf;</xsl:text>

            <xsl:text>.</xsl:text><xsl:value-of select="$ccs-selector"/><xsl:text>adc {&lf;</xsl:text>
            <xsl:text>/* empty */&lf;</xsl:text>
            <xsl:text>}&lf;</xsl:text>
        </xsl:if>

        <xsl:apply-templates mode="css"/>
    </xsl:template>

</xsl:stylesheet>