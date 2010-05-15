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
    version="1.0"
    >


    <!-- Colophon -->

    <xsl:template match="divGen[@type='Colophon']">
        <div class="transcribernote">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>

            <h2 class="main"><xsl:value-of select="$strColophon"/></h2>

            <h3 class="main"><xsl:value-of select="$strAvailability"/></h3>
            <xsl:apply-templates select="/TEI.2/teiHeader/fileDesc/publicationStmt/availability"/>

            <xsl:if test="//idno[@type='PGnum'] and not(contains(//idno[@type='PGnum'], '#'))">
                <p><xsl:value-of select="$strPgCatalogEntry"/>:
                    <a class="pglink">
                        <xsl:attribute name="href">http://www.gutenberg.org/etext/<xsl:value-of select="//idno[@type='PGnum']"/></xsl:attribute>
                        <xsl:value-of select="//idno[@type='PGnum']"/>
                    </a>.
                </p>
            </xsl:if>

            <xsl:if test="//idno[@type='OLN']">
                <p><xsl:value-of select="$strOpenLibraryCatalogEntry"/>:
                    <a class="catlink">
                        <xsl:attribute name="href">http://openlibrary.org/b/<xsl:value-of select="//idno[@type='OLN']"/></xsl:attribute>
                        <xsl:value-of select="//idno[@type='OLN']"/>
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

            <h3 class="main"><xsl:value-of select="$strEncoding"/></h3>
            <xsl:apply-templates select="/TEI.2/teiHeader/encodingDesc"/>

            <h3 class="main"><xsl:value-of select="$strRevisionHistory"/></h3>
            <xsl:apply-templates select="/TEI.2/teiHeader/revisionDesc"/>

            <xsl:call-template name="externalReferences"/>

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

        <table width="75%">
            <xsl:attribute name="summary"><xsl:value-of select="$strCorrectionsOverview"/></xsl:attribute>
            <tr>
                <th><xsl:value-of select="$strPage"/></th>
                <th><xsl:value-of select="$strSource"/></th>
                <th><xsl:value-of select="$strCorrection"/></th>
            </tr>
            <xsl:for-each select="//corr">
                <xsl:if test="not(@resp) or not(@resp = 'm' or @resp = 'p')">
                    <tr>
                        <td class="width20">
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
                        </td>
                        <td class="width40">
                            <xsl:choose>
                                <xsl:when test="@sic != ''">
                                    <xsl:value-of select="@sic"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    [<i><xsl:value-of select="$strNotInSource"/></i>]
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td class="width40">
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
                </xsl:if>
            </xsl:for-each>
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
