<!DOCTYPE stylesheet [
    <!ENTITY nbsp  "&#160;" >
    <!ENTITY cr    "&#x0d;" >
    <!ENTITY lf    "&#x0a;" >
]>

<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:f="urn:stylesheet-functions"
    xmlns:tmp="urn:temporary-items"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="f fn xd xs tmp">

    <xsl:template match="pageMap" mode="expand-page-map">
        <xsl:copy>
            <xsl:apply-templates mode="expand-page-map"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="page" mode="expand-page-map">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="pageRange" mode="expand-page-map">
        <xsl:variable name="offset" select="@s - @from"/>
        <xsl:variable name="type" select="@type"/>
        <xsl:variable name="target" select="@target"/>
        <xsl:variable name="facs" select="@facs"/>
        <xsl:variable name="n" select="@n"/>

        <xsl:for-each select="@from to @to">
            <page 
                n="{f:replacePageNumbers($n, ., . + $offset)}" 
                facs="{f:replacePageNumbers($facs, ., . + $offset)}">
                <xsl:if test="$type">
                    <xsl:attribute name="type" select="$type"/>
                </xsl:if>
                <xsl:if test="$target">
                    <xsl:attribute name="target" select="f:replacePageNumbers($target, ., . + $offset)"/>
                </xsl:if>
            </page>
        </xsl:for-each>
    </xsl:template>

    <xsl:function name="f:replacePageNumbers">
        <xsl:param name="string" as="xs:string"/>
        <xsl:param name="pageNumber" />
        <xsl:param name="sequenceNumber"/>

        <xsl:variable name="string" select="replace($string, '%R', f:to-roman($pageNumber))"/>
        <xsl:variable name="string" select="replace($string, '%r', lower-case(f:to-roman($pageNumber)))"/>

        <xsl:variable name="string" select="replace($string, '%s', string($sequenceNumber))"/>
        <xsl:variable name="string" select="replace($string, '%0s', f:padZero($sequenceNumber, 2))"/>
        <xsl:variable name="string" select="replace($string, '%00s', f:padZero($sequenceNumber, 3))"/>
        <xsl:variable name="string" select="replace($string, '%000s', f:padZero($sequenceNumber, 4))"/>

        <xsl:variable name="string" select="replace($string, '%n', string($pageNumber))"/>
        <xsl:variable name="string" select="replace($string, '%0n', f:padZero($pageNumber, 2))"/>
        <xsl:variable name="string" select="replace($string, '%00n', f:padZero($pageNumber, 3))"/>
        <xsl:variable name="string" select="replace($string, '%000n', f:padZero($pageNumber, 4))"/>

        <xsl:sequence select="$string"/>
    </xsl:function>


    <xsl:function name="f:padZero">
        <xsl:param name="number"/>
        <xsl:param name="width" as="xs:integer"/>

        <xsl:sequence select="format-number(number($number), substring('00000000000000000000000000', 1, $width))"/>
    </xsl:function>


    <xsl:function name="f:to-roman" as="xs:string">
        <xsl:param name="number" as="xs:integer"/>

        <xsl:number value="$number" format="I"/>
    </xsl:function>


<!--
page:       single page
    @n      number as printed on page, always numeric.
    @target id of page (to disambiguate if necessary)
    @type   one of: cover blank image text (default)
    @facs   url to facsimile of page

pageRange:  multiple pages
    @from   first page number as printed on page (inclusive), always numeric.
    @to     last page number as printed on page (inclusive), always numeric.
    @s      first sequence number of facsimile.
    @target id of pages, in which the following template values can be used
                %n = page number      (%0n    zero padded to length 2)
                %s = sequence number  (%0000s zero padded to length 4)
                %r = lower case Roman numeral of page number
                %R = upper case Roman numeral of page number
    @facs   url to facsimile of page, template values as above
    @type   see above

Transform to 

    Facsimile section:

    <facsimile>
        <graphic id="f001" url="p001.png"/>
        <graphic id="f002" url="p002.png"/>
    </facsimile>

    @facs elements to page-breaks

    <pb n="" id="">     becomes     <pb n="" id="" facs="">


    Step 1: transform pageRange elements to page elements

    Step 2: locate matching pages in TEI file
        1. try target value
        2. try n-th p-value (based on n of page)

    (When transforming a TEI text, when dealing with the pb element, we will look up in
    the page map)

-->

</xsl:stylesheet>
