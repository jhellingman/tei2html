<!DOCTYPE xsl:stylesheet [

    <!ENTITY cr         "&#x0D;">
    <!ENTITY lf         "&#x0A;">
    <!ENTITY crlf       "&#x0D;&#x0A;">
]>

<xsl:transform version="2.0"
    xmlns:f="urn:stylesheet-functions"
    xmlns:msg="http://www.gutenberg.ph/2006/schemas/messages"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f msg xd xs">

    <xsl:output
        method="text"
        encoding="utf-8"/>

    <xd:doc type="stylesheet">
        <xd:short>TEI stylesheet to review translations in our localization xml-files.</xd:short>
        <xd:detail> </xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:param name="srclang" select="'en'"/>
    <xsl:param name="destlang" select="'es'"/>


    <xsl:variable name="crlf" select="'nl'"/>


    <xsl:strip-space elements="*"/>

    <xsl:template match="/">
        <!--
        <xsl:text>Missing Translations in </xsl:text><xsl:value-of select="//msg:message[@name=$destlang and lang('en')]"/><xsl:text>&crlf;</xsl:text>
        
        <xsl:text>Message ID,Message in </xsl:text><xsl:value-of select="//msg:message[@name=$srclang and lang('en')]"/><xsl:text>&crlf;</xsl:text>

        <xsl:apply-templates select="//msg:message" mode="missing"/>
        -->

        <xsl:text>Overview of Available Translations in </xsl:text><xsl:value-of select="//msg:message[@name=$destlang and lang('en')]"/><xsl:text>&crlf;</xsl:text>
        
        <xsl:text>Message ID,Message in </xsl:text><xsl:value-of select="//msg:message[@name=$srclang and lang('en')]"/>
        <xsl:text>,Message in </xsl:text><xsl:value-of select="//msg:message[@name=$destlang and lang('en')]"/><xsl:text>&crlf;</xsl:text>

        <xsl:apply-templates select="//msg:message" mode="review"/>
    </xsl:template>


    <xsl:template match="msg:message" mode="missing">
        <xsl:if test="lang($srclang)">
            <xsl:variable name="name" select="@name"/>
            <xsl:variable name="value" select="."/>
            <xsl:if test="not(//msg:message[@name=$name and lang($destlang)])">

                <xsl:variable name="cp-value" as="xs:string">
                    <xsl:apply-templates select="$value" mode="cp"/>
                </xsl:variable>

                <xsl:value-of select="@name"/><xsl:text>,</xsl:text>
                <xsl:choose>
                    <xsl:when test="string-length($value) &lt; 500">
                        <xsl:value-of select="f:escape-for-csv($cp-value)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>[long message omitted]</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>&crlf;</xsl:text>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xsl:template match="msg:message" mode="review">
        <xsl:if test="lang($srclang)">
            <xsl:variable name="name" select="@name"/>
            <xsl:variable name="value" select="."/>
            <xsl:variable name="translation" select="//msg:message[@name=$name and lang($destlang)][1]"/>

            <xsl:if test="string-length($value) &lt; 500">
                <xsl:variable name="cp-value" as="xs:string">
                    <xsl:apply-templates select="$value" mode="cp"/>
                </xsl:variable>

                <xsl:value-of select="@name"/><xsl:text>,</xsl:text>
                <xsl:value-of select="f:escape-for-csv($cp-value)"/><xsl:text>,</xsl:text>
                <xsl:choose>
                    <xsl:when test="$translation">
                        <xsl:variable name="cp-translation" as="xs:string">
                            <xsl:apply-templates select="$translation" mode="cp"/>
                        </xsl:variable>
                        <xsl:value-of select="f:escape-for-csv($cp-translation)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>[no translation available]</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>&crlf;</xsl:text>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xsl:template match="*" mode="cp">
        <xsl:copy>
            <xsl:apply-templates mode="cp"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="msg:param" mode="cp">
        <xsl:text>{</xsl:text><xsl:value-of select="@name"/><xsl:text>}</xsl:text>
    </xsl:template>


    <xsl:function name="f:escape-for-csv" as="xs:string">
        <xsl:param name="string" as="xs:string"/>

        <xsl:value-of select="if (contains($string, ',')) then concat('&quot;', $string, '&quot;') else $string"/>
    </xsl:function>


</xsl:transform>
