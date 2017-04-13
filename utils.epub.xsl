<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="xd xs"
    version="2.0"
    >

    <xd:doc type="stylesheet">
        <xd:short>ePub-specific utility templates and functions, used by tei2epub</xd:short>
        <xd:detail>This stylesheet contains a number of utility templates and functions, used by tei2epub only.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011-2014, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Generate an href attribute.</xd:short>
        <xd:detail>
            <p>href attributes need to point to the correct file and element, depending on
            whether we generate a monolithic or multiple files using the splitter.
            This file contains the named templates for the split-file variant.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="generate-href">
        <xsl:param name="target" select="." as="element()"/>

        <xsl:variable name="targetfile">
            <xsl:call-template name="splitter-generate-filename-for">
                <xsl:with-param name="node" select="$target"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:value-of select="$targetfile"/>#<xsl:value-of select="f:generate-id($target)"/>
    </xsl:template>


    <xsl:function name="f:generate-href" as="xs:string">
        <xsl:param name="target" as="element()"/>

        <xsl:variable name="targetfile">
            <xsl:call-template name="splitter-generate-filename-for">
                <xsl:with-param name="node" select="$target"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:value-of select="concat($targetfile, '#', f:generate-id($target))"/>
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

    <xsl:template name="generate-footnote-href">
        <xsl:param name="target" select="." as="element()"/>

        <xsl:variable name="targetfile">
            <xsl:choose>
                <!-- If we have an explicit call for a footnote section, all footnotes are in there -->
                <xsl:when test="//divGen[@type='Footnotes' or @type='footnotes' or @type='footnotesBody']">
                    <xsl:call-template name="splitter-generate-filename-for">
                        <xsl:with-param name="node" select="(//divGen[@type='Footnotes' or @type='footnotes' or @type='footnotesBody'])[1]"/>
                    </xsl:call-template>
                </xsl:when>

                <!-- Footnotes to div0 elements are in the same fragment as the note itself -->
                <xsl:when test="not(ancestor::div1)">
                    <xsl:call-template name="splitter-generate-filename-for">
                        <xsl:with-param name="node" select="$target"/>
                    </xsl:call-template>
                </xsl:when>

                <!-- Footnotes to div1 elements are found in the last fragment of the div1 -->
                <xsl:otherwise>
                    <xsl:call-template name="splitter-generate-filename-for">
                        <xsl:with-param name="node" select="$target/ancestor::div1[not(ancestor::q)]/*[position() = last()]"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="$targetfile"/>#<xsl:value-of select="f:generate-id($target)"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate an href attribute for an apparatus note.</xd:short>
        <xd:detail>
            <p>Apparatus notes are created from a <code>divGen</code> element with type Apparatus. The instance of the <code>divGen</code> element that
            generates the note content is the first one following the node.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="generate-apparatus-note-href">
        <xsl:param name="target" select="." as="element()"/>

        <xsl:variable name="targetfile">
            <xsl:call-template name="splitter-generate-filename-for">
                <xsl:with-param name="node" select="($target/following::divGen[@type='Apparatus' or @type='apparatus'])[1]"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:value-of select="$targetfile"/>#<xsl:value-of select="f:generate-id($target)"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate a href attribute to the table of external references.</xd:short>
        <xd:detail>
            <p>A table of external references adds an extra level of dereferencing for external references
            in the book, using a separate cross-reference table at the end. The xref-table href attributes 
            always point to somewhere in the colophon.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="generate-xref-table-href">
        <xsl:param name="target" select="." as="element()"/>

        <xsl:variable name="targetfile">
            <xsl:choose>
                <!-- We should have an explicit call for a colophon section, the xref-table is in there -->
                <xsl:when test="//divGen[@type='Colophon']">
                    <xsl:call-template name="splitter-generate-filename-for">
                        <xsl:with-param name="node" select="(//divGen[@type='Colophon'])[1]"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="$targetfile"/>#<xsl:value-of select="f:generate-id($target)"/><xsl:text>ext</xsl:text>
    </xsl:template>


    <xd:doc>
        <xd:short>Copy an XML file.</xd:short>
        <xd:detail>Copy an XML file from a source location to the output location.</xd:detail>
    </xd:doc>

    <xsl:template name="copy-xml-file">
        <xsl:param name="filename" as="xs:string"/>

        <xsl:copy-of select="f:logInfo('Copying XML file: {1} to: {2}.', ($filename, $path))"/>

        <xsl:result-document format="xml-noindent" href="{$path}/{$filename}">
            <xsl:copy-of select="document($filename, .)"/>
        </xsl:result-document>
    </xsl:template>


</xsl:stylesheet>
