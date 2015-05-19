<!DOCTYPE xsl:stylesheet>

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f xd xs"
    version="2.0">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to format lists, to be imported in tei2html.xsl.</xd:short>
        <xd:detail>This stylesheet formats lists elements from TEI.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2014, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xd:doc>
        <xd:short>Format a list.</xd:short>
        <xd:detail>Format a standard list. Take care to open any possible <code>p</code>-elements first (and reopen them if needed).</xd:detail>
    </xd:doc>

    <xsl:template match="list">
        <xsl:call-template name="closepar"/>

        <xsl:variable name="listType" select="f:determine-list-type(@type)"/>

        <xsl:choose>
            <xsl:when test="contains(@rend, 'columns(')">
                <xsl:call-template name="splitlist"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{$listType}">
                    <xsl:call-template name="set-lang-id-attributes"/>
                    <xsl:call-template name="generate-rend-class-attribute-if-needed"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:call-template name="reopenpar"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Determine list-type.</xd:short>
        <xd:detail>Determine the HTML type of a list, based on its TEI <code>@type</code> attribute.</xd:detail>
    </xd:doc>

    <xsl:function name="f:determine-list-type" as="xs:string">
        <xsl:param name="type"/>
        <xsl:choose>
            <xsl:when test="$type = 'ordered'">ol</xsl:when>
            <xsl:otherwise>ul</xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xd:doc>
        <xd:short>Split a list into columns.</xd:short>
        <xd:detail>Split a list into columns; read relevant parameters.</xd:detail>
    </xd:doc>

    <xsl:template name="splitlist">
        <xsl:variable name="columns" as="xs:integer">
            <xsl:value-of select="number(substring-before(substring-after(@rend, 'columns('), ')'))"/>
        </xsl:variable>
        <xsl:variable name="item-order">
            <xsl:value-of select="substring-before(substring-after(@rend, 'item-order('), ')')"/>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$item-order = 'row-first'">
                <xsl:call-template name="splitlist-rows">
                    <xsl:with-param name="columns" select="$columns"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="splitlist-cols">
                    <xsl:with-param name="columns" select="$columns"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Split a list into columns (row-mayor; table).</xd:short>
        <xd:detail>Split a list into columns, using a table; order will be: [1, 2], [3, 4].</xd:detail>
    </xd:doc>

    <xsl:template name="splitlist-rows-table">
        <xsl:param name="columns" select="2" as="xs:integer"/>

        <table>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:for-each-group select="*" group-by="(position() - 1) idiv $columns">
                <tr>
                    <xsl:apply-templates select="current-group()" mode="listitem-as-tablecell"/>
                </tr>
            </xsl:for-each-group>
        </table>
    </xsl:template>


    <xd:doc>
        <xd:short>Split a list into columns (column-mayor; table).</xd:short>
        <xd:detail>Split a list into columns, using a table; order will be: [1, 3], [2, 4].</xd:detail>
    </xd:doc>

    <xsl:template name="splitlist-cols-table">
        <xsl:param name="columns" select="2" as="xs:integer"/>

        <xsl:variable name="rows" select="ceiling(count(*) div $columns)"/>

        <table>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:for-each-group select="*" group-by="(position() - 1) mod $rows">
                <tr>
                    <xsl:apply-templates select="current-group()" mode="listitem-as-tablecell"/>
                </tr>
            </xsl:for-each-group>
        </table>
    </xsl:template>


    <xd:doc>
        <xd:short>Split a list into columns (column-first; table with lists).</xd:short>
        <xd:detail>Split a list into columns, using a table; order will be: [1, 2], [3, 4].</xd:detail>
    </xd:doc>

    <xsl:template name="splitlist-cols">
        <xsl:param name="columns" select="2" as="xs:integer"/>

        <xsl:variable name="listType" select="f:determine-list-type(@type)"/>
        <xsl:variable name="rows" select="ceiling(count(*) div $columns)"/>
        <xsl:variable name="rend" select="@rend"/>
        <xsl:variable name="node" select="."/>

        <table class="splitlisttable">
            <xsl:call-template name="set-lang-id-attributes"/>
            <tr>
                <xsl:for-each-group select="*" group-by="(position() - 1) idiv $rows">
                    <td>
                        <xsl:element name="{$listType}">
                            <xsl:call-template name="generate-rend-class-attribute-if-needed">
                                <xsl:with-param name="rend" select="$rend"/>
                                <xsl:with-param name="node" select="$node"/>
                            </xsl:call-template>
                            <xsl:apply-templates select="current-group()"/>
                        </xsl:element>
                    </td>
                </xsl:for-each-group>
            </tr>
        </table>
    </xsl:template>


    <xd:doc>
        <xd:short>Split a list into columns (row-first; table with lists).</xd:short>
        <xd:detail>Split a list into columns, using a table; order will be: [1, 3], [2, 4].</xd:detail>
    </xd:doc>

    <xsl:template name="splitlist-rows">
        <xsl:param name="columns" select="2" as="xs:integer"/>

        <xsl:variable name="listType" select="f:determine-list-type(@type)"/>
        <xsl:variable name="rend" select="@rend"/>
        <xsl:variable name="node" select="."/>

        <table class="splitlisttable">
            <xsl:call-template name="set-lang-id-attributes"/>
            <tr>
                <xsl:for-each-group select="*" group-by="(position() - 1) mod $columns">
                    <td>
                        <xsl:element name="{$listType}">
                            <xsl:call-template name="generate-rend-class-attribute-if-needed">
                                <xsl:with-param name="rend" select="$rend"/>
                                <xsl:with-param name="node" select="$node"/>
                            </xsl:call-template>
                            <xsl:apply-templates select="current-group()"/>
                        </xsl:element>
                    </td>
                </xsl:for-each-group>
            </tr>
        </table>
    </xsl:template>


    <xd:doc>
        <xd:short>Format a list item as a table cell.</xd:short>
        <xd:detail>Format a a list item as a table cell (used when formatting lists in multiple columns, using tables).</xd:detail>
    </xd:doc>

    <xsl:template match="item" mode="listitem-as-tablecell">
        <td>
            <xsl:call-template name="handle-item"/>
        </td>
    </xsl:template>


    <xd:doc>
        <xd:short>Format a list item.</xd:short>
        <xd:detail>Format a a list item.</xd:detail>
    </xd:doc>

    <xsl:template match="item">
        <li>
            <xsl:call-template name="handle-item"/>
        </li>
    </xsl:template>


    <xd:doc>
        <xd:short>Format the contents of a list item.</xd:short>
        <xd:detail>Format the contents of a list item.</xd:detail>
    </xd:doc>

    <xsl:template name="handle-item">
        <xsl:call-template name="set-lang-id-attributes"/>
        <xsl:call-template name="generate-rend-class-attribute-if-needed"/>
        <xsl:if test="@n and ($outputformat != 'epub')">
            <!-- The value attribute is no longer valid in HTML5, so exclude it for ePub3 -->
            <xsl:attribute name="value">
                <xsl:value-of select="@n"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>


</xsl:stylesheet>
