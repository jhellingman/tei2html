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
        <xd:short>Stylesheet to translate the TEI table model to HTML tables.</xd:short>
        <xd:detail><p>This stylesheet translates the TEI table model to HTML tables. This assumes
        that in the source, cells 'spanned' by other cells are omitted in the data.</p>

        <p>To accommodate attributes common to all cells in a column, this code
        uses additional <code>column</code> elements not present in the TEI table
        model.</p>

        <p>The formatting of a cell is derived from the <code>@rend</code> attribute on the
        column, and can be overridden by the <code>@rend</code> attribute on the cell itself.
        Both <code>@rend</code> attributes are converted to classes, where care needs to be
        taken that the column related classes are always defined before
        the cell classes, as to make this work out correctly with the
        CSS precedence rules. Note that all identical <code>@rend</code> attributes are
        mapped to the same class, and that those might occur in preceding
        tables, we thus have to generate all column-related classes before
        those related to cells.</p>

        <p>In the cell itself, we will find at most two generated class
        attributes: one for the column and one for the cell itself.</p>
        </xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2015, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:template match="table">
        <xsl:copy-of select="f:show-debug-tags(.)"/>
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
            <xsl:when test="f:is-inline(.) or f:rend-value(@rend, 'class') = 'intralinear'">
                <span class="table">
                    <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                    <xsl:apply-templates mode="tablecaption" select="head"/>
                    <xsl:call-template name="inner-table"/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="closepar"/>
                <div class="table">
                    <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
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
        <xsl:context-item as="element(table)" use="required"/>

        <xsl:choose>
            <xsl:when test="f:has-rend-value(@rend, 'columns')">
                <xsl:call-template name="n-up-table"/>
            </xsl:when>

            <xsl:otherwise>
                <xsl:call-template name="normal-table"/>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:if test=".//note[f:is-table-note(.)][not(@sameAs)]">
            <div class="footnotes">
                <xsl:apply-templates select=".//note[f:is-table-note(.)][not(@sameAs)]" mode="footnotes">
                    <!-- Retain the order of markers, irrespective of the order of encoding the table -->
                    <xsl:sort select="@n"/>
                </xsl:apply-templates>
            </div>
        </xsl:if>
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
        <xsl:context-item as="element(table)" use="required"/>

        <table>
            <xsl:copy-of select="if (f:is-inline(.)) then f:set-class-attribute-with(., 'inlinetable') else f:set-class-attribute(.)"/>

            <!-- ePub3 doesn't like summaries on tables -->
            <xsl:if test="f:has-rend-value(@rend, 'summary') and not(f:is-epub())">
                <xsl:attribute name="summary">
                    <xsl:value-of select="f:rend-value(@rend, 'summary')"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:choose>
                <!-- If a table starts with label or unit roles, use the thead and tbody elements in HTML -->
                <xsl:when test="row[1][f:is-header-row(.)]">
                    <thead>
                        <xsl:apply-templates select="*[not(preceding-sibling::row[not(f:is-header-row(.))] or self::row[not(f:is-header-row(.))])]"/>
                    </thead>
                    <tbody>
                        <xsl:apply-templates select="*[preceding-sibling::row[not(f:is-header-row(.))] or self::row[not(f:is-header-row(.))]]"/>
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
            <p>The HTML caption element is not correctly handled in some browsers, so lift table headers out and make them HTML h4 elements.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template mode="tablecaption" match="head">
        <h4>
            <xsl:variable name="class" select="if (f:rend-value(../@rend, 'align') = 'center') then 'aligncenter' else '' || 'tablecaption'"/>
            <xsl:copy-of select="f:set-class-attribute-with(., $class)"/>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
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

            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle a table cell.</xd:short>
        <xd:detail>
            <p>Handle a table cell. Deal with spans and determine the <code>class</code> and <code>id</code> attributes, and render its content.</p>

            <p>Special handling for a cell that spans more than one row and contains only a brace symbol.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="cell">
        <td>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:call-template name="cell-span"/>
            <xsl:call-template name="cell-rend"/>

            <xsl:choose>
                <xsl:when test="@rows &gt; 1 and normalize-space(.) = '{'">
                    <xsl:if test="not(f:has-rend-value(@rend, 'image'))">
                        <xsl:copy-of select="f:output-image('images/lbrace' || @rows || '.png', '{')"/>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="@rows &gt; 1 and normalize-space(.) = '}'">
                    <xsl:if test="not(f:has-rend-value(@rend, 'image'))">
                        <xsl:copy-of select="f:output-image('images/rbrace' || @rows || '.png', '}')"/>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="f:is-sum-cell(.)">
                    <span class="sum">
                        <xsl:apply-templates/>
                    </span>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
            <!-- <xsl:copy-of select="f:handle-last-cell-in-footnote(.)"/> -->
        </td>
    </xsl:template>


    <!-- TODO: this should also be inside the last paragraph in the cell, if the cell has paragraphs -->
    <xsl:function name="f:handle-last-cell-in-footnote">
        <xsl:param name="cell" as="element(cell)"/>
        <xsl:variable name="row" as="element(row)" select="$cell/parent::row"/>
        <xsl:if test="not($cell/following-sibling::cell) and not($row/following-sibling::row)">
            <!-- We are a table in a footnote, the table is the last element of the footnote, and this is the last cell of the table -->
            <xsl:if test="f:inside-footnote($cell)">
                <xsl:variable name="note" select="$cell/ancestor::note[f:is-footnote(.)][1]"/>
                <xsl:if test="f:last-child-is-block-element($note)">
                    <xsl:apply-templates select="$note" mode="footnote-return-arrow"/>
                </xsl:if>
            </xsl:if>
        </xsl:if>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine spanned rows and columns.</xd:short>
        <xd:detail>
            <p>Determine how many rows and columns we span, and set HTML attributes accordingly.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="cell-span">
        <xsl:context-item as="element(cell)" use="required"/>

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
            <p>Determine how to render a cell, using a class attribute with multiple values; we may need to supply multiple class names for rendering:</p>

            <ol>
                <li>one based on the <code>@role</code> attribute,</li>
                <li>one based on the column-level <code>@rend</code> attribute,</li>
                <li>one based on the row-level <code>@rend</code> attribute, and</li>
                <li>one based on the cell-level <code>@rend</code> attribute.</li>
                <li>one based on the presence of a left or right brace as the content of a multi-row cell.</li>
                <li>one to four, based on the position of the cell in the table; the following classes can appear:
                        for data-cells: <code>cellTop cellRight cellBottom cellLeft</code>;
                        for header-cells: <code>cellHeadTop cellHeadRight cellHeadBottom cellHeadLeft</code>.</li>
            </ol>
        </xd:detail>
    </xd:doc>

    <xsl:template name="cell-rend">
        <xsl:context-item as="element(cell)" use="required"/>

        <xsl:variable name="class">
            <xsl:if test="@role and not(@role = ('data', 'sum'))"><xsl:value-of select="@role"/><xsl:text> </xsl:text></xsl:if>
            <xsl:if test="@rows > 1">rowspan </xsl:if>
            <xsl:if test="@cols > 1">colspan </xsl:if>
            <xsl:if test="@rows &gt; 1 and normalize-space(.) = '{'">leftbrace </xsl:if>
            <xsl:if test="@rows &gt; 1 and normalize-space(.) = '}'">rightbrace </xsl:if>
            <xsl:call-template name="cell-rend-row"/><xsl:text> </xsl:text>
            <xsl:call-template name="cell-rend-col"/><xsl:text> </xsl:text>
            <xsl:call-template name="cell-pos-class"/>
        </xsl:variable>
        <xsl:copy-of select="f:set-class-attribute-with(., $class)"/>

        <xsl:if test="f:has-rend-value(@rend, 'image')">
            <xsl:copy-of select="f:output-image(f:rend-value(@rend, 'image'), '')"/>
        </xsl:if>
    </xsl:template>


    <!-- Find rendering information for the current row (our parent) -->
    <xsl:template name="cell-rend-row">
        <xsl:context-item as="element(cell)" use="required"/>

        <xsl:if test="../@rend">
            <xsl:value-of select="f:generate-class-name(..)"/>
        </xsl:if>
    </xsl:template>


    <!-- Find rendering information for the current column -->
    <xsl:template name="cell-rend-col">
        <xsl:context-item as="element(cell)" use="required"/>

        <xsl:variable name="position">
            <xsl:call-template name="find-column-number"/>
        </xsl:variable>
        <xsl:for-each select="../../column[position() = $position]">
            <xsl:copy-of select="f:generate-class(.)"/>
        </xsl:for-each>
    </xsl:template>

    <!-- Find relative postion of cell in table -->
    <xsl:template name="cell-pos-class">
        <xsl:context-item as="element(cell)" use="required"/>

        <!-- A cell is considered part of the table head if it has a @role of label or unit -->
        <xsl:variable name="prefix" select="if (f:is-header-row(..)) then 'cellHead' else 'cell'"/>

        <!-- Some stuff to determine this cell is at the bottom of a column in an N-up table -->
        <xsl:variable name="parentTable" select="ancestor::table[1]"/>
        <xsl:variable name="column-count" as="xs:integer" select="xs:integer(f:if-null(f:rend-value($parentTable/@rend, 'columns'), 1))"/>
        <xsl:variable name="item-order" as="xs:string" select="f:rend-value($parentTable/@rend, 'item-order')"/>
        <xsl:variable name="row-count" as="xs:integer" select="f:count-data-rows($parentTable)"/>
        <xsl:variable name="header-count" as="xs:integer" select="f:count-header-rows($parentTable)"/>
        <xsl:variable name="current-row" as="xs:integer" select="(if (@row) then xs:integer(@row) else count(../preceding-sibling::row)) - $header-count"/>
        <xsl:variable name="rows-per-colum" select="ceiling($row-count div $column-count)"/>

        <xsl:variable name="is-bottom-cell" as="xs:boolean" select="if ($item-order = 'column-major') 
            then $current-row > $row-count - $column-count
            else $current-row mod $rows-per-colum = 0 "/>
        <xsl:variable name="is-top-cell" as="xs:boolean" select="$header-count = 0 and (if ($item-order = 'column-major') 
            then $current-row &lt;= $column-count
            else ($current-row - 1) mod $rows-per-colum = 0)"/>

        <xsl:choose>
            <!-- Do we have the @col attribute on the table, then we can use those attributes -->
            <xsl:when test="@col">
                <xsl:if test="@col = 1"><xsl:value-of select="$prefix"/><xsl:text>Left </xsl:text></xsl:if>
                <xsl:if test="@col + @cols - 1 = ../../@cols"><xsl:value-of select="$prefix"/><xsl:text>Right </xsl:text></xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="f:log-warning('Table {1}, Column position not specified: using simple heuristic to determine borders.', (f:generate-id(ancestor::table[1])))"/>
                <xsl:if test="not(preceding-sibling::cell)"><xsl:value-of select="$prefix"/><xsl:text>Left </xsl:text></xsl:if>
                <xsl:if test="not(following-sibling::cell)"><xsl:value-of select="$prefix"/><xsl:text>Right </xsl:text></xsl:if>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="f:is-header-row(..)">
                <xsl:if test="not(../preceding-sibling::row)"><xsl:text>cellHeadTop </xsl:text></xsl:if>
                <xsl:if test="not(../following-sibling::row[f:is-header-row(.)])"><xsl:text>cellHeadBottom </xsl:text></xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$is-top-cell or not(../preceding-sibling::row)"><xsl:text>cellTop </xsl:text></xsl:if>
                <xsl:if test="$is-bottom-cell or not(../following-sibling::row)"><xsl:text>cellBottom </xsl:text></xsl:if>
            </xsl:otherwise>
        </xsl:choose>

        <!-- Handle the case when a bottom cell is spanned -->
        <xsl:if test="@rows &gt; 1  and @row + @rows - 1 = ../../@headrows"><xsl:value-of select="$prefix"/><xsl:text>Bottom </xsl:text></xsl:if>
        <xsl:if test="@rows &gt; 1  and @row + @rows - 1 = ../../@rows"><xsl:value-of select="$prefix"/><xsl:text>Bottom </xsl:text></xsl:if>
    </xsl:template>


    <!-- Find the column number of the current cell -->
    <xsl:template name="find-column-number">
        <xsl:context-item as="element(cell)" use="required"/>

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


    <xsl:function name="f:is-header-row" as="xs:boolean">
        <xsl:param name="row" as="element(row)"/>
        <xsl:sequence select="$row/@role = ('label', 'unit')"/>
    </xsl:function>

    <xsl:function name="f:is-sum-cell" as="xs:boolean">
        <xsl:param name="cell" as="element(cell)"/>
        <xsl:sequence select="$cell/@role = ('sum', 'subtr', 'avg', 'sumCurrency', 'sumDecimal', 'sumFraction', 'sumSterling', 'sumPeso')"/>
    </xsl:function>


    <xd:doc>
        <xd:short>N-up a table.</xd:short>
        <xd:detail>
            <p>Render a table in N-up format, that is, using n times the number of
            columns and 1/N-th the number of rows; repeating the heading-rows on top.
            Note that this may fail if rows are spanned. The case of number
            of data-rows not divisible by N is handled (the last column will just be partially-filled.)</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="n-up-table">
        <xsl:context-item as="element(table)" use="required"/>

        <xsl:variable name="n" as="xs:integer" select="xs:integer(f:rend-value(@rend, 'columns'))"/>
        <xsl:variable name="item-order" as="xs:string" select="f:rend-value(@rend, 'item-order')"/>

        <!-- Get labels and units first (simplified model, see templates dealing with a normal-table for more complex situation). -->
        <xsl:variable name="headers" select="f:get-header-rows(.)"/>

        <!-- Get remainder of data  -->
        <xsl:variable name="rows" select="f:get-data-rows(.)"/>
        <xsl:variable name="rowCount" select="ceiling(count($rows) div $n)"/>

        <table>
            <xsl:copy-of select="f:set-class-attribute(.)"/>

            <!-- ePub3 doesn't like summaries on tables -->
            <xsl:if test="f:has-rend-value(@rend, 'summary') and not(f:is-epub())">
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
                                    <!-- Prevent duplication of ids by stripping them for all but the first repeat -->
                                    <xsl:variable name="cellHtml">
                                        <xsl:apply-templates select="."/>
                                    </xsl:variable>
                                    <xsl:copy-of select="if ($i = 1) then $cellHtml else f:copy-without-ids($cellHtml)"/>
                                </xsl:for-each>
                            </xsl:for-each>
                        </tr>
                    </xsl:for-each>
                </thead>
            </xsl:if>

            <!-- Take data from each part -->
            <tbody>
                <xsl:choose>
                    <xsl:when test="$item-order = 'column-major'">
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
    
    <xsl:function name="f:get-header-rows" as="element(row)*">
        <xsl:param name="table" as="element(table)"/>
        <xsl:sequence select="$table/row[not(preceding-sibling::row[not(f:is-header-row(.))] or self::row[not(f:is-header-row(.))])]"/>
    </xsl:function>

    <xsl:function name="f:count-header-rows" as="xs:integer">
        <xsl:param name="table" as="element(table)"/>
        <xsl:sequence select="if ($table/@headrows) then xs:integer($table/@headrows) else count(f:get-header-rows($table))"/>
    </xsl:function>

    <xsl:function name="f:get-data-rows" as="element(row)*">
        <xsl:param name="table" as="element(table)"/>
        <xsl:sequence select="$table/row[preceding-sibling::row[not(f:is-header-row(.))] or self::row[not(f:is-header-row(.))]]"/>
    </xsl:function>

    <xsl:function name="f:count-data-rows" as="xs:integer">
        <xsl:param name="table" as="element(table)"/>
        <xsl:sequence select="if ($table/@rows and $table/@headrows) then xs:integer($table/@rows - $table/@headrows) else count(f:get-data-rows($table))"/>
    </xsl:function>

</xsl:stylesheet>
