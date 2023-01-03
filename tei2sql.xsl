<!DOCTYPE xsl:stylesheet [

    <!ENTITY lf         "&#x0A;">

]>
<!--

Generate metadata for insertion into a database from a TEI file

-->

<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:f="urn:stylesheet-functions"
                exclude-result-prefixes="f">

    <xsl:output
        method="text"
        indent="yes"
        encoding="UTF-8"/>

    <xsl:variable name="p.element" select="'p'"/>
    <xsl:variable name="outputMethod" select="'text'"/>
    <xsl:variable name="outputFormat" select="'sql'"/>
    <xsl:variable name="optionPrinceMarkup" select="'No'"/>
    <xsl:variable name="customCssFile" select="''"/>
    <xsl:variable name="path" select="''"/>
    <xsl:variable name="basename" select="''"/>

    <xsl:include href="modules/functions.xsl"/>
    <xsl:include href="modules/stripns.xsl"/>
    <xsl:include href="modules/copyright.xsl"/>
    <xsl:include href="modules/utils.xsl"/>
    <xsl:include href="modules/log.xsl"/>
    <xsl:include href="modules/configuration.xsl"/>
    <xsl:include href="modules/localization.xsl"/>
    <xsl:include href="modules/rend.xsl"/>
    <xsl:include href="modules/css.xsl"/>

    <xsl:variable name="root" select="/"/>
    <xsl:variable name="TEI" select="TEI.2 | TEI"/>
    <xsl:variable name="pgNum" select="$TEI/teiHeader/fileDesc/publicationStmt/idno[@type='PGnum']"/>


    <xsl:template match="/">
        <xsl:text expand-text="yes">DELETE FROM Title WHERE idbook = {$pgNum};</xsl:text>
        <xsl:text expand-text="yes">&lf;DELETE FROM Person WHERE idbook = {$pgNum};</xsl:text>
        <xsl:text expand-text="yes">&lf;DELETE FROM Keyword WHERE idbook = {$pgNum};</xsl:text>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="teiHeader/fileDesc/titleStmt/title">
        <xsl:text>&lf;&lf;INSERT INTO Title (idbook, language, type, nfc, title)</xsl:text>
        <xsl:text expand-text="yes">&lf;  VALUES ({$pgNum}, '{f:get-current-lang(.)}', '{if (@type) then @type else 'main'}', {if (@nfc) then @nfc else 0}, '{.}');</xsl:text>
    </xsl:template>

    <xsl:template match="teiHeader/fileDesc/titleStmt/author">
        <xsl:text>&lf;&lf;INSERT INTO Person (idbook, `key`, name, viaf, dates, role)</xsl:text>
        <xsl:text expand-text="yes">&lf;  VALUES ({$pgNum}, '{if (@key) then @key else ''}', '{.}', '{if (@ref) then @ref else ''}', '', 'Author');</xsl:text>
    </xsl:template>

    <xsl:template match="teiHeader/fileDesc/titleStmt/editor">
        <xsl:text>&lf;&lf;INSERT INTO Person (idbook, `key`, name, viaf, dates, role)</xsl:text>
        <xsl:text expand-text="yes">&lf;  VALUES ({$pgNum}, '{if (@key) then @key else ''}', '{.}', '{if (@ref) then @ref else ''}', '', 'Editor');</xsl:text>
    </xsl:template>

    <xsl:template match="teiHeader/fileDesc/titleStmt/respStmt">
        <xsl:text>&lf;&lf;INSERT INTO Person (idbook, `key`, name, viaf, dates, role)</xsl:text>
        <xsl:text expand-text="yes">&lf;  VALUES ({$pgNum}, '{if (name/@key) then name/@key else ''}', '{name}', '{if (name/@ref) then name/@ref else ''}', '', '{resp}');</xsl:text>
    </xsl:template>

    <xsl:template match="teiHeader/profileDesc/textClass/keywords/list/item">
        <xsl:text>&lf;&lf;INSERT INTO Keyword (idbook, keyword)</xsl:text>
        <xsl:text expand-text="yes">&lf;  VALUES ({$pgNum}, '{.}');</xsl:text>
    </xsl:template>


    <xsl:template match="text()"/>

</xsl:stylesheet>