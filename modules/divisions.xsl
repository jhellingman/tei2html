<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="urn:stylesheet-functions"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="f xd xs">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to convert the main divisions of a TEI file to HTML</xd:short>
        <xd:detail>This stylesheet converts the main divisions of a TEI file to HTML. Each main division
        is converted to a <code>div</code>-element, with a class attribute matching the type of the division.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2016, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <!--====================================================================-->
    <!-- Main subdivisions of work -->

    <xsl:template match="text">
        <xsl:apply-templates/>

        <xsl:if test="not(ancestor::group) and f:is-set('facsimile.enable') and f:is-set('facsimile.wrapper.enable')">
            <xsl:apply-templates select="//pb[@facs]" mode="facsimile"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="front">
        <div class="front">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="group">
        <div class="group">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="body">
        <div class="body">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="back">
        <div class="back">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <xsl:template name="pgComment">
        <xsl:if test="/*[self::TEI.2 or self::TEI]/teiHeader/fileDesc/publicationStmt/publisher[. = 'Project Gutenberg'] and f:is-set('pg.includeComments')">
            <xsl:comment><xsl:value-of select="f:message('msgPGComment')"/></xsl:comment>
        </xsl:if>
    </xsl:template>


    <!--====================================================================-->
    <!-- Divisions and Headings -->


    <!--====================================================================-->
    <!-- div0 -->

    <xd:doc>
        <xd:short>Format a div0 element.</xd:short>
        <xd:detail>Format a <code>div0</code> element. At this level, we need to take care of inserting footnotes not handled earlier.</xd:detail>
    </xd:doc>

    <xsl:template match="div0">
        <xsl:copy-of select="f:show-debug-tags(.)"/>
        <div>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:call-template name="generate-div-class"/>
            <xsl:call-template name="generate-label"/>
            <xsl:call-template name="pgComment"/>

            <xsl:apply-templates/>

            <xsl:call-template name="insert-div0-footnotes"/>
        </div>
    </xsl:template>


    <xd:doc>
        <xd:short>Format head element of div0.</xd:short>
        <xd:detail>Format a head element for a <code>div0</code>. At this level we still set the running header (for ePub3).</xd:detail>
    </xd:doc>

    <xsl:template match="div0/head">
        <xsl:call-template name="headPicture"/>
        <xsl:call-template name="setRunningHeader"/>
        <xsl:call-template name="setLabelHeader"/>
        <xsl:if test="f:rend-value(@rend, 'display') != 'image-only'">
            <h2>
                <xsl:call-template name="headText"/>
            </h2>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Format transcriber notes.</xd:short>
        <xd:detail>Format transcriber notes, which are typically not present in the source, using a special class.</xd:detail>
    </xd:doc>

    <xsl:template match="div1[@type='TranscriberNote']">
        <div class="transcriberNote" id="{f:generate-id(.)}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <xd:doc>
        <xd:short>Format div1 element.</xd:short>
        <xd:detail>Format <code>div1</code> element. At this level, we need to take care of inserting footnotes at the end of the division.
        We also may need to insert footnotes of a higher-level <code>div0</code> element, if present, before starting the output division.</xd:detail>
    </xd:doc>

    <xsl:template match="div1">
        <xsl:copy-of select="f:show-debug-tags(.)"/>
        <xsl:if test="f:is-html()">
            <xsl:call-template name="insert-div0-fragment-footnotes"/>
        </xsl:if>

        <xsl:if test="f:should-display-division(.)">
            <div>
                <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                <xsl:call-template name="generate-div-class"/>
                <xsl:call-template name="generate-toc-link"/>
                <xsl:call-template name="generate-label"/>
                <xsl:call-template name="pgComment"/>
                <xsl:call-template name="handle-div"/>

                <xsl:if test="not(f:has-rend-value(@rend, 'align-with') or f:has-rend-value(@rend, 'align-with-document'))">
                    <xsl:call-template name="insert-footnotes"/>
                </xsl:if>
            </div>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Format head element of div1.</xd:short>
        <xd:detail>Format a head element for a <code>div1</code>. At this level we still set the running header (for ePub3).</xd:detail>
    </xd:doc>

    <xsl:template match="div1/head">
        <xsl:call-template name="headPicture"/>
        <xsl:call-template name="setRunningHeader"/>
        <xsl:call-template name="setLabelHeader"/>
        <xsl:if test="f:rend-value(@rend, 'display') != 'image-only'">
            <h2>
                <xsl:call-template name="headText"/>
            </h2>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Format div2 element.</xd:short>
        <xd:detail>Format a <code>div2</code> element.</xd:detail>
    </xd:doc>

    <xsl:template match="div2">
        <xsl:copy-of select="f:show-debug-tags(.)"/>
        <xsl:if test="f:should-display-division(.)">
            <div>
                <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                <xsl:call-template name="generate-div-class"/>
                <xsl:call-template name="generate-toc-link"/>
                <xsl:call-template name="pgComment"/>
                <xsl:call-template name="generate-label">
                    <xsl:with-param name="headingLevel" select="'h2'"/>
                </xsl:call-template>
                <xsl:call-template name="handle-div"/>
            </div>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Format div3 or deeper nested div element.</xd:short>
        <xd:detail>Format a <code>div2</code> or deeper nested element.</xd:detail>
    </xd:doc>

    <xsl:template match="div3 | div4 | div5 | div6">
        <xsl:copy-of select="f:show-debug-tags(.)"/>
        <xsl:if test="f:should-display-division(.)">
            <div class="{name()}">
                <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                <xsl:call-template name="generate-div-class"/>
                <xsl:call-template name="pgComment"/>
                <xsl:call-template name="handle-div"/>
            </div>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Format head element of div2..div6.</xd:short>
        <xd:detail>Format a head element for a <code>div2</code>...<code>div6</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="div2/head | div3/head | div4/head | div5/head | div6/head">
        <xsl:variable name="level" select="number(substring(name(..), 4, 1)) + 1"/>
        <xsl:variable name="level" select="if ($level &gt; 6) then 6 else $level"/>

        <xsl:call-template name="headPicture"/>
        <xsl:call-template name="setLabelHeader"/>
        <xsl:if test="f:rend-value(@rend, 'display') != 'image-only'">
            <xsl:element name="h{$level}">
                <xsl:call-template name="headText"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!--====================================================================-->
    <!-- unnumbered div (for non-explicit levels and P4/P5 compatibility) -->

    <xsl:template match="div">
        <xsl:copy-of select="f:show-debug-tags(.)"/>
        <xsl:if test="f:rend-value(@rend, 'display') != 'none'">
            <xsl:variable name="level" select="f:div-level(.)"/>
            <div>
                <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                <xsl:call-template name="generate-div-class"/>
                <xsl:if test="$level &lt; 3">
                    <xsl:call-template name="generate-toc-link"/>
                    <xsl:call-template name="generate-label">
                        <xsl:with-param name="headingLevel" select="'h' || $level"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:call-template name="handle-div"/>
                <xsl:if test="parent::front | parent::body | parent::back">
                    <xsl:call-template name="insert-footnotes"/>
                </xsl:if>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template match="div/head">
        <xsl:variable name="level" select="f:div-level(..)" as="xs:integer"/>
        <xsl:variable name="level" select="if ($level &gt; 5) then 5 else $level"/>

        <xsl:call-template name="headPicture"/>
        <xsl:call-template name="setLabelHeader"/>
        <xsl:if test="f:rend-value(@rend, 'display') != 'image-only'">
            <xsl:element name="h{$level + 1}">
                <xsl:call-template name="headText"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!--====================================================================-->
    <!-- floatingText -->

    <xsl:template match="floatingText">
        <xsl:if test="f:rend-value(@rend, 'display') != 'none'">
            <div>
                <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                <xsl:variable name="class" select="'floatingText' || (if (@type) then ' ' || lower-case(@type) else '')"/>
                <xsl:copy-of select="f:set-class-attribute-with(., $class)"/>
                <xsl:apply-templates/>
            </div>
        </xsl:if>
    </xsl:template>


    <!--====================================================================-->
    <!-- Generic division content handling -->

    <xd:doc>
        <xd:short>Format a division.</xd:short>
        <xd:detail>Format a division. This generic template is called for divisions at every level, to handle their contents.</xd:detail>
    </xd:doc>

    <xsl:template name="handle-div">
        <xsl:choose>
            <xsl:when test="f:is-set('includeAlignedDivisions') and f:has-rend-value(@rend, 'align-with')">
                <xsl:variable name="otherId" select="f:rend-value(@rend, 'align-with')"/>
                <xsl:choose>
                    <xsl:when test="//*[@id = $otherId]">
                        <xsl:copy-of select="f:log-info('Align division {1} with division {2}.', (@id, $otherId))"/>
                        <xsl:call-template name="align-divisions">
                            <xsl:with-param name="a" select="."/>
                            <xsl:with-param name="b" select="//*[@id = $otherId]"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="f:log-error('Division with id {1} not found.', ($otherId))"/>
                        <xsl:call-template name="only-left-paragraph"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="f:is-set('includeAlignedDivisions') and f:has-rend-value(@rend, 'align-with-document')">
                <xsl:variable name="target" select="f:rend-value(@rend, 'align-with-document')"/>
                <xsl:variable name="document" select="substring-before($target, '#')"/>
                <xsl:variable name="otherId" select="substring-after($target, '#')"/>
                <xsl:choose>
                    <xsl:when test="document($document, .)//*[@id = $otherId]">
                        <xsl:copy-of select="f:log-info('Align division {1} with external document {2}.', (@id, $target))"/>
                        <xsl:call-template name="align-divisions">
                            <xsl:with-param name="a" select="."/>
                            <xsl:with-param name="b" select="document($document, .)//*[@id = $otherId]"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="f:log-error('Division in external document {1} not found.', ($target))"/>
                        <xsl:call-template name="only-left-paragraph"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:otherwise>
                <!-- Wrap heading part and content part of division in separate divs. -->
                <xsl:if test="*[not(f:is-body-content(.))]">
                    <div class="divHead">
                        <xsl:apply-templates select="*[not(f:is-body-content(.))]"/>
                    </div>
                </xsl:if>
                <xsl:if test="*[f:is-body-content(.)]">
                    <div class="divBody">
                        <xsl:apply-templates select="*[f:is-body-content(.)]"/>
                    </div>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:function name="f:is-body-content" as="xs:boolean">
        <xsl:param name="node"/>

        <xsl:sequence select="$node/preceding-sibling::p
                              or $node/self::p
                              or $node/self::div
                              or $node/self::div1
                              or $node/self::div2
                              or $node/self::div3
                              or $node/self::div4
                              or $node/self::div5
                              or $node/self::div5
                              or $node/self::div6
                              or $node/self::divGen"/>
    </xsl:function>


    <xsl:function name="f:should-display-division" as="xs:boolean">
        <xsl:param name="node"/>

        <xsl:sequence select="f:rend-value($node/@rend, 'display') != 'none' and not(f:is-aligned-with-other($node))"/>
    </xsl:function>


    <xsl:function name="f:is-aligned-with-other" as="xs:boolean">
        <xsl:param name="node"/>
        <xsl:variable name="id" select="$node/@id"/>

        <xsl:sequence select="f:is-set('includeAlignedDivisions') and boolean(($root//div | $root//div0 | $root//div1 | $root//div2 | $root//div3 | $root//div4 | $root//div5 | $root//div6)[f:rend-value(@rend, 'align-with') = $id])"/>
    </xsl:function>



    <!--====================================================================-->
    <!-- remaining headers and bylines -->

    <xsl:template match="head">
        <h4>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </h4>
    </xsl:template>

    <xsl:template match="byline">
        <xsl:element name="{$p.element}">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:variable name="class">
                <xsl:if test="$p.element != 'p'"><xsl:text>par </xsl:text></xsl:if>
                <xsl:text>byline</xsl:text>
            </xsl:variable>
            <xsl:copy-of select="f:set-class-attribute-with(., $class)"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>


    <!--====================================================================-->
    <!-- division numbers integrated in heads -->

    <xsl:template match="ab[@type='divNum']">
        <span class="divNum">
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <!--====================================================================-->
    <!-- support templates -->

    <xd:doc>
        <xd:short>Generate a label head.</xd:short>
        <xd:detail>A label head is a generic head for a division, for example "Chapter IX" or "Section 3.1". These
        are generated from the <code>@type</code> and <code>@n</code> attributes.</xd:detail>
    </xd:doc>

    <xsl:template name="generate-label">
        <xsl:context-item as="element()" use="required"/>
        <xsl:param name="div" select="."/>
        <xsl:param name="headingLevel" select="'h2'"/>

        <xsl:if test="f:rend-value($div/@rend, 'label') = 'yes'">
            <xsl:element name="{$headingLevel}">
                <xsl:attribute name="class">label</xsl:attribute>
                <xsl:value-of select="f:translate-div-type($div/@type)"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$div/@n"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle the head text.</xd:short>
        <xd:detail>Handle the text in a head.</xd:detail>
    </xd:doc>

    <xsl:template name="headText">
        <xsl:context-item as="element(head)" use="required"/>

        <xsl:copy-of select="f:set-lang-id-attributes(.)"/>

        <xsl:variable name="class">
            <xsl:if test="@type"><xsl:value-of select="@type"/><xsl:text> </xsl:text></xsl:if>
            <xsl:if test="not(@type)">main</xsl:if>
        </xsl:variable>
        <xsl:copy-of select="f:set-class-attribute-with(., $class)"/>

        <xsl:apply-templates/>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle an image placed above a head.</xd:short>
        <xd:detail>
            <p>Handle an image placed above a head, typically a decorative illustration.</p>

            <p>There are two ways to indicate such images. 1. Use the <code>@rend</code> attribute on the
            head with a rendition element <code>image(image.jpg)</code> and 2. Place a <code>@rend</code>
            attribute on a figure in the division, with a rendition element <code>position(abovehead)</code>.
            The first method is appropriate for decorative images without accompanying text, the second can
            be used if a title and legend needs to appear with the image.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="headPicture">
        <xsl:context-item as="element(head)" use="required"/>

        <xsl:if test="f:has-rend-value(@rend, 'image')">
            <div class="figure">
                <xsl:copy-of select="f:generate-lang-attribute(@lang)"/>
                <xsl:variable name="alt">
                    <xsl:choose>
                        <xsl:when test="f:has-rend-value(@rend, 'image-alt')"><xsl:value-of select="f:rend-value(@rend, 'image-alt')"/></xsl:when>
                        <xsl:when test=". != ''">
                            <!-- Use the head as alt-text; to make sure nested notes, etc. are not copied into the string. -->
                            <xsl:variable name="head">
                                <xsl:apply-templates select="." mode="toc-head"/>
                            </xsl:variable>
                            <xsl:value-of select="$head"/>
                        </xsl:when>
                        <xsl:otherwise><xsl:value-of select="f:message('msgOrnament')"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:copy-of select="f:output-image(f:rend-value(@rend, 'image'), $alt)"/>
            </div>
        </xsl:if>
        <xsl:if test="count(../p/figure[f:rend-value(@rend, 'position') = 'abovehead']) > 1">
            <xsl:copy-of select="f:log-warning('{1} paragraphs found to be placed above the division head.', (xs:string(count(../p/figure[f:rend-value(@rend, 'position') = 'abovehead']))))"/>
        </xsl:if>
        <xsl:if test="not(preceding-sibling::head)">
            <xsl:apply-templates select="../p/figure[f:rend-value(@rend, 'position') = 'abovehead']"/>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Skip images already placed above the chapter heading.</xd:short>
    </xd:doc>

    <xsl:template match="p[figure[f:rend-value(@rend, 'position') = 'abovehead']]"/>


    <xd:doc>
        <xd:short>Generate an HTML class for a division.</xd:short>
        <xd:detail>Generate an appropriate HTML class for a division. This is based on the division's type, level, and rend attributes.</xd:detail>
    </xd:doc>

    <xsl:template name="generate-div-class">
        <xsl:variable name="div" select="name()"/>
        <xsl:variable name="div" select="if ($div = 'div') then 'div' || f:div-level(.) else $div"/>

        <xsl:variable name="class">
            <xsl:value-of select="$div"/><xsl:text> </xsl:text>
            <xsl:if test="position() = last()"><xsl:text>last-child </xsl:text></xsl:if>
            <xsl:if test="@type"><xsl:value-of select="lower-case(@type)"/><xsl:text> </xsl:text></xsl:if>
        </xsl:variable>
        <xsl:copy-of select="f:set-class-attribute-with(., $class)"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate a link back to the table of contents.</xd:short>
        <xd:detail>Generate a link back (in)to the table of contents, to be placed in the right margin in the HTML output.</xd:detail>
    </xd:doc>

    <xsl:template name="generate-toc-link">
        <xsl:if test="f:is-html()"><!-- TODO: improve ePub version of navigational aids -->
            <xsl:if test="//*[@id='toc'] and not(ancestor::q)">
                <!-- If we have an element with id 'toc', include a link to it (except in quoted material) -->
                <span class="pageNum">
                    <xsl:text>[</xsl:text>
                    <a>
                        <!-- Link to entry for current division if available to make navigation back easier. -->
                        <!-- TODO: improve for working with multiple groups: use convention of name of toc: "toc.<@id of group>" -->
                        <xsl:variable name="id" select="@id"/>
                        <xsl:variable name="tocEntry" select="(//*[starts-with(@id, 'toc')]//ref[@target = $id])[1]"/>
                        <xsl:variable name="divGen" select="(//divGen[@id = 'toc'][@type = 'toc'])[1]"/>
                        <xsl:variable name="maxLevel" select="f:generated-toc-max-level($divGen)"/>

                        <xsl:attribute name="href" select="
                            if ($tocEntry)
                            then f:generate-href($tocEntry)
                            else if ($divGen and f:included-in-toc(., $maxLevel))
                                    then f:determine-filename($divGen) || '#' || $id || '.toc'
                                    else f:generate-href(//*[@id='toc'][1])"/>
                        <xsl:value-of select="f:message('msgToc')"/>
                     </a>
                     <xsl:text>]</xsl:text>
                </span>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xsl:template name="generate-toc-link-epub"><!-- TODO: use this in ePub -->

        <!-- Do not do this in quoted material -->
        <xsl:if test="not(ancestor::q)">
            <xsl:if test="preceding-sibling::div1 or //*[@id='toc'] or following-sibling::div1">
                <p class="navigation">
                    <xsl:text>[ </xsl:text>
                    <xsl:if test="preceding-sibling::div1">
                        <a href="{f:generate-href(preceding-sibling::div1[1])}">
                            <xsl:value-of select="f:message('msgPrevious')"/>
                        </a>
                    </xsl:if>

                    <xsl:if test="//*[@id='toc']">
                        <!-- If we have an element with id 'toc', include a link to it. -->
                        <xsl:if test="preceding-sibling::div1"> | </xsl:if>
                        <a href="{f:generate-href(//*[@id='toc'])}">
                            <xsl:value-of select="f:message('msgToc')"/>
                         </a>
                    </xsl:if>

                    <xsl:if test="following-sibling::div1">
                        <xsl:if test="preceding-sibling::div1 or //*[@id='toc']"> | </xsl:if>
                        <a href="{f:generate-href(following-sibling::div1[1])}">
                            <xsl:value-of select="f:message('msgNext')"/>
                        </a>
                    </xsl:if>
                    <xsl:text> ]</xsl:text>
                </p>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Set the running header.</xd:short>
        <xd:detail>Set the running header, for ePub3 only (not supported in readers yet).</xd:detail>
    </xd:doc>

    <xsl:template name="setRunningHeader">
        <xsl:param name="head" select="."/>

        <xsl:if test="$outputFormat = 'XXX'">
            <div class="pagehead">
                <xsl:value-of select="$head"/>
            </div>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Set the running header.</xd:short>
        <xd:detail>Set the running header, for Prince output (generating PDF) only.</xd:detail>
    </xd:doc>

    <xsl:template name="setLabelHeader">
        <xsl:param name="head" select="."/>
        <xsl:param name="parent" select="name(..)"/>

        <xsl:if test="$optionPrinceMarkup = 'XXX' and (not($head/@type) or $head/@type='main')">
            <div class="label{$parent}">
                <xsl:apply-templates select="$head" mode="setLabelHeader"/>
            </div>
        </xsl:if>
    </xsl:template>


    <!-- suppress footnotes in running headers -->
    <xsl:template match="note" mode="setLabelHeader"/>


    <!--====================================================================-->
    <!-- code to align two divisions based on the @n attribute -->

    <xd:doc>
        <xd:short>Align two division based on the <code>@n</code> attribute in paragraphs.</xd:short>
        <xd:detail>Align two division based on the <code>@n</code> attribute in paragraphs (which can be any
        child element of the div in question). This code handles
        the case where paragraphs are added or removed between aligned paragraphs, as can be
        expected in a more free translation.</xd:detail>
        <xd:param name="a">The first division.</xd:param>
        <xd:param name="b">The second division.</xd:param>
    </xd:doc>

    <xsl:template name="align-divisions">
        <xsl:param name="a" as="node()"/>
        <xsl:param name="b" as="node()"/>

        <!-- Make sure we have an id for the second column -->
        <a id="{f:generate-id($b)}"/>
        <table class="alignedText">
            <xsl:call-template name="align-nested-divisions">
                <xsl:with-param name="a" select="$a"/>
                <xsl:with-param name="b" select="$b"/>
            </xsl:call-template>
        </table>
    </xsl:template>


    <xsl:template name="align-nested-divisions">
        <xsl:param name="a" as="node()"/>
        <xsl:param name="b" as="node()"/>

        <!-- Determine the language of each side, so we can correctly indicate it on the cells. -->
        <xsl:variable name="firstLang" select="($a/ancestor-or-self::*/@lang)[last()]" as="xs:string?"/>
        <xsl:variable name="secondLang" select="($b/ancestor-or-self::*/@lang)[last()]" as="xs:string?"/>

        <!-- We collect all 'anchor' elements, i.e., elements with the
             same value of the @n attribute in both divisions. Those we line up in our table,
             taking care to insert all extra elements inserted after that as well. -->

        <xsl:variable name="anchors" as="xs:string*">
            <xsl:for-each-group select="$a/*[not(self::pb)]/@n, $b/*[not(self::pb)]/@n" group-by=".">
                <xsl:if test="count(current-group()) = 2">
                    <xsl:sequence select="string(.)"/>
                </xsl:if>
                <xsl:if test="count(current-group()) &gt; 2">
                    <xsl:copy-of select="f:log-warning('The n attribute {1} occurs more than twice, this may cause issues in alignment.', (string(.)))"/>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:variable>

        <!-- Handle elements before any element with an anchor -->
        <xsl:if test="not($a/*[not(self::pb)][1]/@n = $anchors) or not($b/*[not(self::pb)][1]/@n = $anchors)">
            <xsl:variable name="first" select="$a/*[not(self::pb)][1]"/>
            <xsl:variable name="second" select="$b/*[not(self::pb)][1]"/>

            <xsl:choose>
                <xsl:when test="f:is-division($first) and f:is-division($second) and not($first/@n = $anchors) and not($second/@n = $anchors)">
                    <xsl:copy-of select="f:log-info('Align nested division {1} with division {2}.', ($first/@id, $second/@id))"/>
                    <!-- add a spacer row to separate the divisions -->
                    <tr>
                        <td id="{f:generate-id($first)}" class="first alignedDiv{f:div-level($first)}">
                            <xsl:copy-of select="f:generate-lang-attribute($firstLang)"/>
                        </td>
                        <td id="{f:generate-id($second)}" class="second alignedDiv{f:div-level($first)}">
                            <xsl:copy-of select="f:generate-lang-attribute($secondLang)"/>
                        </td>
                    </tr>
                    <xsl:call-template name="align-nested-divisions">
                        <xsl:with-param name="a" select="$first"/>
                        <xsl:with-param name="b" select="$second"/>
                    </xsl:call-template>
                    <!-- Deal with unmatched content following these divisions -->
                    <xsl:call-template name="output-initial-paragraphs">
                        <xsl:with-param name="first" select="$first/following-sibling::*[1]"/>
                        <xsl:with-param name="second" select="$second/following-sibling::*[1]"/>
                        <xsl:with-param name="firstLang" select="$firstLang"/>
                        <xsl:with-param name="secondLang" select="$secondLang"/>
                        <xsl:with-param name="anchors" select="$anchors"/>
                    </xsl:call-template>
                </xsl:when>

                <xsl:otherwise>
                    <xsl:call-template name="output-initial-paragraphs">
                        <xsl:with-param name="first" select="$first"/>
                        <xsl:with-param name="second" select="$second"/>
                        <xsl:with-param name="firstLang" select="$firstLang"/>
                        <xsl:with-param name="secondLang" select="$secondLang"/>
                        <xsl:with-param name="anchors" select="$anchors"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>

        <!-- Handle elements with anchors, and after that those following them -->
        <xsl:for-each select="$a/*[not(self::pb)][@n = $anchors]">
            <xsl:variable name="n" select="@n"/>
            <xsl:variable name="first" select="."/>
            <xsl:variable name="second" select="$b/*[not(self::pb)][@n = $n]"/>

            <xsl:choose>
                <xsl:when test="f:is-division($first) and f:is-division($second)">
                    <xsl:copy-of select="f:log-info('Align nested division {1} with division {2}.', ($first/@id, $second/@id))"/>
                    <!-- add a spacer row to separate the divisions -->
                    <tr>
                        <td id="{f:generate-id($first)}" class="first alignedDiv{f:div-level($first)}">
                            <xsl:copy-of select="f:generate-lang-attribute($firstLang)"/>
                        </td>
                        <td id="{f:generate-id($second)}" class="second alignedDiv{f:div-level($first)}">
                            <xsl:copy-of select="f:generate-lang-attribute($secondLang)"/>
                        </td>
                    </tr>
                    <xsl:call-template name="align-nested-divisions">
                        <xsl:with-param name="a" select="$first"/>
                        <xsl:with-param name="b" select="$second"/>
                    </xsl:call-template>
                    <!-- Deal with unmatched content following these divisions -->
                    <xsl:call-template name="output-initial-paragraphs">
                        <xsl:with-param name="first" select="$first/following-sibling::*[1]"/>
                        <xsl:with-param name="second" select="$second/following-sibling::*[1]"/>
                        <xsl:with-param name="firstLang" select="$firstLang"/>
                        <xsl:with-param name="secondLang" select="$secondLang"/>
                        <xsl:with-param name="anchors" select="$anchors"/>
                    </xsl:call-template>
                </xsl:when>

                <xsl:otherwise>
                    <xsl:call-template name="output-matched-paragraphs">
                        <xsl:with-param name="first" select="$first"/>
                        <xsl:with-param name="second" select="$second"/>
                        <xsl:with-param name="firstLang" select="$firstLang"/>
                        <xsl:with-param name="secondLang" select="$secondLang"/>
                        <xsl:with-param name="anchors" select="$anchors"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

        <!-- Include footnotes if at div1 level (for both sides) -->
        <xsl:if test="$a/../div1">
            <xsl:if test="$a//note[f:is-footnote(.)] or $b//note[f:is-footnote(.)]">
                <tr>
                    <td class="first">
                        <xsl:call-template name="insert-footnotes">
                            <xsl:with-param name="div" select="$a"/>
                        </xsl:call-template>
                    </td>
                    <td class="second">
                        <xsl:call-template name="insert-footnotes">
                            <xsl:with-param name="div" select="$b"/>
                        </xsl:call-template>
                    </td>
                </tr>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xsl:template name="output-initial-paragraphs">
        <xsl:param name="first" as="node()?"/>
        <xsl:param name="second" as="node()?"/>
        <xsl:param name="firstLang" as="xs:string?"/>
        <xsl:param name="secondLang" as="xs:string?"/>
        <xsl:param name="anchors" as="xs:string*"/>

        <xsl:if test="($first or $second) and (not($first/@n = $anchors) or not($second/@n = $anchors))">
            <tr>
                <td class="first">
                    <xsl:copy-of select="f:generate-lang-attribute($firstLang)"/>

                    <xsl:if test="$first and not($first/@n = $anchors)">
                        <xsl:apply-templates select="$first"/>
                        <xsl:call-template name="output-inserted-paragraphs">
                            <xsl:with-param name="start" select="$first"/>
                            <xsl:with-param name="anchors" select="$anchors"/>
                        </xsl:call-template>
                    </xsl:if>
                </td>

                <td class="second">
                    <xsl:copy-of select="f:generate-lang-attribute($secondLang)"/>

                    <xsl:if test="$second and not($second/@n = $anchors)">
                        <xsl:apply-templates select="$second"/>
                        <xsl:call-template name="output-inserted-paragraphs">
                            <xsl:with-param name="start" select="$second"/>
                            <xsl:with-param name="anchors" select="$anchors"/>
                        </xsl:call-template>
                    </xsl:if>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>


    <xsl:template name="output-matched-paragraphs">
        <xsl:param name="first" as="node()"/>
        <xsl:param name="second" as="node()"/>
        <xsl:param name="firstLang" as="xs:string?"/>
        <xsl:param name="secondLang" as="xs:string?"/>
        <xsl:param name="anchors" as="xs:string*"/>

        <tr>
            <td class="first">
                <xsl:copy-of select="f:generate-lang-attribute($firstLang)"/>

                <xsl:apply-templates select="$first"/>
                <xsl:call-template name="output-inserted-paragraphs">
                    <xsl:with-param name="start" select="$first"/>
                    <xsl:with-param name="anchors" select="$anchors"/>
                </xsl:call-template>
            </td>

            <td class="second">
                <xsl:copy-of select="f:generate-lang-attribute($secondLang)"/>

                <xsl:apply-templates select="$second"/>
                <xsl:call-template name="output-inserted-paragraphs">
                    <xsl:with-param name="start" select="$second"/>
                    <xsl:with-param name="anchors" select="$anchors"/>
                </xsl:call-template>
            </td>
        </tr>
    </xsl:template>


    <xd:doc>
        <xd:short>Output inserted paragraphs in aligned divisions.</xd:short>
        <xd:detail>Output paragraphs not present in one division, but present in
        the other (that is, without a matching <code>@n</code> attribute).</xd:detail>
    </xd:doc>

    <xsl:template name="output-inserted-paragraphs">
        <xsl:param name="start" as="node()"/>
        <xsl:param name="anchors" as="xs:string*"/>
        <xsl:variable name="next" select="$start/following-sibling::*[1]"/>

        <xsl:if test="not($next/@n = $anchors)">
            <xsl:if test="$next">
                <xsl:apply-templates select="$next"/>

                <xsl:call-template name="output-inserted-paragraphs">
                    <xsl:with-param name="start" select="$next"/>
                    <xsl:with-param name="anchors" select="$anchors"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xsl:template name="only-left-paragraph">
        <table class="alignedText">
            <tr>
                <td class="first"><xsl:apply-templates/></td>
                <td class="second"/>
            </tr>
        </table>
    </xsl:template>

</xsl:stylesheet>