<!DOCTYPE xsl:stylesheet [

    <!ENTITY deg        "&#176;">

]>
<!--

    Stylesheet to format (foot)notes, to be imported in tei2html.xsl.

    Requires: 
        localization.xsl    : templates for localizing strings.
        messages.xsl        : stores localized messages in variables.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"
    >


    <!--====================================================================-->
    <!-- Notes -->

    <!-- Marginal notes should go to the margin -->

    <xsl:template match="/TEI.2/text//note[@place='margin']">
        <span class="leftnote">
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- Move footnotes to the end of the div1 element they appear in (but not in
    quoted texts). Optionally, we place the text of the footnote in-line as well,
    for use by the print stylesheet. In browsers it will be hidden. -->

    <xsl:template match="/TEI.2/text//note[@place='foot' or @place='unspecified' or not(@place)]">
        <a class="noteref">
            <xsl:attribute name="id"><xsl:call-template name="generate-id"/>src</xsl:attribute>
            <xsl:call-template name="generate-footnote-href-attribute"/>
            <xsl:number level="any" count="note[@place='foot' or @place='unspecified' or not(@place)]" from="div1[not(ancestor::q)]"/>
        </a>
        <xsl:if test="$optionPrinceMarkup = 'Yes'">
            <span class="displayfootnote">
                <xsl:call-template name="setLangAttribute"/>
                <xsl:apply-templates/>
            </span>
        </xsl:if>
    </xsl:template>

    <!-- Handle notes that contain paragraphs different from simple notes -->

    <xsl:template match="note[p]" mode="footnotes">
        <p class="footnote">
            <xsl:call-template name="footnote-marker"/>
            <xsl:apply-templates select="*[1]" mode="footfirst"/>
        </p>
        <xsl:apply-templates select="*[position() > 1]" mode="footnotes"/>
    </xsl:template>

    <xsl:template match="note" mode="footnotes">
        <p class="footnote">
            <xsl:call-template name="footnote-marker"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>


    <xsl:template name="footnote-marker">
        <xsl:call-template name="setLangAttribute"/>
        <span class="label">
            <a class="noteref">
                <xsl:call-template name="generate-id-attribute"/>
                <xsl:attribute name="href"><xsl:call-template name="generate-href"/>src</xsl:attribute>
                <xsl:number level="any" count="note[@place='foot' or @place='unspecified' or not(@place)]" from="div1[not(ancestor::q)]"/>
            </a>
        </span>
        <xsl:text> </xsl:text>
    </xsl:template>


    <xsl:template match="*" mode="footfirst">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="p" mode="footnotes">
        <p class="footnote">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="*" mode="footnotes">
        <xsl:apply-templates/>
    </xsl:template>


    <!-- Notes in a critical apparatus (coded with attribute place="apparatus") -->

    <xsl:template match="/TEI.2/text//note[@place='apparatus']">
        <a class="apparatusnote">
            <xsl:attribute name="id"><xsl:call-template name="generate-id"/>src</xsl:attribute>
            <xsl:call-template name="generate-href-attribute"/>
            <xsl:attribute name="title"><xsl:value-of select="."/></xsl:attribute>&deg;</a>
    </xsl:template>

    <xsl:template match="divGen[@type='apparatus']">
        <div class="div1">
            <xsl:attribute name="id"><xsl:call-template name="generate-id"/></xsl:attribute>
            <xsl:call-template name="setLangAttribute"/>
            <h2><xsl:value-of select="$strApparatus"/></h2>

            <xsl:apply-templates select="preceding::note[@place='apparatus']" mode="apparatus"/>
        </div>
    </xsl:template>

    <xsl:template match="note[@place='apparatus']" mode="apparatus">
        <p class="footnote">
            <xsl:call-template name="setLangAttribute"/>
            <span class="label">
                <a class="apparatusnote">
                    <xsl:attribute name="href">#<xsl:call-template name="generate-id"/>src</xsl:attribute>
                    <xsl:call-template name="generate-id-attribute"/>
                    &deg;</a>
            </span>
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>



</xsl:stylesheet>