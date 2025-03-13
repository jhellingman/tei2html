<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
    exclude-result-prefixes="svrl">

    <xsl:output method="html" indent="yes" encoding="UTF-8"/>

    <xsl:template match="/">
        <html>
            <head>
                <title>Schematron Validation Report</title>
                <style>
                    body { font-family: Arial, sans-serif; margin: 20px; }
                    h1 { color: #333; }
                    .error { color: red; font-weight: bold; }
                    .warning { color: orange; font-weight: bold; }
                    .valid { color: green; font-weight: bold; }
                    table { width: 100%%; border-collapse: collapse; margin-top: 20px; }
                    th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
                    th { background-color: #f4f4f4; }
                </style>
            </head>
            <body>
                <h1>Schematron Validation Report</h1>
                <xsl:choose>
                    <xsl:when test="//svrl:failed-assert">
                        <table>
                            <tr>
                                <th>Rule</th>
                                <th>Message</th>
                                <th>Location</th>
                            </tr>
                            <xsl:for-each select="//svrl:failed-assert">
                                <tr>
                                    <td class="error">
                                        <xsl:value-of select="@test"/>
                                    </td>
                                    <td>
                                        <xsl:value-of select="text()"/>
                                    </td>
                                    <td>
                                        <xsl:value-of select="@location"/>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </xsl:when>
                    <xsl:otherwise>
                        <p class="valid">✅ No validation errors found!</p>
                    </xsl:otherwise>
                </xsl:choose>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
