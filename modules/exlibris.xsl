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
        <xd:short>Stylesheet to create an ex-libris</xd:short>
        <xd:detail>This stylesheet creates an ex-libris page in a document, based on information provided in an the file <code>exlibris.xml</code>.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2021, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc type="string">Name of ex-libris file.</xd:doc>
    <xsl:param name="ex-libris-file"/>

    <xd:doc type="string">Custom configuration (if available read from file else empty).</xd:doc>
    <xsl:variable name="ex-libris" select="if ($ex-libris-file)
                                           then document(f:normalizeFilename($ex-libris-file), /)
                                           else $empty-ex-libris"/>

    <xsl:variable name="empty-ex-libris">
        <exlibris/>
    </xsl:variable>

    <xsl:variable name="default-ex-libris">
        <exlibris>           
            <owner>
                <name>Jeroen Hellingman</name>
            <owner>
            <accession>
                <date>2021-10-24</date>
            </accession>
        </exlibris>
    </xsl:variable>


    <xsl:template match="divGen[@type='exlibris']">
        <div class="exlibris">
            <p>This book belongs to: <xsl:value-of select="$ex-libris/owner/name"/>.
        </div>
    </xsl:template>

</xsl:stylesheet>