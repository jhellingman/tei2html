<!DOCTYPE xsl:stylesheet [

    <!ENTITY lsquo      "&#x2018;">
    <!ENTITY rsquo      "&#x2019;">
]>

<xsl:stylesheet version="3.0"                
                xmlns:f="urn:stylesheet-functions"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="f xd xs">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to normalize TEI tables.</xd:short>
        <xd:detail><p>This stylesheet normalizes TEI tables, to be able to apply the
        proper style to a table-cell, we need to know what its position in the table is,
        while taking into account spanned rows and columns.</p>

        <p>To establish the actual row and column of a cell, we need to first normalize
        the table (that is: remove all spans), after which we can simply count the cells, and
        register the cell position in additional attributes. In a final stage, we remove
        the spanned cells again.</p>

        <p>The code assumes that the table being transformed is rectangular. It may behave in
        unexpected ways if this is not the case.</p>

        <p>The normalizing code is based on sample code found on-line
        <a href="https://andrewjwelch.com/code/xslt/table/table-normalization.html">here</a>. This has been
        adjusted to the TEI table model and expanded with code to detect non-rectangular
        tables and to deal with nested tables.</p>

        <p>An additional step is used to align columns on the decimal separator, which
        is not supported in HTML. This is achieved by splitting the cells in two parts, the
        integer, and the fractional part of the number.</p>
        </xd:detail>
    </xd:doc>

    <xsl:namespace-alias stylesheet-prefix="tei" result-prefix="#default"/> 

    <!-- stub function used by log.xsl -->
    <xsl:function name="f:is-set" as="xs:boolean">
        <xsl:param name="value" as="xs:string"/>
        <xsl:sequence select="true()"/>
    </xsl:function>


    <xsl:include href="log.xsl"/>
    <xsl:include href="rend.xsl"/>


    <xsl:template match="table" mode="transpose">

        <!-- Transpose counter-clockwise and reverse order of rows -->

        <!-- Step 1: normalize the table -->
        <xsl:variable name="normalized-table">
            <xsl:apply-templates select="." mode="normalize-table"/>
        </xsl:variable>

        <!-- now we have position attributes on each cell, in @row and @col attributes -->
        <!-- when dealing with nested tables, we only transpose the top-level one, unless explicitely indicated -->

        <tei:table>
            <xsl:variable name="cols" select="$normalized-table/table/@cols" as="xs:integer"/>
            <!-- <xsl:variable name="rows" select="xs:integer($normalized-table/table/@rows) + xs:integer($normalized-table/table/@headrows)" as="xs:integer"/> -->
            <xsl:variable name="rows" select="$normalized-table/table/@rows" as="xs:integer"/>

            <xsl:attribute name="rows" select="$cols"/>
            <xsl:attribute name="cols" select="$rows"/>
            <xsl:attribute name="rend" select="f:remove-rend-value($normalized-table/table/@rend, 'transpose')"/>
            <xsl:copy-of select="$normalized-table/table/@*[not(name() = ('rows', 'headrows', 'cols', 'rend'))]"/>

            <!-- create column objects for each row in the original table -->
            <xsl:for-each select="1 to $rows">
                <tei:column>
                    <!-- Copy the @rend and @role attribute from the corresponding row -->
                    <xsl:variable name="row" select="."/>
                    <xsl:variable name="rend" select="$normalized-table/table/row[cell[@row = $row][1]]/@rend"/>
                    <xsl:if test="$rend">
                        <xsl:attribute name="rend" select="$rend"/>
                    </xsl:if>
                    <xsl:variable name="role" select="$normalized-table/table/row[cell[@row = $row][1]]/@role"/>
                    <xsl:if test="$role">
                        <xsl:attribute name="role" select="$role"/>
                    </xsl:if>
                </tei:column>
            </xsl:for-each>

            <!-- create a row for each column in the original table -->
            <xsl:for-each select="1 to $cols">
                <tei:row>
                    <!-- Copy the @rend and @role attribute from the corresponding @column -->
                    <xsl:variable name="col" select="."/>
                    <xsl:variable name="rend" select="$normalized-table/table/column[$col]/@rend"/>
                    <xsl:if test="$rend">
                        <xsl:attribute name="rend" select="$rend"/>
                    </xsl:if>
                    <xsl:variable name="role" select="$normalized-table/table/column[$col]/@role"/>
                    <xsl:if test="$role">
                        <xsl:attribute name="role" select="$role"/>
                    </xsl:if>

                    <xsl:for-each select="1 to $rows">
                        <xsl:variable name="row" select="."/>
                        <xsl:variable name="cell" select="$normalized-table/table/row/cell[@row = $row and @col = $col]"/>
                        <xsl:if test="$cell">
                            <tei:cell>
                                <xsl:attribute name="row" select="$col"/>
                                <xsl:if test="$cell/@cols"><xsl:attribute name="rows" select="$cell/@cols"/></xsl:if>
                                <xsl:attribute name="col" select="$row"/>
                                <xsl:if test="$cell/@rows"><xsl:attribute name="cols" select="$cell/@rows"/></xsl:if>
                                <!-- Copy contents -->
                                <xsl:copy-of select="$cell/node()"/>
                            </tei:cell>
                        </xsl:if>
                    </xsl:for-each>
                </tei:row>
            </xsl:for-each>
        </tei:table>
    </xsl:template>


    <xsl:template match="table" mode="normalize-table">

        <!-- Step 1: eliminate spanned columns -->
        <xsl:variable name="table-without-colspans">
            <xsl:apply-templates select="." mode="normalize-table-colspans"/>
        </xsl:variable>

        <!-- Step 2: eliminate spanned rows -->
        <xsl:variable name="table-without-rowspans">
            <xsl:apply-templates select="$table-without-colspans" mode="normalize-table-rowspans"/>
        </xsl:variable>

        <!-- Step 3: cleanup added attributes and cells -->
        <xsl:variable name="clean-table">
            <xsl:apply-templates select="$table-without-rowspans" mode="normalize-table-final"/>
        </xsl:variable>

        <!-- Step 3': apply language attributes to cells in column -->
        <xsl:variable name="language-tagged-table">
            <xsl:apply-templates select="$clean-table" mode="language-tag-table"/>
        </xsl:variable>

        <!-- Step 4: split columns for decimal alignment -->
        <xsl:variable name="split-table">
            <xsl:apply-templates select="$language-tagged-table" mode="split-decimal-columns"/>
        </xsl:variable>

        <!-- Step 5: recurse for nested tables (but make sure not to start with the top-level table) -->
        <tei:table>
            <xsl:copy-of select="$split-table/table/@*"/>
            <xsl:apply-templates select="$split-table/table/node()" mode="normalize-table"/>
        </tei:table>
    </xsl:template>


    <xd:doc>
        <xd:short>Copy untouched elements when normalizing a table.</xd:short>
        <xd:detail>
            <p>Copy (in the current phase) untouched elements when normalizing a table.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="@*|node()" mode="normalize-table normalize-table-colspans normalize-table-rowspans normalize-table-final split-decimal-columns recurse-normalize-table">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>


    <xd:doc>
        <xd:short>Normalize the column-spans in a table.</xd:short>
        <xd:detail>
            <p>Normalize the column-spans in a table. This template inserts a placeholder cell for each spanned column.
            It also copies the <code>@rows</code> attribute on cells to a temporary attribute <code>@orig_rows</code> and the <code>@cols</code>
            attribute to <code>@orig_cols</code>.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="cell[@cols]" mode="normalize-table-colspans">
        <xsl:variable name="cell" select="." as="element(cell)"/>
        <xsl:for-each select="1 to @cols">
            <tei:cell>
                <xsl:copy-of select="$cell/@*[not(name() = 'cols')]"/>
                <xsl:choose>
                    <xsl:when test="position() = 1">
                        <!-- Copy the content of the current cell -->
                        <xsl:attribute name="orig_cols" select="$cell/@cols"/>
                        <xsl:if test="$cell/@rows">
                            <xsl:attribute name="orig_rows" select="$cell/@rows"/>
                        </xsl:if>
                        <xsl:copy-of select="$cell/node()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Indicate this is a placeholder for a spanned cell -->
                        <xsl:attribute name="spanned" select="'true'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </tei:cell>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="cell" mode="normalize-table-colspans">
        <tei:cell>
            <xsl:if test="@rows">
                <xsl:attribute name="orig_rows" select="@rows"/>
            </xsl:if>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="./node()"/>
        </tei:cell>
    </xsl:template>


    <xsl:template match="column[@cols]" mode="normalize-table-colspans">
        <xsl:variable name="column" select="." as="element(column)"/>
        <xsl:for-each select="1 to @cols">
            <xsl:copy select="$column">
                <xsl:copy-of select="@rend"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:template>


    <xsl:template match="columnGroup[@repeat]" mode="normalize-table-colspans">
        <xsl:variable name="columnGroup" select="." as="element(columnGroup)"/>
        <xsl:for-each select="1 to @repeat">
            <xsl:apply-templates select="$columnGroup/*" mode="normalize-table-colspans"/>
        </xsl:for-each>
    </xsl:template>


    <xsl:template match="columnGroup" mode="normalize-table-colspans">
        <xsl:apply-templates mode="normalize-table-colspans"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Normalize the row-spans in a table.</xd:short>
        <xd:detail>
            <p>Normalize the row-spans in a table. Start with the easy case by copying the first row. Then handle each row in order.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="table" mode="normalize-table-rowspans">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="*[not(self::row)]"/>
            <xsl:copy-of select="row[1]"/>
            <xsl:apply-templates select="row[2]" mode="normalize-table-rowspans">
                <xsl:with-param name="previousRow" select="row[1]"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>


    <xd:doc>
        <xd:short>Normalize the row-spans in a table-row.</xd:short>
        <xd:detail>
            <p>Normalize the row-spans in a table-row. Start with the second row, compare this
            with the preceding row, and insert placeholder cells for each spanned row. Then
            recurse for the next row, until the end of the table.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="row" mode="normalize-table-rowspans">
        <xsl:param name="previousRow" as="element(row)"/>
        <xsl:variable name="currentRow" select="." as="element(row)"/>

        <xsl:variable name="normalizedCells">
            <xsl:apply-templates select="$previousRow/cell" mode="spans-for-previous-rows">
                <xsl:with-param name="currentRow" select="$currentRow"/>
            </xsl:apply-templates>
        </xsl:variable>

        <!-- Warn for potential data-loss if table is not rectangular -->
        <xsl:if test="count($normalizedCells/cell) &lt; count($currentRow/cell) + count($previousRow/cell[@rows &gt; 1])">
            <xsl:message>ERROR:   Table '<xsl:value-of select="$currentRow/../@id"/>' not rectangular at row <xsl:value-of select="count($currentRow/preceding-sibling::row) + 1"/>. Extra cells will be lost!</xsl:message>
        </xsl:if>

        <xsl:variable name="newRow" as="element(row)">
            <xsl:copy>
                <xsl:copy-of select="$currentRow/@*"/>
                <xsl:copy-of select="$normalizedCells"/>
            </xsl:copy>
        </xsl:variable>

        <xsl:copy-of select="$newRow"/>

        <xsl:apply-templates select="following-sibling::row[1]" mode="normalize-table-rowspans">
            <xsl:with-param name="previousRow" select="$newRow"/>
        </xsl:apply-templates>
    </xsl:template>


    <xsl:template mode="spans-for-previous-rows" match="cell[@rows &gt; 1]">
        <!-- Insert a placeholder cell for the spanned cell from the previous row -->
        <xsl:copy>
            <xsl:attribute name="spanned" select="'true'"/>
            <xsl:attribute name="rows" select="@rows - 1"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template mode="spans-for-previous-rows" match="cell">
        <xsl:param name="currentRow" as="element(row)"/>
        <!-- Copy the cell from the current row -->
        <xsl:variable name="currentPosition" select="1 + count(current()/preceding-sibling::cell[not(@rows) or (@rows = 1)])"/>
        <xsl:variable name="currentCell" select="$currentRow/cell[$currentPosition]"/>
        <xsl:copy-of select="$currentCell"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Cleanup the table as last phase of normalization.</xd:short>
        <xd:detail>
            <p>Cleanup the table as last phase of normalization. Insert the <code>@cols</code> and <code>@rows</code>
            attributes at the table level. Then cleanup the contents of the table.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="table" mode="normalize-table-final">

        <!-- Exceptional condition: if the bottom row of cells all span multiple rows, we need to count those spans. -->
        <xsl:variable name="additionalRows" select="if (row[last()]/cell[1]/@rows) then row[last()]/cell[1]/@rows - 1 else 0"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="cols" select="count(row[1]/cell)"/>
            <xsl:attribute name="rows" select="count(row) + $additionalRows"/>

            <!-- Count heading rows only at top -->
            <xsl:attribute name="headrows" select="count(f:get-top-header-rows(.))"/>

            <xsl:apply-templates mode="normalize-table-final"/>

            <xsl:if test="count(column) != 0 and count(column) != count(row[1]/cell)">
                <xsl:message>WARNING: Table '<xsl:value-of select="@id"/>': count(column) = <xsl:value-of select="count(column)"/>; count(row[1]/cell) = <xsl:value-of select="count(row[1]/cell)"/>.</xsl:message>
            </xsl:if>
        </xsl:copy>
    </xsl:template>


    <xsl:function name="f:get-top-header-rows" as="element(row)*">
        <xsl:param name="table" as="element(table)"/>
        <xsl:sequence select="$table/row[not(preceding-sibling::row[not(f:is-header-row(.))] or self::row[not(f:is-header-row(.))])]"/>
    </xsl:function>


    <xsl:function name="f:is-header-row" as="xs:boolean">
        <xsl:param name="row" as="element(row)"/>
        <xsl:sequence select="$row/@role = ('label', 'unit')"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Cleanup a cell as last phase of normalization.</xd:short>
        <xd:detail>
            <p>Cleanup a cell as last phase of normalization. Drop spanned cells introduced in the process
            and restore the <code>@cols</code> and <code>@rows</code> attributes. Add the <code>@col</code> and <code>@row</code> attribute
            by counting siblings.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="cell" mode="normalize-table-final">
        <xsl:copy>
            <xsl:attribute name="col" select="count(preceding-sibling::cell) + 1"/>
            <xsl:attribute name="row" select="count(../preceding-sibling::row) + 1"/>

            <!-- Restore the original cols and rows -->
            <xsl:if test="@orig_cols"><xsl:attribute name="cols" select="@orig_cols"/></xsl:if>
            <xsl:if test="@orig_rows"><xsl:attribute name="rows" select="@orig_rows"/></xsl:if>

            <xsl:copy-of select="@*[not(name() = 'rows')][not(name() = 'orig_rows')][not(name() = 'orig_cols')]"/>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="cell[@spanned]" mode="normalize-table-final"/>


    <!--==== Split Lsd (Pound/Shilling/Penny) columns (TODO) -->

    <!-- column rend="align(lsd)" will split the column in three separate columns, such that amounts are neatly aligned -->
    <!--
        Data cell cases:
               <cell>1 19 11</cell>     results in <cell>1 </cell><cell>19 </cell><cell>11</cell>
               <cell>  19 11</cell>     results in <cell>  </cell><cell>19 </cell><cell>11</cell>
               <cell>     11</cell>     results in <cell>  </cell><cell>   </cell><cell>11</cell>
               <cell>     11.5</cell>   results in <cell>  </cell><cell>   </cell><cell>11.5</cell>
               <cell>     11-1/2</cell> results in <cell>  </cell><cell>   </cell><cell>11-1/2</cell>

        Header cell cases:
               <cell>L s d</cell>    results in <cell>L </cell><cell>s </cell><cell>d</cell>
               <cell>L. s. d.</cell>    results in <cell>L. </cell><cell>s. </cell><cell>d.</cell>
               <cell><hi>L. s. d.</hi></cell>    results in <cell><hi>L.</hi> </cell><cell><hi>s.</hi> </cell><cell><hi>d.</hi></cell>
               <cell><hi>L.</hi> <hi>s.</hi> <hi>d.</hi></cell>    results in <cell><hi>L.</hi> </cell><cell><hi>s.</hi> </cell><cell><hi>d.</hi></cell>

        Any other cell content will not be split, but the the cell will be given a span:
               <cell>Just a label</cell> results in <cell cols=3>Just a label</cell>
    -->


    <!--==== Split decimal columns ====-->

    <xd:doc>
        <xd:short>Adjust the column count of a table if necessary</xd:short>
    </xd:doc>

    <xsl:template mode="split-decimal-columns" match="table">
        <tei:table>
            <xsl:copy-of select="@*[not(name() = 'cols')]"/>
            <xsl:attribute name="cols" select="f:new-cols-value(., 1, @cols)"/>
            <xsl:apply-templates mode="split-decimal-columns"/>
        </tei:table>
    </xsl:template>


    <xd:doc>
        <xd:short>Split the column element when it contains the rendition <code>align(decimal)</code>.</xd:short>
    </xd:doc>

    <xsl:template mode="split-decimal-columns" match="column[f:rend-value(@rend, 'align') = 'decimal']">

        <xsl:variable name="rend" select="f:remove-rend-value(@rend, 'align')" as="xs:string"/>
        <xsl:variable name="rend" select="f:adjust-rend-dimension($rend, 'width', 0.5)"/>

        <tei:column>
            <xsl:copy-of select="@*[not(name() = 'rend')]"/>
            <xsl:if test="$rend != ''">
                <xsl:attribute name="rend" select="$rend"/>
            </xsl:if>
        </tei:column>
        <tei:column>
            <xsl:copy-of select="@*[not(name() = ('rend', 'id'))]"/>
            <xsl:if test="$rend != ''">
                <xsl:attribute name="rend" select="$rend"/>
            </xsl:if>
        </tei:column>
    </xsl:template>


    <xd:doc>
        <xd:short>Determine whether a cell element needs to be split.</xd:short>
        <xd:detail>
            <p>A cell needs to be split when the corresponding column contains a rendition <code>align(decimal)</code>.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template mode="split-decimal-columns" match="cell">
        <xsl:variable name="col" select="xs:integer(@col)" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="../../column[$col][f:rend-value(@rend, 'align') = 'decimal']">
                <xsl:apply-templates mode="split-cell" select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="adjust-cell" select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Calculate the new <code>@cols</code> value, taking into account split columns being spanned.</xd:short>
    </xd:doc>

    <xsl:function name="f:new-cols-value" as="xs:integer">
        <xsl:param name="table" as="element(table)"/>
        <xsl:param name="start" as="xs:integer"/>
        <xsl:param name="cols" as="xs:integer"/>

        <xsl:variable name="end" select="$start + $cols" as="xs:integer"/>
        <xsl:variable name="columns" select="$table/column"/>
        <xsl:variable name="new-cols-value"
            select="$cols + count($table/column
                [count(preceding-sibling::column | self::column) > $start]
                [count(preceding-sibling::column | self::column) &lt; $end]
                [f:rend-value(@rend, 'align') = 'decimal'])"/>
        <xsl:value-of select="$new-cols-value"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Calculate the new <code>@col</code> value, taking into account split columns before this column.</xd:short>
    </xd:doc>

    <xsl:function name="f:new-col-value" as="xs:integer">
        <xsl:param name="table" as="element(table)"/>
        <xsl:param name="col" as="xs:integer"/>

        <xsl:variable name="new-col-value"
            select="$col + count($table/column
                [count(preceding-sibling::column | self::column) &lt; $col]
                [f:rend-value(@rend, 'align') = 'decimal'])"/>
        <xsl:value-of select="$new-col-value"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Split a cell in two if the first non-empty text() node in it is numeric.</xd:short>
        <xd:detail>
            <p>If the first non-empty <code>text()</code> node is numeric (according to the selected number pattern), it is split
            into an integer and a fractional part. Cells with non-numeric content are normally not split, but if any content
            in the cell is wrapped in an element node, it will be ignored for determining whether the cell is numeric.
            Any non-text nodes preceding the text node go to the first cell, any nodes following this text node go to
            the second cell.</p>

            <p>The use of normalize-space is to avoid issues with pattern-matching in relation to new-lines.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template mode="split-cell" match="cell[matches(normalize-space(text()[normalize-space(.) != ''][1]), f:determine-number-pattern(.))]">
        <xsl:variable name="text" select="normalize-space(text()[normalize-space(.) != ''][1])" as="xs:string"/>

        <xsl:variable name="number-pattern" select="f:determine-number-pattern(.)"/>

        <xsl:variable name="integer" select="replace($text, $number-pattern, '$2')"/>
        <xsl:variable name="fraction" select="replace($text, $number-pattern, '$4$7$8')"/>

        <xsl:variable name="rend" select="if (@rend) then @rend else ''" as="xs:string"/>
        <xsl:variable name="rend" select="f:adjust-rend-dimension($rend, 'width', 0.5)" as="xs:string"/>

        <!-- Generate the cell for the integer part -->
        <tei:cell>
            <xsl:copy-of select="@*[not(name() = ('col', 'rend', 'role'))]"/>
            <xsl:attribute name="col" select="f:new-col-value(../.., @col)"/>
            <xsl:attribute name="rend" select="f:add-class($rend, 'alignDecimalIntegerPart')"/>
            <xsl:if test="@role">
                <xsl:attribute name="role" select="if (@role = 'sum') then 'sumDecimal' else @role"/>
            </xsl:if>
            <xsl:apply-templates select="*[not(preceding-sibling::text()[normalize-space(.) != ''])]"/>
            <xsl:value-of select="$integer"/>
        </tei:cell>

        <!-- Generate the cell for the fractional part -->
        <tei:cell>
            <xsl:copy-of select="@*[not(name() = ('col', 'cols', 'rend', 'role'))]"/>
            <xsl:attribute name="col" select="f:new-col-value(../.., @col) + 1"/>
            <xsl:attribute name="rend" select="f:add-class($rend, 'alignDecimalFractionPart')"/>
            <xsl:if test="@cols">
                <xsl:attribute name="cols" select="f:new-cols-value(../.., xs:integer(@col + 1), @cols)"/>
            </xsl:if>
            <xsl:if test="@role">
                <xsl:attribute name="role" select="if (@role = 'sum') then 'sumFraction' else @role"/>
            </xsl:if>
            <xsl:value-of select="$fraction"/>
            <xsl:apply-templates select="(*|text())[preceding-sibling::text()[normalize-space(.) != '']]"/>
        </tei:cell>
    </xsl:template>


    <xd:doc>
        <xd:short>Don't split other types of cells, but take care column numbering and column spanning is adjusted.</xd:short>
    </xd:doc>

    <xsl:template mode="split-cell" match="cell">
        <xsl:variable name="rend" select="if (@rend) then @rend else ''" as="xs:string"/>
        <tei:cell>
            <xsl:copy-of select="@*[not(name() = ('col', 'cols', 'rend'))]"/>
            <xsl:attribute name="cols" select="if (@cols) then f:new-cols-value(../.., @col, @cols) + 1 else 2"/>
            <xsl:attribute name="col" select="f:new-col-value(../.., @col)"/>
            <xsl:attribute name="rend" select="f:add-class($rend, 'alignDecimalNotNumber')"/>
            <xsl:copy-of select="*|text()"/>
        </tei:cell>
    </xsl:template>

    <xsl:template mode="adjust-cell" match="cell[@cols > 1]">
        <tei:cell>
            <xsl:copy-of select="@*[not(name() = ('col', 'cols'))]"/>
            <xsl:attribute name="cols" select="f:new-cols-value(../.., @col, @cols)"/>
            <xsl:attribute name="col" select="f:new-col-value(../.., @col)"/>
            <xsl:copy-of select="*|text()"/>
        </tei:cell>
    </xsl:template>

    <xsl:template mode="adjust-cell" match="cell">
        <tei:cell>
            <xsl:copy-of select="@*[not(name() = 'col')]"/>
            <xsl:attribute name="col" select="f:new-col-value(../.., @col)"/>
            <xsl:copy-of select="*|text()"/>
        </tei:cell>
    </xsl:template>

    <xd:doc>
        <xd:short>The document root.</xd:short>
        <xd:detail>The document root is set to the root of the document we process, so we can access that, even if we are
        processing document trees generated while processing documents in multiple rounds.</xd:detail>
    </xd:doc>

    <xsl:variable name="root" select="/"/>

    <xd:doc>
        <xd:short>The default decimal separator, set to a period (English usage).</xd:short>
    </xd:doc>

    <xsl:variable name="default-decimal-separator" select="'.'"/>

    <xd:doc>
        <xd:short>Pattern to match Unicode numbers.</xd:short>
        <xd:detail>
            <p>Pattern to match numbers in Unicode, based on the Unicode character category \p{Decimal_Digit_Number}. To allow
            for fractions to appear in a number, we also allow the category \p{Other_Number} to follow a number or to stand alone.</p>
        </xd:detail>
    </xd:doc>

    <!--
         Structure of pattern:

           optional leading spaces             ^\s?
             number                                               $1
               integer part                                       $2
                 currency sign:                [$]?
                   groups of digits            (\p{Nd}+[,])*      $3
                   last group of digits        \p{Nd}+
               fractional part                                    $4
                 fraction digits               ([.]\p{Nd}+)?      $5
                 following numeral             (\p{No})?          $6
               stand-alone numeral             |(\p{No})          $7
               stand-alone fraction digits     |([.]\p{Nd}+)      $8
           optional trailing spaces            \s?$
    -->

    <xsl:variable name="number-pattern-period" select="'^\s?(([$]?(\p{Nd}+[,])*\p{Nd}+)(([.]\p{Nd}+)?(\p{No})?)|(\p{No})|([.]\p{Nd}+))\s?$'"/>
    <xsl:variable name="number-pattern-comma"  select="'^\s?(([$]?(\p{Nd}+[.])*\p{Nd}+)(([,]\p{Nd}+)?(\p{No})?)|(\p{No})|([,]\p{Nd}+))\s?$'"/>


    <xd:doc>
        <xd:short>Determine the decimal separator symbol to be used.</xd:short>
        <xd:detail>
            <p>Obtain this value from the decimal-separator rendition value. First look at the <code>cell</code>-element itself,
            then row, then the table. Since the table is &lsquo;unrooted&rsquo; here, we need to look separately at the
            root-level for a document-wide setting on the text element. Intermediate locations are currently not
            supported.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:determine-decimal-separator" as="xs:string">
        <xsl:param name="cell" as="element(cell)"/>

        <xsl:variable name="rend" select="($cell/ancestor-or-self::*/@rend[f:has-rend-value(., 'decimal-separator')])[last()]"/>
        <xsl:variable name="rend-text" select="$root//text[1]/@rend"/>

        <xsl:value-of select="if (f:has-rend-value($rend, 'decimal-separator'))
            then f:rend-value($rend, 'decimal-separator')
            else if (f:has-rend-value($rend-text, 'decimal-separator'))
                 then f:rend-value($rend-text, 'decimal-separator')
                 else $default-decimal-separator"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine the pattern to be used to recognize numbers.</xd:short>
    </xd:doc>

    <xsl:function name="f:determine-number-pattern" as="xs:string">
        <xsl:param name="cell" as="element(cell)"/>

        <xsl:value-of select="if (f:determine-decimal-separator($cell) = ',')
            then $number-pattern-comma
            else $number-pattern-period"/>
    </xsl:function>


    <!-- Language tagging: bring language tag from the column definition to each individual cell -->

    <xsl:template match="table" mode="language-tag-table">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="*[not(self::row)]"/>
            <xsl:apply-templates select="row" mode="language-tag-table"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="row" mode="language-tag-table">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="cell" mode="language-tag-table"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="cell" mode="language-tag-table">
        <xsl:variable name="columnNumber" select="@col"/>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:if test="not(@lang) and ../../column[position() = $columnNumber]/@lang">
                <xsl:attribute name="lang" select="../../column[position() = $columnNumber]/@lang"/>
            </xsl:if>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
    </xsl:template>


</xsl:stylesheet>
