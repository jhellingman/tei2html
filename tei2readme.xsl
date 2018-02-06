<!DOCTYPE xsl:stylesheet [

    <!ENTITY lf         "&#x0A;">
    <!ENTITY cr         "&#x0D;">
    <!ENTITY crlf       "&#x0D;&#x0A;">

]>
<xsl:stylesheet
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="urn:stylesheet-functions"
    exclude-result-prefixes="f xd xs"
    version="2.0">

    <xsl:output
        method="text"
        indent="yes"
        encoding="UTF-8"/>

    <xsl:variable name="title" select="/*[self::TEI.2 or self::*:TEI]/*:teiHeader/*:fileDesc/*:titleStmt/*:title[not(@type) or @type='main']"/>
    <xsl:variable name="author" select="/*[self::TEI.2 or self::*:TEI]/*:teiHeader/*:fileDesc/*:titleStmt/*:author"/>
    <xsl:variable name="publisher" select="/*[self::TEI.2 or self::*:TEI]/*:teiHeader/*:fileDesc/*:publicationStmt/*:publisher"/>
    <xsl:variable name="pubdate" select="/*[self::TEI.2 or self::*:TEI]/*:teiHeader/*:fileDesc/*:publicationStmt/*:date"/>

    <xsl:template match="/">

        <xsl:text># About This Repository&lf;&lf;</xsl:text>

        <xsl:text>This repository contains the TEI master file, and derived text and HTML files of an ebook posted to [Project Gutenberg](https://www.gutenberg.org/). Like the version posted to Project Gutenberg, this ebook is free from copyright in the U.S. No claim is made about its copyright status outside the U.S.&lf;&lf;</xsl:text>

        <xsl:text>The version maintained in this repository may be slightly out-of-sync with the version maintained at Project Gutenberg. Mostly, fixes will be made first here, and only then reposted to Project Gutenberg. When you encounter any issue in this text, please report it here.&lf;&lf;</xsl:text>

        <xsl:text>## About This Ebook&lf;&lf;</xsl:text>

        <xsl:text>| Field | Value |&lf;</xsl:text>
        <xsl:text>| ----- | ----- |&lf;</xsl:text>
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template match="TEI.2 | TEI">
            <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/title[not(@type='pgshort')]"/>
            <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/author"/>
            <xsl:apply-templates select="teiHeader/fileDesc/publicationStmt"/>
            <xsl:apply-templates select="teiHeader/fileDesc/publicationStmt/availability"/>
            <xsl:if test="text/@lang">
                <dc:language><xsl:value-of select="text/@lang"/></dc:language>
            </xsl:if>
            <xsl:apply-templates select="teiHeader/profileDesc/textClass/keywords/list" mode="keywords"/>
            <xsl:apply-templates select="teiHeader/fileDesc/respStmt/name" mode="contributors"/>
            <xsl:apply-templates select="teiHeader/fileDesc/notesStmt/note[@type='Description']" mode="descriptions"/>
            <xsl:if test="f:isValid(teiHeader/fileDesc/publicationStmt/idno[@type='PGnum'])">
                <xsl:text>| PG Ebook Number | </xsl:text>[<xsl:value-of select="teiHeader/fileDesc/publicationStmt/idno[@type='PGnum']"/>](https://www.gutenberg.org/ebooks/<xsl:value-of select="teiHeader/fileDesc/publicationStmt/idno[@type='PGnum']"/>)<xsl:text> |&lf;</xsl:text>
            </xsl:if>
    </xsl:template>

    <xsl:template match="title">
        <xsl:text>| Title | </xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text> |&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="author">
        <xsl:text>| Author | </xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text> |&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="publicationStmt">
        <xsl:text>| Publisher | </xsl:text><xsl:value-of select="publisher"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="pubPlace"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="date"/><xsl:text> |&lf;</xsl:text>
        <xsl:text>| Publication date | </xsl:text><xsl:value-of select="date"/><xsl:text> |&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="availability">
        <xsl:text>| Availability | </xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text> |&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="item" mode="keywords">
        <!-- Filter out empty subjects and our template default placeholder -->
        <xsl:if test="f:isValid(.)">
            <xsl:text>| Keyword | </xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text> |&lf;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="name" mode="contributors">
        <!-- Filter out empty contributors and our template default placeholder -->
        <xsl:if test="f:isValid(.)">
            <xsl:text>| Contributor | </xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text> |&lf;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="note" mode="descriptions">
        <!-- Filter out empty descriptions and our template default placeholder -->
        <xsl:if test="f:isValid(.)">
            <xsl:text>| Description | </xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text> |&lf;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*"/>


    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>

    <xd:doc>
        <xd:short>Determine a string has a valid value.</xd:short>
        <xd:detail>
            <p>Determine a string has a valid value, that is, not null, empty or '#####' (copied from utils.xml)</p>
        </xd:detail>
        <xd:param name="value" type="string">The value to be tested.</xd:param>
    </xd:doc>

    <xsl:function name="f:isValid" as="xs:boolean">
        <xsl:param name="value"/>
        <xsl:sequence select="$value and not($value = '' or $value = '#####')"/>
    </xsl:function>

</xsl:stylesheet>