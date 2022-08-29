<xsl:stylesheet version="3.0"
                xmlns:s="http://gutenberg.ph/segments"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="s xd xs">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to split a TEI document into segments</xd:short>
        <xd:detail>This stylesheet split a TEI document into segments. This means that paragraphs, lines, and other
        elements are placed within a simpler structure of meaningful contexts, that can be used for
        analysis.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2012, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xd:doc mode="segments">
        <xd:short>Mode used to collect segments.</xd:short>
        <xd:detail>The generic segment-element will replace a range of higher-level structural elements, such as paragraphs.</xd:detail>
    </xd:doc>

    <xd:doc mode="flatten-segments">
        <xd:short>Mode used to flatten segments.</xd:short>
        <xd:detail>Segments are flattened by grouping segment and non-segment elements; the non-segments will be wrapped
            into a new segment, and the contained segments will be handled recursively.</xd:detail>
    </xd:doc>

    <xd:doc>
        <xd:short>Split a text into segments</xd:short>
        <xd:detail>Split a text into segments, in two steps:
        <ol>
            <li>Collect all segments in the document, to provide meaningful contexts.</li>
            <li>Flatten the segments.</li>
        </ol>
        </xd:detail>
    </xd:doc>

    <xsl:template mode="segmentize" match="/">
        <xsl:variable name="segments">
            <s:segment>
                <xsl:apply-templates mode="segments"/>
            </s:segment>
        </xsl:variable>

        <s:segments>
            <xsl:apply-templates mode="flatten-segments" select="$segments"/>
        </s:segments>
    </xsl:template>


    <xd:doc>
        <xd:short>Flatten segments.</xd:short>
        <xd:detail>Flatten segments, that is, make sure segments are not nested, and taking care the attributes on 
        the segment elements are retained.</xd:detail>
    </xd:doc>

    <xsl:template mode="flatten-segments" match="s:segment">
        <xsl:param name="attributes"/>

        <xsl:for-each-group select="node()" group-adjacent="not(self::s:segment)">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">

                    <!-- Sequence of non-segment elements -->
                    <s:segment>
                        <xsl:copy-of select="$attributes"/>
                        <xsl:copy-of select="current-group()"/>
                    </s:segment>
                </xsl:when>
                <xsl:otherwise>

                    <!-- Sequence of segment elements -->
                    <xsl:for-each select="current-group()">
                        <xsl:apply-templates select="." mode="#current">
                            <xsl:with-param name="attributes" select="./@*"/>
                        </xsl:apply-templates>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>


    <xsl:template name="output-segments">
        <xsl:param name="segments" as="node()"/>

        <xsl:result-document
                doctype-public=""
                doctype-system=""
                href="segments.xml"
                method="xml"
                indent="yes"
                encoding="UTF-8">
            <xsl:message>INFO:    Generated file: segments.xml.</xsl:message>
            <xsl:copy-of select="$segments"/>
        </xsl:result-document>
    </xsl:template>


    <xd:doc>
        <xd:short>Ignore the TEI header.</xd:short>
        <xd:detail>Ignore the TEI header, as we are not interested in the words that appear there.</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="teiHeader"/>


    <xd:doc>
        <xd:short>Ignore the TeX Formulas.</xd:short>
        <xd:detail>Ignore the TeX Formulas, we cannot deal with that notation.</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="formula[@notation='TeX']">
        <xsl:variable name="lang" select="(ancestor-or-self::*/@lang|ancestor-or-self::*/@xml:lang)[last()]"/>
        <xsl:variable name="page" as="xs:string">
            <xsl:value-of select="(preceding::pb[@n]/@n)[last()]"/>
        </xsl:variable>

        <s:segment sourceElement="{name()}" sourcePage="{$page}">
            <xsl:copy-of select="@*"/>
            <xsl:if test="not(@lang)">
                <xsl:attribute name="lang"><xsl:value-of select="$lang"/></xsl:attribute>
            </xsl:if>
            <xsl:text>[TeX-formula]</xsl:text>
        </s:segment>
    </xsl:template>


    <xd:doc>
        <xd:short>Ignore notes.</xd:short>
        <xd:detail>Ignore notes. Notes will be lifted from their context, and handled separately.</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="note"/>


    <xd:doc>
        <xd:short>Ignore sic elements in choice.</xd:short>
        <xd:detail>Ignore sic elements in choice. These are typically erroneous text, and should be ignored.</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="choice/sic"/>


    <xd:doc>
        <xd:short>Insert space between orig and reg in choice.</xd:short>
    </xd:doc>

    <xsl:template mode="segments" match="choice[orig]">
        <xsl:apply-templates mode="segments" select="orig"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates mode="segments" select="reg"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Ignore forms work elements.</xd:short>
        <xd:detail>Ignore forms work elements. These are typically running headers, and should be handled separately (TODO).</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="fw"/>


    <xd:doc>
        <xd:short>Insert seg-elements that are copied.</xd:short>
        <xd:detail>Insert seg-elements that are copied. The (presented) content of these is identical to content elsewhere; the actual content is typically only ditto marks.</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="seg[@copyOf]">
        <xsl:variable name="copyOf" select="@copyOf"/>
        <xsl:apply-templates mode="segments" select="seg[@id=$copyOf]"/>
    </xsl:template>


    <xd:doc mode="segment-notes">
        <xd:short>Mode used to lift notes out of their context.</xd:short>
        <xd:detail>Mode used to lift notes out of their context, into a separate context.</xd:detail>
    </xd:doc>

    <xd:doc>
        <xd:short>Segmentize the text.</xd:short>
        <xd:detail>Segmentize the text. Here we also handle the notes separately.</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="*[self::TEI.2 or self::TEI]/text">
        <xsl:apply-templates mode="#current"/>
        <xsl:apply-templates mode="segment-notes" select="/*[self::TEI.2 or self::TEI]/text//note"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Segmentize notes.</xd:short>
        <xd:detail>Segmentize notes. Special handling at this level only, can use mode <code>segments</code> for elements inside notes.</xd:detail>
    </xd:doc>

    <xsl:template mode="segment-notes" match="note">

        <xsl:variable name="lang" select="(ancestor-or-self::*/@lang|ancestor-or-self::*/@xml:lang)[last()]"/>
        <xsl:variable name="page" as="xs:string">
            <xsl:value-of select="(preceding::pb[@n]/@n)[last()]"/>
        </xsl:variable>

        <s:segment sourceElement="{name()}" sourcePage="{$page}">
            <xsl:copy-of select="@*"/>
            <xsl:if test="not(@lang)">
                <xsl:attribute name="lang"><xsl:value-of select="$lang"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates mode="segments"/>
        </s:segment>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle high-level structure.</xd:short>
        <xd:detail>Handle high-level structure. These are typically further divided in segments, so we need not introduce a segment for them.</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="front | back | body | div0 | div1 | div2 | div3 | div4 | div5 | div6 | div7 | table | row">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle segment structure.</xd:short>
        <xd:detail>Introduce a segment for each of these elements that contain text.</xd:detail>
    </xd:doc>

    <!-- For HTML use: "p | h1 | h2 | h3 | h4 | h5 | h6 | li | th | td" -->
    <xsl:template mode="segments" match="p | seg | head | cell | item | castItem | lg | sp | titlePage | stage | speaker | docTitle | titlePart | byline | docAuthor | docImprint">

        <xsl:variable name="lang" select="(ancestor-or-self::*/@lang|ancestor-or-self::*/@xml:lang)[last()]"/>
        <xsl:variable name="page" as="xs:string">
            <xsl:value-of select="(preceding::pb[@n]/@n)[last()]"/>
        </xsl:variable>

        <s:segment sourceElement="{name()}" sourcePage="{$page}">
            <xsl:copy-of select="@*"/>
            <xsl:if test="not(@lang)">
                <xsl:attribute name="lang"><xsl:value-of select="$lang"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates mode="#current"/>
        </s:segment>
    </xsl:template>

    <!-- Introduce spaces around lines of verse. -->
    <xsl:template mode="segments" match="l">
        <xsl:text> </xsl:text>
        <xsl:apply-templates mode="#current"/>
        <xsl:text> </xsl:text>
    </xsl:template>

</xsl:stylesheet>
