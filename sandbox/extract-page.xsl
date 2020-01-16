<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f xs xd"
    version="3.0">

    <xd:doc type="stylesheet">
        <xd:short>Extract a page from a TEI document.</xd:short>
        <xd:detail>
            <p>This stylesheet extracts a page from a TEI document, that is, all content between two pb-elements. This
            allows us to render the content of a page next to a facsimile of the page.</p>

            <p>This is somewhat more complicated than it appears at first because page-break elements are milestones,
            that do not follow any particular structure. To further complicate this, footnotes sometimes spread out
            over more than one page, and we only want the content that actually occurs on the page indicated, that is,
            including any content of footnotes on a previous page that is carried over to the page being extracted,
            and excluding parts of footnotes on the page being extracted that are carried over to following pages.</p>

            <p>We consider the page-break element at the start of the page part of the page (as it carries the number
            of the page in question); the page-break at the end is not part of the page.</p>

            <p>In some cases, we may also have to deal with repeated table-headers, which, in our practice, are removed
            from pages. We will need to restore those at the beginning of the page if the page-break occurs in the middle
            of a table (yet TODO). We won't deal with more degenerative cases, such as nested footnotes overflowing, or
            tables being spread over multiple pages (those are simply treated as a single page).</p>
        </xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2020, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xsl:output
        method="xml"
        indent="yes"
        encoding="utf-8"/>


    <xd:doc>
        <xd:short>Extract a single page based on its position (count of non-footnote page-breaks).</xd:short>
    </xd:doc>

    <xsl:function name="f:extract-page-by-position">
        <xsl:param name="text" as="node()"/>
        <xsl:param name="page" as="xs:integer"/>

        <xsl:copy-of select="f:extract-page($text, ($text//pb[not(f:inside-footnote(.))])[position() = $page])"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Extract a single page based on its number (@n-attribute; first occurence will be used).</xd:short>
    </xd:doc>

    <xsl:function name="f:extract-page-by-number">
        <xsl:param name="text" as="node()"/>
        <xsl:param name="page-number" as="xs:string"/>

        <xsl:copy-of select="f:extract-page($text, ($text//pb[not(f:inside-footnote(.))])[@n = $page-number][1])"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Extract the page after the given page-break element.</xd:short>
    </xd:doc>

    <xsl:function name="f:extract-page" as="node()">
        <xsl:param name="text" as="node()"/>
        <xsl:param name="first" as="element(pb)"/>

        <xsl:variable name="last" select="$first/following::pb[not(f:inside-footnote(.))][1]"/>

        <xsl:apply-templates select="$text" mode="f-extract-page">
            <xsl:with-param name="first" select="$first" tunnel="yes"/>
            <xsl:with-param name="last" select="$last" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:function>


    <xd:doc>
        <xd:short>Only retain elements that are between the first and last give pages (or contain one of these).</xd:short>
    </xd:doc>

    <xsl:template mode="f-extract-page" match="* | node()">
            <xsl:param name="first" as="element(pb)" tunnel="yes"/>
            <xsl:param name="last" as="element(pb)?" tunnel="yes"/>

        <xsl:variable name="after-first" as="xs:boolean" select=". >> $first or . is $first"/>
        <xsl:variable name="not-after-next" as="xs:boolean" select="if ($last) then . &lt;&lt; $last else true()"/>
        <xsl:variable name="contains-first" as="xs:boolean" select="if (.//pb[. is $first]) then true() else false()"/>
        <xsl:variable name="include" as="xs:boolean" select="$after-first and $not-after-next or $contains-first"/>

        <!-- Current node is inside a footnote on this page, but after a pb inside the footnote -->
        <xsl:variable name="in-footnote-overflow" as="xs:boolean" select="if ($include and f:inside-footnote(.)) then f:in-footnote-overflow(.) else false()"/>
        <xsl:variable name="include" as="xs:boolean" select="$include and not($in-footnote-overflow)"/>

        <!-- Current node is inside a footnote on a previous page, and after a pb in the footnote, making it overflow to this page -->
        <xsl:variable name="in-preceding-footnote-overflow" as="xs:boolean"
            select="if (. &lt;&lt; $first and f:inside-footnote(.)) then f:in-preceding-footnote-overflow(., $first) else false()"/>
        <xsl:variable name="include" as="xs:boolean" select="$include or $in-preceding-footnote-overflow"/>

        <!-- Current node contains footnote content that overflows into this page -->
        <xsl:variable name="is-preceding-overflowing-footnote" as="xs:boolean"
            select="if (. &lt;&lt; $first and local-name(.) = 'note') then f:is-preceding-overflowing-footnote(., $first) else false()"/>
        <xsl:variable name="include" as="xs:boolean" select="$include or $is-preceding-overflowing-footnote"/>

        <!-- Copy elements and text on given page -->
        <xsl:choose>
            <xsl:when test="$include">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates mode="f-extract-page"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="f-extract-page"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Determine whether a node overflows to the given page from a preceding footnote.</xd:short>
    </xd:doc>

    <xsl:function name="f:in-preceding-footnote-overflow" as="xs:boolean">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="first" as="element(pb)"/>

        <xsl:variable name="parent-footnote" as="element(note)" select="$node/ancestor-or-self::note[f:is-footnote(.)][1]"/>

        <!-- how many page-breaks between the parent footnote and the page-break in $first? -->
        <xsl:variable name="count-pb" select="count(($parent-footnote/following::pb)[not(f:inside-footnote(.))][. &lt;&lt; $first])"/>
        <xsl:variable name="inner-first" as="element(pb)?" select="$parent-footnote//pb[$count-pb + 1]"/>
        <xsl:variable name="inner-last" as="element(pb)?" select="$parent-footnote//pb[$count-pb + 2]"/>

        <xsl:variable name="after-inner-first" select="if ($inner-first) then $node >> $inner-first or $node is $inner-first else false()"/>
        <xsl:variable name="not-after-inner-last" select="if ($inner-last) then $node &lt;&lt; $inner-last else true()"/>

        <xsl:sequence select="$after-inner-first and $not-after-inner-last"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine whether a footnote contains content that overflows to the given page.</xd:short>
    </xd:doc>

    <xsl:function name="f:is-preceding-overflowing-footnote" as="xs:boolean">
        <xsl:param name="note" as="element(note)"/>
        <xsl:param name="first" as="element(pb)"/>

        <xsl:variable name="count-pb" select="count(($note/following::pb)[not(f:inside-footnote(.))][. &lt;&lt; $first])"/>
        <xsl:sequence select="if ($note//pb[$count-pb + 1]) then true() else false()"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine whether a node in a footnote overflows to a following page.</xd:short>
    </xd:doc>

    <xsl:function name="f:in-footnote-overflow" as="xs:boolean">
        <xsl:param name="node" as="node()"/>

        <xsl:variable name="parent-footnote" as="element(note)" select="$node/ancestor-or-self::note[f:is-footnote(.)][1]"/>
        <xsl:variable name="last" as="element(pb)?" select="$parent-footnote//pb[1]"/>

        <xsl:sequence select="if ($last) then $node >> $last or $node is $last else false()"/>
    </xsl:function>


    <!-- From notes.xsl -->
    <xsl:function name="f:is-footnote" as="xs:boolean">
        <xsl:param name="note" as="element(note)"/>
        <xsl:sequence select="$note/@place = ('foot', 'unspecified') or not($note/@place)"/>
    </xsl:function>

    <!-- From references.xsl -->
    <xsl:function name="f:inside-footnote" as="xs:boolean">
        <xsl:param name="targetNode" as="node()"/>

        <xsl:sequence select="if ($targetNode/ancestor-or-self::note[f:is-footnote(.)]) then true() else false()"/>
    </xsl:function>

</xsl:stylesheet>
