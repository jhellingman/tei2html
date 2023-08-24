<?xml version="1.0" encoding="iso-8859-1" ?>
<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="xd">

    <xd:doc type="stylesheet">
        <xd:short>TEI stylesheet to define commonly used variables.</xd:short>
        <xd:detail>This stylesheet defines some commonly used variables.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2023, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:variable name="root" select="/"/>

    <!-- The complex Xpath is needed at this point, as the document may be in the TEI namespace -->
    <xsl:variable name="fileDesc" select="/*[self::TEI.2 or self::*:TEI]/*:teiHeader/*:fileDesc"/>
    <xsl:variable name="title" select="$fileDesc/*:titleStmt/*:title[not(@type) or @type='main']"/>
    <xsl:variable name="author" select="$fileDesc/*:titleStmt/*:author[1]"/>
    <xsl:variable name="publisher" select="fileDesc/*:publicationStmt/*:publisher"/>
    <xsl:variable name="pubdate" select="$fileDesc/*:publicationStmt/*:date"/>

    <xsl:variable name="authorList" select="$fileDesc/*:titleStmt/*:author"/>
    <xsl:variable name="authorMap" select="map{ 'first': $authorList[1], 'second': $authorList[2], 'third': $authorList[3], 'fourth': $authorList[4] }"/>
    <xsl:variable name="authors">
        <xsl:choose>
            <xsl:when test="count($authorList) = 1">
                <xsl:sequence select="$authorList[1]"/>
            </xsl:when>
            <xsl:when test="count($authorList) = 2">
                <xsl:sequence select="f:format-message('msgListTwo', $authorMap)"/>
            </xsl:when>
            <xsl:when test="count($authorList) = 3">
                <xsl:sequence select="f:format-message('msgListThree', $authorMap)"/>
            </xsl:when>
            <xsl:when test="count($authorList) = 4">
                <xsl:sequence select="f:format-message('msgListFour', $authorMap)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="f:format-message('msgListEtAL', $authorMap)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

</xsl:stylesheet>
