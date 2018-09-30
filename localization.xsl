<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:msg="http://www.gutenberg.ph/2006/schemas/messages"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f msg xd xhtml xs">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to handle the localization of messages in XSLT.</xd:short>
        <xd:detail>This stylesheet contains templates to support localization of messages.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2014, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Localized messages.</xd:short>
        <xd:detail>Node tree of document following the <code>messages.xsd</code> schema. The actual messages are pulled from this structure.</xd:detail>
    </xd:doc>

    <xsl:variable name="messages" select="document('messages.xml')/msg:repository"/>


    <xd:doc>
        <xd:short>Localization language.</xd:short>
        <xd:detail>The language and specific locale to use, e.g. 'en-US'.</xd:detail>
    </xd:doc>

    <xsl:variable name="language" select="if (/TEI.2/@lang | /*:TEI/@xml:lang) then /TEI.2/@lang | /*:TEI/@xml:lang else 'en-US'" as="xs:string"/>


    <xd:doc>
        <xd:short>Localization base-language.</xd:short>
        <xd:detail>The language without the locale, e.g. 'de'.</xd:detail>
    </xd:doc>

    <xsl:variable name="baselanguage" select="if (contains($language, '-')) then substring-before($language, '-') else $language" as="xs:string"/>


    <xd:doc>
        <xd:short>Localization default language.</xd:short>
        <xd:detail>The default language, to be used when no message is available in the specified language. (A warning will be issued in this case.)</xd:detail>
    </xd:doc>

    <xsl:variable name="defaultlanguage" select="'en'" as="xs:string"/>


    <xd:doc>
        <xd:short>Find a localized message.</xd:short>
        <xd:detail>Function to find a localized message in the <code>messages.xml</code> file. This function will first try to find the message
        in the exact locale, then in the base-language, and, if this also fails, in the default locale.</xd:detail>
    </xd:doc>

    <xsl:function name="f:message" as="xs:string">
        <xsl:param name="name" as="xs:string"/>
        <xsl:variable name="msg" select="$messages/msg:messages/msg:message[@name=$name]"/>
        <xsl:choose>
            <xsl:when test="$msg[lang($language)][1]">
                <xsl:apply-templates select="$msg[lang($language)][1]" mode="formatMessage"/>
                <xsl:copy-of select="f:logDebug('{1}: {2} = {3}', ($language, $name, $msg[lang($language)][1]))"/>
            </xsl:when>
            <xsl:when test="$msg[lang($baselanguage)][1]">
                <xsl:apply-templates select="$msg[lang($baselanguage)][1]" mode="formatMessage"/>
                <xsl:copy-of select="f:logDebug('{1}: {2} = {3}', ($baselanguage, $name, $msg[lang($baselanguage)][1]))"/>
            </xsl:when>
            <xsl:when test="$msg[lang($defaultlanguage)][1]">
                <xsl:copy-of select="f:logWarning('Message {1} not available in locale {2}, using {3} instead.', ($name, $language, $defaultlanguage))"/>
                <xsl:apply-templates select="$msg[lang($defaultlanguage)][1]" mode="formatMessage"/>
                <xsl:copy-of select="f:logDebug('{1}: {2} = {3}', ($defaultlanguage, $name, $msg[lang($defaultlanguage)][1]))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="f:logError('Unknown message {1}.', ($name))"/>
                <xsl:value-of select="concat('[### ', $name, ' ###]')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function> 


    <xd:doc>
        <xd:short>Format a localized message.</xd:short>
        <xd:detail>Function to find and format a localized message in the <code>messages.xml</code> file. This function will first try to find the message
        in the exact locale, then in the base-language, and, if this also fails, in the default locale. After finding it, it will apply the given
        parameters to it.</xd:detail>
    </xd:doc>

    <xsl:function name="f:formatMessage">
        <xsl:param name="name" as="xs:string"/>
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
                <xsl:copy-of select="f:logWarning('Message {1} not available in locale {2}, using {3} instead.', ($name, $language, $defaultlanguage))"/>
                <xsl:apply-templates select="$msg[lang($defaultlanguage)][1]" mode="formatMessage">
                    <xsl:with-param name="params" select="$params"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="f:logError('Unknown message {1}.', ($name))"/>
                <xsl:value-of select="concat('[### ', $name, ' ###]')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xd:doc>
        <xd:short>Handle a localized message.</xd:short>
        <xd:detail>Apply the parameters to the selected message. Make sure that we drop namespaces inherited from the
        <code>messages.xml</code> file from the message loaded.</xd:detail>
    </xd:doc>

    <xsl:template match="msg:message" mode="formatMessage">
        <xsl:param name="params" as="document-node()?"/>
        <xsl:variable name="formattedMessage">
            <xsl:apply-templates mode="formatMessage">
                <xsl:with-param name="params" select="$params"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:copy-of select="$formattedMessage" copy-namespaces="no"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Copy element in a localized message.</xd:short>
        <xd:detail>The element is supposed to be suitable for the output format, that is HTML or XHTML.</xd:detail>
    </xd:doc>

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
                <xsl:copy-of select="f:logError('No value specified for parameter {1}.', (@name))"/>
                <xsl:text>[### </xsl:text><xsl:value-of select="@name"/><xsl:text> ###]</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Output a space in the localized message.</xd:short>
    </xd:doc>

    <xsl:template match="space" mode="formatMessage">
        <xsl:text> </xsl:text>
    </xsl:template>


</xsl:stylesheet>
