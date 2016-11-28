<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="urn:stylesheet-functions"
    xmlns:tmp="urn:temporary"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="f tmp xs xd html"
    version="2.0"
    >

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to generate a colophon.</xd:short>
        <xd:detail>This stylesheet will generate a colophon from the <code>teiHeader</code>, and various other types of information in the TEI file.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2016, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <!--====================================================================-->
    <!-- Colophon -->

    <xd:doc>
        <xd:short>Generate a colophon.</xd:short>
        <xd:detail>
            <p>Generate a colophon for a TEI file, based on information in the <code>teiHeader</code>.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="divGen[@type='Colophon']">
        <div class="transcribernote">
            <xsl:call-template name="set-lang-id-attributes"/>

            <h2 class="main"><xsl:value-of select="f:message('msgColophon')"/></h2>

            <xsl:call-template name="colophon-body"/>
        </div>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate the colophon body.</xd:short>
        <xd:detail>
            <p>Generate the body of a colophon for a TEI file, based on information in the <code>teiHeader</code>.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="divGen[@type='ColophonBody']">
        <xsl:call-template name="colophon-body"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate the contents of the colophon body.</xd:short>
        <xd:detail>
            <p>Generate the contents of the body of a colophon for a TEI file, based on information in the <code>teiHeader</code>.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="colophon-body">
        <xsl:variable name="context" select="." as="element(divGen)"/>
        <h3 class="main"><xsl:value-of select="f:message('msgAvailability')"/></h3>
        <xsl:apply-templates select="/*[self::TEI.2 or self::TEI]/teiHeader/fileDesc/publicationStmt/availability"/>

        <xsl:call-template name="contributors"/>

        <xsl:call-template name="keywords"/>

        <xsl:call-template name="classification"/>

        <xsl:call-template name="catalog-entries"/>

        <xsl:if test="/*[self::TEI.2 or self::TEI]/teiHeader/encodingDesc">
            <h3 class="main"><xsl:value-of select="f:message('msgEncoding')"/></h3>
            <xsl:apply-templates select="/*[self::TEI.2 or self::TEI]/teiHeader/encodingDesc"/>
        </xsl:if>

        <h3 class="main"><xsl:value-of select="f:message('msgRevisionHistory')"/></h3>
        <xsl:apply-templates select="/*[self::TEI.2 or self::TEI]/teiHeader/revisionDesc"/>

        <xsl:call-template name="external-references"/>

        <xsl:if test="//corr">
            <h3 class="main"><xsl:value-of select="f:message('msgCorrections')"/></h3>
            <xsl:call-template name="correctionTable"/>
        </xsl:if>
    </xsl:template>


    <xsl:template name="contributors">
        <table>
            <tr>
                <th><xsl:value-of select="f:message('msgName')"/></th>
                <th/>
                <th><xsl:value-of select="f:message('msgRole')"/></th>
            </tr>

            <!-- Authors -->
            <xsl:for-each select="//titleStmt/author">
                <xsl:sort select="@key"/>
                <xsl:copy-of select="f:contributorLine(., @ref, f:message('msgAuthor'))"/>
            </xsl:for-each>

            <!-- Editors -->
            <xsl:for-each select="//titleStmt/editor">
                <xsl:sort select="@key"/>
                <xsl:copy-of select="f:contributorLine(., @ref, f:message('msgEditor'))"/>
            </xsl:for-each>

            <!-- Other contributors -->
            <xsl:for-each select="//titleStmt/respStmt[resp != 'Transcription']">
                <xsl:sort select="name/@key"/>
                <xsl:copy-of select="f:contributorLine(name, name/@ref, f:translateResp(resp))"/>
            </xsl:for-each>
        </table>
    </xsl:template>

    <xsl:function name="f:contributorLine">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="ref" as="xs:string?"/>
        <xsl:param name="role" as="xs:string"/>

        <tr>
            <td>
                <xsl:value-of select="$name"/>
            </td>
            <td>
                <xsl:if test="f:isValid($ref)">
                    <a href="{$ref}"><xsl:value-of select="'VIAF'"/></a>
                </xsl:if>
            </td>
            <td><xsl:value-of select="$role"/></td>
        </tr>
    </xsl:function>


    <xsl:function name="f:translateResp" as="xs:string">
        <xsl:param name="resp" as="xs:string"/>

        <xsl:variable name="roles">
            <roles>
                <role message="msgAdaptor">Adapter</role>
                <role message="msgContributor">Contributor</role>
                <role message="msgTranscriber">Transcription</role>
                <role message="msgTranslator">Translation</role>
                <role message="msgTranslator">Translator</role>
                <role message="msgIllustrator">Illustrator</role>
            </roles>
        </xsl:variable>

        <xsl:variable name="role" select="$roles//*[.=$resp]/@message"/>
        <xsl:copy-of select="f:logDebug('Translating: {1} to {2}', ($resp, $role))"/>
        <xsl:value-of select="if ($role) then f:message($role) else f:message('msgUnknown')"/>
    </xsl:function>



    <xd:doc>
        <xd:short>Generate a list of classifications.</xd:short>
        <xd:detail>
            <p>Generate a list of classifications, based on information in the <code>profileDesc/textClass/classCode</code>. 
            Note that for proper rendering, a <code>taxonomy</code> element corresponding to the indicated scheme must be present,
            and contain a human-readable text.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="classification">
        <xsl:if test="//profileDesc/textClass/classCode">
            <xsl:for-each select="//profileDesc/textClass/classCode">
                <xsl:if test="not(contains(., '#'))">
                    <xsl:variable name="scheme" select="./@scheme"/>
                    <p><xsl:value-of select="//taxonomy[@id=$scheme]/bibl"/>: <xsl:value-of select="."/>.</p>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>


    <xsl:template name="keywords">
        <xsl:if test="//profileDesc/textClass/keywords/list/item[not(contains(., '#'))]">
            <p><xsl:value-of select="f:message('msgKeywords')"/>: 
            <xsl:for-each select="//profileDesc/textClass/keywords/list/item[not(contains(., '#'))]">
                <xsl:value-of select="."/>
                <xsl:value-of select="if (position() &lt; last()) then ', ' else '.'"/>
            </xsl:for-each>
            </p>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:short>Generate links to catalog entries.</xd:short>
        <xd:detail>
            <p>Depending on the presence of various types of <code>idno</code> elements, corresponding links to the relevant sites will be created. Currently
            understood are IDs pointing to Project Gutenberg, the Library of Congress, WorldCat, Open Library and LibraryThing.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="catalog-entries">
        <xsl:if test="//idno[@type='PGnum'] and not(contains(//idno[@type='PGnum'], '#'))">
            <p><xsl:value-of select="f:message('msgPgCatalogEntry')"/>:
                <a class="pglink">
                    <xsl:attribute name="href">https://www.gutenberg.org/ebooks/<xsl:value-of select="//idno[@type='PGnum']"/></xsl:attribute>
                    <xsl:value-of select="//idno[@type='PGnum']"/>
                </a>.
            </p>
        </xsl:if>

        <xsl:if test="f:isValid(//idno[@type='LCCN'])">
            <p><xsl:value-of select="f:message('msgLibraryOfCongressCatalogEntry')"/>:
                <a class="catlink">
                    <xsl:attribute name="href">https://lccn.loc.gov/<xsl:value-of select="//idno[@type='LCCN']"/></xsl:attribute>
                    <xsl:value-of select="//idno[@type='LCCN']"/>
                </a>.
            </p>
        </xsl:if>

        <xsl:if test="f:isValid(//idno[@type='VIAF'])">
            <p><xsl:value-of select="f:message('msgVirtualInternationalAuthorityFile')"/>:
                <a class="catlink">
                    <xsl:attribute name="href">http://viaf.org/viaf/<xsl:value-of select="//idno[@type='VIAF']"/></xsl:attribute>
                    <xsl:value-of select="//idno[@type='VIAF']"/>
                </a>.
            </p>
        </xsl:if>

        <xsl:if test="f:isValid(//idno[@type='OLN'])">
            <p><xsl:value-of select="f:message('msgOpenLibraryCatalogEntry')"/>:
                <a class="catlink">
                    <xsl:attribute name="href">https://openlibrary.org/books/<xsl:value-of select="//idno[@type='OLN']"/></xsl:attribute>
                    <xsl:value-of select="//idno[@type='OLN']"/>
                </a>.
            </p>
        </xsl:if>

        <xsl:if test="f:isValid(//idno[@type='OLW'])">
            <p><xsl:value-of select="f:message('msgOpenLibraryCatalogWorkEntry')"/>:
                <a class="catlink">
                    <xsl:attribute name="href">https://openlibrary.org/works/<xsl:value-of select="//idno[@type='OLW']"/></xsl:attribute>
                    <xsl:value-of select="//idno[@type='OLW']"/>
                </a>.
            </p>
        </xsl:if>

        <xsl:if test="f:isValid(//idno[@type='OCLC'])">
            <p><xsl:value-of select="f:message('msgOclcCatalogEntry')"/>:
                <a class="catlink">
                    <xsl:attribute name="href">https://www.worldcat.org/oclc/<xsl:value-of select="//idno[@type='OCLC']"/></xsl:attribute>
                    <xsl:value-of select="//idno[@type='OCLC']"/>
                </a>.
            </p>
        </xsl:if>

        <xsl:if test="f:isValid(//idno[@type='LibThing'])">
            <p><xsl:value-of select="f:message('msgLibraryThingEntry')"/>:
                <a class="catlink">
                    <xsl:attribute name="href">https://www.librarything.com/work/<xsl:value-of select="//idno[@type='LibThing']"/></xsl:attribute>
                    <xsl:value-of select="//idno[@type='LibThing']"/>
                </a>.
            </p>
        </xsl:if>

        <xsl:if test="f:isValid(//idno[@type='PGSrc'])">
            <p><xsl:value-of select="f:message('msgGitHubRepository')"/>:
                <a class="catlink">
                    <xsl:attribute name="href">https://github.com/GutenbergSource/<xsl:value-of select="//idno[@type='PGSrc']"/></xsl:attribute>
                    <xsl:value-of select="//idno[@type='PGSrc']"/>
                </a>.
            </p>
        </xsl:if>

    </xsl:template>


    <!--====================================================================-->
    <!-- List of Corrections -->

    <xd:doc>
        <xd:short>Generate a list of corrections.</xd:short>
        <xd:detail>
            <p>Generate a list of corrections made to the text, as indicated by <code>corr</code>-elements. Identical
            corrections are grouped together. The page numbers link back to the <code>corr</code>-element as it 
            appears in the text.</p>
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
            in newer TEI versions), the two ways are collected and normalized into <code>tmp:choice</code> elements
            in the variable <code>$corrections</code>. These are then grouped and rendered.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="correctionTable">
        <p><xsl:value-of select="f:message('msgCorrectionsAppliedToText')"/></p>

        <table class="correctiontable">
            <xsl:if test="$outputformat != 'epub'">
                <xsl:attribute name="summary"><xsl:value-of select="f:message('msgCorrectionsOverview')"/></xsl:attribute>
            </xsl:if>
            <tr>
                <th><xsl:value-of select="f:message('msgPage')"/></th>
                <th><xsl:value-of select="f:message('msgSource')"/></th>
                <th><xsl:value-of select="f:message('msgCorrection')"/></th>
            </tr>

            <xsl:variable name="corrections">
                <xsl:apply-templates select="//corr[not(parent::choice)] | //choice[corr]" mode="collectCorrections"/>
            </xsl:variable>

            <xsl:for-each-group select="$corrections/tmp:choice" group-by="concat(tmp:sic, '@@@', tmp:corr)">
                <tr>
                    <td class="width20">
                        <xsl:for-each select="current-group()">
                            <xsl:if test="position() != 1">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <a class="pageref" href="{@href}"><xsl:value-of select="@page"/></a>
                        </xsl:for-each>
                    </td>

                    <td class="width40 bottom">
                        <xsl:choose>
                            <xsl:when test="tmp:sic != ''">
                                <xsl:apply-templates select="tmp:sic"/>
                            </xsl:when>
                            <xsl:otherwise>
                                [<i><xsl:value-of select="f:message('msgNotInSource')"/></i>]
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>

                    <td class="width40 bottom">
                        <xsl:choose>
                            <xsl:when test="tmp:corr != ''">
                                <xsl:apply-templates select="tmp:corr"/>
                            </xsl:when>
                            <xsl:otherwise>
                                [<i><xsl:value-of select="f:message('msgDeleted')"/></i>]
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                </tr>
            </xsl:for-each-group>

        </table>
    </xsl:template>


    <xd:doc>
        <xd:short>Convert a traditional corr element to a temporary choice element.</xd:short>
    </xd:doc>

    <xsl:template match="corr" mode="collectCorrections">
        <tmp:choice>
            <xsl:attribute name="page" select="f:find-pagenumber(.)"/>
            <xsl:call-template name="corr-href-attribute"/>
            <tmp:corr>
                <xsl:copy-of select="* | text()"/>
            </tmp:corr>
            <tmp:sic>
                <xsl:value-of select="@sic"/>
            </tmp:sic>
        </tmp:choice>
    </xsl:template>


    <xd:doc>
        <xd:short>Convert a correction in a choice element to a temporary choice element.</xd:short>
    </xd:doc>

    <xsl:template match="choice" mode="collectCorrections">
        <tmp:choice>
            <xsl:attribute name="page" select="f:find-pagenumber(.)"/>
            <xsl:call-template name="corr-href-attribute"/>
            <tmp:corr>
                <xsl:copy-of select="corr/* | corr/text()"/>
            </tmp:corr>
            <tmp:sic>
                <xsl:copy-of select="sic/* | sic/text()"/>
            </tmp:sic>
         </tmp:choice>
    </xsl:template>


    <xd:doc>
        <xd:short>Determine the link back to the correction.</xd:short>
    </xd:doc>

    <xsl:template name="corr-href-attribute">
        <xsl:choose>
            <xsl:when test="f:insideFootnote(.)">
                <xsl:call-template name="generate-footnote-href-attribute"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="generate-href-attribute"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!--====================================================================-->
    <!-- External References -->

    <xd:doc>
        <xd:short>Generate a table of external references.</xd:short>
        <xd:detail>
            <p>Generate a table of external references in the text, as indicated by <code>xref</code>-elements or
            <code>ref</code>-elements. Identical
            external references are grouped together. The page numbers link back to location the external
            reference appears in the text.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="external-references">
        <xsl:if test="//xref[@url] | /TEI//ref[not(starts-with(@target, '#'))]">
            <h3 class="main"><xsl:value-of select="f:message('msgExternalReferences')"/></h3>

            <p><xsl:value-of select="f:message('msgExternalReferencesDisclaimer')"/></p>

            <xsl:if test="f:isSet('outputExternalLinksTable')">
                <xsl:call-template name="external-reference-table"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:short>Generate the contents of the external references.</xd:short>
        <xd:detail>
            <p>Generate the contents of the table of external references as an HTML table.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="external-reference-table">

        <!-- TODO: make this table also work for P5 href elements -->
        <xsl:if test="//xref[@url]">

            <table class="externalReferenceTable">
                <tr>
                    <th><xsl:value-of select="f:message('msgPage')"/></th>
                    <th><xsl:value-of select="f:message('msgUrl')"/></th>
                </tr>
                <xsl:for-each-group select="//xref[@url]" group-by="@url">
                    <xsl:sort select="@url"/>
                    <tr>
                        <td>
                            <xsl:for-each select="current-group()">
                                <xsl:if test="position() != 1">
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                                <a class="pageref">
                                    <xsl:call-template name="generate-href-attribute"/>
                                    <xsl:attribute name="id">
                                        <xsl:call-template name="generate-id"/><xsl:text>ext</xsl:text>
                                    </xsl:attribute>
                                    <xsl:value-of select="f:find-pagenumber(.)"/>
                                </a>
                            </xsl:for-each>
                        </td>
                        <td>
                            <xsl:variable name="url" select="f:translate-xref-url(@url, substring(/*[self::TEI.2 or self::TEI]/@lang, 1, 2))"/>
                            <xsl:choose>
                                <xsl:when test="f:getSetting('outputExternalLinks') != 'never'">
                                    <a href="{$url}" class="{f:translate-xref-class(@url)}"><xsl:value-of select="$url"/></a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$url"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </xsl:for-each-group>
            </table>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Find the page-number for a node.</xd:short>
        <xd:detail>
            <p>Find the page-number for a node. This will try to locate the preceding <code>pb</code>-element, and return its
            <code>@n</code>-attribute value. This should normally correspond with the page the node appeared on in the source.</p>
        </xd:detail>
        <xd:param name="node" type="node()">The node for which the page-number is to be found.</xd:param>
    </xd:doc>

    <xsl:function name="f:find-pagenumber" as="xs:string">
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
            The fragments are grouped by language, and presented in document order.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="divGen[@type='LanguageFragments']">
        <div class="transcribernote">
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

    <xd:doc mode="languageFragments">
        <xd:short>Mode for special processing of certain elements when displayed in the overview of foreign-language fragments.</xd:short>
        <xd:detail>
            <p>Mode for special processing of certain elements when displayed in the overview of foreign-language fragments. This takes
            care that elements which are normally processed in a special way are treated as normal in this overview.</p>
        </xd:detail>
    </xd:doc>

    <xd:doc>
        <xd:short>Generate an overview of foreign language fragments, for one language.</xd:short>
        <xd:detail>
            <p>Generate a table of foreign language fragments in the text for a given language.
            The fragments are grouped by content (that is, undoubled), and presented in document order.</p>
        </xd:detail>
        <xd:param name="lang" type="string">The code of the language to handle.</xd:param>
    </xd:doc>

    <xsl:template name="language-fragments">
        <xsl:param name="lang" as="xs:string"/>

        <xsl:variable name="fragments" select="//*[@lang=$lang]"/>

        <table class="languageFragmentTable">
            <tr>
                <th><xsl:value-of select="f:message('msgPage')"/></th>
                <th><xsl:value-of select="f:message('msgElement')"/></th>
                <th><xsl:value-of select="f:message('msgFragment')"/></th>
            </tr>
            <xsl:for-each-group select="$fragments" group-by=".">
                <tr>
                    <td>
                        <xsl:for-each select="current-group()">
                            <xsl:if test="position() != 1">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <a class="pageref">
                                <xsl:choose>
                                    <xsl:when test="f:insideFootnote(.)">
                                        <xsl:choose>
                                            <xsl:when test="f:insideChoice(.)">
                                                <!-- Typical scenario: non-Latin text with automatically added transliteration in footnote. -->
                                                <xsl:call-template name="generate-footnote-href-attribute">
                                                    <xsl:with-param name="target" select="./ancestor::choice"/>
                                                </xsl:call-template>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:call-template name="generate-footnote-href-attribute"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:when test="f:insideChoice(.)">
                                        <!-- Typical scenario: non-Latin text with automatically added transliteration. -->
                                        <xsl:call-template name="generate-href-attribute">
                                            <xsl:with-param name="target" select="./ancestor::choice"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="generate-href-attribute"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:value-of select="f:find-pagenumber(.)"/>
                            </a>
                        </xsl:for-each>
                    </td>
                    <td>
                        <xsl:value-of select="name(.)"/>
                    </td>
                    <td>
                        <xsl:apply-templates select="." mode="languageFragments"/>
                    </td>
                </tr>
            </xsl:for-each-group>
        </table>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle elements as usual by default.</xd:short>
    </xd:doc>

    <xsl:template match="*" mode="languageFragments">
        <xsl:apply-templates select="."/>
    </xsl:template>


    <xd:doc>
        <xd:short>Prevent notes from being rendered as raised numerals in the language fragment overview.</xd:short>
    </xd:doc>

    <xsl:template match="note" mode="languageFragments">
        <xsl:apply-templates/>
    </xsl:template>


    <xd:doc>
        <xd:short>Prevent cells from being rendered as extra <code>tb</code> elements in the language fragment overview.</xd:short>
    </xd:doc>

    <xsl:template match="cell" mode="languageFragments">
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>
