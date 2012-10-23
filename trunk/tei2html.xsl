<?xml version="1.0" encoding="iso-8859-1" ?>
<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheets to convert TEI to HTML

    Developed by Jeroen Hellingman <jeroen@bohol.ph>, to be used together with
    CSS stylesheets. Please contact me if you have problems with this stylesheet,
    or have improvements or bug fixes to contribute.

    This file is made available under the GNU General Public License, version 3.0 or later.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="xd"
    version="2.0"
    >

    <xd:doc type="stylesheet">
        <xd:short>TEI stylesheet to convert a TEI document to HTML.</xd:short>
        <xd:detail>This stylesheet is the main entry point for the TEI to HTML conversion. It contains no
        templates itself, but collects all stylesheets, and sets a number of global variables.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:include href="utils.xsl"/>
    <xsl:include href="utils.html.xsl"/>
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
    <xsl:include href="tables.xsl"/>
    <xsl:include href="lists.xsl"/>
    <xsl:include href="figures.xsl"/>
    <xsl:include href="colophon.xsl"/>
    <xsl:include href="gutenberg.xsl"/>
    <xsl:include href="facsimile.xsl"/>


    <xsl:output
        doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
        doctype-system="http://www.w3.org/TR/html4/loose.dtd"
        method="html"
        encoding="iso-8859-1"/>

    <!--<xsl:output
        doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
        method="xml"
        encoding="iso-8859-1"/>-->


    <!--====================================================================-->

    <xd:doc type="string">Name used as prefix for generated file names (not relevant for HTML, but required for some included stylesheets).</xd:doc>
    <xsl:param name="basename" select="'book'"/>

    <xd:doc type="string">Path in which generated file will be placed (not relevant for HTML, but required for some included stylesheets).</xd:doc>
    <xsl:param name="path" select="''"/>

    <xd:doc type="string">Generate special markup used by PrinceXML to generate PDF files (Yes or No).</xd:doc>
    <xsl:param name="optionPrinceMarkup" select="'No'"/>

    <xd:doc type="string">Generate special markup used in ePub files (Yes or No).</xd:doc>
    <xsl:param name="optionEPubMarkup" select="'No'"/>

    <xd:doc type="string">Generate special markup used in ePub3 files (Yes or No).</xd:doc>
    <xsl:param name="optionEPub3" select="'No'"/>

    <xd:doc type="string">Generate Project Gutenberg headers and footers (Yes or No).</xd:doc>
    <xsl:param name="optionPGHeaders" select="'No'"/>

    <xd:doc type="string">Output paragraph numbers, using the value of the @n attribute (Yes or No).</xd:doc>
    <xsl:param name="optionParagraphNumbers" select="'No'"/>

    <xd:doc type="string">Include images in the generated output (Yes or No).</xd:doc>
    <xsl:param name="optionIncludeImages" select="'Yes'"/>

    <xd:doc type="string">Include external links in the generated output (Yes, No, or HeaderOnly). When using HeaderOnly, external links will only appear in the generated colophon.</xd:doc>
    <xsl:param name="optionExternalLinks" select="'Yes'"/>

    <xd:doc type="string">Include a table of external links in the colophon (Yes or No).</xd:doc>
    <xsl:param name="optionExternalLinksTable" select="'No'"/>

    <xd:doc type="string">Generate a digital facsimile from page images (Yes or No).</xd:doc>
    <xsl:param name="optionGenerateFacsimile" select="'Yes'"/>


    <!--====================================================================-->

    <xsl:variable name="mimeType" select="'text/html'"/>   <!-- 'text/html' or 'application/xhtml+xml'. -->
    <xsl:variable name="encoding" select="document('')/xsl:stylesheet/xsl:output/@encoding"/>
    <xsl:variable name="outputmethod" select="document('')/xsl:stylesheet/xsl:output/@method"/>
    <xsl:variable name="outputformat" select="'html'"/>

    <xsl:variable name="title" select="/TEI.2/teiHeader/fileDesc/titleStmt/title" />
    <xsl:variable name="author" select="/TEI.2/teiHeader/fileDesc/titleStmt/author" />
    <xsl:variable name="publisher" select="/TEI.2/teiHeader/fileDesc/publicationStmt/publisher" />
    <xsl:variable name="pubdate" select="/TEI.2/teiHeader/fileDesc/publicationStmt/date" />


    <!--====================================================================-->

    <xd:doc type="string">If units are encoded using the <code>measure</code> tag: use either the original or regularized units (TODO;
    currently both are shown, the original in the text, the regularized units in a pop-up).</xd:doc>
    <xsl:variable name="unitsUsed" select="'Original'"/>


</xsl:stylesheet>
