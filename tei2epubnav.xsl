<?xml version="1.0" encoding="ISO-8859-1"?>

    <xsl:stylesheet
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:epub="http://www.idpf.org/2007/ops"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:f="urn:stylesheet-functions"
        xmlns:xd="http://www.pnp-software.com/XSLTdoc"
        exclude-result-prefixes="f xd"
        version="2.0">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to create an ePub3 navigation document.</xd:short>
        <xd:detail>This stylesheet creates an ePub3 navigation document, following the ePub3 standard. It currently relies on the
        normal toc-creating templates, with some tweaks to remove details not allowable in an ePub3 navigation document.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2014, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Create the ePub3 navigation document.</xd:short>
        <xd:detail>Create a separate ePub3 navigation document.</xd:detail>
    </xd:doc>

    <xsl:template match="TEI.2" mode="ePubNav">
        <xsl:result-document
                href="{$path}/{$basename}-nav.xhtml"
                method="xml"
                indent="yes"
                encoding="UTF-8">
            <xsl:message terminate="no">INFO:    generated file: <xsl:value-of select="$path"/>/<xsl:value-of select="$basename"/>-nav.xhtml.</xsl:message>

            <html>
                <xsl:attribute name="xml:lang">
                    <xsl:value-of select="@lang"/>
                </xsl:attribute>
                <head>
                    <title><xsl:value-of select="f:message('msgTableOfContents')"/></title>
                    <!-- <meta http-equiv="content-type" content="text/html; charset=utf-8"/> -->
                    <meta charset="utf-8"/>
                </head>
                <body>
                    <xsl:apply-templates select="text" mode="ePubNav"/>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>



    <xd:doc>
        <xd:short>Create the ePub3 navigation document toc-body.</xd:short>
        <xd:detail>Create the toc for the navigation document. Currently uses the standard toc-building templates.</xd:detail>
    </xd:doc>

    <!-- http://www.idpf.org/epub/301/spec/epub-contentdocs.html#sec-xhtml-nav-def -->

    <xsl:template match="text" mode="ePubNav">
        <nav epub:type="toc" id="toc">
            <h1><xsl:value-of select="f:message('msgTableOfContents')"/></h1>
            <xsl:call-template name="toc-body">
                <xsl:with-param name="list-element" select="'ol'"/>
                <xsl:with-param name="show-page-numbers" tunnel="yes" select="false()"/>
                <xsl:with-param name="show-div-numbers" tunnel="yes" select="false()"/>
            </xsl:call-template>
        </nav>
    </xsl:template>


    <xsl:template match="*" mode="ePubNav"/>

    <xd:doc>
        <xd:short>Create the ePub3 navigation document pagelist-body.</xd:short>
        <xd:detail>To be implemented....</xd:detail>
    </xd:doc>

    <xsl:template match="text" mode="navPageList"/>


    <xd:doc>
        <xd:short>Create the ePub3 navigation document landmark-body.</xd:short>
        <xd:detail>To be implemented....</xd:detail>
    </xd:doc>

    <xsl:template match="text" mode="navLandMarks">
        <nav epub:type="landmarks" id="guide">
            <h2><xsl:value-of select="f:message('msgGuide')"/></h2>
        </nav>
    </xsl:template>


</xsl:stylesheet>
