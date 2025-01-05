<!DOCTYPE xsl:stylesheet [
    <!ENTITY ndash      "&#x2013;">
]>

<xsl:stylesheet version="3.0"
                xmlns="http://www.gutenberg.ph/2006/schemas/imageinfo"
                xmlns:f="urn:stylesheet-functions"
                xmlns:img="http://www.gutenberg.ph/2006/schemas/imageinfo"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="f img xd xs">

    <xd:doc type="stylesheet">
        <xd:short>Enrich image info with details of each image</xd:short>
        <xd:detail>Enrich image info with details of each image.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2024, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:output
        method="xml"
        indent="yes"
        encoding="UTF-8"/>

    <xsl:include href="modules/functions.xsl"/>
    <xsl:include href="modules/utils.xsl"/>
    <xsl:include href="modules/utils.html.xsl"/>
    <xsl:include href="modules/betacode.xsl"/>
    <xsl:include href="modules/configuration.xsl"/>
    <xsl:include href="modules/log.xsl"/>
    <xsl:include href="modules/localization.xsl"/>
    <xsl:include href="modules/header.xsl"/>
    <xsl:include href="modules/inline.xsl"/>
    <xsl:include href="modules/rend.xsl"/>
    <xsl:include href="modules/css.xsl"/>
    <xsl:include href="modules/references.xsl"/>
    <xsl:include href="modules/titlepage.xsl"/>
    <xsl:include href="modules/block.xsl"/>
    <xsl:include href="modules/notes.xsl"/>
    <xsl:include href="modules/numbers.xsl"/>
    <xsl:include href="modules/drama.xsl"/>
    <xsl:include href="modules/contents.xsl"/>
    <xsl:include href="modules/index.xsl"/>
    <xsl:include href="modules/divisions.xsl"/>
    <xsl:include href="modules/tables.xsl"/>
    <xsl:include href="modules/lists.xsl"/>
    <xsl:include href="modules/formulas.xsl"/>
    <xsl:include href="modules/figures.xsl"/>
    <xsl:include href="modules/colophon.xsl"/>
    <xsl:include href="modules/gutenberg.xsl"/>
    <xsl:include href="modules/facsimile.xsl"/>
    <xsl:include href="modules/stripns.xsl"/>
    <xsl:include href="modules/variables.xsl"/>


    <xd:doc type="string">Name used as prefix for generated file names.</xd:doc>
    <xsl:param name="basename" select="'book'"/>

    <xd:doc type="string">Path in which generated files will be placed.</xd:doc>
    <xsl:param name="path" select="'.'"/>

    <xd:doc type="string">Generate special markup used by PrinceXML to generate PDF files (Yes or No).</xd:doc>
    <xsl:param name="optionPrinceMarkup" select="'No'"/>


    <xsl:variable name="mimeType" select="'text/html'"/>   <!-- 'text/html' or 'application/xhtml+xml'. -->
    <xsl:variable name="encoding" select="document('')/xsl:stylesheet/xsl:output/@encoding"/>
    <xsl:variable name="outputMethod" select="document('')/xsl:stylesheet/xsl:output/@method"/>
    <xsl:variable name="outputFormat" select="'html5'"/>
    <xsl:variable name="p.element" select="'p'"/>


    <xsl:template match="/">
        <images>
            <xsl:apply-templates mode="imageinfo"/>
        </images>
    </xsl:template>

  
    <xsl:template match="figure" mode="imageinfo">

        <xsl:variable name="file" select="f:determine-image-filename(., '.jpg')"/>

        <image 
            id="{@id}" 
            path="{$file}"
            alt="{f:determine-image-alt-text(., '')}"
            filesize="{f:image-file-size($file)}"
            filedate="{f:image-file-date($file)}"
            width="{f:image-width($file)}"
            height="{f:image-height($file)}"
            />

    </xsl:template>


    <xsl:template match="*" mode="imageinfo">
        <xsl:apply-templates mode="imageinfo"/>
    </xsl:template>

    <xsl:template match="*" mode="imageinfo">
        <xsl:apply-templates mode="imageinfo"/>
    </xsl:template>


    <xsl:template match="text()" mode="imageinfo"/>

</xsl:stylesheet>