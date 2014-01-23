<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet with various utily templates, to be imported in tei2html.xsl.

    Requires: 
        localization.xsl    : templates for localizing strings.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="xd"
    version="2.0"
    >

    <xd:doc type="stylesheet">
        <xd:short>HTML-specific utility templates and functions, used by tei2html</xd:short>
        <xd:detail>This stylesheet contains a number of utility templates and functions, used by tei2html only.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <!-- href attributes 

    href attributes need to point to the correct file and element, depending on
    whether we generate a monolithic or multiple files using the splitter.
    This file contains the named templates for the monolithic variant.

    -->

    <xsl:template name="generate-href">
        <xsl:param name="target" select="."/>

        <xsl:text>#</xsl:text>
        <xsl:call-template name="generate-id-for">
            <xsl:with-param name="node" select="$target"/>
        </xsl:call-template>
    </xsl:template>


    <!-- footnote href attributes are the same as normal hrefs in
         single file operation -->

    <xsl:template name="generate-footnote-href">
        <xsl:param name="target" select="."/>

        <xsl:call-template name="generate-href">
            <xsl:with-param name="target" select="$target"/>
        </xsl:call-template>
    </xsl:template>

    <!-- apparatus-note href attributes are the same as normal hrefs in
         single file operation -->

    <xsl:template name="generate-apparatus-note-href">
        <xsl:param name="target" select="."/>

        <xsl:call-template name="generate-href">
            <xsl:with-param name="target" select="$target"/>
        </xsl:call-template>
    </xsl:template>

    <!-- xref table href attributes are the same as normal hrefs in
         single file operation, followed by 'ext' -->

    <xsl:template name="generate-xref-table-href">
        <xsl:param name="target" select="."/>

        <xsl:call-template name="generate-href">
            <xsl:with-param name="target" select="$target"/>
        </xsl:call-template>
        <xsl:text>ext</xsl:text>
    </xsl:template>


</xsl:stylesheet>
