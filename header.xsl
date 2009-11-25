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

    Stylesheet to format the HTML header, to be imported in tei2html.xsl.

    Requires: 
        localization.xsl    : templates for localizing strings.
        messages.xsl        : stores localized messages in variables.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"
    >


    <xsl:param name="customCssFile"/>


    <!--====================================================================-->
    <!-- HTML Header -->


    <xsl:template match="TEI.2">
        <xsl:comment>
            <xsl:text> This HTML file has been automatically generated from an XML source. </xsl:text>
        </xsl:comment>

        <xsl:text> <!-- insert extra new-line for PG -->
        </xsl:text>

        <html>
            <xsl:call-template name="setLangAttribute"/>

            <xsl:call-template name="generate-html-header"/>

            <body>
                <xsl:text> <!-- insert extra new-line for PG -->
                </xsl:text>

                <xsl:if test="$optionPGHeaders = 'Yes'">
                    <xsl:call-template name="PGHeader"/>
                </xsl:if>

                <xsl:apply-templates/>

                <xsl:if test="$optionPGHeaders = 'Yes'">
                    <xsl:call-template name="PGFooter"/>
                </xsl:if>
            </body>
        </html>

        <xsl:text> <!-- insert extra new-line for PG -->
        </xsl:text>

    </xsl:template>


    <xsl:template name="generate-html-header">
        <head>
            <title>
                <xsl:value-of select="$title"/>
            </title>

            <xsl:call-template name="generate-metadata"/>

            <xsl:call-template name="include-stylesheets"/>

        </head>
    </xsl:template>


    <xsl:template name="generate-metadata">

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

    </xsl:template>


    <xsl:template name="include-stylesheets">

        <xsl:if test="$outputformat = 'epub'">
            <!-- In ePub, we collect all stylesheets into a single file -->
            <link href="{$basename}.css"    rel="stylesheet"            type="text/css"/>
        </xsl:if>

        <xsl:if test="$outputformat = 'html'">
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
                    <xsl:copy-of select="document('style/gutenberg.css.xml')/*/node()"/>

                    /* Supplement CSS stylesheet "<xsl:value-of select="normalize-space($stylesheetname)"/>" */
                    <xsl:copy-of select="document(normalize-space($stylesheetname))/*/node()"/>

                    /* Standard Aural CSS stylesheet */
                    <xsl:copy-of select="document('style/aural.css.xml')/*/node()"/>

                    <xsl:if test="$customCssFile">
                        /* Custom CSS stylesheet "<xsl:value-of select="normalize-space($customCssFile)"/>" */
                        <xsl:copy-of select="document(normalize-space($customCssFile))/*/node()"/>
                    </xsl:if>
                </style>
                <!-- Pull in CSS sheet for print (using Prince). -->
                <xsl:if test="$optionPrinceMarkup = 'Yes'">
                    <style type="text/css" media="print">
                        /* CSS stylesheet for printing */
                        <xsl:copy-of select="document('style/print.css.xml')/*/node()"/>
                    </style>
                </xsl:if>
            </xsl:if>

             <style type="text/css">
                /* Generated CSS for specific elements */
                <xsl:apply-templates select="/TEI.2/text" mode="css"/>
            </style>

        </xsl:if>

    </xsl:template>


    <!--====================================================================-->
    <!-- TEI Header -->

    <!-- Suppress the header in the output -->

    <xsl:template match="teiHeader"/>



    <!-- Ignore content in css-mode -->
    <xsl:template match="text()" mode="css"/>


</xsl:stylesheet>
