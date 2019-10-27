<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f xd xhtml xs">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to handle logging.</xd:short>
        <xd:detail>This stylesheet handles logging in a somewhat more flexible way than is possible with the xsl:message instruction.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2016, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:function name="f:log-error">
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>
        <xsl:copy-of select="f:log-message('error', $message, $params)"/>
    </xsl:function>

    <xsl:function name="f:format-error" as="xs:string">
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>
        <xsl:copy-of select="f:format-log-message('error', $message, $params)"/>
    </xsl:function>

    <xsl:function name="f:log-warning">
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>
        <xsl:copy-of select="f:log-message('warning', $message, $params)"/>
    </xsl:function>

    <xsl:function name="f:format-warning" as="xs:string">
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>
        <xsl:copy-of select="f:format-log-message('warning', $message, $params)"/>
    </xsl:function>

    <xsl:function name="f:log-info">
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>
        <xsl:copy-of select="f:log-message('info', $message, $params)"/>
    </xsl:function>

    <xsl:function name="f:format-info" as="xs:string">
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>
        <xsl:copy-of select="f:format-log-message('info', $message, $params)"/>
    </xsl:function>

    <xsl:function name="f:log-debug">
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>
        <xsl:if test="f:is-set('debug')">
            <xsl:copy-of select="f:log-message('debug', $message, $params)"/>
        </xsl:if>
    </xsl:function>

    <xsl:function name="f:format-debug" as="xs:string">
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>
        <xsl:copy-of select="f:format-log-message('debug', $message, $params)"/>
    </xsl:function>

    <xsl:function name="f:log-message">
        <xsl:param name="level" as="xs:string"/>
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>

        <xsl:variable name="formatted" select="f:format-log-message($level, $message, $params)"/>
        <xsl:message><xsl:value-of select="$formatted"/></xsl:message>
    </xsl:function>

    <xsl:function name="f:format-log-message" as="xs:string">
        <xsl:param name="level" as="xs:string"/>
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>
        <xsl:value-of select="upper-case($level) || ': ' || f:formatString($message, $params)"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Format a string with numbered parameters.</xd:short>
        <xd:detail>Format a string. Replace parameter-placeholders in the message string like {1} {2} {3} to the matching value in the <code>$param</code> sequence.</xd:detail>
    </xd:doc>

    <xsl:function name="f:formatString" as="xs:string">
        <xsl:param name="message" as="xs:string"/>
        <xsl:param name="params" as="xs:string*"/>

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
