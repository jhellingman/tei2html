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
        <xsl:sequence select="matches($id, '^urn:uuid:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')"/>
    </xsl:function>

    <sch:pattern id="metadata-title">
      <sch:rule context="//tei:titleStmt">
        <sch:report test="tei:title">ℹ️ Title: <sch:value-of select="tei:title"/></sch:report>
      </sch:rule>
    </sch:pattern>
    
    <sch:pattern id="metadata-author">
      <sch:rule context="//tei:titleStmt">
        <sch:report test="tei:author">ℹ️ Author: <sch:value-of select="tei:author"/></sch:report>
      </sch:rule>      
    </sch:pattern>

    <sch:pattern id="check-epub-id">
        <sch:rule context="//tei:publicationStmt">
            <sch:assert test="count(tei:idno[@type = 'epub-id']) = 1">
                ❌ The publicationStmt must contain exactly one idno element with type="epub-id".
            </sch:assert>
            <sch:assert test="matches(tei:idno[@type='epub-id'], '^urn:uuid:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')">
                ❌ The idno element with type="epub-id" must match the GUID URN format (urn:uuid:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx).
            </sch:assert>
            <sch:assert test="f:is-valid-uuid(tei:idno[@type='epub-id'])">
                ❌ The idno element with type="epub-id" must match the GUID URN format (urn:uuid:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx).
            </sch:assert>
        </sch:rule>
    </sch:pattern>

</sch:schema>
