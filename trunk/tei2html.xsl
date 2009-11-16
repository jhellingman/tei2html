<?xml version="1.0" encoding="iso-8859-1" ?>
<!DOCTYPE xsl:stylesheet [

    <!ENTITY tab        "&#x09;">
    <!ENTITY lf         "&#x0A;">
    <!ENTITY cr         "&#x0D;">
    <!ENTITY deg        "&#176;">
    <!ENTITY ldquo      "&#x201C;">
    <!ENTITY nbsp       "&#160;">
    <!ENTITY mdash      "&#x2014;">
    <!ENTITY prime      "&#x2032;">
    <!ENTITY Prime      "&#x2033;">
    <!ENTITY plusmn     "&#x00B1;">
    <!ENTITY frac14     "&#x00BC;">
    <!ENTITY frac12     "&#x00BD;">
    <!ENTITY frac34     "&#x00BE;">

]>
<!--

    Stylesheet to convert TEI to HTML

    Developed by Jeroen Hellingman <jeroen@bohol.ph>, to be used together with a
    CSS stylesheet. Please contact me if you have problems with this stylesheet,
    or have improvements or bug fixes to contribute.

    This stylesheet can be used with the saxon XSL processor, or with the
    build-in XSL processor in IE 6.0 or higher. Note that the XLS processor
    in Firefox will not always do the right thing.

    You can embed this style sheet in the source document with the
    <?xml-stylesheet type="text/xsl" href="stylesheet.xsl"?> processing instruction.
    This works with IE 6.0 or the latest Mozilla browsers.

    This file is made available under the GNU General Public License, version 3.0 or later.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msg="http://www.gutenberg.ph/2006/schemas/messages"
    xmlns:img="http://www.gutenberg.ph/2006/schemas/imageinfo"
    version="1.0"
    exclude-result-prefixes="msg img"
    >

    <xsl:include href="utils.xsl"/>
    <xsl:include href="localization.xsl"/>
    <xsl:include href="messages.xsl"/>
    <xsl:include href="inline.xsl"/>
    <xsl:include href="contents.xsl"/>
    <xsl:include href="tables.xsl"/>
    <xsl:include href="lists.xsl"/>
    <xsl:include href="figures.xsl"/>
    <xsl:include href="colophon.xsl"/>


    <!--
    <xsl:output
        doctype-public="-//W3C//DTD XHTML 1.1//EN"
        doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
        method="xml"
        encoding="UTF-8"/>
    -->

    <xsl:output
        doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
        doctype-system="http://www.w3.org/TR/html4/loose.dtd"
        method="html"
        encoding="ISO-8859-1"/>


    <!--====================================================================-->

    <!-- imageInfoFile is an XML file that contains information on the dimensions of images. -->
    <xsl:param name="imageInfoFile"/>
    <xsl:param name="customCssFile"/>

    <xsl:param name="optionPrinceMarkup" select="'No'"/>
    <xsl:param name="optionEPubMarkup" select="'No'"/>
    <xsl:param name="optionExternalCSS" select="'No'"/>
    <xsl:param name="optionPGHeaders" select="'No'"/>


    <!--====================================================================-->

    <xsl:variable name="mimeType" select="'text/html'"/>   <!-- 'text/html' or 'application/xhtml+xml'. -->
    <xsl:variable name="encoding" select="document('')/xsl:stylesheet/xsl:output/@encoding"/>

    <xsl:variable name="title" select="/TEI.2/teiHeader/fileDesc/titleStmt/title" />
    <xsl:variable name="author" select="/TEI.2/teiHeader/fileDesc/titleStmt/author" />
    <xsl:variable name="publisher" select="/TEI.2/teiHeader/fileDesc/publicationStmt/publisher" />
    <xsl:variable name="pubdate" select="/TEI.2/teiHeader/fileDesc/publicationStmt/date" />

    <xsl:variable name="language" select="/TEI.2/@lang" />
    <xsl:variable name="baselanguage" select="substring-before($language,'-')" />
    <xsl:variable name="defaultlanguage" select="'en'" />
    <xsl:variable name="messages" select="document('messages.xml')/msg:repository"/>

    <xsl:variable name="unitsUsed" select="'Original'"/>

    <!--====================================================================-->


    <xsl:template match="TEI.2">
        <xsl:comment>
            <xsl:text> This HTML file has been automatically generated from an XML source. </xsl:text>
        </xsl:comment>
        <xsl:text> <!-- insert extra new-line for PG -->
        </xsl:text>
        <html>
            <xsl:call-template name="setLangAttribute"/>

            <head>
                <title>
                    <xsl:value-of select="$title"/>
                </title>

                <meta http-equiv="Content-Type" content="{$mimeType}; charset={$encoding}"/>
                <meta name="generator" content="tei2html.xsl, see http://code.google.com/p/tei2html/"/>
                <meta name="author"             content="{$author}"/>

                <!-- Insert Dublin Core metadata -->
                <link rel="schema.DC"     href="http://dublincore.org/documents/1998/09/dces/"/> <!-- WAS: http://purl.org/DC/elements/1.0/ -->

                <meta name="DC.Creator"   content="{$author}"/>
                <meta name="DC.Title"     content="{$title}"/>
                <meta name="DC.Date"      content="{$pubdate}"/>
                <meta name="DC.Language"  content="{$language}"/>
                <meta name="DC.Format"    content="text/html"/>
                <meta name="DC.Publisher" content="{$publisher}"/>
                <xsl:if test="//idno[@type='PGnum'] and not(contains(//idno[@type='PGnum'], '#'))">
                    <meta name="DC.Rights" content="{$strNotCopyrightedUS}"/>
                    <meta name="DC.Identifier">
                        <xsl:attribute name="content">http://www.gutenberg.org/etext/<xsl:value-of select="//idno[@type='PGnum']"/></xsl:attribute>
                    </meta>
                </xsl:if>

                <xsl:if test="$optionExternalCSS = 'Yes'">
                    <link href="style/gutenberg.css"    rel="stylesheet"            type="text/css"/>
                    <link href="style/arctic.css"       rel="stylesheet"            type="text/css" title="Artic Blue"/>

                    <link href="style/amazonia.css"     rel="alternate stylesheet"  type="text/css" title="Amazonia Green"/>
                    <link href="style/borneo.css"       rel="alternate stylesheet"  type="text/css" title="Borneo Brown"/>

                    <link href="style/print.css"        rel="stylesheet"            type="text/css" media="print"/>
                </xsl:if>

                <xsl:variable name="stylesheetname">
                    <xsl:choose>
                        <xsl:when test="contains(/TEI.2/text/@rend, 'stylesheet(')">
                            <xsl:value-of select="substring-before(substring-after(/TEI.2/text/@rend, 'stylesheet('), ')')"/>
                        </xsl:when>
                        <xsl:otherwise>style/arctic.css</xsl:otherwise>
                    </xsl:choose>.xml
                </xsl:variable>

                <xsl:if test="$optionExternalCSS = 'No'">
                    <!-- Pull in CSS sheets. This requires the CSS to be wrapped in an XML tag at toplevel, so they become valid XML -->
                    <style type="text/css">
                        /* Standard CSS stylesheet */
                        <xsl:variable name="stylesheet" select="document('style/gutenberg.css.xml')"/>
                        <xsl:copy-of select="$stylesheet/*/node()"/>

                        /* Supplement CSS stylesheet "<xsl:value-of select="$stylesheetname"/>" */
                        <xsl:variable name="stylesheetSupplement" select="document(normalize-space($stylesheetname))"/>
                        <xsl:copy-of select="$stylesheetSupplement/*/node()"/>

                        /* Standard Aural CSS stylesheet */
                        <xsl:variable name="stylesheetAural" select="document('style/aural.css.xml')"/>
                        <xsl:copy-of select="$stylesheetAural/*/node()"/>

                        <xsl:if test="$customCssFile">
                            /* Custom CSS stylesheet "<xsl:value-of select="$customCssFile"/>" */
                            <xsl:variable name="stylesheetCustom" select="document(normalize-space($customCssFile))"/>
                            <xsl:copy-of select="$stylesheetCustom/*/node()"/>
                        </xsl:if>
                    </style>
                    <!-- Pull in CSS sheet for print (using Prince). -->
                    <xsl:if test="$optionPrinceMarkup = 'Yes'">
                        <style type="text/css" media="print">
                            /* CSS stylesheet for printing */
                            <xsl:variable name="printstylesheet" select="document('style/print.css.xml')"/>
                            <xsl:copy-of select="$printstylesheet/*/node()"/>
                        </style>
                    </xsl:if>
                </xsl:if>

            </head>
            <body><xsl:text> <!-- insert extra new-line for PG -->
            </xsl:text>
                <xsl:if test="$optionPGHeaders = 'Yes'">
                    <xsl:call-template name="PGHeader"/>
                </xsl:if>
                <xsl:apply-templates/>
                <xsl:if test="$optionPGHeaders = 'Yes'">
                    <xsl:call-template name="PGFooter"/>
                </xsl:if>
            </body>
        </html><xsl:text> <!-- insert extra new-line for PG -->
        </xsl:text>
    </xsl:template>


    <!--====================================================================-->
    <!-- TEI Header -->

    <!-- Suppress the header in the output -->

    <xsl:template match="teiHeader"/>


    <!--====================================================================-->
    <!-- Main subdivisions of work -->

    <xsl:template match="text">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="front">
        <div class="front">
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="body">
        <div class="body">
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="back">
        <div class="back">
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <!--====================================================================-->
    <!-- Title Page -->

    <xsl:template match="titlePage">
        <div class="titlePage">
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>

    <xsl:template match="docTitle" mode="titlePage">
        <xsl:apply-templates mode="titlePage"/>
    </xsl:template>

    <xsl:template match="titlePart" mode="titlePage">
        <h1 class="docTitle">
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates mode="titlePage"/>
        </h1>
    </xsl:template>

    <xsl:template match="titlePart[@type='sub']" mode="titlePage">
        <h2 class="docTitle">
            <xsl:apply-templates mode="titlePage"/>
        </h2>
    </xsl:template>

    <xsl:template match="byline" mode="titlePage">
        <h2 class="byline">
            <xsl:apply-templates mode="titlePage"/>
        </h2>
    </xsl:template>

    <xsl:template match="docAuthor" mode="titlePage">
        <span class="docAuthor">
            <xsl:apply-templates mode="titlePage"/>
        </span>
    </xsl:template>

    <xsl:template match="lb" mode="titlePage">
        <br/>
    </xsl:template>

    <xsl:template match="docImprint" mode="titlePage">
        <h2 class="docImprint">
            <xsl:apply-templates/>
        </h2>
    </xsl:template>

    <xsl:template match="epigraph" mode="titlePage">
        <h2 class="docImprint">
            <xsl:apply-templates/>
        </h2>
    </xsl:template>

    <xsl:template match="figure" mode="titlePage">
        <xsl:apply-templates select="."/>
    </xsl:template>


    <!--====================================================================-->
    <!-- Page Breaks -->

    <xsl:template match="pb">
        <xsl:choose>
            <xsl:when test="@n">
                <span class="pagenum">[<a>
                    <xsl:call-template name="generate-id-attribute"/>
                    <xsl:call-template name="generate-href-attribute"/>
                    <xsl:value-of select="@n"/></a>]</span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="generate-anchor"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!--====================================================================-->
    <!-- Thematic Breaks -->

    <xsl:template match="milestone[@unit='theme' or @unit='tb']">
        <xsl:call-template name="closepar"/>
        <xsl:choose>
            <xsl:when test="contains(@rend, 'stars')">
                <p class="tb">*&nbsp;&nbsp;&nbsp;*&nbsp;&nbsp;&nbsp;*</p>
            </xsl:when>
            <xsl:when test="contains(@rend, 'star')">
                <p class="tb">*</p>
            </xsl:when>
            <xsl:when test="contains(@rend, 'space')">
                <p class="tb"/>
            </xsl:when>
            <xsl:otherwise>
                <hr class="tb"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>


    <xsl:template match="milestone">
        <xsl:call-template name="generate-anchor"/>
    </xsl:template>


    <!--====================================================================-->
    <!-- Divisions and Headings -->

    <xsl:template name="GenerateLabel">
        <xsl:param name="headingLevel" select="'h2'"/>
        <xsl:if test="contains(./@rend, 'label(yes)')">
            <xsl:element name="{$headingLevel}">
                <xsl:attribute name="class">label</xsl:attribute>
                <xsl:call-template name="TranslateType"/>
                <xsl:value-of select="@n"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template name="TranslateType">
        <xsl:choose>
            <xsl:when test="@type='Appendix' or @type='appendix'">
                <xsl:value-of select="$strAppendix"/><xsl:text> </xsl:text>
            </xsl:when>
            <xsl:when test="@type='Chapter' or @type='chapter'">
                <xsl:value-of select="$strChapter"/><xsl:text> </xsl:text>
            </xsl:when>
            <xsl:when test="@type='Part' or @type='part'">
                <xsl:value-of select="$strPart"/><xsl:text> </xsl:text>
            </xsl:when>
            <xsl:when test="@type='Book' or @type='book'">
                <xsl:value-of select="$strBook"/><xsl:text> </xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="headText">
        <xsl:call-template name="generate-id-attribute"/>
        <xsl:call-template name="setLangAttribute"/>
        <xsl:call-template name="setHtmlClass"/>
        <xsl:if test="contains(@rend, 'align(')">
            <xsl:attribute name="align">
                <xsl:value-of select="substring-before(substring-after(@rend, 'align('), ')')"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template name="setHtmlClass">
        <xsl:choose>
            <xsl:when test="@type">
                <xsl:attribute name="class"><xsl:value-of select="@type"/></xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="class">normal</xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="headPicture">
        <xsl:if test="contains(@rend, 'image(')">
            <div class="figure">
                <xsl:call-template name="setLangAttribute"/>
                <xsl:call-template name="insertimage2">
                    <xsl:with-param name="alt">
                    <xsl:choose>
                        <xsl:when test="contains(@rend, 'image-alt')">
                            <xsl:value-of select="substring-before(substring-after(@rend, 'image-alt('), ')')"/>
                        </xsl:when>
                        <xsl:when test=". != ''">
                            <xsl:value-of select="."/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$strOrnament"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </div>
        </xsl:if>
    </xsl:template>


    <!-- div0 -->

    <xsl:template match="div0">
        <div class="div0">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:call-template name="GenerateLabel"/>
            <xsl:apply-templates/>

            <!-- Include footnotes in the div0, if not done so earlier -->

            <xsl:if test=".//note[(@place='foot' or not(@place)) and not(ancestor::div1)] and not(ancestor::q) and not(.//div1)">
                <div class="footnotes">
                    <hr class="fnsep"/>
                    <xsl:apply-templates mode="footnotes" select=".//note[(@place='foot' or not(@place)) and not(ancestor::div1)]"/>
                </div>
            </xsl:if>
        </div>
    </xsl:template>


    <xsl:template match="div0/head">
        <xsl:call-template name="headPicture"/>
        <xsl:if test="not(contains(@rend, 'display(image-only)'))">
            <h2>
                <xsl:call-template name="headText"/>
            </h2>
        </xsl:if>
    </xsl:template>


    <!-- div1 -->

    <xsl:template match="div1[@type='TranscriberNote']">
        <div class="transcribernote">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="div1">
        <!-- HACK: Include footnotes in a preceding part of the div0 section here -->
        <xsl:if test="count(preceding-sibling::div1) = 0 and ancestor::div0">
            <xsl:if test="..//note[(@place='foot' or not(@place)) and not(ancestor::div1)]">
                <div class="footnotes">
                    <hr class="fnsep"/>
                    <xsl:apply-templates mode="footnotes" select="..//note[(@place='foot' or not(@place)) and not(ancestor::div1)]"/>
                </div>
            </xsl:if>
        </xsl:if>

        <div>
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:attribute name="class">div1<xsl:if test="@type='Index'"> index</xsl:if>
                <xsl:if test="contains(@rend, 'class(')">
                    <xsl:text> </xsl:text><xsl:value-of select="substring-before(substring-after(@rend, 'class('), ')')"/>
                </xsl:if>
                <xsl:if test="@type='Advertisment'"> advertisment</xsl:if>
            </xsl:attribute>

            <xsl:if test="//*[@id='toc'] and not(ancestor::q)">
                <!-- If we have an element with id 'toc', include a link to it (except in quoted material) -->
                <span class="pagenum">
                    [<a href="#toc"><xsl:value-of select="$strToc"/></a>]
                </span>
            </xsl:if>

            <xsl:call-template name="GenerateLabel"/>
            <xsl:apply-templates/>

            <xsl:if test=".//note[@place='foot' or not(@place)] and not(ancestor::q)">
                <div class="footnotes">
                    <hr class="fnsep"/>
                    <xsl:apply-templates mode="footnotes" select=".//note[@place='foot' or not(@place)]"/>
                </div>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template match="div1/head">
        <xsl:call-template name="headPicture"/>
        <xsl:if test="not(contains(@rend, 'display(image-only)'))">
            <h2>
                <xsl:call-template name="headText"/>
            </h2>
        </xsl:if>
    </xsl:template>


    <!-- div2 -->

    <xsl:template match="div2">
        <div class="div2">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:call-template name="GenerateLabel">
                <xsl:with-param name="headingLevel" select="'h2'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="div2/head">
        <xsl:call-template name="headPicture"/>
        <h3>
            <xsl:call-template name="headText"/>
        </h3>
    </xsl:template>


    <!-- div3 -->

    <xsl:template match="div3">
        <div class="div3">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="div3/head">
        <xsl:call-template name="headPicture"/>
        <h4>
            <xsl:call-template name="headText"/>
        </h4>
    </xsl:template>


    <!-- div4 -->

    <xsl:template match="div4">
        <div class="div4">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="div4/head">
        <xsl:call-template name="headPicture"/>
        <h5>
            <xsl:call-template name="headText"/>
        </h5>
    </xsl:template>


    <!-- div5 -->

    <xsl:template match="div5">
        <div class="div5">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="div5/head">
        <xsl:call-template name="headPicture"/>
        <h6>
            <xsl:call-template name="headText"/>
        </h6>
    </xsl:template>


    <!-- other headers -->

    <xsl:template match="head">
        <h4>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </h4>
    </xsl:template>

    <xsl:template match="byline">
        <p>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:attribute name="class">byline
                <xsl:if test="contains(@rend, 'align(center)')"><xsl:text> </xsl:text>aligncenter</xsl:if>
            </xsl:attribute>
            <xsl:apply-templates/>
        </p>
    </xsl:template>


    <!-- trailers -->

    <xsl:template match="trailer">
        <p>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:attribute name="class">trailer
                <xsl:if test="contains(@rend, 'align(center)')"><xsl:text> </xsl:text>aligncenter</xsl:if>
            </xsl:attribute>
            <xsl:apply-templates/>
        </p>
    </xsl:template>


    <!--====================================================================-->
    <!-- Arguments (short summary of contents at start of chapter) -->

    <xsl:template match="argument">
        <div class="argument">
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <!--====================================================================-->
    <!-- Epigraphs -->

    <xsl:template match="epigraph">
        <div class="epigraph">
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="bibl">
        <span class="bibl">
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <!--====================================================================-->
    <!-- Blockquotes -->

    <xsl:template match="q[@rend='block']">
        <xsl:call-template name="closepar"/>
        <div class="blockquote">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>

    <xsl:template match="q">
        <xsl:call-template name="closepar"/>
        <div class="q">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>

    <!-- Other uses of q should be ignored, as it is typically used to nest elements that otherwise could not appear at a certain location, such as verse in footnotes. -->


    <!--====================================================================-->
    <!-- Letters, with openers, closers, etc. -->

    <!-- non-TEI shortcut for <q><text><body><div1 type="Letter"> -->
    <xsl:template match="letter">
        <xsl:call-template name="closepar"/>
        <div class="blockquote letter">
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>

    <xsl:template match="opener">
        <div class="opener">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="salute">
        <div class="salute">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="closer">
        <div class="closer">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="signed">
        <div class="signed">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="dateline">
        <div class="dateline">
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <!--====================================================================-->
    <!-- Notes -->

    <!-- Marginal notes should go to the margin -->

    <xsl:template match="/TEI.2/text//note[@place='margin']">
        <span class="leftnote">
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- Move footnotes to the end of the div1 element they appear in (but not in
    quoted texts). Optionally, we place the text of the footnote in-line as well,
    for use by the print stylesheet. In browsers it will be hidden. -->

    <xsl:template match="/TEI.2/text//note[@place='foot' or not(@place)]">
        <a class="noteref">
            <xsl:attribute name="id"><xsl:call-template name="generate-id"/>src</xsl:attribute>
            <xsl:call-template name="generate-href-attribute"/>
            <xsl:number level="any" count="note[@place='foot' or not(@place)]" from="div1[not(ancestor::q)]"/>
        </a>
        <xsl:if test="$optionPrinceMarkup = 'Yes'">
            <span class="displayfootnote">
                <xsl:call-template name="setLangAttribute"/>
                <xsl:apply-templates/>
            </span>
        </xsl:if>
    </xsl:template>

    <!-- Handle notes with paragraphs different from simple notes -->

    <xsl:template match="note[p]" mode="footnotes">
        <p class="footnote">
            <xsl:call-template name="setLangAttribute"/>
            <span class="label">
                <a class="noteref">
                    <xsl:attribute name="href">#<xsl:call-template name="generate-id"/>src</xsl:attribute>
                    <xsl:call-template name="generate-id-attribute"/>
                    <xsl:number level="any" count="note[@place='foot' or not(@place)]" from="div1[not(ancestor::q)]"/>
                </a>
            </span>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="*[1]" mode="footfirst"/>
        </p>
        <xsl:apply-templates select="*[position() > 1]" mode="footnotes"/>
    </xsl:template>

    <xsl:template match="note" mode="footnotes">
        <p class="footnote">
            <xsl:call-template name="setLangAttribute"/>
            <span class="label">
                <a class="noteref">
                    <xsl:attribute name="href">#<xsl:call-template name="generate-id"/>src</xsl:attribute>
                    <xsl:call-template name="generate-id-attribute"/>
                    <xsl:number level="any" count="note[@place='foot' or not(@place)]" from="div1[not(ancestor::q)]"/>
                </a>
            </span>
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="*" mode="footfirst">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="p" mode="footnotes">
        <p class="footnote">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="*" mode="footnotes">
        <xsl:apply-templates/>
    </xsl:template>


    <!-- Notes in a critical apparatus (coded with attribute place="apparatus") -->

    <xsl:template match="/TEI.2/text//note[@place='apparatus']">
        <a style="text-decoration:none">
            <xsl:attribute name="id"><xsl:call-template name="generate-id"/>src</xsl:attribute>
            <xsl:call-template name="generate-href-attribute"/>
            <xsl:attribute name="title"><xsl:value-of select="."/></xsl:attribute>&deg;</a>
    </xsl:template>

    <xsl:template match="divGen[@type='apparatus']">
        <div class="div1">
            <xsl:attribute name="id"><xsl:call-template name="generate-id"/></xsl:attribute>
            <xsl:call-template name="setLangAttribute"/>
            <h2><xsl:value-of select="$strApparatus"/></h2>

            <xsl:apply-templates select="preceding::note[@place='apparatus']" mode="apparatus"/>
        </div>
    </xsl:template>

    <xsl:template match="note[@place='apparatus']" mode="apparatus">
        <p class="footnote">
            <xsl:call-template name="setLangAttribute"/>
            <span class="label">
                <a style="text-decoration:none">
                    <xsl:attribute name="href">#<xsl:call-template name="generate-id"/>src</xsl:attribute>
                    <xsl:call-template name="generate-id-attribute"/>
                    &deg;</a>
            </span>
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>


    <!--====================================================================-->
    <!-- Paragraphs -->

    <xsl:template match="p">
        <xsl:if test="not(contains(@rend, 'display(none)'))">
            <p>
                <xsl:call-template name="generate-id-attribute"/>
                <xsl:call-template name="setLangAttribute"/>
                <xsl:call-template name="setCssClassAttribute"/>  <!-- TODO: handle alignment differently below -->

                <!-- in a few cases, we have paragraphs in quoted material in footnotes, which need to be set in a smaller font: apply the proper class for that. -->
                <xsl:if test="ancestor::note[place='foot' or not(@place)]">
                    <xsl:attribute name="class">footnote</xsl:attribute>
                </xsl:if>

                <xsl:if test="contains(@rend, 'indent(') or contains(@rend, 'align(')">
                    <xsl:attribute name="style">
                        <xsl:if test="contains(@rend, 'indent(')">text-indent:<xsl:value-of select="substring-before(substring-after(@rend, 'indent('), ')')"/>em;</xsl:if>
                        <xsl:if test="contains(@rend, 'align(')">text-align:<xsl:value-of select="substring-before(substring-after(@rend, 'align('), ')')"/>;</xsl:if>
                    </xsl:attribute>
                </xsl:if>

                <xsl:if test="@n">
                    <span class="parnum"><xsl:value-of select="@n"/>.<xsl:text> </xsl:text></span>
                </xsl:if>
                <xsl:apply-templates/>
            </p>
        </xsl:if>
    </xsl:template>


    <!--====================================================================-->
    <!-- Decorative Initials

    Decorative initials are encoded with the rend attribute on the paragraph 
    level.

    To properly show an initial in HTML that may stick over the text, we need 
    to use a number of tricks in CSS.

    1. We set the initial as background picture on the paragraph.
    2. We create a small div which we let float to the left, to give the initial 
       the space it needs.
    3. We set the padding-top to a value such that the initial actually appears 
       to stick over the paragraph.
    4. We set the initial as background picture to the float, such that if the 
       paragraph is to small to contain the entire initial, the float will. We 
       need to take care to adjust the background position to match the 
       padding-top, such that the two background images will align exactly.
    5. We need to take the first letter from the Paragraph, and render it in the 
       float in white, such that it re-appears when no CSS is available.

    -->

    <xsl:template match="p[contains(@rend, 'initial-image')]">
        <p>
            <xsl:attribute name="style">
                background: url(<xsl:value-of select="substring-before(substring-after(@rend, 'initial-image('), ')')"/>) no-repeat top left;
                <xsl:if test="contains(@rend, 'initial-offset(')">
                    padding-top: <xsl:value-of select="substring-before(substring-after(@rend, 'initial-offset('), ')')"/>;
                </xsl:if>
            </xsl:attribute>
            <span>
                <xsl:attribute name="style">
                    float: left;
                    width: <xsl:value-of select="substring-before(substring-after(@rend, 'initial-width('), ')')"/>;
                    height: <xsl:value-of select="substring-before(substring-after(@rend, 'initial-height('), ')')"/>;
                    background: url(<xsl:value-of select="substring-before(substring-after(@rend, 'initial-image('), ')')"/>) no-repeat;
                    <xsl:if test="contains(@rend, 'initial-offset(')">
                        background-position: 0px -<xsl:value-of select="substring-before(substring-after(@rend, 'initial-offset('), ')')"/>;
                    </xsl:if>
                    text-align: right;
                    color: white;
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="substring(.,1,1) = '&ldquo;'">
                        <xsl:value-of select="substring(.,1,2)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring(.,1,1)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </span>
            <xsl:apply-templates mode="eat-initial"/>
        </p>
    </xsl:template>


    <!-- We need to adjust the text() matching template to remove the first character from the paragraph -->
    <xsl:template match="text()" mode="eat-initial">
        <xsl:choose>
            <xsl:when test="position()=1 and substring(.,1,1) = '&ldquo;'">
                <xsl:value-of select="substring(.,3)"/>
            </xsl:when>
            <xsl:when test="position()=1">
                <xsl:value-of select="substring(.,2)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="*" mode="eat-initial">
        <xsl:if test="position()>1">
            <xsl:apply-templates select="."/>
        </xsl:if>
    </xsl:template>


    <!--====================================================================-->
    <!-- Poetry -->

    <!-- top-level gets class=lgouter, nested get class=lg. This we use to center the entire poem on the screen, and still keep the left side of all stanzas aligned. -->
    <xsl:template match="lg">
        <xsl:call-template name="closepar"/>
        <div>
            <xsl:attribute name="class">
                <xsl:if test="not(parent::lg)">lgouter<xsl:text> </xsl:text></xsl:if>
                <xsl:if test="parent::lg">lg<xsl:text> </xsl:text></xsl:if>
                <xsl:if test="contains(@rend, 'font(fraktur)')">fraktur<xsl:text> </xsl:text></xsl:if>
            </xsl:attribute>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>

    <xsl:template match="lg/head">
        <h4>
            <xsl:attribute name="class">
                <xsl:if test="contains(@rend, 'font(fraktur)')">fraktur<xsl:text> </xsl:text></xsl:if>
                <xsl:if test="contains(@rend, 'align(center)')">aligncenter</xsl:if>
            </xsl:attribute>
            <xsl:apply-templates/>
        </h4>
    </xsl:template>

    <xsl:template match="l">
        <p class="line">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:if test="contains(@rend, 'font(italic)') or contains(../@rend, 'font(italic)') or contains(@rend, 'indent(')">
                <xsl:attribute name="style">
                    <xsl:if test="contains(@rend, 'font(italic)') or contains(../@rend, 'font(italic)')">font-style: italic; </xsl:if>
                    <xsl:if test="contains(@rend, 'indent(')">text-indent: <xsl:value-of select="substring-before(substring-after(@rend, 'indent('), ')')"/>em; </xsl:if>
                </xsl:attribute>
            </xsl:if>

            <xsl:if test="@n">
                <span class="linenum"><xsl:value-of select="@n"/></span>
            </xsl:if>

            <xsl:if test="contains(@rend, 'hemistich(')">
                <span class="hemistich"><xsl:value-of select="substring-before(substring-after(@rend, 'hemistich('), ')')"/></span>
            </xsl:if>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- linebreaks specific to an edition are not represented in the output -->
    <xsl:template match="lb[@ed]">
        <a>
            <xsl:call-template name="generate-id-attribute"/>
        </a>
    </xsl:template>

    <!-- linebreaks not linked to a specific edition are to be output -->
    <xsl:template match="lb">
        <br>
            <xsl:call-template name="generate-id-attribute"/>
        </br>
    </xsl:template>


    <!--====================================================================-->
    <!-- Drama -->

    <xsl:template match="sp">
        <div>
            <xsl:attribute name="class">
                <xsl:if test="contains(@rend, 'font(fraktur)')">fraktur<xsl:text> </xsl:text></xsl:if>sp</xsl:attribute>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- Speaker -->

    <xsl:template match="speaker">
        <p class="speaker">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- Stage directions -->

    <xsl:template match="stage">
        <p class="stage">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="stage[@type='exit']">
        <p class="stage alignright">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="stage[@rend='inline' or contains(@rend, 'position(inline)')]">
        <span class="stage">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- Cast lists -->

    <xsl:template match="castList">
        <ul class="castlist">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:apply-templates/>
        </ul>
    </xsl:template>

    <xsl:template match="castList/head">
        <li class="castlist">
            <xsl:call-template name="generate-id-attribute"/>
            <h4><xsl:apply-templates/></h4>
        </li>
    </xsl:template>

    <xsl:template match="castGroup">
        <li class="castlist">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:apply-templates select="head"/>
            <ul class="castGroup">
                <xsl:apply-templates select="castItem"/>
            </ul>
        </li>
    </xsl:template>

    <xsl:template match="castGroup/head">
        <b>
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:apply-templates/>
        </b>
    </xsl:template>

    <xsl:template match="castItem">
        <li class="castitem">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:apply-templates/>
        </li>
    </xsl:template>


    <!--====================================================================-->
    <!-- CSS Class tagging -->

    <xsl:template name="setCssClassAttribute">
        <xsl:if test="contains(@rend, 'class(')">
            <xsl:attribute name="class">
                <xsl:value-of select="substring-before(substring-after(@rend, 'class('), ')')"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>

    <!--====================================================================-->
    <!-- Project Gutenberg Header, Footer, and License -->

    <xsl:template name="authors">
        <xsl:for-each select="//titleStmt/author">
            <xsl:choose>
                <xsl:when test="position() != last() and last() > 2">
                    <xsl:value-of select="."/><xsl:text>, </xsl:text>
                </xsl:when>
                <xsl:when test="position() = last() and last() > 1">
                    <xsl:text> </xsl:text><xsl:value-of select="$strAnd"/><xsl:text> </xsl:text><xsl:value-of select="."/>
                </xsl:when>
                <xsl:when test="last() = 1">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="PGHeader">
        <xsl:variable name="params">
            <params>
                <param name="title"><xsl:value-of select="//titleStmt/title"/></param>
                <param name="authors"><xsl:call-template name="authors"/></param>
                <param name="releasedate"><xsl:value-of select="//publicationStmt/date"/></param>
                <param name="pgnum"><xsl:value-of select="//publicationStmt/idno[@type='pgnum' or @type='PGnum']"/></param>
                <param name="language">
                    <xsl:call-template name="GetMessage">
                        <xsl:with-param name="name" select="/TEI.2/@lang"/>
                    </xsl:call-template>
                </param>
            </params>
        </xsl:variable>
        <xsl:call-template name="FormatMessage">
            <xsl:with-param name="name" select="'msgPGHeader'"/>
            <xsl:with-param name="params" select="$params"/>
        </xsl:call-template>
        <hr/>
        <p/>
    </xsl:template>

    <xsl:template name="PGFooter">
        <xsl:variable name="params">
            <params>
                <param name="title"><xsl:value-of select="//titleStmt/title"/></param>
                <param name="authors"><xsl:call-template name="authors"/></param>
                <param name="transcriber"><xsl:value-of select="//titleStmt/respStmt/name"/></param>
                <param name="pgnum"><xsl:value-of select="//publicationStmt/idno[@type='pgnum' or @type='PGnum']"/></param>
                <param name="pgpath"><xsl:value-of select="substring(//publicationStmt/idno, 1, 1)"/>/<xsl:value-of select="substring(//publicationStmt/idno, 2, 1)"/>/<xsl:value-of select="substring(//publicationStmt/idno, 3, 1)"/>/<xsl:value-of select="substring(//publicationStmt/idno, 4, 1)"/>/<xsl:value-of select="//publicationStmt/idno"/>/</param>
            </params>
        </xsl:variable>
        <p/>
        <hr/>
        <xsl:call-template name="FormatMessage">
            <xsl:with-param name="name" select="'msgPGFooter'"/>
            <xsl:with-param name="params" select="$params"/>
        </xsl:call-template>
        <xsl:call-template name="PGLicense"/>
    </xsl:template>

    <xsl:template name="PGLicense">
        <xsl:call-template name="FormatMessage">
            <xsl:with-param name="name" select="'msgPGLicense'"/>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
