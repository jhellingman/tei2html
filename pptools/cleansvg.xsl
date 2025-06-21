<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:svg="http://www.w3.org/2000/svg">

  <!-- Identity transform: copy everything by default -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Remove aria-* attributes -->
  <xsl:template match="@*[starts-with(name(), 'aria-')]"/>

  <!-- Remove role and focusable attributes from svg elements only -->
  <xsl:template match="svg:svg/@role"/>
  <xsl:template match="svg:svg/@focusable"/>

</xsl:stylesheet>
