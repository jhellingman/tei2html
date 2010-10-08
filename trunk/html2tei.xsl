<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:html="http://www.w3.org/1999/xhtml" 
    xmlns:mf="http://example.com/mf" 
    exclude-result-prefixes="mf html">

<xsl:output method="xml" indent="no"/>



<!-- Main block-level conversions -->
<xsl:template match="html:html">
    <xsl:apply-templates select="html:body"/>
</xsl:template>


<!-- Reconstruct structure of divisions, based on HTML h1..h6 headings
     Note that this will create correctly nested div1..div5 levels, even
     if some h-levels are skipped in the source HTML. You may however get
     more div-levels than you want, and post-processing will be required. -->
<xsl:template match="html:body">
    <body>
        <xsl:call-template name="level1">
            <xsl:with-param name="nodes" select="*|text()"/>
            <xsl:with-param name="level" select="1"/>
        </xsl:call-template>
    </body>
</xsl:template>


<xsl:template name="level1">
    <xsl:param name="nodes" as="element()*"/>
    <xsl:param name="level" as="xs:integer"/>
    
    <xsl:choose>
        <xsl:when test="$nodes/self::html:h1">
            <xsl:for-each-group select="$nodes" group-starting-with="html:h1">
                <xsl:element name="{concat('div', $level)}">
                    <xsl:call-template name="level2">
                        <xsl:with-param name="nodes" select="current-group()"/>
                        <xsl:with-param name="level" select="$level + 1"/>
                    </xsl:call-template>
                </xsl:element>
            </xsl:for-each-group>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="level2">
                <xsl:with-param name="nodes" select="$nodes"/>
                <xsl:with-param name="level" select="$level"/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="level2">
    <xsl:param name="nodes" as="element()*"/>
    <xsl:param name="level" as="xs:integer"/>
    
    <xsl:choose>
        <xsl:when test="$nodes/self::html:h2">
            <xsl:for-each-group select="$nodes" group-starting-with="html:h2">
                <xsl:element name="{concat('div', $level)}">
                    <xsl:call-template name="level3">
                        <xsl:with-param name="nodes" select="current-group()"/>
                        <xsl:with-param name="level" select="$level + 1"/>
                    </xsl:call-template>
                </xsl:element>
            </xsl:for-each-group>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="level3">
                <xsl:with-param name="nodes" select="$nodes"/>
                <xsl:with-param name="level" select="$level"/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="level3">
    <xsl:param name="nodes" as="element()*"/>
    <xsl:param name="level" as="xs:integer"/>
    
    <xsl:choose>
        <xsl:when test="$nodes/self::html:h3">
            <xsl:for-each-group select="$nodes" group-starting-with="html:h3">
                <xsl:element name="{concat('div', $level)}">
                    <xsl:call-template name="level4">
                        <xsl:with-param name="nodes" select="current-group()"/>
                        <xsl:with-param name="level" select="$level + 1"/>
                    </xsl:call-template>
                </xsl:element>
            </xsl:for-each-group>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="level4">
                <xsl:with-param name="nodes" select="$nodes"/>
                <xsl:with-param name="level" select="$level"/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="level4">
    <xsl:param name="nodes" as="element()*"/>
    <xsl:param name="level" as="xs:integer"/>
    
    <xsl:choose>
        <xsl:when test="$nodes/self::html:h4">
            <xsl:for-each-group select="$nodes" group-starting-with="html:h4">
                <xsl:element name="{concat('div', $level)}">
                    <xsl:call-template name="level5">
                        <xsl:with-param name="nodes" select="current-group()"/>
                        <xsl:with-param name="level" select="$level + 1"/>
                    </xsl:call-template>
                </xsl:element>
            </xsl:for-each-group>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="level5">
                <xsl:with-param name="nodes" select="$nodes"/>
                <xsl:with-param name="level" select="$level"/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="level5">
    <xsl:param name="nodes" as="element()*"/>
    <xsl:param name="level" as="xs:integer"/>
    
    <xsl:choose>
        <xsl:when test="$nodes/self::html:h5">
            <xsl:for-each-group select="$nodes" group-starting-with="html:h5">
                <xsl:element name="{concat('div', $level)}">
                    <xsl:call-template name="level6">
                        <xsl:with-param name="nodes" select="current-group()"/>
                        <xsl:with-param name="level" select="$level + 1"/>
                    </xsl:call-template>
                </xsl:element>
            </xsl:for-each-group>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="level6">
                <xsl:with-param name="nodes" select="$nodes"/>
                <xsl:with-param name="level" select="$level"/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<xsl:template name="level6">
    <xsl:param name="nodes" as="element()*"/>
    <xsl:param name="level" as="xs:integer"/>

    <xsl:apply-templates select="$nodes/self::*"/>
