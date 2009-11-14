<?xml version="1.0" encoding="ISO-8859-1"?>

    <xsl:stylesheet
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
        <dc:dc>
            <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/title"/>
            <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/author"/>
            <xsl:apply-templates select="teiHeader/fileDesc/publicationStmt"/>
            <xsl:apply-templates select="teiHeader/fileDesc/publicationStmt/availability"/>
            <xsl:if test="text/@lang">
                <dc:language><xsl:value-of select="text/@lang"/></dc:language>
            </xsl:if>
        </dc:dc>
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
    </xsl:template>

    <xsl:template match="availability">
        <dc:rights>
            <xsl:value-of select="."/>
        </dc:rights>
    </xsl:template>

    <xsl:template match="*"/>

</xsl:stylesheet>
