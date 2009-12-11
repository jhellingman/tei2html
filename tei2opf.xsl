<?xml version="1.0" encoding="ISO-8859-1"?>

    <xsl:stylesheet
        xmlns="http://www.idpf.org/2007/opf"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        xmlns:opf="http://www.idpf.org/2007/opf"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        exclude-result-prefixes="xs"
        version="2.0">


    <xsl:template match="TEI.2" mode="opf">

        <xsl:result-document 
                doctype-public=""
                doctype-system=""
                href="{$path}/{$basename}.opf"
                method="xml" 
                indent="yes"
                encoding="UTF-8">
            <xsl:message terminate="no">Info: generated file: <xsl:value-of select="$path"/>/<xsl:value-of select="$basename"/>.opf.</xsl:message>

            <package version="2.0">
                <xsl:attribute name="unique-identifier">idbook</xsl:attribute>

                <metadata>
                    <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/title" mode="metadata"/>
                    <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/author" mode="metadata"/>
                    <xsl:apply-templates select="teiHeader/fileDesc/publicationStmt" mode="metadata"/>
                    <xsl:apply-templates select="teiHeader/fileDesc/publicationStmt/availability" mode="metadata"/>
                    <xsl:if test="@lang">
                        <dc:language xsi:type="dcterms:RFC4646"><xsl:value-of select="@lang"/></dc:language>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="teiHeader/fileDesc/publicationStmt/idno[@type ='ISBN']"><dc:identifier id="idbook" opf:scheme="ISBN"><xsl:value-of select="teiHeader/fileDesc/publicationStmt/idno[@type = 'ISBN']"/></dc:identifier></xsl:when>
                        <xsl:when test="teiHeader/fileDesc/publicationStmt/idno[@type ='PGnum']"><dc:identifier id="idbook" opf:scheme="URI">http://www.gutenberg.org/ebooks/<xsl:value-of select="teiHeader/fileDesc/publicationStmt/idno[@type = 'PGnum']"/></dc:identifier></xsl:when>
                    </xsl:choose>
                    <dc:date opf:event="publication"><xsl:value-of select="teiHeader/fileDesc/publicationStmt/date"/></dc:date>
                </metadata>

                <manifest>
                    
                    <item id="ncx"
                         href="{$basename}.ncx"
                         media-type="application/x-dtbncx+xml"/>

                    <item id="css"
                         href="{$basename}.css"
                         media-type="text/css"/>

                    <!-- Content Parts -->

                    <xsl:apply-templates select="text" mode="manifest"/>

                    <!-- CSS Style Sheets -->

                    <!-- Illustrations -->

                    <xsl:apply-templates select="//figure" mode="manifest"/>

                    <xsl:apply-templates select="//*[contains(@rend, 'link(')]" mode="manifest-links"/>

                </manifest>

                <spine toc="ncx">
                    <xsl:apply-templates select="text" mode="spine"/>
                </spine>

                <!-- Include references to specific elements -->
                <guide>

                    <xsl:if test="key('id', 'cover')">
                        <reference type="cover" title="{$strCoverImage}">
                            <xsl:call-template name="generate-href-attribute">
                                <xsl:with-param name="target" select="key('id', 'cover')[1]"/>
                            </xsl:call-template>
                        </reference>
                    </xsl:if>

                    <xsl:if test="key('id', 'toc')">
                        <reference type="toc" title="{$strTableOfContents}">
                            <xsl:call-template name="generate-href-attribute">
                                <xsl:with-param name="target" select="key('id', 'toc')[1]"/>
                            </xsl:call-template>
                        </reference>
                    </xsl:if>

                    <xsl:if test="key('id', 'loi')">
                        <reference type="loi" title="{$strListOfIllustrations}">
                            <xsl:call-template name="generate-href-attribute">
                                <xsl:with-param name="target" select="key('id', 'loi')[1]"/>
                            </xsl:call-template>
                        </reference>
                    </xsl:if>

                    <xsl:if test="/TEI.2/text/front/titlePage">
                        <reference type="title-page" title="{$strTitlePage}">
                            <xsl:call-template name="generate-href-attribute">
                                <xsl:with-param name="target" select="/TEI.2/text/front/titlePage[1]"/>
                            </xsl:call-template>
                        </reference>
                    </xsl:if>

                    <xsl:if test="//div1[@type='Dedication']">
                        <reference type="dedication" title="{$strDedication}">
                            <xsl:call-template name="generate-href-attribute">
                                <xsl:with-param name="target" select="//div1[@type='Dedication'][1]"/>
                            </xsl:call-template>
                        </reference>
                    </xsl:if>

                    <xsl:if test="//div1[@type='Epigraph']">
                        <reference type="epigraph" title="{$strEpigraph}">
                            <xsl:call-template name="generate-href-attribute">
                                <xsl:with-param name="target" select="//div1[@type='Epigraph'][1]"/>
                            </xsl:call-template>
                        </reference>
                    </xsl:if>

                    <xsl:if test="//div1[@type='Index']">
                        <reference type="index" title="{$strIndex}">
                            <xsl:call-template name="generate-href-attribute">
                                <xsl:with-param name="target" select="//div1[@type='Index'][1]"/>
                            </xsl:call-template>
                        </reference>
                    </xsl:if>

                    <xsl:if test="//div1[@type='Bibliography']">
                        <reference type="bibliography" title="{$strBibliography}">
                            <xsl:call-template name="generate-href-attribute">
                                <xsl:with-param name="target" select="//div1[@type='Bibliography'][1]"/>
                            </xsl:call-template>
                        </reference>
                    </xsl:if>

                    <xsl:if test="//div1[@type='Copyright']">
                        <reference type="copyright-page" title="{$strCopyrightPage}">
                            <xsl:call-template name="generate-href-attribute">
                                <xsl:with-param name="target" select="//div1[@type='Copyright'][1]"/>
                            </xsl:call-template>
                        </reference>
                    </xsl:if>

                    <xsl:if test="//div1[@type='Preface']">
                        <reference type="preface" title="{$strPreface}">
                            <xsl:call-template name="generate-href-attribute">
                                <xsl:with-param name="target" select="//div1[@type='Preface'][1]"/>
                            </xsl:call-template>
                        </reference>
                    </xsl:if>

                    <xsl:if test="/TEI.2/text/body/div0|/TEI.2/text/body/div1">
                        <reference type="text" title="{$strText}">
                            <xsl:call-template name="generate-href-attribute">
                                <xsl:with-param name="target" select="(/TEI.2/text/body/div0|/TEI.2/text/body/div1)[1]"/>
                            </xsl:call-template>
                        </reference>
                    </xsl:if>

                    <xsl:if test="//divgen[@type='colophon']">
                        <reference type="colophon" title="{$strColophon}">
                            <xsl:call-template name="generate-href-attribute">
                                <xsl:with-param name="target" select="//divgen[@type='colophon'][1]"/>
                            </xsl:call-template>
                        </reference>
                    </xsl:if>

                </guide>

            </package>

        </xsl:result-document>
    </xsl:template>


    <!--== metadata ========================================================-->

    <xsl:template match="title" mode="metadata">
        <dc:title>
            <xsl:value-of select="."/>
        </dc:title>
    </xsl:template>

    <xsl:template match="author" mode="metadata">
        <dc:creator opf:role="aut">
            <xsl:value-of select="."/>
        </dc:creator>
    </xsl:template>

    <xsl:template match="publicationStmt" mode="metadata">
        <dc:publisher>
            <xsl:value-of select="publisher"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="pubPlace"/>
        </dc:publisher>
    </xsl:template>

    <xsl:template match="availability" mode="metadata">
        <dc:rights>
            <xsl:value-of select="."/>
        </dc:rights>
    </xsl:template>


    <!--== manifest ========================================================-->

    <!--== main divisions ==-->


    <xsl:template match="text" mode="manifest">
        <xsl:apply-templates mode="splitter">
            <xsl:with-param name="action" select="'manifest'"/>
        </xsl:apply-templates>
    </xsl:template>


    <!--== figures ==-->

    <xsl:template match="figure" mode="manifest">
        <xsl:variable name="filename">
            <xsl:choose>
                <xsl:when test="contains(@rend, 'image(')">
                    <xsl:value-of select="substring-before(substring-after(@rend, 'image('), ')')"/>
                </xsl:when>
                <xsl:otherwise>images/<xsl:value-of select="@id"/>.jpg</xsl:otherwise>
            </xsl:choose>        
        </xsl:variable>
    
        <xsl:call-template name="manifest-image-item">
            <xsl:with-param name="filename" select="$filename"/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="*" mode="manifest-links">
        <xsl:if test="contains(@rend, 'link(')">
            <xsl:variable name="filename">
                <xsl:value-of select="substring-before(substring-after(@rend, 'link('), ')')"/>
            </xsl:variable>

            <xsl:if test="matches($filename, '^[^:]+\.(jpg|png|gif|svg)$')">
                <xsl:call-template name="manifest-image-item">
                    <xsl:with-param name="filename" select="$filename"/>
                    <xsl:with-param name="how" select="'link'"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xsl:template name="manifest-image-item">
        <xsl:param name="filename" as="xs:string"/>
        <xsl:param name="how" select="''" as="xs:string"/>

        <xsl:variable name="mimetype">
            <xsl:choose>
                <xsl:when test="contains($filename, '.jpg') or contains($filename, '.jpeg')">image/jpeg</xsl:when>
                <xsl:when test="contains($filename, '.png')">image/png</xsl:when>
                <xsl:when test="contains($filename, '.gif')">image/gif</xsl:when>
                <xsl:when test="contains($filename, '.svg')">image/svg+xml</xsl:when>
            </xsl:choose>
        </xsl:variable>

        <item>
            <!-- Append $how after id to make it unique for linked images -->
            <xsl:attribute name="id"><xsl:call-template name="generate-id"/><xsl:value-of select="$how"/></xsl:attribute>
            <xsl:attribute name="href"><xsl:value-of select="$filename"/></xsl:attribute>
            <xsl:attribute name="media-type"><xsl:value-of select="$mimetype"/></xsl:attribute>
        </item>

    </xsl:template>


    <!--== spine ===========================================================-->


    <xsl:template match="text" mode="spine">
        <xsl:apply-templates mode="splitter">
            <xsl:with-param name="action" select="'spine'"/>
        </xsl:apply-templates>
    </xsl:template>

    <!--== guide ===========================================================-->


    <!--== forget about all the rest =======================================-->

    <xsl:template match="*" mode="opf"/>

</xsl:stylesheet>
