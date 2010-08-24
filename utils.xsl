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
    version="2.0"
    >


    <!-- ID Generation 

    Use original ID's when possible to keep ID's stable between versions. 
    We use generated ID's prepended with 'x' to avoid clashes with original 
    ID's. Note that the target id generated here should also be generated 
    on the element being referenced. We cannot use the id() function here, 
    since we do not use a DTD. 

    -->

    <xsl:template name="generate-anchor">
        <a>
            <xsl:call-template name="generate-id-attribute"/>
        </a>
    </xsl:template>

    <xsl:template name="generate-id-attribute">
        <xsl:attribute name="id">
            <xsl:call-template name="generate-id"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="generate-id-attribute-for">
        <xsl:param name="node" select="." as="element()"/>
        <xsl:attribute name="id">
            <xsl:call-template name="generate-id-for">
                <xsl:with-param name="node" select="$node"/>
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="generate-id">
        <xsl:choose>
            <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
            <xsl:otherwise>x<xsl:value-of select="generate-id(.)"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="generate-id-for">
        <xsl:param name="node" select="." as="element()"/>
        <xsl:param name="position"/>
        <xsl:choose>
            <xsl:when test="$node/@id"><xsl:value-of select="$node/@id"/></xsl:when>
            <xsl:otherwise>x<xsl:value-of select="generate-id($node)"/></xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$position">-<xsl:value-of select="$position"/></xsl:if>
    </xsl:template>


    <xsl:template name="generate-href-attribute">
        <xsl:param name="target" select="." as="element()"/>

        <xsl:attribute name="href">
            <xsl:call-template name="generate-href">
                <xsl:with-param name="target" select="$target"/>
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>


    <xsl:template name="generate-footnote-href-attribute">
        <xsl:param name="target" select="."/>

        <xsl:attribute name="href">
            <xsl:call-template name="generate-footnote-href">
                <xsl:with-param name="target" select="$target"/>
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>


    <!--====================================================================-->
    <!-- Close and Open paragraphs 

    To accomodate the differences between the TEI and HTML paragraph model, 
    we sometimes need to close (and reopen) paragraphs, as various elements 
    are not allowed inside p elements in HTML.

    -->

    <xsl:template name="closepar">
        <!-- insert </p> to close current paragraph as tables in paragraphs are illegal in HTML -->
        <xsl:if test="parent::p or parent::note">
            <xsl:text disable-output-escaping="yes">&lt;/p&gt;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template name="reopenpar">
        <xsl:if test="parent::p or parent::note">
            <xsl:text disable-output-escaping="yes">&lt;p&gt;</xsl:text>
        </xsl:if>
    </xsl:template>


    <!--====================================================================-->
    <!-- Language tagging -->

    <xsl:template name="set-lang-attribute">
        <xsl:if test="@lang">
            <xsl:choose>
                <xsl:when test="$outputmethod = 'xml'">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="@lang"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="lang"><xsl:value-of select="@lang"/></xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <!--====================================================================-->
    <!-- Shortcut for both id and language tagging -->

    <xsl:template name="set-lang-id-attributes">
        <xsl:call-template name="generate-id-attribute"/>
        <xsl:call-template name="set-lang-attribute"/>
    </xsl:template>


</xsl:stylesheet>
