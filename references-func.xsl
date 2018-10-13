<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f xd xhtml xs">

    <xd:doc type="stylesheet">
        <xd:short>Functions to handle cross-references.</xd:short>
        <xd:detail>This stylesheet contains a number of functions to handle cross-references.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2018, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Translate a URL to an HTML class.</xd:short>
        <xd:detail>
            <p>Translate a URL to an HTML class, so URL dependent styling can be applied. See the documentation for <code>f:translate-xref-url</code> 
            for short-hand url notations supported.</p>
        </xd:detail>
        <xd:param name="url" type="string">The URL to be translated.</xd:param>
    </xd:doc>

    <xsl:function name="f:translate-xref-class" as="xs:string">
        <xsl:param name="url" as="xs:string"/>

        <xsl:choose>
            <xsl:when test="starts-with($url, 'pg:')">pglink</xsl:when>
            <xsl:when test="starts-with($url, 'pgi:')">pgilink</xsl:when>
            <xsl:when test="starts-with($url, 'oclc:')">catlink</xsl:when>
            <xsl:when test="starts-with($url, 'oln:')">catlink</xsl:when>
            <xsl:when test="starts-with($url, 'olw:')">catlink</xsl:when>
            <xsl:when test="starts-with($url, 'wp:')">wplink</xsl:when>
            <xsl:when test="starts-with($url, 'loc:')">loclink</xsl:when>
            <xsl:when test="starts-with($url, 'bib:')">biblink</xsl:when>
            <xsl:when test="starts-with($url, 'tia:')">tialink</xsl:when>

            <xsl:when test="starts-with($url, 'https:')">seclink</xsl:when>
            <xsl:when test="starts-with($url, 'ftp:')">ftplink</xsl:when>
            <xsl:when test="starts-with($url, 'mailto:')">maillink</xsl:when>
            <xsl:when test="starts-with($url, 'audio/')">audiolink</xsl:when>
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

    <xsl:function name="f:translate-xref-title" as="xs:string">
        <xsl:param name="url" as="xs:string"/>

        <xsl:choose>
            <xsl:when test="starts-with($url, 'pg:')"><xsl:value-of select="f:message('msgLinkToPg')"/></xsl:when>
            <xsl:when test="starts-with($url, 'pgi:')"><xsl:value-of select="f:message('msgLinkToPg')"/></xsl:when>
            <xsl:when test="starts-with($url, 'oclc:')"><xsl:value-of select="f:message('msgLinkToWorldCat')"/></xsl:when>
            <xsl:when test="starts-with($url, 'oln:')"><xsl:value-of select="f:message('msgLinkToOpenLibrary')"/></xsl:when>
            <xsl:when test="starts-with($url, 'olw:')"><xsl:value-of select="f:message('msgLinkToOpenLibrary')"/></xsl:when>
            <xsl:when test="starts-with($url, 'wp:')"><xsl:value-of select="f:message('msgLinkToWikipedia')"/></xsl:when>
            <xsl:when test="starts-with($url, 'loc:')"><xsl:value-of select="f:message('msgLinkToMap')"/></xsl:when>
            <xsl:when test="starts-with($url, 'bib:')"><xsl:value-of select="f:message('msgLinkToBible')"/></xsl:when>
            <xsl:when test="starts-with($url, 'tia:')"><xsl:value-of select="f:message('msgLinkToInternetArchive')"/></xsl:when>
            <xsl:when test="starts-with($url, 'mailto:')"><xsl:value-of select="f:message('msgEmailLink')"/></xsl:when>

            <xsl:when test="starts-with($url, 'audio/')">
                <xsl:choose>
                    <xsl:when test="ends-with($url, '.mid') or ends-with($url, '.midi')"><xsl:value-of select="f:message('msgLinkToMidiFile')"/></xsl:when>
                    <xsl:when test="ends-with($url, '.mp3')"><xsl:value-of select="f:message('msgLinkToMp3File')"/></xsl:when>
                    <xsl:when test="ends-with($url, '.ly')"><xsl:value-of select="f:message('msgLinkToLilypondFile')"/></xsl:when>
                    <xsl:when test="ends-with($url, '.mscz')"><xsl:value-of select="f:message('msgLinkToMuseScoreFile')"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="f:message('msgAudioLink')"/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="f:message('msgExternalLink')"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xsl:variable name="prefixDefs" select="//listPrefixDef/prefixDef" as="element(prefixDef)*"/>


    <xd:doc>
        <xd:short>Translate a URL to an HTML href attribute.</xd:short>
        <xd:detail>
            <p>Translate a URL to a URL that can be used in a HTML href attribute.</p>

            <p>The following short-hand notations are supported:</p>

            <table>
                <tr><th>Shorthand notation</th>                 <th>Description</th></tr>
                <tr><td>pg:<i>[number]</i></td>                 <td>Link to a Project Gutenberg ebook.</td></tr>
                <tr><td>pgi:<i>[number]</i></td>                <td>Link to a Project Gutenberg ebook (internal, for example between multi-volume sets).</td></tr>
                <tr><td>oclc:<i>[id]</i></td>                   <td>Link to an OCLC (WorldCat) catalog entry.</td></tr>
                <tr><td>oln:<i>[id]</i></td>                    <td>Link to an Open Library catalog entry (at the item level).</td></tr>
                <tr><td>olw:<i>[id]</i></td>                    <td>Link to an Open Library catalog entry (at the abstract work level).</td></tr>
                <tr><td>wp:<i>[string]</i></td>                 <td>Link to a Wikipedia article.</td></tr>
                <tr><td>tia:<i>[string]</i></td>                <td>Link to an Internet Archive item.</td></tr>
                <tr><td>loc:<i>[coordinates]</i></td>           <td>Link to a geographical location (currently uses Google Maps).</td></tr>
                <tr><td>bib:<i>[book ch:vs@version]</i></td>    <td>Link to a verse in the Bible (currently uses the Bible gateway, selects the language of the main text, if available).</td></tr>
                <tr><td>mailto:<i>[email address]</i></td>      <td>Link to an email address.</td></tr>
            </table>

            <p>In addition to these defaults, the patterns defined in the <code>//listPrefixDef/prefixDef</code> will be handled here.</p>

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
                        <xsl:value-of select="'https://www.gutenberg.org/files/' || $number || '/' || $number || '-h/' || $number || '-h.htm#' || $anchor"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>https://www.gutenberg.org/ebooks/</xsl:text><xsl:value-of select="substring-after($url, ':')"/>
                    </xsl:otherwise>
                </xsl:choose> 
            </xsl:when>

            <!-- Link to OCLC (worldcat) catalog entry -->
            <xsl:when test="starts-with($url, 'oclc:')">
                <xsl:text>https://www.worldcat.org/oclc/</xsl:text><xsl:value-of select="substring-after($url, ':')"/>
            </xsl:when>

            <!-- Link to Open Library catalog entry (item level) -->
            <xsl:when test="starts-with($url, 'oln:')">
                <xsl:text>https://openlibrary.org/books/</xsl:text><xsl:value-of select="substring-after($url, ':')"/>
            </xsl:when>

            <!-- Link to Open Library catalog entry (abstract work level) -->
            <xsl:when test="starts-with($url, 'olw:')">
                <xsl:text>https://openlibrary.org/work/</xsl:text><xsl:value-of select="substring-after($url, ':')"/>
            </xsl:when>

            <!-- Link to Wikipedia article -->
            <xsl:when test="starts-with($url, 'wp:')">
                <xsl:text>https://</xsl:text><xsl:value-of select="substring($lang, 1, 2)"/><xsl:text>.wikipedia.org/wiki/</xsl:text><xsl:value-of select="substring-after($url, ':')"/>
            </xsl:when>

            <!-- Link to The Internet Archive -->
            <xsl:when test="starts-with($url, 'tia:')">
                <xsl:text>https://archive.org/details/</xsl:text><xsl:value-of select="substring-after($url, ':')"/>
            </xsl:when>

            <!-- Link to location on map, using coordinates -->
            <xsl:when test="starts-with($url, 'loc:')">
                <xsl:variable name="coordinates" select="substring-after($url, ':')"/>
                <xsl:variable name="latitude" select="substring-before($coordinates, ',')"/>
                <xsl:variable name="altitude" select="substring-after($coordinates, ',')"/>
                <xsl:text>https://maps.google.com/maps?q=</xsl:text><xsl:value-of select="$latitude"/>,<xsl:value-of select="$altitude"/>
            </xsl:when>

            <!-- Link to Bible citation -->
            <xsl:when test="starts-with($url, 'bib:')">
                <xsl:variable name="version">
                    <xsl:choose>
                        <xsl:when test="contains($url, '@')"><xsl:value-of select="substring-after($url, '@')"/></xsl:when>
                        <xsl:when test="$lang = 'en'">NRSV</xsl:when>
                        <xsl:when test="$lang = 'fr'">LSG</xsl:when>
                        <xsl:when test="$lang = 'de'">LUTH1545</xsl:when>
                        <xsl:when test="$lang = 'es'">RVR1995</xsl:when>
                        <xsl:when test="$lang = 'nl'">HTB</xsl:when> <!-- unfortunately, only version available in Dutch -->
                        <xsl:when test="$lang = 'la'">VULGATE</xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="f:logWarning('No link to text in language &quot;{1}&quot;.', ($lang))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="url" select="if (contains($url, '@')) then substring-before($url, '@') else $url"/>
                <xsl:variable name="location" select="substring-after($url, ':')"/>

                <xsl:text>https://www.biblegateway.com/passage/?search=</xsl:text><xsl:value-of select="iri-to-uri($location)"/>
                <xsl:if test="$version != ''">
                    <xsl:text>&amp;version=</xsl:text><xsl:value-of select="iri-to-uri($version)"/>
                </xsl:if>
            </xsl:when>

            <!-- Link to secure website (or https://) -->
            <xsl:when test="starts-with($url, 'https:')">
                <xsl:value-of select="$url"/>
            </xsl:when>

            <!-- Link to non-secure website (http://) -->
            <xsl:when test="starts-with($url, 'http:') or starts-with($url, 'https:') or starts-with($url, 'mailto:')">
                <xsl:copy-of select="f:logWarning('Link to non-secure HTTP website ({1}).', ($url))"/>
                <xsl:value-of select="$url"/>
            </xsl:when>

            <!-- Link to email address (mailto:) -->
            <xsl:when test="starts-with($url, 'mailto:')">
                <xsl:value-of select="$url"/>
            </xsl:when>

            <!-- Internal link to audio file -->
            <xsl:when test="starts-with($url, 'audio/')">
                <xsl:value-of select="$url"/>
            </xsl:when>

            <!-- Expand prefixes defined in //listPrefixDef/prefixDef -->
            <xsl:when test="substring-before($url, ':') = $prefixDefs/@ident">
                <xsl:value-of select="f:applyPrefixDef($url, $prefixDefs[@ident = substring-before($url, ':')][1])"/>
            </xsl:when>

            <xsl:otherwise>
                <xsl:copy-of select="f:logWarning('URL &quot;{1}&quot; not understood.', ($url))"/>
                <xsl:value-of select="$url"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xd:doc>
        <xd:short>Apply a prefixDef to a short url.</xd:short>
        <xd:detail>
            <p>Apply a prefixDef to a short url. This directly feeds the match pattern and replacement pattern into
            the XSLT function, so may lead to a run-time error if those values in the document are not valid.</p>
        </xd:detail>
        <xd:param name="url" type="string">The URL to be expanded.</xd:param>
        <xd:param name="prefixDef" type="element(prefixDef)">The applicable prefixDef element.</xd:param>
    </xd:doc>

    <xsl:function name="f:applyPrefixDef" as="xs:string">
        <xsl:param name="url" as="xs:string"/>
        <xsl:param name="prefixDef" as="element(prefixDef)"/>
        <xsl:variable name="locator" select="substring-after($url, ':')" as="xs:string"/>

        <xsl:copy-of select="f:logDebug('URL {1}; pattern: {2}; replacement: {3}.', ($url, $prefixDef/@matchPattern, $prefixDef/@replacementPattern))"/>

        <xsl:value-of select="replace($locator, $prefixDef/@matchPattern, $prefixDef/@replacementPattern)"/>
    </xsl:function>

</xsl:stylesheet>
