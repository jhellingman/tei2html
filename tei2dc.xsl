<?xml version="1.0" encoding="ISO-8859-1"?>

    <!-- Generate RDF/Dublin Core metadata from a TEI file

         This is still a very basic implementation.
         For further ideas on refinements see: http://dublincore.org/documents/dcq-rdf-xml/.
    -->

    <xsl:stylesheet
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        xmlns:xd="http://www.pnp-software.com/XSLTdoc"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:f="urn:stylesheet-functions"
        exclude-result-prefixes="f xd xs"
        version="2.0">

    <xsl:output
        method="xml"
        indent="yes"
        encoding="UTF-8"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="TEI.2">
        <rdf:RDF>
            <rdf:Description>
                <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/title"/>
                <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/author"/>
                <xsl:apply-templates select="teiHeader/fileDesc/publicationStmt"/>
                <xsl:apply-templates select="teiHeader/fileDesc/publicationStmt/availability"/>
                <xsl:if test="text/@lang">
                    <dc:language><xsl:value-of select="text/@lang"/></dc:language>
                </xsl:if>
                <xsl:apply-templates select="teiHeader/profileDesc/textClass/keywords/list" mode="keywords"/>
                <xsl:apply-templates select="teiHeader/fileDesc/respStmt/name" mode="contributors"/>
                <xsl:apply-templates select="teiHeader/fileDesc/notesStmt/note[@type='Description']" mode="descriptions"/>
                <xsl:if test="f:isvalid(teiHeader/fileDesc/publicationStmt/idno[@type='PGnum'])">
                    <dc:identifier>pg:<xsl:value-of select="teiHeader/fileDesc/publicationStmt/idno[@type='PGnum']"/></dc:identifier>
                </xsl:if>
            </rdf:Description>
        </rdf:RDF>
    </xsl:template>

    <xsl:template match="title">
        <dc:title>
            <xsl:value-of select="."/>
        </dc:title>
    </xsl:template>

    <xsl:template match="author">
        <dc:creator>
            <xsl:value-of select="."/>
        </dc:creator>
    </xsl:template>

    <xsl:template match="publicationStmt">
        <dc:publisher>
            <xsl:value-of select="publisher"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="pubPlace"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="date"/>
        </dc:publisher>
        <dc:date><xsl:value-of select="date"/></dc:date>
    </xsl:template>

    <xsl:template match="availability">
        <dc:rights>
            <xsl:value-of select="."/>
        </dc:rights>
    </xsl:template>

    <xsl:template match="item" mode="keywords">
        <!-- Filter out empty subjects and our template default placeholder -->
        <xsl:if test="f:isvalid(.)">
            <dc:subject>
                <xsl:value-of select="."/>
            </dc:subject>
        </xsl:if>
    </xsl:template>

    <xsl:template match="name" mode="contributors">
        <!-- Filter out empty contributors and our template default placeholder -->
        <xsl:if test="f:isvalid(.)">
            <dc:contributor>
                <xsl:value-of select="."/>
            </dc:contributor>
        </xsl:if>
    </xsl:template>

    <xsl:template match="note" mode="descriptions">
        <!-- Filter out empty descriptions and our template default placeholder -->
        <xsl:if test="f:isvalid(.)">
            <dc:description>
                <xsl:value-of select="."/>
            </dc:description>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*"/>


    <xd:doc>
        <xd:short>Determine a string has a valid value.</xd:short>
        <xd:detail>
            <p>Determine a string has a valid value, that is, not null, empty or '#####' (copied from utils.xml)</p>
        </xd:detail>
        <xd:param name="value" type="string">The value to be tested.</xd:param>
    </xd:doc>
    <xsl:function name="f:isvalid" as="xs:boolean">
        <xsl:param name="value"/>
        <xsl:sequence select="$value and not($value = '' or $value = '#####')"/>
    </xsl:function>

</xsl:stylesheet>