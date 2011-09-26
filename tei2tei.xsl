<?xml version="1.0" encoding="utf-8"?>
<!--
$Date: 2001/05/26 $ $Author: rahtz $

 XSLT script for cleaning up the results of applying
   sx -xlower -xcomment -xempty -xndata
 to a TEI SGML file. It does an identity transform, but
 TEI element names are put back to
 their proper XML mixed case. Attributes which have the default
 values are removed. No DOCTYPE declaration is output!!!

 If you do not want UTF-8 output, change the xsl:output. If your
 input encoding was not dealt with properly by SX, you are probably
 in trouble!

 Sebastian Rahtz <sebastian.rahtz@oucs.ox.ac.uk>

 May 2001

 Copyright 2001 TEI Consortium

 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and any associated documentation gfiles (the
 ``Software''), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be included
 in all copies or substantial portions of the Software.
-->
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

<xsl:output
  cdata-section-elements="eg" 
  indent="no" 
  method="xml"
  omit-xml-declaration="yes" />

<xsl:template match="*">
 <xsl:copy>
  <xsl:apply-templates 
      select="*|@*|processing-instruction()|comment()|text()"/>
 </xsl:copy>
</xsl:template>

<xsl:template match="@*|processing-instruction()">
  <xsl:copy/>
</xsl:template>

<xsl:template match="text()">
    <xsl:value-of select="."/> <!-- could normalize() here -->
</xsl:template>

<xsl:template match="tei.2">
<TEI.2>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</TEI.2>
</xsl:template>

<xsl:template match="addname">
<addName>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</addName>
</xsl:template>

<xsl:template match="addspan">
<addSpan>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</addSpan>
</xsl:template>

<xsl:template match="addrline">
<addrLine>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</addrLine>
</xsl:template>

<xsl:template match="altgrp">
<altGrp>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</altGrp>
</xsl:template>

<xsl:template match="attdef">
<attDef>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</attDef>
</xsl:template>

<xsl:template match="attlist">
<attList>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</attList>
</xsl:template>

<xsl:template match="attname">
<attName>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</attName>
</xsl:template>

<xsl:template match="attldecl">
<attlDecl>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</attlDecl>
</xsl:template>

<xsl:template match="basewsd">
<baseWsd>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</baseWsd>
</xsl:template>

<xsl:template match="biblfull">
<biblFull>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</biblFull>
</xsl:template>

<xsl:template match="biblscope">
<biblScope>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</biblScope>
</xsl:template>

<xsl:template match="biblstruct">
<biblStruct>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</biblStruct>
</xsl:template>

<xsl:template match="castgroup">
<castGroup>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</castGroup>
</xsl:template>

<xsl:template match="castitem">
<castItem>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</castItem>
</xsl:template>

<xsl:template match="castlist">
<castList>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</castList>
</xsl:template>

<xsl:template match="catdesc">
<catDesc>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</catDesc>
</xsl:template>

<xsl:template match="catref">
<catRef>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</catRef>
</xsl:template>

<xsl:template match="classcode">
<classCode>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</classCode>
</xsl:template>

<xsl:template match="classdecl">
<classDecl>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</classDecl>
</xsl:template>

<xsl:template match="classdoc">
<classDoc>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</classDoc>
</xsl:template>

<xsl:template match="codedcharset">
<codedCharSet>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</codedCharSet>
</xsl:template>

<xsl:template match="datadesc">
<dataDesc>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</dataDesc>
</xsl:template>

<xsl:template match="daterange">
<dateRange>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</dateRange>
</xsl:template>

<xsl:template match="datestruct">
<dateStruct>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</dateStruct>
</xsl:template>

<xsl:template match="delspan">
<delSpan>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</delSpan>
</xsl:template>

<xsl:template match="divgen">
<divGen>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</divGen>
</xsl:template>

<xsl:template match="docauthor">
<docAuthor>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</docAuthor>
</xsl:template>

<xsl:template match="docdate">
<docDate>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</docDate>
</xsl:template>

<xsl:template match="docedition">
<docEdition>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</docEdition>
</xsl:template>

<xsl:template match="docimprint">
<docImprint>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</docImprint>
</xsl:template>

<xsl:template match="doctitle">
<docTitle>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</docTitle>
</xsl:template>

