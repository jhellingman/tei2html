<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f xd xs">

    <xd:doc type="stylesheet">
        <xd:short>ePub-specific utility templates and functions, used by tei2epub</xd:short>
        <xd:detail>This stylesheet contains utility templates and functions, used by tei2epub only.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2019, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Generate an href attribute safely.</xd:short>
        <xd:detail>
            <p>This function generates a href to the appropriate file, depending on where in the
            source file the element referenced appears.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:generate-safe-href" as="xs:string">
        <xsl:param name="target" as="node()"/>

        <!-- When the target is inside a choice element, it may not be rendered in the output: point at the first ancestor not inside the choice. -->
        <xsl:variable name="target" select="if (f:inside-choice($target)) then $target/ancestor::*[not(f:inside-choice(.))][1] else $target" as="node()"/>

        <!-- When the target is inside a footnote, it may end up in a different file, so some special handling applies. -->
        <xsl:sequence select="if (f:inside-footnote($target)) then f:generate-footnote-href($target) else f:generate-href($target)"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate an href attribute.</xd:short>
        <xd:detail>
            <p>href attributes need to point to the correct file and element, depending on
            whether we generate a monolithic or multiple files using the splitter.
            This file contains the named templates for the split-file variant.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:generate-href" as="xs:string">
        <xsl:param name="target" as="element()"/>

        <xsl:value-of select="f:determine-filename($target) || '#' || f:generate-id($target)"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate an href attribute for a footnote.</xd:short>
        <xd:detail>
            <p>Footnotes generate two items: a marker in the text, and the actual footnote
            content at the end of the chapter. These two need to be linked together.
            The marker should link to the actual note, and the note should link back
            to the marker. The latter is handled in the standard way. For the former,
            we need to find out in which file the footnote referred to has 
            ended up. This is typically the same file that contains the last element 
            of the containing div1.</p>

            <p>The strategy is thus to first find our div1 ancestor and then the last
            element of it. We then find out in which file that has ended
            up. Links to footnotes then can point to that file.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:generate-footnote-href" as="xs:string">
        <xsl:param name="target" as="element()"/>

        <xsl:variable name="targetFile">
            <xsl:choose>
                <!-- If we have an explicit call for a footnote section, all footnotes are in there. -->
                <xsl:when test="root($target)//divGen[@type = ('Footnotes', 'footnotes', 'footnotesBody')]">
                    <xsl:value-of select="f:determine-filename((root($target)//divGen[@type = ('Footnotes', 'footnotes', 'footnotesBody')])[1])"/>
                </xsl:when>

                <!-- Footnotes to div0 elements (i.e., those not in a div1) are in the same fragment as the note itself. -->
                <xsl:when test="not($target/ancestor::div1)">
                    <xsl:value-of select="f:determine-filename($target)"/>
                </xsl:when>

                <!-- Footnotes to div1 elements are found in the last fragment of the div1. -->
                <xsl:otherwise>
                    <xsl:value-of select="f:determine-filename(($target/ancestor::div1[not(ancestor::q)]/*)[last()])"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="$targetFile || '#' || f:generate-id($target)"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate an href attribute for an apparatus note.</xd:short>
        <xd:detail>
            <p>Apparatus notes are created from a <code>divGen</code> element with type Apparatus. The instance of the <code>divGen</code> element that
            generates the note content is the first one following the node.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:generate-apparatus-note-href" as="xs:string">
        <xsl:param name="target" as="element()"/>

        <xsl:variable name="targetFile" select="f:determine-filename(($target/following::divGen[@type='Apparatus' or @type='apparatus'])[1])"/>
        <xsl:value-of select="$targetFile || '#' || f:generate-id($target)"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate a href attribute to the table of external references.</xd:short>
        <xd:detail>
            <p>A table of external references adds an extra level of dereferencing for external references
            in the book, using a separate cross-reference table at the end. The xref-table href attributes 
            always point to somewhere in the colophon.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:generate-xref-table-href">
        <xsl:param name="target" as="element()"/>

        <xsl:variable name="targetFile">
            <xsl:choose>
                <!-- We should have an explicit call for a colophon section; the xref-table is in there. -->
                <xsl:when test="root($target)//divGen[@type='Colophon']">
                    <xsl:value-of select="f:determine-filename((root($target)//divGen[@type='Colophon'])[1])"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="f:log-error('No colophon for cross-reference table in document', ())"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="$targetFile || '#' || f:generate-id($target) || 'ext'"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Copy an XML file.</xd:short>
        <xd:detail>Copy an XML file from a source location to the output location.</xd:detail>
    </xd:doc>

    <xsl:template name="copy-xml-file">
        <xsl:param name="filename" as="xs:string"/>

        <xsl:copy-of select="f:log-info('Copying XML file: {1} to: {2}.', ($filename, $path))"/>

        <xsl:result-document format="xml-noindent" href="{$path}/{$filename}">
            <xsl:copy-of select="document($filename, .)"/>
        </xsl:result-document>
    </xsl:template>


    <xsl:function name="f:is-epub30" as="xs:boolean">
        <xsl:sequence select="$epubversion = '3.0' or $epubversion = '3.0.1'"/>
    </xsl:function>

    <xsl:function name="f:is-epub31" as="xs:boolean">
        <xsl:sequence select="$epubversion = '3.1'"/>
    </xsl:function>

    <xsl:function name="f:epub-main-version" as="xs:string">
        <xsl:value-of select="substring($epubversion, 1,3)"/>
    </xsl:function>



</xsl:stylesheet>
