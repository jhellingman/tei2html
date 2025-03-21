<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns:f="urn:stylesheet-functions"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="f h xd">

    <xsl:output indent="no" method="xml" encoding="utf-8"/>

    <xsl:include href="modules/stripns.xsl"/>
    <xsl:include href="modules/normalize-table.xsl"/>


    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to preprocess TEI documents.</xd:short>
        <xd:detail><h:p>This stylesheet preprocesses TEI documents, so the final conversion to HTML
            can be handled more easily.</h:p>

            <h:p>The following aspects are handled:</h:p>

            <h:ul>
                <h:li>1. Strip the TEI namespace if present (see stripns.xsl).</h:li>
                <h:li>2. Normalize tables (see normalize-table.xsl).</h:li>
                <h:li>3. Remove superfluous attributes.</h:li>
            </h:ul>
        </xd:detail>
    </xd:doc>


    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="@TEIform" mode="#all"/>


    <xsl:template match="table">
        <xsl:apply-templates select="." mode="normalize-table"/>
    </xsl:template>


    <xsl:function name="f:is-margin-note" as="xs:boolean">
        <xsl:param name="note" as="element(note)"/>
        <xsl:sequence select="$note/@place = 'margin' or $note/@type = 'margin'"/>
    </xsl:function>

    <!-- Consecutive marginal notes should be combined into a single marginal note. -->
    <xsl:template match="note[f:is-margin-note(.)]">
        <xsl:if test="not(preceding-sibling::node()[not(self::text()[normalize-space()=''])][1]/self::note[f:is-margin-note(.)])">
            <xsl:variable name="siblings" select="(., following-sibling::node())"/>
            <xsl:variable name="notes">
                <xsl:iterate select="$siblings">
                    <xsl:choose>
                        <xsl:when test="self::note[f:is-margin-note(.)]">
                            <xsl:copy-of select="."/>
                        </xsl:when>
                        <xsl:when test="self::text() and normalize-space(.) = ''">
                            <!-- Skip whitespace -->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:break/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:iterate>
            </xsl:variable>

            <!-- Combine the notes, copy the attributes of the first in the sequence. -->
            <note>
                <xsl:for-each select="@*">
                    <xsl:attribute name="{name(.)}" select="."/>
                </xsl:for-each>
                <xsl:for-each select="$notes/note">
                    <xsl:if test="position() > 1">
                        <lb>
                            <xsl:if test="@id">
                                <xsl:attribute name="id" select="@id"/>
                            </xsl:if>
                            <xsl:message>INFO: merged consecutive marginal notes.</xsl:message>
                        </lb>
                    </xsl:if>
                    <xsl:apply-templates/>
                </xsl:for-each>
            </note>
        </xsl:if>
    </xsl:template>

    <!-- Suppress individual notes that are merged -->
    <xsl:template match="note[f:is-margin-note(.)][preceding-sibling::node()[not(self::text()[normalize-space()=''])][1]/self::note[f:is-margin-note(.)]]" priority="1"/>

    <!-- Two consecutive "phantom"-elements can be merged -->

    <xsl:template match="ab[@type='phantom']" mode="#all">
        <xsl:variable name="following" select="following-sibling::node()[1]"/>
        <xsl:variable name="preceding" select="preceding-sibling::node()[1]"/>

        <xsl:choose>
            <xsl:when test="$following/self::ab[@type='phantom']">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()" mode="#current"/>
                    <xsl:apply-templates select="$following/node()" mode="#current"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="$preceding/self::ab[@type='phantom']"/>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()" mode="#current"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
