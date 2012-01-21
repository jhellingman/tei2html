<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to create a Colophon from a TEI file, to be imported in tei2html.xsl.

    Usage: <divGen type="Colophon"/>

    Requires: 
        localization.xsl    : templates for localizing strings.
        utils.xsl           : various utility templates.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="f xs xd"
    version="2.0"
    >

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to generate a colophon.</xd:short>
        <xd:detail>This stylesheet will generate a colophon from the <code>teiHeader</code>, and various other types of information in the TEI file.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2012, Jeroen Hellingman</xd:copyright>
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


    <xsl:template name="colophon-body">

        <h3 class="main"><xsl:value-of select="f:message('msgAvailability')"/></h3>
        <xsl:apply-templates select="/TEI.2/teiHeader/fileDesc/publicationStmt/availability"/>

        <xsl:if test="//idno[@type='PGnum'] and not(contains(//idno[@type='PGnum'], '#'))">
            <p><xsl:value-of select="f:message('msgPgCatalogEntry')"/>:
                <a class="pglink">
                    <xsl:attribute name="href">http://www.gutenberg.org/ebooks/<xsl:value-of select="//idno[@type='PGnum']"/></xsl:attribute>
                    <xsl:value-of select="//idno[@type='PGnum']"/>
                </a>.
            </p>
        </xsl:if>

        <xsl:if test="f:isvalid(//idno[@type='LCCN'])">
            <p><xsl:value-of select="f:message('msgLibraryOfCongressCatalogEntry')"/>:
                <a class="catlink">
                    <xsl:attribute name="href">http://lccn.loc.gov/<xsl:value-of select="//idno[@type='LCCN']"/></xsl:attribute>
                    <xsl:value-of select="//idno[@type='LCCN']"/>
                </a>.
            </p>
        </xsl:if>

        <xsl:if test="f:isvalid(//idno[@type='OLN'])">
            <p><xsl:value-of select="f:message('msgOpenLibraryCatalogEntry')"/>:
                <a class="catlink">
                    <xsl:attribute name="href">http://openlibrary.org/books/<xsl:value-of select="//idno[@type='OLN']"/></xsl:attribute>
                    <xsl:value-of select="//idno[@type='OLN']"/>
                </a>.
            </p>
        </xsl:if>

        <xsl:if test="f:isvalid(//idno[@type='OLW'])">
            <p><xsl:value-of select="f:message('msgOpenLibraryCatalogWorkEntry')"/>:
                <a class="catlink">
                    <xsl:attribute name="href">http://openlibrary.org/works/<xsl:value-of select="//idno[@type='OLW']"/></xsl:attribute>
                    <xsl:value-of select="//idno[@type='OLW']"/>
                </a>.
            </p>
        </xsl:if>

        <xsl:if test="f:isvalid(//idno[@type='OCLC'])">
            <p><xsl:value-of select="f:message('msgOclcCatalogEntry')"/>:
                <a class="catlink">
                    <xsl:attribute name="href">http://www.worldcat.org/oclc/<xsl:value-of select="//idno[@type='OCLC']"/></xsl:attribute>
                    <xsl:value-of select="//idno[@type='OCLC']"/>
                </a>.
            </p>
        </xsl:if>

        <xsl:if test="/TEI.2/teiHeader/encodingDesc">
            <h3 class="main"><xsl:value-of select="f:message('msgEncoding')"/></h3>
            <xsl:apply-templates select="/TEI.2/teiHeader/encodingDesc"/>
        </xsl:if>

        <h3 class="main"><xsl:value-of select="f:message('msgRevisionHistory')"/></h3>
        <xsl:apply-templates select="/TEI.2/teiHeader/revisionDesc"/>

        <xsl:if test="//xref[@url]">
            <xsl:call-template name="external-references"/>
        </xsl:if>

        <xsl:if test="//corr">
            <h3 class="main"><xsl:value-of select="f:message('msgCorrections')"/></h3>
            <xsl:call-template name="correctionTable"/>
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

    <xsl:template name="correctionTable">
        <p><xsl:value-of select="f:message('msgCorrectionsAppliedToText')"/></p>

        <table class="correctiontable">
            <xsl:attribute name="summary"><xsl:value-of select="f:message('msgCorrectionsOverview')"/></xsl:attribute>
            <tr>
                <th><xsl:value-of select="f:message('msgPage')"/></th>
                <th><xsl:value-of select="f:message('msgSource')"/></th>
                <th><xsl:value-of select="f:message('msgCorrection')"/></th>
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
                                        <xsl:value-of select="f:message('msgNotApplicable')"/>
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
                                [<i><xsl:value-of select="f:message('msgNotInSource')"/></i>]
                            </xsl:otherwise>
                        </xsl:choose>
                    </td>

                    <td class="width40 bottom">
                        <xsl:choose>
                            <xsl:when test=". != ''">
                                <xsl:apply-templates/>
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


    <!--====================================================================-->
    <!-- External References -->

    <xd:doc>
        <xd:short>Generate a table of external references.</xd:short>
        <xd:detail>
            <p>Generate a table of external references in the text, as indicated by <code>xref</code>-elements. Identical
            external references are grouped together. The page numbers link back to the <code>xref</code>-element as it 
            appears in the text.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="external-references">
        <xsl:if test="//xref">
            <h3 class="main"><xsl:value-of select="f:message('msgExternalReferences')"/></h3>

            <p><xsl:value-of select="f:message('msgExternalReferencesDisclaimer')"/></p>

            <xsl:if test="$optionExternalLinksTable = 'Yes'">
                <xsl:call-template name="external-reference-table"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template name="external-reference-table">
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

                                    <xsl:choose>
                                        <xsl:when test="not(preceding::pb[1]/@n) or preceding::pb[1]/@n = ''">
                                            <xsl:value-of select="f:message('msgNotApplicable')"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="preceding::pb[1]/@n"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </a>
                            </xsl:for-each>
                        </td>
                        <td>
                            <xsl:variable name="url" select="f:translate-xref-url(@url, substring(/TEI.2/@lang, 1, 2))"/>
                            <xsl:choose>
                                <xsl:when test="$optionExternalLinks != 'No'">
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

</xsl:stylesheet>
