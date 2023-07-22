<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="urn:stylesheet-functions"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="f xd">

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

    <xsl:template match="TEI.2 | TEI">
        <xsl:comment>
            <xsl:text> This HTML file has been automatically generated from an XML source on </xsl:text>
            <xsl:value-of select="f:utc-timestamp()"/>
            <xsl:text> using </xsl:text>
            <xsl:copy-of select="system-property('xsl:product-name')"/>
            <xsl:text> </xsl:text>
            <xsl:copy-of select="system-property('xsl:product-version')"/>
            <xsl:text>. </xsl:text>
        </xsl:comment>

        <xsl:text> <!-- insert extra new-line for PG -->
        </xsl:text>

        <html xmlns="http://www.w3.org/1999/xhtml">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:call-template name="generate-html-header"/>
            <xsl:call-template name="generate-html-body"/>
        </html>

        <xsl:text> <!-- insert extra new-line for PG -->
        </xsl:text>

    </xsl:template>


    <xd:doc>
        <xd:short>Generate the HTML header.</xd:short>
        <xd:detail>
            <p>Generate the HTML header, including metadata and stylesheets.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="generate-html-header">
        <head>
            <title>
                <xsl:value-of select="teiHeader/fileDesc/titleStmt/title[not(@type) or @type='main'][1]"/>
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
            <xsl:when test="f:is-epub() or f:is-html5()">
                <meta charset="{$encoding}"/>
            </xsl:when>
            <xsl:otherwise>
                <meta http-equiv="Content-Type" content="{$mimeType}; charset={$encoding}"/>
            </xsl:otherwise>
        </xsl:choose>

        <meta name="generator" content="tei2html.xsl, see https://github.com/jhellingman/tei2html"/>

        <xsl:for-each select="teiHeader/fileDesc/titleStmt/author">
            <meta name="author" content="{.}"/>
        </xsl:for-each>

        <!-- Link to cover page -->
        <xsl:if test="//figure[@id='cover-image']">
            <link rel="coverpage" href="{f:determine-image-filename(//figure[@id='cover-image'][1], '.jpg')}"/>
        </xsl:if>

        <!-- Insert Dublin Core metadata -->
        <link rel="schema.DC" href="http://purl.org/dc/elements/1.1/"/>

        <xsl:for-each select="teiHeader/fileDesc/titleStmt/title[not(@type) or @type='main']">
            <meta name="DC.Title" content="{.}"/>
        </xsl:for-each>

        <xsl:for-each select="teiHeader/fileDesc/titleStmt/author">
            <meta name="DC.Creator" content="{.}"/>
        </xsl:for-each>

        <xsl:for-each select="teiHeader/fileDesc/titleStmt/editor">
            <meta name="DC.Contributor" content="{.}"/>
        </xsl:for-each>
        <xsl:for-each select="teiHeader/fileDesc/titleStmt/respStmt[resp != 'Transcription']/name">
            <meta name="DC.Contributor" content="{.}"/>
        </xsl:for-each>

        <xsl:if test="f:is-valid(teiHeader/fileDesc/publicationStmt/date)">
            <meta name="DC.Date" content="{teiHeader/fileDesc/publicationStmt/date}"/>
        </xsl:if>
        <meta name="DC.Language" content="{f:get-current-lang(.)}"/>
        <meta name="DC.Format" content="text/html"/>
        <xsl:if test="f:is-valid(teiHeader/fileDesc/publicationStmt/publisher)">
            <meta name="DC.Publisher" content="{teiHeader/fileDesc/publicationStmt/publisher}"/>
        </xsl:if>
        <xsl:if test="f:is-valid((//idno[@type='PGnum'])[1])">
            <meta name="DC.Rights" content="{f:message('msgNotCopyrightedUS')}"/>
            <meta name="DC.Identifier" content="https://www.gutenberg.org/ebooks/{(//idno[@type='PGnum'])[1]}"/>
        </xsl:if>

        <xsl:for-each select="teiHeader/profileDesc/textClass/keywords/list/item">
            <xsl:if test="f:is-valid(.)">
                <meta name="DC:Subject">
                    <xsl:attribute name="content"><xsl:value-of select="."/></xsl:attribute>
                </meta>
            </xsl:if>
        </xsl:for-each>

        <!-- Link in MathJax script -->
        <xsl:if test="f:get-setting('math.mathJax.format') = 'MathJax' and //formula[@notation='TeX']">
            <script type="text/javascript" async="async"
              src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/latest.js?config={f:get-setting('math.mathJax.configuration')}">
            </script>
        </xsl:if>

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
            <xsl:when test="not(f:is-set('css.inline')) or f:is-epub()">
                <!-- Provide a link to the external stylesheet -->
                <link href="{$basename}.css" rel="stylesheet" type="text/css"/>

                <!-- For ePub, the stylesheets are generated elsewhere; for HTML we still have to call the generating template. -->
                <xsl:if test="f:is-html()">
                    <xsl:call-template name="external-css-stylesheets"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="embed-css-stylesheets"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate the HTML body.</xd:short>
    </xd:doc>

    <xsl:template name="generate-html-body">
        <body>
            <xsl:text> <!-- insert extra new-line for PG -->
            </xsl:text>

            <xsl:if test="f:is-set('pg.includeHeaders')">
                <xsl:call-template name="PGHeader"/>
            </xsl:if>

            <xsl:apply-templates/>

            <xsl:if test="f:is-set('pg.includeHeaders')">
                <xsl:call-template name="PGFooter"/>
            </xsl:if>
        </body>
    </xsl:template>


    <!--====================================================================-->
    <!-- TEI Header -->

    <!-- Suppress the header in the output -->

    <xsl:template match="teiHeader"/>


    <!-- Suppress PGTei extensions -->
    <xsl:template match="pgExtensions">
        <xsl:copy-of select="f:log-warning('This stylesheet does not support the Project Gutenberg PGTEI extensions.', ())"/>
    </xsl:template>

</xsl:stylesheet>
