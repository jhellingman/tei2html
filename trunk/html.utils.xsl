<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet with various utily templates, to be imported in tei2html.xsl.

    Requires: 
        localization.xsl    : templates for localizing strings.
        messages.xsl        : stores localized messages in variables.

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


    <xsl:template name="generate-href-attribute">
        <xsl:param name="source" select="."/>
        <xsl:param name="target" select="."/>

        <xsl:attribute name="href">#<xsl:call-template name="generate-id-for"><xsl:with-param name="node" select="$target"/></xsl:call-template></xsl:attribute>
    </xsl:template>


</xsl:stylesheet>
