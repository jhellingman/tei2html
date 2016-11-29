<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f xd xs"
    version="2.0">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to handle logging.</xd:short>
        <xd:detail>This stylesheet handles logging in a somewhat more flexible way than is possible with the xsl:message instruction.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2016, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:function name="f:logError">
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>
        <xsl:copy-of select="f:logMessage('error', $message, $params)"/>
    </xsl:function>

    <xsl:function name="f:formatError" as="xs:string">
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>
        <xsl:copy-of select="f:formatLogMessage('error', $message, $params)"/>
    </xsl:function>

    <xsl:function name="f:logWarning">
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>
        <xsl:copy-of select="f:logMessage('warning', $message, $params)"/>
    </xsl:function>

    <xsl:function name="f:formatWarning" as="xs:string">
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>
        <xsl:copy-of select="f:formatLogMessage('warning', $message, $params)"/>
    </xsl:function>

    <xsl:function name="f:logInfo">
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>
        <xsl:copy-of select="f:logMessage('info', $message, $params)"/>
    </xsl:function>

    <xsl:function name="f:formatInfo" as="xs:string">
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>
        <xsl:copy-of select="f:formatLogMessage('info', $message, $params)"/>
    </xsl:function>

    <xsl:function name="f:logDebug">
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>
        <xsl:if test="f:isSet('debug')">
            <xsl:copy-of select="f:logMessage('debug', $message, $params)"/>
        </xsl:if>
    </xsl:function>

    <xsl:function name="f:formatDebug" as="xs:string">
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>
        <xsl:copy-of select="f:formatLogMessage('debug', $message, $params)"/>
    </xsl:function>

    <xsl:function name="f:logMessage">
        <xsl:param name="level" as="xs:string"/>
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>

        <xsl:variable name="formatted" select="f:formatLogMessage($level, $message, $params)"/>
        <xsl:message><xsl:value-of select="$formatted"/></xsl:message>
    </xsl:function>

    <xsl:function name="f:formatLogMessage" as="xs:string">
        <xsl:param name="level" as="xs:string"/>
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>
        <xsl:value-of select="concat(upper-case($level), ': ', f:formatString($message, $params))"/>
    </xsl:function>

    <xsl:function name="f:formatString" as="xs:string">
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>

        <!-- replace parameters in the message string like {1} {2} {3} to the matching value in the $param sequence -->
        <xsl:variable name="formatted">
            <xsl:analyze-string select="$message" regex="\{{([0-9]+)\}}">
                <xsl:matching-substring>
                    <xsl:variable name="index" select="xs:integer(regex-group(1))" as="xs:integer"/>
                    <xsl:value-of select="$params[$index]"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>

        <xsl:value-of select="$formatted"/>
    </xsl:function>

</xsl:stylesheet>
