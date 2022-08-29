<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xd">

    <xsl:output indent="no" method="xml" encoding="utf-8"/>

    <xsl:include href="modules/stripns.xsl"/>
    <xsl:include href="modules/normalize-table.xsl"/>


    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to preprocess TEI documents.</xd:short>
        <xd:detail><p>This stylesheet preprocesses TEI documents, so the final conversion to HTML
            can be handled more easily.</p>

            <p>The following aspects are handled:</p>

            <ul>
                <li>1. Strip the TEI namespace if present (see stripns.xsl).</li>
                <li>2. Normalize tables (see normalize-table.xsl).</li>
                <li>3. Remove superfluous attributes.</li>
            </ul>
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
