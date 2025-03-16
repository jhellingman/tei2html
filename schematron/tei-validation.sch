<?xml version="1.0"?>
<sch:schema
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    queryBinding="xslt3">

    <sch:ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
    <sch:ns uri="#functions" prefix="f"/>

    <xsl:function name="f:is-valid-uuid" as="xs:boolean">
        <xsl:param name="id"/>
        <xsl:variable name="uuidPattern" 
            select="'^urn:uuid:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'"/>
        <xsl:sequence select="matches($id, $uuidPattern)"/>
    </xsl:function>

    <sch:pattern id="report-title">
      <sch:rule context="//tei:titleStmt">
        <sch:report test="tei:title">ℹ️ Title: <sch:value-of select="tei:title"/></sch:report>
      </sch:rule>
    </sch:pattern>

    <sch:pattern id="report-author">
      <sch:rule context="//tei:titleStmt">
        <sch:report test="tei:author">ℹ️ Author: <sch:value-of select="tei:author"/></sch:report>
      </sch:rule>
    </sch:pattern>


    <sch:pattern id="is-tei-file">
      <sch:rule context="/">
        <sch:assert test="tei:TEI.2 | tei:TEI">
            ❌ File is not a TEI file.
        </sch:assert>
      </sch:rule>
    </sch:pattern>

    <sch:pattern id="short-title-is-short">
      <sch:rule context="tei:titleStmt">
        <sch:assert test="string-length(title[@type='short']) &lt; 26">
            ❌ Short title should be less than 26 characters.
        </sch:assert>
      </sch:rule>
    </sch:pattern>

    <sch:pattern id="author-has-key">
      <sch:rule context="tei:titleStmt/tei:author">
        <sch:assert test="@key or (. = ('anonymous', 'anoniem'))">
            ❌ An author in the titleStmt should have a key attribute.
        </sch:assert>
      </sch:rule>
    </sch:pattern>

    <sch:pattern id="editor-has-key">
      <sch:rule context="tei:titleStmt/tei:editor">
        <sch:assert test="@key">
            ❌ An editor in the titleStmt should have a key attribute.
        </sch:assert>
      </sch:rule>
    </sch:pattern>

    <sch:pattern id="name-has-key">
        <sch:rule context="tei:titleStmt/tei:respStmt/tei:name">
            <sch:assert test="@key">
                ❌ No @key attribute present for name: <sch:value-of select="."/>
            </sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="author-ref-valid-viaf-url">
        <sch:rule context="tei:titleStmt/tei:author[@ref]">
            <sch:assert test="matches(@ref, '^https://viaf\.org/viaf/[0-9]+/$')">
                ❌ The @ref attribute "<sch:value-of select="@ref"/>" on author "<sch:value-of select="."/>" is not a valid viaf.org URL.
            </sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="editor-ref-valid-viaf-url">
        <sch:rule context="tei:titleStmt/tei:editor[@ref]">
            <sch:assert test="matches(@ref, '^https://viaf\.org/viaf/[0-9]+/$')">
                ❌ The @ref attribute "<sch:value-of select="@ref"/>" on editor "<sch:value-of select="."/>" is not a valid viaf.org URL.
            </sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="name-ref-valid-viaf-url">
        <sch:rule context="tei:titleStmt/tei:respStmt/tei:name[@ref]">
            <sch:assert test="matches(@ref, '^https://viaf\.org/viaf/[0-9]+/$')">
                ❌ The @ref attribute "<sch:value-of select="@ref"/>" on name "<sch:value-of select="."/>" is not a valid viaf.org URL.
            </sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="author-has-ref">
        <sch:rule context="tei:titleStmt/tei:author">
            <sch:assert test="@ref or . = ('Anonymous', 'Anoniem')">
                ❌ No @ref attribute present for author: <sch:value-of select="."/>
            </sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="editor-has-ref">
        <sch:rule context="tei:titleStmt/tei:editor">
            <sch:assert test="@ref">
                ❌ No @ref attribute present for editor: <sch:value-of select="."/>
            </sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="name-has-ref-except-transcription">
        <sch:rule context="tei:titleStmt/tei:respStmt[tei:resp != 'Transcription']/tei:name">
            <sch:assert test="@ref">
                ❌ No @ref attribute present for name: <sch:value-of select="."/>
            </sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="check-epub-id">
        <sch:rule context="tei:publicationStmt">
            <sch:assert test="count(tei:idno[@type = 'epub-id']) = 1">
                ❌ The publicationStmt must contain exactly one idno element with type="epub-id".
            </sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="check-epub-id-format">
        <sch:rule context="tei:publicationStmt/tei:idno[@type='epub-id']">
            <sch:assert test="f:is-valid-uuid(.)">
                ❌ The idno element '<sch:value-of select="."/>' with @type="epub-id" must match the GUID URN format (urn:uuid:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx).
            </sch:assert>
        </sch:rule>
    </sch:pattern>

</sch:schema>
