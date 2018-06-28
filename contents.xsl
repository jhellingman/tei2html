<!DOCTYPE xsl:stylesheet [

    <!ENTITY nbsp       "&#160;">
    <!ENTITY ndash      "&#x2013;">

]>

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:tmp="urn:temporary-nodes"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f tmp xd xhtml xs"
    version="2.0"
    >

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
        <xsl:copy-of select="f:logWarning('divGen element without or with unknown type: {1}.', (@type))"/>
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
        <xd:short>Generate the table of contents body (as a HTML list, OBSOLETE).</xd:short>
    </xd:doc>

    <xsl:template name="toc-body">
        <xsl:param name="list-element" select="'ul'" as="xs:string"/>

        <xsl:variable name="maxlevel">
            <xsl:choose>
                <xsl:when test="f:has-rend-value(@rend, 'tocMaxLevel')">
                    <xsl:value-of select="f:rend-value(@rend, 'tocMaxLevel')"/>
                </xsl:when>
                <xsl:otherwise>7</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:element name="{$list-element}">
            <xsl:apply-templates mode="gentoc" select="/*[self::TEI.2 or self::TEI]/text/front/div1 | /*[self::TEI.2 or self::TEI]/text/front/div">
                <xsl:with-param name="maxlevel" select="$maxlevel"/>
                <xsl:with-param name="list-element" select="$list-element"/>
            </xsl:apply-templates>

            <xsl:apply-templates mode="gentoc" select="if (/*[self::TEI.2 or self::TEI]/text/body/div0) then /*[self::TEI.2 or self::TEI]/text/body/div0 else (/*[self::TEI.2 or self::TEI]/text/body/div1 | /*[self::TEI.2 or self::TEI]/text/body/div)">
                <xsl:with-param name="maxlevel" select="$maxlevel"/>
                <xsl:with-param name="list-element" select="$list-element"/>
            </xsl:apply-templates>

            <xsl:apply-templates mode="gentoc" select="(/*[self::TEI.2 or self::TEI]/text/back/div1 | /*[self::TEI.2 or self::TEI]/text/back/div)[not(@type='Ads') and not(@type='Advertisment')]">
                <xsl:with-param name="maxlevel" select="$maxlevel"/>
                <xsl:with-param name="list-element" select="$list-element"/>
            </xsl:apply-templates>
        </xsl:element>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate an entry in the table of contents (as a HTML list, OBSOLETE).</xd:short>
        <xd:detail>
            <p>Generate an entry for a division in the table of contents, and recursively generate lines for the underlying divisions.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="div | div0 | div1 | div2 | div3 | div4 | div5 | div6" mode="gentoc">
        <xsl:param name="maxlevel" as="xs:integer" select="7"/>
        <xsl:param name="list-element" as="xs:string" select="'ul'"/>

        <!-- Do we want to include this division in the toc? -->
        <xsl:if test="f:rend-value(@rend, 'display') != 'none' and f:rend-value(@rend, 'toc') != 'none'">
            <xsl:choose>
                <!-- Do we have a head to display in the toc? -->
                <xsl:when test="f:has-toc-head(.)">
                    <li>
                        <xsl:call-template name="generate-toc-entry"/>
                        <xsl:if test="f:contains-div(.) and (f:div-level(.) &lt; $maxlevel) and not(@type='Index')">
                            <xsl:element name="{$list-element}">
                                <xsl:apply-templates select="div | div0 | div1 | div2 | div3 | div4 | div5 | div6" mode="gentoc">
                                    <xsl:with-param name="maxlevel" select="$maxlevel"/>
                                    <xsl:with-param name="list-element" select="$list-element"/>
                                </xsl:apply-templates>
                            </xsl:element>
                        </xsl:if>
                    </li>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="f:rend-value(@rend, 'toc') != 'none'">
                        <xsl:copy-of select="f:logWarning('No head for {1} {2}; this and underlying divisions will be omitted from the table of contents.', (name(.), @id))"/>
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
            <xsl:if test="f:isSet('defaultTocEntries')">
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
        <xsl:value-of select="if ($div/div or $div/div0 or $div/div1 or $div/div2 or $div/div3 or $div/div4 or $div/div5 or $div/div6) then 1 else 0"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine the level of the division (by counting its parents or looking at its name).</xd:short>
    </xd:doc>

    <xsl:function name="f:div-level" as="xs:integer">
        <xsl:param name="div" as="node()"/>
        <xsl:choose>
            <xsl:when test="local-name($div) = 'div'">
                <xsl:value-of select="count($div/ancestor::div)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring(local-name($div), 4)"/>
            </xsl:otherwise>
        </xsl:choose>
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
                <xsl:when test="$type = 'Ad'"><xsl:value-of select="f:message('msgAdvertisement')"/></xsl:when>
                <xsl:when test="$type = 'Ads'"><xsl:value-of select="f:message('msgAdvertisements')"/></xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="$head"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate an entry in a table of contents, including its number and pagenumber.</xd:short>
    </xd:doc>

    <xsl:template name="generate-toc-entry">
        <xsl:param name="show-page-numbers" tunnel="yes" as="xs:boolean" select="true()"/>
        <xsl:param name="show-div-numbers" tunnel="yes" as="xs:boolean" select="true()"/>

        <xsl:if test="@n and f:isSet('numberTocEntries') and $show-div-numbers">
            <xsl:value-of select="@n"/><xsl:text>. </xsl:text>
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
                <xsl:apply-templates mode="tochead" select="head"/>
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
                            <xsl:apply-templates mode="tochead"/>
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


    <xd:doc>
        <xd:short>Generating a span containing the page number the current node appears on, and a link to the current node.</xd:short>
    </xd:doc>

    <xsl:template name="insert-toc-page-number">
        <xsl:if test="preceding::pb[1]/@n and preceding::pb[1]/@n != ''">
            <xsl:text>&nbsp;&nbsp;&nbsp;&nbsp; </xsl:text>
            <span class="tocPageNum">
                <a class="pageref" href="{f:generate-href(.)}">
                    <xsl:value-of select="preceding::pb[1]/@n"/>
                </a>
            </span>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Ignore notes that occur in heads in the toc.</xd:short>
    </xd:doc>

    <xsl:template match="note" mode="tochead"/>


    <xd:doc>
        <xd:short>Ignore division numbers that appear in a head.</xd:short>
        <xd:detail>
            <p>Ignore division numbers that appear in a head, when they are indicated
            by <code>&lt;ab type="divNum"&gt;...&lt;/ab&gt;</code>.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="ab[@type='divNum']" mode="tochead"/>

    <xsl:template match="ab[@type='lineNum']" mode="tochead"/>

    <xd:doc>
        <xd:short>Handle text styles in chapter heads.</xd:short>
    </xd:doc>

    <xsl:template match="hi" mode="tochead">
        <i>
            <xsl:apply-templates mode="tochead"/>
        </i>
    </xsl:template>

    <xsl:template match="hi[@rend='italic']" mode="tochead">
        <i>
            <xsl:apply-templates mode="tochead"/>
        </i>
    </xsl:template>

    <xsl:template match="hi[@rend='bold']" mode="tochead">
        <b>
            <xsl:apply-templates mode="tochead"/>
        </b>
    </xsl:template>

    <xsl:template match="hi[@rend='sc']" mode="tochead">
        <span class="sc">
            <xsl:apply-templates mode="tochead"/>
        </span>
    </xsl:template>

    <xsl:template match="hi[@rend='sup']" mode="tochead">
        <sup>
            <xsl:apply-templates mode="tochead"/>
        </sup>
    </xsl:template>


    <!--====================================================================-->
    <!-- Same as above, but now modified to have the toc placed in table -->

    <xsl:template name="toc-body-table">
        <xsl:variable name="maxlevel">
            <xsl:choose>
                <xsl:when test="f:has-rend-value(@rend, 'tocMaxLevel')">
                    <xsl:value-of select="f:rend-value(@rend, 'tocMaxLevel')"/>
                </xsl:when>
                <xsl:otherwise>7</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <table>
            <xsl:apply-templates mode="gentoc-table" select="/*[self::TEI.2 or self::TEI]/text/front/div1 | /*[self::TEI.2 or self::TEI]/text/front/div">
                <xsl:with-param name="maxlevel" select="$maxlevel"/>
            </xsl:apply-templates>

            <xsl:apply-templates mode="gentoc-table" select="if (/*[self::TEI.2 or self::TEI]/text/body/div0) then /*[self::TEI.2 or self::TEI]/text/body/div0 else (/*[self::TEI.2 or self::TEI]/text/body/div1 | /*[self::TEI.2 or self::TEI]/text/body/div)">
                <xsl:with-param name="maxlevel" select="$maxlevel"/>
            </xsl:apply-templates>

            <xsl:apply-templates mode="gentoc-table" select="(/*[self::TEI.2 or self::TEI]/text/back/div1 | /*[self::TEI.2 or self::TEI]/text/back/div)[not(@type='Ads') and not(@type='Advertisment')]">
                <xsl:with-param name="maxlevel" select="$maxlevel"/>
            </xsl:apply-templates>
        </table>
    </xsl:template>


    <xsl:template match="div | div0 | div1 | div2 | div3 | div4 | div5 | div6" mode="gentoc-table">
        <xsl:param name="maxlevel" as="xs:integer" select="7"/>
        <xsl:param name="curlevel" as="xs:integer" select="0"/>

        <!-- Do we want to include this division in the toc? -->
        <xsl:if test="f:rend-value(@rend, 'display') != 'none' and f:rend-value(@rend, 'toc') != 'none'">
            <xsl:choose>
                <!-- Do we have a head to display in the toc? -->
                <xsl:when test="f:has-toc-head(.)">
                    <tr>
                        <xsl:call-template name="generate-toc-entry-table">
                            <xsl:with-param name="maxlevel" select="$maxlevel"/>
                            <xsl:with-param name="curlevel" select="$curlevel"/>
                        </xsl:call-template>
                    </tr>
                    <xsl:if test="f:contains-div(.) and (f:div-level(.) &lt; $maxlevel) and not(@type='Index')">
                        <xsl:apply-templates select="div | div0 | div1 | div2 | div3 | div4 | div5 | div6" mode="gentoc-table">
                            <xsl:with-param name="maxlevel" select="$maxlevel"/>
                            <xsl:with-param name="curlevel" select="$curlevel + 1"/>
                        </xsl:apply-templates>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="f:rend-value(@rend, 'toc') != 'none'">
                        <xsl:copy-of select="f:logWarning('No head for {1} {2}; this and underlying divisions will be omitted from the table of contents.', (name(.), @id))"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>


    <xsl:template name="generate-toc-entry-table">
        <xsl:param name="maxlevel" as="xs:integer"/>
        <xsl:param name="curlevel" as="xs:integer"/>
        <xsl:param name="show-page-numbers" tunnel="yes" as="xs:boolean" select="true()"/>
        <xsl:param name="show-div-numbers" tunnel="yes" as="xs:boolean" select="true()"/>

        <!-- Padding cell if needed to indent nested contents -->
        <xsl:if test="$curlevel > 0">
            <td>
                <xsl:if test="$curlevel > 1">
                    <xsl:attribute name="colspan"><xsl:value-of select="$curlevel"/></xsl:attribute>
                </xsl:if>
            </td>
        </xsl:if>
        <td class="tocDivNum">
            <xsl:if test="@n and f:isSet('numberTocEntries') and $show-div-numbers">
                <xsl:value-of select="@n"/><xsl:text>. </xsl:text>
            </xsl:if>
        </td>
        <td class="tocDivTitle" colspan="{($maxlevel + 1) - $curlevel}">
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
                <xsl:value-of select="preceding::pb[1]/@n"/>
            </a>
        </xsl:if>
    </xsl:template>


    <!--====================================================================-->
    <!-- A classic table of contents with chapter labels, titles, and arguments -->

    <xd:doc>
        <xd:short>Generate a classic table of contents with chapter labels, titles, and arguments.</xd:short>
        <xd:detail>
            <p>Generate a classic table of contents with chapter labels, titles, and arguments. This table of contents only goes one level deep.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="divGen[@type='toca']">
        <div class="div1">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <h2 class="main"><xsl:value-of select="f:message('msgTableOfContents')"/></h2>

            <xsl:apply-templates mode="gentoca" select="/*[self::TEI.2 or self::TEI]/text/front/div1"/>
            <xsl:apply-templates mode="gentoca" select="if (/*[self::TEI.2 or self::TEI]/text/body/div0) then /*[self::TEI.2 or self::TEI]/text/body/div0 else /*[self::TEI.2 or self::TEI]/text/body/div1"/>
            <xsl:apply-templates mode="gentoca" select="/*[self::TEI.2 or self::TEI]/text/back/div1[not(@type='Ads') and not(@type='Advertisment')]"/>
        </div>
    </xsl:template>


    <xsl:template match="div0|div1" mode="gentoca">
        <xsl:if test="head and f:rend-value(@rend, 'toc') != 'none'">
            <xsl:if test="head[@type='label']">
                <p class="tocChapter">
                    <a href="{f:generate-href(.)}">
                        <xsl:apply-templates select="head[@type='label']" mode="tochead"/>
                    </a>
                    <xsl:if test="not(head[not(@type)])">
                        <xsl:call-template name="insert-toc-page-number"/>
                    </xsl:if>
                </p>
            </xsl:if>
            <xsl:if test="head[not(@type)]">
                <p class="tocChapter">
                    <a href="{f:generate-href(.)}">
                        <xsl:apply-templates select="head[not(@type)]" mode="tochead"/>
                    </a>
                    <xsl:call-template name="insert-toc-page-number"/>
                </p>
            </xsl:if>
            <xsl:if test="argument">
                <p class="tocArgument">
                    <xsl:apply-templates select="argument" mode="tochead"/>
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
            <xsl:apply-templates select="../div2[@type != 'SubToc']" mode="gentoc"/>
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
            available, and will use that image in a gallery, linking to the original (full-size) image. The name
            of the thumbnail image file is assumed to be the same as the full-size image, but is located in
            a subdirectory <code>/thumbs/</code>.</p>
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
                <xsl:apply-templates select=". | following::figure[position() &lt; $columns]" mode="gallery-captions"/>
            </tr>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="get-thumbnail-image">
        <xsl:choose>
            <!-- Derive name for thumbnail from image file name -->
            <xsl:when test="f:has-rend-value(@rend, 'image')">
                <xsl:variable name="image">
                    <xsl:value-of select="f:rend-value(@rend, 'image')"/>
                </xsl:variable>
                <xsl:value-of select="substring-before($image, '/')"/>
                <xsl:text>/thumbs/</xsl:text>
                <xsl:value-of select="substring-after($image, '/')"/>
            </xsl:when>
            <!-- Derive name for thumbnail from image id -->
            <xsl:otherwise>images/thumbs/<xsl:value-of select="@id"/>.jpg</xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="figure" mode="gallery">
        <td class="galleryFigure">
            <a href="{f:generate-href(.)}">
                <img>
                    <xsl:attribute name="src"><xsl:call-template name="get-thumbnail-image"/></xsl:attribute>
                    <xsl:attribute name="alt"><xsl:value-of select="head"/></xsl:attribute>
                </img>
            </a>
        </td>
    </xsl:template>


    <xsl:template match="figure" mode="gallery-captions">
        <td class="galleryCaption">
            <a href="{f:generate-href(.)}">
                <xsl:apply-templates select="head" mode="gallery-captions"/>
            </a>
        </td>
    </xsl:template>


    <xsl:template match="head" mode="gallery-captions">
        <xsl:apply-templates mode="gallery-captions"/>
    </xsl:template>


    <xsl:template match="hi" mode="gallery-captions">
        <i><xsl:apply-templates mode="gallery-captions"/></i>
    </xsl:template>


    <xsl:template match="hi[@rend='ex']" mode="gallery-captions">
        <xsl:apply-templates mode="gallery-captions"/>
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

            <p>This will result in a HTML table, in which the item numbers are placed in cells on the left, the items themselves in
            spanned cells in the middle (made to span less columns as they are part of deeply nested items) and the page numbers
            in a cell on the right.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="list[@type='tocList']">
        <xsl:choose>
            <!-- Outer list -->
            <xsl:when test="not(ancestor::list[@type='tocList'])">
                <table class="tocList">
                    <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                    <xsl:apply-templates mode="tocList"/>
                </table>
            </xsl:when>
            <!-- Nested list, part of table generated for outermost list -->
            <xsl:otherwise>
                <xsl:apply-templates mode="tocList"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="tocList" match="item">
        <xsl:variable name="depth" select="count(ancestor::list[@type='tocList']) - 1"/>
        <tr>
            <!-- Use padding cell if needed to indent nested contents -->
            <xsl:if test="$depth > 0">
                <td>
                    <xsl:if test="$depth > 1">
                        <xsl:attribute name="colspan"><xsl:value-of select="$depth"/></xsl:attribute>
                    </xsl:if>
                </td>
            </xsl:if>
            <td class="tocDivNum">
                <xsl:apply-templates mode="tocList" select="ab[@type='tocDivNum']"/>
            </td>
            <td class="tocDivTitle" colspan="{7 - $depth}">
                <xsl:apply-templates select="text()|*[not(@type='tocDivNum' or @type='tocPageNum' or @type='tocList')]"/>
            </td>
            <td class="tocPageNum">
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

            <p>This will result in a HTML table, in which the item numbers are placed in cells on the left, the items themselves in
            spanned cells to the right (made to span less columns as they are part of deeply nested items) together with the
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

    <!-- collect footnotes in a separate section, sorted by div1 -->
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
            and present them, divided by division.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="footnotes-body">
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
        <xsl:if test=".//note[(@place='foot' or @place='unspecified' or not(@place)) and not(ancestor::div1)]">
            <div class="div2 notes">
                <xsl:call-template name="footnote-sectionhead"/>
                <xsl:apply-templates select=".//note[(@place='foot' or @place='unspecified' or not(@place)) and not(ancestor::div1)]" mode="footnotes"/>
            </div>
        </xsl:if>
        <xsl:apply-templates select="div1[not(ancestor::q)]" mode="divgen-footnotes"/>
    </xsl:template>


    <xsl:template match="div1" mode="divgen-footnotes">
        <!-- Only mention the chapter if it has footnotes -->
        <xsl:if test=".//note[@place='foot' or @place='unspecified' or not(@place)]">
            <div class="div2 notes">
                <xsl:call-template name="footnote-sectionhead"/>
                <xsl:apply-templates select=".//note[@place='foot' or @place='unspecified' or not(@place)]" mode="footnotes"/>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="footnote-sectionhead">
        <h3 class="main">
            <xsl:call-template name="generate-single-head"/>
        </h3>
    </xsl:template>


    <!--====================================================================-->
    <!-- Included material (alternative for xml:include) -->

    <xsl:template match="divGen[@type='Inclusion']">
        <!-- Material to be included should be rendered here; material is given on an url parameter -->
        <xsl:if test="@url">
            <xsl:variable name="target" select="@url"/>
            <xsl:variable name="document" select="substring-before($target, '#')"/>
            <xsl:variable name="otherid" select="substring-after($target, '#')"/>

            <xsl:apply-templates select="document($document, .)//*[@id=$otherid]"/>
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
