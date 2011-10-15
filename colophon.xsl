<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to create a Colophon from a TEI file, to be imported in tei2html.xsl.

    Usage: <divGen type="Colophon"/>

    Requires: 
        localization.xsl    : templates for localizing strings.
        messages.xsl        : stores localized messages in variables.
        utils.xsl           : various utility templates.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    >


    <!-- Colophon -->

    <xsl:template match="divGen[@type='Colophon']">
        <div class="transcribernote">
            <xsl:call-template name="set-lang-id-attributes"/>

            <h2 class="main"><xsl:value-of select="$strColophon"/></h2>

            <h3 class="main"><xsl:value-of select="$strAvailability"/></h3>
            <xsl:apply-templates select="/TEI.2/teiHeader/fileDesc/publicationStmt/availability"/>

            <xsl:if test="//idno[@type='PGnum'] and not(contains(//idno[@type='PGnum'], '#'))">
                <p><xsl:value-of select="$strPgCatalogEntry"/>:
                    <a class="pglink">
                        <xsl:attribute name="href">http://www.gutenberg.org/ebooks/<xsl:value-of select="//idno[@type='PGnum']"/></xsl:attribute>
                        <xsl:value-of select="//idno[@type='PGnum']"/>
                    </a>.
                </p>
            </xsl:if>

            <xsl:if test="//idno[@type='LCCN']">
                <p><xsl:value-of select="$strLibraryOfCongressCatalogEntry"/>:
                    <a class="catlink">
                        <xsl:attribute name="href">http://lccn.loc.gov/<xsl:value-of select="//idno[@type='LCCN']"/></xsl:attribute>
                        <xsl:value-of select="//idno[@type='LCCN']"/>
                    </a>.
                </p>
            </xsl:if>

            <xsl:if test="//idno[@type='OLN']">
                <p><xsl:value-of select="$strOpenLibraryCatalogEntry"/>:
                    <a class="catlink">
                        <xsl:attribute name="href">http://openlibrary.org/books/<xsl:value-of select="//idno[@type='OLN']"/></xsl:attribute>
                        <xsl:value-of select="//idno[@type='OLN']"/>
                    </a>.
                </p>
            </xsl:if>

            <xsl:if test="//idno[@type='OLW']">
                <p><xsl:value-of select="$strOpenLibraryCatalogWorkEntry"/>:
                    <a class="catlink">
                        <xsl:attribute name="href">http://openlibrary.org/works/<xsl:value-of select="//idno[@type='OLW']"/></xsl:attribute>
                        <xsl:value-of select="//idno[@type='OLW']"/>
                    </a>.
                </p>
            </xsl:if>

            <xsl:if test="//idno[@type='OCLC']">
                <p><xsl:value-of select="$strOclcCatalogEntry"/>:
                    <a class="catlink">
                        <xsl:attribute name="href">http://www.worldcat.org/oclc/<xsl:value-of select="//idno[@type='OCLC']"/></xsl:attribute>
                        <xsl:value-of select="//idno[@type='OCLC']"/>
                    </a>.
                </p>
            </xsl:if>

            <xsl:if test="/TEI.2/teiHeader/encodingDesc">
                <h3 class="main"><xsl:value-of select="$strEncoding"/></h3>
                <xsl:apply-templates select="/TEI.2/teiHeader/encodingDesc"/>
            </xsl:if>

            <h3 class="main"><xsl:value-of select="$strRevisionHistory"/></h3>
            <xsl:apply-templates select="/TEI.2/teiHeader/revisionDesc"/>

            <xsl:if test="//xref">
                <xsl:call-template name="externalReferences"/>
            </xsl:if>

            <xsl:if test="//corr">
                <h3 class="main"><xsl:value-of select="$strCorrections"/></h3>
                <xsl:call-template name="correctionTable"/>
            </xsl:if>

        </div>
    </xsl:template>


    <!-- List of Corrections -->

    <xsl:template match="divGen[@type='corr']">
        <xsl:if test="//corr">
            <h2 class="main"><xsl:value-of select="$strCorrections"/></h2>
            <xsl:call-template name="correctionTable"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="correctionTable">
        <p><xsl:value-of select="$strCorrectionsAppliedToText"/></p>

        <table class="correctiontable">
            <xsl:attribute name="summary"><xsl:value-of select="$strCorrectionsOverview"/></xsl:attribute>
            <tr>
                <th><xsl:value-of select="$strPage"/></th>
                <th><xsl:value-of select="$strSource"/></th>
                <th><xsl:value-of select="$strCorrection"/></th>
            </tr>

            <xsl:for-each-group select="//corr" group-by="concat(@sic, concat('@@@', .))">
                <tr>
                    <td class="width20">
                        <xsl:for-each select="current-group()">
                            <xsl:if test="position() != 1">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <a class="pageref">
                                <xsl:call-template name="generate-href-attribute"/>
                                <xsl:choose>
                                    <xsl:when test="not(preceding::pb[1]/@n) or preceding::pb[1]/@n = ''">
                                        <xsl:value-of select="$strNotApplicable"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="preceding::pb[1]/@n"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </a>
                        </xsl:for-each>
                    </td>

                    <td class="width40 bottom">
                        <xsl:choose>
                            <xsl:when test="@sic != ''">
                                <xsl:value-of select="@sic"/>
                            </xsl:when>
                            <xsl:otherwise>
                                [<i><xsl:value-of select="$strNotInSource"/></i>]
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>

                    <td class="width40 bottom">
                        <xsl:choose>
                            <xsl:when test=". != ''">
                                <xsl:apply-templates/>
                            </xsl:when>
                            <xsl:otherwise>
                                [<i><xsl:value-of select="$strDeleted"/></i>]
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>
                </tr>
            </xsl:for-each-group>

        </table>
    </xsl:template>


    <!-- External References -->

    <xsl:template name="externalReferences">
        <xsl:if test="//xref">
            <h3 class="main"><xsl:value-of select="$strExternalReferences"/></h3>

            <p><xsl:value-of select="$strExternalReferencesDisclaimer"/></p>
        </xsl:if>
    </xsl:template>


</xsl:stylesheet>
