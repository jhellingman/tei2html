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

<xsl:stylesheet version="2.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:msg="http://www.gutenberg.ph/2006/schemas/messages"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f xd xhtml msg">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to output Project Gutenberg related information.</xd:short>
        <xd:detail>This stylesheet adds various elements to the generated output relevant to Project Gutenberg.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2012, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Combine author names.</xd:short>
        <xd:detail>Combine author names to a sentence, connected with commas and 'and'.</xd:detail>
    </xd:doc>

    <xsl:template name="combine-authors">
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


    <xd:doc>
        <xd:short>Combine transcriber names.</xd:short>
        <xd:detail>Combine transcriber names to a sentence, connected with commas and 'and'.</xd:detail>
    </xd:doc>

    <xsl:template name="combine-transcribers">
        <xsl:for-each select="//titleStmt/respStmt[resp='Transcription']/name">
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


    <xd:doc>
        <xd:short>Generate the PG header.</xd:short>
        <xd:detail>Generate the PG header, based on information in the <code>teiHeader</code>.</xd:detail>
    </xd:doc>

    <xsl:template name="PGHeader">
        <div class="transcribernote">
            <xsl:variable name="params">
                <params>
                    <param name="title"><xsl:value-of select="//titleStmt/title"/></param>
                    <param name="authors"><xsl:call-template name="combine-authors"/></param>
                    <param name="releasedate"><xsl:value-of select="//publicationStmt/date"/></param>
                    <param name="pgnum"><xsl:value-of select="//publicationStmt/idno[@type='pgnum' or @type='PGnum']"/></param>
                    <param name="language"><xsl:value-of select="f:message(/*[self::TEI.2 or self::TEI]/@lang)"/></param>
                </params>
            </xsl:variable>
            <xsl:copy-of select="f:formatMessage('msgPGHeader', $params)"/>
        </div>
        <p/>
    </xsl:template>


    <xsl:template match="divGen[@type='pgfooter']">
        <xsl:call-template name="PGFooter"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate the PG footer.</xd:short>
        <xd:detail>Generate the PG footer, based on information in the <code>teiHeader</code>, and including the long legal text.</xd:detail>
    </xd:doc>

    <xsl:template name="PGFooter">
        <div class="transcribernote">
            <xsl:variable name="idno" select="//publicationStmt/idno[@type='pgnum' or @type='PGnum']"/>
            <xsl:variable name="params">
                <params>
                    <param name="title"><xsl:value-of select="//titleStmt/title"/></param>
                    <param name="authors"><xsl:call-template name="combine-authors"/></param>
                    <param name="transcriber"><xsl:call-template name="combine-transcribers"/></param>
                    <param name="pgnum"><xsl:value-of select="$idno"/></param>
                    <param name="pgpath"><xsl:value-of select="substring($idno, 1, 1)"/>/<xsl:value-of select="substring($idno, 2, 1)"/>/<xsl:value-of select="substring($idno, 3, 1)"/>/<xsl:value-of select="substring($idno, 4, 1)"/>/<xsl:value-of select="$idno"/>/</param>
                </params>
            </xsl:variable>
            <p/>
            <xsl:copy-of select="f:formatMessage('msgPGFooter', $params)"/>
            <xsl:call-template name="PGLicense"/>
        </div>
    </xsl:template>


    <xsl:template name="PGLicense">
        <xsl:variable name="params"><params/></xsl:variable>
        <xsl:copy-of select="f:formatMessage('msgPGLicense', $params)"/>
    </xsl:template>


</xsl:stylesheet>
