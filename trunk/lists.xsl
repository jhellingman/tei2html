<!DOCTYPE xsl:stylesheet [

    <!ENTITY tab        "&#x09;">
    <!ENTITY lf         "&#x0A;">
    <!ENTITY cr         "&#x0D;">
    <!ENTITY deg        "&#176;">
    <!ENTITY ldquo      "&#x201C;">
    <!ENTITY nbsp       "&#160;">
    <!ENTITY mdash      "&#x2014;">
    <!ENTITY prime      "&#x2032;">
    <!ENTITY Prime      "&#x2033;">
    <!ENTITY plusmn     "&#x00B1;">
    <!ENTITY frac14     "&#x00BC;">
    <!ENTITY frac12     "&#x00BD;">
    <!ENTITY frac34     "&#x00BE;">

]>
<!--

    Stylesheet to format tables, to be imported in tei2html.xsl.

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
    <!-- Lists -->

    <xsl:template match="list">
        <xsl:call-template name="closepar"/>

        <xsl:variable name="listType">
            <xsl:choose>
                <xsl:when test="@type='ordered' or @type='simple'">ol</xsl:when>
                <xsl:otherwise>ul</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="contains(@rend, 'columns(2)')">
                <xsl:call-template name="doubleuplist"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{$listType}">
                    <xsl:call-template name="generate-id-attribute"/>
                    <xsl:call-template name="setListStyleType"/>
                    <xsl:call-template name="setLangAttribute"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:call-template name="reopenpar"/>
    </xsl:template>


    <xsl:template name="doubleuplist">
        <table>
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:variable name="listType">
                <xsl:choose>
                    <xsl:when test="@type='ordered' or @type='simple'">ol</xsl:when>
                    <xsl:otherwise>ul</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:variable name="halfway" select="ceiling(count(item) div 2)"/>
            <tr valign="top">
                <td>
                    <xsl:element name="{$listType}">
                        <xsl:call-template name="setListStyleType"/>
                        <xsl:apply-templates select="item[position() &lt; $halfway + 1]"/>
                    </xsl:element>
                </td>
                <td>
                    <xsl:element name="{$listType}">
                        <xsl:call-template name="setListStyleType"/>
                        <xsl:apply-templates select="item[position() &gt; $halfway]"/>
                    </xsl:element>
                </td>
            </tr>
        </table>
    </xsl:template>


    <xsl:template name="setListStyleType">
        <xsl:if test="contains(@rend, 'list-style-type(') or @type='simple'">
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="@type='simple'">lsoff</xsl:when>
                    <xsl:when test="contains(@rend, 'list-style-type(disc)')">lsdisc</xsl:when>
                    <xsl:when test="contains(@rend, 'list-style-type(none)')">lsoff</xsl:when>
                    <xsl:when test="contains(@rend, 'list-style-type(lower-alpha)')">AL</xsl:when>
                    <xsl:when test="contains(@rend, 'list-style-type(upper-alpha)')">AU</xsl:when>
                    <xsl:when test="contains(@rend, 'list-style-type(lower-roman)')">RL</xsl:when>
                    <xsl:when test="contains(@rend, 'list-style-type(upper-roman)')">RU</xsl:when>
                </xsl:choose>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>


    <xsl:template match="item">
        <li>
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:if test="@n">
                <xsl:attribute name="value"><xsl:value-of select="@n"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </li>
    </xsl:template>


    <xsl:template name="rendattrlist">
        <xsl:if test="contains(@rend, 'list-style-type(')">
            <xsl:attribute name="style">
                <xsl:if test="contains(@rend, 'list-style-type(')">list-style-type:<xsl:value-of select="substring-before(substring-after(@rend, 'list-style-type('), ')')"/>;</xsl:if>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>


</xsl:stylesheet>
