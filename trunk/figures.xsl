<!DOCTYPE xsl:stylesheet [

    <!ENTITY nbsp       "&#160;">

]>
<!--

    Stylesheet with templates to format figures, to be imported in
    tei2html.xsl.

    Requires:
        localization.xsl    : templates for localizing strings.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:img="http://www.gutenberg.ph/2006/schemas/imageinfo"
    version="2.0"
    exclude-result-prefixes="img xs"
    >


    <!-- imageInfoFile is an XML file that contains information on the dimensions of images. -->
    <xsl:param name="imageInfoFile"/>


    <!-- Figures

    We derive the file name from the unique id, and assume that the format
    is .jpg, unless an alternative name is given in the rend attribute, using
    image()

    -->


    <xsl:template name="getimagefilename">
        <xsl:param name="format" select="'.jpg'" as="xs:string"/>
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
        <xsl:param name="alt" select="''" as="xs:string"/>
        <xsl:param name="format" select="'.jpg'" as="xs:string"/>

        <!-- Should we link to an external image? -->
        <xsl:choose>
            <xsl:when test="contains(@rend, 'link(')">
                <xsl:variable name="url" select="substring-before(substring-after(@rend, 'link('), ')')"/>
                <a>
                    <xsl:choose>
                        <xsl:when test="$outputformat = 'epub' and matches($url, '^[^:]+\.(jpg|png|gif|svg)$')">
                            <!-- cannot directly link to image file in epub, need to generate wrapper html
                                 and link to that. -->
                            <xsl:call-template name="generate-image-wrapper">
                                <xsl:with-param name="imagefile" select="$url"/>
                            </xsl:call-template>
                            <xsl:attribute name="href"><xsl:value-of select="$basename"/>-<xsl:call-template name="generate-id"/>.xhtml</xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="href">
                                <xsl:value-of select="$url"/>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
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
        <xsl:param name="alt" select="''" as="xs:string"/>
        <xsl:param name="format" select="'.jpg'" as="xs:string"/>
        <xsl:param name="filename" select="''" as="xs:string"/>

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
            <!-- Did we get the file name as parameter? -->
            <xsl:choose>
                <xsl:when test="$filename = ''">
                    <xsl:call-template name="getimagefilename">
                        <xsl:with-param name="format" select="$format"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$filename"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="width">
            <xsl:value-of select="substring-before(document(normalize-space($imageInfoFile), .)/img:images/img:image[@path=$file]/@width, 'px')"/>
        </xsl:variable>
        <xsl:variable name="height">
            <xsl:value-of select="substring-before(document(normalize-space($imageInfoFile), .)/img:images/img:image[@path=$file]/@height, 'px')"/>
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


    <xsl:template name="generate-image-wrapper">
        <xsl:param name="imagefile" as="xs:string"/>

        <xsl:variable name="filename"><xsl:value-of select="$basename"/>-<xsl:call-template name="generate-id"/>.xhtml</xsl:variable>

        <xsl:result-document href="{$path}/{$filename}">
            <xsl:message terminate="no">Info: generated file: <xsl:value-of select="$path"/>/<xsl:value-of select="$filename"/>.</xsl:message>
            <html>
                <xsl:call-template name="generate-html-header"/>
                <body>
                    <div class="figure">

                        <img src="{$imagefile}">
                            <xsl:attribute name="alt">
                                <xsl:choose>
                                    <xsl:when test="figDesc">
                                        <xsl:value-of select="figDesc"/>
                                    </xsl:when>
                                    <xsl:when test="head">
                                        <xsl:value-of select="head"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="''"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                        </img>

                        <xsl:apply-templates/>
                    </div>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>


    <!-- TEI P5 graphic element -->
    <xsl:template match="graphic">
        <xsl:if test="$optionIncludeImages = 'Yes'">
            <xsl:call-template name="insertimage">
                <xsl:with-param name="format" select="'.png'"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <xsl:template match="figure[@rend='inline' or contains(@rend, 'position(inline)')]">
        <xsl:if test="$optionIncludeImages = 'Yes'">
            <xsl:call-template name="insertimage">
                <xsl:with-param name="format" select="'.png'"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <xsl:template match="figure" mode="css">
        <xsl:if test="$optionIncludeImages = 'Yes'">
            <!-- Generate CCS class the normal way -->
            <xsl:call-template name="generate-css-rule"/>

            <!-- Create a special CSS rule for setting the width of this image -->
            <xsl:variable name="file">
                <xsl:call-template name="getimagefilename"/>
            </xsl:variable>
            <xsl:variable name="width">
                <xsl:value-of select="document(normalize-space($imageInfoFile), .)/img:images/img:image[@path=$file]/@width"/>
            </xsl:variable>

            <xsl:if test="$width != ''">
