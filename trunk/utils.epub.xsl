<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet with various utily templates, to be imported in tei2html.xsl.

    Requires: 
        localization.xsl    : templates for localizing strings.
        messages.xsl        : stores localized messages in variables.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"
    >


    <!-- href attributes 

    href attributes need to point to the correct file and element, depending on
    whether we generate a monolithic or multiple files using the splitter.
    This file contains the named templates for the split-file variant.

    -->


    <xsl:template name="generate-href">
        <xsl:param name="target" select="."/>

        <xsl:variable name="targetfile">
            <xsl:call-template name="splitter-generate-filename-for">
                <xsl:with-param name="node" select="$target"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:value-of select="$targetfile"/>#<xsl:call-template name="generate-id-for"><xsl:with-param name="node" select="$target"/></xsl:call-template>
    </xsl:template>


    <!-- footnote href attributes

    Footnotes generate two items: a marker in the text, and the actual footnote
    content at the end of the chapter. These two need to be linked together.
    The marker should link to the actual note, and the note should link back
    to the marker. The latter is handled in the standard way. For the former,
    we need to find out in which file the footnote referred to has 
    ended up. This is typically the same file that contains the last element 
    of the containing div1.

    The strategy is this to find first our div1 ancestor and then the last
    element of it. We then find out in which file that has ended
    up. Links to footnotes then can point to that file.

    -->


    <xsl:template name="generate-footnote-href">
        <xsl:param name="target" select="."/>

        <xsl:if test="not(ancestor::div1)">
            <xsl:message terminate="no">Error: not yet implemented handling of footnotes outside div1 elements.</xsl:message>
        </xsl:if>

        <xsl:variable name="targetfile">
            <xsl:call-template name="splitter-generate-filename-for">
                <xsl:with-param name="node" select="$target/ancestor::div1[not(ancestor::q)]/*[position() = last()]"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:value-of select="$targetfile"/>#<xsl:call-template name="generate-id-for"><xsl:with-param name="node" select="$target"/></xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
