<?xml version="1.0" encoding="ISO-8859-1"?>

    <xsl:stylesheet
        xmlns="http://www.daisy.org/z3986/2005/ncx/"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        version="2.0">

    <xsl:output 
        doctype-public="-//NISO//DTD ncx 2005-1//EN"
        doctype-system="http://www.daisy.org/z3986/2005/ncx-2005-1.dtd"
        method="xml" 
        indent="yes"
        encoding="UTF-8"/>


    <xsl:param name="basename" select="'book'"/>


    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template match="TEI.2">
        <ncx version="2005-1">
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="@lang"/>
            </xsl:attribute>

            <head>
                <meta name="dbt:uid">
                    <xsl:attribute name="content">
                        <xsl:choose>
                            <xsl:when test="teiHeader/fileDesc/publicationStmt/idno[@type ='ISBN']"><xsl:value-of select="teiHeader/fileDesc/publicationStmt/idno[@type = 'ISBN']"/></xsl:when>
                            <xsl:when test="teiHeader/fileDesc/publicationStmt/idno[@type ='PGnum']">http://www.gutenberg.org/ebooks/<xsl:value-of select="teiHeader/fileDesc/publicationStmt/idno[@type = 'PGnum']"/></xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                </meta>

                <meta name="dtb:depth">
                    <xsl:attribute name="content">
                        <xsl:choose>
                            <xsl:when test="//div2">2</xsl:when>
                            <xsl:otherwise>1</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </meta>

                <meta name="dtb:totalPageCount" content="0"/>
                <meta name="dtb:maxPageNumber" content="0"/> 
                <meta name="dtb:generator" content="tei2ncx.xsl, see http://code.google.com/p/tei2html/"/>

            </head>

            <docTitle>
                <text><xsl:value-of select="teiHeader/fileDesc/titleStmt/title"/></text>
            </docTitle>

            <docAuthor>
                <text><xsl:value-of select="teiHeader/fileDesc/titleStmt/author"/></text>
            </docAuthor>

            <navMap>
                <xsl:apply-templates select="//div1" mode="navMap"/>
            </navMap>

        </ncx>
    </xsl:template>


    <!--== navMap ==========================================================-->

    <xsl:template match="div1" mode="navMap">
        <xsl:if test="head">
            <navPoint class="chapter">
                <xsl:attribute name="id"><xsl:call-template name="generate-id"/></xsl:attribute>
                <xsl:attribute name="playOrder"><xsl:number level="any" count="div1|div2"/></xsl:attribute>
                <navLabel>
                    <text>
                        <xsl:apply-templates select="head" mode="navLabel"/>
                    </text>
                </navLabel>
                <content>
                    <xsl:attribute name="src"><xsl:call-template name="generate-id"/>.xhtml</xsl:attribute>
                </content>
                <xsl:if test="div2">
                    <navMap>
                        <xsl:apply-templates select="div2" mode="navMap"/>
                    </navMap>
                </xsl:if>
            </navPoint>
        </xsl:if>
    </xsl:template>


    <xsl:template match="div2" mode="navMap">
        <xsl:if test="head">
            <navPoint class="chapter">
                <xsl:attribute name="id"><xsl:call-template name="generate-id"/></xsl:attribute>
                <xsl:attribute name="playOrder"><xsl:number level="any" count="div1|div2"/></xsl:attribute>
                <navLabel>
                    <text>
                        <xsl:apply-templates select="head" mode="navLabel"/>
                    </text>
                </navLabel>
                <content>
                    <xsl:attribute name="src"><xsl:call-template name="generate-id-for"><xsl:with-param name="node" select=".."/></xsl:call-template>.xhtml#<xsl:call-template name="generate-id"/></xsl:attribute>
                </content>
            </navPoint>
        </xsl:if>
    </xsl:template>


    <xsl:template match="head[@type='label']" mode="navLabel"/>

    <xsl:template match="head" mode="navLabel">
        <xsl:apply-templates mode="navLabel"/>
    </xsl:template>

    <xsl:template match="note" mode="navLabel"/>


    <!--== utils ===========================================================-->

    <xsl:template name="generate-id">
        <xsl:choose>
            <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
            <xsl:otherwise>x<xsl:value-of select="generate-id(.)"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="generate-id-for">
        <xsl:param name="node"/>
        <xsl:choose>
            <xsl:when test="$node/@id"><xsl:value-of select="$node/@id"/></xsl:when>
            <xsl:otherwise>x<xsl:value-of select="generate-id($node)"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--== forget about all the rest =======================================-->

    <xsl:template match="*"/>

</xsl:stylesheet>
