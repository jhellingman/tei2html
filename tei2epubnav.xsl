<?xml version="1.0" encoding="ISO-8859-1"?>

    <xsl:stylesheet
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:epub="http://www.idpf.org/2011/epub"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:f="urn:stylesheet-functions"
        exclude-result-prefixes="f"
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
                    <title><xsl:value-of select="f:message('msgTableOfContents')"/></title>
                    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
                </head>
                <body>
                    <xsl:apply-templates select="text/body" mode="ePubNav"/>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>


    <xsl:template match="body" mode="ePubNav">
        <section>
            <header>
                <h1><xsl:value-of select="f:message('msgTableOfContents')"/></h1>
            </header>
            <nav epub:type="toc" id="toc">
                <xsl:call-template name="toc-body"/>
            </nav>
        </section>
    </xsl:template>


    <xsl:template match="*" mode="ePubNav"/>






    <xsl:template match="TEI.2" mode="navPageList">


    </xsl:template>


    <xsl:template match="TEI.2" mode="navLandMarks">
        <nav epub:type="landmarks" id="guide">
            <h2><xsl:value-of select="f:message('msgGuide')"/></h2>

        </nav>
    </xsl:template>






</xsl:stylesheet>
