<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="f xs xd">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to support merging two or more TEI documents.</xd:short>
        <xd:detail>This stylesheet contains support functions and templates to make merging of multiple TEI files easy.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2012-2022, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:include href="modules/log.xsl"/>
    <xsl:include href="modules/rend.xsl"/>

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

    <xsl:function name="f:import-document">
        <xsl:param name="location" as="xs:string"/>
        <xsl:param name="prefix" as="xs:string"/>
        <xsl:param name="keepPrefix" as="xs:string"/>

        <xsl:variable name="keepPrefixes" select="tokenize($keepPrefix, ' ')"/>

        <xsl:apply-templates select="document($location)" mode="prefix-id">
            <xsl:with-param name="prefix" select="$prefix" tunnel="yes"/>
            <xsl:with-param name="keepPrefixes" select="$keepPrefixes" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:function>

    <xsl:function name="f:import-document">
        <xsl:param name="location" as="xs:string"/>
        <xsl:param name="baseNode"/>

        <xsl:copy-of select="document($location, $baseNode)"/>
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

        <xsl:sequence select="if (f:starts-with-any($id, $keepPrefixes)) then $id else concat($prefix, $id)"/>
    </xsl:function>


    <xsl:function name="f:starts-with-any" as="xs:boolean">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="keepPrefixes" as="xs:string*"/>

        <xsl:sequence select="sum(for $prefix in $keepPrefixes return (if (starts-with($id, $prefix)) then 1 else 0)) &gt; 0"/>
    </xsl:function>


    <xd:doc mode="prefix-id">
        <xd:short>Mode used to prefix ids with a given prefix.</xd:short>
    </xd:doc>


    <xd:doc>
        <xd:short>Do not change language IDs.</xd:short>
    </xd:doc>

    <xsl:template match="language/@id" mode="prefix-id">
        <xsl:copy-of select="."/>
    </xsl:template>


    <xd:doc>
        <xd:short>Translate IDs in <code>@id</code> attributes.</xd:short>
    </xd:doc>

    <xsl:template match="@id" mode="prefix-id">
        <xsl:param name="prefix" as="xs:string" tunnel="yes"/>
        <xsl:param name="keepPrefixes" as="xs:string*" tunnel="yes"/>

        <xsl:attribute name="id">
            <xsl:value-of select="f:prefix-id(., $prefix, $keepPrefixes)"/>
        </xsl:attribute>
    </xsl:template>


    <xd:doc>
        <xd:short>Translate IDs in <code>@target</code> attributes.</xd:short>
    </xd:doc>

    <xsl:template match="@target" mode="prefix-id">
        <xsl:param name="prefix" as="xs:string" tunnel="yes"/>
        <xsl:param name="keepPrefixes" as="xs:string*" tunnel="yes"/>

        <xsl:attribute name="target">
            <xsl:value-of select="f:prefix-id(., $prefix, $keepPrefixes)"/>
        </xsl:attribute>
    </xsl:template>


    <xd:doc>
        <xd:short>Translate IDs in <code>@sameAs</code> attributes.</xd:short>
    </xd:doc>

    <xsl:template match="@sameAs" mode="prefix-id">
        <xsl:param name="prefix" as="xs:string" tunnel="yes"/>
        <xsl:param name="keepPrefixes" as="xs:string*" tunnel="yes"/>

        <xsl:attribute name="sameAs">
            <xsl:value-of select="f:prefix-id(., $prefix, $keepPrefixes)"/>
        </xsl:attribute>
    </xsl:template>


    <xd:doc>
        <xd:short>Translate IDs in <code>@copyOf</code> attributes.</xd:short>
    </xd:doc>

    <xsl:template match="@copyOf" mode="prefix-id">
        <xsl:param name="prefix" as="xs:string" tunnel="yes"/>
        <xsl:param name="keepPrefixes" as="xs:string*" tunnel="yes"/>

        <xsl:attribute name="copyOf">
            <xsl:value-of select="f:prefix-id(., $prefix, $keepPrefixes)"/>
        </xsl:attribute>
    </xsl:template>

    <xd:doc>
        <xd:short>Translate IDs in <code>@rend</code> attributes.</xd:short>
        <xd:detail>IDs occur in <code>align-with()</code> rendition ladder elements.</xd:detail>
    </xd:doc>

    <xsl:template match="@rend" mode="prefix-id">
        <xsl:param name="prefix" as="xs:string" tunnel="yes"/>
        <xsl:param name="keepPrefixes" as="xs:string*" tunnel="yes"/>
    
        <xsl:variable name="rend" select="
            if (f:has-rend-value(., 'align-with'))
            then f:add-rend-value(
                f:remove-rend-value(., 'align-with'),
                'align-with',
                f:prefix-id(f:rend-value(., 'align-with'), $prefix, $keepPrefixes))
            else ."/>

        <xsl:if test="$rend">
            <xsl:attribute name="rend" select="$rend"/>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Copy all other nodes.</xd:short>
    </xd:doc>

    <xsl:template match="node()|@*" mode="prefix-id">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="prefix-id"/>
        </xsl:copy>
    </xsl:template>


    <xd:doc>
        <xd:short>Combine tagsDecl from all documents.</xd:short>
    </xd:doc>

    <xsl:function name="f:combine-tagsDecl">
        <xsl:param name="documents"/>

        <xsl:variable name="tagsDecl">
            <xsl:for-each select="$documents">
                <xsl:copy-of select=".//teiHeader/encodingDesc/tagsDecl/rendition"/>
            </xsl:for-each>
        </xsl:variable>

        <tagsDecl lang="xx">
            <xsl:for-each-group select="$tagsDecl/rendition" group-by="@selector">
                <xsl:copy-of select="current-group()[1]"/>
                <xsl:variable name="rendition" select="current-group()[1]"/>
                <xsl:for-each select="current-group()[position() != 1]">
                    <xsl:if test=". != $rendition">
                        <xsl:message terminate="no" expand-text="yes">WARNING: Inconsitent rendition: {@selector} {{ {.} }}</xsl:message>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each-group>
        </tagsDecl>
    </xsl:function>


    <xd:doc>
        <xd:short>Combine langUsage from all documents.</xd:short>
    </xd:doc>

    <xsl:function name="f:combine-languages">
        <xsl:param name="documents"/>

        <xsl:variable name="langUsage">
            <xsl:for-each select="$documents">
                <xsl:copy-of select=".//teiHeader/profileDesc/langUsage/language"/>
            </xsl:for-each>
        </xsl:variable>

        <langUsage>
            <xsl:if test="$documents//teiHeader/profileDesc/langUsage/@lang">
                <xsl:attribute name="lang" select="($documents//teiHeader/profileDesc/langUsage/@lang)[1]"/>
            </xsl:if>
            <xsl:for-each-group select="$langUsage/language" group-by="@id">
                <xsl:sort select="@id"/>
                <xsl:copy-of select="current-group()[1]"/>
            </xsl:for-each-group>
        </langUsage>
    </xsl:function>



    <!-- Stub methods from included stylesheets -->

    <xsl:function name="f:is-set" as="xs:boolean">
        <xsl:param name="node" as="xs:string"/>
        <xsl:sequence select="false()"/>
    </xsl:function>


</xsl:stylesheet>
