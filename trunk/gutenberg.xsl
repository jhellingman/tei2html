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

    Stylesheet to format Project Gutenberg related materials, to be imported in tei2html.xsl.

    Requires: 
        localization.xsl    : templates for localizing strings.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:f="urn:stylesheet-functions"
    exclude-result-prefixes="f"
    version="2.0"
    >


    <!--====================================================================-->
    <!-- Project Gutenberg Header, Footer, and License -->

    <xsl:template name="authors">
        <xsl:for-each select="//titleStmt/author">
            <xsl:choose>
                <xsl:when test="position() != last() and last() > 2">
                    <xsl:value-of select="."/><xsl:text>, </xsl:text>
                </xsl:when>
                <xsl:when test="position() = last() and last() > 1">
                    <xsl:text> </xsl:text><xsl:value-of select="f:message('msgAnd')"/><xsl:text> </xsl:text><xsl:value-of select="."/>
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


    <xsl:template match="divGen[@type='pgheader']">
        <xsl:call-template name="PGHeader"/>
    </xsl:template>


    <xsl:template name="PGHeader">
        <div class="transcribernote">
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
        </div>
        <p/>
    </xsl:template>


    <xsl:template match="divGen[@type='pgfooter']">
        <xsl:call-template name="PGFooter"/>
    </xsl:template>


    <xsl:template name="PGFooter">
        <div class="transcribernote">
            <xsl:variable name="idno" select="//publicationStmt/idno[@type='pgnum' or @type='PGnum']"/>
            <xsl:variable name="params">
                <params>
                    <param name="title"><xsl:value-of select="//titleStmt/title"/></param>
                    <param name="authors"><xsl:call-template name="authors"/></param>
                    <param name="transcriber"><xsl:value-of select="//titleStmt/respStmt[resp='Transcription']/name"/></param>
                    <param name="pgnum"><xsl:value-of select="$idno"/></param>
                    <param name="pgpath"><xsl:value-of select="substring($idno, 1, 1)"/>/<xsl:value-of select="substring($idno, 2, 1)"/>/<xsl:value-of select="substring($idno, 3, 1)"/>/<xsl:value-of select="substring($idno, 4, 1)"/>/<xsl:value-of select="$idno"/>/</param>
                </params>
            </xsl:variable>
            <p/>
            <xsl:call-template name="FormatMessage">
                <xsl:with-param name="name" select="'msgPGFooter'"/>
                <xsl:with-param name="params" select="$params"/>
            </xsl:call-template>
            <xsl:call-template name="PGLicense"/>
        </div>
    </xsl:template>


    <xsl:template name="PGLicense">
        <xsl:call-template name="FormatMessage">
            <xsl:with-param name="name" select="'msgPGLicense'"/>
        </xsl:call-template>
    </xsl:template>


</xsl:stylesheet>
