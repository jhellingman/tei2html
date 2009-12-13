<!DOCTYPE xsl:stylesheet>
<!--

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

    Special Usage:
        <div2 type="SubToc"/>   Generates a table of contents at the
                                div2 level. This table replaces the
                                actual content of the div2.

    Requires: 
        localization.xsl    : templates for localizing strings.
        messages.xsl        : stores localized messages in variables.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"
    >


    <xsl:template match="divGen">
        <xsl:message terminate="no">Warning: divGen without or with unknown type attribute.</xsl:message>
    </xsl:template>


    <!--====================================================================-->
    <!-- Table of Contents -->
    <!-- Take care only to generate ToC entries for divisions of the main text, not for those in quoted texts -->

    <xsl:template match="divGen[@type='toc']">
        <div class="div1">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <h2 class="normal"><xsl:value-of select="$strTableOfContents"/></h2>
            <ul>
                <xsl:apply-templates mode="gentoc" select="/TEI.2/text/front/div1"/>
                <xsl:choose>
                    <xsl:when test="/TEI.2/text/body/div0">
                        <xsl:apply-templates mode="gentoc" select="/TEI.2/text/body/div0"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="gentoc" select="/TEI.2/text/body/div1"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates mode="gentoc" select="/TEI.2/text/back/div1[not(@type='Ads') and not(@type='Advertisment')]"/>
            </ul>
        </div>
    </xsl:template>


    <!-- TOC: div0 -->

    <xsl:template match="div0" mode="gentoc">
        <xsl:if test="head and not(contains(@rend, 'toc(none)'))">
            <li>
                <a>
                    <xsl:call-template name="generate-href-attribute"/>
                    <xsl:choose>
                        <xsl:when test="@type='part'">
                            <xsl:value-of select="$strPart"/><xsl:text> </xsl:text><xsl:value-of select="./@n"/>:<xsl:text> </xsl:text>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:apply-templates select="head[not(@type='label') and not(@type='super')]" mode="tochead"/>
                </a>
                <xsl:if test="div1">
                    <ul>
                        <xsl:apply-templates select="div1" mode="gentoc"/>
                    </ul>
                </xsl:if>
            </li>
        </xsl:if>
    </xsl:template>


    <!-- TOC: div1 -->

    <xsl:template match="div1" mode="gentoc">
        <xsl:if test="head and not(contains(@rend, 'toc(none)'))">
            <li>
                <a>
                    <xsl:call-template name="generate-href-attribute"/>
                    <xsl:choose>
                        <xsl:when test="@type='chapter'">
                            <xsl:value-of select="$strChapter"/><xsl:text> </xsl:text><xsl:value-of select="./@n"/>:<xsl:text> </xsl:text>
                        </xsl:when>
                        <xsl:when test="@type='appendix'">
                            Appendix <xsl:value-of select="./@n"/>:<xsl:text> </xsl:text>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:apply-templates select="head[not(@type='label') and not(@type='super')]" mode="tochead"/>
                </a>
                <xsl:if test="div2">
                    <ul>
                        <xsl:apply-templates select="div2" mode="gentoc"/>
                    </ul>
                </xsl:if>
            </li>
        </xsl:if>
    </xsl:template>


    <!-- TOC: div2 -->

    <xsl:template match="div2" mode="gentoc">
        <xsl:if test="head and not(contains(@rend, 'toc(none)'))">
            <li>
                <a>
                    <xsl:call-template name="generate-href-attribute"/>
                    <xsl:apply-templates select="head[not(@type='label')]" mode="tochead"/>
                </a>
                <xsl:if test="div3">
                    <ul>
                        <xsl:apply-templates select="div3" mode="gentoc"/>
                    </ul>
                </xsl:if>
            </li>
        </xsl:if>
    </xsl:template>

    <!-- Do not list subordinate tables of contents (the actual subtoc will be replaced by a generated table of contents and links will not work properly) -->
    <xsl:template match="div2[@type='SubToc']" mode="gentoc"/>


    <!-- TOC: div3 -->

    <xsl:template match="div3" mode="gentoc">
        <xsl:if test="head">
            <li>
                <a>
                    <xsl:call-template name="generate-href-attribute"/>
                    <xsl:apply-templates select="head[not(@type='label')]" mode="tochead"/>
                </a>
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
        <xsl:if test="position() = 1 and ./@n">
            <xsl:value-of select="./@n"/><xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="position() &gt; 1">
            <xsl:text>: </xsl:text>
        </xsl:if>
        <xsl:apply-templates mode="tochead"/>
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

    <xsl:template match="divGen[@type='toca']">
        <div class="div1">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <h2 class="normal"><xsl:value-of select="$strTableOfContents"/></h2>

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
                        <xsl:if test="preceding::pb[1]/@n and preceding::pb[1]/@n != ''">
                            <span class="tocPagenum">
                                <xsl:value-of select="preceding::pb[1]/@n"/>
                            </span>
                        </xsl:if>
                    </xsl:if>
                </p>
            </xsl:if>
            <xsl:if test="head[not(@type)]">
                <p class="tocChapter">
                    <a>
                        <xsl:call-template name="generate-href-attribute"/>
                        <xsl:apply-templates select="head[not(@type)]" mode="gentoca"/>
                    </a>
                    <xsl:if test="preceding::pb[1]/@n and preceding::pb[1]/@n != ''">
                        <span class="tocPagenum">
                            <xsl:value-of select="preceding::pb[1]/@n"/>
                        </span>
                    </xsl:if>
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
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <h2 class="normal"><xsl:value-of select="$strListOfIllustrations"/></h2>
            <ul>
                <xsl:apply-templates mode="genloi" select="//figure[head]"/>
            </ul>
        </div>
    </xsl:template>


    <xsl:template match="figure" mode="genloi">
        <li>
            <xsl:call-template name="setLangAttribute"/>
            <a>
                <xsl:call-template name="generate-href-attribute"/>
                <xsl:apply-templates select="head" mode="tochead"/>
            </a>
            <xsl:if test="preceding::pb[1]/@n and preceding::pb[1]/@n != ''">
                <span class="tocPagenum">
                    <xsl:value-of select="preceding::pb[1]/@n"/>
                </span>
            </xsl:if>
        </li>
    </xsl:template>


    <!-- Gallery of thumbnail images -->

    <xsl:template match="divGen[@type='gallery' or @type='Gallery']">
        <div class="div1">
            <xsl:call-template name="generate-id-attribute"/>
            <h2 class="normal"><xsl:value-of select="$strListOfIllustrations"/></h2>
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


    <xsl:template match="figure" mode="gallery">
        <td align="center" valign="middle">
            <a>
                <xsl:call-template name="generate-href-attribute"/>
                <img>
                    <xsl:attribute name="src">images/thumbs/<xsl:value-of select="@id"/>.jpg</xsl:attribute>
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


</xsl:stylesheet>
