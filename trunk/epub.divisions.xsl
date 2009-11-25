<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to format division elements (tailored for ePub, that is
    splitting into separate XHTML files at the div1 level, to be imported 
    in tei2epub.xsl.

    Requires: 
        localization.xsl    : templates for localizing strings.
        messages.xsl        : stores localized messages in variables.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    >


    <xsl:include href="splitter.xsl"/>


    <!--====================================================================-->
    <!-- Main subdivisions of work -->

    <xsl:template match="/TEI.2/text">
        <xsl:apply-templates mode="splitter"/>
    </xsl:template>


    <!--====================================================================-->
    <!-- Divisions and Headings -->

    <xsl:template name="GenerateLabel">
        <xsl:param name="div" select="."/>
        <xsl:param name="headingLevel" select="'h2'"/>

        <xsl:if test="contains($div/@rend, 'label(yes)')">
            <xsl:element name="{$headingLevel}">
                <xsl:attribute name="class">label</xsl:attribute>
                <xsl:call-template name="TranslateType">
                    <xsl:with-param name="type" select="$div/@type"/>
                </xsl:call-template>
                <xsl:value-of select="$div/@n"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>


    <xsl:template name="TranslateType">
        <xsl:param name="type" select="@type"/>

        <xsl:choose>
            <xsl:when test="$type='Appendix' or $type='appendix'">
                <xsl:value-of select="$strAppendix"/><xsl:text> </xsl:text>
            </xsl:when>
            <xsl:when test="$type='Chapter' or $type='chapter'">
                <xsl:value-of select="$strChapter"/><xsl:text> </xsl:text>
            </xsl:when>
            <xsl:when test="$type='Part' or $type='part'">
                <xsl:value-of select="$strPart"/><xsl:text> </xsl:text>
            </xsl:when>
            <xsl:when test="$type='Book' or $type='book'">
                <xsl:value-of select="$strBook"/><xsl:text> </xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="headText">
        <xsl:call-template name="generate-id-attribute"/>
        <xsl:call-template name="setLangAttribute"/>
        <xsl:call-template name="setHtmlClass"/>
        <xsl:if test="contains(@rend, 'align(')">
            <xsl:attribute name="align">
                <xsl:value-of select="substring-before(substring-after(@rend, 'align('), ')')"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template name="setHtmlClass">
        <xsl:choose>
            <xsl:when test="@type">
                <xsl:attribute name="class"><xsl:value-of select="@type"/></xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="class">normal</xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="headPicture">
        <xsl:if test="contains(@rend, 'image(')">
            <div class="figure">
                <xsl:call-template name="setLangAttribute"/>
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
                            <xsl:value-of select="$strOrnament"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </div>
        </xsl:if>
    </xsl:template>


    <!-- div0 -->

    <xsl:template match="div0/head">
        <xsl:call-template name="headPicture"/>
        <xsl:if test="not(contains(@rend, 'display(image-only)'))">
            <h2>
                <xsl:call-template name="headText"/>
            </h2>
        </xsl:if>
    </xsl:template>


    <!-- div1 -->

    <xsl:template match="div1[@type='TranscriberNote']">
        <div class="transcribernote">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="div1">
        <!-- HACK: Include footnotes in a preceding part of the div0 section here -->
        <xsl:if test="count(preceding-sibling::div1) = 0 and ancestor::div0">
            <xsl:if test="..//note[(@place='foot' or not(@place)) and not(ancestor::div1)]">
                <div class="footnotes">
                    <hr class="fnsep"/>
                    <xsl:apply-templates mode="footnotes" select="..//note[(@place='foot' or not(@place)) and not(ancestor::div1)]"/>
                </div>
            </xsl:if>
        </xsl:if>

        <div>
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:attribute name="class">div1<xsl:if test="@type='Index'"> index</xsl:if>
                <xsl:if test="contains(@rend, 'class(')">
                    <xsl:text> </xsl:text><xsl:value-of select="substring-before(substring-after(@rend, 'class('), ')')"/>
                </xsl:if>
                <xsl:if test="@type='Advertisment'"> advertisment</xsl:if>
            </xsl:attribute>

            <xsl:if test="//*[@id='toc'] and not(ancestor::q)">
                <!-- If we have an element with id 'toc', include a link to it (except in quoted material) -->
                <span class="pagenum">
                    [<a>
                        <xsl:call-template name="generate-href-attribute">
                            <xsl:with-param name="target" select="//*[@id='toc']"/>
                        </xsl:call-template>
                        <xsl:value-of select="$strToc"/>
                     </a>]
                </span>
            </xsl:if>

            <xsl:call-template name="GenerateLabel"/>
            <xsl:apply-templates/>

            <xsl:if test=".//note[@place='foot' or not(@place)] and not(ancestor::q)">
                <div class="footnotes">
                    <hr class="fnsep"/>
                    <xsl:apply-templates mode="footnotes" select=".//note[@place='foot' or not(@place)]"/>
                </div>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template match="div1/head">
        <xsl:call-template name="headPicture"/>
        <xsl:if test="not(contains(@rend, 'display(image-only)'))">
            <h2>
                <xsl:call-template name="headText"/>
            </h2>
        </xsl:if>
    </xsl:template>


    <!-- div2 -->

    <xsl:template match="div2">
        <div class="div2">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:call-template name="GenerateLabel">
                <xsl:with-param name="headingLevel" select="'h2'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="div2/head">
        <xsl:call-template name="headPicture"/>
        <h3>
            <xsl:call-template name="headText"/>
        </h3>
    </xsl:template>


    <!-- div3 -->

    <xsl:template match="div3">
        <div class="div3">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="div3/head">
        <xsl:call-template name="headPicture"/>
        <h4>
            <xsl:call-template name="headText"/>
        </h4>
    </xsl:template>


    <!-- div4 -->

    <xsl:template match="div4">
        <div class="div4">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="div4/head">
        <xsl:call-template name="headPicture"/>
        <h5>
            <xsl:call-template name="headText"/>
        </h5>
    </xsl:template>


    <!-- div5 -->

    <xsl:template match="div5">
        <div class="div5">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="div5/head">
        <xsl:call-template name="headPicture"/>
        <h6>
            <xsl:call-template name="headText"/>
        </h6>
    </xsl:template>


    <!-- other headers -->

    <xsl:template match="head">
        <h4>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </h4>
    </xsl:template>

    <xsl:template match="byline">
        <p>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:attribute name="class">byline
                <xsl:if test="contains(@rend, 'align(center)')"><xsl:text> </xsl:text>aligncenter</xsl:if>
            </xsl:attribute>
            <xsl:apply-templates/>
        </p>
    </xsl:template>


</xsl:stylesheet>
