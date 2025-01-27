<!DOCTYPE xsl:stylesheet [

    <!ENTITY nbsp       "&#160;">
    <!ENTITY ndash      "&#x2013;">
]>

<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="urn:stylesheet-functions"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="f xd xi xs">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to generate tables of contents.</xd:short>
        <xd:detail>
            <p>This stylesheet handles the <code>divGen</code> elements for tables of contents.</p>

            <p>The following are supported:</p>

            <table>
                <tr><td><code>&lt;divGen type="toc"/&gt;</code></td>        <td>Generates a standard table of contents.</td></tr>
                <tr><td><code>&lt;divGen type="toca"/&gt;</code></td>       <td>Generates a classical table of contents, with arguments taken from the chapter headings.</td></tr>
                <tr><td><code>&lt;divGen type="loi"/&gt;</code></td>        <td>Generates a list of illustrations.</td></tr>
                <tr><td><code>&lt;divGen type="gallery"/&gt;</code></td>    <td>Generates a gallery of thumbnails of all included illustrations.</td></tr>
                <tr><td><code>&lt;divGen type="footnotes"/&gt;</code></td>  <td>Generates a section with footnotes.</td></tr>
                <tr><td><code>&lt;div2 type="SubToc"/&gt;</code></td>       <td>Generates a table of contents at the <code>div2</code> level. This table replaces the actual content of the <code>div2</code> element.</td></tr>
            </table>
        </xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2012&ndash;2017, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Warn for unknown <code>divGen</code> types.</xd:short>
    </xd:doc>

    <xsl:template match="divGen">
        <xsl:copy-of select="f:log-warning('divGen element without or with unknown type: {1}.', (@type))"/>
    </xsl:template>


    <!--====================================================================-->
    <!-- Table of Contents -->

    <xd:doc>
        <xd:short>Generate a table of contents</xd:short>
        <xd:detail>
            <p>Generate a table of contents for a TEI file, including its head.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="divGen[@type='toc']">
        <div class="div1">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <h2 class="main"><xsl:value-of select="f:message('msgTableOfContents')"/></h2>
            <xsl:call-template name="toc-body-table"/>
        </div>
    </xsl:template>


    <xsl:variable name="toc-excluded" as="xs:string*" select="('Advertisement', 'Advertisements')"/>


    <xd:doc>
        <xd:short>Generate the table of contents body.</xd:short>
        <xd:detail>
            <p>Generate body of the table of contents for a TEI file. Take care only to generate ToC entries for divisions of the main text, not for those in quoted texts.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="divGen[@type='tocBody']">
        <xsl:call-template name="toc-body-table"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate the table of contents body (as an HTML list, OBSOLETE).</xd:short>
    </xd:doc>

    <xsl:template name="toc-body">
        <xsl:param name="list-element" select="'ul'" as="xs:string"/>

        <xsl:variable name="start" select="if (ancestor::group)
            then ancestor-or-self::text[./parent::group]
            else ancestor-or-self::text[last()]"/>
        <xsl:variable name="maxLevel" select="f:generated-toc-max-level(.)" as="xs:integer"/>

        <xsl:element name="{$list-element}">
            <xsl:apply-templates mode="gentoc" select="$start/front/div1 | $start/front/div">
                <xsl:with-param name="maxLevel" select="$maxLevel"/>
                <xsl:with-param name="divGenId" select="f:generate-id(.)"/>
                <xsl:with-param name="list-element" select="$list-element"/>
            </xsl:apply-templates>

            <xsl:apply-templates mode="gentoc" select="$start/group | $start/body/div0 | $start/body/div1 | $start/body/div">
                <xsl:with-param name="maxLevel" select="$maxLevel"/>
                <xsl:with-param name="divGenId" select="f:generate-id(.)"/>
                <xsl:with-param name="list-element" select="$list-element"/>
            </xsl:apply-templates>

            <xsl:apply-templates mode="gentoc" select="($start/back/div1 | $start/back/div)[not(@type = $toc-excluded)]">
                <xsl:with-param name="maxLevel" select="$maxLevel"/>
                <xsl:with-param name="divGenId" select="f:generate-id(.)"/>
                <xsl:with-param name="list-element" select="$list-element"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>

    <xsl:template match="titlePage" mode="gentoc"/>

    <xd:doc>
        <xd:short>Generate an entry in the table of contents (as an HTML list, OBSOLETE).</xd:short>
        <xd:detail>
            <p>Generate an entry for a division in the table of contents, and recursively generate lines for the underlying divisions.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="div | div0 | div1 | div2 | div3 | div4 | div5 | div6" mode="gentoc">
        <xsl:param name="maxLevel" as="xs:integer" select="7"/>
        <xsl:param name="divGenId" as="xs:string"/>
        <xsl:param name="list-element" as="xs:string" select="'ul'"/>

        <!-- Do we want to include this division in the toc? -->
        <xsl:if test="f:rend-value(@rend, 'display') != 'none' and f:rend-value(@rend, 'toc') != 'none'">
            <xsl:choose>
                <!-- Do we have a head to display in the toc? -->
                <xsl:when test="f:has-toc-head(.)">
                    <li id="{f:generate-id(.) || '.' || $divGenId}">
                        <xsl:call-template name="generate-toc-entry"/>
                        <xsl:if test="f:contains-div(.) and (f:div-level(.) &lt; $maxLevel) and not(@type='Index')">
                            <xsl:element name="{$list-element}">
                                <xsl:apply-templates select="./div | ./div0 | ./div1 | ./div2 | ./div3 | ./div4 | ./div5 | ./div6" mode="gentoc">
                                    <xsl:with-param name="maxLevel" select="$maxLevel"/>
                                    <xsl:with-param name="divGenId" select="$divGenId"/>
                                    <xsl:with-param name="list-element" select="$list-element"/>
                                </xsl:apply-templates>
                            </xsl:element>
                        </xsl:if>
                    </li>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="f:rend-value(@rend, 'toc') != 'none'">
                        <xsl:copy-of select="f:log-warning('No head for {1} {2}; this and underlying divisions will be omitted from the table of contents.', (name(.), @id))"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Test whether the division has a suitable head for display in a table of contents.</xd:short>
    </xd:doc>

    <xsl:function name="f:has-toc-head" as="xs:boolean">
        <xsl:param name="div" as="node()"/>

        <xsl:variable name="defaultHead">
            <xsl:if test="f:is-set('toc.defaultEntries')">
                <xsl:value-of select="f:default-toc-head($div/@type)"/>
            </xsl:if>
        </xsl:variable>

        <xsl:value-of select="if ($div/head or f:has-rend-value($div/@rend, 'toc-head') or $defaultHead != '') then 1 else 0"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Test whether a division contains further subdivisions.</xd:short>
    </xd:doc>

    <xsl:function name="f:contains-div" as="xs:boolean">
        <xsl:param name="div" as="node()"/>
        <xsl:sequence select="if ($div/div or $div/div0 or $div/div1 or $div/div2 or $div/div3 or $div/div4 or $div/div5 or $div/div6) then true() else false()"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Lookup a default head based on the division type for an entry in the table of contents.</xd:short>
    </xd:doc>

    <xsl:function name="f:default-toc-head" as="xs:string">
        <xsl:param name="type" as="xs:string"/>

        <xsl:variable name="head">
            <xsl:choose>
                <xsl:when test="$type = 'Colophon'"><xsl:value-of select="f:message('msgColophon')"/></xsl:when>
                <xsl:when test="$type = 'Cover'"><xsl:value-of select="f:message('msgCover')"/></xsl:when>
                <xsl:when test="$type = 'Imprint'"><xsl:value-of select="f:message('msgImprint')"/></xsl:when>
                <xsl:when test="$type = 'TitlePage'"><xsl:value-of select="f:message('msgTitlePage')"/></xsl:when>
                <xsl:when test="$type = 'Advertisement'"><xsl:value-of select="f:message('msgAdvertisement')"/></xsl:when>
                <xsl:when test="$type = 'Advertisements'"><xsl:value-of select="f:message('msgAdvertisements')"/></xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="$head"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate an entry in a table of contents, including its division number and page number.</xd:short>
    </xd:doc>

    <xsl:template name="generate-toc-entry">
        <xsl:param name="show-page-numbers" tunnel="yes" as="xs:boolean" select="true()"/>
        <xsl:param name="show-div-numbers" tunnel="yes" as="xs:boolean" select="true()"/>

        <xsl:if test="@n and f:is-set('toc.numberEntries') and $show-div-numbers and not(f:rend-value(@rend, 'toc-hide-number') = 'true')">
            <xsl:copy-of select="f:convert-markdown(@n)"/><xsl:text>. </xsl:text>
        </xsl:if>
        <a href="{f:generate-href(.)}">
            <xsl:call-template name="generate-single-head"/>
        </a>
        <xsl:if test="$show-page-numbers">
            <xsl:call-template name="insert-toc-page-number"/>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Combine all heads in a division into a single line for use in a table of contents.</xd:short>
        <xd:detail>
            <p>Called in context of a division (<code>div0</code>, <code>div1</code>, etc.). Combine all heads in a division into a
            single line, ignoring "super" and "label" type heads (unless the only available head is marked "label").</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="generate-single-head">
        <xsl:choose>

            <!-- Do we want to fully override the head for the toc using the toc-head() rendering? -->
            <xsl:when test="f:has-rend-value(@rend, 'toc-head')">
                <xsl:value-of select="f:rend-value(@rend, 'toc-head')"/>
            </xsl:when>

            <!-- Handle case where we only have a label as head -->
            <xsl:when test="head[@type='label'] and not(head[2])">
                <xsl:apply-templates select="head" mode="toc-head"/>
            </xsl:when>

            <xsl:when test="head">
                <!-- Handle all remaining headers in sequence -->
                <xsl:for-each select="head">
                    <xsl:choose>
                        <!-- Ignore super heads -->
                        <xsl:when test="@type='super'"/>
                        <!-- Ignore label heads -->
                        <xsl:when test="@type='label'"/>
                        <!-- Use alternative toc-head when present -->
                        <xsl:when test="f:has-rend-value(@rend, 'toc-head')">
                            <xsl:value-of select="f:rend-value(@rend, 'toc-head')"/>
                        </xsl:when>
                        <!-- Include the head given -->
                        <xsl:otherwise>
                            <xsl:apply-templates mode="toc-head"/>
                            <xsl:if test="following-sibling::head">
                                <xsl:text> </xsl:text>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>

            <xsl:otherwise>
                <xsl:value-of select="f:default-toc-head(@type)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <xsl:template name="generate-text-head">
        <xsl:choose>

            <!-- Do we want to fully override the head for the toc using the toc-head() rendering? -->
            <xsl:when test="f:has-rend-value(@rend, 'toc-head')">
                <xsl:value-of select="f:rend-value(@rend, 'toc-head')"/>
            </xsl:when>

            <!-- Try to get the title from the titlePage -->
            <xsl:when test="front/titlePage/docTitle/titlePart[@type='main' or not(@type)]">
                <xsl:value-of select="front/titlePage/docTitle/titlePart[@type='main' or not(@type)][1]"/>
                <xsl:if test="front/titlePage/docTitle/titlePart[@type='volume']">
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="front/titlePage/docTitle/titlePart[@type='volume'][1]"/>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Generating a span containing the page number the current node appears on, and a link to the current node.</xd:short>
    </xd:doc>

    <xsl:template name="insert-toc-page-number">
        <xsl:if test="preceding::pb[1]/@n and preceding::pb[1]/@n != ''">
            <xsl:text>&nbsp;&nbsp;&nbsp;&nbsp; </xsl:text>
            <span class="tocPageNum">
                <a class="pageref" href="{f:generate-href(.)}">
                    <xsl:copy-of select="f:convert-markdown(preceding::pb[1]/@n)"/>
                </a>
            </span>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Ignore notes that occur in heads in the toc.</xd:short>
    </xd:doc>

    <xsl:template match="note" mode="toc-head"/>


    <xd:doc>
        <xd:short>Ignore division numbers that appear in a head.</xd:short>
        <xd:detail>
            <p>Ignore division numbers that appear in a head, when they are indicated
            by <code>&lt;ab type="divNum"&gt;...&lt;/ab&gt;</code>.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="ab[@type='divNum']" mode="toc-head"/>

    <xsl:template match="ab[@type='lineNum']" mode="toc-head"/>


    <!--====================================================================-->
    <!-- Same as above, but now modified to have the toc placed in table. -->

    <xsl:template name="toc-body-table">
        <xsl:variable name="maxLevel" select="f:generated-toc-max-level(.)" as="xs:integer"/>

        <xsl:variable name="start" select="if (ancestor::group)
            then ancestor-or-self::text[./parent::group]
            else ancestor::text[last()]"/>
        <xsl:variable name="maxLevel" select="min((f:find-toc-max-depth($start), $maxLevel))"/>

        <table>
            <xsl:if test="f:is-html() and not(f:is-html5())">
                <xsl:attribute name="summary" select="f:message('msgTableOfContents')"/>
            </xsl:if>
            <xsl:apply-templates mode="gentoc-table" select="$start/front/div1 | $start/front/div">
                <xsl:with-param name="maxLevel" select="$maxLevel"/>
                <xsl:with-param name="divGenId" select="f:generate-id(.)"/>
            </xsl:apply-templates>

            <xsl:apply-templates mode="gentoc-table" select="$start/group | $start/body/div0 | $start/body/div1 | $start/body/div">
                <xsl:with-param name="maxLevel" select="$maxLevel"/>
                <xsl:with-param name="divGenId" select="f:generate-id(.)"/>
            </xsl:apply-templates>

            <xsl:apply-templates mode="gentoc-table" select="($start/back/div1 | $start/back/div)[not(@type = $toc-excluded)]">
                <xsl:with-param name="maxLevel" select="$maxLevel"/>
                <xsl:with-param name="divGenId" select="f:generate-id(.)"/>
            </xsl:apply-templates>
        </table>
    </xsl:template>


    <xsl:function name="f:generated-toc-max-level" as="xs:integer">
        <xsl:param name="divGen"/>

        <xsl:sequence select="if (f:has-rend-value($divGen/@rend, 'toc-max-level'))
            then xs:integer(f:rend-value($divGen/@rend, 'toc-max-level'))
            else 7"/>
    </xsl:function>


    <xsl:template match="group/text" mode="gentoc-table">
        <xsl:param name="maxLevel" as="xs:integer" select="7"/>
        <xsl:param name="curLevel" as="xs:integer" select="0"/>
        <xsl:param name="divGenId" as="xs:string"/>

        <tr id="{f:generate-id(.) || '.' || $divGenId}">
            <td class="tocText">
                <xsl:attribute name="colspan" select="$maxLevel + 2"/>
                <xsl:call-template name="generate-text-head"/>
            </td>
        </tr>

        <xsl:apply-templates mode="gentoc-table" select="./front/div1 | ./front/div">
            <xsl:with-param name="maxLevel" select="$maxLevel"/>
            <xsl:with-param name="divGenId" select="$divGenId"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="gentoc-table" select="./group | ./body/div0 | ./body/div1 | ./body/div">
            <xsl:with-param name="maxLevel" select="$maxLevel"/>
            <xsl:with-param name="divGenId" select="$divGenId"/>
        </xsl:apply-templates>

        <xsl:apply-templates mode="gentoc-table" select="(./back/div1 | ./back/div)[not(@type = $toc-excluded)]">
            <xsl:with-param name="maxLevel" select="$maxLevel"/>
            <xsl:with-param name="divGenId" select="$divGenId"/>
        </xsl:apply-templates>
    </xsl:template>


    <xsl:template match="div | div0 | div1 | div2 | div3 | div4 | div5 | div6" mode="gentoc-table">
        <xsl:param name="maxLevel" as="xs:integer" select="7"/>
        <xsl:param name="curLevel" as="xs:integer" select="0"/>
        <xsl:param name="divGenId" as="xs:string"/>

        <!-- Do we want to include this division in the toc? -->
        <xsl:if test="f:div-level(.) &lt;= $maxLevel and
                      f:rend-value(@rend, 'display') != 'none' and
                      f:rend-value(@rend, 'toc') != 'none'">
            <xsl:choose>
                <!-- Do we have a head to display in the toc? -->
                <xsl:when test="f:has-toc-head(.)">
                    <tr id="{f:generate-id(.) || '.' || $divGenId}">
                        <xsl:attribute name="class" select="'tocLevel' || $curLevel"/>
                        <xsl:call-template name="generate-toc-entry-table">
                            <xsl:with-param name="maxLevel" select="$maxLevel"/>
                            <xsl:with-param name="curLevel" select="$curLevel"/>
                        </xsl:call-template>
                    </tr>
                    <xsl:if test="f:contains-div(.) and not(@type='Index')">
                        <xsl:apply-templates select="./div | ./div0 | ./div1 | ./div2 | ./div3 | ./div4 | ./div5 | ./div6" mode="gentoc-table">
                            <xsl:with-param name="maxLevel" select="$maxLevel"/>
                            <xsl:with-param name="curLevel" select="$curLevel + 1"/>
                            <xsl:with-param name="divGenId" select="$divGenId"/>
                        </xsl:apply-templates>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="f:rend-value(@rend, 'toc') != 'none'">
                        <xsl:copy-of select="f:log-warning('No head for {1} {2}; this and underlying divisions will be omitted from the table of contents.', (name(.), @id))"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>


    <xsl:template name="generate-toc-entry-table">
        <xsl:param name="maxLevel" as="xs:integer"/>
        <xsl:param name="curLevel" as="xs:integer"/>
        <xsl:param name="show-page-numbers" tunnel="yes" as="xs:boolean" select="true()"/>
        <xsl:param name="show-div-numbers" tunnel="yes" as="xs:boolean" select="true()"/>

        <!-- Padding cell if needed to indent nested contents -->
        <xsl:if test="$curLevel > 0">
            <td>
                <xsl:if test="$curLevel > 1">
                    <xsl:attribute name="colspan" select="$curLevel"/>
                </xsl:if>
            </td>
        </xsl:if>
        <td class="tocDivNum">
            <xsl:if test="@n and f:is-set('toc.numberEntries') and $show-div-numbers and not(f:rend-value(@rend, 'toc-hide-number') = 'true')">
                <xsl:copy-of select="f:convert-markdown(@n)"/><xsl:text>. </xsl:text>
            </xsl:if>
        </td>
        <td class="tocDivTitle">
            <xsl:if test="$maxLevel - $curLevel > 1">
                <xsl:attribute name="colspan" select="$maxLevel - $curLevel"/>
            </xsl:if>
            <a href="{f:generate-href(.)}">
                <xsl:call-template name="generate-single-head"/>
            </a>
        </td>
        <td class="tocPageNum">
            <xsl:if test="$show-page-numbers">
                <xsl:call-template name="insert-toc-page-number-table"/>
            </xsl:if>
        </td>
    </xsl:template>


    <xsl:template name="insert-toc-page-number-table">
        <xsl:if test="preceding::pb[1]/@n and preceding::pb[1]/@n != ''">
            <a class="pageref" href="{f:generate-href(.)}">
                <xsl:copy-of select="f:convert-markdown(preceding::pb[1]/@n)"/>
            </a>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Determine an element is actually included in the ToC.</xd:short>
    </xd:doc>

    <xsl:function name="f:included-in-toc" as="xs:boolean">
        <xsl:param name="div" as="element()"/>
        <xsl:param name="maxLevel" as="xs:integer"/>

        <xsl:sequence select="f:is-toc-div($div) and f:div-level($div) &lt;= $maxLevel"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine an element can be included in a ToC.</xd:short>
        <xd:detail>
            <p>Determine an element can potentially be included in a table of contents. Verify the following:</p>
            <ul>
                <li>The element is a <code>div</code> element.</li>
                <li>The division has a suitable head to display.</li>
                <li>The division is not of an excluded type.</li>
                <li>The division is actually displayed.</li>
                <li>The division is not explicitly excluded.</li>
                <li>The division is not a child of an index or quotation.</li>
                <li>The parent is either a front, body or back, or itself an element that can be included in the ToC.</li>
            </ul>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:is-toc-div" as="xs:boolean">
        <xsl:param name="node" as="element()"/>
        <xsl:sequence select="exists(
              $node
                [self::div or self::div0 or self::div1 or self::div2 or self::div3 or self::div4 or self::div5 or self::div6]
                [f:has-toc-head(.)]
                [not(./@type = $toc-excluded)]
                [f:rend-value(./@rend, 'display') != 'none']
                [f:rend-value(./@rend, 'toc') != 'none']
                [not(ancestor::*/@type = 'Index')]
                [not(ancestor::q)]
                [parent::front or parent::body or parent::back or f:is-toc-div(parent::*)]
            )"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine the maximum depth of the ToC.</xd:short>
    </xd:doc>

    <xsl:function name="f:find-toc-max-depth" as="xs:integer">
        <xsl:param name="start"/>

        <xsl:variable name="toc-max-depth">
            <!-- Find all divisions that do not have further divisions in them. -->
            <xsl:for-each select="$start//*[f:is-toc-div(.)][not(*[f:is-toc-div(.)])]">
                <!-- Sort by the number of divisions they have as ancestor -->
                <xsl:sort select="count(ancestor::*[f:is-toc-div(.)])" data-type="number" order="descending"/>
                <!-- Get the number of ancestors for the first one -->
                <xsl:if test="position() = 1">
                    <xsl:value-of select="count(ancestor::*[f:is-toc-div(.)]) + 1"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:sequence select="$toc-max-depth"/>
    </xsl:function>

    <xsl:function name="f:find-toc-list-max-depth" as="xs:integer">
        <xsl:param name="start" as="element(list)"/>

        <xsl:variable name="toc-max-depth">
            <!-- Find all toc-lists that do not have further sub-toc-lists in them. -->
            <xsl:for-each select="$start/descendant-or-self::list[@type='tocList'][not(descendant::list[@type='tocList'])]">
                <!-- Sort by the number of toc-lists they have as ancestor -->
                <xsl:sort select="count(ancestor::list[@type='tocList'])" data-type="number" order="descending"/>
                <!-- Get the number of ancestors for the first one -->
                <xsl:if test="position() = 1">
                    <xsl:value-of select="count(ancestor::list[@type='tocList']) + 1"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:sequence select="$toc-max-depth"/>
    </xsl:function>



    <!--====================================================================-->
    <!-- A classic table of contents with chapter labels, titles and arguments. -->

    <xd:doc>
        <xd:short>Generate a classic table of contents with chapter labels, titles and arguments.</xd:short>
        <xd:detail>
            <p>Generate a classic table of contents with chapter labels, titles and arguments. This table of contents only goes one level deep.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="divGen[@type='toca']">
        <xsl:variable name="start" select="if (ancestor::group)
            then ancestor-or-self::text[./parent::group]
            else ancestor::text[last()]"/>

        <div class="div1">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <h2 class="main"><xsl:value-of select="f:message('msgTableOfContents')"/></h2>

            <xsl:apply-templates mode="gentoca" select="$start/front/div1"/>
            <xsl:apply-templates mode="gentoca" select="if ($start/body/div0) then $start/body/div0 else $start/body/div1"/>
            <xsl:apply-templates mode="gentoca" select="$start/back/div1[not(@type = $toc-excluded)]"/>
        </div>
    </xsl:template>


    <xsl:template match="div0|div1" mode="gentoca">
        <xsl:if test="head and f:rend-value(@rend, 'toc') != 'none'">
            <xsl:if test="head[@type='label']">
                <p class="tocChapter">
                    <a href="{f:generate-href(.)}">
                        <xsl:apply-templates select="head[@type='label']" mode="toc-head"/>
                    </a>
                    <xsl:if test="not(head[not(@type)])">
                        <xsl:call-template name="insert-toc-page-number"/>
                    </xsl:if>
                </p>
            </xsl:if>
            <xsl:if test="head[not(@type)]">
                <p class="tocChapter">
                    <a href="{f:generate-href(.)}">
                        <xsl:apply-templates select="head[not(@type)]" mode="toc-head"/>
                    </a>
                    <xsl:call-template name="insert-toc-page-number"/>
                </p>
            </xsl:if>
            <xsl:if test="argument">
                <p class="tocArgument">
                    <xsl:apply-templates select="argument" mode="toc-head"/>
                </p>
            </xsl:if>
        </xsl:if>
        <xsl:if test="div1">
            <ul>
                <xsl:apply-templates select="div1" mode="gentoca"/>
            </ul>
        </xsl:if>
    </xsl:template>


    <!--====================================================================-->
    <!-- SubToc (special handling for Tribes and Castes volumes) -->

    <xd:doc>
        <xd:short>Replace a div2 element with a generated toc.</xd:short>
        <xd:detail>
            <p>A SubToc is a short table of contents at div2 level, which appears at the beginning of a div1.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="div2[@type='SubToc']">
        <!-- Render heading in normal way -->
        <xsl:apply-templates select="head"/>

        <!-- Generate the table of contents -->
        <xsl:call-template name="SubToc"/>

        <!-- Ignore original content -->
    </xsl:template>


    <xsl:template name="SubToc">
        <ul>
            <xsl:apply-templates select="../div2[@type != 'SubToc']" mode="gentoc">
                <xsl:with-param name="divGenId" select="f:generate-id(.)"/>
            </xsl:apply-templates>
        </ul>
    </xsl:template>


    <!-- Do not list subordinate tables of contents (the actual subtoc will be replaced by a generated table of contents and links will not work properly) -->
    <xsl:template match="div2[@type='SubToc']" mode="gentoc"/>


    <!--====================================================================-->

    <xd:doc>
        <xd:short>Generate a list of illustrations.</xd:short>
    </xd:doc>

    <xsl:template match="divGen[@type='loi']">
        <div class="div1">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <h2 class="main"><xsl:value-of select="f:message('msgListOfIllustrations')"/></h2>
            <ul>
                <xsl:apply-templates select="//figure[head and not(./ancestor::figure)]" mode="genloi"/>
            </ul>
        </div>
    </xsl:template>

    <xd:doc>
        <xd:short>Generate an entry in the list of illustrations.</xd:short>
    </xd:doc>

    <xsl:template match="figure" mode="genloi">
        <!-- TODO: make id unique for each occurrence of <divGen type="loi"> -->
        <li id="loi.{f:generate-id(.)}">
            <xsl:copy-of select="f:generate-lang-attribute(@lang)"/>
            <xsl:call-template name="generate-toc-entry"/>
            <xsl:if test=".//figure[head]">
                <ul>
                    <xsl:apply-templates select=".//figure[head]" mode="genloi"/>
                </ul>
            </xsl:if>
        </li>
    </xsl:template>


    <!--====================================================================-->

    <xd:doc>
        <xd:short>Generate a thumbnail gallery.</xd:short>
        <xd:detail>
            <p>Generate a gallery of thumbnail images. This template assumes that for each image, a thumbnail is
            available, and will use that image in a gallery, linking to the original (full-size) image.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="divGen[@type='gallery' or @type='Gallery']">
        <div class="div1">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <h2 class="main"><xsl:value-of select="f:message('msgListOfIllustrations')"/></h2>
            <table>
                <xsl:call-template name="splitrows">
                    <xsl:with-param name="figures" select="//figure[@id]" />
                    <xsl:with-param name="columns" select="3" />
                </xsl:call-template>
            </table>
        </div>
    </xsl:template>


    <xsl:template name="splitrows">
        <xsl:param name="figures"/>
        <xsl:param name="columns"/>
        <xsl:for-each select="$figures[position() mod $columns = 1]">
            <tr>
                <xsl:apply-templates select=". | following::figure[position() &lt; $columns]" mode="gallery"/>
            </tr>
            <tr>
                <xsl:apply-templates select=". | following::figure[position() &lt; $columns]" mode="gallery-caption"/>
            </tr>
        </xsl:for-each>
    </xsl:template>


    <xd:doc>
        <xd:short>Determine the filename of the thumbnail image.</xd:short>
        <xd:detail>
            <p>The name of the thumbnail image file is assumed to be the same as the full-size image,
            but is located in a subdirectory <code>thumbs</code> of the directory it appears in.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:determine-thumbnail-filename" as="xs:string">
        <xsl:param name="node" as="element(figure)"/>

        <xsl:variable name="filename" select="f:determine-image-filename($node, '.jpg')"/>
        <xsl:variable name="file" select="tokenize($filename, '/')[last()]"/>
        <xsl:variable name="path" select="substring($filename, 1, string-length($filename) - string-length($file))"/>
        <xsl:sequence select="$path || 'thumbs/' || $file"/>
    </xsl:function>


    <xsl:template match="figure" mode="gallery">
        <td class="galleryFigure">
            <a href="{f:generate-href(.)}">
                <xsl:copy-of select="f:output-image(f:determine-thumbnail-filename(.), f:determine-image-alt-text(., ''))"/>
            </a>
        </td>
    </xsl:template>


    <xsl:template match="figure" mode="gallery-caption">
        <td class="galleryCaption">
            <a href="{f:generate-href(.)}">
                <xsl:apply-templates select="head" mode="toc-head"/>
            </a>
        </td>
    </xsl:template>


    <xd:doc>
        <xd:short>Render a table of contents encoded as a list as a table.</xd:short>

        <xd:detail>
            <p>Render a pre-existing table of contents encoded as an itemized list as a table.
            Nested lists are integrated into a single table.</p>

            <p>This depends on the following convention being applied to structure the list representing a table of contents:</p>

            <pre>
                &lt;list type='tocList'&gt;
                    &lt;item&gt; &lt;ab type='tocDivNum'&gt;DIVISION NUMBER&lt;/ab&gt; DIVISION TITLE &lt;ab type='tocPageNum'&gt;PAGE NUMBER&lt;/ab&gt;
                        &lt;list type='tocList'&gt;
                            ...
                        &lt;/list&gt;
                    &lt;/item&gt;
                &lt;/list&gt;
            </pre>

            <p>This will result in an HTML table, in which the item numbers are placed in cells on the left, the items themselves in
            spanned cells in the middle (made to span fewer columns as they are part of deeply nested items), and the page numbers
            in a cell on the right.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="list[@type='tocList']">
        <xsl:choose>
            <!-- Outer list -->
            <xsl:when test="not(ancestor::list[@type='tocList'])">
                <xsl:call-template name="closepar"/>
                <table>
                    <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                    <xsl:copy-of select="f:set-class-attribute-with(., 'tocList')"/>
                    <xsl:apply-templates mode="tocList">
                        <xsl:with-param name="maxDepth" select="f:find-toc-list-max-depth(.)" tunnel="yes"/>
                    </xsl:apply-templates>
                </table>
                <xsl:call-template name="reopenpar"/>
            </xsl:when>
            <!-- Nested list, part of table generated for outermost list -->
            <xsl:otherwise>
                <xsl:apply-templates mode="tocList"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="tocList" match="item">
        <xsl:param name="maxDepth" tunnel="yes"/>

        <xsl:variable name="depth" select="count(ancestor::list[@type='tocList']) - 1"/>
        <tr>
            <xsl:copy-of select="f:set-class-attribute(.)"/>
            <!-- Use padding cell if needed to indent nested contents -->
            <xsl:if test="$depth > 0">
                <td>
                    <xsl:if test="$depth > 1">
                        <xsl:attribute name="colspan"><xsl:value-of select="$depth"/></xsl:attribute>
                    </xsl:if>
                </td>
            </xsl:if>
            <td>
                <xsl:copy-of select="f:set-class-attribute-with(ab[@type='tocDivNum'], 'tocDivNum')"/>
                <xsl:apply-templates mode="tocList" select="ab[@type='tocDivNum']"/>
            </td>
            <td class="tocDivTitle">
                <xsl:if test="$maxDepth - $depth > 1">
                    <xsl:attribute name="colspan"><xsl:value-of select="$maxDepth - $depth"/></xsl:attribute>
                </xsl:if>
                <xsl:apply-templates select="text()|*[not(@type='tocDivNum' or @type='tocPageNum' or @type='tocList')]"/>
            </td>
            <td>
                <xsl:copy-of select="f:set-class-attribute-with(ab[@type='tocPageNum'], 'tocPageNum')"/>
                <xsl:apply-templates mode="tocList" select="ab[@type='tocPageNum']"/>
            </td>
        </tr>
        <!-- Render the nested list (omitted before) -->
        <xsl:apply-templates select="*[@type='tocList']"/>
    </xsl:template>

    <xsl:template mode="tocList" match="ab">
        <xsl:apply-templates/>
    </xsl:template>


    <xd:doc>
        <xd:short>Render a determination table encoded as a list as a table.</xd:short>

        <xd:detail>
            <p>Render a determination table (as used in biology books) encoded as an itemized list as a table.</p>

            <p>The code is fairly similar to the code for tables of contents above. This depends on the following
            convention being applied to structure the list representing a determination table:</p>

            <pre>
                &lt;list type='determinationTable'&gt;
                    &lt;item&gt; &lt;ab type='itemNum'&gt;ITEM NUMBER&lt;/ab&gt; OBSERVATION &lt;ab type='determination'&gt;DETERMINATION or CROSS REFERENCE&lt;/ab&gt;
                        &lt;list type='determinationTable'&gt;
                            ...
                        &lt;/list&gt;
                    &lt;/item&gt;
                &lt;/list&gt;
            </pre>

            <p>This will result in an HTML table, in which the item numbers are placed in cells on the left, the items themselves in
            spanned cells to the right (made to span fewer columns as they are part of deeply nested items) together with the
            determinations, such that the latter are set flush-right, and won't collide (using an inner table).</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="list[@type='determinationTable']">
        <xsl:call-template name="closepar"/>
        <xsl:choose>
            <!-- Outer list -->
            <xsl:when test="not(ancestor::list[@type='determinationTable'])">
                <table class="tocList">
                    <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                    <xsl:apply-templates mode="determinationTable"/>
                </table>
            </xsl:when>
            <!-- Nested list, part of table generated for outermost list -->
            <xsl:otherwise>
                <xsl:apply-templates mode="determinationTable"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>

    <xsl:template mode="determinationTable" match="item">
        <xsl:variable name="depth" select="count(ancestor::list[@type='determinationTable']) - 1"/>

        <tr>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <!-- Use padding cell if needed to indent nested contents -->
            <xsl:if test="$depth > 0">
                <td>
                    <xsl:if test="$depth > 1">
                        <xsl:attribute name="colspan"><xsl:value-of select="$depth"/></xsl:attribute>
                    </xsl:if>
                </td>
            </xsl:if>
            <td class="itemNum">
                <xsl:apply-templates mode="determinationTable" select="ab[@type='itemNum']"/>
            </td>
            <xsl:choose>
                <!-- No determination to be set flush right? -->
                <xsl:when test="not(*[@type='determination'])">
                    <td colspan="{7 - $depth}">
                        <xsl:apply-templates select="text()|*[not(@type='itemNum' or @type='determination' or @type='determinationTable')]"/>
                    </td>
                </xsl:when>
                <xsl:otherwise>
                    <td colspan="{7 - $depth}" class="innerContainer">
                        <table class="inner">
                            <tr>
                                <td><xsl:apply-templates select="text()|*[not(@type='itemNum' or @type='determination' or @type='determinationTable')]"/></td>
                                <td class="alignright"><xsl:apply-templates mode="tocList" select="ab[@type='determination']"/></td>
                            </tr>
                        </table>
                    </td>
                </xsl:otherwise>
            </xsl:choose>
        </tr>
        <!-- Render the nested list (omitted before) -->
        <xsl:apply-templates select="*[@type='determinationTable']"/>
    </xsl:template>

    <xsl:template mode="determinationTable" match="ab">
        <xsl:apply-templates/>
    </xsl:template>

    <!--====================================================================-->

    <xd:doc>
        <xd:short>Generate a footnote section.</xd:short>
        <xd:detail>
            <p>Generate a footnote section, complete with head.</p>
        </xd:detail>
    </xd:doc>

    <!-- collect footnotes in a separate section, optionally divided by division -->
    <xsl:template match="divGen[@type='Footnotes' or @type='footnotes']">
        <div class="div1 notes">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <h2 class="main"><xsl:value-of select="f:message('msgNotes')"/></h2>
            <xsl:call-template name="footnotes-body"/>
        </div>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate the body of a footnote section only.</xd:short>
    </xd:doc>

    <xsl:template match="divGen[@type='footnotesBody']">
        <xsl:call-template name="footnotes-body"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate the footnote section (implementation).</xd:short>
        <xd:detail>
            <p>Generate the footnote section. Collect all footnotes in the text,
            and present them, optionally divided by division, depending on how
            the footnote counter is configured.</p>
        </xd:detail>
    </xd:doc>


    <xsl:template name="footnotes-body">
        <xsl:choose>
            <xsl:when test="f:get-setting('notes.foot.counter') = 'text'">
                <xsl:call-template name="footnotes-body-single"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="footnotes-body-by-division"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="footnotes-body-by-division">
        <xsl:apply-templates select="//front/div1[not(ancestor::q)]" mode="divgen-footnotes"/>
        <xsl:choose>
            <xsl:when test="//body/div0">
                <xsl:apply-templates select="//body/div0[not(ancestor::q)]" mode="divgen-footnotes"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="//body/div1[not(ancestor::q)]" mode="divgen-footnotes"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="//back/div1[not(ancestor::q)]" mode="divgen-footnotes"/>
    </xsl:template>


    <xsl:template match="div0" mode="divgen-footnotes">
        <!-- Only mention the part if it has footnotes (not in the chapters) -->
        <xsl:if test=".//note[f:is-footnote(.) and not(ancestor::div1) and not(@sameAs)]">
            <div class="div2 notes">
                <xsl:call-template name="footnote-sectionhead"/>
                <xsl:apply-templates select=".//note[f:is-footnote(.) and not(ancestor::div1) and not(@sameAs)]" mode="footnotes"/>
            </div>
        </xsl:if>
        <xsl:apply-templates select="div1[not(ancestor::q)]" mode="divgen-footnotes"/>
    </xsl:template>


    <xsl:template match="div1" mode="divgen-footnotes">
        <!-- Only mention the chapter if it has footnotes -->
        <xsl:if test=".//note[f:is-footnote(.) and not(@sameAs)]">
            <div class="div2 notes">
                <xsl:call-template name="footnote-sectionhead"/>
                <xsl:apply-templates select=".//note[f:is-footnote(.) and not(@sameAs)]" mode="footnotes"/>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="footnote-sectionhead">
        <h3 class="main">
            <xsl:if test="@n">
                <xsl:copy-of select="f:convert-markdown(@n)"/><xsl:text>. </xsl:text>
            </xsl:if>
            <xsl:call-template name="generate-single-head"/>
        </h3>
    </xsl:template>


    <xsl:template name="footnotes-body-single">
        <div class="div2 notes">
            <xsl:apply-templates select="//front/div1[not(ancestor::q)]" mode="divgen-footnotes-single"/>
            <xsl:choose>
                <xsl:when test="//body/div0">
                    <xsl:apply-templates select="//body/div0[not(ancestor::q)]" mode="divgen-footnotes-single"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="//body/div1[not(ancestor::q)]" mode="divgen-footnotes-single"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="//back/div1[not(ancestor::q)]" mode="divgen-footnotes-single"/>
        </div>
    </xsl:template>


    <xsl:template match="div0" mode="divgen-footnotes-single">
        <xsl:apply-templates select=".//note[f:is-footnote(.) and not(ancestor::div1) and not(@sameAs)]" mode="footnotes"/>
        <xsl:apply-templates select="div1[not(ancestor::q)]" mode="divgen-footnotes-single"/>
    </xsl:template>


    <xsl:template match="div1" mode="divgen-footnotes-single">
        <xsl:apply-templates select=".//note[f:is-footnote(.) and not(@sameAs)]" mode="footnotes"/>
    </xsl:template>


    <!--====================================================================-->
    <!-- Included material (alternative for xi:include); also take care relevant CSS styles are generated. -->

    <xsl:template match="divGen[@type='Inclusion']" mode="#default css style css-column css-row style-column style-row">

        <xsl:variable name="url" select="if (@url) then @url else f:rend-value(@rend, 'include')"/>
        <xsl:if test="$url">
            <xsl:copy-of select="f:log-info('Including {1}.', ($url))"/>
            <xsl:variable name="document" select="substring-before($url, '#')"/>
            <xsl:variable name="fragmentId" select="substring-after($url, '#')"/>
            <xsl:variable name="content"
                select="if ($fragmentId)
                    then document($document, .)//*[@id=$fragmentId]
                    else document($url, .)/*"/>
            <xsl:if test="not($content)">
                <xsl:copy-of select="f:log-error('{1} is empty.', ($url))"/>
            </xsl:if>
            <xsl:apply-templates mode="#current" select="$content"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="xi:include" mode="#default css style css-column css-row style-column style-row">
        <!-- Material to be included should be rendered here; material is given on using the @href attribute. -->
        <xsl:if test="@href">
            <xsl:copy-of select="f:log-info('Including {1}.', (@href))"/>
            <xsl:variable name="document" select="substring-before(@href, '#')"/>
            <xsl:variable name="fragmentId" select="substring-after(@href, '#')"/>
            <xsl:variable name="content"
                select="if ($fragmentId)
                    then document($document, .)//*[@id=$fragmentId]
                    else document(@href, .)/*"/>
            <xsl:if test="not($content)">
                <xsl:copy-of select="f:log-error('{1} is empty.', (@href))"/>
            </xsl:if>
            <xsl:apply-templates mode="#current" select="$content"/>
        </xsl:if>
    </xsl:template>


    <!--====================================================================-->
    <!-- proto-Bibliography, to help build a bibliography from bibl-elements. -->

    <xsl:template match="divGen[@type='protoBibliography']">
        <xsl:if test="//bibl">
            <h3 class="main"><xsl:value-of select="f:message('msgBibliography')"/></h3>

            <ul>
                <xsl:for-each select="//bibl">
                    <xsl:sort select="."/>
                    <li><xsl:apply-templates select="."/></li>
                </xsl:for-each>
            </ul>
        </xsl:if>
    </xsl:template>


</xsl:stylesheet>
