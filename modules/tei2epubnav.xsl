<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:epub="http://www.idpf.org/2007/ops"
                xmlns:f="urn:stylesheet-functions"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="f xd">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to create an ePub3 navigation document.</xd:short>
        <xd:detail>This stylesheet creates an ePub3 navigation document, following the ePub3 standard. It currently relies on the
        normal toc-creating templates, with some tweaks to remove details not allowable in an ePub3 navigation document.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2014, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Create the ePub3 navigation document.</xd:short>
        <xd:detail>Create a separate ePub3 navigation document.</xd:detail>
    </xd:doc>

    <xsl:template match="TEI.2 | TEI" mode="ePubNav">
        <xsl:result-document href="{$path}/{$basename}-nav.xhtml">
            <xsl:copy-of select="f:log-info('Generated file: {1}/{2}-nav.xhtml.', ($path, $basename))"/>
            <xsl:call-template name="ePubNav"/>
        </xsl:result-document>
    </xsl:template>


    <xd:doc>
        <xd:short>Create the ePub3 navigation document.</xd:short>
        <xd:detail>Create a separate ePub3 navigation document. We use a named template to enable testing this with xspec.</xd:detail>
    </xd:doc>

    <xsl:template name="ePubNav">
        <html>
            <xsl:attribute name="xml:lang">
                <xsl:value-of select="f:fix-lang(@lang)"/>
            </xsl:attribute>
            <head>
                <title><xsl:value-of select="f:message('msgTableOfContents')"/></title>
                <meta charset="utf-8"/>
            </head>
            <body>
                <xsl:apply-templates select="text[1]" mode="ePubNav"/>
                <xsl:apply-templates select="text[1]" mode="navLandMarks"/>
                <xsl:apply-templates select="text[1]" mode="navPageList"/>
            </body>
        </html>
    </xsl:template>


    <xd:doc>
        <xd:short>Create the ePub3 navigation document toc-body.</xd:short>
        <xd:detail>Create the toc for the navigation document. Currently, this uses the standard toc-building templates.</xd:detail>
    </xd:doc>

    <!-- http://www.idpf.org/epub/301/spec/epub-contentdocs.html#sec-xhtml-nav-def -->

    <xsl:template match="text" mode="ePubNav">
        <nav epub:type="toc" id="toc">
            <h1><xsl:value-of select="f:message('msgTableOfContents')"/></h1>
            <xsl:call-template name="toc-body">
                <xsl:with-param name="list-element" select="'ol'"/>
                <xsl:with-param name="show-page-numbers" tunnel="yes" select="false()"/>
                <xsl:with-param name="show-div-numbers" tunnel="yes" select="false()"/>
            </xsl:call-template>
        </nav>
    </xsl:template>


    <xsl:template match="*" mode="ePubNav"/>


    <xd:doc>
        <xd:short>Create the ePub3 navigation document page list.</xd:short>
        <xd:detail>Create the ePub3 navigation document page list. Only include numbered pages and avoid adding page-breaks
        that occur in footnotes.</xd:detail>
    </xd:doc>

    <xsl:template match="text" mode="navPageList">
        <nav epub:type="page-list" id="page-list">
            <ol>
                <xsl:for-each select="//pb[@n and not(ancestor::note)]">
                    <li>
                        <a href="{f:generate-href(.)}">
                            <xsl:value-of select="@n"/>
                        </a>
                    </li>
                </xsl:for-each>
            </ol>
        </nav>
    </xsl:template>


    <xd:doc>
        <xd:short>Create the ePub3 navigation document landmarks list.</xd:short>
        <xd:detail>Create the ePub3 navigation document landmarks list. Include the first occurrence of each
        of the possible categories.</xd:detail>
    </xd:doc>

    <!-- http://www.idpf.org/accessibility/guidelines/content/nav/landmarks.php -->

    <xsl:template match="text" mode="navLandMarks">
        <nav epub:type="landmarks" id="guide">
            <h2><xsl:value-of select="f:message('msgGuide')"/></h2>
            <ol>
                <xsl:if test="//figure[@id='cover-image']">
                    <li>
                        <a epub:type="cover" href="{f:generate-href((//figure[@id='cover-image'])[1])}">
                            <xsl:value-of select="f:message('msgCover')"/>
                        </a>
                    </li>
                </xsl:if>

                <xsl:if test="//*[@id='toc'] | //divGen[@type='toc']">
                    <li>
                        <a epub:type="toc" href="{f:generate-href((//*[@id='toc'] | //divGen[@type='toc'])[1])}">
                            <xsl:value-of select="f:message('msgToc')"/>
                        </a>
                    </li>
                </xsl:if>

                <xsl:if test="//*[@id='loi']">
                    <li>
                        <a epub:type="loi" href="{f:generate-href((//*[@id='loi'])[1])}">
                            <xsl:value-of select="f:message('msgToc')"/>
                        </a>
                    </li>
                </xsl:if>

                <xsl:if test="//frontmatter/div1">
                    <li>
                        <a epub:type="frontmatter" href="{f:generate-href((//frontmatter/div1)[1])}">
                            <xsl:value-of select="f:message('msgFrontMatter')"/>
                        </a>
                    </li>
                </xsl:if>

                <xsl:if test="//titlePage">
                    <li>
                        <a epub:type="titlepage" href="{f:generate-href((//titlePage)[1])}">
                            <xsl:value-of select="f:message('msgTitlePage')"/>
                        </a>
                    </li>
                </xsl:if>

                <xsl:if test="//*[@type='Preface']">
                    <li>
                        <a epub:type="preface" href="{f:generate-href((//*[@type='Preface'])[1])}">
                            <xsl:value-of select="f:message('msgPreface')"/>
                        </a>
                    </li>
                </xsl:if>

                <xsl:if test="//body/div0|//body/div1">
                    <li>
                        <a epub:type="bodymatter" href="{f:generate-href((//body/div0|//body/div1)[1])}">
                            <xsl:value-of select="f:message('msgBodyMatter')"/>
                        </a>
                    </li>
                </xsl:if>

                <xsl:if test="//backmatter/div1">
                    <li>
                        <a epub:type="frontmatter" href="{f:generate-href((//backmatter/div1)[1])}">
                            <xsl:value-of select="f:message('msgBackMatter')"/>
                        </a>
                    </li>
                </xsl:if>

                <xsl:if test="//*[@type='Glossary']">
                    <li>
                        <a epub:type="glossary" href="{f:generate-href((//*[@type='Glossary'])[1])}">
                            <xsl:value-of select="f:message('msgGlossary')"/>
                        </a>
                    </li>
                </xsl:if>

                <xsl:if test="//*[@type='Bibliography']">
                    <li>
                        <a epub:type="bibliography" href="{f:generate-href((//*[@type='Bibliography'])[1])}">
                            <xsl:value-of select="f:message('msgBibliography')"/>
                        </a>
                    </li>
                </xsl:if>

                <xsl:if test="//*[@type='Index']">
                    <li>
                        <a epub:type="index" href="{f:generate-href((//*[@type='Index'])[1])}">
                            <xsl:value-of select="f:message('msgIndex')"/>
                        </a>
                    </li>
                </xsl:if>
            </ol>
        </nav>
    </xsl:template>

</xsl:stylesheet>
