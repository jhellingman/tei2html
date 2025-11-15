<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
    xmlns:edate="http://exslt.org/dates-and-times"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei edate f xs">

    <!--
         P4 to P5 converter

         Sebastian Rahtz <sebastian.rahtz@oucs.ox.ac.uk>

         $Date: 2007-11-01 16:33:34 +0000 (Thu, 01 Nov 2007) $  $Id: p4top5.xsl 3927 2007-11-01 16:33:34Z rahtz $

         Copyright 2007 TEI Consortium

         Permission is hereby granted, free of charge, to any person obtaining
         a copy of this software and any associated documentation files (the
         ``Software''), to deal in the Software without restriction, including
         without limitation the rights to use, copy, modify, merge, publish,
         distribute, sublicense, and/or sell copies of the Software, and to
         permit persons to whom the Software is furnished to do so, subject to
         the following conditions:

         The above copyright notice and this permission notice shall be included
         in all copies or substantial portions of the Software.
    -->

    <xsl:output
        method="xml"
        encoding="utf-8"
        cdata-section-elements="tei:eg"
        omit-xml-declaration="yes"/>

    <xsl:variable name="processor">
        <xsl:value-of select="system-property('xsl:vendor')"/>
    </xsl:variable>

    <xsl:variable name="today">
        <xsl:choose>
            <xsl:when test="function-available('edate:date-time')">
                <xsl:value-of select="edate:date-time()"/>
            </xsl:when>
            <xsl:when test="contains($processor, 'SAXON')">
                <xsl:value-of select="Date:toString(Date:new())" xmlns:Date="/java.util.Date"/>
            </xsl:when>
            <xsl:otherwise>0000-00-00</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="uc">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
    <xsl:variable name="lc">abcdefghijklmnopqrstuvwxyz</xsl:variable>

    <xsl:template match="*">
        <xsl:choose>
            <xsl:when test="namespace-uri()=''">
                <xsl:element name="{local-name(.)}">
                    <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="@*|processing-instruction()|comment()">
        <xsl:copy/>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:value-of select="."/>
    </xsl:template>


    <!-- change of name, or replaced by another element -->
    <xsl:template match="teiCorpus.2">
        <teiCorpus>
            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
        </teiCorpus>
    </xsl:template>

    <xsl:template match="witness/@sigil">
        <xsl:attribute name="xml:id">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="witList">
        <listWit>
            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
        </listWit>
    </xsl:template>

    <xsl:template match="TEI.2">
        <TEI>
            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
        </TEI>
    </xsl:template>

    <xsl:template match="xref">
        <ref>
            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
        </ref>
    </xsl:template>

    <xsl:template match="xptr">
        <ptr>
            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
        </ptr>
    </xsl:template>


    <xsl:template match="figure[@url]">
        <figure>
            <graphic>
                <xsl:copy-of select="@*"/>
            </graphic>
            <xsl:apply-templates/>
        </figure>
    </xsl:template>

    <xsl:template match="figure/@url"/>

    <xsl:template match="figure/@entity"/>

    <xsl:template match="figure[@entity]">
        <figure>
            <graphic url="{unparsed-entity-uri(@entity)}">
                <xsl:apply-templates select="@*"/>
            </graphic>
            <xsl:apply-templates/>
        </figure>
    </xsl:template>

    <xsl:template match="event">
        <incident>
            <xsl:apply-templates select="@*|*|text()|comment()|processing-instruction()"/>
        </incident>
    </xsl:template>

    <xsl:template match="state">
        <refState>
            <xsl:apply-templates select="@*|*|text()|comment()|processing-instruction()"/>
        </refState>
    </xsl:template>


    <!-- lost elements -->
    <xsl:template match="dateRange">
        <date>
            <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
        </date>
    </xsl:template>

    <xsl:template match="dateRange/@from">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="dateRange/@to">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="language">
        <xsl:element name="language">
            <xsl:if test="@id">
                <xsl:attribute name="ident">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="*|processing-instruction()|comment()|text()"/>
        </xsl:element>
    </xsl:template>


    <!-- attributes lost -->
    <!-- dropped from TEI. Added as new change records later -->
    <xsl:template match="@date.created"/>

    <xsl:template match="@date.updated"/>


    <!-- dropped from TEI. No replacement -->
    <xsl:template match="refsDecl/@doctype"/>


    <!-- attributes changed name -->

    <xsl:template match="date/@value">
        <xsl:attribute name="when">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="@url">
        <xsl:attribute name="target">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="@doc">
        <xsl:attribute name="target">
            <xsl:value-of select="unparsed-entity-uri(.)"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="@id">
        <xsl:choose>
            <xsl:when test="parent::lang">
                <xsl:attribute name="ident">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="."/>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="@lang">
        <xsl:attribute name="xml:lang">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="change/@date"/>

    <xsl:template match="date/@certainty">
        <xsl:attribute name="cert">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

  <!-- all pointing attributes preceded by # -->

  <xsl:template match="variantEncoding/@location">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="@ana|@active|@adj|@adjFrom|@adjTo|@children|@children|@class|@code|@code|@copyOf|@corresp|@decls|@domains|@end|@exclude|@fVal|@feats|@follow|@from|@hand|@inst|@langKey|@location|@mergedin|@new|@next|@old|@origin|@otherLangs|@parent|@passive|@perf|@prev|@render|@resp|@sameAs|@scheme|@script|@select|@since|@start|@synch|@target|@targetEnd|@to|@to|@value|@value|@who|@wit">
    <xsl:attribute name="{name(.)}">
      <xsl:call-template name="splitter">
        <xsl:with-param name="val">
          <xsl:value-of select="."/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:attribute>
  </xsl:template>


  <xsl:template name="splitter">
    <xsl:param name="val"/>
    <xsl:choose>
      <xsl:when test="contains($val, ' ')">
        <xsl:text>#</xsl:text>
        <xsl:value-of select="substring-before($val, ' ')"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="splitter">
          <xsl:with-param name="val">
            <xsl:value-of select="substring-after($val, ' ')"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>#</xsl:text>
        <xsl:value-of select="$val"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- fool around with selected elements -->


  <!-- imprint is no longer allowed inside bibl -->
  <xsl:template match="bibl/imprint">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="editionStmt/editor">
    <respStmt>
      <resp><xsl:value-of select="@role"/></resp>
      <name><xsl:apply-templates/></name>
    </respStmt>
  </xsl:template>

  <!-- header -->

  <xsl:template match="teiHeader">
    <teiHeader>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()"/>

      <xsl:if test="not(revisionDesc) and (@date.created or @date.updated)">
        <revisionDesc>
          <xsl:if test="@date.updated">
            <change>
              <label>updated</label>
              <date>
                <xsl:value-of select="@date.updated"/>
              </date>
              <label>Date edited</label>
            </change>
          </xsl:if>
          <xsl:if test="@date.created">
            <change>
              <label>created</label>
              <date>
                <xsl:value-of select="@date.created"/>
              </date>
              <label>Date created</label>
            </change>
          </xsl:if>
        </revisionDesc>
      </xsl:if>
      <!--
      <change when="{$today}" >Converted to TEI P5 XML by p4top5.xsl
      written by Sebastian
      Rahtz at Oxford University Computing Services.</change>
      </revisionDesc>
      </xsl:if>
      -->
    </teiHeader>
  </xsl:template>

  <xsl:template match="revisionDesc">
    <revisionDesc>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()"/>
    </revisionDesc>
  </xsl:template>

  <xsl:template match="publicationStmt">
    <publicationStmt>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()"/>
      <!--
      <availability>
      <p>Licensed under <ptr target="http://creativecommons.org/licenses/by-sa/2.0/uk/"/></p>
      </availability>
      -->
    </publicationStmt>
  </xsl:template>

  <!-- space does not have @extent anymore -->
  <xsl:template match="space/@extent">
    <xsl:attribute name="quantity">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="tagsDecl">
    <xsl:if test="*">
      <tagsDecl>
          <xsl:apply-templates select="*|comment()|processing-instruction"/>
      </tagsDecl>
    </xsl:if>
  </xsl:template>

  <!-- orgTitle inside orgName? redundant -->
  <xsl:template match="orgName/orgTitle">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- no need for empty <p> in sourceDesc -->
  <xsl:template match="sourceDesc/p[string-length(.)=0]"/>

  <!-- start creating the new choice element -->
  <xsl:template match="corr[@sic]">
    <choice>
      <corr>
        <xsl:value-of select="text()"/>
      </corr>
      <sic>
        <xsl:value-of select="@sic"/>
      </sic>
    </choice>
  </xsl:template>

  <xsl:template match="sic[@corr]">
    <choice>
      <sic>
        <xsl:value-of select="text()"/>
      </sic>
      <corr>
        <xsl:value-of select="@corr"/>
      </corr>
    </choice>
  </xsl:template>

  <xsl:template match="abbr[@expan]">
    <choice>
      <abbr>
        <xsl:value-of select="text()"/>
      </abbr>
      <expan>
        <xsl:value-of select="@expan"/>
      </expan>
    </choice>
  </xsl:template>

  <xsl:template match="expan[@abbr]">
    <choice>
      <expan>
        <xsl:value-of select="text()"/>
      </expan>
      <abbr>
        <xsl:value-of select="@abbr"/>
      </abbr>
    </choice>
  </xsl:template>

  <xsl:template match="orig[@reg]">
    <choice>
      <orig>
        <xsl:value-of select="text()"/>
      </orig>
      <reg>
        <xsl:value-of select="@reg"/>
      </reg>
    </choice>
  </xsl:template>

  <xsl:template match="reg[@orig]">
    <choice>
      <reg>
        <xsl:value-of select="text()"/>
      </reg>
      <orig>
        <xsl:value-of select="@orig"/>
      </orig>
    </choice>
  </xsl:template>

  <!-- special consideration for <change> element -->
  <xsl:template match="change">
    <change>

      <xsl:apply-templates select="date"/>

      <xsl:if test="respStmt/resp">
        <label>
          <xsl:value-of select="respStmt/resp/text()"/>
        </label>
      </xsl:if>
      <xsl:for-each select="respStmt/name">
        <name>
          <xsl:apply-templates select="@*|*|comment()|processing-instruction()|text()"/>
        </name>
      </xsl:for-each>
      <xsl:for-each select="item">
        <xsl:apply-templates select="@*|*|comment()|processing-instruction()|text()"/>
      </xsl:for-each>
    </change>
  </xsl:template>


  <xsl:template match="respStmt[resp]">
    <respStmt>
      <xsl:choose>
        <xsl:when test="resp/name">
          <resp>
            <xsl:value-of select="resp/text()"/>
          </resp>
          <xsl:for-each select="resp/name">
            <name>
              <xsl:apply-templates/>
            </name>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </respStmt>
  </xsl:template>

  <xsl:template match="q/@direct"/>

  <xsl:template match="q">
    <q>
      <xsl:apply-templates select="@*|*|comment()|processing-instruction()|text()"/>
    </q>
  </xsl:template>


  <!-- if we are reading the P4 with a DTD, we need to avoid copying the default values
       of attributes -->

  <xsl:template match="@targOrder">
    <xsl:if test="not(translate(.,$uc,$lc) = 'u')">
      <xsl:attribute name="targOrder">
        <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>


  <xsl:template match="@opt">
    <xsl:if test="not(translate(.,$uc,$lc) = 'n')">
      <xsl:attribute name="opt">
        <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>


  <xsl:template match="@to">
    <xsl:if test="not(translate(.,$uc,$lc) = 'ditto')">
      <xsl:attribute name="to">
        <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>


  <xsl:template match="@default">
    <xsl:choose>
      <xsl:when test="translate(.,$uc,$lc) = 'no'"/>
      <xsl:otherwise>
        <xsl:attribute name="default">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="@part">
    <xsl:if test="not(translate(.,$uc,$lc) = 'n')">
      <xsl:attribute name="part">
        <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>


  <xsl:template match="@full">
    <xsl:if test="not(translate(.,$uc,$lc) = 'yes')">
      <xsl:attribute name="full">
        <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>


  <xsl:template match="@from">
    <xsl:if test="not(translate(.,$uc,$lc) = 'root')">
      <xsl:attribute name="from">
        <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>


  <xsl:template match="@status">
    <xsl:choose>
      <xsl:when test="parent::teiHeader">
        <xsl:if test="not(translate(.,$uc,$lc) = 'new')">
          <xsl:attribute name="status">
            <xsl:value-of select="."/>
          </xsl:attribute>
        </xsl:if>
      </xsl:when>
      <xsl:when test="parent::del">
        <xsl:if test="not(translate(.,$uc,$lc) = 'unremarkable')">
          <xsl:attribute name="status">
            <xsl:value-of select="."/>
          </xsl:attribute>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="status">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="@place">
    <xsl:if test="not(translate(.,$uc,$lc) = 'unspecified')">
      <xsl:attribute name="place">
        <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>


  <xsl:template match="@sample">
    <xsl:if test="not(translate(.,$uc,$lc) = 'complete')">
      <xsl:attribute name="sample">
        <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>


  <xsl:template match="@org">
    <xsl:if test="not(translate(.,$uc,$lc) = 'uniform')">
      <xsl:attribute name="org">
        <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template match="teiHeader/@type">
    <xsl:if test="not(translate(.,$uc,$lc) = 'text')">
      <xsl:attribute name="type">
        <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <!-- yes|no to boolean -->

  <xsl:template match="@anchored">
    <xsl:attribute name="anchored">
      <xsl:choose>
        <xsl:when test="translate(.,$uc,$lc) = 'yes'">true</xsl:when>
        <xsl:when test="translate(.,$uc,$lc) = 'no'">false</xsl:when>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="sourceDesc/@default"/>

  <xsl:template match="@tei">
    <xsl:attribute name="tei">
      <xsl:choose>
        <xsl:when test="translate(.,$uc,$lc) = 'yes'">true</xsl:when>
        <xsl:when test="translate(.,$uc,$lc) = 'no'">false</xsl:when>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@langKey"/>

  <xsl:template match="@TEIform"/>

  <!-- assorted atts -->
  <xsl:template match="@old"/>

  <xsl:template match="@mergedin">
    <xsl:attribute name="mergedIn">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <!-- deal with the loss of div0 -->
  <xsl:template match="div1|div2|div3|div4|div5|div6">
    <xsl:variable name="divName">
      <xsl:choose>
        <xsl:when test="ancestor::div0">
          <xsl:text>div</xsl:text>
          <xsl:value-of select="number(substring-after(local-name(.),'div')) + 1"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="local-name()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$divName}">
      <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="div0">
    <div1>
        <xsl:apply-templates select="*|@*|processing-instruction()|comment()|text()"/>
    </div1>
  </xsl:template>

  <!-- Additions by Jeroen Hellingman -->
 
  <!-- Clean up non-standard attributes, introduced in table-normalization -->

  <xsl:template match="cell/@col"/>
  <xsl:template match="cell/@row"/>
  <xsl:template match="table/@headrows"/>

  <!-- Convert figure handling according to my conventions in P3 -->

  <xsl:include href="modules/functions.xsl"/>
  <xsl:include href="modules/configuration.xsl"/>
  <xsl:include href="modules/log.xsl"/>
  <xsl:include href="modules/rend.xsl"/>

  <!-- Function borrowed from modules/utils.xsl -->

    <xsl:function name="f:is-inline" as="xs:boolean">
        <xsl:param name="node" as="element()"/>
        <xsl:sequence select="$node/@rend = 'inline' or f:rend-value($node/@rend, 'position') = 'inline' or f:rend-value($node/@rend, 'display') = 'inline'"/>
    </xsl:function>

  <xsl:variable name="outputFormat" select="'xml'"/>

  <!-- image file indicated in rendition ladder: rend="image(path/to/image)" -->
  <xsl:template match="figure[f:has-rend-value(@rend, 'image')]">
    <figure>
        <xsl:copy-of select="@* except @rend"/>
        <xsl:variable name="rend" select="f:remove-rend-value(@rend, 'image')"/>
        <xsl:if test="$rend">
            <xsl:attribute name="rend" select="$rend"/>
        </xsl:if>
        <graphic url="{f:rend-value(@rend, 'image')}"/>
        <xsl:apply-templates/>
    </figure>
  </xsl:template>

  <!-- image file derived from id attribute, supposed to be .jpg in a directory images -->
  <xsl:template match="figure[@id and not(f:has-rend-value(@rend, 'image'))]">
    <figure>
        <xsl:copy-of select="@*"/>
        <graphic url="{'images/' || @id || (if (f:is-inline(.)) then '.png' else '.jpg')}"/>
        <xsl:apply-templates/>
    </figure>
  </xsl:template>

  <!-- head with image above indicated in rendition ladder -->
  <xsl:template match="head[f:has-rend-value(@rend, 'image')]">
    <head>
        <xsl:variable name="rend" select="f:remove-rend-value(@rend, 'image')"/>
        <xsl:copy-of select="@* except @rend"/>           
        <xsl:if test="$rend">
            <xsl:attribute name="rend" select="$rend"/>
        </xsl:if>
        <graphic url="{f:rend-value(@rend, 'image')}"/>
        <xsl:apply-templates/>
    </head>
  </xsl:template>


</xsl:stylesheet>