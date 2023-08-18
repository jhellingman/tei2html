<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="urn:stylesheet-functions"
                xmlns:msg="http://www.gutenberg.ph/2006/schemas/messages"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="f msg xd xs">

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

    <xsl:variable name="messages" select="document('../locale/messages.xml')/msg:repository"/>


    <xd:doc>
        <xd:short>Localization language.</xd:short>
        <xd:detail>The language and specific locale to use, e.g., 'en-US'.</xd:detail>
    </xd:doc>

    <xsl:variable name="language" select="if (/TEI.2/@lang | /*:TEI/@xml:lang) then /TEI.2/@lang | /*:TEI/@xml:lang else f:get-setting('language')" as="xs:string"/>


    <xd:doc>
        <xd:short>Localization base-language.</xd:short>
        <xd:detail>The language without the locale, e.g., 'de'.</xd:detail>
    </xd:doc>

    <xsl:variable name="baseLanguage" select="if (contains($language, '-')) then substring-before($language, '-') else $language" as="xs:string"/>


    <xd:doc>
        <xd:short>Localization default language.</xd:short>
        <xd:detail>The default language, to be used when no message is available in the specified language. (A warning will be issued in this case.)</xd:detail>
    </xd:doc>

    <xsl:variable name="defaultLanguage" select="f:get-setting('defaultLanguage')" as="xs:string"/>
    <xsl:variable name="defaultBaseLanguage" select="if (contains($defaultLanguage, '-')) then substring-before($defaultLanguage, '-') else $defaultLanguage" as="xs:string"/>


    <xsl:function name="f:is-message-available" as="xs:boolean">
        <xsl:param name="name" as="xs:string"/>
        <xsl:sequence select="f:message($name) != '[### ' || $name || ' ###]'"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Find a localized message.</xd:short>
        <xd:detail>Function to find a localized message in the <code>messages.xml</code> file. This function will first try to find the message
        in the exact locale, then in the base-language, then the fall-back language, and, if this also fails, in the default locale.</xd:detail>
    </xd:doc>

    <xsl:function name="f:message" as="xs:string">
        <xsl:param name="name" as="xs:string"/>

        <xsl:variable name="msg" select="$messages/msg:messages/msg:message[@name=$name]"/>
        <xsl:variable name="fallbackLanguage" select="($messages/msg:messages[lang($baseLanguage)])[1]/@fallback" as="xs:string?"/>

        <xsl:variable name="fallbackLanguage" select="if ($fallbackLanguage) then $fallbackLanguage else $defaultLanguage" as="xs:string"/>

        <xsl:choose>
            <xsl:when test="$msg[lang($language)][1]">
                <xsl:apply-templates select="$msg[lang($language)][1]" mode="formatMessage"/>
                <xsl:copy-of select="f:log-debug('{1}: {2} = {3}', ($language, $name, $msg[lang($language)][1]))"/>
            </xsl:when>
            <xsl:when test="$msg[lang($baseLanguage)][1]">
                <xsl:apply-templates select="$msg[lang($baseLanguage)][1]" mode="formatMessage"/>
                <xsl:copy-of select="f:log-debug('{1}: {2} = {3}', ($baseLanguage, $name, $msg[lang($baseLanguage)][1]))"/>
            </xsl:when>
            <xsl:when test="$msg[lang($fallbackLanguage)][1]">
                <xsl:copy-of select="f:log-warning('Message {1} not available in locale {2}, using {3} instead.', ($name, $language, $fallbackLanguage))"/>
                <xsl:apply-templates select="$msg[lang($fallbackLanguage)][1]" mode="formatMessage"/>
                <xsl:copy-of select="f:log-debug('{1}: {2} = {3}', ($fallbackLanguage, $name, $msg[lang($fallbackLanguage)][1]))"/>
            </xsl:when>
            <xsl:when test="$msg[lang($defaultLanguage)][1]">
                <xsl:copy-of select="f:log-warning('Message {1} not available in locale {2}, using {3} instead.', ($name, $language, $defaultLanguage))"/>
                <xsl:apply-templates select="$msg[lang($defaultLanguage)][1]" mode="formatMessage"/>
                <xsl:copy-of select="f:log-debug('{1}: {2} = {3}', ($defaultLanguage, $name, $msg[lang($defaultLanguage)][1]))"/>
            </xsl:when>
            <xsl:when test="$msg[lang($defaultBaseLanguage)][1]">
                <xsl:copy-of select="f:log-warning('Message {1} not available in locale {2}, using {3} instead.', ($name, $language, $defaultBaseLanguage))"/>
                <xsl:apply-templates select="$msg[lang($defaultBaseLanguage)][1]" mode="formatMessage"/>
                <xsl:copy-of select="f:log-debug('{1}: {2} = {3}', ($defaultBaseLanguage, $name, $msg[lang($defaultBaseLanguage)][1]))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="f:log-error('Unknown message {1}.', ($name))"/>
                <xsl:text expand-text="yes">[### {$name} ###]</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function> 


    <xd:doc>
        <xd:short>Format a localized message.</xd:short>
        <xd:detail>Function to find and format a localized message in the <code>messages.xml</code> file. This function will first try to find the message
        in the exact locale, then in the base-language, and, if this also fails, in the default locale. After finding it, it will apply the given
        parameters to it.</xd:detail>
    </xd:doc>

    <xsl:function name="f:format-message">
        <xsl:param name="name" as="xs:string"/>
        <xsl:param name="params" as="map(xs:string, item()*)"/>

        <xsl:variable name="msg" select="$messages/msg:messages/msg:message[@name=$name]"/>
        <xsl:variable name="fallbackLanguage" select="($messages/msg:messages[lang($baseLanguage)])[1]/@fallback" as="xs:string?"/>

        <xsl:variable name="fallbackLanguage" select="if ($fallbackLanguage) then $fallbackLanguage else $defaultLanguage"/>

        <xsl:choose>
            <xsl:when test="$msg[lang($language)][1]">
                <xsl:apply-templates select="$msg[lang($language)][1]" mode="formatMessage">
                    <xsl:with-param name="params" select="$params" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$msg[lang($baseLanguage)][1]">
                <xsl:apply-templates select="$msg[lang($baseLanguage)][1]" mode="formatMessage">
                    <xsl:with-param name="params" select="$params" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$msg[lang($fallbackLanguage)][1]">
                <xsl:apply-templates select="$msg[lang($fallbackLanguage)][1]" mode="formatMessage">
                    <xsl:with-param name="params" select="$params" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$msg[lang($defaultLanguage)][1]">
                <xsl:copy-of select="f:log-warning('Message {1} not available in locale {2}, using {3} instead.', ($name, $language, $defaultLanguage))"/>
                <xsl:apply-templates select="$msg[lang($defaultLanguage)][1]" mode="formatMessage">
                    <xsl:with-param name="params" select="$params" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="f:log-error('Unknown message {1}.', ($name))"/>
                <xsl:text expand-text="yes">[### {$name} ###]</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xd:doc>
        <xd:short>Handle a localized message.</xd:short>
        <xd:detail>Apply the parameters to the selected message. Make sure that we drop namespaces inherited from the
        <code>messages.xml</code> file from the message loaded.</xd:detail>
    </xd:doc>

    <xsl:template match="msg:message" mode="formatMessage">
        <xsl:variable name="formattedMessage">
            <xsl:apply-templates mode="formatMessage"/>
        </xsl:variable>
        <xsl:copy-of select="$formattedMessage" copy-namespaces="no"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Copy element in a localized message.</xd:short>
        <xd:detail>The element is supposed to be suitable for the output format, that is HTML or XHTML.</xd:detail>
    </xd:doc>

    <xsl:template match="*" mode="formatMessage">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="formatMessage"/>
        </xsl:copy>
    </xsl:template>


    <xd:doc>
        <xd:short>Insert a parameter in a localized message.</xd:short>
        <xd:detail>Template to insert a parameter in a localized message. The parameter is looked-up in the list of parameters supplied
        to the FormatMessage template invocation. If no parameter was supplied, but the message requires one, a warning will be issued.</xd:detail>
    </xd:doc>

    <xsl:template match="msg:param" mode="formatMessage">
        <xsl:param name="params" as="map(xs:string, item()*)" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$params(@name)">
                <xsl:value-of select="$params(@name)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="f:log-error('No value specified for parameter {1}.', (@name))"/>
                <xsl:text expand-text="yes">[### {@name} ###]</xsl:text>
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
