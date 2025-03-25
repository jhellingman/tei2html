<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    version="3.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="no"/>

    <xsl:template match="*">
        <xsl:element name="tei:{local-name(.)}">
            <xsl:apply-templates select="@*|*|text()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:attribute name="{name(.)}"><xsl:value-of select="."/></xsl:attribute>
    </xsl:template>

</xsl:stylesheet>
