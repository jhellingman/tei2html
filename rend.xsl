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
        <xd:short>Functions for dealing with rendition ladders</xd:short>
        <xd:detail>This stylesheet contains a number of functions to make dealing with rendition-ladders easier. rendition ladders are a string
        of key value pairs represented as follows: <code>key1(value1) key2(value2)</code>, etc.</xd:detail>
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

        <xsl:sequence select="matches($rend, concat('(^|\W)', $key, '\(.+?\)'), 'i')"/>
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
        <xd:short>Add (or update) a key-value-pair to a rendition ladder.</xd:short>
    </xd:doc>

    <xsl:function name="f:add-rend-value" as="xs:string">
        <xsl:param name="rend" as="xs:string?"/>
        <xsl:param name="key" as="xs:string"/>
        <xsl:param name="value" as="xs:string"/>

        <xsl:value-of select="normalize-space(f:remove-rend-value($rend, $key) || ' ' || $key || '(' || $value || ')')"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Add a class to the class key in a rendition ladder.</xd:short>
    </xd:doc>

    <xsl:function name="f:add-class" as="xs:string">
        <xsl:param name="rend" as="xs:string?"/>
        <xsl:param name="class" as="xs:string"/>

        <xsl:variable name="new-class" select="normalize-space(f:rend-value($rend, 'class') || ' ' || $class)"/>

        <!-- Remove possible duplicates -->
        <xsl:variable name="classes" select="tokenize($new-class, ' ')"/>
        <xsl:variable name="new-class">
            <xsl:for-each-group select="$classes" group-by=".">
                <xsl:sequence select="."/>
            </xsl:for-each-group>
        </xsl:variable>

        <xsl:value-of select="normalize-space(f:remove-rend-value($rend, 'class') || ' class(' || $new-class || ')')"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Remove a class from the class key in a rendition ladder.</xd:short>
    </xd:doc>

    <xsl:function name="f:remove-class" as="xs:string">
        <xsl:param name="rend" as="xs:string?"/>
        <xsl:param name="class" as="xs:string"/>

        <xsl:variable name="new-class" select="normalize-space(f:rend-value($rend, 'class'))"/>

        <!-- Remove the indicated class -->
        <xsl:variable name="classes" select="tokenize($new-class, ' ')"/>
        <xsl:variable name="new-class">
            <xsl:for-each select="$classes[. != $class]">
                <xsl:sequence select="."/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:value-of select="normalize-space(f:remove-rend-value($rend, 'class') || ' class(' || $new-class || ')')"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Adjust the given dimension in a rendition ladder by multiplying it with a factor.</xd:short>
    </xd:doc>

    <xsl:function name="f:adjust-dimension" as="xs:string?">
        <xsl:param name="rend" as="xs:string?"/>
        <xsl:param name="key" as="xs:string"/>
        <xsl:param name="factor" as="xs:double"/>

        <!-- <xsl:copy-of select="f:log-debug('Adjusting dimensions in rend attribute: {1}.', ($rend))"/> -->

        <xsl:variable name="dimension" select="f:rend-value($rend, $key)"/>
        <xsl:choose>
            <xsl:when test="$dimension != ''">
                <xsl:variable name="regex" select="'([0-9]+(\.[0-9]+)?)([a-z%]+)'" as="xs:string"/>
                <xsl:variable name="count" select="xs:double(replace($dimension, $regex, '$1'))" as="xs:double"/>
                <xsl:variable name="unit" select="replace($dimension, $regex, '$3')" as="xs:string"/>
                <xsl:variable name="new-value" select="concat($count * $factor, $unit)" as="xs:string"/>

                <xsl:copy-of select="f:log-debug('Value of {1}: {2}{3} becomes {4}.', ($key, xs:string($count), $unit, $new-value))"/>

                <xsl:value-of select="normalize-space(concat(f:remove-rend-value($rend, $key), ' ', $key, '(', $new-value, ')'))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$rend"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
