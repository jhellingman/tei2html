<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="f fn xd xs"
    >

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to segmentize a TEI document</xd:short>
        <xd:detail>This stylesheet segmentizes a TEI document. This means that paragraphs, lines, and other
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
        <xd:detail>Segments are flattened by grouping segment and non-segment elements; the non-segments will be wrapped into a new segment, and the contained segments will be handled recursively.</xd:detail>
    </xd:doc>

    <xd:doc>
        <xd:short>Segmentize a text</xd:short>
        <xd:detail>Split a text into segments, in two steps:
        <ol>
            <li>Collect all segments in the document, to provide meaningful contexts.</li>
            <li>Flatten the segments.</li>
        </ol>
        </xd:detail>
    </xd:doc>

    <xsl:template name="segmentize">
        <xsl:variable name="segments">
            <segment>
                <xsl:apply-templates mode="segments"/>
            </segment>
        </xsl:variable>

        <segments>
            <xsl:apply-templates mode="flatten-segments" select="$segments"/>
        </segments>
    </xsl:template>


    <xd:doc>
        <xd:short>Flatten segments.</xd:short>
        <xd:detail>Flatten segments, that is, make sure segments are not nested, and taking care the attributes on 
        the segment elements are retained.</xd:detail>
    </xd:doc>

    <xsl:template mode="flatten-segments" match="segment">
        <xsl:param name="attributes"/>

        <xsl:for-each-group select="node()" group-adjacent="not(self::segment)">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <!-- Sequence of non-segment elements -->
                    <segment>
                        <xsl:copy-of select="$attributes"/>
                        <xsl:copy-of select="current-group()"/>
                    </segment>
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
            <xsl:message terminate="no">INFO:    generated file: segments.xml.</xsl:message>
            <xsl:copy-of select="$segments"/>
        </xsl:result-document>
    </xsl:template>


    <xd:doc>
        <xd:short>Ignore the TEI header.</xd:short>
        <xd:detail>Ignore the TEI header, as we are not interested in the words that appear there.</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="teiHeader"/>

    <xd:doc>
        <xd:short>Ignore notes.</xd:short>
        <xd:detail>Ignore notes. Notes will be lifted from their context, and handled separately.</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="note"/>


    <xd:doc mode="segment-notes">
        <xd:short>Mode used to lift notes out of their context.</xd:short>
        <xd:detail>Mode used to lift notes out of their context, into a separate context.</xd:detail>
    </xd:doc>

    <xd:doc>
        <xd:short>Segmentize the text.</xd:short>
        <xd:detail>Segmentize the text. Here we also handle the notes separately.</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="TEI.2/text">
        <xsl:apply-templates mode="#current"/>
        <xsl:apply-templates mode="segment-notes" select="/TEI.2/text//note"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Segmentize notes.</xd:short>
        <xd:detail>Segmentize notes. Special handling at this level only, can use mode <code>segments</code> for elements inside notes.</xd:detail>
    </xd:doc>

    <xsl:template mode="segment-notes" match="note">
        <segment sourceElement="{name()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="segments"/>
        </segment>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle high-level structure.</xd:short>
        <xd:detail>Handle high-level structure. These are typically further divided in segments, so we need not introduce a segment for them.</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="front | back | body | div0 | div1 | div2 | div3 | div4 | div5 | div6 | lg | table | row | sp">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle segment structure.</xd:short>
        <xd:detail>Introduce a segment for each of these elements that contain text.</xd:detail>
    </xd:doc>

    <!-- For HTML use: "p | h1 | h2 | h3 | h4 | h5 | h6 | li | th | td" -->
    <xsl:template mode="segments" match="p | head | cell | l | item | titlePage | stage | speaker | docTitle | titlePart | byline | docAuthor | docImprint">
        <segment sourceElement="{name()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </segment>
    </xsl:template>


</xsl:stylesheet>
