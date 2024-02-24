<?xml version="1.0" encoding="iso-8859-1" ?>
<!DOCTYPE xsl:stylesheet [

    <!ENTITY lsquo      "&#x2018;">
    <!ENTITY rsquo      "&#x2019;">
    <!ENTITY ldquo      "&#x201C;">
    <!ENTITY rdquo      "&#x201D;">
    <!ENTITY raquo      "&#187;">
    <!ENTITY laquo      "&#171;">
    <!ENTITY bdquo      "&#8222;">

]>
<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="urn:stylesheet-functions"
                xmlns:img="http://www.gutenberg.ph/2006/schemas/imageinfo"
                xmlns:tmp="urn:temporary"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="f img tmp xd xs">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to generate a colophon.</xd:short>
        <xd:detail>This stylesheet will generate a colophon from the <code>teiHeader</code>, and various other types of information in the TEI file.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2016, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:include href="levenshtein.xsl"/>

    <!--====================================================================-->
    <!-- Colophon -->

    <xd:doc>
        <xd:short>Generate a colophon.</xd:short>
        <xd:detail>
            <p>Generate a colophon for a TEI file, based on information in the <code>teiHeader</code>.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="divGen[@type='Colophon']">
        <div class="transcriberNote">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>

            <h2 class="main"><xsl:value-of select="f:message('msgColophon')"/></h2>

            <xsl:call-template name="colophonBody"/>
        </div>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate the colophon body.</xd:short>
        <xd:detail>
            <p>Generate the body of a colophon for a TEI file, based on information in the <code>teiHeader</code>.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="divGen[@type='ColophonBody']">
        <xsl:call-template name="colophonBody"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate the contents of the colophon body.</xd:short>
        <xd:detail>
            <p>Generate the contents of the body of a colophon for a TEI file, based on information in the <code>teiHeader</code>.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="colophonBody">
        <xsl:context-item as="element(divGen)" use="required"/>
        <h3 class="main"><xsl:value-of select="f:message('msgAvailability')"/></h3>
        <xsl:apply-templates select="/*[self::TEI.2 or self::TEI]/teiHeader/fileDesc/publicationStmt/availability"/>

        <xsl:call-template name="colophonMetadata"/>
        <!-- <xsl:call-template name="catalogEntries"/> -->

        <xsl:if test="f:is-valid(/*[self::TEI.2 or self::TEI]/teiHeader/encodingDesc/p[1])">
            <h3 class="main"><xsl:value-of select="f:message('msgEncoding')"/></h3>
            <xsl:apply-templates select="/*[self::TEI.2 or self::TEI]/teiHeader/encodingDesc/p"/>
        </xsl:if>

        <h3 class="main"><xsl:value-of select="f:message('msgRevisionHistory')"/></h3>
        <xsl:apply-templates select="/*[self::TEI.2 or self::TEI]/teiHeader/revisionDesc"/>

        <xsl:if test="f:is-set('colophon.showExternalReferences')">
            <xsl:call-template name="externalReferences"/>
        </xsl:if>

        <xsl:if test="f:is-set('colophon.showCorrections') and //corr">
            <h3 class="main"><xsl:value-of select="f:message('msgCorrections')"/></h3>
            <xsl:call-template name="correctionTable"/>
        </xsl:if>

        <xsl:if test="f:is-set('colophon.showAbbreviations') and //abbr">
            <h3 class="main"><xsl:value-of select="f:message('msgAbbreviations')"/></h3>
            <xsl:call-template name="abbreviationTable"/>
        </xsl:if>
    </xsl:template>


    <xsl:template match="encodingDesc">
        <xsl:apply-templates/>
    </xsl:template>


    <!-- Ignore the classDecl inside the encodingDesc -->
    <xsl:template match="encodingDesc/classDecl"/>


    <!-- Ignore the tagsDecl inside the encodingDesc -->
    <xsl:template match="encodingDesc/tagsDecl"/>


    <xsl:template name="colophonMetadata">
        <h3 class="main"><xsl:value-of select="f:message('msgMetadata')"/></h3>
        <table class="colophonMetadata">
            <xsl:if test="not(f:is-epub()) and not(f:is-html5())">
                <xsl:attribute name="summary"><xsl:value-of select="f:message('msgMetadata')"/></xsl:attribute>
            </xsl:if>
            <!-- Title(s) -->
            <xsl:copy-of select="f:metadata-line(f:message('msgTitle'), $title)"/>

            <xsl:variable name="titleStatement" select="/*[self::TEI.2 or self::TEI]/teiHeader/fileDesc/titleStmt"/>
            <xsl:variable name="originalTitle" select="$titleStatement/title[@type='original'][1]"/>
            <xsl:if test="$originalTitle">
                <xsl:copy-of select="f:metadata-line(f:message('msgOriginalTitle'), $originalTitle)"/>
            </xsl:if>

            <xsl:call-template name="contributors"/>

            <xsl:apply-templates select="//publicationStmt/date[f:is-valid(.)]" mode="publicationDate"/>

            <xsl:call-template name="generationDate"/>

            <xsl:copy-of select="f:metadata-line(f:message('msgLanguage'), f:message(lower-case($language)))"/>

            <xsl:apply-templates select="//sourceDesc" mode="colophonSourceDesc"/>

            <xsl:call-template name="keywords"/>
            <xsl:call-template name="classification"/>
            <xsl:call-template name="catalogReferences"/>
            <xsl:call-template name="qr-code"/>
        </table>
    </xsl:template>


    <xsl:template mode="publicationDate" match="publicationStmt/date">
        <xsl:copy-of select="f:metadata-line(f:message('msgPublicationDate'), .)"/>
    </xsl:template>


    <xsl:template name="generationDate">
        <xsl:copy-of select="f:metadata-line(f:message('msgGenerationDate'), f:utc-datetime())"/>
    </xsl:template>


    <xsl:template name="contributors">
        <!-- Authors -->
        <xsl:for-each select="//titleStmt/author">
            <xsl:sort select="@key"/>
            <xsl:copy-of select="f:metadata-line-with-url(f:message('msgAuthor'), ., @ref, f:message('msgInfo'))"/>
        </xsl:for-each>

        <!-- Editors -->
        <xsl:for-each select="//titleStmt/editor">
            <xsl:sort select="@key"/>
            <xsl:copy-of select="f:metadata-line-with-url(f:message('msgEditor'), ., @ref, f:message('msgInfo'))"/>
        </xsl:for-each>

        <!-- Other contributors -->
        <xsl:for-each select="//titleStmt/respStmt[resp != 'Transcription']">
            <xsl:sort select="name/@key"/>
            <xsl:copy-of select="f:metadata-line-with-url(f:translate-resp(resp), name, name/@ref, f:message('msgInfo'))"/>
        </xsl:for-each>
    </xsl:template>


    <xsl:function name="f:metadata-line-with-url">
        <xsl:param name="key" as="xs:string"/>
        <xsl:param name="node"/>
        <xsl:param name="url" as="xs:string?"/>
        <xsl:param name="urlText" as="xs:string"/>

        <xsl:variable name="value" select="f:plain-text($node)"/>

        <tr>
            <td><b><xsl:value-of select="if ($key = '') then '' else $key || ':'"/></b></td>
            <td><xsl:value-of select="$value"/></td>
            <td>
                <xsl:choose>
                    <xsl:when test="f:show-xref($url)">
                        <a href="{$url}" class="{f:translate-xref-class($url)}"><xsl:value-of select="$urlText"/></a>
                    </xsl:when>
                    <xsl:when test="f:is-valid($url)">
                        <xsl:value-of select="$urlText"/><xsl:text> </xsl:text><span class="externalUrl"><xsl:value-of select="$url"/></span>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- show neither url nor urlText. -->
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:function>


    <xsl:function name="f:show-xref" as="xs:boolean">
        <xsl:param name="url" as="xs:string?"/>

        <xsl:sequence select="f:is-valid($url) and ((f:get-setting('xref.show') != 'never' and not(f:is-set('pg.compliant'))) or f:is-allowed-url($url))"/>
    </xsl:function>


    <xsl:function name="f:metadata-line-as-url">
        <xsl:param name="key" as="xs:string"/>
        <xsl:param name="node"/>
        <xsl:param name="url" as="xs:string?"/>

        <xsl:variable name="value" select="f:plain-text($node)"/>

        <tr>
            <td><b><xsl:value-of select="if ($key = '') then '' else $key || ':'"/></b></td>
            <td>
                <xsl:choose>
                    <xsl:when test="f:show-xref($url)">
                        <a href="{$url}" class="{f:translate-xref-class($url)}"><xsl:value-of select="$value"/></a>
                    </xsl:when>
                    <xsl:when test="f:is-valid($url)">
                        <xsl:value-of select="$value"/><xsl:text> </xsl:text><span class="externalUrl"><xsl:value-of select="$url"/></span>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$value"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <td/>
        </tr>
    </xsl:function>


    <xsl:function name="f:metadata-line">
        <xsl:param name="key" as="xs:string"/>
        <xsl:param name="node"/>

        <xsl:variable name="value" select="f:plain-text($node)"/>

        <tr>
            <td><b><xsl:value-of select="if ($key = '') then '' else $key || ':'"/></b></td>
            <td><xsl:value-of select="$value"/></td>
            <td/>
        </tr>
    </xsl:function>


    <xsl:template match="sourceDesc" mode="colophonSourceDesc">
        <xsl:apply-templates mode="colophonSourceDesc"/>
    </xsl:template>


    <xsl:template match="bibl" mode="colophonSourceDesc">
        <xsl:apply-templates mode="colophonSourceDesc"/>
    </xsl:template>


    <xsl:template match="publisher" mode="colophonSourceDesc">
        <xsl:copy-of select="f:metadata-line(f:message('msgSourcePublisher'), .)"/>
    </xsl:template>


    <xsl:template match="pubPlace" mode="colophonSourceDesc">
        <xsl:copy-of select="f:metadata-line(f:message('msgSourcePubPlace'), .)"/>
    </xsl:template>


    <xsl:template match="date[f:is-valid(.)]" mode="colophonSourceDesc">
        <xsl:copy-of select="f:metadata-line(f:message('msgSourcePublicationDate'), .)"/>
    </xsl:template>


    <!-- Ignore other items in sourceDesc for colophon -->
    <xsl:template match="*" mode="colophonSourceDesc"/>


    <xd:doc>
        <xd:short>Generate a list of classifications.</xd:short>
        <xd:detail>
            <p>Generate a list of classifications, based on information in the <code>profileDesc/textClass/classCode</code>.
            Note that for proper rendering, a <code>taxonomy</code> element corresponding to the indicated scheme must be present,
            and contain a human-readable text. (works for TEI P3; TODO: make this work for TEI P5.)</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="classification">
        <xsl:if test="//profileDesc/textClass/classCode">
            <xsl:for-each select="//profileDesc/textClass/classCode">
                <xsl:choose>
                    <xsl:when test="not(contains(., '#')) and //taxonomy[@id=current()/@scheme]/bibl">
                        <xsl:copy-of select="f:metadata-line(//taxonomy[@id=current()/@scheme]/bibl, .)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="f:metadata-line(f:message('msgClassCode'), .)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>


    <xsl:template name="keywords">
        <xsl:if test="//profileDesc/textClass/keywords/list/item[not(contains(., '#'))]">
            <xsl:for-each select="//profileDesc/textClass/keywords/list/item[not(contains(., '#'))]">
                <xsl:sort select="."/>
                <xsl:variable name="key" select="if (position() = 1) then f:message('msgKeywords') else ''"/>
                <xsl:copy-of select="f:metadata-line($key, .)"/>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate links to catalog entries.</xd:short>
        <xd:detail>
            <p>Depending on the presence of various types of <code>idno</code> elements, corresponding links to the relevant sites will be created. This
            code handles IDs pointing to Project Gutenberg, the Library of Congress, WorldCat, Open Library and LibraryThing.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="catalogEntries">
        <xsl:if test="//idno[f:is-valid(.)]">
            <h3><xsl:value-of select="if (count(//idno[f:is-valid(.)]) > 1) then f:message('msgCatalogEntries') else f:message('msgCatalogEntry')"/></h3>
            <table class="catalogEntries">
                <xsl:if test="not(f:is-epub()) and not(f:is-html5())">
                    <xsl:attribute name="summary"><xsl:value-of select="f:message('msgCatalogEntries')"/></xsl:attribute>
                </xsl:if>
                <xsl:apply-templates select="//idno[@type = 'PGnum'][f:is-valid(.)]" mode="catalogEntries"/>
                <xsl:apply-templates select="//idno[@type != 'PGnum'][f:is-valid(.)]" mode="catalogEntries">
                    <xsl:sort select="@type"/>
                </xsl:apply-templates>
            </table>
        </xsl:if>
    </xsl:template>


    <xsl:function name="f:catalog-entry-line">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="url" as="xs:string"/>
        <xsl:param name="id" as="xs:string"/>

        <tr>
            <td><xsl:value-of select="$name"/>:</td>
            <td>
                <a href="{$url}" class="{f:translate-xref-class($url)}"><xsl:value-of select="$id"/></a>
            </td>
        </tr>
    </xsl:function>


    <xsl:template mode="catalogEntries" match="idno[@type='PGnum']">
        <xsl:copy-of select="f:catalog-entry-line(f:message('msgPgCatalogEntry'), 'https://www.gutenberg.org/ebooks/' || ., .)"/>
    </xsl:template>


    <xsl:template mode="catalogEntries" match="idno[@type='LCCN']">
        <xsl:copy-of select="f:catalog-entry-line(f:message('msgLibraryOfCongressCatalogEntry'), 'https://lccn.loc.gov/' || ., .)"/>
    </xsl:template>


    <xsl:template mode="catalogEntries" match="idno[@type='VIAF']">
        <xsl:copy-of select="f:catalog-entry-line(f:message('msgVirtualInternationalAuthorityFile'), 'https://viaf.org/viaf/' || ., .)"/>
    </xsl:template>


    <xsl:template mode="catalogEntries" match="idno[@type='OLN']">
        <xsl:copy-of select="f:catalog-entry-line(f:message('msgOpenLibraryCatalogEntry'), 'https://openlibrary.org/books/' || ., .)"/>
    </xsl:template>


    <xsl:template mode="catalogEntries" match="idno[@type='OLW']">
        <xsl:copy-of select="f:catalog-entry-line(f:message('msgOpenLibraryCatalogWorkEntry'), 'https://openlibrary.org/works/' || ., .)"/>
    </xsl:template>


    <xsl:template mode="catalogEntries" match="idno[@type='OCLC']">
        <xsl:copy-of select="f:catalog-entry-line(f:message('msgOclcCatalogEntry'), 'https://www.worldcat.org/oclc/' || ., .)"/>
    </xsl:template>


    <xsl:template mode="catalogEntries" match="idno[@type='LibThing']">
        <xsl:copy-of select="f:catalog-entry-line(f:message('msgLibraryThingEntry'), 'https://www.librarything.com/work/' || ., .)"/>
    </xsl:template>


    <xsl:template mode="catalogEntries" match="idno[@type='PGSrc']">
        <xsl:copy-of select="f:catalog-entry-line(f:message('msgGitHubRepository'), 'https://github.com/GutenbergSource/' || ., .)"/>
    </xsl:template>


    <!-- Ignore other types of idno's -->
    <xsl:template mode="catalogEntries" match="idno"/>


    <xsl:function name="f:catalog-entry">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="baseUrl" as="xs:string"/>

        <tr>
            <td><b><xsl:value-of select="f:message('msgCatalogEntry')"/>:</b></td>
            <td colspan="2">
                <xsl:value-of select="$name"/>:
                <a class="catlink" href="{$baseUrl || $id}">
                    <xsl:value-of select="$id"/>
                </a>
            </td>
        </tr>
    </xsl:function>


    <xsl:template name="catalogReferences">
        <xsl:apply-templates select="//idno[@type = 'PGnum'][f:is-valid(.)]" mode="catalogReferences"/>
        <xsl:apply-templates select="//idno[@type != 'PGnum'][f:is-valid(.)]" mode="catalogReferences">
            <xsl:sort select="@type"/>
        </xsl:apply-templates>
    </xsl:template>


    <xsl:template mode="catalogReferences" match="idno[@type='PGnum']">
        <xsl:copy-of select="f:metadata-line-as-url(f:message('msgProjectGutenberg'), ., 'https://www.gutenberg.org/ebooks/' || .)"/>
    </xsl:template>

    <xsl:template mode="catalogReferences" match="idno[@type='LCCN']">
        <xsl:copy-of select="f:metadata-line-as-url(f:message('msgLibraryOfCongress'), ., 'https://lccn.loc.gov/' || .)"/>
    </xsl:template>


    <xsl:template mode="catalogReferences" match="idno[@type='VIAF']">
        <xsl:copy-of select="f:metadata-line-as-url(f:message('msgViaf'), ., 'https://viaf.org/viaf/' || .)"/>
    </xsl:template>


    <xsl:template mode="catalogReferences" match="idno[@type='OLN']">
        <xsl:copy-of select="f:metadata-line-as-url(f:message('msgOpenLibraryBook'), ., 'https://openlibrary.org/books/' || .)"/>
    </xsl:template>


    <xsl:template mode="catalogReferences" match="idno[@type='OLW']">
        <xsl:copy-of select="f:metadata-line-as-url(f:message('msgOpenLibraryWork'), ., 'https://openlibrary.org/works/' || .)"/>
    </xsl:template>


    <xsl:template mode="catalogReferences" match="idno[@type='OCLC']">
        <xsl:copy-of select="f:metadata-line-as-url(f:message('msgOclcWorldCat'), ., 'https://www.worldcat.org/oclc/' || .)"/>
    </xsl:template>


    <xsl:template mode="catalogReferences" match="idno[@type='LibThing']">
        <xsl:copy-of select="f:metadata-line-as-url(f:message('msgLibraryThing'), ., 'https://www.librarything.com/work/' || .)"/>
    </xsl:template>


    <xsl:template mode="catalogReferences" match="idno[@type='PGSrc']">
        <xsl:copy-of select="f:metadata-line-as-url(f:message('msgGitHub'), ., 'https://github.com/GutenbergSource/' || .)"/>
    </xsl:template>


    <!-- Ignore other types of idno's -->
    <xsl:template mode="catalogReferences" match="idno"/>


    <xd:doc>
        <xd:short>Include an image with a QR-code if work is posted to PG.</xd:short>
    </xd:doc>

    <xsl:template name="qr-code">
        <xsl:variable name="pgNum" select="//idno[@type = 'PGnum'][1]"/>
        <xsl:variable name="qrImage" select="f:qr-image($pgNum)"/>

        <xsl:if test="f:is-valid($pgNum) and $imageInfo/img:images/img:image[@path=$qrImage]">
            <tr>
                <td><b><xsl:value-of select="f:message('msgQrCode')"/>:</b></td>
                <td colspan="2">
                    <xsl:copy-of select="f:output-image($qrImage, f:message('msgQrCodePgUrl'))"/>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>


    <xsl:function name="f:qr-image" as="xs:string">
        <xsl:param name="pgNum"/>

        <xsl:sequence select="if (matches($pgNum, '^[0-9]+$')) then 'images/qr' || $pgNum || '.png' else 'images/qrcode.png'"/>
    </xsl:function>


    <!--====================================================================-->
    <!-- List of Corrections -->

    <xd:doc>
        <xd:short>Generate a list of corrections.</xd:short>
        <xd:detail>
            <p>Generate a list of corrections made to the text, as indicated by <code>corr</code>-elements.
            Group identical corrections together. The page numbers links back to the location of the
            <code>corr</code>-element in the text (except when more than a set number).</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="divGen[@type='corr']">
        <xsl:if test="//corr">
            <h2 class="main"><xsl:value-of select="f:message('msgCorrections')"/></h2>
            <xsl:call-template name="correctionTable"/>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:short>Generate the contents of the list of corrections.</xd:short>
        <xd:detail>
            <p>Generate the contents of the list of corrections as an HTML table. Since corrections can be encoded
            in two ways (as <code>corr</code> elements in older TEI versions and as <code>choice</code> elements
            in newer TEI versions), first collect and normalize the two variants into <code>tmp:choice</code> elements
            in the variable <code>$corrections</code>. Group these by content and render as sorted list.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="correctionTable">
        <xsl:variable name="corrections">
            <xsl:apply-templates select="//corr[not(parent::choice) and not(ancestor::seg[@copyOf])] | //choice[corr]" mode="collect-corrections"/>
        </xsl:variable>

        <p><xsl:value-of select="f:format-message('msgCountCorrectionsAppliedToText', map{'count': count($corrections/tmp:choice)})"/></p>

        <table class="correctionTable">
            <xsl:if test="not(f:is-epub()) and not(f:is-html5())">
                <xsl:attribute name="summary"><xsl:value-of select="f:message('msgCorrectionsOverview')"/></xsl:attribute>
            </xsl:if>
            <tr>
                <th><xsl:value-of select="f:message('msgPage')"/></th>
                <th><xsl:value-of select="f:message('msgSource')"/></th>
                <th><xsl:value-of select="f:message('msgCorrection')"/></th>
                <xsl:if test="f:is-set('colophon.showEditDistance')">
                    <th><xsl:value-of select="f:message('msgEditDistance')"/></th>
                </xsl:if>
            </tr>

            <xsl:copy-of select="f:correctionTableRows($corrections)"/>
        </table>

        <xsl:if test="f:is-set('colophon.showSuggestedCorrections')">
            <p><xsl:value-of select="f:message('msgCorrectionsNotAppliedToText')"/></p>

            <xsl:variable name="sics">
                <xsl:apply-templates select="//sic[not(parent::choice) and not(ancestor::seg[@copyOf])] | //choice[sic]" mode="collect-corrections"/>
            </xsl:variable>

            <table class="correctionTable">
                <xsl:if test="not(f:is-epub()) and not(f:is-html5())">
                    <xsl:attribute name="summary"><xsl:value-of select="f:message('msgQuestionablesOverview')"/></xsl:attribute>
                </xsl:if>
                <tr>
                    <th><xsl:value-of select="f:message('msgPage')"/></th>
                    <th><xsl:value-of select="f:message('msgSource')"/></th>
                    <th><xsl:value-of select="f:message('msgSuggestedCorrection')"/></th>
                    <xsl:if test="f:is-set('colophon.showEditDistance')">
                        <th><xsl:value-of select="f:message('msgEditDistance')"/></th>
                    </xsl:if>
                </tr>

                <xsl:copy-of select="f:correctionTableRows($sics)"/>
            </table>
        </xsl:if>
    </xsl:template>


    <xsl:function name="f:correctionTableRows">
        <xsl:param name="corrections"/>

        <xsl:for-each-group select="$corrections/tmp:choice" group-by="tmp:sic || '@@@' || tmp:corr">
            <xsl:if test="f:is-set('colophon.showMinorCorrections') or not(f:correction-is-minor(.))">
                <tr>
                    <td class="width20">
                        <xsl:call-template name="correctionTablePageReferences"/>
                    </td>
                    <td class="width40 bottom" lang="{f:fix-lang(@lang)}">
                        <xsl:call-template name="correctionTableSourceText"/>
                    </td>
                    <td class="width40 bottom" lang="{f:fix-lang(@lang)}">
                        <xsl:call-template name="correctionTableCorrectedText"/>
                    </td>
                    <xsl:if test="f:is-set('colophon.showEditDistance')">
                        <td class="bottom">
                            <xsl:value-of select="f:correction-table-edit-distance(.)"/>
                        </td>
                    </xsl:if>
                </tr>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:function>


    <xsl:template name="correctionTablePageReferences">
        <xsl:context-item as="element(tmp:choice)" use="required"/>
        <xsl:choose>
            <xsl:when test="count(current-group()) &gt; number(f:get-setting('colophon.maxCorrectionCount'))">
                <i>
                    <xsl:attribute name="title">
                        <xsl:copy-of select="f:format-message('msgCountOccurrences', map{'count': count(current-group())})"/>
                    </xsl:attribute>
                    <xsl:value-of select="f:message('msgPassim')"/>.
                </i>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="current-group()">
                    <xsl:if test="position() != 1">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <a class="pageref" href="{@href}"><xsl:copy-of select="f:convert-markdown(@page)"/></a>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="correctionTableSourceText">
        <xsl:context-item as="element(tmp:choice)" use="required"/>
        <xsl:choose>
            <xsl:when test="tmp:sic != ''">
                <xsl:apply-templates select="tmp:sic"/>
            </xsl:when>
            <xsl:otherwise>
                [<i><xsl:value-of select="f:message('msgNotInSource')"/></i>]
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="correctionTableCorrectedText">
        <xsl:context-item as="element(tmp:choice)" use="required"/>
        <xsl:choose>
            <xsl:when test="tmp:corr != ''">
                <xsl:apply-templates select="tmp:corr"/>
            </xsl:when>
            <xsl:otherwise>
                [<i><xsl:value-of select="f:message('msgDeleted')"/></i>]
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:function name="f:correction-is-minor" as="xs:boolean">
        <xsl:param name="choice" as="element(tmp:choice)"/>
        <xsl:variable name="type" select="($choice/tmp:corr/@type | $choice/@type)[1]"/>
        <xsl:sequence select="f:correction-is-minor($choice/tmp:sic, $choice/tmp:corr, $type)"/>
    </xsl:function>


    <xsl:function name="f:correction-is-minor" as="xs:boolean">
        <xsl:param name="sic"/>
        <xsl:param name="corr"/>
        <xsl:param name="type"/>

        <xsl:variable name="sic" select="if ($sic) then $sic else ''" as="xs:string"/>
        <xsl:variable name="corr" select="if ($corr) then $corr else ''" as="xs:string"/>
        <xsl:variable name="type" select="if ($type) then $type else ''" as="xs:string"/>

        <!-- A correction is minor if it
             1. only differs in case,
             2. only differs in accents,
             3. only contains certain punctuation marks and spaces, in total at most 6 characters,
             4. is marked as such with @type="minor" or @type="scanno". -->

        <xsl:sequence select="lower-case(f:strip-diacritics($sic)) = lower-case(f:strip-diacritics($corr))
            or matches($sic || $corr, '^[&lsquo;&rsquo;&ldquo;&rdquo;&bdquo;&laquo;&raquo;.,:; ]{0,6}$')
            or $type = ('minor', 'scanno')"/>
    </xsl:function>


    <xsl:function name="f:correction-table-edit-distance" as="xs:string">
        <xsl:param name="choice" as="element(tmp:choice)"/>
        <xsl:variable name="sic" select="$choice/tmp:sic" as="xs:string"/>
        <xsl:variable name="corr" select="$choice/tmp:corr" as="xs:string"/>

        <xsl:variable name="editDistance" select="f:levenshtein($sic, $corr)" as="xs:integer"/>
        <xsl:variable name="normalizedEditDistance" select="f:levenshtein(f:strip-diacritics($sic), f:strip-diacritics($corr))" as="xs:integer"/>
        <xsl:sequence select="if ($editDistance = $normalizedEditDistance)
            then xs:string($editDistance)
            else xs:string($editDistance) || ' / ' || xs:string($normalizedEditDistance)"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Convert a traditional <code>corr</code> element to a <code>tmp:choice</code> element.</xd:short>
    </xd:doc>

    <xsl:template match="corr[not(f:in-transliteration(.))]" mode="collect-corrections">
        <tmp:choice>
            <xsl:attribute name="lang" select="f:get-current-lang(.)"/>
            <xsl:attribute name="page" select="f:find-page-number(.)"/>
            <xsl:call-template name="corr-href-attribute"/>
            <tmp:corr>
                <xsl:copy-of select="* | text() | @*"/>
            </tmp:corr>
            <tmp:sic>
                <xsl:value-of select="@sic"/>
            </tmp:sic>
        </tmp:choice>
    </xsl:template>


    <xd:doc>
        <xd:short>Convert a traditional <code>sic</code> element to a <code>tmp:choice</code> element.</xd:short>
    </xd:doc>

    <xsl:template match="sic[not(f:in-transliteration(.))]" mode="collect-corrections">
        <tmp:choice>
            <xsl:attribute name="lang" select="f:get-current-lang(.)"/>
            <xsl:attribute name="page" select="f:find-page-number(.)"/>
            <xsl:call-template name="corr-href-attribute"/>
            <tmp:sic>
                <xsl:copy-of select="* | text() | @*"/>
            </tmp:sic>
            <tmp:corr>
                <xsl:value-of select="@corr"/>
            </tmp:corr>
        </tmp:choice>
    </xsl:template>


    <xd:doc>
        <xd:short>Convert a correction in a <code>tmp:choice</code> element to a temporary choice element.</xd:short>

        <xd:detail>Ignore corrections nested inside <code>reg[@type='trans']</code> elements, as those will not be displayed
        in the output, and thus cannot be referenced.</xd:detail>
    </xd:doc>

    <xsl:template match="choice[not(f:in-transliteration(.))]" mode="collect-corrections">
        <tmp:choice>
            <xsl:attribute name="page" select="f:find-page-number(.)"/>
            <xsl:attribute name="lang" select="f:get-current-lang(.)"/>
            <xsl:call-template name="corr-href-attribute"/>
            <tmp:corr>
                <xsl:copy-of select="corr/* | corr/text() | corr/@*"/>
            </tmp:corr>
            <tmp:sic>
                <xsl:copy-of select="sic/* | sic/text() | sic/@*"/>
            </tmp:sic>
         </tmp:choice>
    </xsl:template>


    <xd:doc>
        <xd:short>Determine whether a node is inside (automatically added) transliteration.</xd:short>
    </xd:doc>

    <xsl:function name="f:in-transliteration" as="xs:boolean">
        <xsl:param name="node" as="node()"/>
        <xsl:sequence select="boolean($node/ancestor::reg[@type='trans'])"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine the link back to the correction.</xd:short>
    </xd:doc>

    <xsl:template name="corr-href-attribute">
        <xsl:choose>
            <xsl:when test="f:inside-footnote(.)">
                <xsl:attribute name="href" select="f:generate-footnote-href(.)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="href" select="f:generate-href(.)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!--====================================================================-->
    <!-- Abbreviations -->

    <xd:doc>
        <xd:short>Generate the contents of the list of abbreviations.</xd:short>
        <xd:detail>
            <p>Generate the contents of the list of abbreviations as an HTML table. Since abbreviations can be encoded
            in two ways (as <code>abbr</code> elements in older TEI versions and as <code>choice</code> elements
            in newer TEI versions), first collect and normalize the two variants into <code>tmp:choice</code> elements
            in the variable <code>$abbreviations</code>. Group these by content and render as sorted list.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="abbreviationTable">
        <p><xsl:value-of select="f:message('msgAbbreviationOverview')"/></p>

        <table class="abbreviationTable">
            <xsl:if test="not(f:is-epub()) and not(f:is-html5())">
                <xsl:attribute name="summary"><xsl:value-of select="f:message('msgAbbreviationOverview')"/></xsl:attribute>
            </xsl:if>
            <tr>
                <th><xsl:value-of select="f:message('msgAbbreviation')"/></th>
                <th><xsl:value-of select="f:message('msgExpansion')"/></th>
            </tr>

            <xsl:variable name="abbreviations">
                <xsl:apply-templates select="//abbr[not(parent::choice)] | //choice[abbr]" mode="collect-abbreviations"/>
            </xsl:variable>

            <xsl:variable name="abbreviations">
                <xsl:for-each select="$abbreviations/tmp:choice">
                    <xsl:variable name="abbr" select="tmp:abbr" as="xs:string"/>
                    <xsl:choose>
                        <!-- If we have no expansion, but we do have a case of this abbreviation with an expansion then forget about it. -->
                        <xsl:when test="tmp:expan = '' and $abbreviations/tmp:choice[string(tmp:abbr) = $abbr and tmp:expan != '']"/>
                        <xsl:otherwise>
                            <xsl:copy-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>

            <xsl:for-each-group select="$abbreviations/tmp:choice" group-by="tmp:abbr || '@@@' || tmp:expan">
                <xsl:sort select="lower-case(tmp:abbr)"/>
                <tr>
                    <td class="bottom">
                        <xsl:apply-templates select="tmp:abbr"/>
                    </td>
                    <td class="bottom">
                        <xsl:choose>
                            <xsl:when test="tmp:expan != ''">
                                <xsl:apply-templates select="tmp:expan"/>
                            </xsl:when>
                            <xsl:otherwise>
                                [<i><xsl:value-of select="f:message('msgExpansionNotAvailable')"/></i>]
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                </tr>
            </xsl:for-each-group>
        </table>
    </xsl:template>


    <xd:doc>
        <xd:short>Convert a traditional <code>abbr</code> element to a <code>tmp:choice</code> element.</xd:short>
    </xd:doc>

    <xsl:template match="abbr" mode="collect-abbreviations">
        <tmp:choice>
            <tmp:abbr>
                <xsl:copy-of select="* | text()"/>
            </tmp:abbr>
            <tmp:expan>
                <xsl:value-of select="@expan"/>
            </tmp:expan>
        </tmp:choice>
    </xsl:template>


    <xd:doc>
        <xd:short>Ignore those abbreviations that are stand-ins for dictionary lemmas (to avoid a huge
        list of irrelevant abbreviations).</xd:short>
    </xd:doc>

    <xsl:template match="abbr[@type = 'lemma']" mode="collect-abbreviations"/>


    <xd:doc>
        <xd:short>Convert an abbreviation in a <code>choice</code> element to a <code>tmp:choice</code> element.</xd:short>
    </xd:doc>

    <xsl:template match="choice" mode="collect-abbreviations">
        <tmp:choice>
            <xsl:attribute name="lang" select="f:get-current-lang(.)"/>
            <tmp:abbr>
                <xsl:copy-of select="abbr/* | abbr/text()"/>
            </tmp:abbr>
            <tmp:expan>
                <xsl:copy-of select="expan/* | expan/text()"/>
            </tmp:expan>
         </tmp:choice>
    </xsl:template>


    <!--====================================================================-->
    <!-- External References -->


    <xsl:template match="divGen[@type='References']">
        <xsl:call-template name="internalReferenceTable"/>
        <xsl:call-template name="externalReferenceTable"/>
    </xsl:template>

    <xd:doc>
        <xd:short>Generate a table of external references.</xd:short>
        <xd:detail>
            <p>Generate a table of external references in the text, as indicated by <code>xref</code>-elements or
            <code>ref</code>-elements. Group identical external references together. The page numbers link
            back to the location the external reference appears in the text.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="externalReferences" expand-text="yes">
        <xsl:if test="//xref[not(f:is-allowed-url(@url))] | /TEI//ref[not(starts-with(@target, '#'))]">
            <h3 class="main">{f:message('msgExternalReferences')}</h3>

            <p>{ if (f:get-setting('xref.show') = 'never' and not(f:is-set('pg.compliant')))
                    then f:message('msgGutenbergNoExternalReferences')
                    else f:message('msgExternalReferencesDisclaimer') }
               { if (f:is-set('xref.table'))
                    then f:message('msgGutenbergExternalReferencesExplanation')
                    else '' }
            </p>

            <xsl:if test="f:is-set('xref.table')">
                <xsl:call-template name="externalReferenceTable"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate the contents of the external references.</xd:short>
        <xd:detail>
            <p>Generate the contents of the table of external references as an HTML table.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="externalReferenceTable">

        <!-- TODO: make this table also work for P5 href elements -->
        <xsl:if test="//xref[not(f:is-allowed-url(@url))]">
            <table class="externalReferenceTable">
                <tr>
                    <th><xsl:value-of select="f:message('msgPage')"/></th>
                    <th><xsl:value-of select="f:message('msgUrl')"/></th>
                </tr>
                <xsl:for-each-group select="//xref[not(f:is-allowed-url(@url))]" group-by="@url">
                    <xsl:sort select="@url"/>
                    <tr>
                        <td>
                            <xsl:for-each select="current-group()">
                                <xsl:if test="position() != 1">
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                                <a class="pageref" id="{f:generate-id(.)}ext" href="{f:generate-safe-href(.)}">
                                    <xsl:copy-of select="f:convert-markdown(f:find-page-number(.))"/>
                                </a>
                            </xsl:for-each>
                        </td>
                        <td>
                            <xsl:variable name="url" select="f:translate-xref-url(@url, substring(f:get-document-lang(), 1, 2))"/>
                            <xsl:choose>
                                <xsl:when test="f:get-setting('xref.show') != 'never' and not(f:is-set('pg.compliant'))">
                                    <a href="{$url}" class="{f:translate-xref-class(@url)}"><xsl:value-of select="$url"/></a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <span class="externalUrl"><xsl:value-of select="$url"/></span>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </xsl:for-each-group>
            </table>
        </xsl:if>
    </xsl:template>


    <xsl:template name="internalReferenceTable">
        <xsl:if test="//ref[@target]">
            <table class="internalReferenceTable">
                <tr>
                    <th><xsl:value-of select="f:message('msgPage')"/></th>
                    <th><xsl:value-of select="f:message('msgText')"/></th>
                    <th><xsl:value-of select="f:message('msgTarget')"/></th>
                </tr>
                <xsl:for-each select="//ref[@target]">
                    <xsl:sort select="@target"/>
                    <tr>
                        <td>
                            <a class="pageref" id="{f:generate-id(.)}ext" href="{f:generate-safe-href(.)}">
                                <xsl:copy-of select="f:convert-markdown(f:find-page-number(.))"/>
                            </a>
                        </td>
                        <td>
                            <xsl:apply-templates select="."/>
                        </td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="key('id', @target)[1]">
                                    <xsl:value-of select="@target"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <span class="missingTarget"><xsl:value-of select="@target"/></span>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </xsl:for-each>
            </table>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Find the page number for a node.</xd:short>
        <xd:detail>
            <p>Find the page number for a node. This will try to locate the preceding <code>pb</code>-element, and return its
            <code>@n</code>-attribute value. This should normally correspond with the page the node appeared on in the source.</p>
        </xd:detail>
        <xd:param name="node" type="node()">The node for which the page-number is to be found.</xd:param>
    </xd:doc>

    <xsl:function name="f:find-page-number" as="xs:string">
        <xsl:param name="node" as="node()"/>

        <xsl:choose>
            <xsl:when test="not($node/preceding::pb[1]/@n) or $node/preceding::pb[1]/@n = ''">
                <xsl:value-of select="f:message('msgNotApplicable')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$node/preceding::pb[1]/@n"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <!--====================================================================-->
    <!-- Language Fragments -->

    <xd:doc>
        <xd:short>Generate an overview of foreign language fragments.</xd:short>
        <xd:detail>
            <p>Generate a table of foreign language fragments in the text, as indicated by the <code>@lang</code>-attribute.
            Group the fragments by language, and order them by the language code.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="divGen[@type='LanguageFragments']">
        <div class="transcriberNote">
            <h2 class="main"><xsl:value-of select="f:message('msgOverviewForeignFragments')"/></h2>

            <xsl:variable name="mainlang" select="/*[self::TEI.2 or self::TEI]/@lang"/>
            <xsl:for-each-group select="//*[@lang != $mainlang]" group-by="@lang">
                <xsl:sort select="@lang"/>
                <xsl:variable name="lang" select="@lang"/>
                <h3 class="main"><xsl:value-of select="f:message($lang)"/></h3>
                <xsl:call-template name="language-fragments">
                    <xsl:with-param name="lang" select="$lang"/>
                </xsl:call-template>

            </xsl:for-each-group>
        </div>
    </xsl:template>


    <xd:doc mode="language-fragments">
        <xd:short>Mode for special processing of certain elements when displayed in the overview of foreign-language fragments.</xd:short>
        <xd:detail>
            <p>Mode for special processing of certain elements when displayed in the overview of foreign-language fragments. Take
            care to treat elements that are normally processed in a special way, as normal in this overview.</p>
        </xd:detail>
    </xd:doc>


    <xd:doc>
        <xd:short>Generate an overview of foreign language fragments, for one language.</xd:short>
        <xd:detail>
            <p>Generate a table of foreign language fragments in the text for a given language.
            Group the fragments by content (that is, deduplicated), and give them in document order.</p>
        </xd:detail>
        <xd:param name="lang" type="string">The code of the language to handle.</xd:param>
    </xd:doc>

    <xsl:template name="language-fragments">
        <xsl:param name="lang" as="xs:string"/>

        <xsl:variable name="fragments" select="//*[@lang=$lang]"/>
        <xsl:variable name="id" select="f:generate-id(.) || $lang"/>

        <table class="languageFragmentTable" id="{$id}">
            <tr>
                <th><xsl:value-of select="f:message('msgPage')"/></th>
                <th><xsl:value-of select="f:message('msgElement')"/></th>
                <th><xsl:value-of select="f:message('msgFragment')"/></th>
            </tr>
            <xsl:for-each-group select="$fragments" group-by=".">
                <xsl:sort select="." lang="{f:baseLanguage($lang)}"/>
                <tr>
                    <td>
                        <xsl:for-each select="current-group()">
                            <xsl:if test="position() != 1">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <a class="pageref" href="{f:generate-safe-href(.)}">
                                <xsl:copy-of select="f:convert-markdown(f:find-page-number(.))"/>
                            </a>
                        </xsl:for-each>
                    </td>
                    <td>
                        <xsl:value-of select="name(.)"/>
                    </td>
                    <td>
                        <xsl:attribute name="lang" select="f:get-current-lang(.)"/>
                        <xsl:variable name="fragment">
                            <xsl:apply-templates select="." mode="language-fragments"/>
                        </xsl:variable>
                        <xsl:copy-of select="f:copy-without-ids($fragment)"/>
                    </td>
                </tr>
            </xsl:for-each-group>
        </table>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle elements as usual by default.</xd:short>
    </xd:doc>

    <xsl:template match="*" mode="language-fragments">
        <xsl:apply-templates select="."/>
    </xsl:template>


    <xd:doc>
        <xd:short>Prevent notes from being rendered as raised numerals in the language fragment overview.</xd:short>
    </xd:doc>

    <xsl:template match="note" mode="language-fragments">
        <xsl:apply-templates/>
    </xsl:template>


    <xd:doc>
        <xd:short>Prevent cells from being rendered as extra <code>tb</code> elements in the language fragment overview.</xd:short>
    </xd:doc>

    <xsl:template match="cell" mode="language-fragments">
        <xsl:apply-templates/>
    </xsl:template>


    <xd:doc>
        <xd:short>Prevent <code>q</code>-elements from being rendered with <code>&lt;p&gt;</code> appearing in the language fragment overview.</xd:short>
    </xd:doc>

    <xsl:template match="q" mode="language-fragments">
        <xsl:apply-templates/>
    </xsl:template>


    <!--====================================================================-->
    <!-- Tag Usage -->

    <xsl:key name="elements" match="*" use="name()"/>

    <xd:doc>
        <xd:short>Generate an overview of TEI tag usage.</xd:short>
        <xd:detail>
            <p>Generate a table of TEI tag and attribute usage. Order the tags and attributes by name.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="divGen[@type='TagUsage']">

        <xsl:variable name="tagUsage">
            <tmp:tags>
                <xsl:for-each-group select="//*" group-by="name()">
                    <xsl:sort select="lower-case(name())"/>
                    <xsl:variable name="tagName" select="name()"/>
                    <tmp:tag name="{$tagName}" count="{count(current-group())}">
                        <xsl:for-each-group select="//*[name() = $tagName]/@*" group-by="name()">
                            <xsl:sort select="lower-case(name())"/>
                            <xsl:variable name="attrName" select="name()"/>
                            <tmp:attr name="{$attrName}" count="{count(current-group())}">
                                <xsl:for-each-group select="//*[name() = $tagName]/@*[name() = $attrName]" group-by=".">
                                    <tmp:value value="{.}" count="{count(current-group())}"/>
                                </xsl:for-each-group>
                            </tmp:attr>
                        </xsl:for-each-group>
                    </tmp:tag>
                </xsl:for-each-group>
            </tmp:tags>
        </xsl:variable>

        <div class="transcriberNote tagUsage">
            <h2 class="main"><xsl:value-of select="f:message('msgTagUsageOverview')"/></h2>
            <table>
                <tr>
                    <th rowspan="2"><xsl:value-of select="f:message('msgElement')"/></th>
                    <th rowspan="2"><xsl:value-of select="f:message('msgOccurrences.abbr')"/></th>
                    <th colspan="3"><xsl:value-of select="f:message('msgAttributes')"/></th>
                </tr>
                <tr>
                    <th><xsl:value-of select="f:message('msgName')"/></th>
                    <th><xsl:value-of select="f:message('msgOccurrences.abbr')"/></th>
                    <th><xsl:value-of select="f:message('msgValues')"/></th>
                </tr>
                <xsl:for-each select="$tagUsage/tmp:tags/tmp:tag">
                    <tr>
                        <td><xsl:value-of select="@name"/></td>
                        <td><xsl:value-of select="@count"/></td>
                        <xsl:call-template name="tag-usage-attr-values">
                            <xsl:with-param name="node" select="tmp:attr[1]"/>
                        </xsl:call-template>
                    </tr>
                    <xsl:for-each select="tmp:attr[position() > 1]">
                        <tr>
                            <td/>
                            <td/>
                            <xsl:call-template name="tag-usage-attr-values">
                                <xsl:with-param name="node" select="."/>
                            </xsl:call-template>
                        </tr>
                    </xsl:for-each>
                </xsl:for-each>
            </table>
        </div>
    </xsl:template>


    <xsl:template name="tag-usage-attr-values">
        <xsl:param name="node"/>

        <td>
            <xsl:if test="$node/@name">
                <b>@<xsl:value-of select="$node/@name"/></b>
            </xsl:if>
        </td>
        <td><xsl:value-of select="$node/@count"/></td>
        <td>
            <xsl:for-each select="$node/tmp:value">
                <span class="tagUsageValue"><xsl:value-of select="@value"/></span>
                <xsl:if test="@count &gt; 1">
                    <xsl:text> </xsl:text><i><xsl:value-of select="@count"/></i>
                </xsl:if>
                <xsl:text> </xsl:text>
            </xsl:for-each>
        </td>
    </xsl:template>


    <!--====================================================================-->
    <!-- Personas, create a list of personas, based on the @who id. -->

    <xsl:template match="divGen[@type='Personas']">
        <xsl:if test="//sp[@who]">
          <div class="transcriberNote">
            <h3 class="main"><xsl:value-of select="f:message('msgDramatisPersonae')"/></h3>

            <table>
                <tr>
                    <th><xsl:value-of select="f:message('msgOccurrences')"/></th>
                    <th><xsl:value-of select="f:message('msgId')"/></th>
                    <th><xsl:value-of select="f:message('msgName')"/></th>
                </tr>
                <xsl:for-each-group select="//sp[speaker]" group-by="@who">
                    <xsl:sort select="@who"/>
                    <tr>
                        <td><xsl:value-of select="count(current-group())"/></td>
                        <td><xsl:value-of select="current-grouping-key()"/></td>
                        <td>
                            <xsl:for-each-group select="current-group()" group-by="f:normalize-persona(speaker)">
                                <xsl:value-of select="current-grouping-key()"/>
                                <xsl:if test="position() != last()">
                                     <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each-group>
                        </td>
                    </tr>
                </xsl:for-each-group>

                <xsl:for-each-group select="//sp[not(@who)]" group-by="f:normalize-persona(speaker)">
                    <tr>
                        <td><xsl:value-of select="count(current-group())"/></td>
                        <td><i><xsl:value-of select="f:message('msgUnidentifiedSpeaker')"/></i></td>
                        <td><xsl:value-of select="current-grouping-key()"/></td>
                    </tr>
                </xsl:for-each-group>
            </table>
          </div>
        </xsl:if>
    </xsl:template>

    <xsl:function name="f:normalize-persona">
        <xsl:param name="name"/>
        <xsl:value-of select="replace($name, '[.,:;]', '')"/>
    </xsl:function>


</xsl:stylesheet>
