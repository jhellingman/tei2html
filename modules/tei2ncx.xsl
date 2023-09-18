<?xml version="1.0" encoding="ISO-8859-1"?>

    <xsl:stylesheet version="3.0"
                    xmlns="http://www.daisy.org/z3986/2005/ncx/"
                    xmlns:f="urn:stylesheet-functions"
                    xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
                    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                    xmlns:xs="http://www.w3.org/2001/XMLSchema"
                    exclude-result-prefixes="f xd xs">

    <xd:doc type="stylesheet">
        <xd:short>TEI stylesheet to convert a TEI document to an NCX file, used in ePub 2.0.</xd:short>
        <xd:detail>This stylesheet generates an NCX file, as used in ePub 2.0 (and ePub3 for backwards compatibility).</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2012-15, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <!-- Epubcheck complains about the doctypes, so leave them empty.
         -//NISO//DTD ncx 2005-1//EN http://www.daisy.org/z3986/2005/ncx-2005-1.dtd
    -->
    <xsl:output name="ncx"
        doctype-public=""
        doctype-system=""
        method="xml"
        indent="yes"
        encoding="utf-8"/>


    <xd:doc>
        <xd:short>Generate an NCX file.</xd:short>
        <xd:detail>
            <p>Generate an NCX file. This file is the table of contents for older (ePub 2.0)
            ePub readers. The most important element is the <code>navMap</code>.</p>

            <p>The navMap is generated in two phases. In the first, the contents are collected
            in a variable, in the second, the nodes of the navMap are given the correct playOrder
            attribute.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="TEI.2 | TEI" mode="ncx">

        <xsl:result-document format="ncx" href="{$path}/{$basename}.ncx">
            <xsl:copy-of select="f:log-info('Generated NCX file: {1}/{2}.ncx.', ($path, $basename))"/>

            <ncx version="2005-1">
                <xsl:attribute name="xml:lang">
                    <xsl:value-of select="f:fix-lang(@lang)"/>
                </xsl:attribute>

                <head>
                    <meta name="dtb:uid">
                        <xsl:attribute name="content">
                            <xsl:value-of select="teiHeader/fileDesc/publicationStmt/idno[@type = 'epub-id']"/>
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
                    <meta name="dtb:generator" content="tei2ncx.xsl, see https://github.com/jhellingman/tei2html"/>
                </head>

                <docTitle>
                    <text><xsl:value-of select="teiHeader/fileDesc/titleStmt/title[not(@type) or @type='main']"/></text>
                </docTitle>

                <docAuthor>
                    <text><xsl:value-of select="teiHeader/fileDesc/titleStmt/author"/></text>
                </docAuthor>

                <navMap>
                    <xsl:variable name="navMap">

                        <xsl:copy-of select="f:create-nav-point(key('id', 'cover')[1], 'cover', f:message('msgCoverImage'))"/>
                        <xsl:copy-of select="f:create-nav-point((/*[self::TEI.2 or self::TEI]/text/front/titlePage)[1], 'titlepage', f:message('msgTitlePage'))"/>

                        <xsl:apply-templates select="text" mode="navMap"/>

                        <xsl:copy-of select="f:create-nav-point((//divGen[@id='toc'])[1], 'contents', f:message('msgTableOfContents'))"/>
                        <xsl:copy-of select="f:create-nav-point((//divGen[@id='loi'])[1], 'contents', f:message('msgListOfIllustrations'))"/>
                        <xsl:copy-of select="f:create-nav-point((//divGen[@type='Colophon'])[1], 'colophon', f:message('msgColophon'))"/>

                    </xsl:variable>
                    <xsl:apply-templates select="$navMap" mode="playOrder"/>
                </navMap>
            </ncx>
        </xsl:result-document>
    </xsl:template>


    <xd:doc>
        <xd:short>Create a navPoint element.</xd:short>
        <xd:detail>
            <p>Create a navPoint element for a given node, if the node is present.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:create-nav-point">
        <xsl:param name="node"/>
        <xsl:param name="class" as="xs:string"/>
        <xsl:param name="label" as="xs:string"/>

        <xsl:if test="$node">
            <navPoint class="{$class}" id="{f:generate-id($node)}">
                <navLabel><text><xsl:value-of select="$label"/></text></navLabel>
                <content src="{f:determine-url($node)}"/>
            </navPoint>
        </xsl:if>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine the textual content of the label for a division.</xd:short>
    </xd:doc>

    <xsl:function name="f:create-label">
        <xsl:param name="node"/>

        <xsl:choose>
            <xsl:when test="f:has-rend-value($node/@rend, 'toc-head')">
                <xsl:value-of select="f:rend-value($node/@rend, 'toc-head')"/>
            </xsl:when>
            <xsl:when test="$node/head">
                <xsl:apply-templates select="$node/head" mode="navLabel"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <!--== navMap ==========================================================-->

    <xsl:template match="text" mode="navMap">
        <xsl:apply-templates select="front | group | body | back" mode="navMap"/>
    </xsl:template>


    <xsl:template match="group" mode="navMap">
        <xsl:apply-templates select="text" mode="navMap"/>
    </xsl:template>


    <xsl:template match="front | body | back" mode="navMap">
        <xsl:apply-templates select="div0 | div1" mode="navMap"/>
    </xsl:template>


    <xsl:template match="div0" mode="navMap">
        <xsl:if test="not(f:rend-value(@rend, 'display') = 'none')">

            <xsl:variable name="label" select="f:create-label(.)"/>

            <xsl:if test="$label != ''">
                <navPoint class="part" id="{f:generate-id(.)}">
                    <navLabel>
                        <text>
                            <xsl:value-of select="$label"/>
                        </text>
                    </navLabel>
                    <content src="{f:determine-filename(.)}"/>
                    <xsl:if test="div1">
                        <xsl:apply-templates select="div1" mode="navMap"/>
                    </xsl:if>
                </navPoint>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xsl:template match="div1" mode="navMap">
        <xsl:if test="not(f:rend-value(@rend, 'display') = 'none')">

            <xsl:variable name="label" select="f:create-label(.)"/>

            <xsl:if test="$label != ''">
                <navPoint class="chapter" id="{f:generate-id(.)}">
                    <navLabel>
                        <text>
                            <xsl:value-of select="$label"/>
                        </text>
                    </navLabel>
                    <content src="{f:determine-filename(.)}"/>
                    <xsl:if test="div2">
                        <xsl:apply-templates select="div2" mode="navMap"/>
                    </xsl:if>
                </navPoint>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xsl:template match="div2" mode="navMap">
        <xsl:if test="not(f:rend-value(@rend, 'display') = 'none')">

            <xsl:variable name="label" select="f:create-label(.)"/>

            <xsl:if test="$label != ''">
                <navPoint class="section" id="{f:generate-id(.)}">
                    <navLabel>
                        <text>
                            <xsl:value-of select="$label"/>
                        </text>
                    </navLabel>
                    <content src="{f:determine-url(.)}"/>
                </navPoint>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Ignore 'super' heads, that is, heads repeating the higher-level title.</xd:short>
    </xd:doc>

    <xsl:template match="head[@type='super']" mode="navLabel"/>


    <xd:doc>
        <xd:short>Process the textual content of a head.</xd:short>
    </xd:doc>

    <xsl:template match="head" mode="navLabel">
        <xsl:apply-templates mode="navLabel"/>
        <xsl:if test="following-sibling::head[not(@type='super')]">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Ignore footnotes appearing in a head.</xd:short>
    </xd:doc>

    <xsl:template match="note" mode="navLabel"/>


    <xd:doc>
        <xd:short>Ignore line-numbers appearing in a head.</xd:short>
    </xd:doc>

    <xsl:template match="ab[@type='lineNum']" mode="navLabel"/>


    <!--== playOrder =======================================================-->

    <xsl:template match="@*|node()" mode="playOrder">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="playOrder"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="ncx:navPoint" mode="playOrder">
        <xsl:copy>
            <xsl:attribute name="playOrder">
                <xsl:number level="any" count="ncx:navPoint"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*|node()" mode="playOrder"/>
        </xsl:copy>
    </xsl:template>


    <!--== forget about all the rest =======================================-->

    <xsl:template match="*" mode="ncx"/>

</xsl:stylesheet>
