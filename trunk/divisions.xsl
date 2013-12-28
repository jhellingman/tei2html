<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to format division elements, to be imported in tei2html.xsl.

    Requires: 
        localization.xsl    : templates for localizing strings.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="f xhtml xs xd"
    version="2.0"
    >


    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to convert the main divisions of a TEI file to HTML</xd:short>
        <xd:detail>This stylesheet to convert the main divisions of a TEI file to HTML. Each main division
        is converted to a <code>div</code>-element, with a class attribute matching the type of the division.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <!--====================================================================-->
    <!-- Main subdivisions of work -->

    <xsl:template match="text">
        <xsl:apply-templates/>

        <xsl:if test="$optionGenerateFacsimile = 'Yes'">
            <xsl:apply-templates select="//pb[@facs]" mode="facsimile"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="front">
        <div class="front">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="body">
        <div class="body">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="back">
        <div class="back">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <!--====================================================================-->
    <!-- Divisions and Headings -->


    <!--====================================================================-->
    <!-- div0 -->

    <xd:doc>
        <xd:short>Format a div0 element.</xd:short>
        <xd:detail>Format a div0 element. At this level, we need to take care of inserting footnotes not handled earlier.</xd:detail>
    </xd:doc>

    <xsl:template match="div0">
        <div>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:call-template name="generate-div-class"/>
            <xsl:call-template name="generate-label"/>

            <xsl:apply-templates/>

            <!-- Include footnotes in the div0, if not done so earlier -->

            <xsl:if test=".//note[(@place='foot' or @place='unspecified' or not(@place)) and not(ancestor::div1)] and not(ancestor::q) and not(.//div1)">
                <div class="footnotes">
                    <hr class="fnsep"/>
                    <xsl:apply-templates mode="footnotes" select=".//note[(@place='foot' or @place='unspecified' or not(@place)) and not(ancestor::div1)]"/>
                </div>
            </xsl:if>
        </div>
    </xsl:template>


    <xd:doc>
        <xd:short>Format head element of div0.</xd:short>
        <xd:detail>Format a head element for a div0. At this level we still set the running header (for ePub3).</xd:detail>
    </xd:doc>

    <xsl:template match="div0/head">
        <xsl:call-template name="headPicture"/>
        <xsl:call-template name="setRunningHeader"/>
        <xsl:call-template name="setLabelHeader"/>
        <xsl:if test="not(contains(@rend, 'display(image-only)'))">
            <h2>
                <xsl:call-template name="headText"/>
            </h2>
        </xsl:if>
    </xsl:template>


    <!--====================================================================-->
    <!-- div1 -->

    <xd:doc>
        <xd:short>Format transcriber notes.</xd:short>
        <xd:detail>Format transcriber notes, which are typically not present in the source, using a special class.</xd:detail>
    </xd:doc>

    <xsl:template match="div1[@type='TranscriberNote']">
        <div class="transcribernote">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <xd:doc>
        <xd:short>Format div1 element.</xd:short>
        <xd:detail>Format div1 element. At this level, we need to take care of inserting footnotes at the end of the division.
        We also may need to insert footnotes of a higher-level div0 element, if present, before starting the output division.</xd:detail>
    </xd:doc>

    <xsl:template match="div1">
        <xsl:if test="$outputformat = 'html'">
            <!-- HACK: Include footnotes in a preceding part of the div0 section here -->
            <xsl:if test="count(preceding-sibling::div1) = 0 and ancestor::div0">
                <xsl:if test="..//note[(@place='foot' or @place='unspecified' or not(@place)) and not(ancestor::div1)]">
                    <div class="footnotes">
                        <hr class="fnsep"/>
                        <xsl:apply-templates mode="footnotes" select="..//note[(@place='foot' or @place='unspecified' or not(@place)) and not(ancestor::div1)]"/>
                    </div>
                </xsl:if>
            </xsl:if>
        </xsl:if>

        <xsl:if test="not(contains(@rend, 'display(none)'))">
            <div>
                <xsl:call-template name="set-lang-id-attributes"/>
                <xsl:call-template name="generate-div-class"/>
                <xsl:call-template name="generate-toc-link"/>
                <xsl:call-template name="generate-label"/>
                <xsl:call-template name="handleDiv"/>
                <xsl:call-template name="insert-footnotes"/>
            </div>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Format head element of div1.</xd:short>
        <xd:detail>Format a head element for a div1. At this level we still set the running header (for ePub3).</xd:detail>
    </xd:doc>

    <xsl:template match="div1/head">
        <xsl:call-template name="headPicture"/>
        <xsl:call-template name="setRunningHeader"/>
        <xsl:call-template name="setLabelHeader"/>
        <xsl:if test="not(contains(@rend, 'display(image-only)'))">
            <h2>
                <xsl:call-template name="headText"/>
            </h2>
        </xsl:if>
    </xsl:template>


    <!--====================================================================-->
    <!-- div2 -->

    <xsl:template match="div2">
        <xsl:if test="not(contains(@rend, 'display(none)'))">
            <div>
                <xsl:call-template name="set-lang-id-attributes"/>
                <xsl:call-template name="generate-div-class"/>
                <xsl:call-template name="generate-toc-link"/>
                <xsl:call-template name="generate-label">
                    <xsl:with-param name="headingLevel" select="'h2'"/>
                </xsl:call-template>
                <xsl:call-template name="handleDiv"/>
            </div>
        </xsl:if>
    </xsl:template>

    <!--====================================================================-->
    <!-- div3 and higher -->

    <xsl:template match="div3 | div4 | div5 | div6">
        <div class="{name()}">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:call-template name="generate-div-class"/>
            <xsl:call-template name="handleDiv"/>
        </div>
    </xsl:template>

    <xsl:template match="div2/head | div3/head | div4/head | div5/head | div6/head">
        <xsl:variable name="level" select="number(substring(name(..), 4, 1)) + 1"/>
        <xsl:variable name="level" select="if ($level &gt; 6) then 6 else $level"/>

        <xsl:call-template name="headPicture"/>
        <xsl:call-template name="setLabelHeader"/>
        <xsl:if test="not(contains(@rend, 'display(image-only)'))">
            <xsl:element name="h{$level}">
                <xsl:call-template name="headText"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>


    <!--====================================================================-->
    <!-- Generic division content handling -->

    <xd:doc>
        <xd:short>Format a division.</xd:short>
        <xd:detail>Format a division. This generic templated is called for divisions at every level, to handle the contents.</xd:detail>
    </xd:doc>

    <xsl:template name="handleDiv">
        <xsl:choose>
            <xsl:when test="contains(@rend, 'align-with(')">
                <xsl:variable name="otherid" select="substring-before(substring-after(@rend, 'align-with('), ')')"/>
                <xsl:message terminate="no">INFO:    Align division <xsl:value-of select="@id"/> with division <xsl:value-of select="$otherid"/></xsl:message>
                <xsl:call-template name="align-paragraphs">
                    <xsl:with-param name="a" select="."/>
                    <xsl:with-param name="b" select="//*[@id=$otherid]"/>
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="contains(@rend, 'align-with-document(')">
                <xsl:variable name="target" select="substring-before(substring-after(@rend, 'align-with-document('), ')')"/>
                <xsl:variable name="document" select="substring-before($target, '#')"/>
                <xsl:variable name="otherid" select="substring-after($target, '#')"/>
                <xsl:message terminate="no">INFO:    Align division <xsl:value-of select="@id"/> with external document '<xsl:value-of select="$target"/>'</xsl:message>
                <xsl:call-template name="align-paragraphs">
                    <xsl:with-param name="a" select="."/>
                    <xsl:with-param name="b" select="document($document, .)//*[@id=$otherid]"/>
                </xsl:call-template>
            </xsl:when>

            <xsl:otherwise>
                <!-- Wrap heading part and content part of division in separate divs -->
                <!-- TODO: this fails when a division immediately contains a division -->
                <xsl:if test="*[not(preceding-sibling::p or self::p)]">
                    <div class="divHead">
                        <xsl:apply-templates select="*[not(preceding-sibling::p or self::p)]"/>
                    </div>
                </xsl:if>
                <xsl:if test="*[preceding-sibling::p or self::p]">
                    <div class="divBody">
                        <xsl:apply-templates select="*[preceding-sibling::p or self::p]"/>
                    </div>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!--====================================================================-->
    <!-- remaining headers and bylines -->

    <xsl:template match="head">
        <h4>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </h4>
    </xsl:template>

    <xsl:template match="byline">
        <p>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:attribute name="class">byline <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:apply-templates/>
        </p>
    </xsl:template>


    <!--====================================================================-->
    <!-- division numbers integrated in heads -->

    <xsl:template match="ab[@type='headDivNum']">
        <span class="headDivNum">
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
        <xsl:param name="div" select="."/>
        <xsl:param name="headingLevel" select="'h2'"/>

        <xsl:if test="contains($div/@rend, 'label(yes)')">
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
        <xsl:call-template name="set-lang-id-attributes"/>

        <xsl:variable name="class">
            <xsl:if test="@type"><xsl:value-of select="@type"/><xsl:text> </xsl:text></xsl:if>
            <xsl:if test="not(@type)"><xsl:text>main </xsl:text></xsl:if>
            <xsl:call-template name="generate-rend-class-name-if-needed"/>
        </xsl:variable>

        <xsl:if test="normalize-space($class) != ''">
            <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>
        </xsl:if>

        <xsl:apply-templates/>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle an image placed above a head.</xd:short>
        <xd:detail>Handle an image placed above a head, typically a decorative illustration.</xd:detail>
    </xd:doc>

    <xsl:template name="headPicture">
        <xsl:if test="contains(@rend, 'image(')">
            <div class="figure">
                <xsl:call-template name="set-lang-attribute"/>
                <xsl:call-template name="insertimage2">
                    <xsl:with-param name="alt">
                    <xsl:choose>
                        <xsl:when test="contains(@rend, 'image-alt')">
                            <xsl:value-of select="substring-before(substring-after(@rend, 'image-alt('), ')')"/>
                        </xsl:when>
                        <xsl:when test=". != ''">
                            <xsl:value-of select="."/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="f:message('msgOrnament')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </div>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate an HTML class for a division.</xd:short>
        <xd:detail>Generate an appropriate HTML class for a division. This is based on the division's type, level, and rend attributes.</xd:detail>
    </xd:doc>

    <xsl:template name="generate-div-class">
        <xsl:param name="div" select="name()"/>

        <xsl:variable name="class">
            <xsl:value-of select="$div"/>
            <xsl:if test="@type">
                <xsl:text> </xsl:text><xsl:value-of select="lower-case(@type)"/>
            </xsl:if>
            <xsl:text> </xsl:text><xsl:call-template name="generate-rend-class-name-if-needed"/>
        </xsl:variable>
        <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate a link back to the table of contents.</xd:short>
        <xd:detail>Generate a link back (in)to the table of contents, to be placed in the right margin in the HTML output.</xd:detail>
    </xd:doc>

    <xsl:template name="generate-toc-link">
        <xsl:if test="$outputformat = 'html'"><!-- TODO: improve ePub version of navigational aids -->
            <xsl:if test="//*[@id='toc'] and not(ancestor::q)">
                <!-- If we have an element with id 'toc', include a link to it (except in quoted material) -->
                <span class="pagenum">
                    <xsl:text>[</xsl:text>
                    <a>
                        <xsl:variable name="id" select="@id"/>
                        <xsl:call-template name="generate-href-attribute">
                            <!-- Link to entry for current division if available to make navigation back easier -->
                            <xsl:with-param name="target" select="if (//*[@id='toc']//ref[@target=$id]) then (//*[@id='toc']//ref[@target=$id])[1] else (//*[@id='toc'])[1]"/>
                        </xsl:call-template>
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
                        <a>
                            <xsl:call-template name="generate-href-attribute">
                                <xsl:with-param name="target" select="preceding-sibling::div1[1]"/>
                            </xsl:call-template>
                            <xsl:value-of select="f:message('msgPrevious')"/>
                        </a>
                    </xsl:if>

                    <xsl:if test="//*[@id='toc']">
                        <!-- If we have an element with id 'toc', include a link to it -->
                        <xsl:if test="preceding-sibling::div1"> | </xsl:if>
                        <a>
                            <xsl:call-template name="generate-href-attribute">
                                <xsl:with-param name="target" select="//*[@id='toc']"/>
                            </xsl:call-template>
                            <xsl:value-of select="f:message('msgToc')"/>
                         </a>
                    </xsl:if>

                    <xsl:if test="following-sibling::div1">
                        <xsl:if test="preceding-sibling::div1 or //*[@id='toc']"> | </xsl:if>

                        <a>
                            <xsl:call-template name="generate-href-attribute">
                                <xsl:with-param name="target" select="following-sibling::div1[1]"/>
                            </xsl:call-template>
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
        <xd:detail>Set the running header, for ePub3 only.</xd:detail>
    </xd:doc>

    <xsl:template name="setRunningHeader">
        <xsl:param name="head" select="."/>

        <xsl:if test="$optionEPubMarkup = 'XXX'">
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
                <xsl:apply-templates select="$head" mode="setLabelheader"/>
            </div>
        </xsl:if>
    </xsl:template>


    <!-- suppress footnotes -->
    <xsl:template match="note" mode="setLabelheader"/>


    <!--====================================================================-->
    <!-- code to align two divisions based on the @n attribute -->

    <xd:doc>
        <xd:short>Align two division based on the @n attribute in paragraphs.</xd:short>
        <xd:detail>Align two division based on the @n attribute in paragraphs. This code handles 
        the case where paragraphs are added or removed between aligned paragraphs, as can be
        expected in a more free translation.</xd:detail>
    </xd:doc>

    <xsl:template name="align-paragraphs">
        <xsl:param name="a"/>
        <xsl:param name="b"/>

        <!-- We collect all 'anchor' elements, i.e., elements with the
             same value of the @n attribute. Those we line up in our table,
             taking care to insert all elements inserted after that as well. -->

        <xsl:variable name="anchors" as="xs:string*">
            <xsl:for-each-group select="$a/*/@n, $b/*/@n" group-by=".">
                <xsl:if test="count(current-group()) = 2">
                    <xsl:sequence select="string(.)"/>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:variable>

        <table class="alignedtext">

            <!-- Handle matter before any anchor -->
            <xsl:if test="not($a/*[1]/@n = $anchors) or not($b/*[1]/@n = $anchors)">
                <tr>
                    <td class="first">
                        <xsl:if test="not($a/*[1]/@n = $anchors)">
                            <xsl:apply-templates select="$a/*[1]"/>
                            <xsl:call-template name="output-inserted-paragraphs">
                                <xsl:with-param name="start" select="$a/*[1]"/>
                                <xsl:with-param name="anchors" select="$anchors"/>
                            </xsl:call-template>
                        </xsl:if>
                    </td>
                    <td class="second">
                        <xsl:if test="not($b/*[1]/@n = $anchors)">
                            <xsl:apply-templates select="$b/*[1]"/>
                            <xsl:call-template name="output-inserted-paragraphs">
                                <xsl:with-param name="start" select="$b/*[1]"/>
                                <xsl:with-param name="anchors" select="$anchors"/>
                            </xsl:call-template>
                        </xsl:if>
                    </td>
                </tr>
            </xsl:if>

            <!-- Handle matter for all anchors -->
            <xsl:for-each select="$a/*[@n = $anchors]">
                <xsl:variable name="n" select="@n"/>

                <tr>
                    <td class="first">
                        <xsl:apply-templates select="."/>
                        <xsl:call-template name="output-inserted-paragraphs">
                            <xsl:with-param name="start" select="."/>
                            <xsl:with-param name="anchors" select="$anchors"/>
                        </xsl:call-template>
                    </td>
                    <td class="second">
                        <xsl:apply-templates select="$b/*[@n = $n]"/>
                        <xsl:call-template name="output-inserted-paragraphs">
                            <xsl:with-param name="start" select="$b/*[@n = $n]"/>
                            <xsl:with-param name="anchors" select="$anchors"/>
                        </xsl:call-template>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:template>

    <xd:doc>
        <xd:short>Output inserted paragraphs in aligned divisions.</xd:short>
        <xd:detail>Output paragraphs not present in the first division, but present in
        the second (that is, without a matching @n attribute).</xd:detail>
    </xd:doc>

    <xsl:template name="output-inserted-paragraphs">
        <xsl:param name="start" as="node()"/>
        <xsl:param name="anchors"/>
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


</xsl:stylesheet>
