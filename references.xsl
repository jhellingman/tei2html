<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f xs xd"
    version="2.0"
    >

    <xd:doc type="stylesheet">
        <xd:short>Templates to handle cross-references.</xd:short>
        <xd:detail>This stylesheet contains a number of templates to handle cross-references.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:key name="id" match="*[@id]" use="@id"/>


    <!--====================================================================-->
    <!-- Cross References -->

    <xd:doc>
        <xd:short>Handle an internal cross-reference.</xd:short>
        <xd:detail>
            <p>Insert a hyperlink that will link to the referenced <code>@target</code>-attribute in the generated output.</p>
            <p>This template includes special handling to make sure elements inside footnotes do point to the correct
            target file when generating multiple-file output, and those footnotes end-up in a different file.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="ref[@target]">
        <xsl:variable name="target" select="@target"/>
        <xsl:variable name="targetNode" select="key('id', $target)[1]"/>
        <xsl:choose>

            <xsl:when test="not($targetNode)">
                <xsl:message terminate="no">WARNING: target '<xsl:value-of select="$target"/>' of cross reference not found.</xsl:message>
                <xsl:apply-templates/>
            </xsl:when>
            
            <xsl:when test="@type='noteref'">
                <!-- Special case: reference to footnote, used when the content of the reference 
                     needs to be rendered as a footnote reference mark -->
                <xsl:apply-templates select="$targetNode" mode="noterefnumber"/>
            </xsl:when>

            <xsl:otherwise>
                <a>
                    <xsl:choose>
                        <!-- $target is a footnote or inside footnote -->
                        <xsl:when test="f:insideFootnote($targetNode)">
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

                    <xsl:call-template name="set-lang-id-attributes"/>
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


    <xd:doc>
        <xd:short>Is a node a footnote or inside a footnote?</xd:short>
        <xd:detail>
            <p>This function determines whether a node is a footnote or inside a footnote. This is important,
            as footnotes may be placed in quite different locations than the text they are referred to.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:insideFootnote">
        <xsl:param name="targetNode" as="node()"/>

        <xsl:value-of select="$targetNode/ancestor-or-self::note[@place='foot' or @place='unspecified' or not(@place)]"/>
    </xsl:function>


    <!--====================================================================-->
    <!-- External References -->

    <xd:doc>
        <xd:short>Handle an external cross-reference (1).</xd:short>
        <xd:detail>
            <p>Insert a hyperlink that will link to the referenced <code>@url</code>-attribute in the generated output.</p>
            <p>Two stylesheet parameters control the generation of external links.</p>

            <ul>
                <li>Active external links will be put in the output by setting the stylesheet parameter 
                <code>optionExternalLinks</code> to <code>Yes</code>. External links can be limited to the generated Colophon 
                only by setting this value to <code>HeaderOnly</code>.</li>
                <li>External links will be placed in a table in the colophon (provided a colophon is present) by
                setting <code>optionExternalLinksTable</code> to <code>Yes</code>. Here they will be rendered as an URL.
                The original link will then reference to the table.</li>
            </ul>
        </xd:detail>
    </xd:doc>

    <xsl:template match="xref[@url]">
        <xsl:choose>
            <xsl:when test="$optionExternalLinksTable = 'Yes'">
                <xsl:choose>
                    <xsl:when test="//divGen[@type='Colophon']">
                        <a>
                            <xsl:call-template name="generate-id-attribute"/>
                            <xsl:call-template name="generate-xref-table-href-attribute"/>
                            <xsl:apply-templates/>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

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

    <xd:doc>
        <xd:short>Handle an external cross-reference (2).</xd:short>
        <xd:detail>
            <p>In this template, the <code>class</code>, <code>title</code>, and <code>href</code> attributes in the output HTML are determined.</p>

            <p>The main document language is used to apply language-dependent translations. TODO: This should be changed to use the language of the local context.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="handle-xref">
        <a>
            <xsl:call-template name="set-lang-id-attributes"/>
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


    <xd:doc>
        <xd:short>Translate a URL to an HTML class.</xd:short>
        <xd:detail>
            <p>Translate a URL to an HTML class, so URL dependent styling can be applied. See the documentation for <code>f:translate-xref-url</code> 
            for short-hand url notations supported.</p>
        </xd:detail>
        <xd:param name="url" type="string">The URL to be translated.</xd:param>
    </xd:doc>

    <xsl:function name="f:translate-xref-class">
        <xsl:param name="url" as="xs:string"/>

        <xsl:choose>
            <xsl:when test="starts-with($url, 'pg:')">pglink</xsl:when>
            <xsl:when test="starts-with($url, 'pgi:')">pgilink</xsl:when>
            <xsl:when test="starts-with($url, 'oclc:')">catlink</xsl:when>
            <xsl:when test="starts-with($url, 'oln:')">catlink</xsl:when>
            <xsl:when test="starts-with($url, 'olw:')">catlink</xsl:when>
            <xsl:when test="starts-with($url, 'wpp:')">wpplink</xsl:when>
            <xsl:when test="starts-with($url, 'wp:')">wplink</xsl:when>
            <xsl:when test="starts-with($url, 'loc:')">loclink</xsl:when>
            <xsl:when test="starts-with($url, 'bib:')">biblink</xsl:when>
            <xsl:when test="starts-with($url, 'https:')">seclink</xsl:when>
            <xsl:when test="starts-with($url, 'ftp:')">ftplink</xsl:when>
            <xsl:when test="starts-with($url, 'mailto:')">maillink</xsl:when>
            <xsl:otherwise>exlink</xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:short>Translate a URL to an HTML title attribute.</xd:short>
        <xd:detail>
            <p>Translate a URL to an HTML title attribute. See the documentation for <code>f:translate-xref-url</code> 
            for short-hand url notations supported. Note that these titles will be localized in the main document language.</p>
        </xd:detail>
        <xd:param name="url" type="string">The URL to be translated.</xd:param>
    </xd:doc>

    <xsl:function name="f:translate-xref-title">
        <xsl:param name="url" as="xs:string"/>

        <xsl:choose>
            <xsl:when test="starts-with($url, 'pg:')"><xsl:value-of select="f:message('msgLinkToPg')"/></xsl:when>
            <xsl:when test="starts-with($url, 'pgi:')"><xsl:value-of select="f:message('msgLinkToPg')"/></xsl:when>
            <xsl:when test="starts-with($url, 'oclc:')"><xsl:value-of select="f:message('msgLinkToWorldCat')"/></xsl:when>
            <xsl:when test="starts-with($url, 'oln:')"><xsl:value-of select="f:message('msgLinkToOpenLibrary')"/></xsl:when>
            <xsl:when test="starts-with($url, 'olw:')"><xsl:value-of select="f:message('msgLinkToOpenLibrary')"/></xsl:when>
            <xsl:when test="starts-with($url, 'wpp:')"><xsl:value-of select="f:message('msgLinkToWikiPilipinas')"/></xsl:when>
            <xsl:when test="starts-with($url, 'wp:')"><xsl:value-of select="f:message('msgLinkToWikipedia')"/></xsl:when>
            <xsl:when test="starts-with($url, 'loc:')"><xsl:value-of select="f:message('msgLinkToMap')"/></xsl:when>
            <xsl:when test="starts-with($url, 'bib:')"><xsl:value-of select="f:message('msgLinkToBible')"/></xsl:when>
            <xsl:when test="starts-with($url, 'mailto:')"><xsl:value-of select="f:message('msgEmailLink')"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="f:message('msgExternalLink')"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:short>Translate a URL to an HTML href attribute.</xd:short>
        <xd:detail>
            <p>Translate a URL to a URL that can be used in a HTML href attribute.</p>

            <p>The following short-hand notations are supported:</p>

            <table>
            <tr><th>Shorthand notation</th>         <th>Description</th></tr>
            <tr><td>pg:<i>[number]</i></td>         <td>Link to a Project Gutenberg ebook.</td></tr>
            <tr><td>pgi:<i>[number]</i></td>        <td>Link to a Project Gutenberg ebook (internal, for example between multi-volume sets).</td></tr>
            <tr><td>oclc:<i>[id]</i></td>           <td>Link to an OCLC (WorldCat) catalog entry.</td></tr>
            <tr><td>oln:<i>[id]</i></td>            <td>Link to an Open Library catalog entry (at the item level).</td></tr>
            <tr><td>olw:<i>[id]</i></td>            <td>Link to an Open Library catalog entry (at the abstract work level).</td></tr>
            <tr><td>wp:<i>[string]</i></td>         <td>Link to a Wikipedia article.</td></tr>
            <tr><td>wpp:<i>[string]</i></td>        <td>Link to a WikiPilipinas article.</td></tr>
            <tr><td>loc:<i>[coordinates]</i></td>   <td>Link to a geographical location (currently uses Google Maps).</td></tr>
            <tr><td>bib:<i>[book ch:vs]</i></td>    <td>Link to a verse in the Bible (currently uses the Bible gateway, selects the language of the main text, if available).</td></tr>
            <tr><td>mailto:<i>[email address]</i></td> <td>Link to an email address.</td></tr>
            </table>

        </xd:detail>
        <xd:param name="url" type="string">The URL to be translated.</xd:param>
        <xd:param name="lang" type="string">The language of the resource to link to (if applicable).</xd:param>
    </xd:doc>

    <xsl:function name="f:translate-xref-url">
        <xsl:param name="url" as="xs:string"/>
        <xsl:param name="lang" as="xs:string"/>

        <xsl:choose>

            <!-- Link to Project Gutenberg book -->
            <xsl:when test="starts-with($url, 'pg:') or starts-with($url, 'pgi:')">
                <xsl:choose>
                    <xsl:when test="contains($url, '#')">
                        <xsl:variable name="number" select="substring-before(substring-after($url, ':'), '#')"/>
                        <xsl:variable name="anchor" select="substring-after($url, '#')"/>
                        <xsl:value-of select="concat('http://www.gutenberg.org/files/', $number, '/', $number, '-h/', $number, '-h.htm#', $anchor)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>http://www.gutenberg.org/ebooks/</xsl:text><xsl:value-of select="substring-after($url, ':')"/>
                    </xsl:otherwise>
                </xsl:choose> 
            </xsl:when>

            <!-- Link to OCLC (worldcat) catalog entry -->
            <xsl:when test="starts-with($url, 'oclc:')">
                <xsl:text>http://www.worldcat.org/oclc/</xsl:text><xsl:value-of select="substring-after($url, ':')"/>
            </xsl:when>

            <!-- Link to Open Library catalog entry (item level) -->
            <xsl:when test="starts-with($url, 'oln:')">
                <xsl:text>http://openlibrary.org/books/</xsl:text><xsl:value-of select="substring-after($url, ':')"/>
            </xsl:when>

            <!-- Link to Open Library catalog entry (abstract work level) -->
            <xsl:when test="starts-with($url, 'olw:')">
                <xsl:text>http://openlibrary.org/work/</xsl:text><xsl:value-of select="substring-after($url, ':')"/>
            </xsl:when>

            <!-- Link to WikiPilipinas article -->
            <xsl:when test="starts-with($url, 'wpp:')">
                <xsl:text>http://en.wikipilipinas.org/index.php?title=</xsl:text><xsl:value-of select="substring-after($url, ':')"/>
            </xsl:when>

            <!-- Link to Wikipedia article -->
            <xsl:when test="starts-with($url, 'wp:')">
                <xsl:text>http://</xsl:text><xsl:value-of select="substring($lang, 1, 2)"/><xsl:text>.wikipedia.org/wiki/</xsl:text><xsl:value-of select="substring-after($url, ':')"/>
            </xsl:when>

            <!-- Link to location on map, using coordinates -->
            <xsl:when test="starts-with($url, 'loc:')">
                <xsl:variable name="coordinates" select="substring-after($url, ':')"/>
                <xsl:variable name="latitude" select="substring-before($coordinates, ',')"/>
                <xsl:variable name="altitude" select="substring-after($coordinates, ',')"/>
                <xsl:text>http://maps.google.com/maps?q=</xsl:text><xsl:value-of select="$latitude"/>,<xsl:value-of select="$altitude"/>
            </xsl:when>

            <!-- Link to Bible citation -->
            <xsl:when test="starts-with($url, 'bib:')">
                <xsl:text>http://www.biblegateway.com/passage/?search=</xsl:text><xsl:value-of select="iri-to-uri(substring-after($url, ':'))"/>
                <xsl:choose>
                    <!-- TODO: move this to localization data -->
                    <xsl:when test="$lang = 'en'"/>
                    <xsl:when test="$lang = 'de'">&amp;version=LUTH1545</xsl:when>
                    <xsl:when test="$lang = 'es'">&amp;version=RVR1995</xsl:when>
                    <xsl:when test="$lang = 'nl'">&amp;version=HTB</xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="no">No link to text in language '<xsl:value-of select="$lang"/>'.</xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <!-- Link to website (http:// or https://) -->
            <xsl:when test="starts-with($url, 'http:') or starts-with($url, 'https:') or starts-with($url, 'mailto:')">
                <xsl:value-of select="$url"/>
            </xsl:when>

            <xsl:otherwise>
                <xsl:message terminate="no">WARNING: URL '<xsl:value-of select="$url"/>' not understood.</xsl:message>
                <xsl:value-of select="$url"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


</xsl:stylesheet>
