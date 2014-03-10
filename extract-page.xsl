<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f xs xd"
    version="2.0">

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
        encoding="UTF-8"/>


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
















    <xsl:template name="sample">

Extracting a fragment between milestones from a complex structure.

I am looking for a template which allows me to extract a single page, as marked by milestone
elements <pb n="12"/> from a complex structure. Note that the milestone elements may occur in 
different parents. I want all the parent nodes, and everything between the <pb n="12"/> and the next 
<pb/> element

For example, when applying the extract method with as parameter "12" on the following sample

<TEI>
    <front>...</front>
    <body>
        <div1>
            <head>Blah</head>
            Blah blah <pb n="12"/> blah blah.
        </div1>
        <div1>
            Blah blah blah blah.
        </div1>
        <div1>
            Blah <hi>blah <pb n="13"/> blah</hi> blah.
        </div1>
    </body>
    <back>...</back>
</TEI>

It should return:

<TEI.2>
    <body>
        <div1>
            <pb n="12"/> blah blah.
        </div1>
        <div1>
            Blah blah blah blah.
        </div1>
        <div1>
            Blah <hi>blah <pb n="13"/></hi>
        </div1>
    </body>
</TEI.2>

The idea is that it will copy only elements that are a ancestor of either <pb/> and follow
the first <pb/> and precede the second <pb/>. The problem I face is formulating a nice XPath to select
those elements.

    </xsl:template>

</xsl:stylesheet>
