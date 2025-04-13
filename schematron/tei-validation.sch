<?xml version="1.0"?>
<sch:schema
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    queryBinding="xslt3">

    <sch:ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
    <sch:ns uri="urn:stylesheet-functions" prefix="f"/>

    <xsl:include href="../modules/numbers.xsl"/>

    <xsl:function name="f:is-valid-uuid" as="xs:boolean">
        <xsl:param name="id"/>
        <xsl:variable name="uuidPattern"
            select="'^urn:uuid:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'"/>
        <xsl:sequence select="matches($id, $uuidPattern)"/>
    </xsl:function>

    <xsl:function name="f:strip-hash" as="xs:string">
        <xsl:param name="target" as="xs:string"/>
        <xsl:value-of select="if (starts-with($target, '#')) then substring($target, 2) else $target"/>
    </xsl:function>

    <xsl:function name="f:articles-for-lang" as="xs:string*">
      <xsl:param name="lang" as="xs:string?"/>
      <xsl:variable name="base-lang" select="lower-case(tokenize($lang, '-')[1])"/>
      <xsl:variable name="article-map" as="map(xs:string, xs:string*)"
        select="map {
          'en': ('a', 'an', 'the'),
          'fr': ('le', 'la', 'les', 'l’'),
          'de': ('der', 'die', 'das', 'ein', 'eine', 'einer', 'eines'),
          'nl': ('de', 'het', 'een', '’t', '’n', 'eene')
        }"/>
      <xsl:sequence select="if ($base-lang) then map:get($article-map, $base-lang) else ''"/>
    </xsl:function>

    <sch:pattern id="report-title">
      <sch:rule context="//tei:titleStmt">
        <sch:report role="info" test="tei:title">Title: <sch:value-of select="tei:title"/></sch:report>
      </sch:rule>
    </sch:pattern>

    <sch:pattern id="report-author">
      <sch:rule context="//tei:titleStmt">
        <sch:report role="info" test="tei:author">Author: <sch:value-of select="tei:author"/></sch:report>
      </sch:rule>
    </sch:pattern>


    <sch:pattern id="is-tei-file">
      <sch:rule context="/">
        <sch:assert role="error" test="tei:TEI.2 | tei:TEI">File is not a TEI file.</sch:assert>
      </sch:rule>
    </sch:pattern>

    <sch:pattern id="short-title-is-short">
      <sch:rule context="tei:titleStmt">
        <sch:assert role="warn" test="string-length(title[@type='short']) &lt; 26">Short title should be less than 26 characters.</sch:assert>
      </sch:rule>
    </sch:pattern>

    <sch:pattern id="author-has-key">
      <sch:rule context="tei:titleStmt/tei:author">
        <sch:assert role="warn" test="@key or (. = ('anonymous', 'anoniem'))">An author in the titleStmt should have a key attribute.</sch:assert>
      </sch:rule>
    </sch:pattern>

    <sch:pattern id="editor-has-key">
      <sch:rule context="tei:titleStmt/tei:editor">
        <sch:assert role="warn" test="@key">An editor in the titleStmt should have a key attribute.</sch:assert>
      </sch:rule>
    </sch:pattern>

    <sch:pattern id="name-has-key">
        <sch:rule context="tei:titleStmt/tei:respStmt/tei:name">
            <sch:assert role="warn" test="@key">No @key attribute present for name: <sch:value-of select="."/></sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="author-ref-valid-viaf-url">
        <sch:rule context="tei:titleStmt/tei:author[@ref]">
            <sch:assert role="error" test="matches(@ref, '^https://viaf\.org/viaf/[0-9]+/$')">
                The @ref attribute "<sch:value-of select="@ref"/>" on author "<sch:value-of select="."/>" is not a valid viaf.org URL.
            </sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="editor-ref-valid-viaf-url">
        <sch:rule context="tei:titleStmt/tei:editor[@ref]">
            <sch:assert role="error" test="matches(@ref, '^https://viaf\.org/viaf/[0-9]+/$')">
                The @ref attribute "<sch:value-of select="@ref"/>" on editor "<sch:value-of select="."/>" is not a valid viaf.org URL.
            </sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="name-ref-valid-viaf-url">
        <sch:rule context="tei:titleStmt/tei:respStmt/tei:name[@ref]">
            <sch:assert role="error" test="matches(@ref, '^https://viaf\.org/viaf/[0-9]+/$')">
                The @ref attribute "<sch:value-of select="@ref"/>" on name "<sch:value-of select="."/>" is not a valid viaf.org URL.
            </sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="author-has-ref">
        <sch:rule context="tei:titleStmt/tei:author">
            <sch:assert role="warn" test="@ref or . = ('Anonymous', 'Anoniem')">No @ref attribute present for author: <sch:value-of select="."/></sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="editor-has-ref">
        <sch:rule context="tei:titleStmt/tei:editor">
            <sch:assert role="warn" test="@ref">No @ref attribute present for editor: <sch:value-of select="."/></sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="name-has-ref-except-transcription">
        <sch:rule context="tei:titleStmt/tei:respStmt[tei:resp != 'Transcription']/tei:name">
            <sch:assert role="warn" test="@ref">No @ref attribute present for name: <sch:value-of select="."/></sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="check-epub-id">
        <sch:rule context="tei:publicationStmt">
            <sch:assert role="error" test="count(tei:idno[@type = 'epub-id']) = 1">
                The publicationStmt must contain exactly one idno element with type="epub-id".
            </sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="check-epub-id-format">
        <sch:rule context="tei:publicationStmt/tei:idno[@type='epub-id']">
            <sch:assert role="error" test="f:is-valid-uuid(.)">
                The idno element '<sch:value-of select="."/>' with @type="epub-id" must match the GUID URN format (urn:uuid:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx).
            </sch:assert>
        </sch:rule>
    </sch:pattern>


    <sch:pattern id="seg-copyOf-has-matching-id">
        <sch:rule context="tei:seg[@copyOf]">
            <sch:assert role="error" test="//*[@id = current()/@copyOf]">
                The @copyOf attribute "<sch:value-of select="@copyOf"/>" of seg element has no matching @id.
            </sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="ref-noteRef-should-be-note-sameAs">
        <sch:rule context="tei:ref[@type='noteRef']">
            <sch:report role="trivial" test="true()">
                A ref with @type='noteRef' is better replaced with a note with a @sameAs attribute.
            </sch:report>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="ditto-should-be-seg-copyOf">
        <sch:rule context="tei:ditto">
            <sch:report role="trivial" test="true()">
                The non-standard <sch:name/> element is better replaced with a seg element with a @copyOf attribute.
            </sch:report>
        </sch:rule>
    </sch:pattern>


    <sch:pattern id="text-structure-validation-front">
        <sch:rule context="tei:text">
            <sch:assert role="error" test="tei:front or ancestor::tei:q or ancestor::tei:group">No front element present!</sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="text-structure-validation-body">
        <sch:rule context="tei:text">
            <sch:assert role="error" test="tei:body">No body element present!</sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="text-structure-validation-back">
        <sch:rule context="tei:text">
            <sch:assert role="error" test="tei:back or ancestor::tei:q or ancestor::tei:group">No back element present!</sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="toc-is-present">
        <sch:rule context="tei:text">
            <sch:report role="error" test="not(//tei:divGen[@type = ('toc', 'toca')] or //tei:div[@id = 'toc'] or //tei:div1[@id = 'toc'])">
                No Table of Contents (ToC) present.
            </sch:report>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="only-one-toc-present">
        <sch:rule context="tei:text">
            <sch:report role="error" test="//tei:divGen[@type = ('toc', 'toca')] and (//tei:div[@id = 'toc'] or //tei:div1[@id = 'toc'])">
                Both generated and original Table of Contents (ToC) are present.
            </sch:report>
        </sch:rule>
    </sch:pattern>


    <sch:pattern id="id-references-validation">

        <!-- Check that @target points to an existing @id -->
        <sch:rule context="//*[@target]">
            <sch:assert role="error" test="//*[@id = f:strip-hash(current()/@target)]">
                Element <sch:name/>: target attribute value "<sch:value-of select="@target"/>" not present as an @id.
            </sch:assert>
        </sch:rule>

        <!-- Check that @rendition points to an existing rendition element -->
        <sch:rule context="//*[@rendition]">
            <sch:let name="renditionIds" value="tokenize(@rendition, ' ')" />
            <sch:assert role="error" test="every $id in $renditionIds satisfies //tei:rendition[@id = $id]">
                Element <sch:name/>: rendition attribute references missing rendition element(s): "<sch:value-of select="@rendition"/>".
            </sch:assert>
        </sch:rule>

        <!-- Check that @sameAs points to an existing @id -->
        <sch:rule context="//*[@sameAs]">
            <sch:assert role="error" test="//*[@id = f:strip-hash(current()/@sameAs)]">
                Element <sch:name/>: sameAs attribute value "<sch:value-of select="@sameAs"/>" not present as an @id of any element.
            </sch:assert>
        </sch:rule>

        <!-- Check that @who points to an existing @id on a role element -->
        <sch:rule context="//*[@who]">
            <sch:assert role="error" test="//tei:role[@id = f:strip-hash(current()/@who)]">
                Element <sch:name/>: who attribute value "<sch:value-of select="@who"/>" not present as an @id of a role.
            </sch:assert>
        </sch:rule>

        <!-- Check that language @id or @ident is actually used in @lang or @xml:lang -->
        <sch:rule context="//tei:language[@id or @ident]">
            <sch:let name="ident" value="if (@ident) then @ident else @id"/>
            <sch:assert role="error" test="//*[@lang = $ident] or //*[@xml:lang = $ident]">
                Language "<sch:value-of select="$ident"/>" is declared but not used in the text.
            </sch:assert>
        </sch:rule>

    </sch:pattern>


    <sch:pattern id="pb-location-check">
      <sch:rule context="tei:front/tei:pb[not(preceding-sibling::tei:titlePage)] | tei:body/tei:pb | tei:back/tei:pb">
        <sch:assert role="warn" test="false()">
          `pb` element should not appear directly under `front`, `body`, or `back` (unless immediately following a `titlePage` in `front`).
        </sch:assert>
      </sch:rule>
    </sch:pattern>

    <sch:pattern id="pb-under-text">
      <sch:rule context="tei:text/tei:pb">
        <sch:assert role="warn" test="false()">
          `pb` element should not appear directly under `text`.
        </sch:assert>
      </sch:rule>
    </sch:pattern>

    <sch:pattern id="note-pb-sequence-check">
      <sch:rule context="tei:note[.//tei:pb]">
        <sch:let name="n1" value="(.//tei:pb/@n)[1]"/>
        <sch:let name="n0" value="preceding::tei:pb[1]/@n"/>
        <sch:let name="v1" value="if (f:is-roman($n1)) then f:from-roman($n1) else number($n1)"/>
        <sch:let name="v0" value="if (f:is-roman($n0)) then f:from-roman($n0) else number($n0)"/>
        <sch:assert role="warn" test="not(f:is-integer($v0) and f:is-integer($v1)) or $v1 = $v0 + 1">
          Page break in note: page <sch:value-of select="$n1"/> out of sequence (preceding <sch:value-of select="$n0"/>).
        </sch:assert>
      </sch:rule>
    </sch:pattern>

    <sch:pattern id="correction-equals-sic-attribute">
      <sch:rule context="tei:corr[@sic]">
        <sch:assert test="string(.) != string(@sic)">
          The correction text (<sch:value-of select="."/>) is the same as the value of the @sic attribute.
        </sch:assert>
      </sch:rule>
    </sch:pattern>

    <sch:pattern id="correction-in-choice-equals-sic">
      <sch:rule context="tei:choice[tei:sic and tei:corr]">
        <sch:assert test="string(tei:sic) != string(tei:corr)">
          The correction (<sch:value-of select="tei:corr"/>) is the same as the original text inside a choice element.
        </sch:assert>
      </sch:rule>
    </sch:pattern>

    <sch:pattern id="redundant-lang-attribute">
      <sch:rule context="*[@lang]">
        <sch:assert test="not((ancestor::*[@lang])[last()]/@lang = @lang)">
          The @lang attribute is redundant: it has the same value '<sch:value-of select="@lang"/>' as the nearest ancestor with @lang, <sch:value-of select="name((ancestor::*[@lang])[last()])"/>.
        </sch:assert>
      </sch:rule>
    </sch:pattern>

    <sch:pattern id="redundant-xml-lang-attribute">
      <sch:rule context="*[@xml:lang]">
        <sch:assert test="not((ancestor::*[@xml:lang])[last()]/@xml:lang = @xml:lang)">
          The @xml:lang attribute is redundant: it has the same value '<sch:value-of select="@xml:lang"/>' as the nearest ancestor with @xml:lang, <sch:value-of select="name((ancestor::*[@xml:lang])[last()])"/>.
        </sch:assert>
      </sch:rule>
    </sch:pattern>


    <sch:pattern id="title-nfc-correct">
      <sch:rule context="tei:titleStmt/tei:title">
        <sch:let name="lang" value="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
        <sch:let name="title-text" value="normalize-space(string(.))"/>
        <sch:let name="first-word" value="lower-case(substring-before(concat($title-text, ' '), ' '))"/>
        <sch:let name="articles" value="f:articles-for-lang($lang)"/>
        <sch:let name="expected-nfc" value="string-length($first-word) + 1"/>

        <!-- If title starts with article, @nfc must be present and correct -->
        <sch:assert test="not($first-word = $articles) or @nfc = $expected-nfc">
          Title begins with article "<sch:value-of select="$first-word"/>", so @nfc should be "<sch:value-of select="$expected-nfc"/>".
        </sch:assert>

        <!-- If title does NOT start with article, @nfc must be absent -->
        <sch:assert test="($first-word = $articles) or not(@nfc)">
          Title does not begin with an article "<sch:value-of select="$first-word"/>", so @nfc should be omitted (found: "<sch:value-of select="@nfc"/>").
        </sch:assert>
      </sch:rule>
    </sch:pattern>


    <sch:pattern id="allowed-attribute-values" abstract="true">
      <sch:rule context="$context">
        <sch:let name="values" value="$allowed-values"/>
        <sch:let name="attr" value="@*[name() = $attribute]"/>
        <sch:assert test="$attr = $values">
          The <sch:name/> element has an invalid value for "@<sch:value-of select="$attribute"/>":
          "<sch:value-of select="$attr"/>".
          Allowed values are: <sch:value-of select="string-join($values, ', ')"/>.
        </sch:assert>
      </sch:rule>
    </sch:pattern>

    <sch:pattern is-a="allowed-attribute-values">
      <sch:param name="context" value="tei:head[@type]"/>
      <sch:param name="attribute" value="'type'"/>
      <sch:param name="allowed-values" value="('main', 'sub', 'super', 'label')"/>
    </sch:pattern>

    <sch:pattern is-a="allowed-attribute-values">
      <sch:param name="context" value="tei:front/tei:div1[@type]"/>
      <sch:param name="attribute" value="'type'"/>
      <sch:param name="allowed-values" value="('Advertisement', 'Advertisements', 'Bibliography', 'CastList', 'Contents', 'Copyright', 'Cover', 'Dedication', 'Epigraph', 'Errata', 'Foreword', 'FrenchTitle', 'Frontispiece', 'Glossary', 'Imprint', 'Introduction', 'Motto', 'Note', 'Notes', 'Preface', 'TitlePage')"/>
    </sch:pattern>

    <sch:pattern is-a="allowed-attribute-values">
      <sch:param name="context" value="tei:body/tei:div0[@type]"/>
      <sch:param name="attribute" value="'type'"/>
      <sch:param name="allowed-values" value="('Book', 'Issue', 'Part', 'Volume')"/>
    </sch:pattern>

    <sch:pattern is-a="allowed-attribute-values">
      <sch:param name="context" value="tei:body/tei:div1[@type]"/>
      <sch:param name="attribute" value="'type'"/>
      <sch:param name="allowed-values" value="('Act', 'Scene', 'Article', 'Chapter', 'Part', 'Poem', 'Story', 'Tale')"/>
    </sch:pattern>

    <sch:pattern is-a="allowed-attribute-values">
      <sch:param name="context" value="tei:back/tei:div1[@type]"/>
      <sch:param name="attribute" value="'type'"/>
      <sch:param name="allowed-values" value="('Advertisement', 'Advertisements', 'Appendix', 'Bibliography', 'Conclusion', 'Contents', 'Cover', 'Epilogue', 'Errata', 'Glossary', 'Imprint', 'Index', 'Note', 'Notes', 'Spine', 'Vocabulary')"/>
    </sch:pattern>

    <sch:pattern is-a="allowed-attribute-values">
      <sch:param name="context" value="tei:ab[@type]"/>
      <sch:param name="attribute" value="'type'"/>
      <sch:param name="allowed-values" value="('verseNum', 'lineNum', 'parNum', 'tocPageNum', 'tocDivNum', 'divNum', 'itemNum', 'figNum', 'keyRef', 'lineNumRef', 'endNoteNum', 'textRef', 'keyNum', 'intra', 'top', 'bottom', 'price', 'phantom')"/>
    </sch:pattern>

</sch:schema>
