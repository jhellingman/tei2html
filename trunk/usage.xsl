<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    version="1.0">

    <xsl:output 
        method="html" 
        indent="yes"
        encoding="UTF-8"/>

    <xsl:template match="usage">
        <html>
            <head>
                <title>Usage Report</title>

                <style type="text/css">

                    body { margin-left: 30px; }
                    
                    p { margin: 0px; }
                    
                    .count { color: gray; font-size: smaller; }
                    .gray { color: gray; }
                    .nonword { background-color: #FFFFA0; }

                    .q1 { background-color: #FFFFCC; }
                    .q2 { background-color: #FFFF5C; }
                    .q3 { background-color: #FFDB4D; }
                    .q4 { background-color: #FFB442; font-weight: bold; }
                    .q5 { background-color: #FF8566; font-weight: bold; }
                    .q6 { background-color: red; font-weight: bold; }

                </style>
            </head>
            <body>
                <h3>Contents</h3>

                <ul>
                    <xsl:apply-templates mode="toc"/>
                </ul>

                <xsl:call-template name="word-statistics"/>

                <xsl:apply-templates/>
            </body>
        </html>
    </xsl:template>


    <!-- Overview of Contents -->

    <xsl:template match="words" mode="toc">
        <li>
            <a href="#words{@xml:lang}">Words in <xsl:call-template name="lookup-language-name"/></a>
        </li>
    </xsl:template>

    <xsl:template match="nonwords" mode="toc">
        <li>
            <a href="#nonwords">Non-words</a>
        </li>
    </xsl:template>

    <xsl:template match="tags" mode="toc">
        <li>
            <a href="#tags">Tags</a>
        </li>
    </xsl:template>

    <xsl:template match="rends" mode="toc">
        <li>
            <a href="#rends">@rend Attributes</a>
        </li>
    </xsl:template>

    <xsl:template match="characters" mode="toc">
        <li>
            <a href="#characters">Characters</a>
        </li>
    </xsl:template>


    <xsl:template match="*" mode="toc"/>

    <!-- Words -->

    <xsl:template name="word-statistics">
        <h4>Statistics</h4>
        <table>
            <tr>
                <th></th>
                <th>Distinct</th>
                <th>Total</th>
                <th>Occuring just once</th>
            </tr>
            <tr>
                <td>Known</td>
                <td><xsl:value-of select="count(.//word[@known = 1])"/></td>
                <td><xsl:value-of select="sum(.//word[@known = 1]/@count)"/></td>
                <td><xsl:value-of select="count(.//word[@known = 1 and @count= 1])"/></td>
            </tr>
            <tr>
                <td>Unknown</td>
                <td><xsl:value-of select="count(.//word[@known = 0])"/></td>
                <td><xsl:value-of select="sum(.//word[@known = 0]/@count)"/></td>
                <td><xsl:value-of select="count(.//word[@known = 0 and @count= 1])"/></td>
            </tr>
            <tr>
                <td>Total</td>
                <td><xsl:value-of select="count(.//word)"/></td>
                <td><xsl:value-of select="sum(.//word/@count)"/></td>
                <td><xsl:value-of select="count(.//word[@count= 1])"/></td>
            </tr>
        </table>
    </xsl:template>


    <xsl:template match="words">
        <h3 id="words{@xml:lang}">Words in <xsl:call-template name="lookup-language-name"/></h3>

        <xsl:call-template name="word-statistics"/>

        <h4>Words</h4>

        <xsl:apply-templates/>
    </xsl:template>

    
    <xsl:template name="lookup-language-name">
        <xsl:param name="lang" select="@xml:lang"/>

        <xsl:choose>
            <xsl:when test="$lang = 'de'">German</xsl:when>
            <xsl:when test="$lang = 'en'">English</xsl:when>
            <xsl:when test="$lang = 'en-UK'">English (United Kingdom)</xsl:when>
            <xsl:when test="$lang = 'en-US'">English (United States)</xsl:when>
            <xsl:when test="$lang = 'es'">Spanish</xsl:when>
            <xsl:when test="$lang = 'fr'">French</xsl:when>
            <xsl:when test="$lang = 'it'">Italian</xsl:when>
            <xsl:when test="$lang = 'la'">Latin</xsl:when>
            <xsl:when test="$lang = 'la-x-bio'">Latin (binominal nomenclature)</xsl:when>
            <xsl:when test="$lang = 'nl'">Dutch</xsl:when>
            <xsl:when test="$lang = 'nl-1900'">Dutch (Orthography of De Vries-Te Winkel)</xsl:when>
            <xsl:when test="$lang = 'tl'">Tagalog</xsl:when>

            <xsl:otherwise>Language with code '<xsl:value-of select="$lang"/>'</xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="wordGroup">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>


    <xsl:template match="wordGroup">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>


    <xsl:template match="word">
        <xsl:if test="position() != 1"><xsl:text>, </xsl:text></xsl:if>
        <span>
            <xsl:call-template name="set-word-class"/>
            <xsl:apply-templates/>
        </span>
        <xsl:if test="@count &gt; 1">
            <xsl:text> </xsl:text>
            <span class="count"><xsl:value-of select="@count"/></span>
        </xsl:if>
    </xsl:template>


    <xsl:template name="set-word-class">
        <xsl:attribute name="class">
            <xsl:choose>
                <xsl:when test="@known = 1 and @count &gt; 5">gray</xsl:when>
                <xsl:when test="@known = 1">black</xsl:when>
                <xsl:when test="@count &lt; 2">q5</xsl:when>
                <xsl:when test="@count &lt; 3">q4</xsl:when>
                <xsl:when test="@count &lt; 5">q3</xsl:when>
                <xsl:when test="@count &lt; 8">q2</xsl:when>
                <xsl:when test="@count &lt; 100">q1</xsl:when>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

    <!-- Non-Words -->

    <xsl:template match="nonwords">
        <h3 id="nonwords">Non-Words</h3>

        <p>Counted for all languages combined</p>

        <p>
            <table>
                <tr><th>Non-Word</th><th>Length</th><th>Count</th></tr>

                <xsl:apply-templates/>
            </table>
        </p>
    </xsl:template>

    <xsl:template match="nonword">
        <tr>
            <td><span class="nonword"><xsl:value-of select="translate(., ' ', '&#160;')"/></span></td>
            <td><xsl:value-of select="string-length(.)"/></td>
            <td><xsl:value-of select="@count"/></td>
        </tr>
    </xsl:template>


    <!-- Tags -->

    <xsl:template match="tags">
        <h3 id="tags">Tags</h3>

        <p>Counted for all languages combined</p>

        <p>
            <table>
                <tr><th>Tag</th><th>Count</th></tr>

                <xsl:apply-templates/>
            </table>
        </p>
    </xsl:template>

    <xsl:template match="tag">
        <tr>
            <td><xsl:value-of select="."/></td>
            <td><xsl:value-of select="@count"/></td>
        </tr>
    </xsl:template>


    <!-- Rend -->

    <xsl:template match="rends">
        <h3 id="rends">Rendering Attributes</h3>

        <p>Counted for all languages combined</p>

        <p>
            <table>
                <tr><th>@rend attribute</th><th>Count</th></tr>

                <xsl:apply-templates/>
            </table>
        </p>
    </xsl:template>

    <xsl:template match="rend">
        <tr>
            <td><xsl:value-of select="."/></td>
            <td><xsl:value-of select="@count"/></td>
        </tr>
    </xsl:template>


    <!-- Characters -->

    <xsl:template match="characters">
        <h3 id="characters">Characters</h3>

        <p>
            <table>
                <tr><th>Character</th><th>Code</th><th>Count</th></tr>

                <xsl:apply-templates/>
            </table>
        </p>
    </xsl:template>


    <xsl:template match="character">
        <tr>
            <td><xsl:value-of select="."/></td>
            <td><xsl:value-of select="@code"/></td>
            <td><xsl:value-of select="@count"/></td>
        </tr>
    </xsl:template>


    <!-- Remainder -->

    <xsl:template match="*"/>

</xsl:stylesheet>
