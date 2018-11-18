<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:i="http://gutenberg.ph/issues"
    xmlns:msg="http://www.gutenberg.ph/2006/schemas/messages"
    xmlns:s="http://gutenberg.ph/segments"
    xmlns:tmp="urn:temporary"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="i f msg s tmp xd xhtml xs">


    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to deal with numbers.</xd:short>
        <xd:copyright>2018, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xsl:function name="f:isInteger" as="xs:boolean" visibility="public">
        <xsl:param name="string"/>

        <xsl:sequence select="matches(string($string), '^[\d]+$', 'i')"/>
    </xsl:function>


    <xsl:function name="f:isRoman" as="xs:boolean" visibility="public">
        <xsl:param name="string"/>

        <xsl:sequence select="string-length($string) != 0 and matches($string, '^M{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$', 'i')"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Convert a Roman number to an integer.</xd:short>
        <xd:detail>
            <p>Convert a Roman number to an integer. This function calls a recursive implementation, which
            establishes the value of the first letter, and then adds or subtracts that value to/from the
            value of the tail, depending on whether the next character represent a higher or lower
            value.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:fromRoman" as="xs:integer" visibility="public">
        <xsl:param name="roman" as="xs:string"/>

        <xsl:sequence select="f:fromRomanImplementation($roman, 0)"/>
    </xsl:function>


    <xsl:function name="f:fromRomanImplementation" as="xs:integer" visibility="private">
        <xsl:param name="roman" as="xs:string"/>
        <xsl:param name="value" as="xs:integer"/>

        <xsl:variable name="length" select="string-length($roman)"/>

        <xsl:choose>
            <xsl:when test="not($length) or $length = 0">
                <xsl:sequence select="$value"/>
            </xsl:when>

            <xsl:when test="$length = 1">
                <xsl:sequence select="$value + f:romanValue($roman)"/>
            </xsl:when>

            <xsl:otherwise>
                <xsl:variable name="headValue" select="f:romanValue(substring($roman, 1, 1))"/>
                <xsl:variable name="tail" select="substring($roman, 2, $length - 1)"/>

                <xsl:sequence select="if ($headValue &lt; f:romanValue(substring($roman, 2, 1)))
                    then f:fromRomanImplementation($tail, $value - $headValue)
                    else f:fromRomanImplementation($tail, $value + $headValue)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xsl:function name="f:romanValue" as="xs:integer" visibility="private">
        <xsl:param name="character" as="xs:string"/>

        <xsl:sequence select="(1, 5, 10, 50, 100, 500, 1000)[index-of(('I', 'V', 'X', 'L', 'C', 'D', 'M'), upper-case($character))]"/>
    </xsl:function>


</xsl:stylesheet>