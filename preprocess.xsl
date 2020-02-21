<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f xd xhtml xs">

    <xsl:output indent="no" omit-xml-declaration="yes"/>

    <!-- stub function used by log.xsl -->
    <xsl:function name="f:is-set" as="xs:boolean">
        <xsl:param name="value" as="xs:string"/>
        <xsl:sequence select="true()"/>
    </xsl:function>

    <xsl:include href="log.xsl"/>
    <xsl:include href="rend.xsl"/>
    <xsl:include href="stripns.xsl"/>
    <xsl:include href="normalize-table.xsl"/>


    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to preprocess TEI documents.</xd:short>
        <xd:detail><p>This stylesheet preprocesses TEI documents, so the final conversion to HTML 
            can be handled more easily.</p>

            <p>The following aspects are handled:</p>

            <ul>
                <li>1. Strip the TEI namespace if present (see stripns.xsl).</li>
                <li>2. Normalize tables (see normalize-table.xsl).</li>
                <li>3. Remove superflous attributes.</li>
            </ul>
        </xd:detail>
    </xd:doc>


    <xsl:template match="@TEIform" mode="#all"/>


    <xsl:template match="table">
        <xsl:apply-templates select="." mode="normalize-table"/>
    </xsl:template>


</xsl:stylesheet>
