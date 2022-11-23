<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="f xs xd">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to support merging two or more TEI documents.</xd:short>
        <xd:detail>This stylesheet contains a number of support functions and templates to make merging of two TEI files easy.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2012, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Import Document.</xd:short>
        <xd:detail>
            <p>Import a document as node-set, while at the same time adjusting internal ids to make them unique.</p>
        </xd:detail>
        <xd:param name="location">The location of the file to be imported.</xd:param>
        <xd:param name="baseNode">Node to disambiguate relative locations.</xd:param>
        <xd:param name="prefix">The prefix to add to all ids in this document.</xd:param>
        <xd:param name="keepPrefix">List of space-separated prefixes of ids that should <i>not</i> be prefixed.</xd:param>
    </xd:doc>

    <xsl:function name="f:import-document">
        <xsl:param name="location" as="xs:string"/>
        <xsl:param name="baseNode"/>
        <xsl:param name="prefix" as="xs:string"/>
        <xsl:param name="keepPrefix" as="xs:string"/>

        <xsl:variable name="keepPrefixes" select="tokenize($keepPrefix, ' ')"/>

        <xsl:apply-templates select="document($location, $baseNode)" mode="prefix-id">
            <xsl:with-param name="prefix" select="$prefix" tunnel="yes"/>
            <xsl:with-param name="keepPrefixes" select="$keepPrefixes" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:function>


    <xd:doc>
        <xd:short>Prefix IDs.</xd:short>
        <xd:detail>
            <p>Place a prefix before an ID to make them unique. Do not add a prefix if the ID already has certain prefixes.</p>
        </xd:detail>
        <xd:param name="id">The id to be adjusted.</xd:param>
        <xd:param name="prefix">The prefix to add.</xd:param>
        <xd:param name="keepPrefixes">Prefixes of ids that should <i>not</i> be prefixed.</xd:param>
    </xd:doc>

    <xsl:function name="f:prefix-id" as="xs:string">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="prefix" as="xs:string"/>
        <xsl:param name="keepPrefixes" as="xs:string*"/>

        <!--
        <xsl:message>ID: <xsl:value-of select="$id"/>.</xsl:message>
        <xsl:message>PREFIX: <xsl:value-of select="$prefix"/>.</xsl:message>
        <xsl:message>PREFIXES: <xsl:value-of select="$keepPrefixes"/>.</xsl:message>
        <xsl:message>TEST: <xsl:value-of select="f:starts-with-any($id, $keepPrefixes)"/>.</xsl:message>
        <xsl:message>RESULT: <xsl:value-of select="if (f:starts-with-any($id, $keepPrefixes)) then $id else concat($prefix, $id)"/>.</xsl:message>
        -->

        <xsl:sequence select="if (f:starts-with-any($id, $keepPrefixes)) then $id else concat($prefix, $id)"/>
    </xsl:function>


    <xsl:function name="f:starts-with-any" as="xs:boolean">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="keepPrefixes" as="xs:string*"/>

        <!--
        <xsl:message>TEST: <xsl:value-of select="$id"/> : <xsl:value-of select="$keepPrefixes"/>.</xsl:message>
        <xsl:message>RESULT: <xsl:value-of select="sum(for $prefix in $keepPrefixes return (if (starts-with($id, $prefix)) then 1 else 0)) > 1"/>.</xsl:message>
        -->

        <xsl:sequence select="sum(for $prefix in $keepPrefixes return (if (starts-with($id, $prefix)) then 1 else 0)) &gt; 0"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Do not mess with language ids.</xd:short>
    </xd:doc>

    <xsl:template match="language/@id" mode="prefix-id">
        <xsl:copy-of select="."/>
    </xsl:template>


    <xd:doc>
        <xd:short>Translate ids in <code>@id</code> attribute.</xd:short>
    </xd:doc>

    <xsl:template match="@id" mode="prefix-id">
        <xsl:param name="prefix" as="xs:string" tunnel="yes"/>
        <xsl:param name="keepPrefixes" as="xs:string*" tunnel="yes"/>

        <xsl:attribute name="id">
            <xsl:value-of select="f:prefix-id(., $prefix, $keepPrefixes)"/>
        </xsl:attribute>
    </xsl:template>


    <xd:doc>
        <xd:short>Translate ids in <code>@target</code> attributes.</xd:short>
    </xd:doc>

    <xsl:template match="@target" mode="prefix-id">
        <xsl:param name="prefix" as="xs:string" tunnel="yes"/>
        <xsl:param name="keepPrefixes" as="xs:string*" tunnel="yes"/>

        <xsl:attribute name="target">
            <xsl:value-of select="f:prefix-id(., $prefix, $keepPrefixes)"/>
        </xsl:attribute>
    </xsl:template>


    <xd:doc>
        <xd:short>Translate ids in <code>@sameAs</code> attributes.</xd:short>
    </xd:doc>

    <xsl:template match="@sameAs" mode="prefix-id">
        <xsl:param name="prefix" as="xs:string" tunnel="yes"/>
        <xsl:param name="keepPrefixes" as="xs:string*" tunnel="yes"/>

        <xsl:attribute name="sameAs">
            <xsl:value-of select="f:prefix-id(., $prefix, $keepPrefixes)"/>
        </xsl:attribute>
    </xsl:template>


    <xd:doc>
        <xd:short>Translate ids in <code>@copyOf</code> attributes.</xd:short>
    </xd:doc>

    <xsl:template match="@copyOf" mode="prefix-id">
        <xsl:param name="prefix" as="xs:string" tunnel="yes"/>
        <xsl:param name="keepPrefixes" as="xs:string*" tunnel="yes"/>

        <xsl:attribute name="copyOf">
            <xsl:value-of select="f:prefix-id(., $prefix, $keepPrefixes)"/>
        </xsl:attribute>
    </xsl:template>


    <xd:doc>
        <xd:short>Copy all other nodes.</xd:short>
    </xd:doc>

    <xsl:template match="node()|@*" mode="prefix-id">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="prefix-id"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
