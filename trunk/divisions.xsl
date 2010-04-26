<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to format division elements, to be imported in tei2html.xsl.

    Requires: 
        localization.xsl    : templates for localizing strings.
        messages.xsl        : stores localized messages in variables.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"
    >


    <!--====================================================================-->
    <!-- Main subdivisions of work -->

    <xsl:template match="text">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="front">
        <div class="front">
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="body">
        <div class="body">
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="back">
        <div class="back">
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
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

        <xsl:variable name="class">
            <xsl:if test="@type"><xsl:value-of select="@type"/><xsl:text> </xsl:text></xsl:if>
            <xsl:call-template name="generate-rend-class-name-if-needed"/>
        </xsl:variable>

        <xsl:if test="normalize-space($class) != ''">
            <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>
        </xsl:if>

        <xsl:apply-templates/>
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


    <!--====================================================================-->
    <!-- div0 -->

    <xsl:template match="div0">
        <div class="div0">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:call-template name="GenerateLabel"/>

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


    <xsl:template match="div0/head">
        <xsl:call-template name="headPicture"/>
        <xsl:call-template name="setRunningHeader"/>
        <xsl:if test="not(contains(@rend, 'display(image-only)'))">
            <h2>
                <xsl:call-template name="headText"/>
            </h2>
        </xsl:if>
    </xsl:template>


    <!--====================================================================-->
    <!-- div1 -->

    <xsl:template match="div1[@type='TranscriberNote']">
        <div class="transcribernote">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

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

        <div>
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>

            <xsl:attribute name="class">div1<xsl:if test="@type='Index'"> index</xsl:if>
                <xsl:if test="contains(@rend, 'class(')">
                    <xsl:text> </xsl:text><xsl:value-of select="substring-before(substring-after(@rend, 'class('), ')')"/>
                </xsl:if>
                <xsl:if test="@type='Advertisment'"> advertisment</xsl:if>
            </xsl:attribute>

            <xsl:call-template name="generate-toc-link"/>

            <xsl:call-template name="GenerateLabel"/>
            <xsl:apply-templates/>
            <xsl:call-template name="insert-footnotes"/>
        </div>
    </xsl:template>


    <xsl:template name="generate-toc-link">
        <xsl:if test="$outputformat = 'html'"><!-- TODO: improve ePub version of navigational aids -->
            <xsl:if test="//*[@id='toc'] and not(ancestor::q)">
                <!-- If we have an element with id 'toc', include a link to it (except in quoted material) -->
                <span class="pagenum">
                    <xsl:text>[</xsl:text>
                    <a>
                        <xsl:call-template name="generate-href-attribute">
                            <xsl:with-param name="target" select="//*[@id='toc']"/>
                        </xsl:call-template>
                        <xsl:value-of select="$strToc"/>
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
                            <xsl:value-of select="$strPrevious"/>
                        </a>
                    </xsl:if>

                    <xsl:if test="//*[@id='toc']">
                        <!-- If we have an element with id 'toc', include a link to it -->
                        <xsl:if test="preceding-sibling::div1"> | </xsl:if>
                        <a>
                            <xsl:call-template name="generate-href-attribute">
                                <xsl:with-param name="target" select="//*[@id='toc']"/>
                            </xsl:call-template>
                            <xsl:value-of select="$strToc"/>
                         </a>
                    </xsl:if>

                    <xsl:if test="following-sibling::div1">
                        <xsl:if test="preceding-sibling::div1 or //*[@id='toc']"> | </xsl:if>

                        <a>
                            <xsl:call-template name="generate-href-attribute">
                                <xsl:with-param name="target" select="following-sibling::div1[1]"/>
                            </xsl:call-template>
                            <xsl:value-of select="$strNext"/>
                        </a>
                    </xsl:if>
                    <xsl:text> ]</xsl:text>
                </p>

            </xsl:if>

        </xsl:if>

    </xsl:template>


    <xsl:template match="div1/head">
        <xsl:call-template name="headPicture"/>
        <xsl:call-template name="setRunningHeader"/>
        <xsl:if test="not(contains(@rend, 'display(image-only)'))">
            <h2>
                <xsl:call-template name="headText"/>
            </h2>
        </xsl:if>
    </xsl:template>



    <!--====================================================================-->
    <!-- div2 -->

    <xsl:template match="div2">
        <div class="div2">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>

            <xsl:call-template name="generate-toc-link"/>
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


    <!--====================================================================-->
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


    <!--====================================================================-->
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


    <!--====================================================================-->
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


    <!--====================================================================-->
    <!-- div6 -->

    <xsl:template match="div6">
        <div class="div6">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="div6/head">
        <xsl:call-template name="headPicture"/>
        <h6>
            <xsl:call-template name="headText"/>
        </h6>
    </xsl:template>

    <!--====================================================================-->
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
            <xsl:attribute name="class">byline <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!--====================================================================-->
    <!-- support templates -->


    <xsl:template name="setRunningHeader">
        <xsl:param name="head" select="."/>

        <xsl:if test="$optionEPubMarkup = 'XXX'">
            <div class="pagehead">
                <xsl:value-of select="$head"/>
            </div>
        </xsl:if>
    </xsl:template>


</xsl:stylesheet>
