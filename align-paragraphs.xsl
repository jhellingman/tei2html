<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:f="http://example.com/"
    exclude-result-prefixes="f xs"
    >


<xsl:output method="html" indent="yes"/>


<xsl:template match="test">

    <html>
        <head>
            <title>Test of parallel columns</title>
            <style type="text/css">
                tr { vertical-align: top; }

                tr:nth-child(even) { background: #CCC; }
                tr:nth-child(odd) { background: #EEE; }

                td { padding-bottom: 1em; }
            </style>
        </head>
        <body>

            <xsl:call-template name="align-paragraphs">
                <xsl:with-param name="a" select="//div[@id='ch1']"/>
                <xsl:with-param name="b" select="//div[@id='ch2']"/>
            </xsl:call-template>
        
        </body>
    </html>
</xsl:template>



<xsl:template name="align-paragraphs">
    <xsl:param name="a"/>
    <xsl:param name="b"/>

    <xsl:variable name="anchors" as="xs:string*">
        <xsl:for-each-group select="$a/p/@n, $b/p/@n" group-by=".">
            <xsl:if test="count(current-group()) = 2">
                <xsl:sequence select="string(.)"/>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:variable>

    <table>
        <xsl:for-each select="$a/p[@n = $anchors]">
            <xsl:variable name="n" select="@n"/>

            <tr class="alignedtext">
                <td>
                    <xsl:apply-templates select="."/>
                    <xsl:call-template name="output-inserted-lines">
                        <xsl:with-param name="start" select="."/>
                        <xsl:with-param name="anchors" select="$anchors"/>
                    </xsl:call-template>
                </td>
                <td>
                    <xsl:apply-templates select="$b/p[@n = $n]"/>
                    <xsl:call-template name="output-inserted-lines">
                        <xsl:with-param name="start" select="$b/p[@n = $n]"/>
                        <xsl:with-param name="anchors" select="$anchors"/>
                    </xsl:call-template>
                </td>
            </tr>
        </xsl:for-each>
    </table>
</xsl:template>


<xsl:template name="output-inserted-lines">
    <xsl:param name="start" as="node()"/>
    <xsl:param name="anchors"/>
    <xsl:variable name="next" select="$start/following-sibling::*[1]"/>

    <xsl:if test="not($next/@n = $anchors)">
        <xsl:if test="$next">
            <xsl:apply-templates select="$next"/>

            <xsl:call-template name="output-inserted-lines">
                <xsl:with-param name="start" select="$next"/>
                <xsl:with-param name="anchors" select="$anchors"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:if>
</xsl:template>





<xsl:template name="sample-input">
    <test>
        <div id="ch1">
            <p n="a1">Eerste Alinea.</p>
            <p n="a1.1">Zomaar ertussen.</p>
            <p n="a2">Tweede Alinea.</p>
            <p n="a3">Derde Alinea.</p>
        </div>
        <div id="ch2">
            <p n="a1">First Paragraph.</p>
            <p n="a2">Second Paragraph.</p>
            <p n="a2.1">Something added here.</p>
            <p n="a3">Third Paragraph.</p>
        </div>
    </test>
</xsl:template>

<xsl:template name="sample-output">
    <table>
        <tr><td>Eerste Alinea.</td>  <td>First Paragraph.</td></tr>
        <tr><td>Zomaar ertussen.</td><td/></tr>
        <tr><td>Tweede Alinea.</td>   <td>Second Paragraph.</td></tr>
        <tr><td/>                       <td>Something added here.</td></tr>
        <tr><td>Derde Alinea.</td>   <td>Third Paragraph.</td></tr>
    </table>
</xsl:template>


<xsl:template name="old-code">
    <xsl:param name="a"/>
    <xsl:param name="b"/>

    <table>
        <xsl:for-each-group group-by="@n" select="$a/p, $b/p">
            <xsl:sort select="@n"/>
            <xsl:variable name="name" select="@n"/>
            <xsl:comment select="current-grouping-key()"/> 
            <tr>
                <td>
                    <xsl:apply-templates select="current-group()[.. is $a]"/> 
                </td>
                <td>
                    <xsl:apply-templates select="current-group()[.. is $b]"/> 
                </td>
             </tr>
        </xsl:for-each-group>
    </table>

</xsl:template>

</xsl:stylesheet>