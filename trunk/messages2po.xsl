<xsl:transform
    xmlns:msg="http://www.gutenberg.ph/2006/schemas/messages"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"
    exclude-result-prefixes="msg"
>

    <xsl:output
        method="text"
        encoding="UTF-8"/>

    <!-- review translations in our messages.xml -->

    <xsl:variable name="srclang" select="'en'"/>
    <xsl:variable name="destlang" select="'nl'"/>

    <xsl:template match="/">

        <xsl:text># Automatically converted .po file.

msgid ""
msgstr ""
"Project-Id-Version: PACKAGE VERSION\n"
"Report-Msgid-Bugs-To: person@example.com\n"
"POT-Creation-Date: 2010-01-30 12:01+0100\n"
"PO-Revision-Date: 2010-04-15 12:01+0100\n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=CHARSET\n"
"Content-Transfer-Encoding: 8bit\n"


</xsl:text>

        <xsl:apply-templates select="//msg:message">
            <xsl:sort select="@name" order="ascending"/>
        </xsl:apply-templates>
    </xsl:template>


    <xsl:template match="msg:message">
        <xsl:if test="lang($srclang)">
            <xsl:variable name="name" select="@name"/>
            <xsl:variable name="value" select="."/>
            <xsl:variable name="translation" select="//msg:message[@name=$name and lang($destlang)]"/>

            <xsl:text>#: id:</xsl:text>
            <xsl:value-of select="$name"/>
            <xsl:text>
</xsl:text>
            <xsl:text>msgid "</xsl:text>
            <xsl:apply-templates select="$value" mode="cp"/>
            <xsl:text>"
</xsl:text>
            <xsl:text>msgstr "</xsl:text>
            <xsl:apply-templates select="$translation" mode="cp"/>
            <xsl:text>"

</xsl:text>
        </xsl:if>
    </xsl:template>


    <xsl:template match="msg:*" mode="cp">
        <xsl:apply-templates mode="cp"/>
    </xsl:template>


    <!-- retain tags as-is in the strigns -->
    <xsl:template match="*" mode="cp">
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:apply-templates select="@*" mode="cp"/>
        <xsl:text>&gt;</xsl:text>
        <xsl:apply-templates mode="cp"/>
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>&gt;</xsl:text>
    </xsl:template>


    <!-- represent parameters with the ${name} syntax -->
    <xsl:template match="msg:param" mode="cp">
        <xsl:text>${</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>}</xsl:text>
    </xsl:template>


    <!-- surround single lines with quotes --> 
    <xsl:template match="text()" mode="cp">
        <xsl:call-template name="string-replace-all">
            <xsl:with-param name="text" select="."/>
            <xsl:with-param name="replace" select="'&#x0A;'"/>
            <xsl:with-param name="with" select="'&quot;&#x0A;&quot;'"/>
        </xsl:call-template>

        <!--<xsl:value-of select="translate(., $uppercase, $lowercase)"/> -->
    </xsl:template>

    
    <!-- handle attributes to be copied, using single quotes -->
    <xsl:template match="@*" mode="cp">
        <xsl:text> </xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>='</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>'</xsl:text>
    </xsl:template>

    
    <xsl:template name="string-replace-all">
        <xsl:param name="text"/>
        <xsl:param name="replace"/>
        <xsl:param name="with"/>
        <xsl:choose>
            <xsl:when test="contains($text, $replace)">
                <xsl:value-of select="substring-before($text,$replace)"/>
                <xsl:value-of select="$with"/>
                <xsl:call-template name="string-replace-all">
                    <xsl:with-param name="text"
                    select="substring-after($text,$replace)"/>
                    <xsl:with-param name="replace" select="$replace"/>
                    <xsl:with-param name="with" select="$with"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:variable name="uppercase" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="lowercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>


</xsl:transform>
