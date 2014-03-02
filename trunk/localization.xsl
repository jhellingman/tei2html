<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to handle the localization of messages in XSLT.

    This file is made available under the GNU General Public License, version 3.0 or later.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:msg="http://www.gutenberg.ph/2006/schemas/messages"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f xs"
    version="2.0"
    >

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to handle the localization of messages in XSLT.</xd:short>
        <xd:detail>This stylesheet contains templates to support localization of messages.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2014, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xd:doc>
        <xd:short>Localized messages.</xd:short>
        <xd:detail>Node tree of document following the messages.xsd schema. The actual messages are pulled from this structure.</xd:detail>
    </xd:doc>

    <xsl:variable name="messages" select="document('messages.xml')/msg:repository"/>

    <xd:doc>
        <xd:short>Localization language.</xd:short>
        <xd:detail>The language and specific locale to use, e.g. 'de-AT'.</xd:detail>
    </xd:doc>

    <xsl:variable name="language" select="/TEI.2/@lang" />

    <xd:doc>
        <xd:short>Localization base-language.</xd:short>
        <xd:detail>The language without the locale, e.g. 'de'.</xd:detail>
    </xd:doc>

    <xsl:variable name="baselanguage" select="if (contains($language, '-')) then substring-before($language, '-') else $language" />

    <xd:doc>
        <xd:short>Localization default language.</xd:short>
        <xd:detail>The default language, to be used when no message is available in the specified language. (A warning will be issued in this case.)</xd:detail>
    </xd:doc>

    <xsl:variable name="defaultlanguage" select="'en'" />

    <xd:doc>
        <xd:short>Find a localized message (short form).</xd:short>
    </xd:doc>

    <xsl:function name="f:_" as="xs:string">
        <xsl:param name="name" as="xs:string"/>
        <xsl:value-of select="f:message($name)"/>
    </xsl:function> 

    <xd:doc>
        <xd:short>Find a localized message.</xd:short>
        <xd:detail>Function to find a localized message in the messages.xml file. This function will first try to find the message
        in the exact locale, then in the base-language, and, if this also fails, in the default locale.</xd:detail>
    </xd:doc>

    <xsl:function name="f:message" as="xs:string">
        <xsl:param name="name" as="xs:string"/>
            <xsl:variable name="msg" select="$messages/msg:messages/msg:message[@name=$name]"/>
            <xsl:choose>
                <xsl:when test="$msg[lang($language)][1]">
                    <xsl:apply-templates select="$msg[lang($language)][1]"/>
                    <!-- <xsl:message terminate="no">INFO:    message '<xsl:value-of select="$name"/>' is '<xsl:value-of select="$msg[lang($baselanguage)][1]"/>' in locale <xsl:value-of select="$language"/>.</xsl:message> -->
                </xsl:when>
                <xsl:when test="$msg[lang($baselanguage)][1]">
                    <xsl:apply-templates select="$msg[lang($baselanguage)][1]"/>
                    <!-- <xsl:message terminate="no">INFO:    message '<xsl:value-of select="$name"/>' is '<xsl:value-of select="$msg[lang($baselanguage)][1]"/>' in locale <xsl:value-of select="$baselanguage"/>.</xsl:message> -->
                </xsl:when>
                <xsl:when test="$msg[lang($defaultlanguage)][1]">
                    <xsl:message terminate="no">WARNING: message '<xsl:value-of select="$name"/>' not available in locale <xsl:value-of select="$language"/>, using <xsl:value-of select="$defaultlanguage"/> instead.</xsl:message>
                    <xsl:apply-templates select="$msg[lang($defaultlanguage)][1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="no">WARNING: unknown message '<xsl:value-of select="$name"/>'.</xsl:message>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:function> 

    <xd:doc>
        <xd:short>Find a localized message.</xd:short>
        <xd:detail>Template to find a localized message in the messages.xml file. This template will first try to find the message
        in the exact locale, then in the base-language, and, if this also fails, in the default locale.</xd:detail>
    </xd:doc>

    <xsl:template name="GetMessage">
        <xsl:param name="name" select="'msgError'" as="xs:string"/>
        <xsl:variable name="msg" select="$messages/msg:messages/msg:message[@name=$name]"/>
        <xsl:choose>
            <xsl:when test="$msg[lang($language)][1]">
                <xsl:apply-templates select="$msg[lang($language)][1]"/>
                <!-- <xsl:message terminate="no">INFO:    message '<xsl:value-of select="$name"/>' is '<xsl:value-of select="$msg[lang($baselanguage)][1]"/>' in locale <xsl:value-of select="$language"/>.</xsl:message> -->
            </xsl:when>
            <xsl:when test="$msg[lang($baselanguage)][1]">
                <xsl:apply-templates select="$msg[lang($baselanguage)][1]"/>
                <!-- <xsl:message terminate="no">INFO:    message '<xsl:value-of select="$name"/>' is '<xsl:value-of select="$msg[lang($baselanguage)][1]"/>' in locale <xsl:value-of select="$baselanguage"/>.</xsl:message> -->
            </xsl:when>
            <xsl:when test="$msg[lang($defaultlanguage)][1]">
                <xsl:message terminate="no">WARNING: message '<xsl:value-of select="$name"/>' not available in locale <xsl:value-of select="$language"/>, using <xsl:value-of select="$defaultlanguage"/> instead.</xsl:message>
                <xsl:apply-templates select="$msg[lang($defaultlanguage)][1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no">WARNING: unknown message '<xsl:value-of select="$name"/>'.</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:short>Format a localized message.</xd:short>
        <xd:detail>Template to find and format a localized message in the messages.xml file. This template will first try to find the message
        in the exact locale, then in the base-language, and, if this also fails, in the default locale. After finding it, it will apply the given
        parameters to it.</xd:detail>
    </xd:doc>

    <xsl:template name="FormatMessage">
        <xsl:param name="name" select="'msgError'" as="xs:string"/>
        <xsl:param name="params" as="document-node()"/>
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
                <xsl:message terminate="no">WARNING: message '<xsl:value-of select="$name"/>' not available in locale <xsl:value-of select="$language"/>, using <xsl:value-of select="$defaultlanguage"/> instead.</xsl:message>
                <xsl:apply-templates select="$msg[lang($defaultlanguage)][1]" mode="formatMessage">
                    <xsl:with-param name="params" select="$params"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no">WARNING: unknown message '<xsl:value-of select="$name"/>'.</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="msg:message" mode="formatMessage">
        <xsl:param name="params" as="document-node()?"/>
        <xsl:apply-templates mode="formatMessage">
            <xsl:with-param name="params" select="$params"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="*" mode="formatMessage">
        <xsl:param name="params" as="document-node()?"/>
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:apply-templates mode="formatMessage">
                    <xsl:with-param name="params" select="$params"/>
                </xsl:apply-templates>
            </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:short>Insert a parameter in a localized message.</xd:short>
        <xd:detail>Template to insert a parameter in a localized message. The parameter is being looked-up in the list of parameters supplied
        to the FormatMessage template invocation. If no parameter was supplied, but the message requires one, a warning will be issued.</xd:detail>
    </xd:doc>

    <xsl:template match="msg:param" mode="formatMessage">
        <xsl:param name="params" as="document-node()?"/>
        <xsl:variable name="name" select="@name"/>
        <xsl:choose>
            <xsl:when test="$params//*[@name=$name]">
                <xsl:value-of select="$params//*[@name=$name]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no">WARNING: no value specified for parameter '<xsl:value-of select="@name"/>'.</xsl:message>
                <xsl:text>[### </xsl:text><xsl:value-of select="@name"/><xsl:text> ###]</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="space" mode="formatMessage">
        <xsl:text> </xsl:text>
    </xsl:template>


</xsl:stylesheet>
