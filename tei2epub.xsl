<?xml version="1.0" encoding="iso-8859-1" ?>
<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to convert TEI to HTML

    Developed by Jeroen Hellingman <jeroen@bohol.ph>, to be used together with a
    CSS stylesheet. Please contact me if you have problems with this stylesheet,
    or have improvements or bug fixes to contribute.

    This file is made available under the GNU General Public License, version 3.0 or later.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"
    >

    <xsl:include href="utils.xsl"/>
    <xsl:include href="localization.xsl"/>
    <xsl:include href="messages.xsl"/>
    <xsl:include href="header.xsl"/>
    <xsl:include href="inline.xsl"/>
    <xsl:include href="block.xsl"/>
    <xsl:include href="notes.xsl"/>
    <xsl:include href="drama.xsl"/>
    <xsl:include href="contents.xsl"/>
    <xsl:include href="divisions.xsl"/>
    <xsl:include href="tables.xsl"/>
    <xsl:include href="lists.xsl"/>
    <xsl:include href="figures.xsl"/>
    <xsl:include href="colophon.xsl"/>
    <xsl:include href="gutenberg.xsl"/>


    <xsl:output
        doctype-public="-//W3C//DTD XHTML 1.1//EN"
        doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
        method="xml"
        encoding="UTF-8"/>


    <!--====================================================================-->


    <xsl:param name="optionPrinceMarkup" select="'No'"/>
    <xsl:param name="optionEPubMarkup" select="'Yes'"/>
    <xsl:param name="optionExternalCSS" select="'No'"/>
    <xsl:param name="optionPGHeaders" select="'No'"/>


    <!--====================================================================-->

    <xsl:variable name="mimeType" select="'application/xhtml+xml'"/>
    <xsl:variable name="encoding" select="document('')/xsl:stylesheet/xsl:output/@encoding"/>

    <xsl:variable name="title" select="/TEI.2/teiHeader/fileDesc/titleStmt/title" />
    <xsl:variable name="author" select="/TEI.2/teiHeader/fileDesc/titleStmt/author" />
    <xsl:variable name="publisher" select="/TEI.2/teiHeader/fileDesc/publicationStmt/publisher" />
    <xsl:variable name="pubdate" select="/TEI.2/teiHeader/fileDesc/publicationStmt/date" />


    <!--====================================================================-->

    <xsl:variable name="unitsUsed" select="'Original'"/>


</xsl:stylesheet>
