<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="urn:stylesheet-functions"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="f xd xs">

    <xd:doc>
        <xd:short>Calculate the Levenshtein distance between two strings.</xd:short>
        <xd:detail>This stylesheet is based on the algorithm given by Jeni Tennison, see http://www.jenitennison.com/2007/05/06/levenshtein-distance-on-the-diagonal.html.</xd:detail>
    </xd:doc>

    <xsl:function name="f:levenshtein" as="xs:integer">
        <xsl:param name="a" as="xs:string"/>
        <xsl:param name="b" as="xs:string"/>

        <xsl:sequence select="if ($a = '') then string-length($b)
            else if ($b = '') then string-length($a)
            else f:calculate-levenshtein-distance(
                string-to-codepoints($a),
                string-to-codepoints($b),
                string-length($a),
                string-length($b),
                (1, 0, 1), 2)"/>
    </xsl:function>

    <xsl:function name="f:calculate-levenshtein-distance" as="xs:integer">
        <xsl:param name="chars1" as="xs:integer*"/>
        <xsl:param name="chars2" as="xs:integer*"/>
        <xsl:param name="length1" as="xs:integer"/>
        <xsl:param name="length2" as="xs:integer"/>
        <xsl:param name="lastDiag" as="xs:integer*"/>
        <xsl:param name="total" as="xs:integer"/>

        <xsl:variable name="shift" as="xs:integer" select="if ($total > $length2) then ($total - ($length2 + 1)) else 0"/>

        <xsl:variable name="diag" as="xs:integer*">
            <xsl:for-each select="max((0, $total - $length2)) to min(($total, $length1))">
                <xsl:variable name="i" as="xs:integer" select="."/>
                <xsl:variable name="j" as="xs:integer" select="$total - $i"/>
                <xsl:variable name="d" as="xs:integer" select="($i - $shift) * 2"/>

                <xsl:if test="$j &lt; $length2">
                    <xsl:sequence select="$lastDiag[$d - 1]"/>
                </xsl:if>
                <xsl:sequence select="if ($i = 0) then $j
                    else if ($j = 0) then $i
                    else min(($lastDiag[$d - 1] + 1, $lastDiag[$d + 1] + 1, $lastDiag[$d] + (if ($chars1[$i] eq $chars2[$j]) then 0 else 1)))"/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:sequence select="if ($total = $length1 + $length2) then exactly-one($diag)
            else f:calculate-levenshtein-distance($chars1, $chars2, $length1, $length2, $diag, $total + 1)"/>
    </xsl:function>

</xsl:stylesheet>
