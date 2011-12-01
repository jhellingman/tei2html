<!DOCTYPE xsl:stylesheet [

    <!ENTITY deg        "&#176;">

]>
<!--

    Stylesheet to format (foot)notes, to be imported in tei2html.xsl.

    Requires: 
        localization.xsl    : templates for localizing strings.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:f="urn:stylesheet-functions"
    exclude-result-prefixes="f"
    version="2.0"
    >


    <!--====================================================================-->
    <!-- Notes -->

    <!-- Marginal notes should go to the margin -->

    <xsl:template match="/TEI.2/text//note[@place='margin']">
        <span class="marginnote">
            <xsl:call-template name="set-lang-id-attributes"/>
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
            <xsl:call-template name="footnote-number"/>
        </a>
        <!-- No explicit request for footnote division -->
        <xsl:if test="not(//divGen[@type='Footnotes' or @type='footnotes' or @type='footnotesBody'])">
            <xsl:if test="$optionPrinceMarkup = 'Yes'">
                <span class="displayfootnote">
                    <xsl:call-template name="set-lang-id-attributes"/>
                    <xsl:apply-templates/>
                </span>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <!-- Insert footnotes at the current location -->

    <xsl:template name="insert-footnotes">
        <xsl:param name="div" select="."/>
        <xsl:param name="notes" select="$div//note[@place='foot' or @place='unspecified' or not(@place)]"/>
        
        <!-- No explicit request for a notes division -->
        <xsl:if test="not(//divGen[@type='Footnotes' or @type='footnotes' or @type='footnotesBody'])">
            <!-- Division is not part of quoted text -->
            <xsl:if test="$div[not(ancestor::q)]">
                <!-- We actually do have notes -->
                <xsl:if test="$notes">
                    <div class="footnotes">
                        <hr class="fnsep"/>
                        <xsl:apply-templates mode="footnotes" select="$notes"/>
                    </div>
                </xsl:if>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <!-- Handle notes that contain paragraphs different from simple notes -->

    <xsl:template match="note[p]" mode="footnotes">
        <p>
            <xsl:variable name="class">
                footnote
                <xsl:call-template name="generate-rend-class-name-if-needed"/>
            </xsl:variable>
            <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>

            <xsl:call-template name="footnote-marker"/>
            <xsl:apply-templates select="*[1]" mode="footfirst"/>
        </p>
        <xsl:apply-templates select="*[position() > 1]" mode="footnotes"/>
    </xsl:template>

    <xsl:template match="note" mode="footnotes">
        <p>
            <xsl:variable name="class">
                footnote
                <xsl:call-template name="generate-rend-class-name-if-needed"/>
            </xsl:variable>
            <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>

            <xsl:call-template name="footnote-marker"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>


    <xsl:template name="footnote-marker">
        <xsl:call-template name="set-lang-attribute"/>
        <span class="label">
            <a class="noteref">
                <xsl:call-template name="generate-id-attribute"/>
                <xsl:attribute name="href"><xsl:call-template name="generate-href"/>src</xsl:attribute>
                <xsl:call-template name="footnote-number"/>
            </a>
        </span>
        <xsl:text> </xsl:text>
    </xsl:template>


    <xsl:template name="footnote-number">
        <xsl:choose>
            <xsl:when test="not(ancestor::div1[not(ancestor::q)])">
                <xsl:number level="any" count="note[(@place='foot' or @place='unspecified' or not(@place)) and not(ancestor::div1[not(ancestor::q)])]" from="div0[not(ancestor::q)]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:number level="any" count="note[@place='foot' or @place='unspecified' or not(@place)]" from="div1[not(ancestor::q)]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="*" mode="footfirst">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="p" mode="footnotes">
        <p>
            <xsl:variable name="class">
                footnote
                <xsl:call-template name="generate-rend-class-name-if-needed"/>
            </xsl:variable>
            <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>

            <xsl:call-template name="set-lang-id-attributes"/>
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
            <xsl:call-template name="set-lang-id-attributes"/>
            <h2 class="main"><xsl:value-of select="f:message('msgApparatus')"/></h2>

            <xsl:apply-templates select="preceding::note[@place='apparatus']" mode="apparatus"/>
        </div>
    </xsl:template>

    <xsl:template match="note[@place='apparatus']" mode="apparatus">
        <p>
            <xsl:variable name="class">
                footnote
                <xsl:call-template name="generate-rend-class-name-if-needed"/>
            </xsl:variable>
            <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>

            <xsl:call-template name="set-lang-id-attributes"/>
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
