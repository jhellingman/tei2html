<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet with various utily templates, to be imported in tei2html.xsl.

    Requires: 
        localization.xsl    : templates for localizing strings.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"
    >


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


</xsl:stylesheet>
