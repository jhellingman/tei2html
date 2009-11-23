<?xml version="1.0" encoding="iso-8859-1" ?>
<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to convert TEI to HTML

    Developed by Jeroen Hellingman <jeroen@bohol.ph>, to be used together with a
    CSS stylesheet. Please contact me if you have problems with this stylesheet,
    or have improvements or bug fixes to contribute.

    This stylesheet can be used with the saxon XSL processor, or with the
    build-in XSL processor in IE 6.0 or higher. Note that the XLS processor
    in Firefox will not always do the right thing.

    You can embed this style sheet in the source document with the
    <?xml-stylesheet type="text/xsl" href="stylesheet.xsl"?> processing instruction.
    This works with IE 6.0 or the latest Mozilla browsers.

    This file is made available under the GNU General Public License, version 3.0 or later.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"
    >

    <xsl:include href="utils.xsl"/>
    <xsl:include href="html.utils.xsl"/>
    <xsl:include href="localization.xsl"/>
    <xsl:include href="messages.xsl"/>
    <xsl:include href="header.xsl"/>
    <xsl:include href="inline.xsl"/>
    <xsl:include href="references.xsl"/>
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
        doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
        doctype-system="http://www.w3.org/TR/html4/loose.dtd"
        method="html"
        encoding="ISO-8859-1"/>


    <!--====================================================================-->

    <xsl:param name="basename" select="'book'"/>


    <xsl:param name="optionPrinceMarkup" select="'No'"/>
    <xsl:param name="optionEPubMarkup" select="'No'"/>
    <xsl:param name="optionExternalCSS" select="'No'"/>
    <xsl:param name="optionPGHeaders" select="'No'"/>


    <!--====================================================================-->

    <xsl:variable name="mimeType" select="'text/html'"/>   <!-- 'text/html' or 'application/xhtml+xml'. -->
    <xsl:variable name="encoding" select="document('')/xsl:stylesheet/xsl:output/@encoding"/>
    <xsl:variable name="outputmethod" select="document('')/xsl:stylesheet/xsl:output/@method"/>

    <xsl:variable name="title" select="/TEI.2/teiHeader/fileDesc/titleStmt/title" />
    <xsl:variable name="author" select="/TEI.2/teiHeader/fileDesc/titleStmt/author" />
    <xsl:variable name="publisher" select="/TEI.2/teiHeader/fileDesc/publicationStmt/publisher" />
    <xsl:variable name="pubdate" select="/TEI.2/teiHeader/fileDesc/publicationStmt/date" />


    <!--====================================================================-->

    <xsl:variable name="unitsUsed" select="'Original'"/>


</xsl:stylesheet>
