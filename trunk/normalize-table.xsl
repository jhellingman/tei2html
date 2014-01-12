<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    version="2.0"
    exclude-result-prefixes="xs xd">

<xsl:output indent="no" omit-xml-declaration="yes"/>

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to normalize TEI tables.</xd:short>
        <xd:detail><p>This stylesheet normalizes TEI tables, to be able to apply the
        proper style to a table-cell, we need to be able what it's position in the table is,
        while taking into account spanned rows and columns.</p>

        <p>To establish the actual row and column of a cell, we need to first normalize
        the table (that is: remove all spans), after which we can simply count the cells, and
        register the cell position in additional attributes. In a final stage, we remove
        the spanned cells again.</p>

        <p>The normalizing code is based on sample code found on-line here:
        http://andrewjwelch.com/code/xslt/table/table-normalization.html. This has been
        adjusted to the TEI table model and expanded with code to detect non-well-formed
        tables.</p>
        </xd:detail>
    </xd:doc>


<xsl:template match="@TEIform" mode="#all"/>

<xsl:template match="table">

    <!-- Step 1: eliminate spanned columns -->
    <xsl:variable name="table-without-colspans">
        <xsl:apply-templates select="." mode="normalize-table-colspans"/>
    </xsl:variable>

    <!-- Step 2: eliminate spanned rows -->
    <xsl:variable name="table-without-rowspans">
        <xsl:apply-templates select="$table-without-colspans" mode="normalize-table-rowspans"/>
    </xsl:variable>

    <!-- Step 3: cleanup added attributes and cells -->
    <xsl:apply-templates select="$table-without-rowspans" mode="normalize-table-final"/>
</xsl:template>


<!-- Templates to normalize a table -->

<xsl:template match="@*|node()" mode="#all">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
</xsl:template>


<xsl:template match="cell" mode="normalize-table-colspans">
    <xsl:choose>
        <xsl:when test="@cols">
            <xsl:variable name="this" select="." as="element()"/>
            <xsl:for-each select="1 to @cols">
                <cell>
                    <xsl:copy-of select="$this/@*[not(name() = 'cols')]"/>
                    <xsl:choose>
                        <xsl:when test="position() = 1">
                            <!-- Copy the content of the current cell -->
                            <xsl:attribute name="orig_cols" select="$this/@cols"/>
                            <xsl:if test="$this/@rows"><xsl:attribute name="orig_rows" select="$this/@rows"/></xsl:if>
                            <xsl:copy-of select="$this/node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- Insert a placeholder for the spanned cell -->
                            <xsl:attribute name="spanned" select="'true'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </cell>
            </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
            <cell>
                <xsl:if test="@rows">
                    <xsl:attribute name="orig_rows" select="@rows"/>
                </xsl:if>
                <xsl:copy-of select="@*"/>
                <xsl:copy-of select="./node()"/>
            </cell>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


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


<xsl:template match="row" mode="normalize-table-rowspans">
    <xsl:param name="previousRow" as="element()"/>

    <xsl:variable name="currentRow" select="."/>

    <xsl:variable name="normalizedCells">
        <xsl:for-each select="$previousRow/cell">
            <xsl:choose>
                <xsl:when test="@rows &gt; 1">
                    <!-- Insert a placeholder cell for the spanned cell from the previous row -->
                    <xsl:copy>
                        <xsl:attribute name="spanned" select="'true'"/>
                        <xsl:attribute name="rows" select="@rows - 1"/>
                    </xsl:copy>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Copy the cell from the current row -->
                    <xsl:variable name="currentPosition" select="1 + count(current()/preceding-sibling::cell[not(@rows) or (@rows = 1)])"/>
                    <xsl:variable name="currentCell" select="$currentRow/cell[$currentPosition]"/>
                    <xsl:copy-of select="$currentCell"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:variable>

    <!-- Warn for potential data-loss if table is not well-formed -->
    <xsl:if test="count($normalizedCells/cell) &lt; count($currentRow/cell) + count($previousRow/cell[@rows &gt; 1])">
        <xsl:message terminate="no">ERROR:   table '<xsl:value-of select="$currentRow/../@id"/>' not rectangular at row <xsl:value-of select="count($currentRow/preceding-sibling::row) + 1"/>. Extra cells will be lost!</xsl:message>
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


<xsl:template match="table" mode="normalize-table-final">
    <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:attribute name="cols" select="count(row[1]/cell)"/>
        <xsl:attribute name="rows" select="count(row)"/>
        <!-- TODO: Count heading rows only at top -->
        <xsl:attribute name="headrows" select="count(row[@role = 'label' or @role = 'unit'])"/>

        <xsl:apply-templates mode="normalize-table-final"/>
    </xsl:copy>
</xsl:template>


<xsl:template match="cell" mode="normalize-table-final">
    <xsl:if test="not(@spanned)">
        <xsl:copy>
            <xsl:attribute name="col" select="count(preceding-sibling::cell) + 1"/>
            <xsl:attribute name="row" select="count(../preceding-sibling::row) + 1"/>

            <!-- Restore the original cols and rows -->
            <xsl:if test="@orig_cols"><xsl:attribute name="cols" select="@orig_cols"/></xsl:if>
            <xsl:if test="@orig_rows"><xsl:attribute name="rows" select="@orig_rows"/></xsl:if>

            <xsl:copy-of select="@*[not(name() = 'rows')][not(name() = 'orig_rows')][not(name() = 'orig_cols')]"/>
            <xsl:copy-of select="node()"/>
        </xsl:copy>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>