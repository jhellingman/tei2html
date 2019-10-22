<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet with various utily templates, to be imported in tei2html.xsl.

    Requires: 
        localization.xsl    : templates for localizing strings.

-->

<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="f xd xs">

    <xd:doc type="stylesheet">
        <xd:short>HTML-specific utility templates and functions, used by tei2html</xd:short>
        <xd:detail>This stylesheet contains a number of utility templates and functions, used by tei2html only.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011-2017, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Generate an href attribute savely.</xd:short>
        <xd:detail>
            <p>For HTML version, same as basic generate-href.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:generate-safe-href" as="xs:string">
        <xsl:param name="target" as="element()"/>

        <!-- When the target is inside a choice element, it may not be rendered in the output: point at the first ancestor not inside the choice. -->
        <xsl:variable name="target" select="if (f:inside-choice($target)) then $target/ancestor::*[not(f:inside-choice(.))][1] else $target" as="node()"/>

        <xsl:sequence select="f:generate-href($target)"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate a href-attribute.</xd:short>
        <xd:detail>
            <p>href attributes need to point to the correct file and element, depending on whether we generate 
            a monolithic or multiple files using the splitter. This file contains the named templates for the 
            monolithic variant.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:generate-href" as="xs:string">
        <xsl:param name="target" as="element()"/>

        <xsl:value-of select="'#' || f:generate-id($target)"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate a href-attribute for footnotes.</xd:short>
        <xd:detail>
            <p>Footnote href attributes are the same as normal hrefs in
            single file operation.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:generate-footnote-href" as="xs:string">
        <xsl:param name="target" as="element()"/>

        <xsl:value-of select="f:generate-href($target)"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate a href-attribute for apparatus notes.</xd:short>
        <xd:detail>
            <p>Apparatus-note href attributes are the same as normal hrefs in
            single file operation.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:generate-apparatus-note-href" as="xs:string">
        <xsl:param name="target" as="element()"/>

        <xsl:value-of select="f:generate-href($target)"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate a href-attribute to the xref-table in the colophon.</xd:short>
        <xd:detail>
            <p>The xref-table href attributes are the same as normal hrefs in
         single file operation, followed by 'ext'.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:generate-xref-table-href" as="xs:string">
        <xsl:param name="target" as="element()"/>

        <xsl:value-of select="f:generate-href($target) || 'ext'"/>
    </xsl:function>


</xsl:stylesheet>
