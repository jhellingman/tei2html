<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:f="urn:stylesheet-functions"
    version="2.0"
    exclude-result-prefixes="f xs xd">

    <xd:doc type="stylesheet">
        <xd:short>Functions for dealing with rendition-ladders</xd:short>
        <xd:detail>This stylesheet contains a number of functions to make dealing with rendition-ladders easier.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2016, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xd:doc>
        <xd:short>Determine whether a rendition ladder contains a certain value.</xd:short>
        <xd:detail>
            <p>Determine whether a rendition ladder contains a certain value. This takes care of handling the case where a key is a substring of another key.</p>
        </xd:detail>
        <xd:param name="rend">The rendition ladder to be tested.</xd:param>
        <xd:param name="key">The key to look for.</xd:param>
    </xd:doc>

    <xsl:function name="f:has-rend-value" as="xs:boolean">
        <xsl:param name="rend" as="xs:string?"/>
        <xsl:param name="key" as="xs:string"/>

        <xsl:value-of select="matches($rend, concat('(^|\W)', $key, '\(.+?\)'), 'i')"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Find the value for a key in a rendition ladder.</xd:short>
        <xd:detail>
            <p>Find the value for a key in a rendition ladder. This takes care of handling the case where a key is a substring of another key.
            If the rendition ladder is empty or doesn't contain the key, the result will be an empty string.</p>
        </xd:detail>
        <xd:param name="rend">The rendition ladder to be tested.</xd:param>
        <xd:param name="key">The key to find the value for. This should be a string matching <code>/[a-z0-9-]+/</code>, as otherwise the regular expression constructed from it will fail.</xd:param>
    </xd:doc>

    <xsl:function name="f:rend-value" as="xs:string">
        <xsl:param name="rend" as="xs:string?"/>
        <xsl:param name="key" as="xs:string"/>

        <xsl:variable name="regex" select="concat('(^|\W)', $key, '\((.+?)\)')"/>

        <xsl:variable name="result">
            <xsl:choose>
                <xsl:when test="not($rend)"/>
                <xsl:otherwise>
                    <xsl:analyze-string select="$rend" regex="{$regex}" flags="i">
                        <xsl:matching-substring>
                            <xsl:value-of select="regex-group(2)"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="$result"/>
    </xsl:function>

    <xd:doc>
        <xd:short>Remove a key-value-pair from a rendition ladder.</xd:short>
    </xd:doc>

    <xsl:function name="f:remove-rend-value" as="xs:string">
        <xsl:param name="rend" as="xs:string?"/>
        <xsl:param name="key" as="xs:string"/>

        <xsl:variable name="regex" select="'([a-z][0-9a-z-]+)\((.+?)\)'"/>

        <xsl:variable name="result">
            <xsl:choose>
                <xsl:when test="not($rend)"/>
                <xsl:otherwise>
                    <xsl:analyze-string select="$rend" regex="{$regex}" flags="i">
                        <xsl:matching-substring>
                            <xsl:if test="regex-group(1) != $key">
                                <xsl:value-of select="regex-group(0)"/>
                                <xsl:text> </xsl:text>
                            </xsl:if>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="normalize-space($result)"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Add a class to the class key in a rendition ladder.</xd:short>
    </xd:doc>

    <xsl:function name="f:add-class" as="xs:string">
        <xsl:param name="rend" as="xs:string?"/>
        <xsl:param name="class" as="xs:string"/>

        <xsl:variable name="new-class" select="normalize-space(concat(f:rend-value($rend, 'class'), ' ', $class))"/>
        <xsl:value-of select="normalize-space(concat(f:remove-rend-value($rend, 'class'), ' class(', $new-class, ')'))"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Adjust the given dimension in a rendition ladder by multiplying it with a factor.</xd:short>
    </xd:doc>

    <xsl:function name="f:adjust-dimension" as="xs:string?">
        <xsl:param name="rend" as="xs:string?"/>
        <xsl:param name="key" as="xs:string"/>
        <xsl:param name="factor" as="xs:double"/>

        <!-- <xsl:message>ADJUST REND: <xsl:value-of select="$rend"/></xsl:message> -->

        <xsl:variable name="dimension" select="f:rend-value($rend, $key)"/>
        <xsl:choose>
            <xsl:when test="$dimension != ''">
                <xsl:variable name="regex" select="'([0-9]+(\.[0-9]+)?)([a-z%]+)'" as="xs:string"/>
                <xsl:variable name="count" select="xs:double(replace($dimension, $regex, '$1'))" as="xs:double"/>
                <xsl:variable name="unit" select="replace($dimension, $regex, '$3')" as="xs:string"/>
                <xsl:variable name="new-value" select="concat($count * $factor, $unit)" as="xs:string"/>

                <!-- <xsl:message>ADJUST <xsl:value-of select="$key"/>: <xsl:value-of select="$count"/><xsl:value-of select="$unit"/> to <xsl:value-of select="$new-value"/></xsl:message> -->
    
                <xsl:value-of select="normalize-space(concat(f:remove-rend-value($rend, $key), ' ', $key, '(', $new-value, ')'))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$rend"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
