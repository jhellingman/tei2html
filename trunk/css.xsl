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


    <xsl:key name="rend" match="*" use="concat(name(), ':', @rend)"/>


    <xsl:template name="translate-rend-attribute">
        <xsl:param name="rend" select="normalize-space(@rend)"/>
        <xsl:param name="name" select="name()"/>

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
                <xsl:with-param name="name" select="$name"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <!-- We need to filter out those rendering attributes that have special meaning
         to the formatting code, and should not be translated into CSS -->

    <xsl:template name="filter-css-property">
        <xsl:param name="property"/>
        <xsl:param name="value"/>

        <xsl:choose>
            <!-- Drop properties without values -->
            <xsl:when test="normalize-space($value)=''"/>

            <!-- Properties handled otherwise -->
            <xsl:when test="$property='class'"/>
            <xsl:when test="$property='link'"/>
            <xsl:when test="$property='image'"/>
            <xsl:when test="$property='summary'"/>
            <xsl:when test="$property='label'"/>
            <xsl:when test="$property='columns'"/>
            <xsl:when test="$property='stylesheet'"/>
            <xsl:when test="$property='position'"/>

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

            <xsl:when test="$property='align'">text-align:<xsl:value-of select="$value"/>;</xsl:when>
            <xsl:when test="$property='indent'">text-indent:<xsl:value-of select="$value"/>em;</xsl:when>

            <!-- Assume the rest is valid CSS -->
            <xsl:otherwise>
                <xsl:value-of select="$property"/>:<xsl:value-of select="$value"/>;
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <!-- Generate a class name for the rend; typically we use a generated id 
         for the first element having this rend attribute value -->
    <xsl:template name="generate-rend-class-name">
        <xsl:param name="rend" select="@rend"/>

        <xsl:text>x</xsl:text><xsl:value-of select="generate-id(key('rend', concat(name(), ':', $rend)))"/>
    </xsl:template>


    <!-- The same as above, but now wrapped up in an attribute -->
    <xsl:template name="generate-rend-class-attribute">
        <xsl:param name="rend" select="@rend"/>

        <xsl:attribute name="class">
            <xsl:call-template name="generate-rend-class-name">
                <xsl:with-param name="rend" select="$rend"/>
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>


    <!-- We only need to insert a class name in the output, if
         there is a matching css rule. -->
    <xsl:template name="generate-rend-class-name-if-needed">
        <xsl:param name="rend" select="@rend"/>

        <xsl:variable name="css-properties">
            <xsl:call-template name="translate-rend-attribute">
                <xsl:with-param name="rend" select="normalize-space($rend)"/>
                <xsl:with-param name="name" select="name()"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:if test="normalize-space($css-properties) != ''">
            <xsl:call-template name="generate-rend-class-name">
                <xsl:with-param name="rend" select="$rend"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <!-- The same as above, but now wrapped up in an attribute -->
    <xsl:template name="generate-rend-class-attribute-if-needed">
        <xsl:param name="rend" select="@rend"/>

        <xsl:variable name="css-properties">
            <xsl:call-template name="translate-rend-attribute">
                <xsl:with-param name="rend" select="normalize-space($rend)"/>
                <xsl:with-param name="name" select="name()"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:if test="normalize-space($css-properties) != ''">
            <xsl:call-template name="generate-rend-class-attribute">
                <xsl:with-param name="rend" select="$rend"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <!-- Low priority default rule for generating the css rules from the 
         rend attribute in css mode -->

    <xsl:template match="*[@rend]" mode="css" priority="0">
        <xsl:if test="generate-id() = generate-id(key('rend', concat(name(), ':', @rend)))">

            <xsl:variable name="css-properties">
                <xsl:call-template name="translate-rend-attribute">
                    <xsl:with-param name="rend" select="normalize-space(@rend)"/>
                    <xsl:with-param name="name" select="name()"/>
                </xsl:call-template>
            </xsl:variable>

            <xsl:if test="normalize-space($css-properties) != ''">
                <!-- Use the id of the first element with this rend attribute as a class selector -->
                .<xsl:call-template name="generate-rend-class-name"/>
                {
                    <xsl:value-of select="normalize-space($css-properties)"/> /* node='<xsl:value-of select="name()"/>' rend='<xsl:value-of select="normalize-space(@rend)"/>' count='<xsl:value-of select="count(key('rend', concat(name(), ':', @rend)))"/>' */
                }
            </xsl:if>

        </xsl:if>
        <xsl:apply-templates mode="css"/>
    </xsl:template>



    <!-- Ignore content in css-mode -->
    <xsl:template match="text()" mode="css"/>


</xsl:stylesheet>
