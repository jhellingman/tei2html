<xsl:transform version="2.0"
    xmlns:msg="http://www.gutenberg.ph/2006/schemas/messages"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xliff="urn:oasis:names:tc:xliff:document:1.2"
    exclude-result-prefixes="msg">

    <xsl:output
        method="xml"
        encoding="utf-8"/>

    <xsl:variable name="srclang" select="'en'"/>
    <xsl:variable name="destlang" select="'nl'"/>

    <xsl:template match="/">
        <xliff:xliff version="1.2">
            <xliff:file original="messages-en.xml" datatype="plaintext" source-language="{$srclang}" target-language="{$destlang}">
                <xliff:body>
                    <xsl:apply-templates select="//msg:message[lang($srclang)]"/>
                </xliff:body>
            </xliff:file>
        </xliff:xliff>
    </xsl:template>

    <xsl:template match="msg:message[lang($srclang)]">
        <xliff:trans-unit id="{@name}" datatype="plaintext">
            <xsl:variable name="name" select="@name"/>
            <xsl:variable name="source" select="."/>
            <xsl:variable name="target" select="//msg:message[@name=$name and lang($destlang)]"/>
            <xliff:source><xsl:apply-templates select="$source" mode="cp"/></xliff:source>
            <xliff:target><xsl:apply-templates select="$target" mode="cp"/></xliff:target>
        </xliff:trans-unit>
    </xsl:template>


    <xsl:template match="msg:*" mode="cp">
        <xsl:apply-templates mode="cp"/>
    </xsl:template>

    <!-- represent parameters with the {name} syntax -->
    <xsl:template match="msg:param" mode="cp">
        <xsl:text>{</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>}</xsl:text>
    </xsl:template>


</xsl:transform>
