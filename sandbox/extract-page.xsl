<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f xs xd"
    version="3.0">

    <xd:doc type="stylesheet">
        <xd:short>Extract page from a TEI document.</xd:short>
        <xd:detail>
            <p>This stylesheet extracts a page from a TEI document, that is, all content between two pb-elements.</p>

            <p>This is somewhat more complicated than it appears at first because page-break elements are milestones, that
            do not follow any particular structure, and
            sometimes footnotes spread out over more than one page, and we only want the content that actually occurs on
            the page indicated, that is, including any parts of footnotes on a previous page that are carried over to
            the page being extracted, and excluding parts of footnotes that have been carried over to following pages.</p>

            <p>To make the code to achieve this somewhat readable, we first pre-process the TEI document, such that
            page-breaks in footnotes use a different element (fnpb), and all page-breaks have a @p attribute, indicating
            their position (we clean this up later-on). Then we split-up the horrendous test required to achieve this
            into several parts.</p>
        </xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xsl:output
        method="xml"
        indent="yes"
        encoding="utf-8"/>


    <xd:doc type="string">Number of page to extract (based on @n attribute).</xd:doc>

    <xsl:param name="n" select="-1"/>


    <xd:doc type="string">Number of page following the page to extract, determined by code.</xd:doc>

    <xsl:variable name="m">
        <xsl:value-of select="//pb[not(ancestor::note)][@n=$n]/following::pb[not(ancestor::note)][1]/@n"/>
    </xsl:variable>


    <xd:doc type="string">Number of page to extract (based on position).</xd:doc>

    <xsl:param name="p" select="count(//pb[not(ancestor::note)][@n=$n]/preceding::pb[not(ancestor::note)])"/>

    <xsl:variable name="q">
        <xsl:value-of select="$p + 1"/>
    </xsl:variable>


    <xsl:function name="f:extract-page-by-position">
        <xsl:param name="text" as="node()"/>
        <xsl:param name="page" as="xs:integer"/>

        <xsl:copy-of select="f:extract-page($text, ($text//pb[not(f:inside-footnote(.))])[position() = $page])"/>
    </xsl:function>


    <xsl:function name="f:extract-page" as="node()">
        <xsl:param name="text" as="node()"/>
        <xsl:param name="first" as="element(pb)"/>

        <xsl:variable name="last" select="$first/following::pb[not(f:inside-footnote(.))][1]"/>

        <xsl:apply-templates select="$text" mode="f-extract-page">
            <xsl:with-param name="first" select="$first" tunnel="yes"/>
            <xsl:with-param name="last" select="$last" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:function>


    <xsl:template mode="f-extract-page" match="* | node()">
            <xsl:param name="first" as="element(pb)" tunnel="yes"/>
            <xsl:param name="last" as="element(pb)?" tunnel="yes"/>

        <!-- Current node is same as or after first -->
        <xsl:variable name="after-first" select=". >> $first or . is $first"/>

        <!-- Current node is same as or before last -->
        <xsl:variable name="not-after-next" select="if ($last) then . &lt;&lt; $last or . is $last else true()"/>

        <!-- Current node contains first -->
        <xsl:variable name="contains-first" select=".//pb[. is $first]"/>

        <!-- Current node is inside a footnote on this page, but after a pb inside the footnote -->
        <xsl:variable name="in-footnote-overflow" select="if ($after-first and $not-after-next and f:inside-footnote(.)) then f:in-footnote-overflow(.) else false()"/>

        <!-- Current node is inside a footnote on a previous page, and after a pb in the footnote, making it overflow to this page -->
        <xsl:variable name="in-preceding-footnote-overflow" select="if (. &lt;&lt; first and f:inside-footnote(.)) then f:in-preceding-footnote-overflow(., $first) else false()"/>

        <!-- Current node contains a footnote content that overflows into this page -->


        <!-- Copy elements and text on given page -->
        <xsl:choose>
            <xsl:when test="($after-first and $not-after-next or $contains-first) and not($in-footnote-overflow)">
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


    <xsl:function name="f:in-preceding-footnote-overflow" as="xs:boolean">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="first" as="element(pb)"/>

        <xsl:variable name="parent-footnote" as="element(note)" select="$node/ancestor-or-self::note[f:is-footnote(.)][1]"/>

        <!-- how many pb between $parent-footnote and $first? -->
        <xsl:variable name="count-pb" select="count(($parent-footnote/following::pb)[not(f:inside-footnote(.))][. &lt;&lt; $first])"/>
        <xsl:variable name="inner-first" as="element(pb)?" select="$parent-footnote//pb[$count-pb]"/>
        <xsl:variable name="inner-last" as="element(pb)?" select="$parent-footnote//pb[$count-pb + 1]"/>

        <xsl:variable name="after-inner-first" select="if ($inner-first) then $node >> $inner-first else false()"/>
        <xsl:variable name="not-after-inner-last" select="if ($inner-last) then $node &lt;&lt; $inner-last or $node is $inner-last else true()"/>

        <xsl:sequence select="$after-inner-first and $not-after-inner-last"/>
    </xsl:function>


    <xsl:function name="f:in-footnote-overflow" as="xs:boolean">
        <xsl:param name="node" as="node()"/>

        <xsl:variable name="parent-footnote" as="element(note)" select="$node/ancestor-or-self::note[f:is-footnote(.)][1]"/>
        <xsl:variable name="last" as="element(pb)?" select="$parent-footnote//pb[1]"/>

        <xsl:sequence select="if ($last) then $node >> $last else false()"/>
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




    <xsl:template match="/">

        <xsl:message>Extracting page '<xsl:value-of select="$n"/>' at position <xsl:value-of select="$p"/></xsl:message>

        <xsl:variable name="text">
            <xsl:apply-templates mode="preprocess"/>
        </xsl:variable>

        <xsl:variable name="text">
            <xsl:apply-templates select="$text" mode="countnotes"/>
        </xsl:variable>

        <xsl:variable name="page">
            <xsl:apply-templates select="$text" mode="extract-page-q"/>
        </xsl:variable>

        <xsl:variable name="page">
            <xsl:apply-templates select="$page" mode="cleanup"/>
        </xsl:variable>

        <xsl:copy-of select="$page"/>

    </xsl:template>


    <xsl:template mode="preprocess" match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates mode="preprocess" select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template mode="preprocess" match="pb[ancestor::note]">
        <fnpb>
            <xsl:apply-templates mode="preprocess" select="@*|node()"/>
        </fnpb>
    </xsl:template>




    <xsl:template mode="countnotes" match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates mode="countnotes" select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template mode="countnotes" match="pb">
        <xsl:copy>
            <xsl:attribute name="p" select="count(preceding::pb)"/>
            <xsl:apply-templates mode="countnotes" select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template mode="countnotes" match="fnpb">
        <xsl:copy>
            <xsl:attribute name="p" select="count(preceding::pb) + count(preceding::fnpb[./descendant::note])"/>
            <xsl:apply-templates mode="countnotes" select="@*|node()"/>
        </xsl:copy>
    </xsl:template>




    <xsl:template mode="cleanup" match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates mode="cleanup" select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template mode="cleanup" match="fnpb">
        <pb>
            <xsl:apply-templates mode="cleanup" select="@*|node()"/>
        </pb>
    </xsl:template>

    <xsl:template mode="cleanup" match="fnpb/@p | pb/@p"/>




    <xsl:template mode="extract-page-q" match="* | node()" priority="3">

        <!-- Content not after pb/@p=q -->
        <xsl:variable name="test" select="not(preceding::pb/@p=$q or self::pb/@p=$q)"/>

        <!-- Content after pb/@p=p -->
        <xsl:variable name="test" select="$test and ((self::* and descendant-or-self::pb/@p=$p) or preceding::pb/@p=$p)"/>

        <!-- Content in note and not after fnpb/@p=q -->
        <xsl:variable name="overflow" select="./ancestor::note and (preceding::fnpb/@p=$q or self::fnpb/@p=$q)"/>

        <!-- Exclude the overflow of notes on this page -->
        <xsl:variable name="test" select="$test and not($overflow)"/>

        <!-- Content in a preceding note might overflow into this page -->
        <xsl:variable name="previousoverflow" select="if ((ancestor::note or self::note) and following::pb/@p=$p) then true() else false()"/>

        <!-- Content in a note not after fnpb/@p=q -->
        <xsl:variable name="previousoverflow" select="$previousoverflow and not(preceding::fnpb/@p=$q or self::fnpb/@p=$q)"/>

        <!-- Content in a note after fnpb/@p=p -->
        <xsl:variable name="previousoverflow" select="$previousoverflow and ((self::* and descendant-or-self::fnpb/@p=$p) or preceding::fnpb/@p=$p)"/>

        <!-- We want the content of the current page and those of notes overflown into this page -->
        <xsl:variable name="test" select="$test or $previousoverflow"/>

        <!-- Copy elements and text on given page -->
        <xsl:choose>
            <xsl:when test="$test">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates mode="extract-page-q"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="extract-page-q"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>






    <!-- To make the below more readable, replace pb[not(ancestor::note)] with pb -->


    <xsl:template mode="extract-page" match="node()" priority="1"/>

    <xsl:template mode="extract-page" match="*[descendant-or-self::pb[not(ancestor::note)][count(preceding::pb[not(ancestor::note)])=$p]] | node()[preceding::pb[not(ancestor::note)][count(preceding::pb[not(ancestor::note)])=$p]]" priority="2">
         <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="extract-page"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template mode="extract-page" match="node()[preceding::pb[not(ancestor::note)][count(preceding::pb[not(ancestor::note)])=$q] or self::pb[not(ancestor::note)][count(preceding::pb[not(ancestor::note)])=$q]]" priority="3"/>




    <xsl:template mode="extract-page-n" match="node()" priority="1"/>

    <xsl:template mode="extract-page-n" match="*[descendant-or-self::pb[not(ancestor::note)][not(ancestor::note)]/@n=$n] | node()[preceding::pb[not(ancestor::note)][not(ancestor::note)]/@n=$n]" priority="2">
         <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="extract-page-n"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template mode="extract-page-n" match="node()[preceding::pb[not(ancestor::note)][not(ancestor::note)]/@n=$m or self::pb[not(ancestor::note)][not(ancestor::note)]/@n=$m]" priority="3"/>





</xsl:stylesheet>