</xsl:template>











<!-- Paragraphs -->
<xsl:template match="html:p">
    <xsl:choose>
        <xsl:when test="normalize-space(.) = ''">
            <xsl:apply-templates/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:text>
</xsl:text>
            <p>
                <xsl:apply-templates/>
            </p>
            <xsl:text>
</xsl:text>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- Ignore empty paragraphs -->
<xsl:template match="html:p[normalize-space(.) = '' and count(*) = 0]"/>


<xsl:template match="text()">
    <xsl:copy/>
</xsl:template>



<!-- inline formatting -->
<xsl:template match="html:b">
    <hi rend="bold">
        <xsl:apply-templates/>
    </hi>
</xsl:template>

<xsl:template match="html:i">
 <hi>
  <xsl:apply-templates/>
 </hi>
</xsl:template>

<xsl:template match="html:small">
  <xsl:apply-templates/>
</xsl:template>


<xsl:template match="html:br">
    <lb/>
</xsl:template>



<!-- External links -->
<xsl:template match="html:a[contains(@href,'http://') or contains(@href,'ftp://')]">
 <xref>
  <xsl:attribute name="url">
   <xsl:value-of select="normalize-space(@href)"/>
  </xsl:attribute>
  <xsl:apply-templates/>
 </xref>
</xsl:template>

<!-- Internal cross references -->
<xsl:template match="html:a[contains(@href,'#')]">
 <ref>
  <xsl:attribute name="target">
    <xsl:value-of select="substring-after(@href,'#')"/>
  </xsl:attribute>
  <xsl:apply-templates/>
 </ref>
</xsl:template>

<xsl:template match="html:a">
  <xsl:apply-templates/>
</xsl:template>



<!-- Block level elements -->

<xsl:template match="html:h1|html:h2|html:h3|html:h4">
    <head>
        <xsl:apply-templates/>
    </head>
</xsl:template>


<xsl:template match="html:hr">
    <milestone unit="tb"/>
</xsl:template>


<xsl:template match="html:div|html:span|html:pre">
    <xsl:apply-templates/>
</xsl:template>





<!-- Images -->
<xsl:template match="html:img">
 
 
</xsl:template>




<!-- Lists -->
<xsl:template match="html:ul">
 <list>
  <xsl:apply-templates/>
 </list>
</xsl:template>

<xsl:template match="html:ol">
 <list>
  <xsl:apply-templates/>
 </list>
</xsl:template>
        
<xsl:template match="html:li">
 <item>
    <xsl:apply-templates/>
 </item>
</xsl:template>
        



<!-- Tables -->
<xsl:template match="html:table">
    <table>
        <xsl:apply-templates/>
    </table>
</xsl:template>


<xsl:template match="html:tbody">
    <xsl:apply-templates/>
</xsl:template>


<xsl:template match="html:tr">
    <row>
        <xsl:apply-templates/>
    </row>
</xsl:template>

<xsl:template match="html:th|html:td">
 <xsl:variable name="position" select="count(preceding-sibling::*) + 1"/>
 <cell>
  <xsl:if test="@colspan &gt; 1">
   <xsl:attribute name="cols">
    <xsl:value-of select="@colspan"/>
   </xsl:attribute>
  </xsl:if>
  <xsl:if test="@rowspan &gt; 1">
   <xsl:attribute name="rows">
    <xsl:value-of select="@rowspan"/>
   </xsl:attribute>
  </xsl:if>
  <xsl:apply-templates/>
 </cell>
</xsl:template>


<!-- Stop processing when an unknown element is encountered -->     
<xsl:template match="*">
 <xsl:message>Unhandled element <xsl:value-of select="name()"/>
 </xsl:message>
 <xsl:apply-templates/>
</xsl:template>


</xsl:stylesheet>