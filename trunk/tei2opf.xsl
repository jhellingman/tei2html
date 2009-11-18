<?xml version="1.0" encoding="ISO-8859-1"?>

    <xsl:stylesheet
        xmlns="http://www.idpf.org/2007/opf"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        xmlns:opf="http://www.idpf.org/2007/opf"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        version="2.0">

    <xsl:output 
        method="xml" 
        indent="yes"
        encoding="UTF-8"/>


    <xsl:param name="basename" select="'book'"/>

    
    <xsl:include href="utils.xsl"/>


    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template match="TEI.2">
        <package version="2.0">
            <xsl:attribute name="unique-identifier">idbook</xsl:attribute>

            <metadata>
                <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/title" mode="metadata"/>
                <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/author" mode="metadata"/>
                <xsl:apply-templates select="teiHeader/fileDesc/publicationStmt" mode="metadata"/>
                <xsl:apply-templates select="teiHeader/fileDesc/publicationStmt/availability" mode="metadata"/>
                <xsl:if test="@lang">
                    <dc:language xsi:type="dcterms:RFC4646"><xsl:value-of select="@lang"/></dc:language>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="teiHeader/fileDesc/publicationStmt/idno[@type ='ISBN']"><dc:identifier id="idbook" opf:scheme="ISBN"><xsl:value-of select="teiHeader/fileDesc/publicationStmt/idno[@type = 'ISBN']"/></dc:identifier></xsl:when>
                    <xsl:when test="teiHeader/fileDesc/publicationStmt/idno[@type ='PGnum']"><dc:identifier id="idbook" opf:scheme="URI">http://www.gutenberg.org/ebooks/<xsl:value-of select="teiHeader/fileDesc/publicationStmt/idno[@type = 'PGnum']"/></dc:identifier></xsl:when>
                </xsl:choose>
                <dc:date opf:event="publication"><xsl:value-of select="teiHeader/fileDesc/publicationStmt/date"/></dc:date>
            </metadata>

            <manifest>
                
                <item id="ncx"
                     href="book.ncx"
                     media-type="application/x-dtbncx+xml"/>

                <!-- Content Parts -->

                <xsl:apply-templates select="//div1" mode="manifest"/>

                <!-- CSS Style Sheets -->

                <!-- Illustrations -->

                <xsl:apply-templates select="//figure" mode="manifest"/>

            </manifest>

            <spine toc="ncx">
                <xsl:apply-templates select="//div1" mode="spine"/>
            </spine>

            <guide>
                <reference />
            </guide>

        </package>
    </xsl:template>


    <!--== metadata ========================================================-->

    <xsl:template match="title" mode="metadata">
        <dc:title>
            <xsl:value-of select="."/>
        </dc:title>
    </xsl:template>

    <xsl:template match="author" mode="metadata">
        <dc:creator opf:role="aut">
            <xsl:value-of select="."/>
        </dc:creator>
    </xsl:template>

    <xsl:template match="publicationStmt" mode="metadata">
        <dc:publisher>
            <xsl:value-of select="publisher"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="pubPlace"/>
        </dc:publisher>
    </xsl:template>

    <xsl:template match="availability" mode="metadata">
        <dc:rights>
            <xsl:value-of select="."/>
        </dc:rights>
    </xsl:template>


    <!--== manifest ========================================================-->

    <!--== main divisions ==-->

    <xsl:template match="div1[not(ancestor::div1)]" mode="manifest">
        <item>
            <xsl:variable name="id">
                <xsl:choose>
                    <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
                    <xsl:otherwise>x<xsl:value-of select="generate-id(.)"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
            <xsl:attribute name="href"><xsl:value-of select="$basename"/>-<xsl:value-of select="$id"/>.xhtml</xsl:attribute>
            <xsl:attribute name="mediatype">application/xhtml+xml</xsl:attribute>
        </item>
    </xsl:template>


    <!-- nested div1 elements (for example in quoted texts, etc.) should be ignored -->
    <xsl:template match="div1[ancestor::div1]" mode="manifest"/>


    <!--== figures ==-->

    <xsl:template match="figure" mode="manifest">
        <item>
            <xsl:attribute name="id"><xsl:call-template name="generate-id"/></xsl:attribute>
            <xsl:attribute name="href"><xsl:call-template name="getimagefilename"/></xsl:attribute>
            <xsl:attribute name="mediatype"><xsl:call-template name="getimagefiletype"/></xsl:attribute>
        </item>
    </xsl:template>

    <xsl:template name="getimagefilename">
        <xsl:choose>
            <xsl:when test="contains(@rend, 'image(')">
                <xsl:value-of select="substring-before(substring-after(@rend, 'image('), ')')"/>
            </xsl:when>
            <xsl:otherwise>images/<xsl:value-of select="@id"/>.jpg</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getimagefiletype">
        <xsl:variable name="filename"><xsl:call-template name="getimagefilename"/></xsl:variable>
        <xsl:choose>
            <xsl:when test="contains($filename, '.jpg') or contains($filename, '.jpeg')">image/jpeg</xsl:when>
            <xsl:when test="contains($filename, '.png')">image/png</xsl:when>
            <xsl:when test="contains($filename, '.gif')">image/gif</xsl:when>
            <xsl:when test="contains($filename, '.svg')">image/svg</xsl:when>
        </xsl:choose>
    </xsl:template>


    <!--== spine ===========================================================-->

    <xsl:template match="div1" mode="spine">
        <itemref linear="yes">
            <xsl:attribute name="idref"><xsl:call-template name="generate-id"/></xsl:attribute>
        </itemref>
    </xsl:template>


    <!--== forget about all the rest =======================================-->

    <xsl:template match="*"/>

</xsl:stylesheet>
