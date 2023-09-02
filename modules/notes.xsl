<!DOCTYPE xsl:stylesheet [

    <!ENTITY deg        "&#176;">
    <!ENTITY nbsp       "&#160;">
    <!ENTITY uparrow    "&#8593;">
]>

<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="urn:stylesheet-functions"
                xmlns:tmp="urn:temporary"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:epub="http://www.idpf.org/2007/ops"
                exclude-result-prefixes="epub f tmp xd xs">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to handle notes.</xd:short>
        <xd:detail>This stylesheet contains templates to handle notes in TEI files.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2017, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Determine whether a note is a footnote.</xd:short>
        <xd:detail>Note that Perseus texts encode the placement of the note in the <code>@type</code> attribute, hence the complex check.</xd:detail>
    </xd:doc>

    <xsl:function name="f:is-footnote" as="xs:boolean">
        <xsl:param name="note" as="element(note)"/>
        <xsl:sequence select="($note/@place = ('foot', 'unspecified') or (not($note/@place) and not($note/@type = 'margin')))
            and not($note/ancestor::teiHeader)"/>
    </xsl:function>

    <xsl:function name="f:is-margin-note" as="xs:boolean">
        <xsl:param name="note" as="element(note)"/>
        <xsl:sequence select="$note/@place = ('margin', 'left', 'right') or $note/@type = 'margin'"/>
    </xsl:function>

    <xsl:function name="f:is-cut-in-note" as="xs:boolean">
        <xsl:param name="note" as="element(note)"/>
        <xsl:sequence select="$note/@place = ('cut-in-left', 'cut-in-right')"/>
    </xsl:function>

    <xsl:function name="f:is-apparatus-note" as="xs:boolean">
        <xsl:param name="note" as="element(note)"/>
        <xsl:sequence select="$note/@place = 'apparatus'"/>
    </xsl:function>

    <xsl:function name="f:is-table-note" as="xs:boolean">
        <xsl:param name="note" as="element(note)"/>
        <xsl:sequence select="$note/@place = ('table')"/>
    </xsl:function>


    <!--====================================================================-->
    <!-- Notes -->

    <xd:doc>
        <xd:short>Handle marginal notes.</xd:short>
        <xd:detail>Marginal notes should go to the margin. CSS handles the actual placement.</xd:detail>
    </xd:doc>

    <xsl:template match="note[f:is-margin-note(.)]">
        <span class="{if (@place = 'right') then 'right-marginnote' else 'marginnote'}">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="note[f:is-cut-in-note(.)]">
        <span class="{@place}-note">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <!-- Hack to make tagging easier, should be replaced by <note place="margin"> at some stage. -->
    <xsl:template match="margin">
        <span class="marginnote">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle footnotes.</xd:short>
        <xd:detail>Handle footnotes. This template handles the placement of the footnote marker
        only. Unless there is an explicit request for a footnote section, tei2html moves the
        footnote content to the end of the <code>div1</code> element they appear in (but is careful
        to avoid this in <code>div1</code> elements embedded in quoted texts).</xd:detail>
    </xd:doc>

    <xsl:template match="note[f:is-footnote(.)]">
        <xsl:call-template name="insert-note-ref"/>
    </xsl:template>

    <xsl:template name="insert-note-ref">
        <xsl:context-item as="element(note)" use="required"/>
        <a class="noteRef" id="{f:generate-id(.)}src" href="{f:generate-footnote-href(.)}">
            <xsl:if test="f:is-epub()">
                <xsl:attribute name="epub:type" select="'noteref'"/>
            </xsl:if>
            <xsl:call-template name="footnote-number"/>
        </a>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle duplicated footnotes.</xd:short>
        <xd:detail>Handle duplicated footnotes. This template handles the placement of the footnote marker
        only.</xd:detail>
    </xd:doc>

    <xsl:template match="note[@sameAs]" priority="1">
        <xsl:variable name="targetNote" select="key('id', replace(@sameAs, '#', ''))[1]"/>
        <xsl:apply-templates select="$targetNote" mode="noterefnumber">
            <xsl:with-param name="sourceNote" select="."/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template name="insert-note-same-as-ref">
        <xsl:context-item as="element(note)" use="required"/>
        <xsl:variable name="targetNote" select="key('id', replace(@sameAs, '#', ''))[1]"/>
        <xsl:apply-templates select="$targetNote" mode="noterefnumber">
            <xsl:with-param name="sourceNote" select="."/>
        </xsl:apply-templates>
    </xsl:template>


