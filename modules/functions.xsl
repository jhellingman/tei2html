<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:f="urn:stylesheet-functions"
    exclude-result-prefixes="f xs xd">


    <xd:doc type="stylesheet">
        <xd:short>Utility functions, used by tei2html</xd:short>
        <xd:detail>This stylesheet contains several utility functions, used by tei2html and tei2epub.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2021, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Normalize a file name received as a parameter.</xd:short>
    </xd:doc>

    <xsl:function name="f:normalize-filename" as="xs:string?">
        <xsl:param name="filename" as="xs:string?"/>
        <xsl:value-of select="replace(normalize-space($filename), '^file:/', '')"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Get the current UTC-time in a string.</xd:short>
        <xd:detail>
            <p>Get the current UTC-time in a string, format "YYYY-MM-DDThh:mm:ssZ"</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:utc-timestamp" as="xs:string">
        <xsl:variable name="utc-timestamp" select="adjust-dateTime-to-timezone(current-dateTime(), xs:dayTimeDuration('PT0H'))"/>
        <xsl:value-of select="format-dateTime($utc-timestamp, '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/>
    </xsl:function>

    <xsl:function name="f:utc-datetime" as="xs:string">
        <xsl:variable name="utc-datetime" select="adjust-dateTime-to-timezone(current-dateTime(), xs:dayTimeDuration('PT0H'))"/>
        <xsl:value-of select="format-dateTime($utc-datetime, '[Y0001]-[M01]-[D01] [H01]:[m01]:[s01] UTC')"/>
    </xsl:function>



    <xd:doc>
        <xd:short>Determine a string has a valid value.</xd:short>
        <xd:detail>
            <p>Determine a string has a valid value, that is, not null, empty or '#####'</p>
        </xd:detail>
        <xd:param name="value" type="string">The value to be tested.</xd:param>
    </xd:doc>

    <xsl:function name="f:is-valid" as="xs:boolean">
        <xsl:param name="value" as="xs:string?"/>
        <xsl:sequence select="$value and not($value = '' or $value = '#####')"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Provide a default value when a value is null.</xd:short>
        <xd:param name="value" type="string">The value to be tested.</xd:param>
        <xd:param name="default" type="string">The default value.</xd:param>
    </xd:doc>

    <xsl:function name="f:if-null">
        <xsl:param name="value"/>
        <xsl:param name="default"/>
        <xsl:sequence select="if (not($value)) then $default else $value"/>
    </xsl:function>

</xsl:stylesheet>
