<!DOCTYPE xsl:stylesheet [

    <!ENTITY nbsp       "&#160;">

]><!--

    Stylesheet with to generate a table of contents, to be imported in 
    tei2html.xsl.

    Usage: 
        <divGen type="toc"/>    Generates a standard table of contents.
        <divGen type="toca"/>   Generates a classice table of contents,
                                with arguments taken from the chapter
                                headings.
        <divGen type="loi"/>    Generates a list of illustrations.
        <divGen type="gallery"/> Generates a gallery of thumbnails of
                                all included illustrations.

        <divGen type="index"/>  Generates an index.

    Special Usage:
        <div2 type="SubToc"/>   Generates a table of contents at the
                                div2 level. This table replaces the
                                actual content of the div2.

    Requires: 
        localization.xsl    : templates for localizing strings.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:f="urn:stylesheet-functions"
    exclude-result-prefixes="f xhtml xs"
    version="2.0"
    >


    <xsl:template match="divGen">
        <xsl:message terminate="no">Warning: divGen element without or with unknown type attribute: <xsl:value-of select="@type"/>.</xsl:message>
    </xsl:template>


    <!--====================================================================-->
    <!-- Table of Contents -->
    <!-- Take care only to generate ToC entries for divisions of the main text, not for those in quoted texts -->

    <xsl:template match="divGen[@type='toc']">
        <div class="div1">
            <xsl:call-template name="set-lang-id-attributes"/>
            <h2 class="main"><xsl:value-of select="f:message('msgTableOfContents')"/></h2>
            <xsl:call-template name="toc-body"/>
        </div>
    </xsl:template>


    <xsl:template match="divGen[@type='tocBody']">
        <xsl:call-template name="toc-body"/>
    </xsl:template>


    <xsl:template name="toc-body">
        <xsl:variable name="maxlevel">
            <xsl:choose>
                <xsl:when test="contains(@rend, 'tocMaxLevel(')">
                    <xsl:value-of select="substring-before(substring-after(@rend, 'tocMaxLevel('), ')')"/>
                </xsl:when>
                <xsl:otherwise>7</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <ul>
            <xsl:apply-templates mode="gentoc" select="/TEI.2/text/front/div1">
                <xsl:with-param name="maxlevel" select="$maxlevel"/>
            </xsl:apply-templates>
            <xsl:choose>
                <xsl:when test="/TEI.2/text/body/div0">
                    <xsl:apply-templates mode="gentoc" select="/TEI.2/text/body/div0">
                        <xsl:with-param name="maxlevel" select="$maxlevel"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="gentoc" select="/TEI.2/text/body/div1">
                        <xsl:with-param name="maxlevel" select="$maxlevel"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates mode="gentoc" select="/TEI.2/text/back/div1[not(@type='Ads') and not(@type='Advertisment')]">
                <xsl:with-param name="maxlevel" select="$maxlevel"/>
            </xsl:apply-templates>
        </ul>
    </xsl:template>

    <!-- TOC: div0 -->

    <xsl:template match="div0" mode="gentoc">
        <xsl:param name="maxlevel" as="xs:integer"/>
        <xsl:if test="head and not(contains(@rend, 'toc(none)'))">
            <li>
                <a>
                    <xsl:call-template name="generate-href-attribute"/>
                    <!-- <xsl:value-of select="f:translate-div-type(@type)"/><xsl:text> </xsl:text><xsl:value-of select="@n"/>:<xsl:text> </xsl:text> -->
                    <xsl:apply-templates select="head[not(@type='label') and not(@type='super')]" mode="tochead"/>
                </a>
                <xsl:call-template name="insert-toc-page-number"/>
                <xsl:if test="div1 and $maxlevel &gt;= 1">
                    <ul>
                        <xsl:apply-templates select="div1" mode="gentoc">
                            <xsl:with-param name="maxlevel" select="$maxlevel"/>
                        </xsl:apply-templates>
                    </ul>
                </xsl:if>
            </li>
        </xsl:if>
    </xsl:template>


    <!-- TOC: div1 -->

    <xsl:template match="div1" mode="gentoc">
        <xsl:param name="maxlevel" as="xs:integer"/>
        <xsl:if test="head and not(contains(@rend, 'toc(none)'))">
            <li>
                <a>
                    <xsl:call-template name="generate-href-attribute"/>
                    <!-- <xsl:value-of select="f:translate-div-type(@type)"/><xsl:text> </xsl:text><xsl:value-of select="@n"/>:<xsl:text> </xsl:text> -->
                    <xsl:apply-templates select="head[not(@type='label') and not(@type='super')]" mode="tochead"/>
                </a>
                <xsl:call-template name="insert-toc-page-number"/>
                <xsl:if test="div2 and $maxlevel &gt;= 2 and (not(@type) or @type != 'Index')">
                    <ul>
                        <xsl:apply-templates select="div2" mode="gentoc">
                            <xsl:with-param name="maxlevel" select="$maxlevel"/>
                        </xsl:apply-templates>
                    </ul>
                </xsl:if>
            </li>
        </xsl:if>
    </xsl:template>


    <!-- TOC: div2 -->

    <xsl:template match="div2" mode="gentoc">
        <xsl:param name="maxlevel" as="xs:integer"/>
        <xsl:if test="head and not(contains(@rend, 'toc(none)'))">
            <li>
                <a>
                    <xsl:call-template name="generate-href-attribute"/>
                    <xsl:apply-templates select="head[not(@type='label')]" mode="tochead"/>
                </a>
                <xsl:call-template name="insert-toc-page-number"/>
                <xsl:if test="div3 and $maxlevel &gt;= 3">
                    <ul>
                        <xsl:apply-templates select="div3" mode="gentoc">
                            <xsl:with-param name="maxlevel" select="$maxlevel"/>
                        </xsl:apply-templates>
                    </ul>
                </xsl:if>
            </li>
        </xsl:if>
    </xsl:template>

    <!-- Do not list subordinate tables of contents (the actual subtoc will be replaced by a generated table of contents and links will not work properly) -->
    <xsl:template match="div2[@type='SubToc']" mode="gentoc"/>


    <!-- TOC: div3 -->

    <xsl:template match="div3" mode="gentoc">
        <xsl:param name="maxlevel" as="xs:integer"/>
        <xsl:if test="head">
            <li>
                <a>
                    <xsl:call-template name="generate-href-attribute"/>
                    <xsl:apply-templates select="head[not(@type='label')]" mode="tochead"/>
                </a>
                <xsl:call-template name="insert-toc-page-number"/>
                <xsl:if test="div4 and $maxlevel &gt;= 4">
                    <ul>
                        <xsl:apply-templates select="div4" mode="gentoc">
                            <xsl:with-param name="maxlevel" select="$maxlevel"/>
                        </xsl:apply-templates>
                    </ul>
                </xsl:if>
            </li>
        </xsl:if>
    </xsl:template>

    <!-- TOC: div4 -->

    <xsl:template match="div4" mode="gentoc">
        <xsl:param name="maxlevel" as="xs:integer"/>
        <xsl:if test="head">
            <li>
                <a>
                    <xsl:call-template name="generate-href-attribute"/>
                    <xsl:apply-templates select="head[not(@type='label')]" mode="tochead"/>
                </a>
                <xsl:call-template name="insert-toc-page-number"/>
                <xsl:if test="div5 and $maxlevel &gt;= 5">
                    <ul>
                        <xsl:apply-templates select="div5" mode="gentoc">
                            <xsl:with-param name="maxlevel" select="$maxlevel"/>
                        </xsl:apply-templates>
                    </ul>
                </xsl:if>
            </li>
        </xsl:if>
    </xsl:template>

    <!-- TOC: div5 -->

    <xsl:template match="div5" mode="gentoc">
        <xsl:param name="maxlevel" as="xs:integer"/>
        <xsl:if test="head">
            <li>
                <a>
                    <xsl:call-template name="generate-href-attribute"/>
                    <xsl:apply-templates select="head[not(@type='label')]" mode="tochead"/>
                </a>
                <xsl:call-template name="insert-toc-page-number"/>
                <xsl:if test="div6 and $maxlevel &gt;= 6">
                    <ul>
                        <xsl:apply-templates select="div6" mode="gentoc"/>
                    </ul>
                </xsl:if>
            </li>
        </xsl:if>
    </xsl:template>

    <!-- TOC: div6 -->

    <xsl:template match="div6" mode="gentoc">
        <xsl:if test="head">
            <li>
                <a>
                    <xsl:call-template name="generate-href-attribute"/>
                    <xsl:apply-templates select="head[not(@type='label')]" mode="tochead"/>
                </a>
                <xsl:call-template name="insert-toc-page-number"/>
            </li>
        </xsl:if>
    </xsl:template>

    <!-- Special short table of contents for indexes -->

    <xsl:template match="divGen[@type='IndexToc']">
        <xsl:call-template name="genindextoc"/>
    </xsl:template>

    <xsl:template name="genindextoc">
        <div class="transcribernote indextoc">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:apply-templates select="../div2/head" mode="genindextoc"/>
        </div>
    </xsl:template>

    <xsl:template match="head" mode="genindextoc">
        <xsl:if test="position() != 1">
            <xsl:text> | </xsl:text>
        </xsl:if>
        <a>
            <xsl:call-template name="generate-href-attribute"/>
            <xsl:if test="contains(., '.')">
                <xsl:value-of select="substring-before(., '.')"/>
            </xsl:if>
            <xsl:if test="not(contains(., '.'))">
                <xsl:value-of select="."/>
            </xsl:if>
        </a>
    </xsl:template>


    <!-- Suppress notes in table of contents (to avoid getting them twice) -->
    <xsl:template match="note" mode="tochead"/>


    <!-- Suppress 'label' headings in table of contents -->
    <xsl:template match="head[@type='label']" mode="tochead"/>


    <xsl:template match="head" mode="tochead">
        <xsl:choose>
            <xsl:when test="contains(../@rend, 'toc-head(')">
                <xsl:value-of select="substring-before(substring-after(../@rend, 'toc-head('), ')')"/>
            </xsl:when>
            <xsl:when test="contains(@rend, 'toc-head(')">
                <xsl:value-of select="substring-before(substring-after(@rend, 'toc-head('), ')')"/>
            </xsl:when>
            <xsl:when test="contains(@rend, 'toc-head(')">
                <xsl:value-of select="substring-before(substring-after(@rend, 'toc-head('), ')')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="position() = 1 and ./@n">
                    <xsl:value-of select="./@n"/><xsl:text> </xsl:text>
                </xsl:if>
                <xsl:if test="position() &gt; 1">
                    <xsl:text>: </xsl:text>
                </xsl:if>
                <xsl:apply-templates mode="tochead"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- Text styles in chapter headings -->

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

    <xsl:template match="hi[@rend='sup']" mode="tochead">
        <sup>
            <xsl:apply-templates mode="tochead"/>
        </sup>
    </xsl:template>


    <!--====================================================================-->
    <!-- A classical table of contents with chapter labels, titles, and arguments -->


    <!-- insert a span containing the page number, and a link to it. -->
    <xsl:template name="insert-toc-page-number">
        <xsl:if test="preceding::pb[1]/@n and preceding::pb[1]/@n != ''">
            <xsl:text>&nbsp;&nbsp;&nbsp;&nbsp; </xsl:text>
            <span class="tocPagenum">
                <a class="pageref">
                    <xsl:call-template name="generate-href-attribute">
                        <!-- we always have a head here in the context, so link to that -->
                        <xsl:with-param name="target" select="head[1]"/>
                    </xsl:call-template>
                    <xsl:value-of select="preceding::pb[1]/@n"/>
                </a>
            </span>
        </xsl:if>
    </xsl:template>


    <xsl:template match="divGen[@type='toca']">
        <div class="div1">
            <xsl:call-template name="set-lang-id-attributes"/>
            <h2 class="main"><xsl:value-of select="f:message('msgTableOfContents')"/></h2>

            <xsl:apply-templates mode="gentoca" select="/TEI.2/text/front/div1"/>
            <xsl:choose>
                <xsl:when test="/TEI.2/text/body/div0">
                    <xsl:apply-templates mode="gentoca" select="/TEI.2/text/body/div0"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="gentoca" select="/TEI.2/text/body/div1"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates mode="gentoca" select="/TEI.2/text/back/div1[not(@type='Ads') and not(@type='Advertisment')]"/>
        </div>
    </xsl:template>


    <xsl:template match="div0|div1" mode="gentoca">
        <xsl:if test="head and not(contains(@rend, 'toc(none)'))">
            <xsl:if test="head[@type='label']">
                <p class="tocChapter">
                    <a>
                        <xsl:call-template name="generate-href-attribute"/>
                        <xsl:apply-templates select="head[@type='label']" mode="gentoca"/>
                    </a>
                    <xsl:if test="not(head[not(@type)])">
                        <xsl:call-template name="insert-toc-page-number"/>
                    </xsl:if>
                </p>
            </xsl:if>
            <xsl:if test="head[not(@type)]">
                <p class="tocChapter">
                    <a>
                        <xsl:call-template name="generate-href-attribute"/>
                        <xsl:apply-templates select="head[not(@type)]" mode="gentoca"/>
                    </a>
                    <xsl:call-template name="insert-toc-page-number"/>
                </p>
            </xsl:if>
            <xsl:if test="argument">
                <p class="tocArgument">
                    <xsl:apply-templates select="argument" mode="gentoca"/>
                </p>
            </xsl:if>
        </xsl:if>
        <xsl:if test="div1">
            <ul>
                <xsl:apply-templates select="div1" mode="gentoca"/>
            </ul>
        </xsl:if>
    </xsl:template>

    <xsl:template match="note" mode="gentoca"/>

    <xsl:template match="hi" mode="gentoca">
        <i>
            <xsl:apply-templates mode="gentoca"/>
        </i>
    </xsl:template>

    <xsl:template match="hi[@rend='italic']" mode="gentoca">
        <i>
            <xsl:apply-templates mode="gentoca"/>
        </i>
    </xsl:template>

    <xsl:template match="hi[@rend='sup']" mode="gentoca">
        <sup>
            <xsl:apply-templates mode="gentoca"/>
        </sup>
    </xsl:template>


    <!--====================================================================-->
    <!-- SubToc (special handling for Tribes and Castes volumes) -->

    <!-- A SubToc is a short table of contents at div2 level, which appears at the beginning of a div1 -->

    <xsl:template match="div2[@type='SubToc']">
        <!-- Render heading in normal fashion -->
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

    <xsl:template match="div2" mode="SubToc">
        <li>
            <xsl:if test="@n">
                <xsl:value-of select="@n"/>.
            </xsl:if>
            <xsl:apply-templates select="head" mode="tochead"/>
        </li>
    </xsl:template>


    <!--====================================================================-->
    <!-- List of Illustrations -->

    <xsl:template match="divGen[@type='loi']">
        <div class="div1">
            <xsl:call-template name="set-lang-id-attributes"/>
            <h2 class="main"><xsl:value-of select="f:message('msgListOfIllustrations')"/></h2>
            <ul>
                <xsl:apply-templates mode="genloi" select="//figure[head]"/>
            </ul>
        </div>
    </xsl:template>


    <xsl:template match="figure" mode="genloi">
        <li>
            <xsl:call-template name="set-lang-id-attributes"/>
            <a>
                <xsl:call-template name="generate-href-attribute"/>
                <xsl:apply-templates select="head" mode="tochead"/>
            </a>
            <xsl:if test="preceding::pb[1]/@n and preceding::pb[1]/@n != ''">
                <xsl:text>&nbsp;&nbsp;&nbsp;&nbsp; </xsl:text>
                <span class="tocPagenum">
                    <xsl:value-of select="preceding::pb[1]/@n"/>
                </span>
            </xsl:if>
        </li>
    </xsl:template>


    <!-- Gallery of thumbnail images -->

    <xsl:template match="divGen[@type='gallery' or @type='Gallery']">
        <div class="div1">
            <xsl:call-template name="set-lang-id-attributes"/>
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
            <xsl:when test="contains(@rend, 'image(')">
                <xsl:variable name="image">
                    <xsl:value-of select="substring-before(substring-after(@rend, 'image('), ')')"/>
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
        <td align="center" valign="middle">
            <a>
                <xsl:call-template name="generate-href-attribute"/>
                <img>
                    <xsl:attribute name="src"><xsl:call-template name="get-thumbnail-image"/></xsl:attribute>
                    <xsl:attribute name="alt"><xsl:value-of select="head"/></xsl:attribute>
                </img>
            </a>
        </td>
    </xsl:template>

    <xsl:template match="figure" mode="gallery-captions">
        <td align="center" valign="top">
            <a>
                <xsl:call-template name="generate-href-attribute"/>
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

    <!--====================================================================-->
    <!-- Render pre-existing table of contents encoded as itemized list as table 
         Nested lists are integrated into a single table. 
         
         This depends on the following convention to structure a table of contents:

            [list type='tocList']
                [item] [ab type=tocDivNum]DIVISION NUMBER[/ab] DIVISION TITLE [ab type=tocPageNum]PAGE NUMBER[/ab]
                    [list type='tocList]
                        ... 
                    [/list]
                [/item]
            [/list]

         -->

    <xsl:template match="list[@type='tocList']">
        <xsl:choose>
            <!-- Outer list -->
            <xsl:when test="not(ancestor::list[@type='tocList'])">
                <table class="tocList">
                    <xsl:apply-templates mode="tocList"/>
                </table>
            </xsl:when>
            <!-- Nested list -->
            <xsl:otherwise>
                <xsl:apply-templates mode="tocList"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="tocList" match="item">
        <xsl:variable name="depth" select="count(ancestor::list[@type='tocList']) - 1"/>
        <tr>
            <!-- Padding cell if needed to indent nested contents -->
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
            <td class="tocDivTitle" colspan="{5 - $depth}">
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


    <!--====================================================================-->
    <!-- Index -->

    <xsl:template match="divGen[@type='Index' or @type='index']">
        <div class="div1">
            <xsl:call-template name="set-lang-id-attributes"/>
            <h2 class="main"><xsl:value-of select="f:message('msgIndex')"/></h2>

            <xsl:message terminate="no">Info: Generating Index</xsl:message>

            <!-- Collect all index entries into a tree structure, and add the page numbers to them -->
            <xsl:variable name="index">
                <divIndex>
                    <xsl:for-each select="//index">
                        <index>
                            <xsl:attribute name="level1"><xsl:value-of select="@level1"/></xsl:attribute>
                            <xsl:attribute name="level2"><xsl:value-of select="@level2"/></xsl:attribute>
                            <xsl:attribute name="level3"><xsl:value-of select="@level3"/></xsl:attribute>
                            <xsl:attribute name="level4"><xsl:value-of select="@level4"/></xsl:attribute>
                            <xsl:attribute name="index"><xsl:value-of select="@index"/></xsl:attribute>
                            <xsl:attribute name="page">
                                <xsl:choose>
                                    <xsl:when test="preceding::pb[1]/@n and preceding::pb[1]/@n != ''">
                                        <xsl:value-of select="preceding::pb[1]/@n"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>###</xsl:text>
                                        <xsl:message terminate="no">Warning: no valid page number found preceding index entry. (<xsl:value-of select="@level1"/>)</xsl:message>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:call-template name="generate-href-attribute">
                                <xsl:with-param name="target" select="."/>
                            </xsl:call-template>
                        </index>
                    </xsl:for-each>
                </divIndex>
            </xsl:variable>

            <xsl:apply-templates select="$index" mode="index"/>
        </div>
    </xsl:template>


    <xsl:template match="xhtml:divIndex" mode="index">
        <xsl:for-each-group select="xhtml:index" group-by="lower-case(@level1)">
            <xsl:sort select="lower-case(@level1)"/>

            <p>
                <xsl:value-of select="@level1"/>

                <xsl:for-each-group select="current-group()" group-by="lower-case(@level2)">
                    <xsl:sort select="lower-case(@level2)"/>
                    <xsl:choose>
                        <xsl:when test="position() = 1"><xsl:text> </xsl:text></xsl:when>
                        <xsl:otherwise>; </xsl:otherwise>
                    </xsl:choose>
                    
                    <xsl:value-of select="@level2"/>

                    <!-- Group to suppress duplicate page numbers -->
                    <xsl:for-each-group select="current-group()" group-by="@page">
                        <xsl:choose>
                            <xsl:when test="position() = 1"><xsl:text> </xsl:text></xsl:when>
                            <xsl:otherwise>, </xsl:otherwise>
                        </xsl:choose>
                        <a>
                            <xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
                            <xsl:value-of select="@page"/>
                        </a>
                    </xsl:for-each-group>
                </xsl:for-each-group>
            </p>
        </xsl:for-each-group>
    </xsl:template>


    <xsl:template match="index">
        <a>
            <xsl:call-template name="set-lang-id-attributes"/>
        </a>
    </xsl:template>


    <!--====================================================================-->
    <!-- Footnotes -->

    <!-- collect footnotes in a separate section, sorted by div1 -->
    <xsl:template match="divGen[@type='Footnotes' or @type='footnotes']">
        <div class="div1 notes">
            <xsl:call-template name="set-lang-id-attributes"/>
            <h2 class="main"><xsl:value-of select="f:message('msgNotes')"/></h2>

            <xsl:call-template name="footnotes-body"/>
        </div>
    </xsl:template>


    <xsl:template match="divGen[@type='footnotesBody']">
        <xsl:call-template name="footnotes-body"/>
    </xsl:template>


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
                <xsl:apply-templates select="./head[not(@type='label') and not(@type='super')]" mode="divgen-footnotes"/>
                <xsl:apply-templates select=".//note[(@place='foot' or @place='unspecified' or not(@place)) and not(ancestor::div1)]" mode="footnotes"/>
            </div>
        </xsl:if>
        <xsl:apply-templates select="div1[not(ancestor::q)]" mode="divgen-footnotes"/>
    </xsl:template>

    <xsl:template match="div1" mode="divgen-footnotes">
        <!-- Only mention the chapter if it has footnotes -->
        <xsl:if test=".//note[@place='foot' or @place='unspecified' or not(@place)]">
            <div class="div2 notes">
                <xsl:apply-templates select="./head[not(@type='label') and not(@type='super')]" mode="divgen-footnotes"/>
                <xsl:apply-templates select=".//note[@place='foot' or @place='unspecified' or not(@place)]" mode="footnotes"/>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="head" mode="divgen-footnotes">
        <h3 class="main">
            <xsl:apply-templates select="." mode="tochead"/>
        </h3>
    </xsl:template>


</xsl:stylesheet>