<!--
    <xd:doc>
        <xd:short>Handle footnotes inside collected apparatus material.</xd:short>
        <xd:detail>When footnotes appear nested inside apparatus nodes, and we collect the apparatus
        notes into a single block, the <code>note</code> elements are no longer rooted under the <code>TEI</code>
        element, so the above templates will not match them. These templates resolve that.</xd:detail>
    </xd:doc>

    <xsl:template match="tmp:span//note[f:is-footnote(.)]">
        <xsl:call-template name="insert-note-ref"/>
    </xsl:template>

    <xsl:template match="tmp:span//note[@sameAs]" priority="1">
        <xsl:call-template name="insert-note-same-as-ref"/>
    </xsl:template>
-->

    <xsl:template match="note">
        <xsl:copy-of select="f:log-warning('unclassified note not handled (n={1}; id={2}).', (@n, f:generate-id(.)))"/>
        <xsl:apply-templates/>
    </xsl:template>


    <xd:doc>
        <xd:short>Determine whether we should insert footnotes at the current location.</xd:short>
        <xd:detail>To have a footnote division, we have to meet the following conditions:
            <ul>
                <li>1. We have footnotes.</li>
                <li>2. We do not have an explicit request for a footnote division elsewhere.</li>
                <li>3. We should not be a division inside a quotation.</li>
            </ul>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:div-has-footnotes" as="xs:boolean">
        <xsl:param name="div"/>
        <xsl:variable name="notes" select="$div//note[f:is-footnote(.)][not(@sameAs)]" as="element(note)*"/>
        <xsl:sequence select="f:div-has-footnotes($div, $notes)"/>
    </xsl:function>

    <xsl:function name="f:div-has-footnotes" as="xs:boolean">
        <xsl:param name="div"/>
        <xsl:param name="notes"/>

        <xsl:sequence select="$notes
            and not($root//divGen[@type = ('Footnotes', 'footnotes', 'footnotesBody')])
            and $div[not(ancestor::q)]"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Insert footnotes at the current location.</xd:short>
        <xd:detail>Insert footnotes at the current location. This template will place all footnotes occurring in the
        indicated division at this location.</xd:detail>
    </xd:doc>

    <xsl:template name="insert-footnotes">
        <xsl:param name="div" select="." as="element()"/>
        <xsl:param name="notes" select="$div//note[f:is-footnote(.)][not(@sameAs)]" as="element(note)*"/>

        <xsl:if test="f:div-has-footnotes($div, $notes)">
            <div class="footnotes">
                <hr class="fnsep"/>
                <div class="footnote-body">
                    <xsl:apply-templates mode="footnotes" select="$notes"/>
                </div>
            </div>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Insert footnotes that belong to a div0.</xd:short>
        <xd:detail>These should only be inserted if not done so earlier (which happens if the <code>div0</code> contains
        a <code>div1</code> element).</xd:detail>
    </xd:doc>

    <xsl:template name="insert-div0-footnotes">
        <xsl:if test=".//note[f:is-footnote(.) and not(ancestor::div1)] and not(ancestor::q) and not(.//div1)">
            <div class="footnotes">
                <hr class="fnsep"/>
                <div class="footnote-body">
                    <xsl:apply-templates mode="footnotes" select=".//note[f:is-footnote(.) and not(ancestor::div1)]"/>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:short>Insert footnotes that belong to a div0 fragment at the current location.</xd:short>
        <xd:detail>Insert footnotes in the preceding fragment of the div0 section here. This is
        something of a hack to get those footnotes in a more-or-less decent location.</xd:detail>
    </xd:doc>

    <xsl:template name="insert-div0-fragment-footnotes">
        <xsl:context-item as="element(div1)" use="required"/>
        <xsl:if test="count(preceding-sibling::div1) = 0 and ancestor::div0">
            <xsl:if test="..//note[f:is-footnote(.) and not(ancestor::div1)]">
                <div class="footnotes">
                    <hr class="fnsep"/>
                    <div class="footnote-body">
                        <xsl:apply-templates mode="footnotes" select="..//note[f:is-footnote(.) and not(ancestor::div1)]"/>
                    </div>
                </div>
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
        <div class="fndiv">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:if test="f:is-epub()">
                <xsl:attribute name="epub:type" select="'footnote'"/>
            </xsl:if>
            <xsl:element name="{$p.element}">
                <xsl:call-template name="footnote-class-lang"/>
                <xsl:call-template name="footnote-marker"/>
                <xsl:apply-templates select="*[1]" mode="footfirst"/>
                <xsl:if test="count(*) = 1">
                    <xsl:if test="not(f:last-child-is-block-element(./p))">
                        <xsl:call-template name="footnote-return-arrow"/>
                    </xsl:if>
                </xsl:if>
            </xsl:element>
            <xsl:apply-templates select="*[position() > 1 and position() != last()]" mode="footnotes"/>
            <xsl:apply-templates select="*[position() > 1 and position() = last()]" mode="footlast"/>
        </div>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle footnotes without embedded paragraphs.</xd:short>
        <xd:detail>Insert a footnote without embedded paragraphs.</xd:detail>
    </xd:doc>

    <xsl:template match="note" mode="footnotes">
        <div class="fndiv">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:if test="f:is-epub()">
                <xsl:attribute name="epub:type" select="'footnote'"/>
            </xsl:if>
            <xsl:element name="{$p.element}">
                <xsl:call-template name="footnote-class-lang"/>
                <xsl:call-template name="footnote-marker"/>
                <xsl:apply-templates/>

                <!-- Don't put a return arrow after a block-element (table, list, lg), since it goes
                     to a new line and thus takes up too much space. -->
                <xsl:if test="not(f:last-child-is-block-element(.))">
                    <xsl:call-template name="footnote-return-arrow"/>
                </xsl:if>
            </xsl:element>
        </div>
    </xsl:template>


    <xsl:function name="f:last-child-is-block-element" as="xs:boolean">
        <xsl:param name="element" as="element()"/>
        <xsl:variable name="lastChild" select="($element/node())[last()]"/>
        <xsl:sequence select="exists($lastChild/self::table)
                              or exists($lastChild/self::list)
                              or exists($lastChild/self::lg)
                              or exists($lastChild/self::q)"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Set the class and lang attributes of a footnote-paragraph.</xd:short>
    </xd:doc>

    <xsl:template name="footnote-class-lang">
        <xsl:context-item as="element(note)" use="required"/>
        <xsl:variable name="class">
            <xsl:if test="$p.element != 'p'"><xsl:text>par </xsl:text></xsl:if>
            <xsl:text>footnote </xsl:text>
        </xsl:variable>
        <xsl:copy-of select="f:set-class-attribute-with(., $class)"/>
        <xsl:copy-of select="f:generate-lang-attribute(@lang)"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Place a footnote marker.</xd:short>
        <xd:detail>Place a footnote marker in front of the footnote, linking back
        to the location of the footnote in the text.</xd:detail>
    </xd:doc>

    <xsl:template name="footnote-marker">
        <xsl:context-item as="element(note)" use="required"/>
        <span class="fnlabel">
            <a class="noteRef" href="{f:generate-href(.)}src">
                <xsl:value-of select="f:note-marker(.)"/>
            </a>
        </span>
        <xsl:text> </xsl:text>
    </xsl:template>


    <xsl:function name="f:note-marker" as="xs:string">
        <xsl:param name="note" as="element(note)"/>

        <xsl:sequence select="if (f:has-rend-value($note/@rend, 'note-marker'))
                              then f:rend-value($note/@rend, 'note-marker')
                              else if (f:is-footnote($note))
                                   then f:footnote-number($note)
                                   else if ($note/@n)
                                        then $note/@n
                                        else ''"/>
    </xsl:function>


    <xsl:template match="note" mode="footnote-return-arrow">
        <xsl:call-template name="footnote-return-arrow"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Place a footnote return arrow.</xd:short>
        <xd:detail>Place a footnote return arrow after the footnote. If a footnote is referenced multiple times,
        next to the footnotes, generate back-references to each location using lower-case letters.</xd:detail>
    </xd:doc>

    <xsl:template name="footnote-return-arrow">
        <xsl:context-item as="element()" use="required"/>
        <xsl:if test="f:is-set('notes.foot.returnArrow')">

            <!-- Take care to pick the first ancestor for the href, to work correctly with nested footnotes. -->
            <xsl:variable name="note" select="ancestor-or-self::note[1]" as="element(note)"/>
            <xsl:variable name="id" select="$note/@id"/>
            <xsl:variable name="mark" select="f:note-marker($note)"/>

            <xsl:text>&nbsp;</xsl:text>
            <xsl:choose>
                <!-- Do we have multiple reference to this footnote? -->
                <xsl:when test="root(.)//note[@sameAs=$id]">
                    <span class="fnarrow">&uparrow;&nbsp;</span>
                    <a class="fnreturn" href="{f:generate-href($note)}src"
                       title="{f:format-message('msgReturnToNoteMarkInText', map{'mark': $mark || '(a)'})}">
                        <xsl:text>a</xsl:text>
                    </a>
                    <xsl:for-each select="root(.)//note[@sameAs=$id]">
                        <xsl:variable name="letter">
                            <xsl:number value="position() + 1" format="a"/>
                        </xsl:variable>

                        <xsl:text> </xsl:text>
                        <a class="fnreturn" href="{f:generate-href(.)}src"
                           title="{f:format-message('msgReturnToNoteMarkInText', map{'mark': $mark || '(' || $letter || ')'})}">
                            <xsl:value-of select="$letter"/>
                        </a>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <a class="fnarrow" href="{f:generate-href($note)}src"
                       title="{f:format-message('msgReturnToNoteMarkInText', map{'mark': $mark})}">
                        <xsl:text>&uparrow;</xsl:text>
                    </a>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Calculate the footnote number.</xd:short>
        <xd:detail>Calculate the footnote number. This number is based on the position of the note
        in the <code>div</code>, <code>div0</code> or <code>div1</code> element it occurs in.
        Take care to ignore <code>div1</code> elements that appear in embedded quoted text.</xd:detail>
    </xd:doc>

    <xsl:template name="footnote-number">
        <xsl:context-item as="element(note)" use="required"/>
        <xsl:choose>
            <xsl:when test="f:has-rend-value(@rend, 'note-marker')">
                <xsl:value-of select="f:rend-value(@rend, 'note-marker')"/>
            </xsl:when>
            <xsl:when test="f:get-setting('notes.foot.counter') = 'text'">
                <xsl:number
                    level="any"
                    count="note[f:is-footnote(.)][not(@sameAs)]"
                    from="text"/>
            </xsl:when>
            <xsl:when test="ancestor::div">
                <xsl:number
                    level="any"
                    count="note[f:is-footnote(.)][not(@sameAs)]"
                    from="div[not(ancestor::q) and (parent::front or parent::body or parent::back)]"/>
            </xsl:when>
            <xsl:when test="not(ancestor::div1[not(ancestor::q)])">
                <xsl:number
                    level="any"
                    count="note[f:is-footnote(.) and not(@sameAs) and not(ancestor::div1[not(ancestor::q)])]"
                    from="div0[not(ancestor::q)]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:number
                    level="any"
                    count="note[f:is-footnote(.)][not(@sameAs)]"
                    from="div1[not(ancestor::q)]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Calculate the footnote number.</xd:short>
        <xd:detail>wrap the named template <code>footnote-number</code> in a function, so we can
        easily call it.</xd:detail>
    </xd:doc>

    <xsl:function name="f:footnote-number">
        <xsl:param name="note" as="element(note)"/>
        <xsl:for-each select="$note">
            <xsl:call-template name="footnote-number"/>
        </xsl:for-each>
    </xsl:function>


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
            <xsl:if test="not(f:last-child-is-block-element(.))">
                <xsl:call-template name="footnote-return-arrow"/>
            </xsl:if>
        </xsl:element>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle a paragraph in a footnote.</xd:short>
        <xd:detail>Handle a paragraph in a footnote (and apparatus note) by setting the relevant classes, and handling the content as regular content.</xd:detail>
    </xd:doc>

    <xsl:template name="footnote-paragraph">
        <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
        <xsl:variable name="class">
            <xsl:if test="$p.element != 'p'"><xsl:text>par </xsl:text></xsl:if>
            <xsl:text>footnote </xsl:text>
            <xsl:if test="preceding-sibling::p">cont </xsl:if>
            <xsl:if test="ancestor::note[f:is-apparatus-note(.)]">apparatus</xsl:if>
        </xsl:variable>
        <xsl:copy-of select="f:set-class-attribute-with(., $class)"/>
        <xsl:apply-templates/>
    </xsl:template>


    <xd:doc>
        <xd:short>Style a reference to a footnote as a footnote reference.</xd:short>
        <xd:detail>
            <p>Make explicit references to a footnote (marked with <code>@sameAs</code> or
            <code>@type="noteRef"</code>) look the same as automatically generated
            footnote references.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="note[f:is-footnote(.)]" mode="noterefnumber">
        <xsl:param name="sourceNote" as="element(note)"/>
        <a class="pseudoNoteRef" id="{f:generate-id($sourceNote)}src" href="{f:generate-footnote-href(.)}">
            <xsl:if test="f:is-epub()">
                <xsl:attribute name="epub:type" select="'noteref'"/>
            </xsl:if>
            <xsl:call-template name="footnote-number"/>
        </a>
    </xsl:template>


    <xd:doc>
        <xd:short>Insert a reference to a footnote as a plain footnote number.</xd:short>
        <xd:detail>
            <p>Make explicit references to a footnote (<code>@type="noteNumber"</code>) using
            just the unstyled note-number.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="note[f:is-footnote(.)]" mode="unstyled-note-number">
        <a href="{f:generate-footnote-href(.)}">
            <xsl:call-template name="footnote-number"/>
        </a>
    </xsl:template>


    <!--==== TABLE NOTES ====-->

    <xsl:template match="/*[self::TEI.2 or self::TEI]/text//note[f:is-table-note(.)]">
        <a class="noteRef" id="{f:generate-id(.)}src" href="{f:generate-footnote-href(.)}">
            <xsl:value-of select="@n"/>
        </a>
    </xsl:template>

    <xsl:template match="note[f:is-table-note(.)]" mode="noterefnumber">
        <xsl:param name="sourceNote" as="element(note)"/>
        <!-- @sameAs references must be in the same table -->
        <a class="pseudoNoteRef" id="{f:generate-id($sourceNote)}src" href="{f:generate-href(.)}">
            <xsl:value-of select="@n"/>
        </a>
    </xsl:template>


    <!--==== APPARATUS NOTES ====-->

    <xd:doc>
        <xd:short>Handle notes in a text-critical apparatus.</xd:short>
        <xd:detail>Handle notes in a text-critical apparatus (<code>note</code> elements coded with
        attribute <code>@place="apparatus"</code>) by placing a marker in the text. Only include these
        notes when a <code>divGen</code> element is present, calling for their rendition; a text can
        include multiple <code>divGen</code> elements, in which case only the text-critical notes after
        the preceding one are included.</xd:detail>
    </xd:doc>

    <xsl:template match="/*[self::TEI.2 or self::TEI]/text//note[f:is-apparatus-note(.)]">
        <a class="apparatusnotemarker" id="{f:generate-id(.)}src" href="{f:generate-apparatus-note-href(.)}">
            <xsl:attribute name="title"><xsl:value-of select="f:title-from-note(.)"/></xsl:attribute>
            <xsl:value-of select="f:apparatus-note-marker(.)"/>
        </a>
    </xsl:template>


    <xsl:function name="f:title-from-note" as="xs:string">
        <xsl:param name="node" as="element(note)"/>
        <xsl:variable name="string">
            <xsl:apply-templates select="$node/node()" mode="title-from-note"/>
        </xsl:variable>
        <xsl:sequence select="normalize-space($string)"/>
    </xsl:function>

    <xsl:template match="*" mode="title-from-note">
        <xsl:text> </xsl:text>
        <xsl:apply-templates mode="title-from-note"/>
    </xsl:template>

    <xsl:template match="text()" mode="title-from-note">
        <xsl:value-of select="."/>
    </xsl:template>

    <!-- Ignore nested notes -->
    <xsl:template match="note" mode="title-from-note"/>

    <!-- Ignore corrected mistakes -->
    <xsl:template match="choice/sic" mode="title-from-note"/>


    <xd:doc>
        <xd:short>Generate the notes for a text-critical apparatus.</xd:short>
        <xd:detail>Render all text-critical notes preceding the matched <code>divGen</code>, but after the previous <code>divGen</code>, here.</xd:detail>
    </xd:doc>

    <xsl:template match="divGen[@type='apparatus']">
        <div class="div1">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>

            <!-- Determine whether we already have seen a divGen for apparatus notes, by finding its id.
                 If that is the case, we only include the apparatus notes after the previous one! -->
            <xsl:variable name="id" select="generate-id(preceding::divGen[@type='apparatus'][1])"/>
            <xsl:variable name="notes" select="if ($id)
                        then preceding::note[f:is-apparatus-note(.)][generate-id(preceding::divGen[@type='apparatus'][1]) = $id]
                        else preceding::note[f:is-apparatus-note(.)]"/>

            <h2 class="main"><xsl:value-of select="if (count($notes) &lt;= 1) then f:message('msgApparatusNote') else f:message('msgApparatusNotes')"/></h2>

            <xsl:call-template name="handle-apparatus-notes">
                <xsl:with-param name="notes" select="$notes"/>
                <xsl:with-param name="rend" select="@rend"/>
            </xsl:call-template>
        </div>
    </xsl:template>

    <xd:doc>
        <xd:short>Generate the notes for a text-critical apparatus.</xd:short>
        <xd:detail>Render the text-critical notes. This template just selects
        the format to use, based on the configuration and calls the appropriate
        template.</xd:detail>
    </xd:doc>

    <xsl:template name="handle-apparatus-notes">
        <xsl:param name="notes" as="element(note)*"/>
        <xsl:param name="rend" as="xs:string?"/>

        <xsl:variable name="format" select="f:get-setting('notes.apparatus.format')"/>

        <xsl:choose>
            <xsl:when test="$format = 'paragraphs'">
                <xsl:call-template name="handle-apparatus-notes-paragraphs">
                    <xsl:with-param name="notes" select="$notes"/>
                    <xsl:with-param name="rend" select="$rend"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$format = 'block'">
                <xsl:call-template name="handle-apparatus-notes-block">
                    <xsl:with-param name="notes" select="$notes"/>
                    <xsl:with-param name="rend" select="$rend"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="f:log-error('Invalid configuration value for &quot;notes.apparatus.format&quot;: {1}.', ($format))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Format apparatus notes as separate paragraphs.</xd:short>
        <xd:detail>Render the text-critical notes as separate paragraphs in one or more columns.
        This uses a table; the order of the notes will be: [1, 2], [3, 4], ... The splitting works
        under the assumption that the average length of each note is about the same. A smarter way
        of balancing the two columns can only be achieved when actually rendering the columns (in
        the browser or otherwise), using the CSS3 multi-column feature.</xd:detail>
    </xd:doc>

    <xsl:template name="handle-apparatus-notes-paragraphs">
        <xsl:param name="notes" as="element(note)*"/>
        <xsl:param name="rend" as="xs:string?"/>

        <xsl:variable name="columns" select="number(f:rend-value($rend, 'columns'))"/>

        <xsl:choose>
            <xsl:when test="$columns &gt; 1 and count($notes) &gt; 1">
                <xsl:variable name="rows" select="ceiling(count($notes) div $columns)"/>
                <table class="cols{$columns}">
                    <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
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
                <xsl:if test="$p.element != 'p'"><xsl:text>par </xsl:text></xsl:if>
                <xsl:text>footnote apparatus </xsl:text>
            </xsl:variable>
            <xsl:copy-of select="f:set-class-attribute-with(., $class)"/>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:call-template name="apparatus-note-marker"/>
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
            <xsl:call-template name="footnote-return-arrow"/>
        </xsl:element>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle text-critical apparatus notes with embedded paragraphs.</xd:short>
        <xd:detail>Insert an apparatus note with embedded paragraphs. These need to be handled slightly differently
        from apparatus notes that do not contain paragraphs, to ensure the generated HTML is valid.</xd:detail>
    </xd:doc>

    <xsl:template match="note[@place='apparatus' and p]" mode="apparatus">
        <xsl:element name="{$p.element}">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:variable name="class">
                <xsl:if test="$p.element != 'p'"><xsl:text>par </xsl:text></xsl:if>
                <xsl:text>footnote apparatus</xsl:text>
            </xsl:variable>
            <xsl:copy-of select="f:set-class-attribute-with(., $class)"/>

            <xsl:call-template name="apparatus-note-marker"/>
            <xsl:apply-templates select="*[1]" mode="footfirst"/>
            <xsl:if test="count(*) = 1">
                <xsl:call-template name="footnote-return-arrow"/>
            </xsl:if>
        </xsl:element>
        <xsl:apply-templates select="*[position() > 1 and position() != last()]" mode="footnotes"/>
        <xsl:apply-templates select="*[position() > 1 and position() = last()]" mode="footlast"/>
    </xsl:template>


    <xsl:template match="note[@place='apparatus' and @sameAs]" mode="apparatus"/>


    <xsl:template name="apparatus-note-marker">
        <xsl:context-item as="element(note)" use="required"/>

        <span class="fnlabel">
            <a class="apparatusnotemarker" href="{f:generate-href(.)}src">
                <xsl:value-of select="f:apparatus-note-marker(.)"/>
            </a>
        </span>
    </xsl:template>


    <xsl:function name="f:apparatus-note-marker" as="xs:string">
        <xsl:param name="note" as="element()"/>

        <xsl:sequence select="if (f:has-rend-value($note/@rend, 'note-marker'))
                              then f:rend-value($note/@rend, 'note-marker')
                              else f:get-setting('notes.apparatus.noteMarker')"/>
    </xsl:function>

    <xsl:function name="f:apparatus-return-marker" as="xs:string">
        <xsl:param name="note" as="element()"/>

        <xsl:sequence select="if (f:has-rend-value($note/@rend, 'return-marker'))
                              then f:rend-value($note/@rend, 'return-marker')
                              else f:get-setting('notes.apparatus.returnMarker')"/>
    </xsl:function>

    <xsl:template match="note[f:is-apparatus-note(.)]" mode="noterefnumber">
        <xsl:param name="sourceNote" as="element(note)"/>
        <a class="apparatusnotemarker" id="{f:generate-id($sourceNote)}src" href="{f:generate-apparatus-note-href(.)}">
            <xsl:attribute name="title"><xsl:value-of select="f:title-from-note(.)"/></xsl:attribute>
            <xsl:value-of select="f:apparatus-note-marker($sourceNote)"/>
        </a>
    </xsl:template>


    <xd:doc>
        <xd:short>Format apparatus notes as a single block.</xd:short>
        <xd:detail><p>Format apparatus notes as a single block. A complicating factor here is that some notes do contain
        paragraphs, and we want to preserve the paragraph break in that case, starting the multi-paragraph note after the preceding note
        on the same line, start a new line for the following paragraph of the note, and then have the following note follow the
        last paragraph of the multi-paragraph note. To achieve this, first collect the content of all the notes in a single list,
        indicating where the paragraph breaks should remain, and then group them back into paragraphs.</p>

        <p>As part of this action, we copy elements into a temporary structure, which we also use to retain the ids of the
        original notes, so cross-references can be resolved.</p></xd:detail>
    </xd:doc>

    <xsl:template name="handle-apparatus-notes-block">
        <xsl:param name="notes" as="element(note)*"/>
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
                        <xsl:if test="$p.element != 'p'"><xsl:text>par </xsl:text></xsl:if>
                        <xsl:text>apparatus </xsl:text>
                    </xsl:variable>
                    <xsl:copy-of select="f:set-class-attribute-with(., $class)"/>

                    <xsl:apply-templates select="current-group()"/>
                </xsl:element>
            </xsl:for-each-group>
        </div>
    </xsl:template>


    <xsl:template match="note[@place='apparatus' and not(p)]" mode="collect-apparatus">
        <tmp:span id="{f:generate-id(.)}">
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


    <xsl:template match="note[@place='apparatus' and @sameAs]" priority="1" mode="collect-apparatus"/>


    <xsl:template match="p" mode="collect-apparatus-first">
        <tmp:span id="{f:generate-id(ancestor::note[1])}">
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
        <span class="apparatusnote">
            <xsl:if test="@id">
                <xsl:attribute name="id" select="@id"/>
                <a class="apparatusnotemarker">
                    <xsl:attribute name="href">#<xsl:value-of select="@id"/>src</xsl:attribute>
                    <xsl:attribute name="title"><xsl:value-of select="f:message('msgReturnToSourceLocation')"/></xsl:attribute>
                    <xsl:value-of select="f:apparatus-return-marker(.)"/>
                </a>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
        <xsl:text> </xsl:text>
    </xsl:template>


    <xsl:template match="tmp:br"/>


</xsl:stylesheet>
