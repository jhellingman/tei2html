<?xml version="1.0" encoding="iso-8859-1" ?>
<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:msg="http://www.gutenberg.ph/2006/schemas/messages"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f msg xd xhtml">

    <xd:doc type="stylesheet">
        <xd:short>TEI stylesheet to convert a TEI document to ePub.</xd:short>
        <xd:detail>This stylesheet is the main entry point for the TEI to ePub conversion. It contains no
        templates itself, but collects all stylesheets, and sets a number of global variables.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2012, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:include href="modules/functions.xsl"/>
    <xsl:include href="modules/utils.xsl"/>
    <xsl:include href="modules/utils.epub.xsl"/>
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
    <xsl:include href="modules/splitter.xsl"/>
    <xsl:include href="modules/tables.xsl"/>
    <xsl:include href="modules/lists.xsl"/>
    <xsl:include href="modules/formulas.xsl"/>
    <xsl:include href="modules/figures.xsl"/>
    <xsl:include href="modules/colophon.xsl"/>
    <xsl:include href="modules/gutenberg.xsl"/>
    <xsl:include href="modules/facsimile.xsl"/>
    <xsl:include href="modules/stripns.xsl"/>

    <xsl:include href="modules/tei2opf.xsl"/>
    <xsl:include href="modules/tei2ncx.xsl"/>
    <xsl:include href="modules/tei2epubnav.xsl"/>

    <xsl:output name="xhtml"
        doctype-public="-//W3C//DTD XHTML 1.1//EN"
        doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
        method="xml"
        encoding="utf-8"/>

    <xsl:output name="xml"
        doctype-public=""
        doctype-system=""
        method="xml"
        indent="yes"
        encoding="utf-8"/>

    <xsl:output name="xml-noindent"
        doctype-public=""
        doctype-system=""
        method="xml"
        indent="no"
        encoding="utf-8"/>

    <xsl:output
        method="xml"
        doctype-system="about:legacy-compat"
        encoding="utf-8"
        indent="no"/>

    <!--====================================================================-->

    <xsl:param name="basename" select="'book'"/>
    <xsl:param name="path" select="'ePub'"/>
    <xsl:param name="epubversion" select="'3.0.1'"/>        <!-- Values: '3.1' or '3.0.1' -->

    <xsl:param name="optionPrinceMarkup" select="'No'"/>    <!-- Should always be 'No' for ePub -->

    <!--====================================================================-->

    <xsl:variable name="root" select="/"/>

    <xsl:variable name="mimeType" select="'application/xhtml+xml'"/>
    <xsl:variable name="encoding" select="document('')/xsl:stylesheet/xsl:output[not(@name)]/@encoding"/>
    <xsl:variable name="outputMethod" select="document('')/xsl:stylesheet/xsl:output/@method"/>
    <xsl:variable name="outputFormat" select="'epub'"/>

    <xsl:variable name="title" select="/*[self::TEI.2 or self::TEI]/teiHeader/fileDesc/titleStmt/title[not(@type) or @type='main']" />
    <xsl:variable name="author" select="/*[self::TEI.2 or self::TEI]/teiHeader/fileDesc/titleStmt/author" />
    <xsl:variable name="publisher" select="/*[self::TEI.2 or self::TEI]/teiHeader/fileDesc/publicationStmt/publisher" />
    <xsl:variable name="pubdate" select="/*[self::TEI.2 or self::TEI]/teiHeader/fileDesc/publicationStmt/date" />

    <xsl:variable name="p.element" select="'p'"/>

    <!--====================================================================-->


    <xd:doc>
        <xd:short>Main stylesheet for ePub generation.</xd:short>
        <xd:detail>
            <p>This XSLT-stylesheet is intended to be the first triggered, and will initiate
            generation of various ePub elements.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="/">
        <xsl:call-template name="mimetype"/>
        <xsl:call-template name="container"/>
        <xsl:call-template name="external-css-stylesheets"/>
        <xsl:call-template name="copy-smil-files"/>

        <xsl:apply-templates mode="opf"/>
        <xsl:apply-templates mode="ncx"/>
        <xsl:apply-templates mode="ePubNav"/>
        <xsl:apply-templates/>
    </xsl:template>


    <!--====================================================================-->
    <!-- Mimetype file -->

    <xd:doc>
        <xd:short>Generate the file with the ePub mimetype: application/epub+zip.</xd:short>
    </xd:doc>

    <xsl:template name="mimetype">
        <xsl:result-document
                href="{$path}/mimetype"
                method="text"
                encoding="UTF-8">
            <xsl:copy-of select="f:log-info('Generated file: {1}/mimetype.', ($path))"/>
            <xsl:text>application/epub+zip</xsl:text>
        </xsl:result-document>
    </xsl:template>


    <!--====================================================================-->
    <!-- Container file -->

    <xd:doc>
        <xd:short>Generate the container file which points to the OPF file, as required by ePub.</xd:short>
    </xd:doc>

    <xsl:template name="container">
        <xsl:result-document format="xml" href="{$path}/META-INF/container.xml">
            <xsl:copy-of select="f:log-info('Generated container file: {1}/META-INF/container.xml.', ($path))"/>
            <container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
               <rootfiles>
                  <rootfile full-path="{$basename}.opf" media-type="application/oebps-package+xml"/>
               </rootfiles>
            </container>
        </xsl:result-document>
    </xsl:template>


    <!--====================================================================-->
    <!-- SMIL files -->

    <xd:doc>
        <xd:short>Collect all SMIL-files with media-overlays, and copy them into the output.</xd:short>
    </xd:doc>

    <xsl:template name="copy-smil-files">
        <xsl:for-each select="//*[f:has-rend-value(@rend, 'media-overlay')]">
            <xsl:call-template name="copy-xml-file">
                <xsl:with-param name="filename" select="f:rend-value(@rend, 'media-overlay')"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>


    <!--====================================================================-->
    <!-- Cover -->

    <xsl:template name="cover">
        <xsl:result-document
                href="{$path}/cover.xhtml"
                method="xml"
                encoding="UTF-8">
            <xsl:copy-of select="f:log-info('Generated cover file: {1}/cover.xhtml.', ($path))"/>
        </xsl:result-document>
    </xsl:template>

</xsl:stylesheet>
