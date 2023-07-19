<!DOCTYPE xsl:stylesheet [

    <!ENTITY ndash      "&#x2013;">

]>

<!-- Generate RDF/Dublin Core metadata from a TEI file

     This is still a very basic implementation.
     For further ideas on refinements see: http://dublincore.org/documents/dcq-rdf-xml/.
-->

<xsl:stylesheet version="3.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:f="urn:stylesheet-functions"
                exclude-result-prefixes="f">

    <xsl:output
        method="xml"
        indent="yes"
        encoding="UTF-8"/>

    <xsl:include href="modules/functions.xsl"/>
    <xsl:include href="modules/stripns.xsl"/>
    <xsl:include href="modules/copyright.xsl"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:variable name="TEI" select="TEI.2 | TEI"/>

    <xsl:template match="TEI.2 | TEI">
        <xsl:comment>
            <xsl:text> Generated on </xsl:text>
            <xsl:value-of select="f:utc-timestamp()"/>
            <xsl:text>. </xsl:text>
        </xsl:comment>
        <rdf:RDF>
            <rdf:Description>
                <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/title[not(@type='pgshort')]"/>
                <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/author"/>
                <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/editor"/>
                <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/respStmt[resp != 'Transcription']/name"/>
                <xsl:apply-templates select="teiHeader/fileDesc/publicationStmt"/>
                <xsl:apply-templates select="teiHeader/fileDesc/publicationStmt/availability"/>
                <xsl:if test="text/@lang">
                    <dc:language><xsl:value-of select="text/@lang"/></dc:language>
                </xsl:if>
                <xsl:apply-templates select="teiHeader/profileDesc/textClass/keywords/list" mode="keywords"/>
                <xsl:apply-templates select="teiHeader/fileDesc/respStmt/name" mode="contributors"/>
                <xsl:apply-templates select="teiHeader/fileDesc/notesStmt/note[@type='Description']" mode="descriptions"/>
                <xsl:if test="f:is-valid(teiHeader/fileDesc/publicationStmt/idno[@type='PGnum'])">
                    <dc:identifier>pg:<xsl:value-of select="teiHeader/fileDesc/publicationStmt/idno[@type='PGnum']"/></dc:identifier>
                </xsl:if>
            </rdf:Description>
        </rdf:RDF>
    </xsl:template>

    <xsl:template match="title">
        <dc:title>
            <xsl:value-of select="f:plain-text(.)"/>
        </dc:title>
    </xsl:template>

    <xsl:template match="author">
        <dc:creator>
            <xsl:value-of select="."/>
        </dc:creator>
    </xsl:template>

    <xsl:template match="editor">
        <dc:creator>
            <xsl:value-of select="."/>
        </dc:creator>
    </xsl:template>

    <xsl:template match="respStmt/name">
        <dc:creator>
            <xsl:value-of select="."/>
        </dc:creator>
    </xsl:template>

    <xsl:template match="publicationStmt">
        <dc:publisher>
            <xsl:value-of select="publisher"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="pubPlace"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="date"/>
        </dc:publisher>
        <dc:date><xsl:value-of select="date"/></dc:date>
    </xsl:template>

 
    <xsl:template match="availability">
        <dc:rights>
            <xsl:value-of select="."/>
            <xsl:choose>
                <xsl:when test="f:in-copyright('EU', $TEI/teiHeader)">
                    <xsl:text>(Based on the available metadata, this work is likely to be subject to copyright in jurisdictions where copyright lasts for life plus 70 years until at least 1 January </xsl:text>
                    <xsl:value-of select="f:last-contributor-death($TEI/teiHeader) + 71"/>
                    <xsl:text>.)</xsl:text>
                </xsl:when>
                <xsl:when test="f:in-copyright('Bern', $TEI/teiHeader)">
                    <xsl:text>(Based on the available metadata, this work is likely to be subject to copyright in jurisdictions where copyright lasts for life plus 50 years until at least 1 January </xsl:text>
                    <xsl:value-of select="f:last-contributor-death($TEI/teiHeader) + 51"/>
                    <xsl:text>.)</xsl:text>
                </xsl:when>
            </xsl:choose>
        </dc:rights>
    </xsl:template>


    <xsl:template match="item" mode="keywords">
        <!-- Filter out empty subjects and our template default placeholder -->
        <xsl:if test="f:is-valid(.)">
            <dc:subject>
                <xsl:value-of select="."/>
            </dc:subject>
        </xsl:if>
    </xsl:template>

    <xsl:template match="name" mode="contributors">
        <!-- Filter out empty contributors and our template default placeholder -->
        <xsl:if test="f:is-valid(.)">
            <dc:contributor>
                <xsl:value-of select="."/>
            </dc:contributor>
        </xsl:if>
    </xsl:template>

    <xsl:template match="note" mode="descriptions">
        <!-- Filter out empty descriptions and our template default placeholder -->
        <xsl:if test="f:is-valid(.)">
            <dc:description>
                <xsl:value-of select="."/>
            </dc:description>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*"/>


</xsl:stylesheet>