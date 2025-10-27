<!DOCTYPE xsl:stylesheet [
    <!ENTITY lf         "&#x0A;">
    <!ENTITY cr         "&#x0D;">
    <!ENTITY crlf       "&#x0D;&#x0A;">
]>
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:f="urn:stylesheet-functions"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                exclude-result-prefixes="f xd">

    <xd:doc type="stylesheet">
        <xd:short>Generate metadata from a TEI file in ASCIIdoc format.</xd:short>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2024, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:param name="imageDir" select="'images'"/>

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

    <xsl:template match="/" expand-text="yes">

        <xsl:text>= {f:message('t2aAboutThisRepository')}&lf;&lf;</xsl:text>

        <xsl:if test="$pgnum">
            <xsl:text>{f:message('t2aAboutThisRepositoryParagraph1')}&lf;&lf;</xsl:text>

            <xsl:text>{f:message('t2aAboutThisRepositoryParagraph2')}&lf;&lf;</xsl:text>
        </xsl:if>

        <xsl:text>== {f:message('t2aAboutThisEbook')}&lf;&lf;</xsl:text>

        <xsl:text>[cols="1,3"]&lf;</xsl:text>
        <xsl:text>|===&lf;</xsl:text>
        <xsl:text>|{f:message('t2aField')} |{f:message('t2aValue')}&lf;</xsl:text>
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
            <xsl:variable name="pgNum" select="teiHeader/fileDesc/publicationStmt/idno[@type='PGnum']"/>
            <xsl:if test="f:is-valid($pgNum)">
                <xsl:text>|{f:message('t2aPGEbookNumber')} |https://www.gutenberg.org/ebooks/{$pgNum}[{$pgNum}]&lf;</xsl:text>
                <xsl:text>|{f:message('t2aQRCodeForDownload')} a|image::Processed/{$imageDir}/qr{$pgNum}.png[QR code,148,148]&lf;</xsl:text>
            </xsl:if>
    </xsl:template>

    <xsl:template match="title" expand-text="yes">
        <xsl:text>|{f:message('msgTitle')} |{normalize-space(f:plain-text(.))}&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="title[@type='short']" expand-text="yes">
        <xsl:text>|{f:message('msgShortTitle')} |{normalize-space(f:plain-text(.))}&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="title[@type='original']" expand-text="yes">
        <xsl:text>|{f:message('msgOriginalTitle')} |{normalize-space(f:plain-text(.))}&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="author" expand-text="yes">
        <xsl:text>|{f:message('msgAuthor')} |{normalize-space(.)}&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="editor" expand-text="yes">
        <xsl:text>|{f:message('msgEditor')} |{normalize-space(.)}&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="respStmt[resp = ('Translator', 'Translation')]" expand-text="yes">
        <xsl:text>|{f:message('msgTranslator')} |{normalize-space(name)}&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="respStmt[resp = 'Illustrator']" expand-text="yes">
        <xsl:text>|{f:message('msgIllustrator')} |{normalize-space(name)}&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="respStmt[resp = 'Contributor']" expand-text="yes">
        <xsl:text>|{f:message('msgContributor')} |{normalize-space(name)}&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="respStmt"/>

    <xsl:template match="publicationStmt" expand-text="yes">
        <xsl:text>|{f:message('msgPublisher')} |{publisher}, {pubPlace}, {date}&lf;</xsl:text>
        <xsl:text>|{f:message('msgPublicationDate')} |{date}&lf;</xsl:text>
    </xsl:template>

    <xsl:template match="availability" expand-text="yes">
        <xsl:if test="f:is-valid(.)">
            <xsl:variable name="availability"><xsl:apply-templates mode="text"/></xsl:variable>
            <xsl:text>|{f:message('msgAvailability')} |{normalize-space(string($availability))}&lf;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="item" mode="keywords" expand-text="yes">
        <!-- Filter out empty subjects and our template default placeholder -->
        <xsl:if test="f:is-valid(.)">
            <xsl:text>|{f:message('msgKeyword')} |{normalize-space(.)}&lf;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="note" mode="descriptions" expand-text="yes">
        <!-- Filter out empty descriptions and our template default placeholder -->
        <xsl:if test="f:is-valid(.)">
            <xsl:variable name="description"><xsl:apply-templates mode="text"/></xsl:variable>
            <xsl:text>|{f:message('msgDescription')} |{normalize-space(string($description))}&lf;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*"/>

    <xsl:template match="xref" mode="text" expand-text="yes">
        <xsl:text>{f:translate-xref-url(@url, $baseLanguage)}[{.}]</xsl:text>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:value-of select="."/>
    </xsl:template>

</xsl:stylesheet>
