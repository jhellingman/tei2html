<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="f xs xd">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to support merging two or more TEI documents.</xd:short>
        <xd:detail>This stylesheet contains a number of support functions and templates to make merging of two TEI files easy. 
            Currently this is designed to work with TEI P4 documents only. To make it also work for P5, the url attribute also
            needs to be taken in consideration (only when starting with a # symbol).</xd:detail>
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

        <xsl:apply-templates select="document($location, $baseNode)" mode="import-document">
            <xsl:with-param name="prefix" select="$prefix"/>
            <xsl:with-param name="keepPrefixes" select="$keepPrefixes"/>
        </xsl:apply-templates>
    </xsl:function>


    <xd:doc>
        <xd:short>Combine IDs.</xd:short>
        <xd:detail>
            <p>Combine IDs with a prefix, to make them unique. Do not add a prefix if one is already present.</p>
        </xd:detail>
        <xd:param name="id">The id to be adjusted.</xd:param>
        <xd:param name="prefix">The prefix to add.</xd:param>
        <xd:param name="keepPrefixes">Prefixes of ids that should <i>not</i> be prefixed.</xd:param>
    </xd:doc>

    <xsl:function name="f:combine-id" as="xs:string">
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

        <xsl:sequence select="sum(for $prefix in $keepPrefixes return (if (starts-with($id, $prefix)) then 1 else 0)) &gt;= 1"/>
    </xsl:function>

    <xd:doc>
        <xd:short>Do not mess with language ids.</xd:short>
    </xd:doc>

    <xsl:template match="language/@id" mode="import-document">
        <xsl:copy-of select="."/>
    </xsl:template>


    <xd:doc>
        <xd:short>Translate ids in <code>@id</code> attribute.</xd:short>
    </xd:doc>

    <xsl:template match="@id" mode="import-document">
        <xsl:param name="prefix" as="xs:string"/>
        <xsl:param name="keepPrefixes" as="xs:string*"/>

        <xsl:attribute name="id">
            <xsl:value-of select="f:combine-id(., $prefix, $keepPrefixes)"/>
        </xsl:attribute>
    </xsl:template>


    <xd:doc>
        <xd:short>Translate ids in <code>@target</code> attributes.</xd:short>
    </xd:doc>

    <xsl:template match="@target" mode="import-document">
        <xsl:param name="prefix" as="xs:string"/>
        <xsl:param name="keepPrefixes" as="xs:string*"/>

        <xsl:attribute name="target">
            <xsl:value-of select="f:combine-id(., $prefix, $keepPrefixes)"/>
        </xsl:attribute>
    </xsl:template>


    <xd:doc>
        <xd:short>Translate ids in <code>@sameAs</code> attributes.</xd:short>
    </xd:doc>

    <xsl:template match="@sameAs" mode="import-document">
        <xsl:param name="prefix" as="xs:string"/>
        <xsl:param name="keepPrefixes" as="xs:string*"/>

        <xsl:attribute name="sameAs">
            <xsl:value-of select="f:combine-id(., $prefix, $keepPrefixes)"/>
        </xsl:attribute>
    </xsl:template>


    <xd:doc>
        <xd:short>Translate ids in <code>@copyOf</code> attributes.</xd:short>
    </xd:doc>

    <xsl:template match="@copyOf" mode="import-document">
        <xsl:param name="prefix" as="xs:string"/>
        <xsl:param name="keepPrefixes" as="xs:string*"/>

        <xsl:attribute name="copyOf">
            <xsl:value-of select="f:combine-id(., $prefix, $keepPrefixes)"/>
        </xsl:attribute>
    </xsl:template>


    <xd:doc>
        <xd:short>Copy all other nodes.</xd:short>
    </xd:doc>

    <xsl:template match="node()|@*" mode="import-document">
        <xsl:param name="prefix" as="xs:string"/>
        <xsl:param name="keepPrefixes" as="xs:string*"/>

        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="import-document">
                <xsl:with-param name="prefix" select="$prefix"/>
                <xsl:with-param name="keepPrefixes" select="$keepPrefixes"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
