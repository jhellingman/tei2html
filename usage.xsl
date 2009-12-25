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

                    .q1 { background-color: #FFFFCC; }
                    .q2 { background-color: #FFFF5C; }
                    .q3 { background-color: #FFDB4D; }
                    .q4 { background-color: #FFB442; font-weight: bold; }
                    .q5 { background-color: #FF8566; font-weight: bold; }
                    .q6 { background-color: red; font-weight: bold; }

                </style>
            </head>
            <body>
                <xsl:apply-templates/>
            </body>
        </html>
    </xsl:template>


    <xsl:template match="words">
        <h3>Words in <xsl:call-template name="lookup-language-name"/></h3>
        <xsl:apply-templates/>
    </xsl:template>

    
    <xsl:template name="lookup-language-name">
        <xsl:param name="lang" select="@xml:lang"/>

        <xsl:choose>
            <xsl:when test="$lang = 'en'">English</xsl:when>
            <xsl:when test="$lang = 'en-US'">English (United States)</xsl:when>
            <xsl:when test="$lang = 'en-UK'">English (United Kingdom)</xsl:when>
            <xsl:when test="$lang = 'es'">Spanish</xsl:when>
            <xsl:when test="$lang = 'nl'">Dutch</xsl:when>
            <xsl:when test="$lang = 'la'">Latin</xsl:when>
            <xsl:when test="$lang = 'de'">German</xsl:when>
            <xsl:when test="$lang = 'tl'">Tagalog</xsl:when>
            <xsl:when test="$lang = 'fr'">French</xsl:when>
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


    <xsl:template match="*"/>

</xsl:stylesheet>