.x<xsl:value-of select="generate-id()"/>width
{
    width:<xsl:value-of select="$width"/>;
}
            </xsl:if>

            <xsl:apply-templates mode="css"/>
        </xsl:if>
    </xsl:template>


    <xsl:template match="figure">
        <xsl:if test="$optionIncludeImages = 'Yes'">
            <xsl:call-template name="closepar"/>
            <div class="figure">
                <xsl:call-template name="set-lang-id-attributes"/>

                <xsl:variable name="file">
                    <xsl:call-template name="getimagefilename"/>
                </xsl:variable>
                <xsl:variable name="width">
                    <xsl:value-of select="document(normalize-space($imageInfoFile), .)/img:images/img:image[@path=$file]/@width"/>
                </xsl:variable>

                <xsl:if test="$width = ''">
                    <xsl:message terminate="no">Warning: Image "<xsl:value-of select="$file"/>" not present in imageinfo file "<xsl:value-of select="normalize-space($imageInfoFile)"/>".</xsl:message>
                </xsl:if>

                <xsl:attribute name="class">
                    <xsl:text>figure </xsl:text>
                    <xsl:if test="contains(@rend, 'float(left)')">floatLeft </xsl:if>
                    <xsl:if test="contains(@rend, 'float(right)')">floatRight </xsl:if>
                    <xsl:call-template name="generate-rend-class-name-if-needed"/><xsl:text> </xsl:text>
                    <!-- Add the class that sets the width, if the width is known -->
                    <xsl:if test="$width != ''">x<xsl:value-of select="generate-id()"/><xsl:text>width</xsl:text></xsl:if>
                </xsl:attribute>

                <xsl:call-template name="figure-annotations-top"/>

                <xsl:call-template name="insertimage">
                    <xsl:with-param name="alt" select="if (figDesc) then figDesc else (if (head) then head else '')"/>
                </xsl:call-template>

                <xsl:call-template name="figure-annotations-bottom"/>

                <xsl:apply-templates/>
            </div>
            <xsl:call-template name="reopenpar"/>
        </xsl:if>
    </xsl:template>


    <xsl:template name="figure-annotations-top">
        <xsl:if test="p[@type='figTopLeft' or @type='figTop' or @type='figTopRight']">

            <xsl:variable name="file">
                <xsl:call-template name="getimagefilename"/>
            </xsl:variable>
            <xsl:variable name="width">
                <xsl:value-of select="document(normalize-space($imageInfoFile), .)/img:images/img:image[@path=$file]/@width"/>
            </xsl:variable>

            <div>
                <xsl:attribute name="class">
                    <xsl:text>figAnnotation </xsl:text>
                    <xsl:if test="$width != ''">x<xsl:value-of select="generate-id()"/><xsl:text>width</xsl:text></xsl:if>
                </xsl:attribute>

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
    </xsl:template>


    <xsl:template name="figure-annotations-bottom">
        <xsl:if test="p[@type='figBottomLeft' or @type='figBottom' or @type='figBottomRight']">

            <xsl:variable name="file">
                <xsl:call-template name="getimagefilename"/>
            </xsl:variable>
            <xsl:variable name="width">
                <xsl:value-of select="document(normalize-space($imageInfoFile), .)/img:images/img:image[@path=$file]/@width"/>
            </xsl:variable>

            <div>
                <xsl:attribute name="class">
                    <xsl:text>figAnnotation </xsl:text>
                    <xsl:if test="$width != ''">x<xsl:value-of select="generate-id()"/><xsl:text>width</xsl:text></xsl:if>
                </xsl:attribute>

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
