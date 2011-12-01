<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to format cross references, to be imported in tei2html.xsl.

    Requires: 
        localization.xsl    : templates for localizing strings.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="urn:stylesheet-functions"
    exclude-result-prefixes="f xs"
    version="2.0"
    >


    <xsl:key name="id" match="*[@id]" use="@id"/>


    <!--====================================================================-->
    <!-- Cross References -->

    <xsl:template match="ref[@target]">
        <xsl:variable name="target" select="@target"/>
        <xsl:variable name="targetNode" select="key('id', $target)"/>
        <xsl:choose>

            <xsl:when test="not($targetNode)">
                <xsl:message terminate="no">Warning: target '<xsl:value-of select="$target"/>' of cross reference not found.</xsl:message>
                <xsl:apply-templates/>
            </xsl:when>
            
            <xsl:when test="@type='noteref'">
                <!-- Special case: reference to footnote, used when the content of the reference 
                     needs to be rendered as the footnote reference mark -->
                <xsl:apply-templates select="$targetNode" mode="noterefnumber"/>
            </xsl:when>

            <xsl:otherwise>
                <a>
                    <xsl:choose>
                        <!-- $target is footnote or inside footnote -->
                        <xsl:when test="$targetNode/ancestor-or-self::note[@place='foot' or @place='unspecified' or not(@place)]">
                            <xsl:call-template name="generate-footnote-href-attribute">
                                <xsl:with-param name="target" select="$targetNode"/>
                            </xsl:call-template>
                        </xsl:when>

                        <xsl:otherwise>
                            <xsl:call-template name="generate-href-attribute">
                                <xsl:with-param name="target" select="$targetNode"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:call-template name="generate-id-attribute"/>
                    <xsl:if test="@type='pageref'">
                        <xsl:attribute name="class">pageref</xsl:attribute>
                    </xsl:if>
                    <xsl:if test="@type='endnoteref'">
                        <xsl:attribute name="class">noteref</xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="note" mode="noterefnumber">
        <a class="pseudonoteref">
            <xsl:call-template name="generate-footnote-href-attribute"/>
            <xsl:call-template name="footnote-number"/>
        </a>
    </xsl:template>


    <!--====================================================================-->
    <!-- External References -->

    <xsl:template match="xref[@url]">
        <xsl:choose>
            <xsl:when test="$optionExternalLinks = 'Yes'">
                <xsl:call-template name="handle-xref"/>
            </xsl:when>

            <xsl:when test="$optionExternalLinks = 'HeaderOnly' and ancestor::teiHeader">
                <xsl:call-template name="handle-xref"/>
            </xsl:when>

            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="handle-xref">
        <a>
            <xsl:attribute name="class">
                <xsl:value-of select="f:translate-xref-class(@url)"/>
                <xsl:text> </xsl:text>
                <xsl:call-template name="generate-rend-class-name"/>
            </xsl:attribute>
            <xsl:attribute name="title">
                <xsl:value-of select="f:translate-xref-title(@url)"/>
            </xsl:attribute>
            <xsl:attribute name="href">
                <xsl:value-of select="f:translate-xref-url(@url, substring(/TEI.2/@lang, 1, 2))"/>
            </xsl:attribute>
            <xsl:if test="@rel">
                <xsl:attribute name="rel"><xsl:value-of select="@rel"/></xsl:attribute>
            </xsl:if>

            <xsl:apply-templates/>
        </a>
    </xsl:template>


    <xsl:function name="f:translate-xref-class">
        <xsl:param name="url" as="xs:string"/>

        <xsl:choose>
            <xsl:when test="substring($url, 1, 3) = 'pg:'">pglink</xsl:when>
            <xsl:when test="substring($url, 1, 5) = 'oclc:'">catlink</xsl:when>
            <xsl:when test="substring($url, 1, 4) = 'oln:'">catlink</xsl:when>
            <xsl:when test="substring($url, 1, 4) = 'olw:'">catlink</xsl:when>
            <xsl:when test="substring($url, 1, 4) = 'wpp:'">wpplink</xsl:when>
            <xsl:when test="substring($url, 1, 3) = 'wp:'">wplink</xsl:when>
            <xsl:when test="substring($url, 1, 4) = 'loc:'">loclink</xsl:when>
            <xsl:when test="substring($url, 1, 4) = 'bib:'">biblink</xsl:when>
            <xsl:otherwise>exlink</xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="f:translate-xref-title">
        <xsl:param name="url" as="xs:string"/>

        <xsl:choose>
            <xsl:when test="substring($url, 1, 3) = 'pg:'"><xsl:value-of select="f:message('msgLinkToPg')"/></xsl:when>
            <xsl:when test="substring($url, 1, 5) = 'oclc:'"><xsl:value-of select="f:message('msgLinkToWorldCat')"/></xsl:when>
            <xsl:when test="substring($url, 1, 4) = 'oln:'"><xsl:value-of select="f:message('msgLinkToOpenLibrary')"/></xsl:when>
            <xsl:when test="substring($url, 1, 4) = 'olw:'"><xsl:value-of select="f:message('msgLinkToOpenLibrary')"/></xsl:when>
            <xsl:when test="substring($url, 1, 4) = 'wpp:'"><xsl:value-of select="f:message('msgLinkToWikiPilipinas')"/></xsl:when>
            <xsl:when test="substring($url, 1, 3) = 'wp:'"><xsl:value-of select="f:message('msgLinkToWikipedia')"/></xsl:when>
            <xsl:when test="substring($url, 1, 4) = 'loc:'"><xsl:value-of select="f:message('msgLinkToMap')"/></xsl:when>
            <xsl:when test="substring($url, 1, 4) = 'bib:'"><xsl:value-of select="f:message('msgLinkToBible')"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="f:message('msgExternalLink')"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="f:translate-xref-url">
        <xsl:param name="url" as="xs:string"/>
        <xsl:param name="lang" as="xs:string"/>

        <xsl:choose>

            <!-- Link to Project Gutenberg book -->
            <xsl:when test="substring($url, 1, 3) = 'pg:'">
                <xsl:text>http://www.gutenberg.org/ebooks/</xsl:text><xsl:value-of select="substring-after($url, 'pg:')"/>
            </xsl:when>

            <!-- Link to OCLC (worldcat) catalog entry -->
            <xsl:when test="substring($url, 1, 5) = 'oclc:'">
                <xsl:text>http://www.worldcat.org/oclc/</xsl:text><xsl:value-of select="substring-after($url, 'oclc:')"/>
            </xsl:when>

            <!-- Link to Open Library catalog entry (item level) -->
            <xsl:when test="substring($url, 1, 4) = 'oln:'">
                <xsl:text>http://openlibrary.org/books/</xsl:text><xsl:value-of select="substring-after($url, 'oln:')"/>
            </xsl:when>

            <!-- Link to Open Library catalog entry (abstract work level) -->
            <xsl:when test="substring($url, 1, 4) = 'olw:'">
                <xsl:text>http://openlibrary.org/work/</xsl:text><xsl:value-of select="substring-after($url, 'olw:')"/>
            </xsl:when>

            <!-- Link to WikiPilipinas article -->
            <xsl:when test="substring($url, 1, 4) = 'wpp:'">
                <xsl:text>http://en.wikipilipinas.org/index.php?title=</xsl:text><xsl:value-of select="substring-after($url, 'wpp:')"/>
            </xsl:when>

            <!-- Link to Wikipedia article -->
            <xsl:when test="substring($url, 1, 3) = 'wp:'">
                <xsl:text>http://en.wikipedia.org/wiki/</xsl:text><xsl:value-of select="substring-after($url, 'wp:')"/>
            </xsl:when>

            <!-- Link to location on map, using coordinates -->
            <xsl:when test="substring($url, 1, 4) = 'loc:'">
                <xsl:variable name="coordinates" select="substring-after($url, 'loc:')"/>
                <xsl:variable name="latitude" select="substring-before($coordinates, ',')"/>
                <xsl:variable name="altitude" select="substring-after($coordinates, ',')"/>
                <xsl:text>http://maps.google.com/maps?q=</xsl:text><xsl:value-of select="$latitude"/>,<xsl:value-of select="$altitude"/>
            </xsl:when>

            <!-- Link to Bible citation -->
            <xsl:when test="substring($url, 1, 4) = 'bib:'">
                <xsl:text>http://www.biblegateway.com/passage/?search=</xsl:text><xsl:value-of select="iri-to-uri(substring-after($url, 'bib:'))"/>
                <xsl:choose>
                    <!-- TODO: move this to localization data -->
                    <xsl:when test="$lang = 'de'">&amp;version=LUTH1545</xsl:when>
                    <xsl:when test="$lang = 'es'">&amp;version=RVR1995</xsl:when>
                    <xsl:when test="$lang = 'nl'">&amp;version=HTB</xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="no">No link to text in language '<xsl:value-of select="$lang"/>'.</xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <!-- Link to website (http:// or https://) -->
            <xsl:when test="substring($url, 1, 5) = 'http:' or substring($url, 1, 6) = 'https:'">
                <xsl:value-of select="$url"/>
            </xsl:when>

            <xsl:otherwise>
                <xsl:message terminate="no">Warning: URL '<xsl:value-of select="$url"/>' not understood.</xsl:message>
                <xsl:value-of select="$url"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


</xsl:stylesheet>
