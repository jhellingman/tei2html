<?xml version="1.0" encoding="iso-8859-1" ?>
<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:include href="../modules/functions.xsl"/>
    <xsl:include href="../modules/utils.xsl"/>
    <xsl:include href="../modules/utils.html.xsl"/>
    <xsl:include href="../modules/betacode.xsl"/>
    <xsl:include href="../modules/spellout.xsl"/>
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
    <xsl:include href="../modules/variables.xsl"/>

    <xsl:output
        doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
        method="xml"
        encoding="utf-8"/>

    <xsl:param name="basename" select="'book'"/>
    <xsl:param name="path" select="'.'"/>
    <xsl:param name="optionPrinceMarkup" select="'No'"/>

    <xsl:variable name="mimeType" select="'text/html'"/>
    <xsl:variable name="encoding" select="document('')/xsl:stylesheet/xsl:output/@encoding"/>
    <xsl:variable name="outputMethod" select="document('')/xsl:stylesheet/xsl:output/@method"/>
    <xsl:variable name="outputFormat" select="'html'"/>

    <xsl:variable name="p.element" select="if (f:is-pdf()) then 'div' else 'p'"/>
    <xsl:variable name="section.element" select="'div'"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>
