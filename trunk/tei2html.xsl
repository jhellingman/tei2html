<?xml version="1.0" encoding="iso-8859-1" ?>
<!DOCTYPE xsl:stylesheet [

    <!ENTITY degrees    "&#176;">
    <!ENTITY nbsp       "&#160;">

]>
<!--

    Stylesheet to convert TEI to HTML

    Developed by Jeroen Hellingman <jeroen@bohol.ph>, to be used together with a CSS stylesheet. Please contact me if you have problems with this stylesheet, or have improvements or bug fixes to contribute.

    This stylesheet can be used with the saxon XSL processor, or with the build-in XSL processor in IE 6.0 or higher. Note that the XLS processor in Firefox will not always do the right thing.

    You can embed this style sheet in the source document with the <?xml-stylesheet type="text/xsl" href="stylesheet.xsl"?> processing instruction. This works with IE 6.0 or the latest Mozilla browsers.

    This file is made available under the GNU General Public License, version 2.0.

-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msg="http://www.gutenberg.ph/2006/schemas/messages"
    xmlns:img="http://www.gutenberg.ph/2006/schemas/imageinfo"
    version="1.0"
    >

    <xsl:output
        doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
        doctype-system="http://www.w3.org/TR/html4/loose.dtd"
        method="html"
        encoding="ISO-8859-1"/>

    <!--====================================================================-->

    <!-- imageInfoFile is an XML file that contains information on the dimensions of images. -->
    <xsl:param name="imageInfoFile"/>

    <!--====================================================================-->

    <xsl:variable name="optionExternalCSS" select="'No'" />
    <xsl:variable name="optionPGHeaders"   select="'No'" />

    <!--====================================================================-->

    <xsl:variable name="title" select="/TEI.2/teiHeader/fileDesc/titleStmt/title" />
    <xsl:variable name="author" select="/TEI.2/teiHeader/fileDesc/titleStmt/author" />
    <xsl:variable name="pubdate" select="/TEI.2/teiHeader/fileDesc/publicationStmt/date" />

    <xsl:variable name="language" select="/TEI.2/@lang" />
    <xsl:variable name="baselanguage" select="substring-before($language,'-')" />
    <xsl:variable name="defaultlanguage" select="'en'" />

    <xsl:variable name="messages" select="document('messages.xml')/msg:repository"/>

    <xsl:variable name="strUnitsUsed" select="'Original'"/>

    <!--====================================================================-->

    <xsl:template name="GetMessage">
        <xsl:param name="name" select="'msgError'"/>
        <xsl:variable name="msg" select="$messages/msg:messages/msg:message[@name=$name]"/>
        <xsl:choose>
            <xsl:when test="$msg[lang($language)][1]">
                <xsl:apply-templates select="$msg[lang($language)][1]"/>
            </xsl:when>
            <xsl:when test="$msg[lang($baselanguage)][1]">
                <xsl:apply-templates select="$msg[lang($baselanguage)][1]"/>
            </xsl:when>
            <xsl:when test="$msg[lang($defaultlanguage)][1]">
                <xsl:message terminate="no">
                    Warning: message '<xsl:value-of select="$name"/>' not available in locale <xsl:value-of select="$language"/>.
                </xsl:message>
                <xsl:apply-templates select="$msg[lang($defaultlanguage)][1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no">
                    Warning: unknown message '<xsl:value-of select="$name"/>'.
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="FormatMessage">
        <xsl:param name="name" select="'msgError'"/>
        <xsl:param name="params"/>
        <xsl:variable name="msg" select="$messages/msg:messages/msg:message[@name=$name]"/>
        <xsl:choose>
            <xsl:when test="$msg[lang($language)][1]">
                <xsl:apply-templates select="$msg[lang($language)][1]" mode="formatMessage">
                    <xsl:with-param name="params" select="$params"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$msg[lang($baselanguage)][1]">
                <xsl:apply-templates select="$msg[lang($baselanguage)][1]" mode="formatMessage">
                    <xsl:with-param name="params" select="$params"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="$msg[lang($defaultlanguage)][1]">
                <xsl:message terminate="no">
                    Warning: message '<xsl:value-of select="$name"/>' not available in locale <xsl:value-of select="$language"/>.
                </xsl:message>
                <xsl:apply-templates select="$msg[lang($defaultlanguage)][1]" mode="formatMessage"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no">
                    Warning: unknown message '<xsl:value-of select="$name"/>'.
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="msg:message" mode="formatMessage">
        <xsl:param name="params"/>
        <xsl:apply-templates mode="formatMessage">
            <xsl:with-param name="params" select="$params"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="*" mode="formatMessage">
        <xsl:param name="params"/>
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:apply-templates mode="formatMessage">
                    <xsl:with-param name="params" select="$params"/>
                </xsl:apply-templates>
            </xsl:copy>
    </xsl:template>

    <xsl:template match="msg:param" mode="formatMessage">
        <xsl:param name="params"/>
        <xsl:choose>
            <xsl:when test="$params/params/param[@name=current()/@name]">
                <xsl:value-of select="$params/params/param[@name=current()/@name]"/>
            </xsl:when>
            <xsl:otherwise>
                [### <xsl:value-of select="@name"/> ###]
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="space" mode="formatMessage">
        <xsl:text> </xsl:text>
    </xsl:template>

    <!--====================================================================-->
    <!-- Pull strings into easier to use variables -->

    <xsl:variable name="strToc">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgToc'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strFigure">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgFigure'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strPlate">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgPlate'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strPart">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgPart'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strTableOfContents">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgTableOfContents'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strAppendix">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgAppendix'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strPage">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgPage'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strChapter">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgChapter'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strBook">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgBook'"/>
        </xsl:call-template>
    </xsl:variable> <xsl:variable name="strAnd">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgAnd'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strListOfIllustrations">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgListOfIllustrations'"/>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="strCorrections">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgCorrection.n'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strCorrection">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgCorrection'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strTranscription">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgTranscription'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strSource">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgSource'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strLocation">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgLocation'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strCorrectionsAppliedToText">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgCorrectionsAppliedToText'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strColophon">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgColophon'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strRevisionHistory">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgRevisionHistory'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strAvailability">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgAvailability'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strEncoding">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgEncoding'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strOrnament">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgOrnament'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strNotInSource">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgNotInSource'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="strDeleted">
        <xsl:call-template name="GetMessage">
            <xsl:with-param name="name" select="'msgDeleted'"/>
        </xsl:call-template>
    </xsl:variable>


    <!--====================================================================-->

    <xsl:template match="/">
        <xsl:comment>
            <xsl:text> This HTML file has been automatically generated from an XML source, using XSLT. If you find any mistakes, please edit the XML source. </xsl:text>
        </xsl:comment>
        <xsl:text> <!-- insert extra new-line for PG -->
        </xsl:text>
        <html lang="{$language}">
            <head>
                <title>
                    <xsl:value-of select="$title"/>
                </title>

                <link rel="schema.DC"     href="http://dublincore.org/documents/1998/09/dces/"/> <!-- WAS: http://purl.org/DC/elements/1.0/ -->

                <meta name="author"       content="{$author}"/>
                <meta name="DC.Creator"   content="{$author}"/>
                <meta name="DC.Title"     content="{$title}"/>
                <meta name="DC.Date"      content="{$pubdate}"/>
                <meta name="DC.Language"  content="{$language}"/>

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
                    <!-- Pull in CSS sheets. This requires them to be wrapped in a tag at toplevel, so they become valid XML -->
                    <style type="text/css">
                        <xsl:variable name="stylesheet" select="document('style/gutenberg.css.xml')"/>
                        <xsl:copy-of select="$stylesheet/*/node()"/>
                        <xsl:variable name="stylesheet2" select="document($stylesheetname)"/>
                        <xsl:copy-of select="$stylesheet2/*/node()"/>
                    </style>
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

    <xsl:template match="front">
        <div class="front">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="body">
        <div class="body">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="back">
        <div class="back">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!--====================================================================-->
    <!-- TEI Header -->

    <!-- Suppress the header in the output -->

    <xsl:template match="teiHeader"/>

    <!--====================================================================-->
    <!-- Title Page -->

    <xsl:template match="titlePage">
        <div class="titlePage">
            <xsl:apply-templates mode="titlePage"/>
        </div>
    </xsl:template>

    <xsl:template match="docTitle" mode="titlePage">
        <xsl:apply-templates mode="titlePage"/>
    </xsl:template>

    <xsl:template match="titlePart" mode="titlePage">
        <h1 class="docTitle">
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
    <!-- Corrections; abbreviations; numbers; transcriptions -->

    <xsl:template match="corr">
        <a id="{generate-id(.)}"></a>
        <xsl:choose>
            <xsl:when test="@resp='m'">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <span class="corr">
                    <xsl:attribute name="title">
                        <xsl:value-of select="$strSource"/><xsl:text>: </xsl:text><xsl:value-of select="@sic"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="abbr">
        <a id="{generate-id(.)}"></a>
        <span class="abbr">
            <xsl:attribute name="title">
                <xsl:value-of select="@expan"/>
            </xsl:attribute>
            <abbr>
                <xsl:attribute name="title">
                    <xsl:value-of select="@expan"/>
                </xsl:attribute>
                <xsl:apply-templates/>
            </abbr>
        </span>
    </xsl:template>


    <xsl:template match="num">
        <a id="{generate-id(.)}"></a>
        <span class="abbr">
            <xsl:attribute name="title">
                <xsl:value-of select="@value"/>
            </xsl:attribute>
            <abbr>
                <xsl:attribute name="title">
                    <xsl:value-of select="@value"/>
                </xsl:attribute>
                <xsl:apply-templates/>
            </abbr>
        </span>
    </xsl:template>


    <xsl:template match="trans">
        <a id="{generate-id(.)}"></a>
        <span class="abbr">
            <xsl:attribute name="title">
                <xsl:value-of select="$strTranscription"/><xsl:text>: </xsl:text><xsl:value-of select="@trans"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <xsl:template match="gi|tag|att">
        <code>
            <xsl:apply-templates/>
        </code>
    </xsl:template>


    <!--====================================================================-->
    <!-- Measurements with metric equivalent  -->

    <xsl:template match="measure">
        <a id="{generate-id(.)}"></a>
        <span class="measure">
            <xsl:attribute name="title"><xsl:value-of select="./@reg"/></xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <!--====================================================================-->
    <!-- Cross References -->

    <!-- Only use generated ID's to avoid clashes of original with generated ID's. Note that the target id generated here should also be generated on the element being referenced. We cannot use the id() function here, since we do not use a DTD. -->

    <!-- Special case: reference to footnote, used when the same footnote reference mark is used multiple times -->

    <xsl:template match="ref[@target and @type='noteref']">
        <xsl:variable name="target" select="./@target"/>
        <xsl:apply-templates select="//*[@id=$target]" mode="noterefnumber"/>
    </xsl:template>

    <xsl:template match="note" mode="noterefnumber">
        <a href="#{generate-id()}" class="noteref">
            <xsl:number level="any" count="note[@place='foot' or not(@place)]" from="div1[not(ancestor::q)]"/>
        </a>
    </xsl:template>

    <!-- Normal case -->

    <xsl:template match="ref[@target and not(@type='noteref')]">
        <xsl:variable name="target" select="./@target"/>
        <a id="{generate-id(.)}" href="#{generate-id(//*[@id=$target])}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <!--====================================================================-->
    <!-- External References -->

    <xsl:template match="xref[@url]">
        <a>
            <xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute>
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <!--====================================================================-->
    <!-- Page Breaks -->

    <xsl:template match="pb">
        <a id="{generate-id()}"/>
        <xsl:if test="@n">
            <span class="pagenum">[<a href="#{generate-id()}"><xsl:value-of select="@n"/></a>]</span>
        </xsl:if>
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
        <a id="{generate-id()}"/>
    </xsl:template>


    <!--====================================================================-->
    <!-- Table of Contents -->
    <!-- Take care only to generate ToC entries for divisions of the main text, not for those in quoted texts -->

    <xsl:template match="divGen[@type='toc']">
        <div class="div1" id="{generate-id()}">
            <h2><xsl:value-of select="$strTableOfContents"/></h2>
            <ul>
                <xsl:apply-templates mode="gentoc" select="/TEI.2/text/front/div1"/>
                <xsl:choose>
                    <xsl:when test="/TEI.2/text/body/div0">
                        <xsl:apply-templates mode="gentoc" select="/TEI.2/text/body/div0"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="gentoc" select="/TEI.2/text/body/div1"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates mode="gentoc" select="/TEI.2/text/back/div1"/>
            </ul>
        </div>
    </xsl:template>

    <xsl:template match="div0" mode="gentoc">
        <xsl:if test="head">
            <li>
                <a href="#{generate-id()}">
                <xsl:choose>
                    <xsl:when test="@type='part'">
                        <xsl:value-of select="$strPart"/><xsl:text> </xsl:text><xsl:value-of select="./@n"/>:<xsl:text> </xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:apply-templates select="head[not(@type='label')]" mode="tochead"/></a>
                <xsl:if test="div1">
                    <ul>
                        <xsl:apply-templates select="div1" mode="gentoc"/>
                    </ul>
                </xsl:if>
            </li>
        </xsl:if>
    </xsl:template>

    <xsl:template match="div1" mode="gentoc">
        <xsl:if test="head">
            <li>
                <a href="#{generate-id()}">
                <xsl:choose>
                    <xsl:when test="@type='chapter'">
                        <xsl:value-of select="$strChapter"/><xsl:text> </xsl:text><xsl:value-of select="./@n"/>:<xsl:text> </xsl:text>
                    </xsl:when>
                    <xsl:when test="@type='appendix'">
                        Appendix <xsl:value-of select="./@n"/>:<xsl:text> </xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:apply-templates select="head[not(@type='label')]" mode="tochead"/></a>
                <xsl:if test="div2">
                    <ul>
                        <xsl:apply-templates select="div2" mode="gentoc"/>
                    </ul>
                </xsl:if>
            </li>
        </xsl:if>
    </xsl:template>

    <xsl:template match="div2" mode="gentoc">
        <xsl:if test="head">
            <li>
                <a href="#{generate-id()}">
                <xsl:apply-templates select="head[not(@type='label')]" mode="tochead"/></a>
                <xsl:if test="div3">
                    <ul>
                        <xsl:apply-templates select="div3" mode="gentoc"/>
                    </ul>
                </xsl:if>
            </li>
        </xsl:if>
    </xsl:template>

    <xsl:template match="div3" mode="gentoc">
        <xsl:if test="head">
            <li>
                <a href="#{generate-id()}">
                <xsl:apply-templates select="head[not(@type='label')]" mode="tochead"/></a>
            </li>
        </xsl:if>
    </xsl:template>

    <!-- Special short table of contents for indexes -->

    <xsl:template match="divGen[@type='IndexToc']">
        <xsl:call-template name="genindextoc"/>
    </xsl:template>

    <xsl:template name="genindextoc">
        <div class="transcribernote">
            <div style="text-align: center">
                <xsl:apply-templates select="../div2/head" mode="genindextoc"/>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="head" mode="genindextoc">
        <xsl:if test="position() != 1">
            <xsl:text> | </xsl:text>
        </xsl:if>
        <a href="#{generate-id()}">
            <xsl:value-of select="substring-before(., '.')"/>
        </a>
    </xsl:template>


    <!-- Suppress notes in table of contents (to avoid getting them twice) -->

    <xsl:template match="note" mode="tochead"/>


    <!-- Suppress 'label' headings in table of contents -->

    <xsl:template match="head[@type='label']" mode="tochead"/>


    <xsl:template match="head" mode="tochead">
        <xsl:if test="position() = 1 and ./@n">
            <xsl:value-of select="./@n"/><xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="position() &gt; 1">
            <xsl:text>: </xsl:text>
        </xsl:if>
        <xsl:apply-templates mode="tochead"/>
    </xsl:template>


    <!-- Text styles in chapter headings -->

    <xsl:template match="hi" mode="tochead">
        <i>
            <xsl:apply-templates mode="tochead"/>
        </i>
    </xsl:template>

    <xsl:template match="hi[@rend='italic']" mode="tochead">
        <i>
            <xsl:apply-templates mode="tochead"/>
        </i>
    </xsl:template>

    <xsl:template match="hi[@rend='sup']" mode="tochead">
        <sup>
            <xsl:apply-templates mode="tochead"/>
        </sup>
    </xsl:template>


    <!--====================================================================-->
    <!-- Generated Divisions -->

    <!-- Gallery of thumbnail images -->

    <xsl:template match="divGen[@type='gallery' or @type='Gallery']">
        <div class="div1">
            <h2><xsl:value-of select="$strListOfIllustrations"/></h2>
            <table>
                <xsl:call-template name="splitrows">
                    <xsl:with-param name="figures" select="//figure[@id]" />
                    <xsl:with-param name="columns" select="3" />
                </xsl:call-template>
            </table>
        </div>
    </xsl:template>


    <xsl:template name="splitrows">
        <xsl:param name="figures"/>
        <xsl:param name="columns"/>
        <xsl:for-each select="$figures[position() mod $columns = 1]">
            <tr>
                <xsl:apply-templates select=". | following::figure[position() &lt; $columns]" mode="gallery"/>
            </tr>
            <tr>
                <xsl:apply-templates select=". | following::figure[position() &lt; $columns]" mode="gallery-captions"/>
            </tr>
        </xsl:for-each>
    </xsl:template>


    <xsl:template match="figure" mode="gallery">
        <td align="center" valign="center">
            <a href="#{generate-id()}">
                <img border="0">
                    <xsl:attribute name="src">images/thumbs/<xsl:value-of select="@id"/>.jpg</xsl:attribute>
                    <xsl:attribute name="alt"><xsl:value-of select="head"/></xsl:attribute>
                </img>
            </a>
        </td>
    </xsl:template>


    <xsl:template match="figure" mode="gallery-captions">
        <td align="center" valign="top">
            <a href="#{generate-id()}"><xsl:apply-templates select="head" mode="gallery-captions"/></a>
        </td>
    </xsl:template>


    <xsl:template match="head" mode="gallery-captions">
        <xsl:value-of select="."/>
    </xsl:template>


    <!-- List of Corrections -->

    <xsl:template match="divGen[@type='corr']">
        <h2><xsl:value-of select="$strCorrections"/></h2>
        <xsl:call-template name="correctionTable"/>
    </xsl:template>

    <xsl:template name="correctionTable">
        <p><xsl:value-of select="$strCorrectionsAppliedToText"/></p>

        <table width="75%">
            <tr>
                <th><xsl:value-of select="$strLocation"/></th>
                <th><xsl:value-of select="$strSource"/></th>
                <th><xsl:value-of select="$strCorrection"/></th>
            </tr>
            <xsl:for-each select="//corr">
                <xsl:if test="not(@resp) or @resp != 'm'">
                    <tr>
                        <td width="20%">
                            <a href="#{generate-id(.)}">
                                <xsl:value-of select="$strPage"/><xsl:text> </xsl:text>
                                <xsl:value-of select="preceding::pb[1]/@n"/>
                            </a>
                        </td>
                        <td width="40%">
                            <xsl:choose>
                                <xsl:when test="@sic != ''">
                                    <xsl:value-of select="@sic"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    [<i><xsl:value-of select="$strNotInSource"/></i>]
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td width="40%">
                            <xsl:choose>
                                <xsl:when test=". != ''">
                                    <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:otherwise>
                                    [<i><xsl:value-of select="$strDeleted"/></i>]
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </xsl:if>
            </xsl:for-each>
        </table>
    </xsl:template>


    <!-- Colophon -->

    <xsl:template match="divGen[@type='Colophon']">
        <div class="transcribernote">
            <h2><xsl:value-of select="$strColophon"/></h2>

            <h3><xsl:value-of select="$strAvailability"/></h3>
            <xsl:apply-templates select="/TEI.2/teiHeader/fileDesc/publicationStmt/availability"/>

            <h3><xsl:value-of select="$strEncoding"/></h3>
            <xsl:apply-templates select="/TEI.2/teiHeader/encodingDesc"/>

            <h3><xsl:value-of select="$strRevisionHistory"/></h3>
            <xsl:apply-templates select="/TEI.2/teiHeader/revisionDesc"/>

            <h3><xsl:value-of select="$strCorrections"/></h3>
            <xsl:call-template name="correctionTable"/>
        </div>
    </xsl:template>


    <!--====================================================================-->
    <!-- Main parts of text -->

    <xsl:template match="text">
        <xsl:apply-templates/>
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

    <xsl:template name="headPicture">
        <xsl:if test="contains(@rend, 'image(')">
            <div class="figure">
                <xsl:call-template name="insertimage2">
                    <xsl:with-param name="alt"><xsl:value-of select="$strOrnament"/></xsl:with-param>
                </xsl:call-template>
            </div>
        </xsl:if>
    </xsl:template>


    <!-- div0 -->

    <xsl:template match="div0">
        <div class="div0" id="{generate-id(.)}">
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
        <h2>
            <xsl:if test="@type='label'">
                <xsl:attribute name="class">label</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </h2>
    </xsl:template>

    <!-- div1 -->

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

        <div id="{generate-id(.)}">
            <xsl:attribute name="class">div1<xsl:if test="@type='Index'"> index</xsl:if>
            </xsl:attribute>

            <xsl:if test="//*[@id='toc']">
                <!-- If we have an element with id 'toc', include a link to it -->
                <span class="pagenum">
                    [<a href="#{generate-id(//*[@id='toc'])}"><xsl:value-of select="$strToc"/></a>]
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
        <h2 id="{generate-id(.)}">
            <xsl:if test="@type='label'">
                <xsl:attribute name="class">label</xsl:attribute>
            </xsl:if>
            <xsl:if test="contains(@rend, 'align(')">
                <xsl:attribute name="align">
                    <xsl:value-of select="substring-before(substring-after(@rend, 'align('), ')')"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </h2>
    </xsl:template>

    <!-- div2 -->

    <xsl:template match="div2">
        <div class="div2" id="{generate-id(.)}">
            <xsl:call-template name="GenerateLabel">
                <xsl:with-param name="headingLevel" select="'h2'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="div2/head">
        <xsl:call-template name="headPicture"/>
        <h3 id="{generate-id(.)}">
            <xsl:if test="@type='label'">
                <xsl:attribute name="class">label</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </h3>
    </xsl:template>

    <!-- div3 -->

    <xsl:template match="div3">
        <div class="div3" id="{generate-id(.)}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="div3/head">
        <xsl:call-template name="headPicture"/>
        <h4><xsl:apply-templates/></h4>
    </xsl:template>

    <!-- div4 -->

    <xsl:template match="div4">
        <div class="div4" id="{generate-id(.)}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="div4/head">
        <xsl:call-template name="headPicture"/>
        <h5><xsl:apply-templates/></h5>
    </xsl:template>

    <!-- div5 -->

    <xsl:template match="div5">
        <div class="div5" id="{generate-id(.)}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="div5/head">
        <xsl:call-template name="headPicture"/>
        <h6><xsl:apply-templates/></h6>
    </xsl:template>

    <!-- other headers -->

    <xsl:template match="head">
        <h4><xsl:apply-templates/></h4>
    </xsl:template>

    <xsl:template match="byline">
        <p class="byline">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

	<!-- trailers -->

    <xsl:template match="trailer">
		<p>
			<xsl:attribute name="class">trailer
				<xsl:if test="contains(@rend, 'align(center)')"><xsl:text> </xsl:text>aligncenter</xsl:if>
			</xsl:attribute>
			<xsl:apply-templates/>
		</p>
    </xsl:template>


    <!--====================================================================-->
    <!-- Tables: Translate the TEI model to HTML tables. -->


    <xsl:template name="closepar">
        <!-- insert </p> to close current paragraph as tables in paragraphs are illegal in HTML -->
        <xsl:if test="parent::p">
            <xsl:text disable-output-escaping="yes">&lt;/p&gt;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template name="reopenpar">
        <xsl:if test="parent::p">
            <xsl:text disable-output-escaping="yes">&lt;p&gt;</xsl:text>
        </xsl:if>
    </xsl:template>


    <xsl:template match="table">
        <xsl:call-template name="closepar"/>
        <div class="table">
            <xsl:apply-templates select="head" mode="tablecaption"/>

            <table id="{generate-id(.)}">

                <xsl:if test="contains(@rend, 'font-size(')">
                    <xsl:attribute name="style">font-size: <xsl:value-of select="substring-before(substring-after(@rend, 'font-size('), ')')"/>;</xsl:attribute>
                </xsl:if>

                <xsl:if test="contains(@rend, 'width(')">
                    <xsl:attribute name="width"><xsl:value-of select="substring-before(substring-after(@rend, 'width('), ')')"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="not(contains(@rend, 'width('))">
                    <xsl:attribute name="width">100%</xsl:attribute>
                </xsl:if>

                <xsl:if test="contains(@rend, 'summary(')">
                    <xsl:attribute name="summary"><xsl:value-of select="substring-before(substring-after(@rend, 'summary('), ')')"/></xsl:attribute>
                </xsl:if>

                <xsl:apply-templates select="head"/>
                <xsl:apply-templates select="row"/>
            </table>
        </div>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>


    <!-- HTML caption element is not correctly handled in some browsers, so lift them out and make them headers. -->

    <xsl:template match="head" mode="tablecaption">
        <h4 class="tablecaption">
            <xsl:apply-templates/>
        </h4>
    </xsl:template>

    <!-- headers already handled. -->
    <xsl:template match="table/head"/>


    <xsl:template match="row">
        <tr valign="top">
            <xsl:apply-templates/>
        </tr>
    </xsl:template>

    <xsl:template match="row[@role='label']/cell">
        <td valign="top">
            <xsl:call-template name="cell-span"/>
            <b><xsl:apply-templates/></b>
        </td>
    </xsl:template>

    <xsl:template match="cell[@role='label']">
        <td valign="top">
            <xsl:call-template name="cell-span"/>
            <b><xsl:apply-templates/></b>
        </td>
    </xsl:template>

    <xsl:template match="row[@role='unit']/cell">
        <td valign="top">
            <xsl:call-template name="cell-span"/>
            <i><xsl:apply-templates/></i>
        </td>
    </xsl:template>

    <xsl:template match="cell[@role='unit']">
        <td valign="top">
            <xsl:call-template name="cell-span"/>
            <i><xsl:apply-templates/></i>
        </td>
    </xsl:template>

    <xsl:template match="cell">
        <td valign="top">
            <xsl:call-template name="cell-span"/>
            <xsl:apply-templates/>
        </td>
    </xsl:template>


    <xsl:template name="cell-span">
        <xsl:if test="@cols and (@cols > 1)">
            <xsl:attribute name="colspan"><xsl:value-of select="@cols"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="@rows and (@rows > 1)">
            <xsl:attribute name="rowspan"><xsl:value-of select="@rows"/></xsl:attribute>
        </xsl:if>

        <xsl:if test="contains(@rend, 'width(')">
            <xsl:attribute name="width"><xsl:value-of select="substring-before(substring-after(@rend, 'width('), ')')"/></xsl:attribute>
        </xsl:if>

        <xsl:if test="contains(@rend, 'align(right)')">
            <xsl:attribute name="class">alignright</xsl:attribute>
        </xsl:if>
        <xsl:if test="contains(@rend, 'align(center)')">
            <xsl:attribute name="class">aligncenter</xsl:attribute>
        </xsl:if>

        <xsl:if test="contains(@rend, 'padding-top(') or contains(@rend, 'padding-bottom(') or @role='sum' or contains(@rend, 'font-weight(')">
            <xsl:attribute name="style">
                <xsl:if test="@role='sum'">padding-top: 2px; border-top: solid black 1px;</xsl:if>
                <xsl:if test="contains(@rend, 'padding-top(')">padding-top:<xsl:value-of select="substring-before(substring-after(@rend, 'padding-top('), ')')"/>;</xsl:if>
                <xsl:if test="contains(@rend, 'padding-bottom(')">padding-bottom:<xsl:value-of select="substring-before(substring-after(@rend, 'padding-bottom('), ')')"/>;</xsl:if>
                <xsl:if test="contains(@rend, 'font-weight(')">font-weight:<xsl:value-of select="substring-before(substring-after(@rend, 'font-weight('), ')')"/>;</xsl:if>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>


    <!--====================================================================-->
    <!-- Lists -->

    <xsl:template match="list">
        <xsl:call-template name="closepar"/>
        <xsl:choose>
            <xsl:when test="contains(@rend, 'columns(2)')">
                <xsl:call-template name="doubleuplist"/>
            </xsl:when>
            <xsl:otherwise>
                <ul id="{generate-id(.)}">
                    <xsl:call-template name="rendattrlist"/>
                    <xsl:apply-templates/>
                </ul>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>


    <xsl:template name="doubleuplist">
        <table id="{generate-id(.)}">
            <xsl:variable name="halfway" select="ceiling(count(item) div 2)"/>
            <tr valign="top">
                <td>
                    <ul>
                        <xsl:call-template name="rendattrlist"/>
                        <xsl:apply-templates select="item[position() &lt; $halfway + 1]"/>
                    </ul>
                </td>
                <td>
                    <ul>
                        <xsl:call-template name="rendattrlist"/>
                        <xsl:apply-templates select="item[position() &gt; $halfway]"/>
                    </ul>
                </td>
            </tr>
        </table>
    </xsl:template>


    <xsl:template match="item">
        <li id="{generate-id(.)}">
            <xsl:apply-templates/>
        </li>
    </xsl:template>


    <xsl:template name="rendattrlist">
        <xsl:if test="contains(@rend, 'list-style-type(')">
            <xsl:attribute name="style">
                <xsl:if test="contains(@rend, 'list-style-type(')">list-style-type:<xsl:value-of select="substring-before(substring-after(@rend, 'list-style-type('), ')')"/>;</xsl:if>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>


    <!--====================================================================-->
    <!-- Figures -->

    <!-- We derive the file name from the unique id, and assume that the format is .jpg, unless an alternative name is
         given in the rend attribute, using image() -->


    <xsl:template name="getimagefilename">
        <xsl:param name="format" select="'.jpg'"/>
        <xsl:choose>
            <xsl:when test="contains(@rend, 'image(')">
                <xsl:value-of select="substring-before(substring-after(@rend, 'image('), ')')"/>
            </xsl:when>
            <xsl:when test="@url">
                <xsl:value-of select="@url"/>
                <xsl:message terminate="no">
                    Warning: using non-standard attribute url on figure.
                </xsl:message>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>images/</xsl:text><xsl:value-of select="@id"/><xsl:value-of select="$format"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="insertimage">
        <xsl:param name="alt" select="''"/>
        <xsl:param name="format" select="'.jpg'"/>

        <!-- What is the text that should go on the img alt attribute in HTML? -->
        <xsl:variable name="alt2">
            <xsl:choose>
                <xsl:when test="figDesc">
                    <xsl:value-of select="figDesc"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$alt"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Should we link to an external image? -->
        <xsl:choose>
            <xsl:when test="contains(@rend, 'link(')">
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="substring-before(substring-after(@rend, 'link('), ')')"/>
                    </xsl:attribute>
                    <xsl:call-template name="insertimage2">
                        <xsl:with-param name="alt" select="$alt2"/>
                        <xsl:with-param name="format" select="$format"/>
                    </xsl:call-template>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="insertimage2">
                    <xsl:with-param name="alt" select="$alt2"/>
                    <xsl:with-param name="format" select="$format"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="insertimage2">
        <xsl:param name="alt" select="''"/>
        <xsl:param name="format" select="'.jpg'"/>

        <xsl:variable name="file">
            <xsl:call-template name="getimagefilename">
                <xsl:with-param name="format" select="$format"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="width">
            <xsl:value-of select="substring-before(document($imageInfoFile)/img:images/img:image[@path=$file]/@width, 'px')"/>
        </xsl:variable>
        <xsl:variable name="height">
            <xsl:value-of select="substring-before(document($imageInfoFile)/img:images/img:image[@path=$file]/@height, 'px')"/>
        </xsl:variable>

        <img border="0">
            <xsl:attribute name="src">
                <xsl:value-of select="$file"/>
            </xsl:attribute>
            <xsl:attribute name="alt">
                <xsl:value-of select="$alt"/>
            </xsl:attribute>
            <xsl:if test="$width != ''">
                <xsl:attribute name="width">
                    <xsl:value-of select="$width"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$height != ''">
                <xsl:attribute name="height">
                    <xsl:value-of select="$height"/>
                </xsl:attribute>
            </xsl:if>
        </img>
    </xsl:template>


    <xsl:template match="figure[@rend='inline' or contains(@rend, 'position(inline)')]">
        <xsl:call-template name="insertimage">
            <xsl:with-param name="format" select="'.png'"/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="figure">
        <xsl:call-template name="closepar"/>
        <div id="{generate-id()}">

            <xsl:variable name="file">
                <xsl:call-template name="getimagefilename"/>
            </xsl:variable>
            <xsl:variable name="width">
                <xsl:value-of select="document($imageInfoFile)/img:images/img:image[@path=$file]/@width"/>
            </xsl:variable>

            <xsl:choose>
                <xsl:when test="@rend='left' or contains(@rend, 'float(left)')">
                    <xsl:attribute name="class">figure floatLeft</xsl:attribute>
                    <xsl:if test="$width != ''">
                        <xsl:attribute name="style">width: <xsl:value-of select="$width"/></xsl:attribute>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="@rend='right' or contains(@rend, 'float(right)')">
                    <xsl:attribute name="class">figure floatRight</xsl:attribute>
                    <xsl:if test="$width != ''">
                        <xsl:attribute name="style">width: <xsl:value-of select="$width"/></xsl:attribute>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class">figure</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:call-template name="insertimage">
                <xsl:with-param name="alt" select="head"/>
            </xsl:call-template>

            <xsl:apply-templates/>
        </div>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>


    <xsl:template match="figure/head">
        <p class="figureHead"><xsl:apply-templates/></p>
    </xsl:template>


    <xsl:template match="figDesc"/>


    <!--====================================================================-->
    <!-- Decorative Initials

    Decorative initials are encoded with the rend attribute on the paragraph level.

    To properly show an initial in HTML that may stick over the text, we need to use a number of tricks in CSS.

    1. We set the initial as background picture on the paragraph.
    2. We create a small div which we let float to the left, to give the initial the space it needs.
    3. We set the padding-top to a value such that the initial actually appears to stick over the paragraph.
    4. We set the initial as background picture to the float, such that if the paragraph is to small to contain the entire initial, the float will. We need to take care to adjust the background position to match the padding-top, such that the two background images will align exactly.
    5. We need to take the first letter from the Paragraph, and render it in the float in white, such that it re-appears when no CSS is available.

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
                <xsl:value-of select="substring(.,1,1)"/>
            </span>
            <xsl:apply-templates mode="eat-initial"/>
        </p>
    </xsl:template>

    <!-- We need to adjust the text() matching template to remove the first character from the paragraph -->

    <xsl:template match="text()" mode="eat-initial">
        <xsl:choose>
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
    <!-- Arguments (short summary of contents at start of chapter) -->

    <xsl:template match="argument">
        <div class="argument">
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <!--====================================================================-->
    <!-- Epigraphs -->

    <xsl:template match="epigraph">
        <div class="epigraph">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="bibl">
        <div class="bibl">
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <!--====================================================================-->
    <!-- Blockquotes -->

    <xsl:template match="q[@rend='block' or @rend='display']">
        <xsl:call-template name="closepar"/>
        <div class="blockquote">
            <xsl:apply-templates/>
        </div>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>

    <xsl:template match="q">
        <xsl:call-template name="closepar"/>
        <xsl:apply-templates/>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>

    <!-- Other use of q should be ignored, as it is typically used to nest elements that otherwise could not appear at a certain location, such as verse in footnotes. -->

    <!--====================================================================-->
    <!-- Notes -->

    <!-- Marginal notes should go to the margin -->

    <xsl:template match="/TEI.2/text//note[@place='margin']">
        <span class="leftnote">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- Move footnotes to the end of the div1 element they appear in (but not in quoted texts) -->

    <xsl:template match="/TEI.2/text//note[@place='foot' or not(@place)]">
        <a id="{generate-id()}src" href="#{generate-id()}" class="noteref">
            <xsl:number level="any" count="note[@place='foot' or not(@place)]" from="div1[not(ancestor::q)]"/>
        </a>
    </xsl:template>

    <!-- Handle notes with paragraphs different from simple notes -->

    <xsl:template match="note[p]" mode="footnotes">
        <p class="footnote">
            <span class="label">
                <a id="{generate-id()}" href="#{generate-id()}src" class="noteref">
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
            <span class="label">
                <a id="{generate-id()}" href="#{generate-id()}src" class="noteref">
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
        <p id="{generate-id()}" class="footnote"><xsl:apply-templates/></p>
    </xsl:template>

    <xsl:template match="*" mode="footnotes">
        <xsl:apply-templates/>
    </xsl:template>


    <!-- Notes in a critical apparatus (coded with place=apparatus) -->

    <xsl:template match="/TEI.2/text//note[@place='apparatus']">
        <a id="{generate-id()}src" href="#{generate-id()}" style="text-decoration:none">
            <xsl:attribute name="title"><xsl:value-of select="."/></xsl:attribute>&degrees;
        </a>
    </xsl:template>

    <xsl:template match="divGen[@type='apparatus']">
        <div class="footnotes">
            <hr class="fnsep"/>
            <xsl:apply-templates select="preceding::note[@place='apparatus']" mode="apparatus"/>
        </div>
    </xsl:template>

    <xsl:template match="note[@place='apparatus']" mode="apparatus">
        <p class="footnote">
            <span class="label">
                <a id="{generate-id()}" href="#{generate-id()}src" style="text-decoration:none">&degrees;</a>
            </span>
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!--====================================================================-->
    <!-- Paragraphs -->

    <xsl:template match="p">
        <xsl:if test="not(contains(@rend, 'display(none)'))">
            <p id="{generate-id()}">
                <xsl:if test="contains(@rend, 'align(')">
                    <xsl:variable name="align" select="substring-before(substring-after(@rend, 'align('), ')')"/>
                    <xsl:attribute name="class">align<xsl:value-of select="$align"/></xsl:attribute>
                </xsl:if>
                <xsl:apply-templates/>
            </p>
        </xsl:if>
    </xsl:template>

    <!-- Special types of Paragraphs (introduced for Filippino Riddles) -->

    <xsl:template match="p[@rend='Question']">
        <xsl:if test="@n">
            <h3 id="{generate-id()}"><xsl:value-of select="@n"/></h3>
        </xsl:if>
        <p class="question"><xsl:apply-templates/></p>
    </xsl:template>

    <xsl:template match="p[@rend='Answer']">
        <p id="{generate-id()}" class="answer"><xsl:apply-templates/></p>
    </xsl:template>

    <xsl:template match="p[@rend='Explanation']">
        <p id="{generate-id()}" class="explanation"><xsl:apply-templates/></p>
    </xsl:template>

    <!--====================================================================-->
    <!-- Line groups -->

    <xsl:template name="insertNBSpaces">
        <xsl:param name="count" select="1"/>
        <xsl:text>&nbsp;&nbsp;&nbsp;</xsl:text>
        <xsl:if test="$count &gt; 1">
            <xsl:call-template name="insertNBSpaces">
                <xsl:with-param name="count"><xsl:value-of select="$count - 1"/></xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template match="lb">
        <br id="{generate-id()}"/>
    </xsl:template>

    <xsl:template match="lg|sp">
        <div class="poem">
            <div class="stanza">
                <xsl:apply-templates/>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="lg/head">
        <h4 class="lghead"><xsl:apply-templates/></h4>
    </xsl:template>

    <xsl:template match="speaker">
        <p>
            <b><xsl:apply-templates/></b>
        </p>
    </xsl:template>

    <xsl:template match="stage">
        <h4 class="lghead"><xsl:apply-templates/></h4>
    </xsl:template>

    <xsl:template match="l">
        <p class="line">
            <xsl:attribute name="style">
                <xsl:if test="contains(@rend, 'font(italic)') or contains(../@rend, 'font(italic)')">font-style: italic; </xsl:if>
                <xsl:if test="contains(@rend, 'indent(')">text-indent: <xsl:value-of select="substring-before(substring-after(@rend, 'indent('), ')')"/>em; </xsl:if>
            </xsl:attribute>

            <xsl:if test="@n">
                <span class="linenum"><xsl:value-of select="@n"/></span>
            </xsl:if>

            <span id="{generate-id()}">
                <xsl:apply-templates/>
            </span>
        </p>
    </xsl:template>


    <xsl:template match="ab[@type='versenum']">
        <span class="versenum">
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <!--====================================================================-->
    <!-- Text styles -->

    <!-- TODO: line is actually too high for the intended use. -->
    <xsl:template match="hi[@rend='overline']">
        <span style="text-decoration: overline;"><xsl:apply-templates/></span>
    </xsl:template>

    <!-- TODO: find way to make very wide tildes over words -->
    <xsl:template match="hi[@rend='overtilde']">
        <span style="text-decoration: overline;"><xsl:apply-templates/></span>
    </xsl:template>

    <xsl:template match="hi[@rend='sup']">
        <sup><xsl:apply-templates/></sup>
    </xsl:template>

    <xsl:template match="hi[@rend='sub']">
        <sub><xsl:apply-templates/></sub>
    </xsl:template>

    <xsl:template match="hi[@rend='italic']">
        <i><xsl:apply-templates/></i>
    </xsl:template>

    <xsl:template match="hi[@rend='bold']">
        <b><xsl:apply-templates/></b>
    </xsl:template>

    <xsl:template match="hi[@rend='sc']">
        <span class="smallcaps"><xsl:apply-templates/></span>
    </xsl:template>

    <xsl:template match="hi[@rend='expanded' or @rend='ex']">
        <span class="letterspaced"><xsl:apply-templates/></span>
    </xsl:template>

    <xsl:template match="hi">
        <i><xsl:apply-templates/></i>
    </xsl:template>



    <!-- Use other font for Greek passages -->
    <xsl:template match="foreign[@lang='el' or @lang='grc']">
        <span class="Greek"><xsl:apply-templates/></span>
    </xsl:template>

    <!-- Use other font for Arabic passages -->
    <xsl:template match="foreign[@lang='ar']">
        <span class="Arabic"><xsl:apply-templates/></span>
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
