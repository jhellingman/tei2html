<?xml version="1.0" encoding="Latin1"?>
<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xslo="http://www.w3.org/1999/XSL/Transform/Output"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="urn:stylesheet-functions"
    >

    <xsl:output method="xml" indent="yes"/>

    <xsl:namespace-alias stylesheet-prefix="xslo" result-prefix="xsl"/>

    <!-- convert pattern file to XSLT templates -->

    <xsl:variable name="testPattern">
        <patternFile>
            <patterns name="firstSet" noMatch="error">
                <pattern match="ABC"><put value="DEF"/><switch name="secondSet"/></pattern>
                <pattern match="DEF"><put value="ABC"/></pattern>
            </patterns>
            <patterns name="secondSet" noMatch="copy">
                <pattern match="ABC"><put value="DEF"/><switch name="firstSet"/></pattern>
                <pattern match="Q"><put value="Q1"/></pattern>
                <pattern match="QQ"><put value="Q2"/></pattern>
                <pattern match="QQQ"><put value="Q3"/></pattern>
            </patterns>
        </patternFile>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:apply-templates select="$testPattern/*"/>
    </xsl:template>

    <xsl:template match="patternFile">

        <xslo:stylesheet version="3.0">
            <xslo:output method="xml" indent="yes"/>

            <xslo:template match="/">
                <xslo:value-of select="f:transliterate('QABCQQQQQABCDEF')"/>
            </xslo:template>

            <xslo:function name="f:transliterate" as="xs:string">
                <xslo:param name="string" as="xs:string"/>
                <xslo:variable name="result">
                    <xslo:apply-templates select="$string" mode="{./patterns[1]/@name}"/>
                </xslo:variable>
                <xslo:value-of select="$result"/>
            </xslo:function>

            <xsl:apply-templates/>

        </xslo:stylesheet>
    </xsl:template>

    <xsl:template match="patterns[@noMatch='error']">
        <xsl:apply-templates/>

        <xslo:template match="." mode="{@name}">
            <xslo:message expand-text="yes">ERROR: Unmatched character: '{substring(., 1, 1)}'</xslo:message>
            <xslo:apply-templates select="substring(., 2)" mode="#current"/>
        </xslo:template>

        <xslo:template match=".[. = '']" mode="{@name}"/>
    </xsl:template>

    <xsl:template match="patterns[@noMatch='copy']">
        <xsl:apply-templates/>

        <xslo:template match="." mode="{@name}">
            <xslo:text expand-text="yes">{substring(., 1, 1)}</xslo:text>
            <xslo:apply-templates select="substring(., 2)" mode="#current"/>
        </xslo:template>

        <xslo:template match=".[. = '']" mode="{@name}"/>
    </xsl:template>

    <xsl:template match="pattern">
        <xslo:template match=".[starts-with(., '{@match}')]" mode="{../@name}" priority="{string-length(@match)}">
            <!-- <xslo:message expand-text="yes">Match: <xsl:value-of select="@match"/> called with: {.} in mode <xsl:value-of select="../@name"/>; continue with <xslo:value-of select="substring(., {string-length(@match) + 1})"/></xslo:message> -->

            <xsl:if test="put/@value">
                <xslo:text><xsl:value-of select="put/@value"/></xslo:text>
            </xsl:if>
            <xslo:apply-templates 
                select="substring(., {string-length(@match) + 1})" 
                mode="{if (switch/@name) then switch/@name else '#current'}"/>
        </xslo:template>
    </xsl:template>

</xsl:stylesheet>









