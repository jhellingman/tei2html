<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to generate css, to be imported in tei2html.xsl.
    Note that the templates for css mode are mostly integrated
    with the content templates, to keep these together with
    the layout code.

    Requires: 
        localization.xsl    : templates for localizing strings.
        messages.xsl        : stores localized messages in variables.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"
    >


    <xsl:template name="translate-rend-attribute">
        <xsl:param name="rend" select="normalize-space(@rend)"/>

        <!-- A rendition ladder is straighfowardly converted to CSS, by taking the 
             characters before the ( as the css property, and the characters 
             between ( and ) as the value. We convert an entire string
             by simply doing the head, and then recursively the tail -->

        <xsl:if test="$rend != ''">
            <xsl:call-template name="filter-css-property">
                <xsl:with-param name="property" select="substring-before($rend, '(')"/>
                <xsl:with-param name="value" select="substring-before(substring-after($rend, '('), ')')"/>
            </xsl:call-template>

            <xsl:call-template name="translate-rend-attribute">
                <xsl:with-param name="rend" select="normalize-space(substring-after($rend, ')'))"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <!-- We need to filter out those rendering attributes that have special meaning
         to the formatting code, and should not be translated into CSS -->

    <xsl:template name="filter-css-property">
        <xsl:param name="property"/>
        <xsl:param name="value"/>

        <xsl:choose>
            <!-- Properties used to render verse -->
            <xsl:when test="$property='hemistich'"/>

            <!-- Properties related to decorative initials -->
            <xsl:when test="$property='initial-image'"/>
            <xsl:when test="$property='initial-offset'"/>
            <xsl:when test="$property='initial-width'"/>
            <xsl:when test="$property='initial-height'"/>

            <!-- Properties related to special font usage -->
            <xsl:when test="$property='font' and $value='fraktur'"/>
            <xsl:when test="$property='font' and $value='italic'">font-style:italic;</xsl:when>

            <!-- Assume the rest is valid CSS -->
            <xsl:otherwise>
                <xsl:value-of select="$property"/>:<xsl:value-of select="$value"/>;
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>





    <!-- Ignore content in css-mode -->
    <xsl:template match="text()" mode="css"/>


</xsl:stylesheet>
