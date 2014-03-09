<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="xd"
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


    <xsl:function name="f:innote" as="xs:boolean">
        <xsl:param name="pb" as="node()"/>

        <xsl:value-of select="$pb[ancestor::note]"/>
    </xsl:function>



    <xsl:template match="/">

        <xsl:message>Extracting page '<xsl:value-of select="$n"/>' at position <xsl:value-of select="$p"/></xsl:message>

        <xsl:variable name="page">
            <xsl:apply-templates mode="extract-page"/>
        </xsl:variable>

        <!-- Eliminate those parts of footnotes not part of this page, that is, following a <pb> element. -->
        <xsl:variable name="page">
            <xsl:apply-templates select="$page" mode="handle-notes"/>
        </xsl:variable>

        <xsl:copy-of select="$page"/>

        <!-- Find preceding pages with footnotes that extend into this page -->


        <!-- TODO -->


    </xsl:template>


    <xsl:template mode="handle-notes" match="*|node()">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="handle-notes"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template mode="handle-notes" match="note" priority="1">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="fn-extract-page"/>
        </xsl:copy>
    </xsl:template>




    <xsl:template mode="fn-extract-current-page" match="node()" priority="1"/>

    <xsl:template mode="fn-extract-current-page" match="*[descendant-or-self::pb[count(preceding::pb)=0]] | node()[preceding::pb[count(preceding::pb)=0]]" priority="2">
         <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="fn-extract-current-page"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template mode="fn-extract-current-page" match="node()[preceding::pb[count(preceding::pb)=1] or self::pb[count(preceding::pb)=1]]" priority="3"/>



    <xsl:template mode="fn-extract-page" match="* | node()" priority="2">
        <xsl:param name="p" select="0" as="xs:integer"/>
        <xsl:param name="q" select="$p + 1" as="xs:integer"/>

        <xsl:if test="not(preceding::pb[count(preceding::pb)=$q] or self::pb[count(preceding::pb)=$q])">
            <xsl:if test="(self::* and descendant-or-self::pb[count(preceding::pb)=$p]) or preceding::pb[count(preceding::pb)=$p]">
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates mode="fn-extract-page"/>
                </xsl:copy>
            </xsl:if>
        </xsl:if>
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
