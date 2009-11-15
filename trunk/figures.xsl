<!DOCTYPE xsl:stylesheet [

    <!ENTITY tab        "&#x09;">
    <!ENTITY lf         "&#x0A;">
    <!ENTITY cr         "&#x0D;">
    <!ENTITY deg        "&#176;">
    <!ENTITY ldquo      "&#x201C;">
    <!ENTITY nbsp       "&#160;">
    <!ENTITY mdash      "&#x2014;">
    <!ENTITY prime      "&#x2032;">
    <!ENTITY Prime      "&#x2033;">
    <!ENTITY plusmn     "&#x00B1;">
    <!ENTITY frac14     "&#x00BC;">
    <!ENTITY frac12     "&#x00BD;">
    <!ENTITY frac34     "&#x00BE;">

]>
<!--

    Stylesheet with templates to format figures, to be imported in 
    tei2html.xsl.

    Requires: 
        localization.xsl    : templates for localizing strings.
        messages.xsl        : stores localized messages in variables.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:img="http://www.gutenberg.ph/2006/schemas/imageinfo"
    version="1.0"
    exclude-result-prefixes="img"
    >

    <!-- Figures

    We derive the file name from the unique id, and assume that the format
    is .jpg, unless an alternative name is given in the rend attribute, using
    image()

    -->


    <xsl:template name="getimagefilename">
        <xsl:param name="format" select="'.jpg'"/>
        <xsl:choose>
            <xsl:when test="contains(@rend, 'image(')">
                <xsl:value-of select="substring-before(substring-after(@rend, 'image('), ')')"/>
            </xsl:when>
            <xsl:when test="@url">
                <xsl:value-of select="@url"/>
                <xsl:message terminate="no">Warning: using non-standard attribute url on figure.</xsl:message>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>images/</xsl:text><xsl:value-of select="@id"/><xsl:value-of select="$format"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="insertimage">
        <xsl:param name="alt" select="''"/>
        <xsl:param name="format" select="'.jpg'"/>

        <!-- Should we link to an external image? -->
        <xsl:choose>
            <xsl:when test="contains(@rend, 'link(')">
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="substring-before(substring-after(@rend, 'link('), ')')"/>
                    </xsl:attribute>
                    <xsl:call-template name="insertimage2">
                        <xsl:with-param name="alt" select="$alt"/>
                        <xsl:with-param name="format" select="$format"/>
                    </xsl:call-template>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="insertimage2">
                    <xsl:with-param name="alt" select="$alt"/>
                    <xsl:with-param name="format" select="$format"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="insertimage2">
        <xsl:param name="alt" select="''"/>
        <xsl:param name="format" select="'.jpg'"/>

        <!-- What is the text that should go on the img alt attribute in HTML? -->
        <xsl:variable name="alt2">
            <xsl:choose>
                <xsl:when test="figDesc">
                    <xsl:value-of select="figDesc"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$alt"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="file">
            <xsl:call-template name="getimagefilename">
                <xsl:with-param name="format" select="$format"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="width">
            <xsl:value-of select="substring-before(document(normalize-space($imageInfoFile))/img:images/img:image[@path=$file]/@width, 'px')"/>
        </xsl:variable>
        <xsl:variable name="height">
            <xsl:value-of select="substring-before(document(normalize-space($imageInfoFile))/img:images/img:image[@path=$file]/@height, 'px')"/>
        </xsl:variable>

        <img>
            <xsl:attribute name="src">
                <xsl:value-of select="$file"/>
            </xsl:attribute>
            <xsl:attribute name="alt">
                <xsl:value-of select="$alt2"/>
            </xsl:attribute>
            <xsl:if test="$width != ''">
                <xsl:attribute name="width">
                    <xsl:value-of select="$width"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$height != ''">
                <xsl:attribute name="height">
                    <xsl:value-of select="$height"/>
                </xsl:attribute>
            </xsl:if>
        </img>
    </xsl:template>


    <xsl:template match="figure[@rend='inline' or contains(@rend, 'position(inline)')]">
        <xsl:call-template name="insertimage">
            <xsl:with-param name="format" select="'.png'"/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="figure">
        <xsl:call-template name="closepar"/>
        <div class="figure">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>

            <xsl:variable name="file">
                <xsl:call-template name="getimagefilename"/>
            </xsl:variable>
            <xsl:variable name="width">
                <xsl:value-of select="document(normalize-space($imageInfoFile))/img:images/img:image[@path=$file]/@width"/>
            </xsl:variable>

            <xsl:choose>
                <xsl:when test="@rend='left' or contains(@rend, 'float(left)')">
                    <xsl:attribute name="class">figure floatLeft</xsl:attribute>
                    <xsl:if test="$width != ''">
                        <xsl:attribute name="style">width: <xsl:value-of select="$width"/></xsl:attribute>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="@rend='right' or contains(@rend, 'float(right)')">
                    <xsl:attribute name="class">figure floatRight</xsl:attribute>
                    <xsl:if test="$width != ''">
                        <xsl:attribute name="style">width: <xsl:value-of select="$width"/></xsl:attribute>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">figure</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:if test="p[@type='figTopLeft' or @type='figTop' or @type='figTopRight']">
                <div class="figAnnotation">
                    <xsl:if test="$width != ''">
                        <xsl:attribute name="style">width: <xsl:value-of select="$width"/></xsl:attribute>
                    </xsl:if>
                    <xsl:if test="p[@type='figTopLeft']">
                        <span class="figTopLeft"><xsl:apply-templates select="p[@type='figTopLeft']" mode="figAnnotation"/></span>
                    </xsl:if>
                    <xsl:if test="p[@type='figTop']">
                        <span class="figTop"><xsl:apply-templates select="p[@type='figTop']" mode="figAnnotation"/></span>
                    </xsl:if>
                    <xsl:if test="not(p[@type='figTop'])">
                        <span class="figTop"><xsl:text>&nbsp;</xsl:text></span>
                    </xsl:if>
                    <xsl:if test="p[@type='figTopRight']">
                        <span class="figTopRight"><xsl:apply-templates select="p[@type='figTopRight']" mode="figAnnotation"/></span>
                    </xsl:if>
                </div>
            </xsl:if>

            <xsl:call-template name="insertimage">
                <xsl:with-param name="alt" select="head"/>
            </xsl:call-template>

            <xsl:if test="p[@type='figBottomLeft' or @type='figBottom' or @type='figBottomRight']">
                <div class="figAnnotation">
                    <xsl:if test="$width != ''">
                        <xsl:attribute name="style">width: <xsl:value-of select="$width"/></xsl:attribute>
                    </xsl:if>
                    <xsl:if test="p[@type='figBottomLeft']">
                        <span class="figBottomLeft"><xsl:apply-templates select="p[@type='figBottomLeft']" mode="figAnnotation"/></span>
                    </xsl:if>
                    <xsl:if test="p[@type='figBottom']">
                        <span class="figBottom"><xsl:apply-templates select="p[@type='figBottom']" mode="figAnnotation"/></span>
                    </xsl:if>
                    <xsl:if test="not(p[@type='figBottom'])">
                        <span class="figTop"><xsl:text>&nbsp;</xsl:text></span>
                    </xsl:if>
                    <xsl:if test="p[@type='figBottomRight']">
                        <span class="figBottomRight"><xsl:apply-templates select="p[@type='figBottomRight']" mode="figAnnotation"/></span>
                    </xsl:if>
                </div>
            </xsl:if>

            <xsl:apply-templates/>
        </div>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>


    <xsl:template match="figure/head">
        <p class="figureHead"><xsl:apply-templates/></p>
    </xsl:template>


    <xsl:template match="p[@type='figTopLeft' or @type='figTop' or @type='figTopRight' or @type='figBottomLeft' or @type='figBottom' or @type='figBottomRight']"/>

    <xsl:template match="p[@type='figTopLeft' or @type='figTop' or @type='figTopRight' or @type='figBottomLeft' or @type='figBottom' or @type='figBottomRight']" mode="figAnnotation">
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template match="figDesc"/>


</xsl:stylesheet>
