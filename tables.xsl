<!DOCTYPE xsl:stylesheet>
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
        <xd:copyright>2015, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:template match="table">
        <xsl:apply-templates select="." mode="render-table"/>
    </xsl:template>

    <xd:doc>
        <xd:short>Render a table in HTML (1).</xd:short>
        <xd:detail>
            <p>At the top-level, the code differentiates between an inline table, and one
            at the block level; the former get wrapped in a HTML <code>span</code> element, the latter in
            a <code>div</code> element.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="table" mode="render-table">
        <xsl:choose>
            <xsl:when test="f:rend-value(@rend, 'position') = 'inline' or f:rend-value(@rend, 'class')  = 'intralinear'">
                <span class="table">
                    <xsl:call-template name="set-lang-id-attributes"/>
                    <xsl:apply-templates mode="tablecaption" select="head"/>
                    <xsl:call-template name="inner-table"/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="closepar"/>
                <div class="table">
                    <xsl:call-template name="set-lang-id-attributes"/>
                    <xsl:apply-templates mode="tablecaption" select="head"/>
                    <xsl:call-template name="inner-table"/>
                </div>
                <xsl:call-template name="reopenpar"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Render a table in HTML (2).</xd:short>
        <xd:detail>
            <p>The second step in handling tables is deciding whether they need to be
            doubled-up. This is indicated by the <code>columns(2)</code> value in the
            <code>@rend</code>-attribute.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="inner-table">
        <xsl:variable name="context" select="." as="element(table)"/>

        <xsl:choose>
            <xsl:when test="f:has-rend-value(@rend, 'columns')">
                <xsl:call-template name="n-up-table"/>
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
        <xsl:variable name="context" select="." as="element(table)"/>

        <table>
            <xsl:call-template name="generate-rend-class-attribute-if-needed"/>

            <!-- ePub3 doesn't like summaries on tables -->
            <xsl:if test="f:has-rend-value(@rend, 'summary') and $outputformat != 'epub'">
                <xsl:attribute name="summary">
                    <xsl:value-of select="f:rend-value(@rend, 'summary')"/>
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


    <xd:doc>
        <xd:short>Handle a table caption.</xd:short>
        <xd:detail>
            <p>The HTML caption element is not correctly handled in some browsers, so lift them out and make them headers.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template mode="tablecaption" match="head">
        <h4 class="tablecaption">
            <xsl:call-template name="set-lang-id-attributes"/>

            <!-- TODO: improve handling of table/@rend attribute here -->
            <xsl:if test="f:rend-value(../@rend, 'align') = 'center'">
                <xsl:attribute name="class">aligncenter</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </h4>
    </xsl:template>


    <xd:doc>
        <xd:short>Eliminate table headers.</xd:short>
        <xd:detail>
            <p>The table header is already handled in the mode <code>tablecaption</code>, so can be omitted.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="table/head"/>


    <xd:doc>
        <xd:short>Handle a table row.</xd:short>
        <xd:detail>
            <p>Handle a table row. Determine the <code>class</code> and <code>id</code> attributes, and render its content.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="row">
        <tr>
            <xsl:if test="f:determine-row-class(.) != ''">
                <xsl:attribute name="class"><xsl:value-of select="f:determine-row-class(.)"/></xsl:attribute>
            </xsl:if>

            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle a table cell.</xd:short>
        <xd:detail>
            <p>Handle a table cell. Deal with spans and determine the <code>class</code> and <code>id</code> attributes, and render its content.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="cell">
        <td>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:call-template name="cell-span"/>
            <xsl:call-template name="cell-rend"/>

            <xsl:choose>
                <xsl:when test="@rows &gt; 1 and normalize-space(.) = '{'">
                    <xsl:call-template name="insert-left-brace"/>
                </xsl:when>
                <xsl:when test="@rows &gt; 1 and normalize-space(.) = '}'">
                    <xsl:call-template name="insert-right-brace"/>
                </xsl:when>
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


    <xsl:template name="insert-right-brace">
        <xsl:call-template name="insertimage2">
            <xsl:with-param name="alt" select="''"/>
            <xsl:with-param name="filename" select="concat('images/rbrace', @rows, '.png')"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="insert-left-brace">
        <xsl:call-template name="insertimage2">
            <xsl:with-param name="alt" select="''"/>
            <xsl:with-param name="filename" select="concat('images/lbrace', @rows, '.png')"/>
        </xsl:call-template>
    </xsl:template>


    <xd:doc>
        <xd:short>Determine spanned rows and columns.</xd:short>
        <xd:detail>
            <p>Determine how many rows and columns we span, and set HTML attributes accordingly.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="cell-span">
        <xsl:variable name="context" select="." as="element(cell)"/>

        <xsl:if test="@cols and (@cols > 1)">
            <xsl:attribute name="colspan"><xsl:value-of select="@cols"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="@rows and (@rows > 1)">
            <xsl:attribute name="rowspan"><xsl:value-of select="@rows"/></xsl:attribute>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Determine cell rendering.</xd:short>
        <xd:detail>
            <p>Determine how to render a cell, using a class attribute with multiple values; we may need to supply up to five class names for rendering:</p>

            <ol>
                <li>one based on the <code>@role</code> attribute,</li>
                <li>one based on the column-level <code>@rend</code> attribute,</li>
                <li>one based on the row-level <code>@rend</code> attribute, and</li>
                <li>one based on the cell-level <code>@rend</code> attribute.</li>
                <li>one to four, based on the position of the cell in the table; the following classes can appear:
                        for data-cells: <code>cellTop cellRight cellBottom cellLeft</code>;
                        for header-cells: <code>cellHeadTop cellHeadRight cellHeadBottom cellHeadLeft</code>.</li>
            </ol>
        </xd:detail>
    </xd:doc>

    <xsl:template name="cell-rend">
        <xsl:variable name="context" select="." as="element(cell)"/>

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

        <xsl:if test="f:has-rend-value(@rend, 'image')">
            <xsl:call-template name="insertimage2">
                <xsl:with-param name="alt" select="''"/>
            </xsl:call-template>
        </xsl:if>

    </xsl:template>


    <!-- Find rendering information for the current row (our parent) -->
    <xsl:template name="cell-rend-row">
        <xsl:variable name="context" select="." as="element(cell)"/>

        <xsl:if test="../@rend">
            <xsl:call-template name="generate-rend-class-name">
                <xsl:with-param name="rend" select="../@rend"/>
                <xsl:with-param name="node" select=".."/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <!-- Find rendering information for the current column -->
    <xsl:template name="cell-rend-col">
        <xsl:variable name="context" select="." as="element(cell)"/>

        <xsl:variable name="position">
            <xsl:call-template name="find-column-number"/>
        </xsl:variable>
        <xsl:for-each select="../../column[position() = $position]">
            <xsl:call-template name="generate-rend-class-name-if-needed"/>
        </xsl:for-each>
    </xsl:template>

    <!-- Find relative postion of cell in table -->
    <xsl:template name="cell-pos-class">
        <xsl:variable name="context" select="." as="element(cell)"/>

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
        <xsl:variable name="context" select="." as="element(cell)"/>

        <!-- The column corresponding to this cell, taking into account preceding @cols attributes -->
        <!-- If we have the @col attribute, we will use this value -->
        <!-- The alternative simple calculation will fail in cases where @rows attributes in preceding rows cause cells to be skipped. -->
        <xsl:value-of select="if (@col) then @col else sum(preceding-sibling::cell[@cols]/@cols) + count(preceding-sibling::cell[not(@cols)]) + 1"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Determine the class to apply to a row.</xd:short>
        <xd:detail>
            <p>Determine the class to apply to a row. This is based on the <code>@role</code> attribute and the class
            indicated in the <code>@rend</code> attribute.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:determine-row-class" as="xs:string">
        <xsl:param name="node" as="node()"/>

        <xsl:variable name="class">
            <xsl:if test="$node/@role and not($node/@role='data')">
                <xsl:value-of select="$node/@role"/>
                <xsl:text> </xsl:text>
            </xsl:if>
            <!-- Due to the way HTML deals with CSS on tr elements, the @rend attribute here is handled on the individual cells; however, we do extract the explicitly named class. -->
            <xsl:if test="f:has-rend-value($node/@rend, 'class')">
                <xsl:value-of select="f:rend-value($node/@rend, 'class')"/>
                <xsl:text> </xsl:text>
            </xsl:if>
        </xsl:variable>

        <xsl:value-of select="normalize-space($class)"/>
    </xsl:function>


    <xd:doc>
        <xd:short>N-up a table.</xd:short>
        <xd:detail>
            <p>Render a table in n-up format, that is, using n times the number of
            columns and 1/n-th the number of rows; repeating the heading-rows on top.
            Note that this may fail if rows are spanned. The case of number
            of data-rows not divisible by n is handled (the last column will just be partially-filled.)</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="n-up-table">
        <xsl:variable name="context" select="." as="element(table)"/>

        <xsl:variable name="n" as="xs:integer">
            <xsl:value-of select="number(substring-before(substring-after(@rend, 'columns('), ')'))"/>
        </xsl:variable>

        <xsl:variable name="item-order" as="xs:string">
            <xsl:value-of select="substring-before(substring-after(@rend, 'item-order('), ')')"/>
        </xsl:variable>

        <!-- Get labels and units first (simplified model, see templates dealing with a normal-table for more complex situation). -->
        <xsl:variable name="headers" select="row[not(preceding-sibling::row[not(@role='label' or @role='unit')] or self::row[not(@role='label' or @role='unit')])]"/>

        <!-- Get remainder of data  -->
        <xsl:variable name="rows" select="row[preceding-sibling::row[not(@role='label' or @role='unit')] or self::row[not(@role='label' or @role='unit')]]"/>

        <xsl:variable name="rowCount" select="ceiling(count($rows) div $n)"/>

        <table>
            <xsl:call-template name="generate-rend-class-attribute-if-needed"/>

            <!-- ePub3 doesn't like summaries on tables -->
            <xsl:if test="f:has-rend-value(@rend, 'summary') and $outputformat != 'epub'">
                <xsl:attribute name="summary">
                    <xsl:value-of select="f:rend-value(@rend, 'summary')"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:if test="$headers">
                <!-- Repeat headers n times -->
                <thead>
                    <xsl:for-each select="1 to count($headers)">
                        <xsl:variable name="headerRow" select="."/>
                        <tr>
                            <xsl:if test="f:determine-row-class($headers[$headerRow]) != ''">
                                <xsl:attribute name="class"><xsl:value-of select="f:determine-row-class($headers[$headerRow])"/></xsl:attribute>
                            </xsl:if>

                            <xsl:for-each select="1 to $n">
                                <xsl:variable name="i" select="."/>
                                <xsl:for-each select="$headers[$headerRow]/cell">
                                    <!-- Insert a dummy cell between doubled-up columns -->
                                    <xsl:if test="$i &gt; 1 and position() = 1">
                                        <td class="cellDoubleUp"/>
                                    </xsl:if>
                                    <xsl:apply-templates select="."/>
                                </xsl:for-each>
                            </xsl:for-each>
                        </tr>
                    </xsl:for-each>
                </thead>
            </xsl:if>

            <!-- Take data from each part -->
            <tbody>
                <xsl:choose>
                    <xsl:when test="$item-order = 'row-first'">
                        <xsl:for-each-group select="$rows" group-by="(position() - 1) idiv $n">
                            <tr>
                                <xsl:for-each select="current-group()/cell">
                                    <!-- Insert a dummy cell between doubled-up columns -->
                                    <xsl:if test="position() &gt; 1 and count(./preceding-sibling::*) = 0">
                                        <td class="cellDoubleUp"/>
                                    </xsl:if>
                                    <xsl:apply-templates select="."/>
                                </xsl:for-each>
                            </tr>
                        </xsl:for-each-group>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each-group select="$rows" group-by="(position() - 1) mod $rowCount">
                            <tr>
                                <xsl:for-each select="current-group()/cell">
                                    <!-- Insert a dummy cell between doubled-up columns -->
                                    <xsl:if test="position() &gt; 1 and count(./preceding-sibling::*) = 0">
                                        <td class="cellDoubleUp"/>
                                    </xsl:if>
                                    <xsl:apply-templates select="."/>
                                </xsl:for-each>
                            </tr>
                        </xsl:for-each-group>
                    </xsl:otherwise>
                </xsl:choose>
            </tbody>
        </table>
    </xsl:template>

</xsl:stylesheet>
