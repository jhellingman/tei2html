<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to format tables, to be imported in tei2html.xsl.

    Requires:
        localization.xsl    : templates for localizing strings.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="f xd xs"
    version="2.0"
    >

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to translate the TEI table model to HTML tables.</xd:short>
        <xd:detail><p>This stylesheet translates the TEI table model to HTML tables. This assumes
        that in the source, cells 'spanned' by other cells are omitted in the data.</p>

        <p>To accommodate attributes common to all cells in a column, this code
        uses additional <code>column</code> elements not present in the TEI table
        model.</p>

        <p>The formatting of a cell is derived from the <code>@rend</code> attribute on the
        column, and can be overriden by the <code>@rend</code> attribute on the cell itself.
        Both <code>@rend</code> attributes are converted to classes, where care needs to be
        taken that the column related classes are always defined before
        the cell classes, as to make this work out correctly with the
        CSS precedence rules. Note that all identical <code>@rend</code> attributes are
        mapped to the same class, and that those might occur in preceeding
        tables, we thus have to generate all column-related classes before
        those related to cells.</p>

        <p>In the cell itself, we will find at most two generated class
        attributes: one for the column and one for the cell itself.</p>
        </xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2012, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:template match="table">
        <xsl:call-template name="closepar"/>
        <xsl:apply-templates select="." mode="render-table"/>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>

    <xd:doc>
        <xd:short>Render a table in HTML.</xd:short>
        <xd:detail>
            <p>At the top-level, the code differentiates between an inline table, and one
            at the block level; the former get wrapped in a HTML span element, the latter in
            a div element.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="table" mode="render-table">
        <xsl:choose>
            <xsl:when test="contains(@rend, 'position(inline)') or contains(@rend, 'class(intralinear)')">
                <span class="table">
                    <xsl:call-template name="set-lang-id-attributes"/>
                    <xsl:apply-templates mode="tablecaption" select="head"/>
                    <xsl:call-template name="inner-table"/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <div class="table">
                    <xsl:call-template name="set-lang-id-attributes"/>
                    <xsl:apply-templates mode="tablecaption" select="head"/>
                    <xsl:call-template name="inner-table"/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Render a table in HTML (2).</xd:short>
        <xd:detail>
            <p>The second step in handling tables is deciding whether they need to be
            doubled-up.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="inner-table">
        <xsl:choose>
            <xsl:when test="contains(@rend, 'columns(2)')">
                <xsl:call-template name="doubleup-table"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="normal-table"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Render a table in HTML (3).</xd:short>
        <xd:detail>
            <p>Now we are ready to actually format a normal (not-doubled-up) table.
            When possible, the header rows (with the role-attribute having the values
            label or unit) are treated separately from the data-rows.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="normal-table">
        <table>
            <xsl:call-template name="generate-rend-class-attribute-if-needed"/>

            <!-- Stretch to the size of the outer div if the width is set explicitly -->
            <xsl:if test="contains(@rend, 'width(')">
                <xsl:attribute name="width">100%</xsl:attribute>
            </xsl:if>

            <xsl:if test="contains(@rend, 'summary(')">
                <xsl:attribute name="summary">
                    <xsl:value-of select="substring-before(substring-after(@rend, 'summary('), ')')"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:choose>
                <!-- If a table starts with label or unit roles, use the thead and tbody elements in HTML -->
                <xsl:when test="row[1][@role='label' or @role='unit']">
                    <thead>
                        <xsl:apply-templates select="*[not(preceding-sibling::row[not(@role='label' or @role='unit')] or self::row[not(@role='label' or @role='unit')])]"/>
                    </thead>
                    <tbody>
                        <xsl:apply-templates select="*[preceding-sibling::row[not(@role='label' or @role='unit')] or self::row[not(@role='label' or @role='unit')]]"/>
                    </tbody>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </table>
    </xsl:template>


    <!-- The HTML caption element is not correctly handled in some browsers, so lift them out and make them headers. -->
    <xsl:template mode="tablecaption" match="head">
        <h4 class="tablecaption">
            <xsl:call-template name="set-lang-id-attributes"/>

            <!-- TODO: improve handling of table/@rend attribute here -->
            <xsl:if test="contains(../@rend, 'align(center)')">
                <xsl:attribute name="class">aligncenter</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </h4>
    </xsl:template>


    <!-- headers already handled in mode tablecaption. -->
    <xsl:template match="table/head"/>


    <xsl:template match="row">
        <tr>
            <xsl:variable name="class">
                <xsl:if test="@role and not(@role='data')"><xsl:value-of select="@role"/><xsl:text> </xsl:text></xsl:if>
                <!-- Due to the way HTML deals with CSS on tr elements, the @rend attribute here is handled on the individual cells -->
            </xsl:variable>

            <xsl:if test="normalize-space($class) != ''">
                <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>
            </xsl:if>

            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>


    <xsl:template match="cell">
        <td>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:call-template name="cell-span"/>
            <xsl:call-template name="cell-rend"/>

            <xsl:choose>
                <xsl:when test="@role='sum'">
                    <span class="sum">
                        <xsl:apply-templates/>
                    </span>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </td>
    </xsl:template>


    <!-- Determine how many rows and columns we span, and set attributes accordingly. -->
    <xsl:template name="cell-span">
        <xsl:if test="@cols and (@cols > 1)">
            <xsl:attribute name="colspan"><xsl:value-of select="@cols"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="@rows and (@rows > 1)">
            <xsl:attribute name="rowspan"><xsl:value-of select="@rows"/></xsl:attribute>
        </xsl:if>
    </xsl:template>


    <!-- Here we may need to supply up to four class names for rendering:
         1. one for the @role attribute,
         2. one for the column-level @rend attribute,
         3. one for the row-level @rend attribute, and
         4. one for the cell-level @rend attribute.
         5. one for the cell position in the table:
            cellTop cellRight cellBottom cellLeft
            cellHeadTop cellHeadRight cellHeadBottom cellHeadLeft
    -->
    <xsl:template name="cell-rend">

        <xsl:variable name="class">
            <xsl:if test="@role and not(@role='data' or @role='sum')"><xsl:value-of select="@role"/><xsl:text> </xsl:text></xsl:if>
            <xsl:call-template name="generate-rend-class-name-if-needed"/><xsl:text> </xsl:text>
            <xsl:call-template name="cell-rend-row"/><xsl:text> </xsl:text>
            <xsl:call-template name="cell-rend-col"/><xsl:text> </xsl:text>
            <xsl:call-template name="cell-pos-class"/>
        </xsl:variable>

        <xsl:if test="normalize-space($class) != ''">
            <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>
        </xsl:if>

        <xsl:if test="contains(@rend, 'image(')">
            <xsl:call-template name="insertimage2">
                <xsl:with-param name="alt">
                    <xsl:value-of select="x"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>

    </xsl:template>


    <!-- Find rendering information for the current row (our parent) -->
    <xsl:template name="cell-rend-row">
        <xsl:if test="../@rend">
            <xsl:call-template name="generate-rend-class-name">
                <xsl:with-param name="rend" select="../@rend"/>
                <xsl:with-param name="node" select=".."/>
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

    <!-- Find relative postion of cell in table -->
    <xsl:template name="cell-pos-class">

        <!-- A cell is considered part of the table head if it has a @role of label or unit -->
        <xsl:variable name="prefix" select="if (..[@role='label' or @role='unit']) then 'cellHead' else 'cell'"/>

        <xsl:choose>
            <!-- Do we have the @col attribute on the table, then we can use those attributes -->
            <xsl:when test="@col">
                <xsl:if test="@col = 1"><xsl:value-of select="$prefix"/><xsl:text>Left </xsl:text></xsl:if>
                <xsl:if test="@col + @cols - 1 = ../../@cols"><xsl:value-of select="$prefix"/><xsl:text>Right </xsl:text></xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="not(preceding-sibling::cell)"><xsl:value-of select="$prefix"/><xsl:text>Left </xsl:text></xsl:if>
                <xsl:if test="not(following-sibling::cell)"><xsl:value-of select="$prefix"/><xsl:text>Right </xsl:text></xsl:if>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="..[@role='label' or @role='unit']">
                <xsl:if test="not(../preceding-sibling::row)"><xsl:text>cellHeadTop </xsl:text></xsl:if>
                <xsl:if test="not(../following-sibling::row[@role='label' or @role='unit'])"><xsl:text>cellHeadBottom </xsl:text></xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="not(../preceding-sibling::row)"><xsl:text>cellTop </xsl:text></xsl:if>
                <xsl:if test="not(../following-sibling::row)"><xsl:text>cellBottom </xsl:text></xsl:if>
            </xsl:otherwise>
        </xsl:choose>

        <!-- Handle the case when a bottom cell is spanned -->
        <xsl:if test="@rows &gt; 1  and @row + @rows - 1 = ../../@headrows"><xsl:value-of select="$prefix"/><xsl:text>Bottom </xsl:text></xsl:if>
        <xsl:if test="@rows &gt; 1  and @row + @rows - 1 = ../../@rows"><xsl:value-of select="$prefix"/><xsl:text>Bottom </xsl:text></xsl:if>
    </xsl:template>


    <!-- Find the column number of the current cell -->
    <xsl:template name="find-column-number">
        <!-- The column corresponding to this cell, taking into account preceding @cols attributes -->
        <!-- If we have the @col attribute, we will use this value -->
        <!-- The alternative simple calculation will fail in cases where @rows attributes in preceding rows cause cells to be skipped. -->
        <xsl:value-of select="if (@col) then @col else sum(preceding-sibling::cell[@cols]/@cols) + count(preceding-sibling::cell[not(@cols)]) + 1"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Double-up a table.</xd:short>
        <xd:detail>
            <p>Render a table in doubled-up format, that is, using double the number of
            columns and half the number of rows; repeating the heading-rows on top.
            Note that this may fail if rows are spanned. The case of an odd number
            of data-rows is handled (the last row will just be half-filled.)</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="doubleup-table">

        <!-- Get labels and units first (simplified model, see template normal-table for more complex situation -->
        <xsl:variable name="headers" select="*[not(preceding-sibling::row[not(@role='label' or @role='unit')] or self::row[not(@role='label' or @role='unit')])]"/>

        <!-- Get remainder of data  -->
        <xsl:variable name="rows" select="*[preceding-sibling::row[not(@role='label' or @role='unit')] or self::row[not(@role='label' or @role='unit')]]"/>
        <xsl:variable name="halfway" select="ceiling(count($rows) div 2)"/>
        <xsl:variable name="rows1" select="$rows[position() &lt; $halfway + 1]"/>
        <xsl:variable name="rows2" select="$rows[position() &gt; $halfway]"/>

        <table>
            <xsl:if test="$headers">
                <!-- Set headers twice -->
                <thead>
                    <xsl:for-each select="$headers">
                        <tr>
                            <xsl:apply-templates select="./cell"/>
                            <xsl:apply-templates select="./cell"/>
                        </tr>
                    </xsl:for-each>
                </thead>
            </xsl:if>

            <!-- Take data from each half -->
            <tbody>
                <xsl:for-each select="$rows1">
                    <xsl:variable name="position" select="position()"/>
                    <tr>
                        <xsl:apply-templates select="./cell"/>
                        <xsl:apply-templates select="$rows2[$position]/cell"/>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </xsl:template>


</xsl:stylesheet>
