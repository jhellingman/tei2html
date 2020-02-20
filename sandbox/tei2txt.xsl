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


<!-- tei2txt.xslt - stylesheet to convert TEI files to plain text format -->

<xsl:param name="lineWidth" select="72"/>

<!--
Lift the lb elements to the paragraph level, closing and reopening all
elements as they appear in the paragraph (similar to the pb handling in extract-page.xsl) 
-->

<xsl:template mode="extract-partial-paragraph" match="* | node()">
        <xsl:param name="start" as="element()?" tunnel="yes"/>
        <xsl:param name="end" as="element()?" tunnel="yes"/>

    <xsl:variable name="after-start" as="xs:boolean" select=". >> $start or . is $start"/>
    <xsl:variable name="not-after-end" as="xs:boolean" select="if ($end) then $end >> . else true()"/>
    <xsl:variable name="contains-start" as="xs:boolean" select="if (.//*[. is $start]) then true() else false()"/>
    <xsl:variable name="include" select="($after-start and $not-after-end) or $contains-start"/>

    <!-- TODO: need to exclude footnotes from traversal (best done in separate template) -->

    <xsl:choose>
        <xsl:when test="$include">
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:apply-templates mode="extract-partial-paragraph"/>
            </xsl:copy>
        </xsl:when>
        <xsl:otherwise>
            <xsl:apply-templates mode="extract-partial-paragraph"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<xd:doc>
    <xd:short>Break a paragraph on line-breaks.</xd:short>
    <xd:detail>Break a paragraph on line-breaks, regardless off how deeply nested in the paragraph
    the line-breaks occur. Close and re-open any elements that contain the line-break.</xd:detail>
    <xd:param name="p">The paragraph to be broken-up.</xd:param>
</xd:doc>

<xsl:function name="f:preprocess-paragraph">
    <xsl:param name="p" as="element(p)"/>

    <xsl:choose>
        <xsl:when test="$p[//lb]">
            <!-- Get the material until the first lb -->
            <xsl:apply-templates select="$p" mode="extract-partial-paragraph">
                    <xsl:with-param name="start" select="$p" tunnel="yes"/>
                    <xsl:with-param name="end" select="($p//lb)[1]" tunnel="yes"/>
            </xsl:apply-templates>

            <!-- Iterate over the following lb's to get the material between them -->
            <xsl:iterate select="$p//lb">
                <xsl:param name="start" select="($p//lb)[1]" as="element()?"/>
                <xsl:param name="end" select="($p//lb)[2]" as="element()?"/>

                <xsl:apply-templates select="$p" mode="extract-partial-paragraph">
                    <xsl:with-param name="start" select="$start" tunnel="yes"/>
                    <xsl:with-param name="end" select="$end" tunnel="yes"/>
                </xsl:apply-templates>

                <xsl:next-iteration>
                    <xsl:with-param name="start" select="$end"/>
                    <xsl:with-param name="end" select="($end/following::lb)[1]"/>
                </xsl:next-iteration>
            </xsl:iterate>
        </xsl:when>
        <xsl:otherwise>
            <xsl:copy-of select="$p"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:function>


<xsl:template match="p">
    <xsl:variable name="split-paragraph">
        <xsl:copy-of select="f:preprocess-paragraph(.)"/>
    </xsl:variable>

    <xsl:apply-templates select="$split-paragraph" mode="split-paragraph"/>
</xsl:template>


<xsl:template match="p" mode="split-paragraph">
    <xsl:variable name="text">
        <xsl:apply-templates/>
    </xsl:variable>
    <xsl:copy-of select="f:break-into-lines($text, $lineWidth)"/>
</xsl:template>


<xsl:template match="note">
    <xsl:text>[</xsl:text>
    <xsl:number count="note" level="any"/>
    <xsl:text>]</xsl:text>
</xsl:template>


<xsl:template match="choice/corr">
    <xsl:apply-templates/>
</xsl:template>


<xsl:template match="choice/sic"/>


<!--======= lift-from-paragraph =======-->

<!-- 

The main use case for this is to deal with sloppy TEI, where </p> tags have not been
used before an element that is not supposed to go into a paragraph. In TEI, this is
valid, in HTML it is not. The assumption is that such non-nestable items are only
present as direct childeren of the paragraph, so deeper nested items will not be
lifted out of the paragraph.

TODO:

* Strip leading spaces from first text node in following paragraphs
* Generate an id, to make sure the id is based on the original p element.
* Handle other items that should be lifted (q, lg, figure, list, etc.)
* Process rendering ladders, such that paragraph initial things (like drop-caps) will not be repeated
* Add a class to subsequent generated paragraphs, to indicate they are follow-up paragraphs.

To make this work without introducing complex code, it is best to run this
in a separate process in a pipeline of XSL transformations.

-->

<xsl:template match="node() | @*" mode="lift-from-paragraph">
    <xsl:copy-of select="."/>
</xsl:template>

