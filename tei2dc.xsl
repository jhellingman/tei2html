<?xml version="1.0" encoding="ISO-8859-1"?>

    <!-- Generate RDF/Dublin Core metadata from a TEI file

         This is still a very basic implementation.
         For further ideas on refinements see: http://dublincore.org/documents/dcq-rdf-xml/.
    -->

    <xsl:stylesheet
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        version="1.0">

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
        <xsl:if test="not(. = '' or . = '#####')">
            <dc:subject>
                <xsl:value-of select="."/>
            </dc:subject>
        </xsl:if>
    </xsl:template>

    <xsl:template match="name" mode="contributors">
        <!-- Filter out empty contributors and our template default placeholder -->
        <xsl:if test="not(. = '' or . = '#####')">
            <dc:contributor>
                <xsl:value-of select="."/>
            </dc:contributor>
        </xsl:if>
    </xsl:template>

    <xsl:template match="note" mode="descriptions">
        <!-- Filter out empty descriptions and our template default placeholder -->
        <xsl:if test="not(. = '' or . = '#####')">
            <dc:description>
                <xsl:value-of select="."/>
            </dc:description>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*"/>

</xsl:stylesheet>