<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to handle the localization of messages in XSLT.

    The messages are pulled from a variable $messages, that should contain a node tree, following the
    messages.xsd schema. The importing stylesheet is responsible for filling this variable.

    This file is made available under the GNU General Public License, version 3.0 or later.

-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msg="http://www.gutenberg.ph/2006/schemas/messages"
    version="1.0"
    >


    <xsl:template name="GetMessage">
        <xsl:param name="name" select="'msgError'"/>
        <xsl:variable name="msg" select="$messages/msg:messages/msg:message[@name=$name]"/>
        <xsl:choose>
            <xsl:when test="$msg[lang($language)][1]">
                <xsl:apply-templates select="$msg[lang($language)][1]"/>
            </xsl:when>
            <xsl:when test="$msg[lang($baselanguage)][1]">
                <xsl:apply-templates select="$msg[lang($baselanguage)][1]"/>
            </xsl:when>
            <xsl:when test="$msg[lang($defaultlanguage)][1]">
                <xsl:message terminate="no">Warning: message '<xsl:value-of select="$name"/>' not available in locale <xsl:value-of select="$language"/>.</xsl:message>
                <xsl:apply-templates select="$msg[lang($defaultlanguage)][1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no">Warning: unknown message '<xsl:value-of select="$name"/>'.</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="FormatMessage">
        <xsl:param name="name" select="'msgError'"/>
        <xsl:param name="params"/>
        <xsl:variable name="msg" select="$messages/msg:messages/msg:message[@name=$name]"/>
        <xsl:choose>
            <xsl:when test="$msg[lang($language)][1]">
                <xsl:apply-templates select="$msg[lang($language)][1]" mode="formatMessage">
                    <xsl:with-param name="params" select="$params"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$msg[lang($baselanguage)][1]">
                <xsl:apply-templates select="$msg[lang($baselanguage)][1]" mode="formatMessage">
                    <xsl:with-param name="params" select="$params"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$msg[lang($defaultlanguage)][1]">
                <xsl:message terminate="no">Warning: message '<xsl:value-of select="$name"/>' not available in locale <xsl:value-of select="$language"/>.</xsl:message>
                <xsl:apply-templates select="$msg[lang($defaultlanguage)][1]" mode="formatMessage"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no">Warning: unknown message '<xsl:value-of select="$name"/>'.</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="msg:message" mode="formatMessage">
        <xsl:param name="params"/>
        <xsl:apply-templates mode="formatMessage">
            <xsl:with-param name="params" select="$params"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="*" mode="formatMessage">
        <xsl:param name="params"/>
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:apply-templates mode="formatMessage">
                    <xsl:with-param name="params" select="$params"/>
                </xsl:apply-templates>
            </xsl:copy>
    </xsl:template>

    <xsl:template match="msg:param" mode="formatMessage">
        <xsl:param name="params"/>
        <xsl:choose>
            <xsl:when test="$params/params/param[@name=current()/@name]">
                <xsl:value-of select="$params/params/param[@name=current()/@name]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no">Warning: no value specified for parameter '<xsl:value-of select="@name"/>'.</xsl:message>
                [### <xsl:value-of select="@name"/> ###]
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="space" mode="formatMessage">
        <xsl:text> </xsl:text>
    </xsl:template>


</xsl:stylesheet>
