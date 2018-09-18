<!DOCTYPE xsl:stylesheet [

    <!ENTITY lf         "&#x0A;">
    <!ENTITY cr         "&#x0D;">

]>

<xsl:stylesheet version="2.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:svg="http://www.w3.org/2000/svg"
    exclude-result-prefixes="f xd xhtml xs">

    <xd:doc type="stylesheet">
        <xd:short>Templates for mathematical formulas</xd:short>
        <xd:detail>This stylesheet contains templates for handling mathematical formulas in TeX format.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2018, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:template match="formula[@notation='TeX']">

        <xsl:variable name="basename" select="f:formulaBasename(.)" as="xs:string"/>
        <xsl:variable name="path" select="concat('formulas/', $basename)" as="xs:string"/>
        <xsl:variable name="texFile" select="concat($path, '.tex')" as="xs:string"/>
        <xsl:variable name="mmlFile" select="concat($path, '.mml')" as="xs:string"/>
        <xsl:variable name="svgFile" select="concat($path, '.svg')" as="xs:string"/>

        <xsl:variable name="texString" select="f:stripMathDelimiters(.)" as="xs:string"/>
        <xsl:variable name="svgTitle" select="document($svgFile, .)/svg:svg/svg:title" as="xs:string?"/>
        <xsl:variable name="description" select="if ($svgTitle) then $svgTitle else $texString" as="xs:string"/>

        <xsl:result-document
                href="{$texFile}"
                method="text"
                encoding="UTF-8">
            <xsl:copy-of select="f:logInfo('Generated file: {1}.', ($texFile))"/>
            <xsl:value-of select="$texString"/>
        </xsl:result-document>

        <xsl:choose>
            <!-- Dynamic mathJax -->
            <xsl:when test="f:getSetting('math.mathJax.format') = 'MathJax'">
                <span>
                    <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                    <xsl:value-of select="if (f:isDisplayMath(.)) then '$$' else '\('"/>
                    <xsl:value-of select="$texString"/>
                    <xsl:value-of select="if (f:isDisplayMath(.)) then '$$' else '\)'"/>
                </span>
            </xsl:when>
            <!-- Precomputed MML inline -->
            <xsl:when test="f:getSetting('math.mathJax.format') = 'MML'">
                <span class="{concat(f:formulaPosition(.), 'Math')}">
                    <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                    <xsl:copy-of select="f:logInfo('Including file: {1}.', ($mmlFile))"/>
                    <xsl:copy-of select="document($mmlFile, .)/*"/>
                </span>
            </xsl:when>
            <!-- Precomputed SVG inline -->
            <xsl:when test="f:getSetting('math.mathJax.format') = 'SVG'">
                <span class="{concat(f:formulaPosition(.), 'Math')}">
                    <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                    <xsl:copy-of select="f:logInfo('Including file: {1}.', ($svgFile))"/>
                    <xsl:copy-of select="document($svgFile, .)/*"/>
                </span>
            </xsl:when>
            <!-- Precomputed SVG as img -->
            <xsl:when test="f:getSetting('math.mathJax.format') = 'SVG+IMG'">
                <span>
                    <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                    <xsl:copy-of select="f:set-class-attribute-with(., concat(f:formulaPosition(.), 'Math'))"/>
                    <img src="{$svgFile}" title="{$description}"/>
                </span>
                </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="f:logError('Unknown format for math formulas: {1}.', (f:getSetting('math.mathJax.format')))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="formula[@notation='TeX']" mode="css">
        <xsl:next-match/>
        <xsl:if test="f:getSetting('math.mathJax.format') = 'SVG+IMG'">
            <xsl:variable name="basename" select="f:formulaBasename(.)"/>
            <xsl:variable name="svgFile" select="concat(concat('formulas/', $basename), '.svg')" as="xs:string"/>
            <xsl:variable name="style" select="document($svgFile, .)/svg:svg/@style"/>

            <xsl:if test="$style">
                <xsl:text>/* Extracted style from SVG file "</xsl:text><xsl:value-of select="$svgFile"/><xsl:text>" */&lf;</xsl:text>
                <xsl:text>#</xsl:text><xsl:value-of select="f:generate-id(.)"/><xsl:text> {&lf;</xsl:text>
                <xsl:value-of select="$style"/> 
                <xsl:text>&lf;}&lf;</xsl:text>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xsl:function name="f:formulaBasename" as="xs:string">
        <xsl:param name="formula" as="element(formula)"/>

        <xsl:value-of select="concat(concat(f:formulaPosition($formula), '-'), f:generate-id($formula))"/>
    </xsl:function>


    <xsl:function name="f:formulaPosition" as="xs:string">
        <xsl:param name="formula" as="element(formula)"/>

        <xsl:value-of select="if (f:isDisplayMath($formula)) then 'display' else 'inline'"/>
    </xsl:function>


    <xsl:function name="f:stripMathDelimiters" as="xs:string">
        <xsl:param name="texString" as="xs:string"/>

        <xsl:variable name="texString" select="replace($texString, '^[$]+' ,'')"/>
        <xsl:variable name="texString" select="replace($texString, '[$]+$' ,'')"/>
        <xsl:value-of select="normalize-space($texString)"/>
    </xsl:function>


    <xsl:function name="f:isDisplayMath" as="xs:boolean">
        <xsl:param name="texString" as="xs:string"/>

        <xsl:value-of select="substring($texString, 1, 2) = '$$'"/>
    </xsl:function>


</xsl:stylesheet>