<xsl:template match="eleaf">
<eLeaf>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</eLeaf>
</xsl:template>

<xsl:template match="etree">
<eTree>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</eTree>
</xsl:template>

<xsl:template match="editionstmt">
<editionStmt>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</editionStmt>
</xsl:template>

<xsl:template match="editorialdecl">
<editorialDecl>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</editorialDecl>
</xsl:template>

<xsl:template match="elemdecl">
<elemDecl>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</elemDecl>
</xsl:template>

<xsl:template match="encodingdesc">
<encodingDesc>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</encodingDesc>
</xsl:template>

<xsl:template match="entdoc">
<entDoc>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</entDoc>
</xsl:template>

<xsl:template match="entname">
<entName>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</entName>
</xsl:template>

<xsl:template match="entityset">
<entitySet>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</entitySet>
</xsl:template>

<xsl:template match="entryfree">
<entryFree>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</entryFree>
</xsl:template>

<xsl:template match="extfigure">
<extFigure>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</extFigure>
</xsl:template>

<xsl:template match="falt">
<fAlt>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</fAlt>
</xsl:template>

<xsl:template match="fdecl">
<fDecl>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</fDecl>
</xsl:template>

<xsl:template match="fdescr">
<fDescr>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</fDescr>
</xsl:template>

<xsl:template match="flib">
<fLib>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</fLib>
</xsl:template>

<xsl:template match="figdesc">
<figDesc>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</figDesc>
</xsl:template>

<xsl:template match="filedesc">
<fileDesc>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</fileDesc>
</xsl:template>

<xsl:template match="firstlang">
<firstLang>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</firstLang>
</xsl:template>

<xsl:template match="forename">
<foreName>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</foreName>
</xsl:template>

<xsl:template match="forestgrp">
<forestGrp>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</forestGrp>
</xsl:template>

<xsl:template match="fsconstraints">
<fsConstraints>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</fsConstraints>
</xsl:template>

<xsl:template match="fsdecl">
<fsDecl>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</fsDecl>
</xsl:template>

<xsl:template match="fsdescr">
<fsDescr>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</fsDescr>
</xsl:template>

<xsl:template match="fslib">
<fsLib>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</fsLib>
</xsl:template>

<xsl:template match="fsddecl">
<fsdDecl>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</fsdDecl>
</xsl:template>

<xsl:template match="fvlib">
<fvLib>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</fvLib>
</xsl:template>

<xsl:template match="genname">
<genName>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</genName>
</xsl:template>

<xsl:template match="geogname">
<geogName>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</geogName>
</xsl:template>

<xsl:template match="gramgrp">
<gramGrp>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</gramGrp>
</xsl:template>

<xsl:template match="handlist">
<handList>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</handList>
</xsl:template>

<xsl:template match="handshift">
<handShift>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</handShift>
</xsl:template>

<xsl:template match="headitem">
<headItem>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</headItem>
</xsl:template>

<xsl:template match="headlabel">
<headLabel>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</headLabel>
</xsl:template>

<xsl:template match="inode">
<iNode>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</iNode>
</xsl:template>

<xsl:template match="interpgrp">
<interpGrp>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</interpGrp>
</xsl:template>

<xsl:template match="joingrp">
<joinGrp>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</joinGrp>
</xsl:template>

<xsl:template match="lacunaend">
<lacunaEnd>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</lacunaEnd>
</xsl:template>

<xsl:template match="lacunastart">
<lacunaStart>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</lacunaStart>
</xsl:template>

<xsl:template match="langknown">
<langKnown>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</langKnown>
</xsl:template>

<xsl:template match="langusage">
<langUsage>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</langUsage>
</xsl:template>

<xsl:template match="linkgrp">
<linkGrp>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</linkGrp>
</xsl:template>

<xsl:template match="listbibl">
<listBibl>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</listBibl>
</xsl:template>

<xsl:template match="metdecl">
<metDecl>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</metDecl>
</xsl:template>

<xsl:template match="namelink">
<nameLink>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</nameLink>
</xsl:template>

<xsl:template match="notesstmt">
<notesStmt>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</notesStmt>
</xsl:template>

<xsl:template match="oref">
<oRef>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</oRef>
</xsl:template>

<xsl:template match="ovar">
<oVar>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</oVar>
</xsl:template>

