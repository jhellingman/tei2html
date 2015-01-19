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
            <back id="backmatter">
                <divGen type="toc" id="toc"/>
                <divGen type="Colophon"/>
            </back>
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
            <notesStmt>
                <note type="Description">
                    <xsl:value-of select="fb2:title-info/fb2:annotation"/>
                </note>
            </notesStmt>
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
        <encodingDesc>
            <xsl:apply-templates select="fb2:title-info/fb2:annotation"/>
        </encodingDesc>
        <profileDesc>
            <langUsage>
                <language>
                    <xsl:attribute name="id" select="//fb2:description/fb2:title-info/fb2:lang"/>
                    <xsl:text>TODO: lookup main language name.</xsl:text>
                </language>
                <xsl:for-each-group select="//@xml:lang" group-by=".">
                    <language id="{.}">TODO: lookup language name.</language>
                </xsl:for-each-group>
            </langUsage>
            <xsl:apply-templates mode="keywords" select="fb2:title-info/fb2:keywords"/>
        </profileDesc>
    </teiHeader>
</xsl:template>


<xsl:template mode="keywords" match="fb2:keywords">
    <textClass>
        <keywords>
            <list>
                <xsl:for-each select="tokenize(current(), ',')">
                    <item>
                        <xsl:value-of select="normalize-space(.)"/>
                    </item>
                </xsl:for-each>
            </list>
        </keywords>
    </textClass>
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


<xsl:template match="fb2:*">
    <xsl:message terminate="no">Unhandled fb2 element: <xsl:value-of select="name()"/></xsl:message>
        <xsl:apply-templates/>
</xsl:template>



<xsl:template match="fb2:body">
    <body>
        <xsl:apply-templates/>
    </body>
</xsl:template>


<xsl:template match="fb2:section">
    <div>
        <xsl:apply-templates/>
    </div>
</xsl:template>


<xsl:template match="fb2:annotation">
    <xsl:apply-templates/>
</xsl:template>


<xsl:template match="fb2:p">
    <p>
        <xsl:if test="@xml:lang">
            <xsl:attribute name="lang" select="@xml:lang"/>
        </xsl:if>

        <xsl:apply-templates/>
    </p>
</xsl:template>


<xsl:template match="fb2:title">
    <head>
        <xsl:apply-templates mode="head"/>
    </head>
</xsl:template>


<xsl:template match="fb2:cite">
    <p rend="class(cite)">
        <xsl:apply-templates/>
    </p>
</xsl:template>


<xsl:template match="fb2:subtitle">
    <p rend="class(subtitle)">
        <xsl:apply-templates/>
    </p>
</xsl:template>

<xsl:template match="fb2:text-author">
    <p rend="class(text-author)">
        <xsl:apply-templates/>
    </p>
</xsl:template>


<!-- Skip p elements in titles -->
<xsl:template mode="head" match="fb2:p">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template mode="head" match="*">
    <xsl:apply-templates/>
</xsl:template>


<xsl:template mode="head" match="fb2:epigraph">
    <epigraph>
        <xsl:apply-templates/>
    </epigraph>
</xsl:template>


<xsl:template match="fb2:empty-line">
    <milestone unit="tb" rend="space"/>
</xsl:template>


<xsl:template match="fb2:style[@name='foreign lang']">
    <foreign>
        <xsl:if test="@xml:lang">
            <xsl:attribute name="lang" select="@xml:lang"/>
        </xsl:if>
        <xsl:apply-templates/>
    </foreign>
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


<xsl:template match="fb2:poem">
    <lg type="lgouter">
        <xsl:apply-templates/>
    </lg>
</xsl:template>

<xsl:template match="fb2:stanza">
    <lg>
        <xsl:apply-templates/>
    </lg>
</xsl:template>

<xsl:template match="fb2:v">
    <l>
        <xsl:apply-templates/>
    </l>
</xsl:template>



<xsl:template match="fb2:a[@type='note']">
    <note type="footnote">
        <xsl:attribute name="n" select="."/>
        <xsl:variable name="id" select="f:href2id(@xlink:href)"/>
        <xsl:apply-templates mode="footnote" select="//*[@id=$id]"/>
    </note>
</xsl:template>


<!-- Skip section elements in footnotes -->
<xsl:template mode="footnote" match="fb2:section">
    <xsl:apply-templates mode="footnote"/>
</xsl:template>

<!-- Remove title elements in footnotes (they are the footnote numbers!) -->
<xsl:template mode="footnote" match="fb2:title"/>

<xsl:template mode="footnote" match="*">
    <xsl:apply-templates/>
</xsl:template>


<xsl:function name="f:href2id" as="xs:string">
    <xsl:param name="href"/>
    <xsl:value-of select="substring-after($href, '#')"/>
</xsl:function>


<!-- Drop section with footnotes; should be inlined by this template. -->
<xsl:template match="fb2:body[@name='notes']"/>


<xsl:template match="fb2:image">
    <figure>
        <xsl:attribute name="rend">
            <xsl:text>image(</xsl:text>
            <xsl:value-of select="f:href2id(@xlink:href)"/>
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

    <xsl:value-of select="if (ends-with($basename, $extension)) then $basename else concat($basename, $extension)"/>
</xsl:function>


</xsl:stylesheet>