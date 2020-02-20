<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="urn:stylesheet-functions"
                version="3.0">
   <xsl:output method="xml" indent="yes"/>
   <xsl:template match="/">
      <xsl:value-of select="f:transliterate('ABCIQ3IQCBAQRS')"/>
   </xsl:template>
   <xsl:function name="f:transliterate" as="xs:string">
      <xsl:param name="string" as="xs:string"/>
      <xsl:apply-templates select="$string" mode="xyz"/>
   </xsl:function>
   <xsl:template match=".[starts-with(., 'ABC')]" mode="xyz" priority="3">
      <xsl:text>DEF</xsl:text>
      <xsl:apply-templates select="substring(., string-length(.))" mode="zyx"/>
   </xsl:template>
   <xsl:template match=".[starts-with(., 'QRS')]" mode="xyz" priority="3">
      <xsl:text>TUV</xsl:text>
      <xsl:apply-templates select="substring(., string-length(.))" mode="#current"/>
   </xsl:template>
   <xsl:template match="." mode="@name">
      <xsl:message expand-text="yes">ERROR: Unmatched character {substring(., 0, 1)}</xsl:message>
      <xsl:apply-templates select="substring(., 1)" mode="#current"/>
   </xsl:template>
   <xsl:template match=".[starts-with(., 'CBA')]" mode="zyx" priority="3">
      <xsl:text>DEF</xsl:text>
      <xsl:apply-templates select="substring(., string-length(.))" mode="xyz"/>
   </xsl:template>
   <xsl:template match=".[starts-with(., 'IQ')]" mode="zyx" priority="2">
      <xsl:text>QQ</xsl:text>
      <xsl:apply-templates select="substring(., string-length(.))" mode="#current"/>
   </xsl:template>
   <xsl:template match=".[starts-with(., 'IQ3')]" mode="zyx" priority="3">
      <xsl:text>QQQ</xsl:text>
      <xsl:apply-templates select="substring(., string-length(.))" mode="#current"/>
   </xsl:template>
   <xsl:template match="." mode="@name">
      <xsl:text expand-text="yes">{substring(., 0, 1)}</xsl:text>
      <xsl:apply-templates select="substring(., 1)" mode="#current"/>
   </xsl:template>
</xsl:stylesheet>
