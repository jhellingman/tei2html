<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet 
    version="2.0"

    xmlns:f="urn:stylesheet-functions"
    xmlns:fb2="http://www.gribuser.ru/xml/fictionbook/2.0"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

    exclude-result-prefixes="f fb2 xd xlink xs"
    >

    <xd:doc type="stylesheet">
        <xd:short>XSLT stylesheet to convert a fictionbook format text to TEI.</xd:short>
        <xd:detail>This stylesheet converts a fictionbook (.fb2) file to TEI.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2015, Jeroen Hellingman</xd:copyright>
    </xd:doc>

<xsl:template match="fb2:FictionBook">
    <TEI.2>
        <xsl:attribute name="lang" select="fb2:description/fb2:title-info/fb2:lang"/>
        <xsl:apply-templates select="fb2:description"/>
        <text>
            <xsl:apply-templates select="fb2:body"/>
        </text>
        <xsl:apply-templates select="fb2:binary"/>
    </TEI.2>
</xsl:template>


<xsl:template match="fb2:description">

        <teiHeader>
            <fileDesc>
                <titleStmt>
                    <title>
                        <xsl:value-of select="fb2:title-info/fb2:book-title"/>
                    </title>
                    <author>
                        <xsl:value-of select="f:concatName(fb2:title-info/fb2:author)"/>
                     </author>
                </titleStmt>
                <publicationStmt>
                    <publisher>
                        <xsl:value-of select="fb2:publish-info/fb2:publisher"/>
                    </publisher>
                    <pubPlace></pubPlace>
                    <idno type="isbn">
                        <xsl:value-of select="fb2:publish-info/fb2:isbn"/>
                    </idno>
                    <idno type="epub-id">
                        <xsl:value-of select="fb2:document-info/fb2:id"/>
                    </idno>
                    <date>
                        <xsl:value-of select="fb2:publish-info/fb2:year"/>
                    </date>
                </publicationStmt>
                <sourceDesc>
                    <bibl>
                        <author>
                            <xsl:value-of select="f:concatName(fb2:title-info/fb2:author)"/>
                        </author>
                        <title>
                            <xsl:value-of select="fb2:title-info/fb2:book-title"/>
                        </title>
                        <date>
                            <xsl:value-of select="fb2:publish-info/fb2:year"/>
                        </date>
                    </bibl>
                </sourceDesc>
            </fileDesc>
        </teiHeader>

</xsl:template>



<xsl:function name="f:concatName" as="xs:string">
    <xsl:param name="node"/>

        <xsl:variable name="result">
            <xsl:value-of select="$node/fb2:first-name"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$node/fb2:middle-name"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$node/fb2:last-name"/>
        </xsl:variable>

        <xsl:value-of select="normalize-space($result)"/>
</xsl:function>


<xsl:template match="fb2:section">
    <div>
        <xsl:apply-templates/>
    </div>
</xsl:template>


<xsl:template match="fb2:p">
    <p>
        <xsl:apply-templates/>
    </p>
</xsl:template>


<xsl:template match="fb2:title">
    <head>
        <xsl:apply-templates/>
    </head>
</xsl:template>


<xsl:template match="fb2:empty-line">
    <milestone unit="tb"/>
</xsl:template>


<xsl:template match="fb2:strong">
    <hi rend="bold">
        <xsl:apply-templates/>
    </hi>
</xsl:template>


<xsl:template match="fb2:emphasis">
    <hi>
        <xsl:apply-templates/>
    </hi>
</xsl:template>


<xsl:template match="fb2:image">
    <figure>
        <xsl:attribute name="rend">
            <xsl:text>image(images/</xsl:text>
            <xsl:value-of select="@xlink:href"/>
            <xsl:text>)</xsl:text>
        </xsl:attribute>
    </figure>
</xsl:template>


<xsl:template match="fb2:binary">
    <xsl:variable name="filename" select="f:getFilename(.)"/>
    <xsl:message terminate="no">Extracted binary file: <xsl:value-of select="$filename"/></xsl:message>
    <xsl:result-document
            href="{$filename}.hex"
            method="text"
            encoding="UTF-8"><xsl:value-of select="."/></xsl:result-document>
</xsl:template>


<xsl:function name="f:getFilename" as="xs:string">
    <xsl:param name="node"/>

    <xsl:variable name="basename" select="$node/@id"/>
    <xsl:variable name="contentType" select="$node/@content-type"/>
    <xsl:variable name="extension">
        <xsl:choose>
            <xsl:when test="$contentType = 'image/jpeg'">.jpg</xsl:when>
            <xsl:when test="$contentType = 'image/png'">.png</xsl:when>
            <xsl:when test="$contentType = 'image/gif'">.gif</xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:value-of select="concat($basename, $extension)"/>
</xsl:function>


</xsl:stylesheet>