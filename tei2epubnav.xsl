<?xml version="1.0" encoding="ISO-8859-1"?>

    <xsl:stylesheet
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:epub="http://www.idpf.org/2011/epub"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        version="2.0">

    <xsl:template match="TEI.2" mode="ePubNav">
        <xsl:result-document
                href="{$path}/{$basename}-nav.xhtml"
                method="xml"
                indent="yes"
                encoding="UTF-8">
            <xsl:message terminate="no">Info: generated file: <xsl:value-of select="$path"/>/<xsl:value-of select="$basename"/>-nav.xhtml.</xsl:message>

            <html>
                <xsl:attribute name="xml:lang">
                    <xsl:value-of select="@lang"/>
                </xsl:attribute>
                <head>
                    <title><xsl:value-of select="$strTableOfContents"/></title>
                </head>
                <body>
                    <xsl:apply-templates select="text/body" mode="ePubNav"/>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>


    <xsl:template match="body" mode="ePubNav">
        <nav epub:type="toc" id="toc">
            <h1><xsl:value-of select="$strTableOfContents"/></h1>
            <xsl:call-template name="toc-body"/>
        </nav>
    </xsl:template>


    <xsl:template match="*" mode="ePubNav"/>






    <xsl:template match="TEI.2" mode="navPageList">


    </xsl:template>


    <xsl:template match="TEI.2" mode="navLandMarks">


    </xsl:template>






</xsl:stylesheet>