<xsl:template match="p[f:contains-liftable-item(.)]" mode="lift-from-paragraph">
    <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:if test="not(@id)"><xsl:attribute name="id" select="generate-id(.)"/></xsl:if>
        <xsl:copy-of select="*[f:is-liftable-item(.)][1]/preceding-sibling::node()"/>
    </xsl:copy>
    <xsl:copy-of select="*[f:is-liftable-item(.)][1]"/>
    <xsl:variable name="remainder">
        <xsl:copy>
            <!-- prevent duplications of ids -->
            <xsl:copy-of select="@*[local-name(.) != 'id']"/>
            <xsl:copy-of select="*[f:is-liftable-item(.)][1]/following-sibling::node()"/>
        </xsl:copy>
    </xsl:variable>
    <xsl:if test="$remainder/p/element() or normalize-space($remainder) != ''">
        <xsl:apply-templates select="$remainder" mode="lift-from-paragraph" />
    </xsl:if>
</xsl:template>

<xsl:function name="f:is-liftable-item" as="xs:boolean">
    <xsl:param name="node" as="node()"/>
    <xsl:sequence select="if ($node/self::table) then true() else false()"/>
</xsl:function>

<xsl:function name="f:contains-liftable-item" as="xs:boolean">
    <xsl:param name="node" as="node()"/>
    <xsl:sequence select="if ($node/*[f:is-liftable-item(.)]) then true() else false()"/>
</xsl:function>


<!--======= f:break-into-lines =======-->

<xsl:function name="f:break-into-lines" as="element(line)*">
    <xsl:param name="text" as="xs:string"/>
    <xsl:param name="max-width" as="xs:integer"/>

    <!-- strip initial space from string -->
    <xsl:variable name="text" select="replace($text, '^\s+', '')"/>

    <!-- break string up in words and spaces -->
    <xsl:variable name="words">
        <xsl:analyze-string select="$text" regex="\s">
            <xsl:matching-substring>
                <tmp:space text="{.}" width="{f:unicode-character-count(.)}"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <tmp:word text="{.}" width="{f:unicode-character-count(.)}"/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:variable>

    <!-- greedily output words and spaces as long as they fit -->
    <xsl:iterate select="$words/*">
        <xsl:param name="text" select="''" as="xs:string"/>
        <xsl:param name="width" select="0" as="xs:integer"/>

        <xsl:on-completion>
            <line><xsl:value-of select="$text"/></line>
        </xsl:on-completion> 

        <xsl:variable name="pos" select="position()"/>

        <xsl:if test="f:word-wrap-break($words, $width, $pos, $max-width)">
            <line><xsl:value-of select="$text"/></line>
        </xsl:if>

        <xsl:variable name="newWidth" select="if (f:word-wrap-break($words, $width, $pos, $max-width))
            then 0
            else xs:integer($width + @width)" as="xs:integer"/>

        <xsl:variable name="newText" select="if (f:word-wrap-break($words, $width, $pos, $max-width))
            then ''
            else $text || @text" as="xs:string"/>

        <xsl:next-iteration>
            <xsl:with-param name="text" select="$newText"/>
            <xsl:with-param name="width" select="$newWidth"/>
        </xsl:next-iteration>
    </xsl:iterate>
</xsl:function>


<!--======= f:word-wrap =======-->

<xsl:function name="f:word-wrap" as="xs:string">
    <xsl:param name="text" as="xs:string"/>
    <xsl:param name="max-width" as="xs:integer"/>

    <!-- break string up in words and spaces -->
    <xsl:variable name="words">
        <xsl:analyze-string select="$text" regex="\s">
            <xsl:matching-substring>
                <tmp:space text="{.}" width="{f:unicode-character-count(.)}"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <tmp:word text="{.}" width="{f:unicode-character-count(.)}"/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:variable>

    <!-- greedily output words and spaces as long as they fit -->
    <xsl:iterate select="$words/*">
        <xsl:param name="text" select="''" as="xs:string"/>
        <xsl:param name="width" select="0" as="xs:integer"/>

        <xsl:on-completion>
            <xsl:sequence select="$text"/>
        </xsl:on-completion> 

        <xsl:variable name="pos" select="position()"/>

        <xsl:variable name="newWidth" select="if (f:word-wrap-break($words, $width, $pos, $max-width))
            then 0
            else xs:integer($width + @width)" as="xs:integer"/>

        <xsl:variable name="newText" select="if (f:word-wrap-break($words, $width, $pos, $max-width))
            then $text || '&#x0a;'
            else $text || @text" as="xs:string"/>

        <xsl:next-iteration>
            <xsl:with-param name="text" select="$newText"/>
            <xsl:with-param name="width" select="$newWidth"/>
        </xsl:next-iteration>
    </xsl:iterate>
</xsl:function>

<xsl:function name="f:word-wrap-break" as="xs:boolean">
    <xsl:param name="words"/>
    <xsl:param name="width" as="xs:integer"/>
    <xsl:param name="pos" as="xs:integer"/>
    <xsl:param name="max-width" as="xs:integer"/>

    <xsl:sequence select="$width > 0 
        and local-name($words/*[$pos]) = 'space'
        and $words/*[$pos + 1]
        and $width + $words/*[$pos]/@width + $words/*[$pos + 1]/@width > $max-width"/>
</xsl:function>

<xsl:function name="f:unicode-character-count" as="xs:integer">
    <xsl:param name="string" as="xs:string"/>
    <xsl:sequence select="string-length(f:strip-diacritics($string))"/>
</xsl:function>

<xsl:function name="f:strip-diacritics" as="xs:string">
    <xsl:param name="string" as="xs:string"/>
    <xsl:sequence select="replace(normalize-unicode($string, 'NFD'), '\p{M}', '')"/>
</xsl:function>


</xsl:stylesheet>
