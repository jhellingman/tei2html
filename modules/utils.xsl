<!DOCTYPE xsl:stylesheet [

    <!ENTITY mdash       "&#x2014;">
    <!ENTITY ndash       "&#x2013;">
    <!ENTITY hellip      "&#x2026;">

]>
<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:f="urn:stylesheet-functions"
    exclude-result-prefixes="f xs xd">


    <xd:doc type="stylesheet">
        <xd:short>Utility templates and functions, used by tei2html</xd:short>
        <xd:detail>This stylesheet contains utility templates and functions, used by tei2html and tei2epub.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2017, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Generate a stable id for a node.</xd:short>
        <xd:detail>
            <p>We want to generate ids that are slightly more stable than those generated by
            <code>generate-id()</code>. The general idea is to use an explicit id if that is present, and
            otherwise create an id based on the first ancestor node that does have an id. If,
            for example the third paragraph of a division with id '<code>ch2</code>' has no id of itself,
            we generate: "<code>ch2_p_3</code>" as an id. The second note in this division would receive
            the id "<code>ch2_note_2</code>".</p>

            <table>
                <tr><th>Language    </th><th>Safe ID syntax </th></tr>
                <tr><td>HTML:       </td><td><code>[A-Za-z][A-Za-z0-9_:.-]*</code></td></tr>
                <tr><td>CSS:        </td><td><code>-?[_a-zA-Z]+[_a-zA-Z0-9-]*</code></td></tr>
                <tr><td>Combined:   </td><td><code>[A-Za-z][A-Za-z0-9_-]*</code></td></tr>
            </table>
        </xd:detail>
        <xd:param name="node">The node for which the stable id is generated.</xd:param>
    </xd:doc>

    <xsl:function name="f:generate-stable-id" as="xs:string">
        <xsl:param name="node" as="node()"/>

        <xsl:variable name="base" select="$node/ancestor-or-self::*[@id][1]"/>
        <xsl:variable name="base" select="if ($base) then $base else ($node/ancestor-or-self::*)[1]"/>
        <xsl:variable name="baseid" select="if ($base/@id) then $base/@id else ''" as="xs:string"/>
        <xsl:variable name="name" select="local-name($node)" as="xs:string"/>
        <xsl:variable name="count" select="count($base//*[local-name() = $name] except $node/following::*[local-name() = $name])"/>
        <xsl:variable name="id" select="$baseid || '_' || $name || '_' || $count"/>

        <xsl:copy-of select="f:log-info('Generated ID: {1} from {2}-th [{3}] child of [{4}].', ($id, string($count), $name, local-name($base)))"/>

        <xsl:value-of select="$id"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate an <code>id</code>-value.</xd:short>
        <xd:detail>
            <p>Generate an <code>id</code>-value for a node.</p>
            <p>The generated id will re-use the existing <code>id</code> attribute if present, or use the <code>generate-id()</code> function otherwise.
            Such generated id's will be prefixed with the letter 'x'</p>
        </xd:detail>
        <xd:param name="node" type="element()">The node for which the <code>id</code>-value is generated.</xd:param>
    </xd:doc>

    <xsl:function name="f:generate-id" as="xs:string">
        <xsl:param name="node" as="element()"/>
        <xsl:value-of select="if ($node/@id) then $node/@id else 'x' || generate-id($node)"/>
    </xsl:function>


    <xsl:function name="f:needs-id" as="xs:boolean">
        <xsl:param name="node" as="element()"/>

        <xsl:choose>
            <!-- Do we have a reference to it -->
            <xsl:when test="root($node)//ref[@target = $node/@id]"><xsl:value-of select="true()"/></xsl:when>
            <!-- Division that appears in a table of contents -->
            <xsl:when test="name($node) = ('div', 'div0', 'div1', 'div2', 'div3', 'div4', 'div5', 'div6') and root($node)//divGen[@type='toc']"><xsl:value-of select="true()"/></xsl:when>

            <xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
        </xsl:choose>

        <!-- Image that appears in a list of illustrations -->
        <!-- Correction that appears in a list of corrections -->
        <!-- External reference that appears in a list of external references -->
        <!-- Footnotes -->

    </xsl:function>


    <xd:doc>
        <xd:short>Generate an <code>id</code>-value.</xd:short>
        <xd:detail>
            <p>Generate an <code>id</code>-value for a node.</p>
            <p>The generated id will use <code>f:generate-id</code> and append the position.</p>
        </xd:detail>
        <xd:param name="node" type="element()">The node for which the <code>id</code>-value is generated.</xd:param>
        <xd:param name="position" type="xs:integer">A value appended after the generated <code>id</code>.</xd:param>
    </xd:doc>

    <xsl:function name="f:generate-nth-id" as="xs:string">
        <xsl:param name="node" as="element()"/>
        <xsl:param name="position" as="xs:integer"/>
        <xsl:value-of select="f:generate-id($node) || '-' || $position"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Copy a node-tree while stripping al ids.</xd:short>
        <xd:detail>Copy a node-tree while stripping al ids. This allows us to use content from the source document multiple times,
        without having duplicate ids (which we normally copy from the source document, if present) in the output.</xd:detail>
    </xd:doc>

    <xsl:function name="f:copy-without-ids">
        <xsl:param name="nodes"/>
        <xsl:apply-templates select="$nodes" mode="copy-without-ids"/>
    </xsl:function>

    <xsl:template match="@id" mode="copy-without-ids"/>

    <xsl:template match="@*|node()" mode="copy-without-ids">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="copy-without-ids"/>
        </xsl:copy>
    </xsl:template>


    <xd:doc>
        <xd:short>Copy a node-tree while prefixing all ids.</xd:short>
        <xd:detail>Copy a node-tree while prefixing al ids with a given prefix. This allows us to use content from the source document multiple times,
        without having duplicate ids (which we normally copy from the source document, if present) in the output.</xd:detail>
    </xd:doc>

    <xsl:function name="f:copy-with-id-prefix">
        <xsl:param name="nodes"/>
        <xsl:param name="id-prefix" as="xs:string"/>

        <xsl:apply-templates select="$nodes" mode="copy-with-id-prefix">
            <xsl:with-param name="id-prefix" select="$id-prefix" as="xs:string" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:function>

    <xsl:template match="@id" mode="copy-with-id-prefix">
        <xsl:param name="id-prefix" as="xs:string" tunnel="yes"/>
        <xsl:attribute name="id" select="$id-prefix || ."/>
    </xsl:template>

    <xsl:template match="@*|node()" mode="copy-with-id-prefix">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="copy-with-id-prefix"/>
        </xsl:copy>
    </xsl:template>


    <!--====================================================================-->
    <!-- Close and (re-)open paragraphs -->

    <xd:doc>
        <xd:short>Close a <code>p</code>-element in the output.</xd:short>
        <xd:detail><p>To accommodate the differences between the TEI and HTML paragraph model,
        we sometimes need to close (and reopen) paragraphs, as various elements
        are not allowed inside <code>p</code>-elements in HTML.</p>

        <p>The following cases need to be taken into account:</p>

        <ul>
            <li>We use the variable <code>$p.element</code> but it is not set the value <code>'p'</code></li>
            <li>We are actually inside a <code>p</code> element.</li>
            <li>We do not locally override the variable <code>$p.element</code>, for example when we need to nest special elements
            in a <code>p</code> element (see template handle-paragraph in block.xsl).</li>
        </ul>

        </xd:detail>
    </xd:doc>

    <xsl:function name="f:needs-close-par" as="xs:boolean">
        <xsl:param name="element" as="element()"/>

        <xsl:variable name="output_p" select="$p.element = 'p'" as="xs:boolean"/>
        <xsl:variable name="parent_p" select="$element/parent::p or $element/parent::note" as="xs:boolean"/>
        <xsl:variable name="parent_does_not_contain_ditto" select="not($element/parent::p[.//ditto] or $element/parent::note[.//ditto])" as="xs:boolean"/>

        <xsl:value-of select="$output_p and $parent_p and $parent_does_not_contain_ditto"/>
        <!--<xsl:value-of select="false()"/>-->
    </xsl:function>

    <xsl:template name="closepar">
        <!-- insert </p> to close current paragraph as tables in paragraphs are illegal in HTML -->
        <xsl:if test="f:needs-close-par(.)">
            <xsl:text disable-output-escaping="yes">&lt;/p&gt;</xsl:text>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Re-open a <code>p</code>-element in the output.</xd:short>
        <xd:detail>Re-open a previously closed <code>p</code>-element in the output.
        This generates an extra <code>p</code>-element in the output.</xd:detail>
    </xd:doc>

    <xsl:template name="reopenpar">
        <xsl:if test="f:needs-close-par(.)">
            <xsl:text disable-output-escaping="yes">&lt;p&gt;</xsl:text>
        </xsl:if>
    </xsl:template>


    <xsl:function name="f:show-debug-tags">
        <xsl:param name="node" as="node()"/>

        <xsl:if test="f:is-set('debug')">
            <span class="showtags">
                <xsl:text>&lt;</xsl:text>
                <xsl:value-of select="name($node)"/>
                <xsl:if test="$node/@id">
                    <xsl:text> id='</xsl:text><xsl:value-of select="$node/@id"/><xsl:text>'</xsl:text>
                </xsl:if>
                <xsl:text>&gt;</xsl:text>
            </span>
        </xsl:if>
    </xsl:function>


    <!--====================================================================-->
    <!-- Language tagging -->

    <xd:doc>
        <xd:short>Determine the natural language used in the indicated node.</xd:short>
    </xd:doc>

    <xsl:function name="f:get-current-lang" as="xs:string">
        <xsl:param name="node" as="node()"/>
        <xsl:variable
            name="current-lang"
            select="($node/ancestor-or-self::*/@lang | $node/ancestor-or-self::*/@xml:lang)[last()]"/>
        <xsl:value-of select="if ($current-lang) then $current-lang else f:get-document-lang()"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine the natural language indicated for the entire document.</xd:short>
    </xd:doc>

    <xsl:function name="f:get-document-lang" as="xs:string">
        <xsl:value-of select="$root/*[self::TEI.2 or self::TEI]/@lang | $root/*[self::TEI.2 or self::TEI]/@xml:lang"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate a lang attribute.</xd:short>
        <xd:detail>Generate a lang attribute. Depending on the output method (HTML or XML),
        either the <code>lang</code> or the <code>xml:lang</code> attribute, or both, will
        be set on the output element if a lang attribute is present in the source.</xd:detail>
    </xd:doc>

    <xsl:function name="f:generate-lang-attribute" as="attribute()*">
        <xsl:param name="lang" as="xs:string?"/>

        <xsl:if test="$lang">
            <xsl:choose>
                <xsl:when test="$outputMethod = 'xhtml'">
                    <xsl:if test="f:is-html()">
                        <xsl:attribute name="lang" select="f:fix-lang($lang)"/>
                    </xsl:if>
                    <xsl:attribute name="xml:lang" select="f:fix-lang($lang)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="lang" select="f:fix-lang($lang)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>


    <xd:doc>
        <xd:short>Normalize a language attribute.</xd:short>
        <xd:detail>Normalize language attributes used in the output to match
        valid language codes (see https://tools.ietf.org/html/rfc5646).</xd:detail>
    </xd:doc>

    <xsl:function name="f:fix-lang" as="xs:string">
        <xsl:param name="lang" as="xs:string"/>

        <xsl:choose>
            <!-- Strip endings with -x-..., such as in la-x-bio -->
            <xsl:when test="matches($lang, '^[a-z]{2}-x-')">
                <xsl:value-of select="substring($lang, 1, 2)"/>
            </xsl:when>
            <!-- Strip endings with -1900, such as in nl-1900 -->
            <xsl:when test="matches($lang, '^[a-z]{2}-\d{4}')">
                <xsl:value-of select="substring($lang, 1, 2)"/>
            </xsl:when>
            <!-- Fix case of language + country code (e.g. nl-BE) -->
            <xsl:when test="matches($lang, '^[a-z]{2}-[A-Za-z]{2}$')">
                <xsl:value-of select="substring($lang, 1, 3) || upper-case(substring($lang, 4, 2))"/>
            </xsl:when>
            <!-- Avoid 2-letter language + 4-letter script code, if in pg-compliant mode -->
            <xsl:when test="f:is-set('pg.compliant') and matches($lang, '^[a-z]{2}-[A-Za-z]{4}$')">
                <!-- Use 'und' to prevent browsers from automatically selecting the font for the default script -->
                <xsl:value-of select="'und'"/>
            </xsl:when>
            <!-- Fix case of 2-letter language + script code (e.g. zh-Latn) -->
            <xsl:when test="matches($lang, '^[a-z]{2}-[A-Za-z]{4}$')">
                <xsl:value-of select="substring($lang, 1, 3) || upper-case(substring($lang, 4, 1)) || lower-case(substring($lang, 5, 3))"/>
            </xsl:when>
            <!-- Strip script code of 3-letter language + script code, if in pg-compliant mode -->
            <xsl:when test="f:is-set('pg.compliant') and matches($lang, '^[a-z]{3}-[A-Za-z]{4}$')">
                <xsl:value-of select="substring($lang, 1, 3)"/>
            </xsl:when>
            <!-- Fix case of 3-letter language + script code (e.g. grc-Latn) -->
            <xsl:when test="matches($lang, '^[a-z]{3}-[A-Za-z]{4}$')">
                <xsl:value-of select="substring($lang, 1, 4) || upper-case(substring($lang, 5, 1)) || lower-case(substring($lang, 6, 3))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$lang"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <!--====================================================================-->
    <!-- Shortcut for both id and language tagging -->

    <xd:doc>
        <xd:short>Generate both a lang and an id attribute.</xd:short>
    </xd:doc>

    <xsl:function name="f:set-lang-id-attributes" as="attribute()*">
        <xsl:param name="node" as="element()"/>

        <xsl:attribute name="id" select="f:generate-id($node)"/>
        <xsl:copy-of select="f:generate-lang-attribute($node/@lang)"/>
    </xsl:function>



    <xd:doc>
        <xd:short>Determine a node is a division.</xd:short>
    </xd:doc>

    <xsl:function name="f:is-division" as="xs:boolean">
        <xsl:param name="node"/>
        <xsl:sequence select="local-name($node) = ('div', 'div0', 'div1', 'div2', 'div3', 'div4', 'div5', 'div6')"/>
    </xsl:function>


    <!--====================================================================-->
    <!-- Generate labels for heads in the correct language -->

    <xd:doc>
        <xd:short>Translate the <code>type</code>-attribute of a division.</xd:short>
        <xd:detail>
            <p>Translate the <code>type</code>-attribute of a division to a string in the currently active language.</p>
        </xd:detail>
        <xd:param name="type" type="string">The value of the <code>type</code>-attribute.</xd:param>
    </xd:doc>

    <xsl:function name="f:translate-div-type" as="xs:string">
        <xsl:param name="type" as="xs:string"/>
        <xsl:variable name="type" select="lower-case($type)" as="xs:string"/>

        <xsl:choose>
            <xsl:when test="$type=''"><xsl:value-of select="''"/></xsl:when>
            <xsl:when test="$type='appendix'"><xsl:value-of select="f:message('msgAppendix')"/></xsl:when>
            <xsl:when test="$type='chapter'"><xsl:value-of select="f:message('msgChapter')"/></xsl:when>
            <xsl:when test="$type='part'"><xsl:value-of select="f:message('msgPart')"/></xsl:when>
            <xsl:when test="$type='book'"><xsl:value-of select="f:message('msgBook')"/></xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="f:log-warning('Division type: {1} not understood.', ($type))"/>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine the level of the division (either by counting its parents or looking at its name).</xd:short>
    </xd:doc>

    <xsl:function name="f:div-level" as="xs:integer">
        <xsl:param name="div" as="node()"/>

        <xsl:choose>
            <xsl:when test="local-name($div) = 'div'">
                <xsl:choose>
                    <xsl:when test="$div/ancestor::q">
                        <xsl:value-of select="count($div/ancestor::div[ancestor::q])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="count($div/ancestor::div) + 1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="local-name($div) = ('div0', 'div1', 'div2', 'div3', 'div4', 'div5', 'div6')">
                <xsl:choose>
                    <xsl:when test="$div/ancestor::q">
                        <xsl:value-of select="count($div/ancestor::*[self::div0 or self::div1 or self::div2 or self::div3 or self::div4 or self::div5 or self::div6][ancestor::q])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="count($div/ancestor::*[self::div0 or self::div1 or self::div2 or self::div3 or self::div4 or self::div5 or self::div6]) + 1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="f:log-error('Node {1} is not a division.', (local-name($div)))"/>
                <xsl:value-of select="1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xd:doc>
        <xd:short>List of contributor roles and related OPF-codes and message ids.</xd:short>
        <xd:detail>
            <p>The list used was taken from the OPF Standard, 2.0, section 2.2.6
            [https://www.openebook.org/2007/opf/OPF_2.0_final_spec.html], which in turn was derived from the
            MARC Code List for Relators [https://www.loc.gov/marc/relators/relaterm.html] and extended.</p>
        </xd:detail>
    </xd:doc>

    <xsl:variable name="contributorRoles">
        <roles>
            <role code="adp" message="msgAdaptor">Adaptor</role>
            <role code="aft" message="msgAuthorOfAfterword">Author of afterword</role>
            <role code="aft" message="msgAuthorOfColophon">Author of colophon</role>
            <role code="aft" message="msgAuthorOfPostface">Author of postface</role>
            <role code="ann" message="msgAnnotator">Annotator</role>
            <role code="ant" message="msgBibliographicAntecedent">Bibliographic antecedent</role>
            <role code="aqt" message="msgAuthorInQuotations">Author in quotations</role>
            <role code="aqt" message="msgAuthorInTextExtracts">Author in text extracts</role>
            <role code="arr" message="msgArranger">Arranger</role>
            <role code="art" message="msgArtist">Artist</role>
            <role code="asn" message="msgAssociatedName">Associated name</role>
            <role code="aui" message="msgAuthorOfForeword">Author of foreword</role>
            <role code="aui" message="msgAuthorOfIntroduction">Author of introduction</role>
            <role code="aui" message="msgAuthorOfPreface">Author of preface</role>
            <role code="aut" message="msgAuthor">Author</role>
            <role code="bkp" message="msgBookProducer">Book producer</role>
            <role code="clb" message="msgCollaborator">Collaborator</role>
            <role code="clb" message="msgContributor">Contributor</role>
            <role code="cmm" message="msgCommentator">Commentator</role>
            <role code="dsr" message="msgDesigner">Designer</role>
            <role code="edt" message="msgEditor">Editor</role>
            <role code="egr" message="msgEngraver">Engraver</role>
            <role code="ill" message="msgIllustrator">Illustrator</role>
            <role code="ill" message="msgIllustrator">Illustration</role>
            <role code="ill" message="msgIllustrator">Illustrations</role>
            <role code="lyr" message="msgLyricist">Lyricist</role>
            <role code="mdc" message="msgMetadataContact">Metadata contact</role>
            <role code="mus" message="msgMusician">Musician</role>
            <role code="nrt" message="msgNarrator">Narrator</role>
            <role code="oth" message="msgOther">Other</role>
            <role code="pht" message="msgPhotographer">Photographer</role>
            <role code="prt" message="msgPrinter">Printer</role>
            <role code="red" message="msgRedactor">Redactor</role>
            <role code="rev" message="msgReviewer">Reviewer</role>
            <role code="spn" message="msgSponsor">Sponsor</role>
            <role code="ths" message="msgThesisAdvisor">Thesis advisor</role>
            <role code="trc" message="msgTranscriber">Transcriber</role>
            <role code="trc" message="msgTranscriber">Transcription</role>
            <role code="trl" message="msgTranslator">Translation</role>
            <role code="trl" message="msgTranslator">Translator</role>
        </roles>
    </xsl:variable>

    <xsl:function name="f:translate-resp" as="xs:string">
        <xsl:param name="resp" as="xs:string"/>

        <xsl:variable name="message" select="$contributorRoles//*[.=$resp]/@message"/>
        <xsl:copy-of select="f:log-debug('Translating contributor role: {1} to {2}', ($resp, $message))"/>
        <xsl:value-of select="if ($message) then f:message($message) else f:message('msgUnknown')"/>
    </xsl:function>

    <xsl:function name="f:translate-resp-code" as="xs:string">
        <xsl:param name="resp" as="xs:string"/>

        <xsl:variable name="code" select="$contributorRoles//*[.=$resp]/@code"/>
        <xsl:copy-of select="f:log-debug('Translating contributor role: {1} to {2}', ($resp, $code))"/>
        <xsl:value-of select="if ($code) then $code else 'oth'"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Strip all diacritics from a string.</xd:short>
        <xd:detail>
            <p>Strip all diacritics from a string, by first putting the string in the Unicode 'NFKD' normalization form, and
            then removing all characters in the category diacritic mark.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:strip-diacritics" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:value-of select="replace(normalize-unicode($string, 'NFKD'), '\p{M}' ,'')"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine whether an element is rendered in the output.</xd:short>
        <xd:detail>
            <p>Determine whether an element is rendered in the output, based on the presence of <code>display(none)</code> in the <code>@rend</code>
            attribute of this element or one of its ancestors.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:is-rendered" as="xs:boolean">
        <xsl:param name="node" as="node()"/>
        <xsl:sequence select="not($node/ancestor-or-self::*[f:rend-value(./@rend, 'display') = 'none'])"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine whether an element is rendered inline in the output.</xd:short>
        <xd:detail>
            <p>Determine whether an element is rendered inline (that is, not as a block-level element) in the output, based on the presence of <code>position(inline)</code> in the <code>@rend</code>
            attribute of this element. Note that this only takes into account the <code>@rend</code> attribute, not the default value for <code>display</code> of an HTML element in the output.</p>
        </xd:detail>
    </xd:doc>


    <!-- TODO: deprecate use of 'position' for inline. -->

    <xsl:function name="f:is-inline" as="xs:boolean">
        <xsl:param name="node" as="element()"/>
        <xsl:sequence select="$node/@rend = 'inline' or f:rend-value($node/@rend, 'position') = 'inline' or f:rend-value($node/@rend, 'display') = 'inline'"/>
    </xsl:function>


    <xsl:function name="f:is-block" as="xs:boolean">
        <xsl:param name="node" as="element()"/>
        <xsl:sequence select="$node/@rend = 'block' or f:rend-value($node/@rend, 'display') = 'block' or f:has-class($node/@rend, 'block', 'q')"/>
    </xsl:function>


    <!-- hidden: not visible, but takes up space. If an ancestor is hidden, we are hidden as well. -->

    <xsl:function name="f:is-hidden" as="xs:boolean">
        <xsl:param name="node" as="element()"/>
        <xsl:sequence select="exists($node/ancestor-or-self::*[f:rend-value(./@rend, 'visibility') = 'hidden'])"/>
    </xsl:function>


    <!-- not-displayed: not visible and not taking up space. If an ancestor is not displayed, we are not displayed as well.  -->
    <!-- Sometimes content marked as hidden is still displayed via the align-with rend attribute! -->

    <xsl:function name="f:is-not-displayed" as="xs:boolean">
        <xsl:param name="node" as="element()"/>
        <xsl:sequence select="exists($node/ancestor-or-self::*[f:rend-value(./@rend, 'display') = 'none' and not(f:used-in-align-with(.))])"/>
    </xsl:function>

    <xsl:function name="f:used-in-align-with" as="xs:boolean">
        <xsl:param name="node" as="element()"/>
        <xsl:sequence select="exists($root//*[f:rend-value(./@rend, 'align-with') = $node/@id])"/>
    </xsl:function>

    <xsl:function name="f:is-pdf" as="xs:boolean">
        <xsl:sequence select="$optionPrinceMarkup = 'Yes'"/>
    </xsl:function>

    <xsl:function name="f:is-epub" as="xs:boolean">
        <xsl:sequence select="$outputFormat = 'epub'"/>
    </xsl:function>

    <xsl:function name="f:is-html" as="xs:boolean">
        <xsl:sequence select="$outputFormat = ('html', 'html5', 'xhtml', 'xhtml5')"/>
    </xsl:function>

    <xsl:function name="f:is-html5" as="xs:boolean">
        <xsl:sequence select="$outputFormat = ('html5', 'xhtml5')"/>
    </xsl:function>

    <xd:doc>
        <xd:short>Classify the content of an element.</xd:short>
        <xd:detail>
            <p>Try to classify the content of an element, based on a regular expression. This will be used to set a class-attribute on the generated HTML element. The following types will be recognized:</p>

            <table>
                <tr><th>Type        </th><th>Code       </th><th>Description </th></tr>

                <tr><td>Empty       </td><td>ccEmpty    </td><td>Empty or nearly empty (whitespace only)</td></tr>
                <tr><td>Dash        </td><td>ccDash     </td><td>Dash, ellipsis or other marker that indicates no value is available</td></tr>
                <tr><td>Numeric     </td><td>ccNum      </td><td>Numeric value</td></tr>
                <tr><td>Percentage  </td><td>ccPct      </td><td>Percentage (i.e., followed by a percent sign)</td></tr>
                <tr><td>Amount      </td><td>ccAmt      </td><td>Monetary amount (i.e., preceded or followed by a currency sign)</td></tr>
                <tr><td>Text        </td><td>ccTxt      </td><td>Alpha-numeric content, not being one of the above.</td></tr>
                <!--
                <tr><td>Date        </td><td>ccDate     </td><td>A calendar date</td></tr>
                <tr><td>Time        </td><td>ccTime     </td><td>A time</td></tr>
                <tr><td>Date + Time </td><td>ccDttm     </td><td>A date and time</td></tr>
                -->
                <tr><td>Other       </td><td>ccOther    </td><td>Anything else.</td></tr>
            </table>

            <p>The content of (embedded) notes will ignored, and if the element already has a <code>@rend</code> attribute with a relevant type, and empty string will be returned.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:classify-content" as="xs:string">
        <xsl:param name="node" as="element()"/>

        <!-- flatten content and strip notes -->
        <xsl:variable name="string">
            <xsl:apply-templates select="$node" mode="flatten-textual-content"/>
        </xsl:variable>
        <xsl:variable name="string" select="string-join($string)"/>
        <xsl:variable name="string" select="normalize-space($string)"/>

        <xsl:sequence select="if (f:has-content-classification($node))  then ''
            else if (not($string) or $string = '')                      then 'ccEmpty'
            else if (f:is-dash-like($string))                           then 'ccDash'
            else if (f:is-unicode-number($string))                      then 'ccNum'
            else if (f:is-unicode-percentage($string))                  then 'ccPct'
            else if (f:is-unicode-amount($string))                      then 'ccAmt'
            else if (f:is-unicode-text($string))                        then 'ccTxt'
            else 'ccOther'"/>
    </xsl:function>

    <xsl:function name="f:has-content-classification" as="xs:boolean">
        <xsl:param name="node" as="element()"/>

        <xsl:variable name="name" select="name($node)"/>

        <xsl:sequence select="
               f:has-class($node/@rend, 'alignDecimalIntegerPart', $name)
            or f:has-class($node/@rend, 'alignDecimalFractionPart', $name)
            or f:has-class($node/@rend, 'ccEmpty', $name)
            or f:has-class($node/@rend, 'ccDash', $name)
            or f:has-class($node/@rend, 'ccNum', $name)
            or f:has-class($node/@rend, 'ccPct', $name)
            or f:has-class($node/@rend, 'ccAmt', $name)
            or f:has-class($node/@rend, 'ccTxt', $name)
            or f:has-class($node/@rend, 'ccOther', $name)
            "/>
    </xsl:function>


    <xsl:template match="note" mode="flatten-textual-content"/>

    <xsl:template match="choice[corr]" mode="flatten-textual-content">
        <xsl:apply-templates select="corr" mode="flatten-textual-content"/>
    </xsl:template>

    <xsl:template match="seg[@copyOf]" mode="flatten-textual-content">
        <xsl:apply-templates select="//*[@id = current()/@copyOf]" mode="flatten-textual-content"/>
    </xsl:template>


    <xsl:variable name="unicode-number-pattern" select="'^\s?(((\p{Nd}+[.,])*\p{Nd}+)(([.,]\p{Nd}+)?(\p{No})?)|(\p{No})|([.,]\p{Nd}+))\s?$'"/>
    <xsl:variable name="unicode-percentage-pattern" select="'^\s?(((\p{Nd}+[.,])*\p{Nd}+)(([.,]\p{Nd}+)?(\p{No})?)|(\p{No})|([.,]\p{Nd}+))\s*[%&#x2030;&#x2031;&#x066A;&#xFF05;&#xFE6A;]\s?$'"/>
    <xsl:variable name="unicode-amount-pattern-1" select="'^\s*\p{Sc}\s*(((\p{Nd}+[.,])*\p{Nd}+)(([.,]\p{Nd}+)?(\p{No})?)|(\p{No})|([.,]\p{Nd}+))\s*$'"/>
    <xsl:variable name="unicode-amount-pattern-2" select="'^\s*(((\p{Nd}+[.,])*\p{Nd}+)(([.,]\p{Nd}+)?(\p{No})?)|(\p{No})|([.,]\p{Nd}+))\s*\p{Sc}\s*$'"/>

    <xsl:function name="f:is-unicode-number" as="xs:boolean">
        <xsl:param name="string"/>
        <xsl:sequence select="matches(string($string), $unicode-number-pattern, 'i')"/>
    </xsl:function>

    <xsl:function name="f:is-unicode-percentage" as="xs:boolean">
        <xsl:param name="string"/>
        <xsl:sequence select="matches(string($string), $unicode-percentage-pattern, 'i')"/>
    </xsl:function>

    <xsl:function name="f:is-unicode-amount" as="xs:boolean">
        <xsl:param name="string"/>
        <xsl:sequence select="matches(string($string), $unicode-amount-pattern-1, 'i')
                           or matches(string($string), $unicode-amount-pattern-2, 'i')"/>
    </xsl:function>

    <xsl:function name="f:is-unicode-text" as="xs:boolean">
        <xsl:param name="string"/>
        <xsl:sequence select="matches(string($string), '\p{L}+', 'i')"/>
    </xsl:function>

    <xsl:function name="f:is-dash-like" as="xs:boolean">
        <xsl:param name="string"/>
        <xsl:sequence select="matches(string($string), '^([&mdash;&ndash;&hellip;-]|(\.\.\.+))$', 'i')"/>
    </xsl:function>


</xsl:stylesheet>
