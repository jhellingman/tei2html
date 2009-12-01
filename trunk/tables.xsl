<!DOCTYPE xsl:stylesheet [

    <!ENTITY tab        "&#x09;">
    <!ENTITY lf         "&#x0A;">
    <!ENTITY cr         "&#x0D;">
    <!ENTITY deg        "&#176;">
    <!ENTITY ldquo      "&#x201C;">
    <!ENTITY nbsp       "&#160;">
    <!ENTITY mdash      "&#x2014;">
    <!ENTITY prime      "&#x2032;">
    <!ENTITY Prime      "&#x2033;">
    <!ENTITY plusmn     "&#x00B1;">
    <!ENTITY frac14     "&#x00BC;">
    <!ENTITY frac12     "&#x00BD;">
    <!ENTITY frac34     "&#x00BE;">

]>
<!--

    Stylesheet to format tables, to be imported in tei2html.xsl.

    Requires: 
        localization.xsl    : templates for localizing strings.
        messages.xsl        : stores localized messages in variables.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"
    >

    <!--====================================================================-->
    <!-- Tables: Translate the TEI table model to HTML tables.

         To accommodate attributes common to all cells in a column, this code
         uses additional <column> elements not present in the TEI table
         model.
         
         The formatting of a cell is derived from the rend attribute on the
         column, and can be overriden by the rend attribute on the cell itself.
         Both rend attributes are converted to classes, where care needs to be
         taken that the column related classes are always defined before
         the cell classes, as to make this work out correctly with the
         CSS precedence rules. Note that all identical rend attributes are
         mapped to the same class, and that those might occur in preceeding
         tables, we thus have to generate all column related classes before
         that related to cells.

         In the cell itself, we will find at most two generated class 
         attributes: one for the column and one for the cell itself.
         
    -->


    <xsl:template match="table">
        <xsl:call-template name="closepar"/>
        <div>
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>

            <xsl:attribute name="class">
                <xsl:text>table </xsl:text>
                <xsl:call-template name="generate-rend-class-name-if-needed"/>
            </xsl:attribute>

            <xsl:apply-templates select="head" mode="tablecaption"/>

            <table>
                <!-- Stretch to the size of the outer div if the width is set explicitly -->
                <xsl:if test="contains(@rend, 'width(')">
                    <xsl:attribute name="width">100%</xsl:attribute>
                </xsl:if>

                <xsl:if test="contains(@rend, 'summary(')">
                    <xsl:attribute name="summary">
                        <xsl:value-of select="substring-before(substring-after(@rend, 'summary('), ')')"/>
                    </xsl:attribute>
                </xsl:if>

                <xsl:apply-templates select="head"/>
                <xsl:apply-templates select="row"/>
            </table>
        </div>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>


    <!-- HTML caption element is not correctly handled in some browsers, so lift them out and make them headers. -->

    <xsl:template match="head" mode="tablecaption">
        <h4 class="tablecaption">
            <xsl:call-template name="setLangAttribute"/>
            <xsl:if test="contains(../@rend, 'align(center)')">
                <xsl:attribute name="class">aligncenter</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </h4>
    </xsl:template>


    <!-- headers already handled. -->
    <xsl:template match="table/head"/>


    <xsl:template match="row">
        <tr valign="top">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>

    <xsl:template match="row[@role='label']/cell">
        <td valign="top">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:call-template name="cell-span"/>
            <b><xsl:apply-templates/></b>
        </td>
    </xsl:template>

    <xsl:template match="cell[@role='label']">
        <td valign="top">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:call-template name="cell-span"/>
            <b><xsl:apply-templates/></b>
        </td>
    </xsl:template>

    <xsl:template match="row[@role='unit']/cell">
        <td valign="top">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:call-template name="cell-span"/>
            <i><xsl:apply-templates/></i>
        </td>
    </xsl:template>

    <xsl:template match="cell[@role='unit']">
        <td valign="top">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:call-template name="cell-span"/>
            <i><xsl:apply-templates/></i>
        </td>
    </xsl:template>

    <xsl:template match="cell">
        <td valign="top">
            <xsl:call-template name="generate-id-attribute"/>
            <xsl:call-template name="setLangAttribute"/>
            <xsl:call-template name="cell-span"/>
            <xsl:apply-templates/>
        </td>
    </xsl:template>


    <xsl:template name="cell-span">
        <xsl:if test="@cols and (@cols > 1)">
            <xsl:attribute name="colspan"><xsl:value-of select="@cols"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="@rows and (@rows > 1)">
            <xsl:attribute name="rowspan"><xsl:value-of select="@rows"/></xsl:attribute>
        </xsl:if>

        <xsl:call-template name="cell-rend"/>
    </xsl:template>


    <!-- Here we potentially need to supply two class names for rendering: 
         one for the column-level rend attribute, and one for the cell-
         level rend attribute. -->
    <xsl:template name="cell-rend">

        <xsl:variable name="class">
            <xsl:if test="@role and not(@role = 'data')"><xsl:value-of select="@role"/><xsl:text> </xsl:text></xsl:if>
            <xsl:call-template name="generate-rend-class-name-if-needed"/><xsl:text> </xsl:text>
            <xsl:call-template name="cell-rend-col"/>
        </xsl:variable>

        <xsl:if test="normalize-space($class) != ''">
            <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>
        </xsl:if>

        <xsl:if test="contains(@rend, 'valign(')">
            <xsl:attribute name="valign"><xsl:value-of select="substring-before(substring-after(@rend, 'valign('), ')')"/></xsl:attribute>
        </xsl:if>

        <xsl:if test="contains(@rend, 'image(')">
            <xsl:call-template name="insertimage2">
                <xsl:with-param name="alt">
                    <xsl:value-of select="x"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>

    </xsl:template>


    <!-- Find rendering information for the current column -->
    <xsl:template name="cell-rend-col">
        <xsl:variable name="position">
            <xsl:call-template name="find-column-number"/>
        </xsl:variable>
        <xsl:for-each select="../../column[position() = $position]">
            <xsl:call-template name="generate-rend-class-name-if-needed"/>
        </xsl:for-each>
    </xsl:template>


    <!-- Find the column number of the current cell -->
    <xsl:template name="find-column-number">
        <!-- The position of the current cell -->
        <xsl:variable name="position">
            <xsl:value-of select="position()"/>
        </xsl:variable>
        <!-- The column corresponding to this cell, taking into account preceding @cols attributes -->
        <!-- Note that this simple calculation will fail in cases where @rows attributes in preceding rows cause cells to be skipped. -->
        <xsl:value-of select="sum(../cell[position() &lt; $position]/@cols) + count(../cell[position() &lt; $position and not(@cols)])"/>
    </xsl:template>


</xsl:stylesheet>
