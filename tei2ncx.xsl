<?xml version="1.0" encoding="ISO-8859-1"?>

    <xsl:stylesheet
        xmlns="http://www.daisy.org/z3986/2005/ncx/"
        xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:f="urn:stylesheet-functions"
        exclude-result-prefixes="f xs"
        version="2.0">


    <xsl:template match="TEI.2" mode="ncx">

        <xsl:result-document
                href="{$path}/{$basename}.ncx"
                doctype-public="-//NISO//DTD ncx 2005-1//EN"
                doctype-system="http://www.daisy.org/z3986/2005/ncx-2005-1.dtd"
                method="xml"
                indent="yes"
                encoding="UTF-8">
            <xsl:message terminate="no">INFO:    generated file: <xsl:value-of select="$path"/>/<xsl:value-of select="$basename"/>.ncx.</xsl:message>

            <ncx version="2005-1">
                <xsl:attribute name="xml:lang">
                    <xsl:value-of select="@lang"/>
                </xsl:attribute>

                <head>
                    <meta name="dbt:uid">
                        <xsl:attribute name="content">
                            <xsl:choose>
                                <xsl:when test="teiHeader/fileDesc/publicationStmt/idno[@type ='ISBN']"><xsl:value-of select="teiHeader/fileDesc/publicationStmt/idno[@type = 'ISBN']"/></xsl:when>
                                <xsl:when test="teiHeader/fileDesc/publicationStmt/idno[@type ='PGnum']">http://www.gutenberg.org/etext/<xsl:value-of select="teiHeader/fileDesc/publicationStmt/idno[@type = 'PGnum']"/></xsl:when>
                            </xsl:choose>
                        </xsl:attribute>
                    </meta>

                    <meta name="dtb:depth">
                        <xsl:attribute name="content">
                            <xsl:choose>
                                <xsl:when test="//div2 and //div0">3</xsl:when>
                                <xsl:when test="//div2 and //div1">2</xsl:when>
                                <xsl:when test="//div1 and //div0">2</xsl:when>
                                <xsl:otherwise>1</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </meta>

                    <meta name="dtb:totalPageCount" content="0"/>
                    <meta name="dtb:maxPageNumber" content="0"/>
                    <meta name="dtb:generator" content="tei2ncx.xsl, see http://code.google.com/p/tei2html/"/>

                </head>

                <docTitle>
                    <text><xsl:value-of select="teiHeader/fileDesc/titleStmt/title"/></text>
                </docTitle>

                <docAuthor>
                    <text><xsl:value-of select="teiHeader/fileDesc/titleStmt/author"/></text>
                </docAuthor>

                <navMap>
                    <xsl:variable name="navMap">

                        <xsl:copy-of select="f:create-nav-point(key('id', 'cover')[1], 'cover', f:message('msgCoverImage'))"/>
                        <xsl:copy-of select="f:create-nav-point(/TEI.2/text/front/titlePage[1], 'titlepage', f:message('msgTitlePage'))"/>

                        <xsl:apply-templates select="text" mode="navMap"/>

                        <xsl:copy-of select="f:create-nav-point((//divGen[@id='toc'])[1], 'contents', f:message('msgTableOfContents'))"/>
                        <xsl:copy-of select="f:create-nav-point(key('id', 'loi')[1], 'contents', f:message('msgListOfIllustrations'))"/>
                        <xsl:copy-of select="f:create-nav-point((//divGen[@type='Colophon'])[1], 'colophon', f:message('msgColophon'))"/>

                    </xsl:variable>
                    <xsl:apply-templates select="$navMap" mode="playorder"/>
                </navMap>

            </ncx>

        </xsl:result-document>

    </xsl:template>

    <xsl:function name="f:create-nav-point">
        <xsl:param name="node"/>
        <xsl:param name="class" as="xs:string"/>
        <xsl:param name="label" as="xs:string"/>

        <xsl:if test="$node">
            <navPoint class="{$class}">
                <xsl:attribute name="id">
                    <xsl:call-template name="generate-id-for">
                        <xsl:with-param name="node" select="$node"/>
                    </xsl:call-template>
                </xsl:attribute>
                <navLabel><text><xsl:value-of select="$label"/></text></navLabel>
                <content>
                    <xsl:attribute name="src">
                        <xsl:call-template name="splitter-generate-url-for">
                            <xsl:with-param name="node" select="$node"/>
                        </xsl:call-template>
                    </xsl:attribute>
                </content>
            </navPoint>
        </xsl:if>
    </xsl:function>


    <!--== navMap ==========================================================-->

    <xsl:template match="text" mode="navMap">
        <xsl:apply-templates select="front | body | back" mode="navMap"/>
    </xsl:template>

    <xsl:template match="front | body | back" mode="navMap">
        <xsl:apply-templates select="div0 | div1" mode="navMap"/>
    </xsl:template>

    <xsl:template match="div0" mode="navMap">
        <xsl:choose>
            <xsl:when test="contains(@rend, 'toc-head(')">
                <navPoint class="part">
                    <xsl:attribute name="id"><xsl:call-template name="generate-id"/></xsl:attribute>
                    <navLabel>
                        <text>
                            <xsl:value-of select="substring-before(substring-after(@rend, 'toc-head('), ')')"/>
                        </text>
                    </navLabel>
                    <content>
                        <xsl:attribute name="src"><xsl:call-template name="splitter-generate-filename-for"/></xsl:attribute>
                    </content>
                    <xsl:if test="div1">
                        <xsl:apply-templates select="div1" mode="navMap"/>
                    </xsl:if>
                </navPoint>
            </xsl:when>

            <xsl:when test="head">
                <navPoint class="part">
                    <xsl:attribute name="id"><xsl:call-template name="generate-id"/></xsl:attribute>
                    <navLabel>
                        <text>
                            <xsl:apply-templates select="head" mode="navLabel"/>
                        </text>
                    </navLabel>
                    <content>
                        <xsl:attribute name="src"><xsl:call-template name="splitter-generate-filename-for"/></xsl:attribute>
                    </content>
                    <xsl:if test="div1">
                        <xsl:apply-templates select="div1" mode="navMap"/>
                    </xsl:if>
                </navPoint>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="div1" mode="navMap">
        <xsl:choose>
            <xsl:when test="contains(@rend, 'toc-head(')">
                <navPoint class="part">
                    <xsl:attribute name="id"><xsl:call-template name="generate-id"/></xsl:attribute>
                    <navLabel><text><xsl:value-of select="substring-before(substring-after(@rend, 'toc-head('), ')')"/></text></navLabel>
                    <content>
                        <xsl:attribute name="src"><xsl:call-template name="splitter-generate-filename-for"/></xsl:attribute>
                    </content>
                    <xsl:if test="div2">
                        <xsl:apply-templates select="div2" mode="navMap"/>
                    </xsl:if>
                </navPoint>
            </xsl:when>

            <xsl:when test="head">
                <navPoint class="chapter">
                    <xsl:attribute name="id"><xsl:call-template name="generate-id"/></xsl:attribute>
                    <navLabel>
                        <text>
                            <xsl:apply-templates select="head" mode="navLabel"/>
                        </text>
                    </navLabel>
                    <content>
                        <xsl:attribute name="src"><xsl:call-template name="splitter-generate-filename-for"/></xsl:attribute>
                    </content>
                    <xsl:if test="div2">
                        <xsl:apply-templates select="div2" mode="navMap"/>
                    </xsl:if>
                </navPoint>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="div2" mode="navMap">
        <xsl:choose>
            <xsl:when test="contains(@rend, 'toc-head(')">
                <navPoint class="part">
                    <xsl:attribute name="id"><xsl:call-template name="generate-id"/></xsl:attribute>
                    <navLabel><text><xsl:value-of select="substring-before(substring-after(@rend, 'toc-head('), ')')"/></text></navLabel>
                    <content>
                        <xsl:attribute name="src"><xsl:call-template name="splitter-generate-filename-for"/></xsl:attribute>
                    </content>
                </navPoint>
            </xsl:when>

            <xsl:when test="head">
                <navPoint class="section">
                    <xsl:attribute name="id"><xsl:call-template name="generate-id"/></xsl:attribute>
                    <navLabel>
                        <text>
                            <xsl:apply-templates select="head" mode="navLabel"/>
                        </text>
                    </navLabel>
                    <content>
                        <xsl:attribute name="src"><xsl:call-template name="splitter-generate-url-for"></xsl:call-template></xsl:attribute>
                    </content>
                </navPoint>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="head[@type='super']" mode="navLabel"/>

    <xsl:template match="head" mode="navLabel">
        <xsl:apply-templates mode="navLabel"/>
        <xsl:if test="following-sibling::head[not(@type='super')]">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="note" mode="navLabel"/>

    <!--== playorder =======================================================-->

    <xsl:template match="@*|node()" mode="playorder">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="playorder"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="ncx:navPoint" mode="playorder">
        <xsl:copy>
            <xsl:attribute name="playOrder"><xsl:number level="any" count="ncx:navPoint"/></xsl:attribute>
            <xsl:apply-templates select="@*|node()" mode="playorder"/>
        </xsl:copy>
    </xsl:template>


    <!--== forget about all the rest =======================================-->

    <xsl:template match="*" mode="ncx"/>

</xsl:stylesheet>
