<!DOCTYPE xsl:stylesheet [

    <!ENTITY deg        "&#176;">
    <!ENTITY nbsp       "&#160;">
    <!ENTITY uparrow    "&#8593;">

]>

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:tmp="urn:temporary"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f xd xs tmp"
    version="2.0"
    >

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to handle footnotes.</xd:short>
        <xd:detail>This stylesheet contains templates to handle footnotes in TEI files.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2016, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <!--====================================================================-->
    <!-- Notes -->

    <xd:doc>
        <xd:short>Handle marginal notes.</xd:short>
        <xd:detail>Marginal notes should go to the margin. The actual placement in handled through CSS.</xd:detail>
    </xd:doc>

    <xsl:template match="/*[self::TEI.2 or self::TEI]/text//note[@place='margin']">
        <span class="marginnote">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle footnotes.</xd:short>
        <xd:detail>Handle footnotes. Unless there is an explicit request for a footnote section, tei2html moves
        footnotes to the end of the <code>div1</code> element they appear in (but be careful to avoid this in
        <code>div1</code> elements embedded in quoted texts). Optionally, we place the text of the footnote in-line as well,
        for use by the print stylesheet. In browsers this inline text will be hidden.</xd:detail>
    </xd:doc>

    <xsl:template match="/*[self::TEI.2 or self::TEI]/text//note[@place='foot' or @place='unspecified' or not(@place)]">
        <a class="noteref">
            <xsl:attribute name="id"><xsl:call-template name="generate-id"/>src</xsl:attribute>
            <xsl:call-template name="generate-footnote-href-attribute"/>
            <xsl:call-template name="footnote-number"/>
        </a>
        <!-- No explicit request for footnote division -->
        <xsl:if test="not(//divGen[@type='Footnotes' or @type='footnotes' or @type='footnotesBody'])">
            <!-- TODO: this doesn't work properly yet, so disabled. -->
            <xsl:if test="$optionPrinceMarkup = 'XXX'">
                <xsl:choose>
                    <xsl:when test="p">
                        <div class="displayfootnote">
                            <xsl:call-template name="set-lang-id-attributes"/>
                            <xsl:apply-templates/>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <span class="displayfootnote">
                            <xsl:call-template name="set-lang-id-attributes"/>
                            <xsl:apply-templates/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
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
                        <div class="footnote-body">
                            <xsl:apply-templates mode="footnotes" select="$notes"/>
                        </div>
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
        <xsl:element name="{$p.element}">
            <xsl:variable name="class">
                par footnote
                <xsl:call-template name="generate-rend-class-name-if-needed"/>
            </xsl:variable>
            <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>

            <xsl:call-template name="footnote-marker"/>
            <xsl:apply-templates select="*[1]" mode="footfirst"/>
            <xsl:if test="count(*) = 1">
                <xsl:call-template name="footnote-return-arrow"/>
            </xsl:if>
        </xsl:element>
        <xsl:apply-templates select="*[position() > 1 and position() != last()]" mode="footnotes"/>
        <xsl:apply-templates select="*[position() > 1 and position() = last()]" mode="footlast"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle footnotes without embedded paragraphs.</xd:short>
        <xd:detail>Insert a footnote without embedded paragraphs.</xd:detail>
    </xd:doc>

    <xsl:template match="note" mode="footnotes">
        <xsl:element name="{$p.element}">
            <xsl:variable name="class">
                par footnote
                <xsl:call-template name="generate-rend-class-name-if-needed"/>
            </xsl:variable>
            <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>

            <xsl:call-template name="footnote-marker"/>
            <xsl:apply-templates/>
            <xsl:call-template name="footnote-return-arrow"/>
        </xsl:element>
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
        <xsl:if test="f:isSet('useFootnoteReturnArrow')">
            <xsl:text>&nbsp;</xsl:text>
            <a class="fnarrow">
                <xsl:attribute name="href">
                    <xsl:call-template name="generate-href">
                        <!-- Take care to pick the first ancestor, to work correctly with nested footnotes. -->
                        <xsl:with-param name="target" select="ancestor-or-self::note[1]"/>
                    </xsl:call-template>
                    <xsl:text>src</xsl:text>
                </xsl:attribute>
                <xsl:text>&uparrow;</xsl:text>
            </a>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Calculate the footnote number.</xd:short>
        <xd:detail>Calculate the footnote number. This number is based on the position of the note in the <code>div</code>, <code>div0</code> or <code>div1</code> element it occurs in.
        Take care to ignore <code>div1</code> elements that appear in embedded quoted text.</xd:detail>
    </xd:doc>

    <xsl:template name="footnote-number">
        <xsl:choose>
            <xsl:when test="ancestor::div">
                <xsl:number level="any" count="note[@place='foot' or @place='unspecified' or not(@place)]" from="div[not(ancestor::q) and (parent::front or parent::body or parent::back)]"/>
            </xsl:when>
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
        <xsl:element name="{$p.element}">
            <xsl:call-template name="footnote-paragraph"/>
        </xsl:element>
    </xsl:template>


    <xsl:template match="p" mode="footlast">
        <xsl:element name="{$p.element}">
            <xsl:call-template name="footnote-paragraph"/>
            <xsl:call-template name="footnote-return-arrow"/>
        </xsl:element>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle a paragraph in a footnote.</xd:short>
        <xd:detail>Handle a paragraph in a footnote (and apparatus note) by setting the relevant classes, and handling the content as regular content.</xd:detail>
    </xd:doc>

    <xsl:template name="footnote-paragraph">
        <xsl:variable name="class">
            par footnote
            <xsl:if test="preceding-sibling::p">cont </xsl:if>
            <xsl:if test="ancestor::note[@place='apparatus']">apparatus</xsl:if>
            <xsl:call-template name="generate-rend-class-name-if-needed"/>
        </xsl:variable>
        <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>

        <xsl:call-template name="set-lang-id-attributes"/>
        <xsl:apply-templates/>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle notes in a text-critical apparatus.</xd:short>
        <xd:detail>Handle notes in a text-critical apparatus (<code>note</code> elements coded with attribute <code>place="apparatus"</code>). These notes are only
        included when a <code>divGen</code> element is present, calling for their rendition; a text can include
        multiple <code>divGen</code> elements, in which case only the text-critical notes after the preceding one
        are included.</xd:detail>
    </xd:doc>

    <xsl:template match="/*[self::TEI.2 or self::TEI]/text//note[@place='apparatus']">
        <a class="apparatusnote">
            <xsl:attribute name="id"><xsl:call-template name="generate-id"/>src</xsl:attribute>
            <xsl:attribute name="href"><xsl:call-template name="generate-apparatus-note-href"/></xsl:attribute>
            <xsl:attribute name="title"><xsl:value-of select="."/></xsl:attribute>
            <xsl:value-of select="f:getSetting('textCriticalNoteSymbol')"/>
        </a>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate the notes for a text-critical apparatus.</xd:short>
        <xd:detail>Render all text-critical notes preceding the matched <code>divGen</code>, but after the previous <code>divGen</code>, here.</xd:detail>
    </xd:doc>

    <xsl:template match="divGen[@type='apparatus']">
        <div class="div1">
            <xsl:call-template name="set-lang-id-attributes"/>

            <!-- Determine whether we already have seen a divGen for apparatus notes, by finding its id.
                 If that is the case, we only include the apparatus notes after the previous one! -->
            <xsl:variable name="id" select="generate-id(preceding::divGen[@type='apparatus'][1])"/>
            <xsl:variable name="notes" select="if ($id)
                        then preceding::note[@place='apparatus'][generate-id(preceding::divGen[@type='apparatus'][1]) = $id] 
                        else preceding::note[@place='apparatus']"/>

            <h2 class="main"><xsl:value-of select="if (count($notes) &lt;= 1) then f:message('msgApparatusNote') else f:message('msgApparatusNotes')"/></h2>

            <xsl:call-template name="handle-apparatus-notes"> 
                <xsl:with-param name="notes" select="$notes"/>
                <xsl:with-param name="rend" select="@rend"/>
            </xsl:call-template>
        </div>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate the notes for a text-critical apparatus in one or two columns.</xd:short>
        <xd:detail>Render the text-critical notes in one or two columns. The splitting works under the assumption
        that the average length of each note is about the same. A smarter way of balancing the two
        columns can only be achieved when actually rendering the columns (in the browser or otherwise).</xd:detail>
    </xd:doc>

    <xsl:template name="handle-apparatus-notes-xx">
        <xsl:param name="notes" as="node()*"/>
        <xsl:param name="rend" as="xs:string?"/>

        <xsl:choose>
            <xsl:when test="f:rend-value($rend, 'columns') = '2' and count($notes) &gt; 1">
                <xsl:variable name="halfway" select="ceiling(count($notes) div 2)"/>
                <table class="apparataus">
                    <tr>
                        <td class="first">
                            <xsl:for-each select="$notes[position() &lt; $halfway + 1]">
                                <xsl:apply-templates select="." mode="apparatus"/>
                            </xsl:for-each>
                        </td>
                        <td class="second">
                            <xsl:for-each select="$notes[position() &gt; $halfway]">
                                <xsl:apply-templates select="." mode="apparatus"/>
                            </xsl:for-each>
                        </td>
                    </tr>
                </table>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$notes">
                    <xsl:apply-templates select="." mode="apparatus"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Split a sequence of notes into columns (row-mayor; table).</xd:short>
        <xd:detail>Split a sequence of notes into columns, using a table; order will be: [1, 2], [3, 4].</xd:detail>
    </xd:doc>

    <xsl:template name="handle-apparatus-notes-xxx">
        <xsl:param name="notes" as="node()*"/>
        <xsl:param name="rend" as="xs:string?"/>

        <xsl:variable name="columns" select="number(f:rend-value($rend, 'columns'))"/>

        <xsl:choose>
            <xsl:when test="$columns &gt; 1 and count($notes) &gt; 1">
                <xsl:variable name="rows" select="ceiling(count($notes) div $columns)"/>
                <table class="cols{$columns}">
                    <xsl:call-template name="set-lang-id-attributes"/>
                    <tr>
                        <xsl:for-each-group select="$notes" group-by="(position() - 1) idiv number($rows)">
                            <td>
                                <xsl:for-each select="current-group()">
                                    <xsl:apply-templates select="." mode="apparatus"/>
                                </xsl:for-each>
                            </td>
                        </xsl:for-each-group>
                    </tr>
                </table>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$notes">
                    <xsl:apply-templates select="." mode="apparatus"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate a single note for a text-critical apparatus.</xd:short>
        <xd:detail>Render a single text-critical note.</xd:detail>
    </xd:doc>

    <xsl:template match="note[@place='apparatus' and not(p)]" mode="apparatus">
        <xsl:element name="{$p.element}">
            <xsl:variable name="class">
                par footnote apparatus
                <xsl:call-template name="generate-rend-class-name-if-needed"/>
            </xsl:variable>
            <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>

            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:call-template name="apparatus-note-marker"/>
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
            <xsl:call-template name="footnote-return-arrow"/>
        </xsl:element>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle text-critical apparatus notes with embedded paragraphs.</xd:short>
        <xd:detail>Insert a footnote with embedded paragraphs. These need to be handled slightly differently
        from footnotes that do not contain paragraphs, to ensure the generated HTML is valid.</xd:detail>
    </xd:doc>

    <xsl:template match="note[@place='apparatus' and p]" mode="apparatus">
        <xsl:element name="{$p.element}">
            <xsl:variable name="class">
                par footnote apparatus
                <xsl:call-template name="generate-rend-class-name-if-needed"/>
            </xsl:variable>
            <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>

            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:call-template name="apparatus-note-marker"/>
            <xsl:apply-templates select="*[1]" mode="footfirst"/>
            <xsl:if test="count(*) = 1">
                <xsl:call-template name="footnote-return-arrow"/>
            </xsl:if>
        </xsl:element>
        <xsl:apply-templates select="*[position() > 1 and position() != last()]" mode="footnotes"/>
        <xsl:apply-templates select="*[position() > 1 and position() = last()]" mode="footlast"/>
    </xsl:template>

    <xsl:template name="apparatus-note-marker">
        <span class="label">
            <a class="apparatusnote">
                <xsl:attribute name="href"><xsl:call-template name="generate-href"/>src</xsl:attribute>
                <xsl:value-of select="f:getSetting('textCriticalNoteSymbol')"/>
            </a>
        </span>
    </xsl:template>


    <xd:doc>
        <xd:short>Format apparatus notes as a single paragraph.</xd:short>
        <xd:detail><p>Format apparatus notes as a single paragraph. A complicating factor here is that some of the notes do contain
        paragraphs, and we want to preserve the paragraph breaks, having a multi-paragraph note following the preceding note
        on the same line, start a new line for the following paragraphs of that note, and have the following note follow the
        last paragraph of the multi-paragraph note. To achieve this, first collect the content of all the notes in a single list, indicating where
        the paragraph breaks should remain, and then group them back into paragraphs.</p>
    
        <p>As part of this action, we copy elements into a temporary structure, which we also need to use to retain the ids of the
        original notes, as to keep cross references working.</p></xd:detail>
    </xd:doc>

    <xsl:template name="handle-apparatus-notes">
        <xsl:param name="notes" as="node()*"/>
        <xsl:param name="rend" as="xs:string?"/>

        <xsl:variable name="collected-notes">
            <xsl:for-each select="$notes">
                <xsl:apply-templates select="." mode="collect-apparatus"/>
            </xsl:for-each>
        </xsl:variable>

        <div class="textual-notes-body">
            <xsl:for-each-group select="$collected-notes/*" group-starting-with="tmp:br">
                <xsl:element name="{$p.element}">
                    <xsl:variable name="class">
                        par apparatus
                        <xsl:call-template name="generate-rend-class-name-if-needed"/>
                    </xsl:variable>
                    <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>

                    <xsl:apply-templates select="current-group()"/>
                </xsl:element>
            </xsl:for-each-group>
        </div>
    </xsl:template>

    <xsl:template match="note[@place='apparatus' and not(p)]" mode="collect-apparatus">
        <tmp:span>
            <xsl:call-template name="generate-id-attribute-for"/>
            <xsl:attribute name="rend" select="@rend"/>
            <xsl:attribute name="lang" select="@lang"/>
            <xsl:for-each select="*|text()">
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </tmp:span>
    </xsl:template>

    <xsl:template match="note[@place='apparatus' and p]" mode="collect-apparatus">
        <xsl:apply-templates select="*[1]" mode="collect-apparatus-first"/>
        <xsl:apply-templates select="*[position() > 1]" mode="collect-apparatus"/>
    </xsl:template>

    <xsl:template match="p" mode="collect-apparatus-first">
        <tmp:span>
            <xsl:call-template name="generate-id-attribute-for">
                <xsl:with-param name="node" select="ancestor::note[1]"/>
            </xsl:call-template>
            <xsl:attribute name="rend" select="ancestor::note[1]/@rend"/>
            <xsl:attribute name="lang" select="ancestor::note[1]/@lang"/>
            <xsl:for-each select="*|text()">
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </tmp:span>
    </xsl:template>

    <xsl:template match="p" mode="collect-apparatus">
        <tmp:br/>
        <tmp:span>
            <xsl:attribute name="rend" select="ancestor::note[1]/@rend"/>
            <xsl:attribute name="lang" select="ancestor::note[1]/@lang"/>
            <xsl:for-each select="*|text()">
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </tmp:span>
    </xsl:template>

    <xsl:template match="tmp:span">
        <span class="apparatus-note">
            <xsl:if test="@id">
                <xsl:attribute name="id" select="@id"/>
                <a class="apparatusnote">
                    <xsl:attribute name="href">#<xsl:value-of select="@id"/>src</xsl:attribute>
                    <xsl:attribute name="title"><xsl:value-of select="f:message('msgReturnToSourceLocation')"/></xsl:attribute>
                    <xsl:value-of select="f:getSetting('textCriticalNoteReturnSymbol')"/>
                </a>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="tmp:br"/>


</xsl:stylesheet>
