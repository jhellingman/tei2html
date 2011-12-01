<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to format tables, to be imported in tei2html.xsl.

    Requires: 
        localization.xsl    : templates for localizing strings.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0"
    >

    <!--====================================================================-->
    <!-- Lists -->

    <xsl:template match="list">
        <xsl:call-template name="closepar"/>

        <xsl:variable name="listType">
            <xsl:choose>
                <xsl:when test="@type='ordered'">ol</xsl:when>
                <xsl:otherwise>ul</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="contains(@rend, 'columns(2)')">
                <xsl:call-template name="doubleuplist"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{$listType}">
                    <xsl:call-template name="set-lang-id-attributes"/>
                    <xsl:call-template name="generate-rend-class-attribute-if-needed"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:call-template name="reopenpar"/>
    </xsl:template>


    <xsl:template name="doubleuplist">
        <table>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:variable name="listType">
                <xsl:choose>
                    <xsl:when test="@type='ordered'">ol</xsl:when>
                    <xsl:otherwise>ul</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:variable name="halfway" select="ceiling(count(item) div 2)"/>
            <tr>
                <td>
                    <xsl:element name="{$listType}">
                        <xsl:call-template name="generate-rend-class-attribute-if-needed"/>
                        <xsl:apply-templates select="item[position() &lt; $halfway + 1]"/>
                    </xsl:element>
                </td>
                <td>
                    <xsl:element name="{$listType}">
                        <xsl:call-template name="generate-rend-class-attribute-if-needed"/>
                        <xsl:apply-templates select="item[position() &gt; $halfway]"/>
                    </xsl:element>
                </td>
            </tr>
        </table>
    </xsl:template>


    <xsl:template match="item">
        <li>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:call-template name="generate-rend-class-attribute-if-needed"/>
            <xsl:if test="@n">
                <xsl:attribute name="value"><xsl:value-of select="@n"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </li>
    </xsl:template>


</xsl:stylesheet>
