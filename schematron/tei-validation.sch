<?xml version="1.0"?>
<schema
    xmlns="http://purl.oclc.org/dsdl/schematron"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    queryBinding="xslt3">

    <ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
    <ns uri="#functions" prefix="f"/>

    <xsl:function name="f:is-valid-uuid" as="xs:boolean">
        <xsl:param name="id"/>
        <xsl:sequence select="matches($id, '^urn:uuid:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')"/>
    </xsl:function>

    <pattern id="metadata">
      <rule context="//tei:titleStmt">
        <report test="tei:title">ℹ️ Title: <value-of select="."/></report>
      </rule>
    </pattern>

    <pattern id="check-epub-id">
        <rule context="//tei:publicationStmt">
            <assert test="count(tei:idno[@type = 'epub-id']) = 1">
                ❌ The publicationStmt must contain exactly one idno element with type="epub-id".
            </assert>
            <assert test="matches(tei:idno[@type='epub-id'], '^urn:uuid:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')">
                ❌ The idno element with type="epub-id" must match the GUID URN format (urn:uuid:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx).
            </assert>
            <assert test="f:is-valid-uuid(tei:idno[@type='epub-id'])">
                ❌ The idno element with type="epub-id" must match the GUID URN format (urn:uuid:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx).
            </assert>
        </rule>
    </pattern>

</schema>