<xsl:template match="offset">
<offSet>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</offSet>
</xsl:template>

<xsl:template match="orgdivn">
<orgDivn>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</orgDivn>
</xsl:template>

<xsl:template match="orgname">
<orgName>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</orgName>
</xsl:template>

<xsl:template match="orgtitle">
<orgTitle>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</orgTitle>
</xsl:template>

<xsl:template match="orgtype">
<orgType>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</orgType>
</xsl:template>

<xsl:template match="otherform">
<otherForm>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</otherForm>
</xsl:template>

<xsl:template match="pref">
<pRef>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</pRef>
</xsl:template>

<xsl:template match="pvar">
<pVar>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</pVar>
</xsl:template>

<xsl:template match="particdesc">
<particDesc>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</particDesc>
</xsl:template>

<xsl:template match="particlinks">
<particLinks>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</particLinks>
</xsl:template>

<xsl:template match="persname">
<persName>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</persName>
</xsl:template>

<xsl:template match="persongrp">
<personGrp>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</personGrp>
</xsl:template>

<xsl:template match="placename">
<placeName>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</placeName>
</xsl:template>

<xsl:template match="postbox">
<postBox>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</postBox>
</xsl:template>

<xsl:template match="postcode">
<postCode>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</postCode>
</xsl:template>

<xsl:template match="profiledesc">
<profileDesc>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</profileDesc>
</xsl:template>

<xsl:template match="projectdesc">
<projectDesc>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</projectDesc>
</xsl:template>

<xsl:template match="pubplace">
<pubPlace>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</pubPlace>
</xsl:template>

<xsl:template match="publicationstmt">
<publicationStmt>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</publicationStmt>
</xsl:template>

<xsl:template match="rdggrp">
<rdgGrp>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</rdgGrp>
</xsl:template>

<xsl:template match="recordingstmt">
<recordingStmt>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</recordingStmt>
</xsl:template>

<xsl:template match="refsdecl">
<refsDecl>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</refsDecl>
</xsl:template>

<xsl:template match="respstmt">
<respStmt>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</respStmt>
</xsl:template>

<xsl:template match="revisiondesc">
<revisionDesc>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</revisionDesc>
</xsl:template>

<xsl:template match="roledesc">
<roleDesc>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</roleDesc>
</xsl:template>

<xsl:template match="rolename">
<roleName>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</roleName>
</xsl:template>

<xsl:template match="samplingdecl">
<samplingDecl>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</samplingDecl>
</xsl:template>

<xsl:template match="scriptstmt">
<scriptStmt>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</scriptStmt>
</xsl:template>

<xsl:template match="seriesstmt">
<seriesStmt>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</seriesStmt>
</xsl:template>

<xsl:template match="settingdesc">
<settingDesc>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</settingDesc>
</xsl:template>

<xsl:template match="socalled">
<soCalled>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</soCalled>
</xsl:template>

<xsl:template match="socecstatus">
<socecStatus>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</socecStatus>
</xsl:template>

<xsl:template match="sourcedesc">
<sourceDesc>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</sourceDesc>
</xsl:template>

<xsl:template match="spangrp">
<spanGrp>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</spanGrp>
</xsl:template>

<xsl:template match="stdvals">
<stdVals>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</stdVals>
</xsl:template>

<xsl:template match="tagdoc">
<tagDoc>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</tagDoc>
</xsl:template>

<xsl:template match="tagusage">
<tagUsage>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</tagUsage>
</xsl:template>

<xsl:template match="tagsdecl">
<tagsDecl>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</tagsDecl>
</xsl:template>

<xsl:template match="teicorpus.2">
<teiCorpus.2>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</teiCorpus.2>
</xsl:template>

<xsl:template match="teifsd2">
<teiFsd2>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</teiFsd2>
</xsl:template>

<xsl:template match="teiheader">
<teiHeader>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</teiHeader>
</xsl:template>

<xsl:template match="termentry">
<termEntry>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</termEntry>
</xsl:template>

<xsl:template match="textclass">
<textClass>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</textClass>
</xsl:template>

<xsl:template match="textdesc">
<textDesc>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</textDesc>
</xsl:template>

<xsl:template match="timerange">
<timeRange>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</timeRange>
</xsl:template>

<xsl:template match="timestruct">
<timeStruct>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</timeStruct>
</xsl:template>

