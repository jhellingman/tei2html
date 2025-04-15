<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="urn:stylesheet-functions"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="f xd xs">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to generate plain text.</xd:short>
        <xd:copyright>2025, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:function name="f:split-into-lines" as="xs:string*">
        <xsl:param name="text" as="xs:string"/>
        <xsl:param name="max-length" as="xs:integer"/>

        <xsl:variable name="words" select="tokenize(normalize-space($text), '\s')" as="xs:string*"/>

        <xsl:iterate select="$words">
            <xsl:param name="current-line" select="''" as="xs:string"/>
            <xsl:param name="result" select="()" as="xs:string*"/>

            <xsl:on-completion select="if ($current-line != '') then ($result, $current-line) else $result"/>

            <xsl:variable name="next-word" select="."/>
            <xsl:variable name="next-line" select="if ($current-line = '') then $next-word else $current-line || ' ' || $next-word"/>

            <xsl:choose>
                <xsl:when test="string-length($next-line) le $max-length">
                    <!-- Word fits, continue accumulating -->
                    <xsl:next-iteration>
                        <xsl:with-param name="current-line" select="$next-line"/>
                        <xsl:with-param name="result" select="$result"/>
                    </xsl:next-iteration>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Word doesn't fit, start new line -->
                    <xsl:next-iteration>
                        <xsl:with-param name="current-line" select="$next-word"/>
                        <xsl:with-param name="result" select="if ($current-line != '') then ($result, $current-line) else $result"/>   
                    </xsl:next-iteration>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:iterate>
    </xsl:function>

</xsl:stylesheet>