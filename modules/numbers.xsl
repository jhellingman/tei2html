<!DOCTYPE xsl:stylesheet [

    <!ENTITY mdash       "&#x2014;">
    <!ENTITY ndash       "&#x2013;">
    <!ENTITY hellip      "&#x2026;">

]>
<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="urn:stylesheet-functions"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="f xd xs">


    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to deal with numbers.</xd:short>
        <xd:copyright>2018, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xsl:function name="f:is-integer" as="xs:boolean" visibility="public">
        <xsl:param name="string"/>

        <xsl:sequence select="matches(string($string), '^[\d]+$', 'i')"/>
    </xsl:function>


    <xsl:variable name="unicode-number-pattern" select="'^\s?(((\p{Nd}+[.,])*\p{Nd}+)(([.,]\p{Nd}+)?(\p{No})?)|(\p{No})|([.,]\p{Nd}+))\s?$'"/>

    <xsl:function name="f:is-unicode-number" as="xs:boolean">
        <xsl:param name="string"/>

        <xsl:sequence select="matches(string($string), $unicode-number-pattern, 'i')"/>
    </xsl:function>


    <xsl:function name="f:is-dash-like" as="xs:boolean">
        <xsl:param name="string"/>

        <xsl:sequence select="matches(string($string), '^([&mdash;&ndash;&hellip;-]|(\.\.\.+))$', 'i')"/>
    </xsl:function>


    <xsl:function name="f:is-roman" as="xs:boolean" visibility="public">
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

    <xsl:function name="f:from-roman" as="xs:integer" visibility="public">
        <xsl:param name="roman" as="xs:string"/>

        <xsl:sequence select="f:from-roman-implementation($roman, 0)"/>
    </xsl:function>


    <xsl:function name="f:from-roman-implementation" as="xs:integer" visibility="private">
        <xsl:param name="roman" as="xs:string"/>
        <xsl:param name="value" as="xs:integer"/>

        <xsl:variable name="length" select="string-length($roman)"/>

        <xsl:choose>
            <xsl:when test="not($length) or $length = 0">
                <xsl:sequence select="$value"/>
            </xsl:when>

            <xsl:when test="$length = 1">
                <xsl:sequence select="$value + f:roman-value($roman)"/>
            </xsl:when>

            <xsl:otherwise>
                <xsl:variable name="headValue" select="f:roman-value(substring($roman, 1, 1))"/>
                <xsl:variable name="tail" select="substring($roman, 2, $length - 1)"/>

                <xsl:sequence select="if ($headValue &lt; f:roman-value(substring($roman, 2, 1)))
                    then f:from-roman-implementation($tail, $value - $headValue)
                    else f:from-roman-implementation($tail, $value + $headValue)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xsl:function name="f:roman-value" as="xs:integer" visibility="private">
        <xsl:param name="character" as="xs:string"/>

        <xsl:sequence select="(1, 5, 10, 50, 100, 500, 1000)[index-of(('I', 'V', 'X', 'L', 'C', 'D', 'M'), upper-case($character))]"/>
    </xsl:function>


</xsl:stylesheet>