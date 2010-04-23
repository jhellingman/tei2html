<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to format cross references, to be imported in tei2html.xsl.

    Requires: 
        localization.xsl    : templates for localizing strings.
        messages.xsl        : stores localized messages in variables.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"
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
        <a>
            <xsl:choose>
                
                <!-- Link to Project Gutenberg book -->
                <xsl:when test="substring(@url, 1, 3) = 'pg:'">
                    <xsl:attribute name="class">pglink</xsl:attribute>
                    <xsl:attribute name="title"><xsl:value-of select="$strLinkToPg"/></xsl:attribute>
                    <xsl:attribute name="href">http://www.gutenberg.org/etext/<xsl:value-of select="substring-after(@url, 'pg:')"/></xsl:attribute>
                </xsl:when>
                
                <!-- Link to OCLC (worldcat) catalog entry -->
                <xsl:when test="substring(@url, 1, 5) = 'oclc:'">
                    <xsl:attribute name="class">catlink</xsl:attribute>
                    <xsl:attribute name="title"><xsl:value-of select="$strLinkToWorldCat"/></xsl:attribute>
                    <xsl:attribute name="href">http://www.worldcat.org/oclc/<xsl:value-of select="substring-after(@url, 'oclc:')"/></xsl:attribute>
                </xsl:when>

                <!-- Link to Open Library catalog entry -->
                <xsl:when test="substring(@url, 1, 4) = 'oln:'">
                    <xsl:attribute name="class">catlink</xsl:attribute>
                    <xsl:attribute name="title"><xsl:value-of select="$strLinkToOpenLibrary"/></xsl:attribute>
                    <xsl:attribute name="href">http://openlibrary.org/b/<xsl:value-of select="substring-after(@url, 'oln:')"/></xsl:attribute>
                </xsl:when>

                <!-- Link to WikiPilipinas article -->
                <xsl:when test="substring(@url, 1, 4) = 'wpp:'">
                    <xsl:attribute name="class">wpplink</xsl:attribute>
                    <xsl:attribute name="title"><xsl:value-of select="$strLinkToWikiPilipinas"/></xsl:attribute>
                    <xsl:attribute name="href">http://en.wikipilipinas.org/index.php?title=<xsl:value-of select="substring-after(@url, 'wpp:')"/></xsl:attribute>
                </xsl:when>

                <!-- Link to Wikipedia article -->
                <xsl:when test="substring(@url, 1, 3) = 'wp:'">
                    <xsl:attribute name="class">wplink</xsl:attribute>
                    <xsl:attribute name="title"><xsl:value-of select="$strLinkToWikipedia"/></xsl:attribute>
                    <xsl:attribute name="href">http://en.wikipedia.org/wiki/<xsl:value-of select="substring-after(@url, 'wp:')"/></xsl:attribute>
                </xsl:when>

                <!-- Link to location on map, using coordinates -->
                <xsl:when test="substring(@url, 1, 4) = 'loc:'">
                    <xsl:attribute name="class">loclink</xsl:attribute>
                    <xsl:attribute name="title"><xsl:value-of select="$strLinkToMap"/></xsl:attribute>
                    <xsl:variable name="coordinates" select="substring-after(@url, 'loc:')"/>
                    <xsl:variable name="latitude" select="substring-before($coordinates, ',')"/>
                    <xsl:variable name="altitude" select="substring-after($coordinates, ',')"/>
                    <xsl:attribute name="href">http://maps.google.com/maps?q=<xsl:value-of select="$latitude"/>,<xsl:value-of select="$altitude"/></xsl:attribute>
                </xsl:when>

                <!-- Link to Bible citation -->
                <xsl:when test="substring(@url, 1, 4) = 'bib:'">
                    <xsl:attribute name="class">biblink</xsl:attribute>
                    <xsl:attribute name="title"><xsl:value-of select="$strLinkToBible"/></xsl:attribute>
                    <xsl:attribute name="href">http://www.biblegateway.com/passage/?search=<xsl:value-of select="substring-after(@url, 'bib:')"/></xsl:attribute>
                </xsl:when>

                <xsl:otherwise>
                    <xsl:attribute name="class">exlink</xsl:attribute>
                    <xsl:attribute name="title"><xsl:value-of select="$strExternalLink"/></xsl:attribute>
                    <xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </a>
    </xsl:template>


</xsl:stylesheet>
