<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="http://example.com/"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="f xd xs"
    >

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to align paragraphs in two TEI documents.</xd:short>
        <xd:detail><p>Stylesheet to align paragraphs in two TEI documents.</p>
        </xd:detail>
    </xd:doc>


    <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>


    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="@TEIform" mode="#all"/>


    <xsl:template match="div|div1|div2|div3|div4|div5|div6">
        <xsl:copy>
            <xsl:choose>
                <!-- Align with internal division -->
                <xsl:when test="contains(@rend, 'align-with(')">
                    <xsl:apply-templates select="attribute()" mode="adjust-rend"/>
                    <xsl:variable name="otherid" select="substring-before(substring-after(@rend, 'align-with('), ')')"/>
                    <xsl:message terminate="no">INFO:    Align division <xsl:value-of select="@id"/> with division <xsl:value-of select="$otherid"/></xsl:message>
                    <xsl:call-template name="align-paragraphs">
                        <xsl:with-param name="a" select="."/>
                        <xsl:with-param name="b" select="//*[@id=$otherid]"/>
                    </xsl:call-template>
                </xsl:when>

                <!-- Align with external division -->
                <xsl:when test="contains(@rend, 'align-with-document(')">
                    <xsl:apply-templates select="attribute()" mode="adjust-rend"/>
                    <xsl:variable name="target" select="substring-before(substring-after(@rend, 'align-with-document('), ')')"/>
                    <xsl:variable name="document" select="substring-before($target, '#')"/>
                    <xsl:variable name="otherid" select="substring-after($target, '#')"/>
                    <xsl:message terminate="no">INFO:    Align division <xsl:value-of select="@id"/> with external document '<xsl:value-of select="$target"/>'</xsl:message>
                    <xsl:call-template name="align-paragraphs">
                        <xsl:with-param name="a" select="."/>
                        <xsl:with-param name="b" select="document($document, .)//*[@id=$otherid]"/>
                    </xsl:call-template>
                </xsl:when>

                <!-- No alignment, just copy -->
                <xsl:otherwise>
                    <xsl:apply-templates select="attribute()|element()|text()|comment()|processing-instruction()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>


    <!--====================================================================-->
    <!-- Remove the align-annotations from the rend attribute -->

    <xsl:template match="@*|node()" mode="adjust-rend">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@rend" mode="adjust-rend">
        <xsl:variable name="rend" select='replace(., "align-with(-document)?\([^)]+\)", "")'/>
        <xsl:if test="$rend != ''">
            <xsl:attribute name="rend">
                <xsl:value-of select="$rend"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>


    <!--====================================================================-->
    <!-- code to align two divisions based on the @n attribute -->

    <xd:doc>
        <xd:short>Align two division based on the <code>@n</code> attribute in paragraphs.</xd:short>
        <xd:detail>Align two division based on the <code>@n</code> attribute in paragraphs. This code handles
        the case where paragraphs are added or removed between aligned paragraphs, as can be
        expected in a more free translation.</xd:detail>
    </xd:doc>

    <xsl:template name="align-paragraphs">
        <xsl:param name="a"/>
        <xsl:param name="b"/>

        <!-- We collect all 'anchor' elements, i.e., elements with the
             same value of the @n attribute. Those we line up in our table,
             taking care to insert all elements inserted after that as well. -->

        <xsl:variable name="anchors" as="xs:string*">
            <xsl:for-each-group select="$a/*/@n, $b/*/@n" group-by=".">
                <xsl:if test="count(current-group()) = 2">
                    <xsl:sequence select="string(.)"/>
                </xsl:if>
            </xsl:for-each-group>
        </xsl:variable>

        <table rend="class(alignedtext)">

            <!-- Handle matter before any anchor -->
            <xsl:if test="not($a/*[1]/@n = $anchors) or not($b/*[1]/@n = $anchors)">
                <row>
                    <cell rend="class(first)">
                        <xsl:if test="not($a/*[1]/@n = $anchors)">
                            <xsl:apply-templates select="$a/*[1]" mode="adjust"/>
                            <xsl:call-template name="output-inserted-paragraphs">
                                <xsl:with-param name="start" select="$a/*[1]"/>
                                <xsl:with-param name="anchors" select="$anchors"/>
                            </xsl:call-template>
                        </xsl:if>
                    </cell>
                    <cell rend="class(second)">
                        <xsl:if test="not($b/*[1]/@n = $anchors)">
                            <xsl:apply-templates select="$b/*[1]" mode="adjust"/>
                            <xsl:call-template name="output-inserted-paragraphs">
                                <xsl:with-param name="start" select="$b/*[1]"/>
                                <xsl:with-param name="anchors" select="$anchors"/>
                            </xsl:call-template>
                        </xsl:if>
                    </cell>
                </row>
            </xsl:if>

            <!-- Handle matter for all anchors -->
            <xsl:for-each select="$a/*[@n = $anchors]">
                <xsl:variable name="n" select="@n"/>

                <row>
                    <cell rend="class(first)">
                        <xsl:apply-templates select="." mode="adjust"/>
                        <xsl:call-template name="output-inserted-paragraphs">
                            <xsl:with-param name="start" select="."/>
                            <xsl:with-param name="anchors" select="$anchors"/>
                        </xsl:call-template>
                    </cell>
                    <cell rend="class(second)">
                        <xsl:apply-templates select="$b/*[@n = $n]" mode="adjust"/>
                        <xsl:call-template name="output-inserted-paragraphs">
                            <xsl:with-param name="start" select="$b/*[@n = $n]"/>
                            <xsl:with-param name="anchors" select="$anchors"/>
                        </xsl:call-template>
                    </cell>
                </row>
            </xsl:for-each>
        </table>
    </xsl:template>


    <xd:doc>
        <xd:short>Output inserted paragraphs in aligned divisions.</xd:short>
        <xd:detail>Output paragraphs not present in the first division, but present in
        the second (that is, without a matching <code>@n</code> attribute).</xd:detail>
    </xd:doc>

    <xsl:template name="output-inserted-paragraphs">
        <xsl:param name="start" as="node()"/>
        <xsl:param name="anchors"/>
        <xsl:variable name="next" select="$start/following-sibling::*[1]"/>

        <xsl:if test="not($next/@n = $anchors)">
            <xsl:if test="$next">
                <xsl:apply-templates select="$next" mode="adjust"/>

                <xsl:call-template name="output-inserted-paragraphs">
                    <xsl:with-param name="start" select="$next"/>
                    <xsl:with-param name="anchors" select="$anchors"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <!--====================================================================-->
    <!-- code to adjust elements that won't work out well inside tables -->

    <xsl:template match="*" mode="adjust">
        <xsl:apply-templates select="."/>
    </xsl:template>

    <!-- TODO: further sort out how to handle this best. -->

    <xsl:template match="head" mode="adjust">
        <p>
            <xsl:attribute name="rend">
                <xsl:text>class(</xsl:text>
                <xsl:value-of select="'h1'"/>
                <xsl:text>)</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates/>
        </p>
    </xsl:template>


</xsl:stylesheet>