<xsl:template match="titlepage">
<titlePage>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</titlePage>
</xsl:template>

<xsl:template match="titlepart">
<titlePart>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</titlePart>
</xsl:template>

<xsl:template match="titlestmt">
<titleStmt>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</titleStmt>
</xsl:template>

<xsl:template match="valt">
<vAlt>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</vAlt>
</xsl:template>

<xsl:template match="vdefault">
<vDefault>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</vDefault>
</xsl:template>

<xsl:template match="vrange">
<vRange>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</vRange>
</xsl:template>

<xsl:template match="valdesc">
<valDesc>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</valDesc>
</xsl:template>

<xsl:template match="vallist">
<valList>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</valList>
</xsl:template>

<xsl:template match="variantencoding">
<variantEncoding>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</variantEncoding>
</xsl:template>

<xsl:template match="witdetail">
<witDetail>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</witDetail>
</xsl:template>

<xsl:template match="witend">
<witEnd>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</witEnd>
</xsl:template>

<xsl:template match="witlist">
<witList>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</witList>
</xsl:template>

<xsl:template match="witstart">
<witStart>
 <xsl:apply-templates select="@*"/>
 <xsl:apply-templates/>
</witStart>
</xsl:template>

<xsl:template match="@tei">
 <xsl:attribute name="TEI"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@adjfrom">
 <xsl:attribute name="adjFrom"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@adjto">
 <xsl:attribute name="adjTo"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@assertedvalue">
 <xsl:attribute name="assertedValue"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@basetype">
 <xsl:attribute name="baseType"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@copyof">
 <xsl:attribute name="copyOf"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@depptr">
 <xsl:attribute name="depPtr"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@entityloc">
 <xsl:attribute name="entityLoc"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@entitystd">
 <xsl:attribute name="entityStd"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@fval">
 <xsl:attribute name="fVal"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@grpptr">
 <xsl:attribute name="grpPtr"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@indegree">
 <xsl:attribute name="inDegree"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@mutexcl">
 <xsl:attribute name="mutExcl"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@outdegree">
 <xsl:attribute name="outDegree"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@sameas">
 <xsl:attribute name="sameAs"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@targfunc">
 <xsl:attribute name="targFunc"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@targorder">
  <xsl:if test="not(. = 'u')">
 <xsl:attribute name="targOrder"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:if>
</xsl:template>

<xsl:template match="@targtype">
 <xsl:attribute name="targType"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@targetend">
 <xsl:attribute name="targetEnd"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@valueto">
 <xsl:attribute name="valueTo"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@varseq">
 <xsl:attribute name="varSeq"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@wscale">
 <xsl:attribute name="wScale"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@teiform"/>

<xsl:template match="@opt">
  <xsl:if test="not(. = 'n')">
 <xsl:attribute name="opt"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:if>
</xsl:template>

<xsl:template match="@to">
  <xsl:if test="not(. = 'ditto')">
 <xsl:attribute name="to"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:if>
</xsl:template>

<xsl:template match="@default">
  <xsl:if test="not(. = 'no')">
 <xsl:attribute name="default"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:if>
</xsl:template>

<xsl:template match="@part">
  <xsl:if test="not(. = 'n')">
 <xsl:attribute name="part"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:if>
</xsl:template>

<xsl:template match="@full">
  <xsl:if test="not(. = 'yes')">
 <xsl:attribute name="full"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:if>
</xsl:template>

<xsl:template match="@status">
  <xsl:if test="not(. = 'unremarkable')">
 <xsl:attribute name="status"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:if>
</xsl:template>

<xsl:template match="@place">
  <xsl:if test="not(. = 'unspecified')">
 <xsl:attribute name="place"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:if>
</xsl:template>

<xsl:template match="@sample">
  <xsl:if test="not(. = 'complete')">
 <xsl:attribute name="sample"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:if>
</xsl:template>

<xsl:template match="@org">
  <xsl:if test="not(. = 'uniform')">
 <xsl:attribute name="org"><xsl:value-of
 select="."/></xsl:attribute>
</xsl:if>
</xsl:template>


<xsl:template match="@lang">
    <xsl:attribute name="lang"><xsl:value-of select="."/></xsl:attribute>
    <xsl:attribute name="xml:lang"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

</xsl:stylesheet>
