<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="urn:stylesheet-functions"
                version="3.0">
   <xsl:output method="xml" indent="yes"/>
   <xsl:template match="/">
      <xsl:value-of select="f:transliterate('QABCQQQQQABCDEF')"/>
   </xsl:template>
   <xsl:function name="f:transliterate" as="xs:string">
      <xsl:param name="string" as="xs:string"/>
      <xsl:variable name="result">
         <xsl:apply-templates select="$string" mode="firstSet"/>
      </xsl:variable>
      <xsl:value-of select="$result"/>
   </xsl:function>
   <xsl:template match=".[starts-with(., 'ABC')]" mode="firstSet" priority="3">
      <xsl:text>DEF</xsl:text>
      <xsl:apply-templates select="substring(., 4)" mode="secondSet"/>
   </xsl:template>
   <xsl:template match=".[starts-with(., 'DEF')]" mode="firstSet" priority="3">
      <xsl:text>ABC</xsl:text>
      <xsl:apply-templates select="substring(., 4)" mode="#current"/>
   </xsl:template>
   <xsl:template match="." mode="firstSet">
      <xsl:message expand-text="yes">ERROR: Unmatched character: '{substring(., 1, 1)}'</xsl:message>
      <xsl:apply-templates select="substring(., 2)" mode="#current"/>
   </xsl:template>
   <xsl:template match=".[. = '']" mode="firstSet"/>
   <xsl:template match=".[starts-with(., 'ABC')]" mode="secondSet" priority="3">
      <xsl:text>DEF</xsl:text>
      <xsl:apply-templates select="substring(., 4)" mode="firstSet"/>
   </xsl:template>
   <xsl:template match=".[starts-with(., 'Q')]" mode="secondSet" priority="1">
      <xsl:text>Q1</xsl:text>
      <xsl:apply-templates select="substring(., 2)" mode="#current"/>
   </xsl:template>
   <xsl:template match=".[starts-with(., 'QQ')]" mode="secondSet" priority="2">
      <xsl:text>Q2</xsl:text>
      <xsl:apply-templates select="substring(., 3)" mode="#current"/>
   </xsl:template>
   <xsl:template match=".[starts-with(., 'QQQ')]" mode="secondSet" priority="3">
      <xsl:text>Q3</xsl:text>
      <xsl:apply-templates select="substring(., 4)" mode="#current"/>
   </xsl:template>
   <xsl:template match="." mode="secondSet">
      <xsl:text expand-text="yes">{substring(., 1, 1)}</xsl:text>
      <xsl:apply-templates select="substring(., 2)" mode="#current"/>
   </xsl:template>
   <xsl:template match=".[. = '']" mode="secondSet"/>
</xsl:stylesheet>
