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

    <xsl:template name="generate-href-attribute">
        <xsl:attribute name="href">#<xsl:call-template name="generate-id"/></xsl:attribute>
    </xsl:template>

    <xsl:template name="generate-href-attribute-for">
        <xsl:param name="node"/>
        <xsl:attribute name="href">#<xsl:call-template name="generate-id-for"><xsl:with-param name="node"/></xsl:call-template></xsl:attribute>
    </xsl:template>

    <xsl:template name="generate-id">
        <xsl:choose>
            <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
            <xsl:otherwise>x<xsl:value-of select="generate-id(.)"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="generate-id-for">
        <xsl:param name="node"/>
        <xsl:choose>
            <xsl:when test="$node/@id"><xsl:value-of select="$node/@id"/></xsl:when>
            <xsl:otherwise>x<xsl:value-of select="generate-id($node)"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="generate-filename">
        <xsl:param name="extension" select="'xhtml'"/>
        <xsl:value-of select="$basename"/>-<xsl:call-template name="generate-id"/>.<xsl:value-of select="$extension"/>
    </xsl:template>

    <xsl:template name="generate-filename-for">
        <xsl:param name="node"/>
        <xsl:param name="extension" select="'xhtml'"/>
        <xsl:value-of select="$basename"/>-<xsl:call-template name="generate-id-for"><xsl:with-param name="node" select="$node"/></xsl:call-template>.<xsl:value-of select="$extension"/>
    </xsl:template>


    <!--====================================================================-->
    <!-- Close and Open paragraphs 

    To accomodate the differences between the TEI and HTML paragraph model, 
    we sometimes need to close (and reopen) paragraphs, as various elements 
    are not allowed inside p elements in HTML.

    -->

    <xsl:template name="closepar">
        <!-- insert </p> to close current paragraph as tables in paragraphs are illegal in HTML -->
        <xsl:if test="parent::p">
            <xsl:text disable-output-escaping="yes">&lt;/p&gt;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template name="reopenpar">
        <xsl:if test="parent::p">
            <xsl:text disable-output-escaping="yes">&lt;p&gt;</xsl:text>
        </xsl:if>
    </xsl:template>


    <!--====================================================================-->
    <!-- Language tagging -->

    <xsl:template name="setLangAttribute">
        <xsl:if test="@lang">
            <xsl:choose>
                <xsl:when test="document('')/xsl:stylesheet/xsl:output/@method = 'xml'">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="@lang"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="lang"><xsl:value-of select="@lang"/></xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>


    <!--====================================================================-->
    <!-- CSS Class tagging -->

    <xsl:template name="setCssClassAttribute">
        <xsl:if test="contains(@rend, 'class(')">
            <xsl:attribute name="class">
                <xsl:value-of select="substring-before(substring-after(@rend, 'class('), ')')"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>


</xsl:stylesheet>
