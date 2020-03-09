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

    <xsl:include href="../log.xsl"/>
    <xsl:include href="../rend.xsl"/>


<!--======= lift-from-paragraph =======-->

<!--

The main use case for this is to deal with the differences between the TEI and HTML
paragraph models. Several types of elements that TEI allows in a paragraph are
not not supposed to go into a paragraph in HTML. For this implementation, the assumption
is that such non-nestable items are only present as direct childeren of the paragraph,
so deeper nested items will not be lifted out of the paragraph. (Coded will added
to signal such cases on transformation.)

TODO:

* Strip leading spaces from first text node in following paragraphs
* [NOT NEEDED: PRE-PROCESSING] Generate an id, to make sure the id is based on the original p element.
* [DONE] Handle other items that should be lifted (q, lg, figure, list, etc.)
* [DONE] Process rendering ladders, such that paragraph initial things (like drop-caps) will not be repeated
* [DONE] Add a class to subsequent generated paragraphs, to indicate they are follow-up paragraphs.

To make this work without introducing complex code, it is best to run this
in a separate process in a pipeline of XSL transformations.

-->

<xsl:template match="node() | @*" mode="lift-from-paragraph">
    <xsl:copy-of select="."/>
</xsl:template>

<xsl:template match="p[f:contains-liftable-item(.)]" mode="lift-from-paragraph">
    <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:copy-of select="*[f:is-liftable-item(.)][1]/preceding-sibling::node()"/>
    </xsl:copy>
    <xsl:copy-of select="*[f:is-liftable-item(.)][1]"/>
    <xsl:variable name="remainder">
        <xsl:copy>
            <!-- prevent duplication of id by dropping them from the copy -->
            <xsl:copy-of select="@*[not(local-name(.) = ('id', 'rend'))]"/>
            <xsl:copy-of select="f:adjust-rend-attribute-for-following-fragments(@rend)"/>
            <xsl:copy-of select="*[f:is-liftable-item(.)][1]/following-sibling::node()"/>
        </xsl:copy>
    </xsl:variable>
    <xsl:if test="$remainder/p/element() or normalize-space($remainder) != ''">
        <xsl:apply-templates select="$remainder" mode="lift-from-paragraph" />
    </xsl:if>
</xsl:template>


<xsl:function name="f:adjust-rend-attribute-for-following-fragments">
    <xsl:param name="rend" as="xs:string?"/>

    <xsl:variable name="rend" select="f:remove-rend-value($rend, 'initial-offset')"/>
    <xsl:variable name="rend" select="f:remove-rend-value($rend, 'initial-width')"/>
    <xsl:variable name="rend" select="f:remove-rend-value($rend, 'initial-height')"/>
    <xsl:variable name="rend" select="f:remove-rend-value($rend, 'initial-image')"/>

    <xsl:variable name="rend" select="f:remove-class($rend, 'dropcap')"/>

    <xsl:variable name="rend" select="f:add-class($rend, 'noindent')"/>

    <xsl:if test="$rend">
        <xsl:attribute name="rend" select="$rend"/>
    </xsl:if>
</xsl:function>


<xsl:function name="f:is-liftable-item" as="xs:boolean">
    <xsl:param name="node" as="node()"/>
    <xsl:sequence select="if (
                                   $node/self::milestone[@unit = ('theme', 'tb')]
                                or $node/self::q[@rend = 'block']
                                or $node/self::letter
                                or $node/self::list
                                or $node/self::figure[not(f:is-inline(.) or f:rend-value(@rend, 'position') = 'abovehead')]
                                or $node/self::table[not(f:is-inline(.))]
                             )
                          then true()
                          else false()"/>
</xsl:function>


<xsl:function name="f:contains-liftable-item" as="xs:boolean">
    <xsl:param name="node" as="node()"/>
    <xsl:sequence select="if ($node/*[f:is-liftable-item(.)]) then true() else false()"/>
</xsl:function>


<!-- Stub methods from included stylesheets -->

<xsl:function name="f:is-inline" as="xs:boolean">
    <xsl:param name="node" as="node()"/>
    <xsl:sequence select="false()"/>
</xsl:function>


<xsl:function name="f:is-set" as="xs:boolean">
    <xsl:param name="node" as="xs:string"/>
    <xsl:sequence select="false()"/>
</xsl:function>


<!--
<xsl:function name="f:rend-value" as="xs:string">
    <xsl:param name="node" as="node()?"/>
    <xsl:param name="name" as="xs:string"/>
    <xsl:sequence select="'dummy'"/>
</xsl:function>
-->

</xsl:stylesheet>
