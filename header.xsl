<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to format the HTML header, to be imported in tei2html.xsl.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="f xd xs"
    version="2.0"
    >

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to format the HTML header.</xd:short>
        <xd:detail>Stylesheet to format the HTML header, to be imported in tei2html.xsl.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:param name="customCssFile"/>


    <!--====================================================================-->
    <!-- HTML Header -->

    <xd:doc>
        <xd:short>Generate the high-level HTML.</xd:short>
        <xd:detail>
            <p>Generate the high-level structure of the output HTML file.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="TEI.2|TEI">
        <xsl:comment>
            <xsl:text> This HTML file has been automatically generated from an XML source on </xsl:text><xsl:value-of select="f:utc-timestamp()"/><xsl:text>. </xsl:text>
        </xsl:comment>

        <xsl:text> <!-- insert extra new-line for PG -->
        </xsl:text>

        <html>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:call-template name="generate-html-header"/>

            <body>
                <xsl:text> <!-- insert extra new-line for PG -->
                </xsl:text>

                <xsl:if test="f:isSet('includePGHeaders')">
                    <xsl:call-template name="PGHeader"/>
                </xsl:if>

                <xsl:apply-templates/>

                <xsl:if test="f:isSet('includePGHeaders')">
                    <xsl:call-template name="PGFooter"/>
                </xsl:if>
            </body>
        </html>

        <xsl:text> <!-- insert extra new-line for PG -->
        </xsl:text>

    </xsl:template>


    <xd:doc>
        <xd:short>Generate the HTML header.</xd:short>
        <xd:detail>
            <p>Generate the HTML header, including the metadata and the included stylesheets.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="generate-html-header">
        <head>
            <title>
                <xsl:value-of select="$title"/>
            </title>

            <xsl:call-template name="generate-metadata"/>
            <xsl:call-template name="include-stylesheets"/>
        </head>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate the metadata in <code>meta</code>-tags.</xd:short>
        <xd:detail>
            <p>Generate the metadata in <code>meta</code>-tags. This is based on values placed in variables, and will be output in the Dublin Core format.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="generate-metadata">

        <xsl:choose>
            <xsl:when test="$outputformat = 'epub'">
                <meta charset="{$encoding}"/>
            </xsl:when>
            <xsl:otherwise>
                <meta http-equiv="content-type" content="{$mimeType}; charset={$encoding}"/>
            </xsl:otherwise>
        </xsl:choose>
        <meta name="generator" content="tei2html.xsl, see https://github.com/jhellingman/tei2html"/>
        <meta name="author" content="{$author}"/>

        <!-- Link to cover page -->
        <xsl:if test="//figure[@id='cover-image']">
            <link rel="coverpage" href="{f:getimagefilename(//figure[@id='cover-image'][1], '.jpg')}"/>
        </xsl:if>

        <!-- Insert Dublin Core metadata -->
        <link rel="schema.DC" href="http://dublincore.org/documents/1998/09/dces/"/> <!-- WAS: http://purl.org/DC/elements/1.0/ -->

        <meta name="DC.Creator" content="{$author}"/>
        <meta name="DC.Title" content="{$title}"/>
        <xsl:if test="f:isvalid($pubdate)">
            <meta name="DC.Date" content="{$pubdate}"/>
        </xsl:if>
        <meta name="DC.Language" content="{$language}"/>
        <meta name="DC.Format" content="text/html"/>
        <meta name="DC.Publisher" content="{$publisher}"/>
        <xsl:if test="f:isvalid(//idno[@type='PGnum'])">
            <meta name="DC.Rights" content="{f:message('msgNotCopyrightedUS')}"/>
            <meta name="DC.Identifier">
                <xsl:attribute name="content">https://www.gutenberg.org/ebooks/<xsl:value-of select="//idno[@type='PGnum']"/></xsl:attribute>
            </meta>
        </xsl:if>

        <xsl:for-each select="teiHeader/profileDesc/textClass/keywords/list/item">
            <meta name="DC:Subject">
                <xsl:attribute name="content"><xsl:value-of select="."/></xsl:attribute>
            </meta>
        </xsl:for-each>

    </xsl:template>


    <xd:doc>
        <xd:short>Generate stylesheets.</xd:short>
        <xd:detail>
            <p>Generate CSS stylesheets for the generated HTML. With HTML output, these will be placed in-line
            in the output; with ePub output, they will be placed in a single CSS file, and we only generate a
            link to that file here.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="include-stylesheets">
        <xsl:choose>
            <xsl:when test="not(f:isSet('inlineStylesheet')) or $outputformat = 'epub'">
                <!-- Provide a link to the external stylesheet -->
                <link href="{$basename}.css" rel="stylesheet" type="text/css"/>

                <!-- For ePub, the stylesheets are generated elsewhere; for HTML we still have to call the generating template. -->
                <xsl:if test="$outputformat = 'html'">
                    <xsl:call-template name="external-css-stylesheets"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="embed-css-stylesheets"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--====================================================================-->
    <!-- TEI Header -->

    <!-- Suppress the header in the output -->

    <xsl:template match="teiHeader"/>


    <!-- Suppress PGTei extensions -->
    <xsl:template match="pgExtensions">
        <xsl:message terminate="no">WARNING: This stylesheet does not support the Project Gutenberg PGTEI extensions.</xsl:message>
    </xsl:template>

</xsl:stylesheet>
