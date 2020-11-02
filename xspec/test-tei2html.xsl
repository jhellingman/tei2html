<?xml version="1.0" encoding="iso-8859-1" ?>
<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:include href="../utils.xsl"/>
    <xsl:include href="../utils.html.xsl"/>
    <xsl:include href="../betacode.xsl"/>
    <xsl:include href="../configuration.xsl"/>
    <xsl:include href="../log.xsl"/>
    <xsl:include href="../localization.xsl"/>
    <xsl:include href="../header.xsl"/>
    <xsl:include href="../inline.xsl"/>
    <xsl:include href="../rend.xsl"/>
    <xsl:include href="../css.xsl"/>
    <xsl:include href="../references.xsl"/>
    <xsl:include href="../titlepage.xsl"/>
    <xsl:include href="../block.xsl"/>
    <xsl:include href="../notes.xsl"/>
    <xsl:include href="../numbers.xsl"/>
    <xsl:include href="../drama.xsl"/>
    <xsl:include href="../contents.xsl"/>
    <xsl:include href="../index.xsl"/>
    <xsl:include href="../divisions.xsl"/>
    <xsl:include href="../tables.xsl"/>
    <xsl:include href="../lists.xsl"/>
    <xsl:include href="../formulas.xsl"/>
    <xsl:include href="../figures.xsl"/>
    <xsl:include href="../colophon.xsl"/>
    <xsl:include href="../gutenberg.xsl"/>
    <xsl:include href="../facsimile.xsl"/>
    <xsl:include href="../stripns.xsl"/>

    <xsl:param name="basename" select="'book'"/>
    <xsl:param name="path" select="'.'"/>
    <xsl:param name="optionPrinceMarkup" select="'No'"/>

    <xsl:variable name="root" select="/"/>

    <xsl:variable name="mimeType" select="'text/html'"/>
    <xsl:variable name="encoding" select="document('')/xsl:stylesheet/xsl:output/@encoding"/>
    <xsl:variable name="outputmethod" select="document('')/xsl:stylesheet/xsl:output/@method"/>
    <xsl:variable name="outputformat" select="'html'"/>

    <xsl:variable name="title" select="/*[self::TEI.2 or self::*:TEI]/*:teiHeader/*:fileDesc/*:titleStmt/*:title[not(@type) or @type='main']"/>
    <xsl:variable name="author" select="/*[self::TEI.2 or self::*:TEI]/*:teiHeader/*:fileDesc/*:titleStmt/*:author"/>
    <xsl:variable name="publisher" select="/*[self::TEI.2 or self::*:TEI]/*:teiHeader/*:fileDesc/*:publicationStmt/*:publisher"/>
    <xsl:variable name="pubdate" select="/*[self::TEI.2 or self::*:TEI]/*:teiHeader/*:fileDesc/*:publicationStmt/*:date"/>

    <xsl:variable name="p.element" select="if ($optionPrinceMarkup = 'Yes') then 'div' else 'p'"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>
