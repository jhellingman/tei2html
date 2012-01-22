<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to handle the localization of messages in XSLT.

    This file is made available under the GNU General Public License, version 3.0 or later.

    == Required variables ==

    This uses the following variables:

    $messages           Node tree of document following the messages.xsd schema. 
                        The actual messages are pulled from this structure.
    $language           The language and specific locale to use, e.g. 'de-AT'
    $baselanguage       The language without the locale, e.g. 'de'
    $defaultlanguage    The default language, to be used when no message is available
                        in the specified language.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msg="http://www.gutenberg.ph/2006/schemas/messages"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="urn:stylesheet-functions"
    exclude-result-prefixes="f xs"
    version="2.0"
    >

    <xsl:variable name="language" select="/TEI.2/@lang" />
    <xsl:variable name="baselanguage" select="if (contains($language, '-')) then substring-before($language, '-') else $language" />
    <xsl:variable name="defaultlanguage" select="'en'" />
    <xsl:variable name="messages" select="document('messages.xml')/msg:repository"/>

    <xsl:function name="f:_" as="xs:string">
        <xsl:param name="name" as="xs:string"/>
        <xsl:value-of select="f:message($name)"/>
    </xsl:function> 

    <xsl:function name="f:message" as="xs:string">
        <xsl:param name="name" as="xs:string"/>
            <xsl:variable name="msg" select="$messages/msg:messages/msg:message[@name=$name]"/>
            <xsl:choose>
                <xsl:when test="$msg[lang($language)][1]">
                    <xsl:apply-templates select="$msg[lang($language)][1]"/>
                    <!-- <xsl:message terminate="no">Info: message '<xsl:value-of select="$name"/>' is '<xsl:value-of select="$msg[lang($baselanguage)][1]"/>' in locale <xsl:value-of select="$language"/>.</xsl:message> -->
                </xsl:when>
                <xsl:when test="$msg[lang($baselanguage)][1]">
                    <xsl:apply-templates select="$msg[lang($baselanguage)][1]"/>
                    <!-- <xsl:message terminate="no">Info: message '<xsl:value-of select="$name"/>' is '<xsl:value-of select="$msg[lang($baselanguage)][1]"/>' in locale <xsl:value-of select="$baselanguage"/>.</xsl:message> -->
                </xsl:when>
                <xsl:when test="$msg[lang($defaultlanguage)][1]">
                    <xsl:message terminate="no">Warning: message '<xsl:value-of select="$name"/>' not available in locale <xsl:value-of select="$language"/>, using <xsl:value-of select="$defaultlanguage"/> instead.</xsl:message>
                    <xsl:apply-templates select="$msg[lang($defaultlanguage)][1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="no">Warning: unknown message '<xsl:value-of select="$name"/>'.</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:function> 

    <xsl:template name="GetMessage">
        <xsl:param name="name" select="'msgError'"/>
        <xsl:variable name="msg" select="$messages/msg:messages/msg:message[@name=$name]"/>
        <xsl:choose>
            <xsl:when test="$msg[lang($language)][1]">
                <xsl:apply-templates select="$msg[lang($language)][1]"/>
                <!-- <xsl:message terminate="no">Info: message '<xsl:value-of select="$name"/>' is '<xsl:value-of select="$msg[lang($baselanguage)][1]"/>' in locale <xsl:value-of select="$language"/>.</xsl:message> -->
            </xsl:when>
            <xsl:when test="$msg[lang($baselanguage)][1]">
                <xsl:apply-templates select="$msg[lang($baselanguage)][1]"/>
                <!-- <xsl:message terminate="no">Info: message '<xsl:value-of select="$name"/>' is '<xsl:value-of select="$msg[lang($baselanguage)][1]"/>' in locale <xsl:value-of select="$baselanguage"/>.</xsl:message> -->
            </xsl:when>
            <xsl:when test="$msg[lang($defaultlanguage)][1]">
                <xsl:message terminate="no">Warning: message '<xsl:value-of select="$name"/>' not available in locale <xsl:value-of select="$language"/>, using <xsl:value-of select="$defaultlanguage"/> instead.</xsl:message>
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
        <xsl:variable name="name" select="@name"/>
        <xsl:choose>
            <xsl:when test="$params//*[@name=$name]">
                <xsl:value-of select="$params//*[@name=$name]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no">Warning: no value specified for parameter '<xsl:value-of select="@name"/>'.</xsl:message>
                <xsl:text>[### </xsl:text><xsl:value-of select="@name"/><xsl:text> ###]</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="space" mode="formatMessage">
        <xsl:text> </xsl:text>
    </xsl:template>


</xsl:stylesheet>
