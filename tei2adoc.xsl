<!DOCTYPE xsl:stylesheet [

    <!ENTITY lf         "&#x0A;">
    <!ENTITY cr         "&#x0D;">
    <!ENTITY crlf       "&#x0D;&#x0A;">

]>
<xsl:stylesheet version="3.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:f="urn:stylesheet-functions"
                exclude-result-prefixes="f"
>

    <xsl:variable name="outputFormat" select="markdown"/>

    <xsl:include href="modules/functions.xsl"/>
    <xsl:include href="modules/log.xsl"/>
    <xsl:include href="modules/configuration.xsl"/>
    <xsl:include href="modules/localization.xsl"/>
    <xsl:include href="modules/references-func.xsl"/>
    <xsl:include href="modules/stripns.xsl"/>

    <xsl:output
        method="text"
        indent="yes"
        encoding="UTF-8"/>

    <xsl:variable name="title" select="/*[self::TEI.2 or self::*:TEI]/*:teiHeader/*:fileDesc/*:titleStmt/*:title[not(@type) or @type='main']"/>
    <xsl:variable name="author" select="/*[self::TEI.2 or self::*:TEI]/*:teiHeader/*:fileDesc/*:titleStmt/*:author"/>
    <xsl:variable name="publisher" select="/*[self::TEI.2 or self::*:TEI]/*:teiHeader/*:fileDesc/*:publicationStmt/*:publisher"/>
    <xsl:variable name="pubdate" select="/*[self::TEI.2 or self::*:TEI]/*:teiHeader/*:fileDesc/*:publicationStmt/*:date"/>
    <xsl:variable name="pgnum" select="/*[self::TEI.2 or self::*:TEI]/*:teiHeader/*:fileDesc/*:publicationStmt/*:idno[@type='PGnum']"/>

    <xsl:template match="/">

        <xsl:text>= About This Repository&lf;&lf;</xsl:text>

        <xsl:if test="$pgnum">
            <xsl:text>This repository contains the TEI source file, and derived text and HTML files of an ebook posted to https://www.gutenberg.org/[Project Gutenberg]. Like the version posted to Project Gutenberg, this ebook is free from copyright in the U.S. No claim is made about its copyright status outside the U.S.&lf;&lf;</xsl:text>

            <xsl:text>The version maintained in this repository may be slightly out-of-sync with the version maintained at Project Gutenberg. Mostly, fixes will be made first here, and only then reposted to Project Gutenberg. When you encounter any issue in this text, please report it here.&lf;&lf;</xsl:text>
        </xsl:if>

        <xsl:text>== About This Ebook&lf;&lf;</xsl:text>

        <xsl:text>|===&lf;</xsl:text>
        <xsl:text>|Field |Value&lf;</xsl:text>
        <xsl:text>&lf;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>|===&lf;</xsl:text>
    </xsl:template>


    <xsl:template match="TEI.2 | TEI" expand-text="yes">
            <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/title[not(@type='pgshort')]"/>
            <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/author"/>
            <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/respStmt"/>
            <xsl:apply-templates select="teiHeader/fileDesc/publicationStmt"/>
            <xsl:apply-templates select="teiHeader/fileDesc/publicationStmt/availability"/>
            <xsl:apply-templates select="teiHeader/profileDesc/textClass/keywords/list" mode="keywords"/>
            <xsl:apply-templates select="teiHeader/fileDesc/notesStmt/note[@type='Description']" mode="descriptions"/>
            <xsl:if test="f:is-valid(teiHeader/fileDesc/publicationStmt/idno[@type='PGnum'])">
                <xsl:text>|PG Ebook Number |https://www.gutenberg.org/ebooks/{teiHeader/fileDesc/publicationStmt/idno[@type='PGnum']}[{teiHeader/fileDesc/publicationStmt/idno[@type='PGnum']}]&lf;</xsl:text>
            </xsl:if>
    </xsl:template>

    <xsl:template match="title" expand-text="yes">
        <xsl:text>|Title |{normalize-space(f:plain-text(.))}&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="title[@type='short']" expand-text="yes">
        <xsl:text>|Short title |{normalize-space(f:plain-text(.))}&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="title[@type='original']" expand-text="yes">
        <xsl:text>|Original title |{normalize-space(f:plain-text(.))}&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="author" expand-text="yes">
        <xsl:text>|Author |{normalize-space(.)}&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="editor" expand-text="yes">
        <xsl:text>|Editor |{normalize-space(.)}&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="respStmt[resp = 'Translator']" expand-text="yes">
        <xsl:text>|Translator |{normalize-space(name)}&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="respStmt[resp = 'Illustrator']" expand-text="yes">
        <xsl:text>|Illustrator |{normalize-space(name)}&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="respStmt[resp = 'Contributor']" expand-text="yes">
        <xsl:text>|Contributor |{normalize-space(name)}&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="respStmt"/>

    <xsl:template match="publicationStmt" expand-text="yes">
        <xsl:text>|Publisher |{publisher}, {pubPlace}, {date}&lf;</xsl:text>
        <xsl:text>|Publication date |{date}&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="availability" expand-text="yes">
        <xsl:if test="f:is-valid(.)">
            <xsl:variable name="availability"><xsl:apply-templates mode="text"/></xsl:variable>
            <xsl:text>|Availability |{normalize-space(string($availability))}&lf;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="item" mode="keywords" expand-text="yes">
        <!-- Filter out empty subjects and our template default placeholder -->
        <xsl:if test="f:is-valid(.)">
            <xsl:text>|Keyword |{normalize-space(.)}&lf;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="note" mode="descriptions" expand-text="yes">
        <!-- Filter out empty descriptions and our template default placeholder -->
        <xsl:if test="f:is-valid(.)">
            <xsl:variable name="description"><xsl:apply-templates mode="text"/></xsl:variable>
            <xsl:text>|Description |{normalize-space(string($description))}&lf;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*"/>

    <xsl:template match="xref" mode="text" expand-text="yes">
        <xsl:text>{f:translate-xref-url(@url, 'en')}[{.}]</xsl:text>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:value-of select="."/>
    </xsl:template>


</xsl:stylesheet>
