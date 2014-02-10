<?xml version="1.0" encoding="iso-8859-1" ?>
<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to convert TEI to ePub

    Developed by Jeroen Hellingman <jeroen@bohol.ph>, to be used together with a
    CSS stylesheet. Please contact me if you have problems with this stylesheet,
    or have improvements or bug fixes to contribute.

    This file is made available under the GNU General Public License, version 3.0 or later.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:f="urn:stylesheet-functions"
    exclude-result-prefixes="f xd"
    version="2.0"
    >

    <xd:doc type="stylesheet">
        <xd:short>TEI stylesheet to convert a TEI document to ePub.</xd:short>
        <xd:detail>This stylesheet is the main entry point for the TEI to ePub conversion. It contains no
        templates itself, but collects all stylesheets, and sets a number of global variables.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2012, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:include href="utils.xsl"/>
    <xsl:include href="utils.epub.xsl"/>
    <xsl:include href="configuration.xsl"/>
    <xsl:include href="localization.xsl"/>
    <xsl:include href="header.xsl"/>
    <xsl:include href="inline.xsl"/>
    <xsl:include href="css.xsl"/>
    <xsl:include href="references.xsl"/>
    <xsl:include href="titlepage.xsl"/>
    <xsl:include href="block.xsl"/>
    <xsl:include href="notes.xsl"/>
    <xsl:include href="drama.xsl"/>
    <xsl:include href="contents.xsl"/>
    <xsl:include href="divisions.xsl"/>
    <xsl:include href="splitter.xsl"/>
    <xsl:include href="tables.xsl"/>
    <xsl:include href="lists.xsl"/>
    <xsl:include href="figures.xsl"/>
    <xsl:include href="colophon.xsl"/>
    <xsl:include href="gutenberg.xsl"/>
    <xsl:include href="facsimile.xsl"/>

    <xsl:include href="tei2opf.xsl"/>
    <xsl:include href="tei2ncx.xsl"/>
    <xsl:include href="tei2epubnav.xsl"/>

    <xsl:output
        doctype-public="-//W3C//DTD XHTML 1.1//EN"
        doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
        method="xml"
        encoding="utf-8"/>

    <!--====================================================================-->

    <xsl:param name="basename" select="'book'"/>
    <xsl:param name="path" select="'ePub'"/>

    <xsl:param name="optionPrinceMarkup" select="'No'"/>
    <xsl:param name="optionEPubMarkup" select="'Yes'"/>
    <xsl:param name="optionEPub3" select="'Yes'"/>
    <xsl:param name="optionEPubStrict" select="'Yes'"/>
    <xsl:param name="optionPGHeaders" select="'No'"/>
    <xsl:param name="optionParagraphNumbers" select="'No'"/>

    <xd:doc type="string">Include images in the HTML output.</xd:doc>
    <xsl:param name="optionIncludeImages" select="'Yes'"/>

    <xd:doc type="string">Render external links as such in HTML.</xd:doc>
    <xsl:param name="optionExternalLinks" select="'Yes'"/>

    <xd:doc type="string">Place external links in a separate table in the Colophon.</xd:doc>
    <xsl:param name="optionExternalLinksTable" select="'Yes'"/>

    <xd:doc type="string">Generate a digital facsimile from page images (Yes or No).</xd:doc>
    <xsl:param name="optionGenerateFacsimile" select="'No'"/>

    <!--====================================================================-->

    <xsl:variable name="mimeType" select="'application/xhtml+xml'"/>
    <xsl:variable name="encoding" select="document('')/xsl:stylesheet/xsl:output/@encoding"/>
    <xsl:variable name="outputmethod" select="document('')/xsl:stylesheet/xsl:output/@method"/>
    <xsl:variable name="outputformat" select="'epub'"/>

    <xsl:variable name="title" select="/TEI.2/teiHeader/fileDesc/titleStmt/title" />
    <xsl:variable name="author" select="/TEI.2/teiHeader/fileDesc/titleStmt/author" />
    <xsl:variable name="publisher" select="/TEI.2/teiHeader/fileDesc/publicationStmt/publisher" />
    <xsl:variable name="pubdate" select="/TEI.2/teiHeader/fileDesc/publicationStmt/date" />

    <!--====================================================================-->

    <xsl:variable name="unitsUsed" select="'Original'"/>

    <xd:doc>
        <xd:short>Main stylesheet for ePub generation.</xd:short>
        <xd:detail>
            <p>This stylesheet is intended to be the first triggered, and will initiates 
            generation of various ePub elements.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="/">

        <xsl:call-template name="mimetype"/>
        <xsl:call-template name="container"/>

        <!--
        <xsl:if test="//pb">
            <xsl:call-template name="pagemap"/>
        </xsl:if>
        -->

        <xsl:call-template name="copy-stylesheets"/>
        <xsl:call-template name="copy-smil-files"/>

        <xsl:apply-templates mode="opf"/>
        <xsl:apply-templates mode="ncx"/>
        <xsl:if test="$optionEPub3 = 'Yes'">
            <xsl:apply-templates mode="ePubNav"/>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>


    <!--====================================================================-->
    <!-- Mimetype file -->

    <xd:doc>
        <xd:short>Generate the file with the epub mimetype: application/epub+zip.</xd:short>
    </xd:doc>

    <xsl:template name="mimetype">
        <xsl:result-document 
                href="{$path}/mimetype"
                method="text" 
                encoding="UTF-8">
            <xsl:message terminate="no">INFO:    generated file: <xsl:value-of select="$path"/>/mimetype.</xsl:message>application/epub+zip</xsl:result-document>
    </xsl:template>


    <!--====================================================================-->
    <!-- Container file -->

    <xd:doc>
        <xd:short>Generate the container file which points to the OPF file, as required by ePub.</xd:short>
    </xd:doc>

    <xsl:template name="container">
        <xsl:result-document 
                doctype-public=""
                doctype-system=""
                href="{$path}/META-INF/container.xml"
                method="xml" 
                indent="yes"
                encoding="UTF-8">
            <xsl:message terminate="no">INFO:    generated file: <xsl:value-of select="$path"/>/META-INF/container.xml.</xsl:message>

            <container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
               <rootfiles>
                  <rootfile full-path="{$basename}.opf" media-type="application/oebps-package+xml"/>
               </rootfiles>
            </container>
        </xsl:result-document>
    </xsl:template>


    <!--====================================================================-->
    <!-- Stylesheets -->

    <xd:doc>
        <xd:short>Collect all CSS used into a single .css file.</xd:short>
    </xd:doc>

    <xsl:template name="copy-stylesheets">
        <xsl:result-document 
                href="{$path}/{$basename}.css"
                method="text" 
                encoding="UTF-8">

            <xsl:variable name="stylesheetname">
                <xsl:choose>
                    <xsl:when test="contains(/TEI.2/text/@rend, 'stylesheet(')">
                        <xsl:value-of select="substring-before(substring-after(/TEI.2/text/@rend, 'stylesheet('), ')')"/>
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="f:getConfiguration('defaultStylesheet')"/></xsl:otherwise>
                </xsl:choose>.xml
            </xsl:variable>

            <!-- Standard CSS stylesheet -->
            <xsl:copy-of select="document('style/layout-epub.css.xml')/*/node()"/>

            <!-- Supplement CSS stylesheet -->
            <xsl:copy-of select="document(normalize-space($stylesheetname))/*/node()"/>

            <!-- Custom CSS stylesheet -->
            <xsl:if test="$customCssFile">
                <xsl:copy-of select="document(normalize-space($customCssFile), .)/*/node()"/>
            </xsl:if>

            <!-- Generate CSS for rend attributes -->
            <xsl:apply-templates select="/" mode="css"/>

        </xsl:result-document>
    </xsl:template>

    <!--====================================================================-->
    <!-- SMIL files -->

    <xd:doc>
        <xd:short>Collect all SMIL-files with media-overlays, and copy them into the output.</xd:short>
    </xd:doc>

    <xsl:template name="copy-smil-files">
        <xsl:for-each select="//*[contains(@rend, 'media-overlay(')]">
            <xsl:call-template name="copy-xml-file">
                <xsl:with-param name="filename" select="f:rend-value(., 'media-overlay')"/>
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

            <xsl:message terminate="no">INFO:    generated file: <xsl:value-of select="$path"/>/cover.xhtml.</xsl:message>

        </xsl:result-document>
    </xsl:template>


    <!--====================================================================-->
    <!-- Adobe Pagemap -->

    <xd:doc>
        <xd:short>Create a (non-standard) Adobe pagemap file.</xd:short>
    </xd:doc>

    <xsl:template name="pagemap">
        <xsl:result-document 
                doctype-public=""
                doctype-system=""
                href="{$path}/pagemap.xml"
                method="xml" 
                encoding="UTF-8">

            <xsl:message terminate="no">INFO:    generated file: <xsl:value-of select="$path"/>/pagemap.xml.</xsl:message>

            <page-map xmlns="http://www.idpf.org/2007/opf">
                <xsl:for-each select="//pb">
                    <page>
                        <xsl:attribute name="name"><xsl:value-of select="@n"/></xsl:attribute>
                        <xsl:call-template name="generate-href-attribute"/>
                    </page>
                </xsl:for-each>
            </page-map>

        </xsl:result-document>
    </xsl:template>


    <!--====================================================================-->
    <!-- ePub specific overrides -->

    <!-- Only generate anchors, but do not put page numbers in the margin (from block.xsl) -->
    <xsl:template match="pb" priority="2">
        <xsl:choose>
            <!-- In HTML, we do not allow a span element at the top-level, so wrap into a p-element, unless we are in a block element already. -->
            <xsl:when test="ancestor::p | ancestor::list | ancestor::table | ancestor::l">
                <xsl:call-template name="generate-anchor"/>
            </xsl:when>
            <xsl:otherwise>
                <p><xsl:call-template name="generate-anchor"/></p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
