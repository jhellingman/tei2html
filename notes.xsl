<!DOCTYPE xsl:stylesheet [

    <!ENTITY deg        "&#176;">
    <!ENTITY nbsp       "&#160;">
    <!ENTITY uparrow    "&#8593;">

]>

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f xd"
    version="2.0"
    >

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to handle footnotes.</xd:short>
        <xd:detail>This stylesheet contains templates to handle footnotes in TEI files.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2014, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <!--====================================================================-->
    <!-- Notes -->

    <xd:doc>
        <xd:short>Handle marginal notes.</xd:short>
        <xd:detail>Marginal notes should go to the margin. The actual placement in handled through CSS.</xd:detail>
    </xd:doc>

    <xsl:template match="/TEI.2/text//note[@place='margin']">
        <span class="marginnote">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle footnotes.</xd:short>
        <xd:detail>Handle footnotes. Unless there is an explicit request for a footnote section, tei2html moves 
        footnotes to the end of the div1 element they appear in (but be careful to avoid this in
        div1 elements embedded in quoted texts). Optionally, we place the text of the footnote in-line as well,
        for use by the print stylesheet. In browsers this inline text will be hidden.</xd:detail>
    </xd:doc>

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


    <xd:doc>
        <xd:short>Insert footnotes at the current location.</xd:short>
        <xd:detail>Insert footnotes at the current location. This template will place all footnotes occuring in the
        indicated division at this location.</xd:detail>
    </xd:doc>

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

    <xd:doc>
        <xd:short>Handle footnotes with embedded paragraphs.</xd:short>
        <xd:detail>Insert a footnote with embedded paragraphs. These need to be handled slightly differently 
        from footnotes that do not contain paragraphs, to ensure the generated HTML is valid.</xd:detail>
    </xd:doc>

    <xsl:template match="note[p]" mode="footnotes">
        <p>
            <xsl:variable name="class">
                footnote
                <xsl:call-template name="generate-rend-class-name-if-needed"/>
            </xsl:variable>
            <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>

            <xsl:call-template name="footnote-marker"/>
            <xsl:apply-templates select="*[1]" mode="footfirst"/>
            <xsl:if test="count(*) = 1">
                <xsl:call-template name="footnote-return-arrow"/>
            </xsl:if>
        </p>
        <xsl:apply-templates select="*[position() > 1 and position() != last()]" mode="footnotes"/>
        <xsl:apply-templates select="*[position() > 1 and position() = last()]" mode="footlast"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle footnotes without embedded paragraphs.</xd:short>
        <xd:detail>Insert a footnote without embedded paragraphs.</xd:detail>
    </xd:doc>

    <xsl:template match="note" mode="footnotes">
        <p>
            <xsl:variable name="class">
                footnote
                <xsl:call-template name="generate-rend-class-name-if-needed"/>
            </xsl:variable>
            <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>

            <xsl:call-template name="footnote-marker"/>
            <xsl:apply-templates/>
            <xsl:call-template name="footnote-return-arrow"/>
        </p>
    </xsl:template>


    <xd:doc>
        <xd:short>Place a footnote marker.</xd:short>
        <xd:detail>Place a footnote marker in front of the footnote.</xd:detail>
    </xd:doc>

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


    <xd:doc>
        <xd:short>Place a footnote return arrow.</xd:short>
        <xd:detail>Place a footnote return arrow after the footnote.</xd:detail>
    </xd:doc>

    <xsl:template name="footnote-return-arrow">
        <xsl:text>&nbsp;</xsl:text>
        <a class="fnarrow">
            <xsl:attribute name="href">
                <xsl:call-template name="generate-href">
                    <xsl:with-param name="target" select="ancestor-or-self::note"/>
                </xsl:call-template>
                <xsl:text>src</xsl:text>
            </xsl:attribute>
            <xsl:text>&uparrow;</xsl:text>
        </a>
    </xsl:template>


    <xd:doc>
        <xd:short>Calculate the footnote number.</xd:short>
        <xd:detail>Calculate the footnote number. This number is based on the position of the note in the div0 or div1 element it occurs in.
        Take care to ignore div1 elements that appear in embedded quoted text.</xd:detail>
    </xd:doc>

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


    <xsl:template match="*" mode="footfirst footlast">
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template match="p" mode="footnotes">
        <p>
            <xsl:call-template name="footnote-paragraph"/>
        </p>
    </xsl:template>


    <xsl:template match="p" mode="footlast">
        <p>
            <xsl:call-template name="footnote-paragraph"/>
            <xsl:call-template name="footnote-return-arrow"/>
        </p>
    </xsl:template>


    <xsl:template name="footnote-paragraph">
        <xsl:variable name="class">
            footnote
            <xsl:call-template name="generate-rend-class-name-if-needed"/>
        </xsl:variable>
        <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>

        <xsl:call-template name="set-lang-id-attributes"/>
        <xsl:apply-templates/>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle notes in a text-critical apparatus.</xd:short>
        <xd:detail>Handle notes in a text-critical apparatus (coded with attribute place="apparatus"). These notes are only
        included when a divGen element is present, calling for their rendition.</xd:detail>
    </xd:doc>

    <xsl:template match="/TEI.2/text//note[@place='apparatus']">
        <a class="apparatusnote">
            <xsl:attribute name="id"><xsl:call-template name="generate-id"/>src</xsl:attribute>
            <xsl:attribute name="href"><xsl:call-template name="generate-apparatus-note-href"/></xsl:attribute>
            <xsl:attribute name="title"><xsl:value-of select="."/></xsl:attribute>&deg;</a>
    </xsl:template>

    <xd:doc>
        <xd:short>Generate the notes for a text-critical apparatus.</xd:short>
        <xd:detail>Render all text-critical notes preceding the matched divGen element here.</xd:detail>
    </xd:doc>

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
                <a class="apparatusnote"><xsl:attribute name="href"><xsl:call-template name="generate-href"/>src</xsl:attribute>&deg;</a>
            </span>
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

</xsl:stylesheet>
