<xsl:transform
    xmlns:msg="http://www.gutenberg.ph/2006/schemas/messages"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    version="1.0"
    exclude-result-prefixes="msg xd">

    <xsl:output
        doctype-system="http://www.gutenberg.ph/2006/schemas/messages"
        method="xml"
        encoding="UTF-8"/>

    <xd:doc type="stylesheet">
        <xd:short>TEI stylesheet to review translations in our localization xml-files.</xd:short>
        <xd:detail> </xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:param name="srclang" select="'en'"/>
    <xsl:param name="destlang" select="'es'"/>

    <xsl:strip-space elements="*"/>

    <xsl:template match="/">
        <msg:repository
            xmlns:msg="http://www.gutenberg.ph/2006/schemas/messages"
            version="1.0">

            <msg:messages xml:lang="{$destlang}">
                <xsl:apply-templates select="//msg:message" mode="missing"/>
            </msg:messages>
        </msg:repository>
    </xsl:template>


    <xsl:template match="msg:message" mode="missing">
        <xsl:if test="lang($srclang)">
            <xsl:variable name="name" select="@name"/>
            <xsl:if test="not(//msg:message[@name=$name and lang($destlang)])">
                <msg:message name="{$name}">
                    <xsl:text>[</xsl:text>
                    <xsl:apply-templates mode="cp"/>
                    <xsl:text>]</xsl:text>
                </msg:message>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xsl:template match="msg:message" mode="review">
        <xsl:if test="lang($srclang)">
            <xsl:variable name="name" select="@name"/>
            <xsl:variable name="value" select="."/>
            <xsl:variable name="translation" select="//msg:message[@name=$name and lang($destlang)]"/>

            <msg:message name="{$name}">
                    <xsl:choose>
                        <xsl:when test="$translation">
                            <xsl:apply-templates select="$translation" mode="cp"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>[</xsl:text>
                            <xsl:apply-templates select="$value" mode="cp"/>
                            <xsl:text>]</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
            </msg:message>
        </xsl:if>
    </xsl:template>


    <xsl:template match="*" mode="cp">
        <xsl:copy>
            <xsl:apply-templates mode="cp"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="msg:param" mode="cp">
        <msg:param name="{@name}"/>
    </xsl:template>


</xsl:transform>
