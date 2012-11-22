<xsl:transform
    xmlns:msg="http://www.gutenberg.ph/2006/schemas/messages"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    version="1.0"
    exclude-result-prefixes="msg xd">

    <xsl:output
        doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
        doctype-system="http://www.w3.org/TR/html4/loose.dtd"
        method="html"
        encoding="UTF-8"/>

    <xd:doc type="stylesheet">
        <xd:short>TEI stylesheet to review translations in our localization xml-files.</xd:short>
        <xd:detail> </xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:param name="srclang" select="'en'"/>
    <xsl:param name="destlang" select="'ceb'"/>

    <xsl:strip-space elements="*"/>

    <xsl:template match="/">
    <html>
        <head>
            <title>Review <xsl:value-of select="//msg:message[@name=$destlang and lang('en')]"/> Translations in Messages.xml</title>

            <style type="text/css">

                .param { color: red; font-weight: bold; font-family: courier new; }
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
                    <th width="80%">Message in <xsl:value-of select="//msg:message[@name=$srclang and lang('en')]"/></th></tr>
                <xsl:apply-templates select="//msg:message" mode="missing"/>
            </table>

            <h2>Overview of Available Translations in <xsl:value-of select="//msg:message[@name=$destlang and lang('en')]"/></h2>
            <table>
                <tr>
                    <th width="20%">Message ID</th>
                    <th width="40%">Message in <xsl:value-of select="//msg:message[@name=$srclang and lang('en')]"/></th>
                    <th width="40%">Message in <xsl:value-of select="//msg:message[@name=$destlang and lang('en')]"/></th>
                </tr>
                <xsl:apply-templates select="//msg:message" mode="review"/>
            </table>
        </body>
    </html>
    </xsl:template>


    <xsl:template match="msg:message" mode="missing">
        <xsl:if test="lang($srclang)">
            <xsl:variable name="name" select="@name"/>
            <xsl:variable name="value" select="."/>
            <xsl:if test="not(//msg:message[@name=$name and lang($destlang)])">
                <tr>
                    <td class="messageid"><xsl:value-of select="@name"/></td>
                        <xsl:choose>
                        <xsl:when test="string-length($value) &lt; 2000">
                            <td><xsl:apply-templates select="$value" mode="cp"/></td>
                        </xsl:when>
                        <xsl:otherwise>
                            <td><i class="missing">long message omitted</i></td>
                        </xsl:otherwise>
                    </xsl:choose>
                </tr>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xsl:template match="msg:message" mode="review">
        <xsl:if test="lang($srclang)">
            <xsl:variable name="name" select="@name"/>
            <xsl:variable name="value" select="."/>
            <xsl:variable name="translation" select="//msg:message[@name=$name and lang($destlang)]"/>
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
        <span class="param">{<xsl:value-of select="@name"/>}</span>
    </xsl:template>


</xsl:transform>
