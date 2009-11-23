<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to format cross references, to be imported in tei2html.xsl.

    Requires: 
        localization.xsl    : templates for localizing strings.
        messages.xsl        : stores localized messages in variables.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"
    >


    <!--====================================================================-->
    <!-- Cross References -->

    <!-- Special case: reference to footnote, used when the same footnote reference mark is used multiple times -->

    <xsl:template match="ref[@target and @type='noteref']">
        <xsl:variable name="target" select="./@target"/>
        <xsl:apply-templates select="//*[@id=$target]" mode="noterefnumber"/>
    </xsl:template>

    <xsl:template match="note" mode="noterefnumber">
        <a class="pseudonoteref">
            <xsl:call-template name="generate-href-attribute"/>
            <xsl:number level="any" count="note[@place='foot' or not(@place)]" from="div1[not(ancestor::q)]"/>
        </a>
    </xsl:template>

    <!-- Normal case -->

    <xsl:template match="ref[@target and not(@type='noteref')]">
        <xsl:variable name="target" select="./@target"/>
        <xsl:choose>
            <xsl:when test="not(//*[@id=$target])">
                <xsl:message terminate="no">Warning: target '<xsl:value-of select="$target"/>' of cross reference not found.</xsl:message>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <a>
                    <xsl:call-template name="generate-href-for">
                        <xsl:with-param name="node" select="//*[@id=$target]"/>
                    </xsl:call-template>
                    <xsl:call-template name="generate-id-attribute"/>
                    <xsl:if test="@type='pageref'">
                        <xsl:attribute name="class">pageref</xsl:attribute>
                    </xsl:if>
                    <xsl:if test="@type='endnoteref'">
                        <xsl:attribute name="class">noteref</xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="generate-href-for">
        <xsl:param name="node"/>

        <xsl:attribute name="href">
            <xsl:call-template name="generate-url-for">
                <xsl:with-param name="node" select="$node"/>
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="generate-url-for">
        <xsl:param name="node"/>

        <!-- Determine whether the source and destination are in the same file -->
        <xsl:variable name="sourcefile"><xsl:call-template name="splitter-generate-filename-for"/></xsl:variable>
        <xsl:variable name="targetfile"><xsl:call-template name="splitter-generate-filename-for"><xsl:with-param name="node" select="$node"/></xsl:call-template></xsl:variable>
        <xsl:if test="$sourcefile != $targetfile"><xsl:value-of select="$targetfile"/></xsl:if>#<xsl:call-template name="generate-id-for"><xsl:with-param name="node" select="$node"/></xsl:call-template>
    </xsl:template>



    <!--====================================================================-->
    <!-- External References -->

    <xsl:template match="xref[@url]">
        <a>
            <xsl:choose>
                <xsl:when test="substring(@url, 1, 3) = 'pg:'">
                    <xsl:attribute name="class">pglink</xsl:attribute>
                    <xsl:attribute name="title"><xsl:value-of select="$strLinkToPg"/></xsl:attribute>
                    <xsl:attribute name="href">http://www.gutenberg.org/etext/<xsl:value-of select="substring-after(@url, 'pg:')"/></xsl:attribute>
                </xsl:when>
                <xsl:when test="substring(@url, 1, 5) = 'oclc:'">
                    <xsl:attribute name="class">catlink</xsl:attribute>
                    <xsl:attribute name="title"><xsl:value-of select="$strLinkToWorldCat"/></xsl:attribute>
                    <xsl:attribute name="href">http://www.worldcat.org/oclc/<xsl:value-of select="substring-after(@url, 'oclc:')"/></xsl:attribute>
                </xsl:when>
                <xsl:when test="substring(@url, 1, 4) = 'oln:'">
                    <xsl:attribute name="class">catlink</xsl:attribute>
                    <xsl:attribute name="title"><xsl:value-of select="$strLinkToOpenLibrary"/></xsl:attribute>
                    <xsl:attribute name="href">http://openlibrary.org/b/<xsl:value-of select="substring-after(@url, 'oln:')"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">exlink</xsl:attribute>
                    <xsl:attribute name="title"><xsl:value-of select="$strExternalLink"/></xsl:attribute>
                    <xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </a>
    </xsl:template>


</xsl:stylesheet>
