<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="1.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:msg="http://www.gutenberg.ph/2006/schemas/messages"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="msg xd">

    <xsl:output
        doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
        doctype-system="http://www.w3.org/TR/html4/loose.dtd"
        method="html"
        encoding="UTF-8"/>

    <xd:doc type="stylesheet">
        <xd:short>TEI stylesheet to review translations in localization xml-files.</xd:short>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:param name="srclang" select="'en'"/>
    <xsl:param name="destlang" select="'de'"/>

    <xsl:strip-space elements="*"/>

    <xsl:template match="/">
    <html>
        <head>
            <title>Review <xsl:value-of select="//msg:message[@name=$destlang and lang('en')]"/> Translations in Messages.xml</title>

            <style type="text/css">

                .param { color: red; font-weight: bold; font-family: courier new, monospace; }
                .missing { background-color: yellow; }
                table { width: 100%; }
                th, td { text-align: left; vertical-align: top; }

            </style>
        </head>
        <body>
            <h2>Missing Translations in <xsl:value-of select="//msg:message[@name=$destlang and lang('en')]"/></h2>
            <table>
                <tr>
                    <th width="20%">Message ID</th>
                    <th width="30%">Message in <xsl:value-of select="//msg:message[@name=$srclang and lang('en')]"/></th>
                    <th width="50%">Disambiguation</th>
                </tr>
                <xsl:apply-templates select="//msg:message" mode="missing"/>
            </table>

            <h2>Overview of Available Translations in <xsl:value-of select="//msg:message[@name=$destlang and lang('en')]"/></h2>
            <table>
                <tr>
                    <th width="20%">Message ID</th>
                    <th width="30%">Message in <xsl:value-of select="//msg:message[@name=$srclang and lang('en')]"/></th>
                    <th width="50%">Message in <xsl:value-of select="//msg:message[@name=$destlang and lang('en')]"/></th>
                </tr>
                <xsl:apply-templates select="//msg:message" mode="review"/>
            </table>
        </body>
    </html>
    </xsl:template>


    <xsl:template match="msg:message[@plural]" mode="missing">
        <xsl:if test="lang($srclang)">
            <xsl:variable name="name" select="@name"/>
            <xsl:variable name="plural" select="@plural"/>
            <xsl:variable name="value" select="."/>
            <xsl:if test="not(//msg:message[@name=$name and lang($destlang) and @plural=$plural])">
                <tr>
                    <td class="messageId"><xsl:value-of select="@name"/> [<xsl:value-of select="@plural"/>]</td>
                        <xsl:choose>
                        <xsl:when test="string-length($value) &lt; 2000">
                            <td><xsl:apply-templates select="$value" mode="cp"/></td>
                            <td><xsl:value-of select="@help"/></td>
                        </xsl:when>
                        <xsl:otherwise>
                            <td colspan="2"><i class="missing">long message omitted</i></td>
                        </xsl:otherwise>
                    </xsl:choose>
                </tr>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="msg:message[not(@plural)]" mode="missing">
        <xsl:if test="lang($srclang)">
            <xsl:variable name="name" select="@name"/>
            <xsl:variable name="value" select="."/>
            <xsl:if test="not(//msg:message[@name=$name and lang($destlang) and not(@plural)])">
                <tr>
                    <td class="messageId"><xsl:value-of select="@name"/></td>
                    <xsl:choose>
                        <xsl:when test="string-length($value) &lt; 2000">
                            <td><xsl:apply-templates select="$value" mode="cp"/></td>
                            <td><xsl:value-of select="@help"/></td>
                        </xsl:when>
                        <xsl:otherwise>
                            <td colspan="2"><i class="missing">long message omitted</i></td>
                        </xsl:otherwise>
                    </xsl:choose>
                </tr>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="msg:message[@plural]" mode="review">
        <xsl:if test="lang($srclang)">
            <xsl:variable name="name" select="@name"/>
            <xsl:variable name="plural" select="@plural"/>
            <xsl:variable name="value" select="."/>
            <xsl:variable name="translation" select="//msg:message[@name=$name and lang($destlang) and @plural=$plural]"/>
            <tr>
                <td>
                    <xsl:value-of select="@name"/> [<xsl:value-of select="@plural"/>]
                </td>
                <td>
                    <xsl:apply-templates select="$value" mode="cp"/>
                </td>
                <td>
                    <xsl:choose>
                        <xsl:when test="$translation">
                            <xsl:apply-templates select="$translation" mode="cp"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <i class="missing">no translation available</i>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template match="msg:message[not(@plural)]" mode="review">
        <xsl:if test="lang($srclang)">
            <xsl:variable name="name" select="@name"/>
            <xsl:variable name="value" select="."/>
            <xsl:variable name="translation" select="//msg:message[@name=$name and lang($destlang) and not(@plural)]"/>
            <tr>
                <td>
                    <xsl:value-of select="@name"/>
                </td>
                <td>
                    <xsl:apply-templates select="$value" mode="cp"/>
                </td>
                <td>
                    <xsl:choose>
                        <xsl:when test="$translation">
                            <xsl:apply-templates select="$translation" mode="cp"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <i class="missing">no translation available</i>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*" mode="cp">
        <xsl:copy>
            <xsl:apply-templates mode="cp"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="msg:param" mode="cp">
        <span class="param">{<xsl:value-of select="@name"/><xsl:if test="@type">:<xsl:value-of select="@type"/></xsl:if>}</span>
    </xsl:template>

</xsl:stylesheet>
