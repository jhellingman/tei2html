<?xml version="1.0" encoding="iso-8859-1" ?>
<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:include href="../modules/utils.xsl"/>
    <xsl:include href="../modules/utils.html.xsl"/>
    <xsl:include href="../modules/betacode.xsl"/>
    <xsl:include href="../modules/configuration.xsl"/>
    <xsl:include href="../modules/log.xsl"/>
    <xsl:include href="../modules/localization.xsl"/>
    <xsl:include href="../modules/header.xsl"/>
    <xsl:include href="../modules/inline.xsl"/>
    <xsl:include href="../modules/rend.xsl"/>
    <xsl:include href="../modules/css.xsl"/>
    <xsl:include href="../modules/references.xsl"/>
    <xsl:include href="../modules/titlepage.xsl"/>
    <xsl:include href="../modules/block.xsl"/>
    <xsl:include href="../modules/notes.xsl"/>
    <xsl:include href="../modules/numbers.xsl"/>
    <xsl:include href="../modules/drama.xsl"/>
    <xsl:include href="../modules/contents.xsl"/>
    <xsl:include href="../modules/index.xsl"/>
    <xsl:include href="../modules/divisions.xsl"/>
    <xsl:include href="../modules/tables.xsl"/>
    <xsl:include href="../modules/lists.xsl"/>
    <xsl:include href="../modules/formulas.xsl"/>
    <xsl:include href="../modules/figures.xsl"/>
    <xsl:include href="../modules/colophon.xsl"/>
    <xsl:include href="../modules/gutenberg.xsl"/>
    <xsl:include href="../modules/facsimile.xsl"/>
    <xsl:include href="../modules/stripns.xsl"/>

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
