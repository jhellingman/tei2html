<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:svg="http://www.w3.org/2000/svg"
    exclude-result-prefixes="f xd xhtml xs">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to create SVG graphics.</xd:short>
        <xd:detail>Stylesheet to create SVG graphics.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2021, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xsl:output
        method="html"
        doctype-public="XSLT-compat"
        omit-xml-declaration="yes"
        encoding="UTF-8"
        indent="yes" />


    <xsl:function name="f:right-brace">
        <xsl:param name="rows" as="xs:integer"/>

        <xsl:variable name="v" select="25 * ($rows - 1) + 5"/>
        <xsl:variable name="height" select="40 + 2 * $v"/>

        <svg viewBox="0 0 25 {$height}" preserveAspectRatio="xMidYMid meet" width="10px" height="{$height div 2.5}px">
            <path d="M2 2h4q9 0 9 9v{$v}q0 8 8 8v2q-8 0 -8 8v{$v}q0 9 -9 9h-4 v-2q8 0 8 -8v-{$v}q0 -6 6 -8 -6 -2 -6 -8v-{$v}q0 -8 -8 -8z" style="fill: black;"/>
        </svg>
    </xsl:function>


    <xsl:function name="f:left-brace">
        <xsl:param name="rows" as="xs:integer"/>

        <xsl:variable name="v" select="25 * ($rows - 1) + 5"/>
        <xsl:variable name="height" select="40 + 2 * $v"/>

        <svg viewBox="0 0 25 {$height}" preserveAspectRatio="xMidYMid meet" width="10px" height="{$height div 2.5}px">
            <path d="M24 3h-4q-9 0 -9 9v{$v}q0 8 -8 8v2q8 0 8 8v{$v}q0 9 9 9h4 v-2q-8 0 -8 -8v-{$v}q0 -6 -6 -8 6 -2 6 -8v-{$v}q0 -8 8 -8z" style="fill: black;"/>
        </svg>
    </xsl:function>


    <xsl:template match="/">
        <html>
            <body>
                <h1>Test of braces</h1>
                <table>
                    <tr>
                        <td rowspan="2"><xsl:copy-of select="f:left-brace(2)"/></td>
                        <td>First Line</td>
                        <td rowspan="2"><xsl:copy-of select="f:right-brace(2)"/></td>
                    </tr>
                    <tr>
                        <td>Second Line</td>
                    </tr>
                </table>


                <table>
                    <tr>
                        <td rowspan="3"><xsl:copy-of select="f:left-brace(3)"/></td>
                        <td>First Line</td>
                        <td rowspan="3"><xsl:copy-of select="f:right-brace(3)"/></td>
                    </tr>
                    <tr>
                        <td>Second Line</td>
                    </tr>
                    <tr>
                        <td>Third Line</td>
                    </tr>
                </table>

                <table>
                    <tr>
                        <td rowspan="4"><xsl:copy-of select="f:left-brace(4)"/></td>
                        <td>First Line</td>
                        <td rowspan="4"><xsl:copy-of select="f:right-brace(4)"/></td>
                    </tr>
                    <tr>
                        <td>Second Line</td>
                    </tr>
                    <tr>
                        <td>Third Line</td>
                    </tr>
                    <tr>
                        <td>Fourth Line</td>
                    </tr>
                </table>

            </body>
        </html>
    </xsl:template>


</xsl:stylesheet>
