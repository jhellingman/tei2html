<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="3.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xd tei">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to remove the TEI namespace from a TEI-document.</xd:short>
        <xd:detail>This stylesheet removes the TEI namespace from a TEI-document. This makes
        it possible to process TEI documents regardless of whether they are in the TEI
        namespace or not.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2016, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Remove the TEI namespace from the top-level TEI element.</xd:short>
        <xd:detail>When we detect we have a TEI document in the TEI namespace, we copy the entire document, while
        stripping the namespace, and process the result. This enables us to process both documents in the
        TEI namespace and in the default namespace with the same stylesheet.</xd:detail>
    </xd:doc>

    <xsl:template match="tei:TEI">
        <xsl:variable name="document">
            <xsl:apply-templates select="/" mode="stripns"/>
        </xsl:variable>
        <xsl:apply-templates select="$document"/>
    </xsl:template>


    <xsl:template match="*" mode="stripns">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@* | node()" mode="stripns"/>
        </xsl:element>
    </xsl:template>


    <xsl:template match="@*" mode="stripns">
        <xsl:attribute name="{local-name()}">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>


    <xsl:template match="comment() | text() | processing-instruction()" mode="stripns">
        <xsl:copy/>
    </xsl:template>


</xsl:stylesheet>
