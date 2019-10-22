<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f xd xhtml xs">

    <xd:doc type="stylesheet">
        <xd:short>Templates to handle cross-references.</xd:short>
        <xd:detail>This stylesheet contains a number of templates to handle cross-references.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:include href="references-func.xsl"/>

    <xsl:key name="id" match="*[@id]" use="@id"/>

    <!--====================================================================-->
    <!-- Cross References -->

    <xd:doc>
        <xd:short>Handle a cross-reference (TEI/P5).</xd:short>
        <xd:detail>
            <p>Handle TEI/P5 references that can be either internal or external references. Targets starting with a
            <code>#</code> are considered internal, all others external.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="TEI//ref[@target]">
        <xsl:choose>
            <xsl:when test="starts-with(@target, '#')">
                <xsl:call-template name="handleInternalReference">
                    <xsl:with-param name="target" select="substring(@target, 2)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="handleExternalReference">
                    <xsl:with-param name="url" select="@target"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle an internal cross-reference (TEI.2/P4).</xd:short>
        <xd:detail>
            <p>Insert a hyperlink that will link to the referenced <code>@target</code>-attribute in the generated output.</p>
            <p>This template includes special handling to make sure elements inside footnotes do point to the correct
            target file when generating multiple-file output, and those footnotes end-up in a different file.</p>
            <p>This template is for TEI.2 (P4) documents only.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="TEI.2//ref[@target]">
        <xsl:call-template name="handleInternalReference">
            <xsl:with-param name="target" select="replace(@target, '#', '')"/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="handleInternalReference">
        <xsl:param name="target" as="xs:string"/>
        <xsl:variable name="targetNode" select="key('id', $target)[1]"/>

        <xsl:choose>
            <xsl:when test="not($targetNode)">
                <xsl:copy-of select="f:logWarning('Target &quot;{1}&quot; of cross reference not found.', ($target))"/>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="@type='noteref'">
                <!-- Special case: reference to footnote, used when the content of the reference 
                     needs to be rendered as a footnote reference mark -->
                <xsl:apply-templates select="$targetNode" mode="noterefnumber"/>
            </xsl:when>
            <xsl:otherwise>
                <a href="{f:generate-safe-href($targetNode)}">
                    <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                    <xsl:if test="@type='pageref'">
                        <xsl:attribute name="class">pageref</xsl:attribute>
                    </xsl:if>
                    <xsl:if test="@type='endnoteref'">
                        <xsl:attribute name="class">noteref</xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Style a reference to a footnote as a footnote reference.</xd:short>
        <xd:detail>
            <p>Make explicit references to a footnote (marked <code>noteref</code>) look exactly 
            the same as automatically generated footnote references.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="note" mode="noterefnumber">
        <a class="pseudonoteref" href="{f:generate-footnote-href(.)}">
            <xsl:call-template name="footnote-number"/>
        </a>
    </xsl:template>


    <xd:doc>
        <xd:short>Is a node a footnote or inside a footnote?</xd:short>
        <xd:detail>
            <p>This function determines whether a node is a footnote or inside a footnote. This is important,
            as footnotes may be placed in quite different locations than the text they are referred to.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:inside-footnote" as="xs:boolean">
        <xsl:param name="targetNode" as="node()"/>

        <xsl:sequence select="if ($targetNode/ancestor-or-self::note[f:isFootnote(.)]) then true() else false()"/>
    </xsl:function>

    <xd:doc>
        <xd:short>Is a node inside a choice-element?</xd:short>
        <xd:detail>
            <p>This function determines whether a node is inside a choice-element. This is important,
            as elements inside choice elements may not be rendered at all.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:inside-choice" as="xs:boolean">
        <xsl:param name="targetNode" as="node()"/>

        <xsl:sequence select="if ($targetNode/ancestor::choice) then true() else false()"/>
    </xsl:function>


    <!--====================================================================-->
    <!-- External References -->

    <xd:doc>
        <xd:short>Handle an external cross-reference (1).</xd:short>
        <xd:detail>
            <p>Insert a hyperlink that will link to the referenced <code>@url</code>-attribute in the generated output.</p>
            <p>Two stylesheet parameters control the generation of external links.</p>

            <ul>
                <li>Active external links will be put in the output by setting the stylesheet parameter 
                <code>outputExternalLinks</code> to <code>always</code>. External links can be limited to the generated Colophon 
                only by setting this value to <code>colophon</code>.</li>
                <li>External links will be placed in a table in the colophon (provided a colophon is present) by
                setting <code>outputExternalLinksTable</code> to <code>true</code>. Here they will be rendered as an URL.
                The original link will then link to the table.</li>
            </ul>

            <p>The <code>xref</code>-element has been removed in TEI P5, so this template will not be used with newer TEI files.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="xref[@url]">
        <xsl:call-template name="handleExternalReference">
            <xsl:with-param name="url" select="@url"/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="handleExternalReference">
        <xsl:param name="url" as="xs:string"/>

        <xsl:choose>
            <xsl:when test="f:isSet('outputExternalLinksTable')">
                <xsl:choose>
                    <xsl:when test="//divGen[@type='Colophon']">
                        <a id="{f:generate-id(.)}" href="{f:generate-xref-table-href(.)}">
                            <xsl:apply-templates/>
                        </a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="f:getSetting('outputExternalLinks') = 'always' 
                            or (f:getSetting('outputExternalLinks') = 'colophon' and ancestor::teiHeader)">
                <xsl:call-template name="handle-xref">
                    <xsl:with-param name="url" select="$url"/>
                </xsl:call-template>
            </xsl:when>

            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xd:doc>
        <xd:short>Handle an external cross-reference (2).</xd:short>
        <xd:detail>
            <p>In this template, the <code>class</code>, <code>title</code>, and <code>href</code> attributes in the output HTML are determined.</p>

            <p>The main document language is used to apply language-dependent translations. TODO: This should be changed to use the language of the local context.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="handle-xref">
        <xsl:param name="url" as="xs:string"/>

        <a>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:attribute name="class">
                <xsl:value-of select="f:translate-xref-class($url)"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="f:generate-class-name(.)"/>
            </xsl:attribute>
            <xsl:attribute name="title">
                <xsl:value-of select="f:translate-xref-title($url)"/>
            </xsl:attribute>
            <xsl:attribute name="href">
                <xsl:value-of select="f:translate-xref-url($url, substring(f:get-document-lang(), 1, 2))"/>
            </xsl:attribute>
            <xsl:if test="@rel">
                <xsl:attribute name="rel"><xsl:value-of select="@rel"/></xsl:attribute>
            </xsl:if>

            <xsl:apply-templates/>
        </a>
    </xsl:template>

</xsl:stylesheet>
