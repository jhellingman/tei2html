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
        <xd:short>Stylesheet to format lists, to be imported in tei2html.xsl.</xd:short>
        <xd:detail>This stylesheet formats lists elements from TEI.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2016, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Format a list.</xd:short>
        <xd:detail>Format a standard list. Take care to open any possible <code>p</code>-elements first (and reopen them if needed).</xd:detail>
    </xd:doc>

    <xsl:template match="list">
        <xsl:call-template name="closepar"/>

        <xsl:variable name="listType" select="f:determine-list-type(@type)"/>

        <xsl:choose>
            <xsl:when test="f:has-rend-value(@rend, 'columns')">
                <xsl:call-template name="splitlist"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="{$listType}">
                    <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                    <xsl:copy-of select="f:set-class-attribute(.)"/>
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
        <xsl:param name="type" as="xs:string?"/>
        <xsl:value-of select="if ($type = 'ordered') then 'ol' else 'ul'"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Split a list into columns.</xd:short>
        <xd:detail>Split a list into columns; read relevant parameters.</xd:detail>
    </xd:doc>

    <xsl:template name="splitlist">
        <xsl:variable name="columns" as="xs:integer">
            <xsl:value-of select="number(f:rend-value(@rend, 'columns'))"/>
        </xsl:variable>
        <xsl:variable name="item-order" as="xs:string">
            <xsl:value-of select="f:rend-value(@rend, 'item-order')"/>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$item-order = 'column-major'">
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
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
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
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:for-each-group select="*" group-by="(position() - 1) mod $rows">
                <tr>
                    <xsl:apply-templates select="current-group()" mode="listitem-as-tablecell"/>
                </tr>
            </xsl:for-each-group>
        </table>
    </xsl:template>


    <xd:doc>
        <xd:short>Split a list into columns (row-mayor; table with lists).</xd:short>
        <xd:detail>Split a list into columns, using a table; order will be: [1, 2], [3, 4].</xd:detail>
    </xd:doc>

    <xsl:template name="splitlist-cols">
        <xsl:param name="columns" select="2" as="xs:integer"/>

        <xsl:variable name="listType" select="f:determine-list-type(@type)"/>
        <xsl:variable name="rows" select="ceiling(count(*) div $columns)"/>
        <xsl:variable name="node" select="."/>

        <table class="splitListTable">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <tr>
                <xsl:for-each-group select="*" group-by="(position() - 1) idiv $rows">
                    <td>
                        <xsl:element name="{$listType}">
                            <xsl:copy-of select="f:set-class-attribute($node)"/>
                            <xsl:apply-templates select="current-group()"/>
                        </xsl:element>
                    </td>
                </xsl:for-each-group>
            </tr>
        </table>
    </xsl:template>


    <xd:doc>
        <xd:short>Split a list into columns (column-major; table with lists).</xd:short>
        <xd:detail>Split a list into columns, using a table; order will be: [1, 3], [2, 4].</xd:detail>
    </xd:doc>

    <xsl:template name="splitlist-rows">
        <xsl:param name="columns" select="2" as="xs:integer"/>

        <xsl:variable name="listType" select="f:determine-list-type(@type)"/>
        <xsl:variable name="node" select="."/>

        <table class="splitListTable">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <tr>
                <xsl:for-each-group select="*" group-by="(position() - 1) mod $columns">
                    <td>
                        <xsl:element name="{$listType}">
                            <xsl:copy-of select="f:set-class-attribute($node)"/>
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
        <xd:detail>Format a list item.</xd:detail>
    </xd:doc>

    <xsl:template match="item">
        <li>
            <xsl:call-template name="handle-item"/>
        </li>
    </xsl:template>


    <xd:doc>
        <xd:short>Format a group of items.</xd:short>
        <xd:detail>Format a group of list items. Sometimes, lists are encountered with braces that group items. The (non-standard)
        element <code>itemGroup</code> provides an easy shortcut to encode them and achieve the graphic result. Note that this
        is different from a nested list, in that item groups remain at the same level. An alternative approach would be using an
        embedded table or nested list.
        See also the stylesheet for <code>castGroup</code> in <code>drama.xsl</code>.</xd:detail>
    </xd:doc>

    <xsl:template match="itemGroup">
        <li>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:variable name="numberedItemClass" select="if (item/ab[@type='itemNum']) then ' numberedItem' else ''" as="xs:string"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'itemGroup' || $numberedItemClass)"/>

            <xsl:variable name="this" select="."/>
            <xsl:variable name="count" select="count(item)"/>
            <xsl:variable name="before" select="(*|text())[not(self::item or preceding-sibling::item)]"/>
            <xsl:variable name="after" select="(*|text())[not(self::item or following-sibling::item)]"/>
            <xsl:variable name="contentBefore" select="normalize-space(string-join($before, '')) != ''"/>
            <xsl:variable name="contentAfter" select="normalize-space(string-join($after, '')) != ''"/>

            <table class="itemGroupTable">
                <xsl:for-each select="item">
                    <tr>
                        <xsl:if test="position() = 1">
                            <xsl:if test="$contentBefore">
                                <td rowspan="{$count}"><xsl:apply-templates select="$before"/></td>
                            </xsl:if>
                            <xsl:if test="$contentBefore or $this/@rend='braceBefore'">
                                <td rowspan="{$count}" class="itemGroupBrace">
                                    <xsl:copy-of select="f:output-image('images/lbrace' || $count || '.png', '{')"/>
                                </td>
                            </xsl:if>
                        </xsl:if>
                        <td>
                            <xsl:apply-templates select="." mode="itemGroupTable"/>
                        </td>
                        <xsl:if test="position() = 1">
                            <xsl:if test="$contentAfter or $this/@rend='braceAfter'">
                                <td rowspan="{$count}" class="itemGroupBrace">
                                    <xsl:copy-of select="f:output-image('images/rbrace' || $count || '.png', '}')"/>
                                </td>
                            </xsl:if>
                            <xsl:if test="$contentAfter">
                                <td rowspan="{$count}"><xsl:apply-templates select="$after"/></td>
                            </xsl:if>
                        </xsl:if>
                    </tr>
                </xsl:for-each>
            </table>
        </li>
    </xsl:template>

    <!-- TEI conforming variant of the above -->
    <xsl:template match="list[@type='itemGroup']">
        <li>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:variable name="numberedItemClass" select="if (item/ab[@type='itemNum']) then ' numberedItem' else ''" as="xs:string"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'itemGroup' || $numberedItemClass)"/>

            <xsl:variable name="this" select="."/>
            <xsl:variable name="count" select="count(item)"/>

            <table class="itemGroupTable">
                <xsl:for-each select="item">
                    <tr>
                        <xsl:if test="position() = 1">
                            <xsl:if test="$this/head">
                                <td rowspan="{$count}"><xsl:apply-templates select="$this/head/node()"/></td>
                            </xsl:if>
                            <xsl:if test="$this/head or $this/@rend='braceBefore'">
                                <td rowspan="{$count}" class="itemGroupBrace">
                                    <xsl:copy-of select="f:output-image('images/lbrace' || $count || '.png', '{')"/>
                                </td>
                            </xsl:if>
                        </xsl:if>
                        <td>
                            <xsl:apply-templates select="." mode="itemGroupTable"/>
                        </td>
                        <xsl:if test="position() = 1">
                            <xsl:if test="$this/trailer or $this/@rend='braceAfter'">
                                <td rowspan="{$count}" class="itemGroupBrace">
                                    <xsl:copy-of select="f:output-image('images/rbrace' || $count || '.png', '}')"/>
                                </td>
                            </xsl:if>
                            <xsl:if test="$this/trailer">
                                <td rowspan="{$count}"><xsl:apply-templates select="$this/trailer/node()"/></td>
                            </xsl:if>
                        </xsl:if>
                    </tr>
                </xsl:for-each>
            </table>
        </li>
    </xsl:template>

    <xsl:template match="item" mode="itemGroupTable">
        <xsl:call-template name="handle-item"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Format the contents of a list item.</xd:short>
        <xd:detail>Format the contents of a list item. Since the item numbering abilities of HTML are
        limited, we supply our own item number mechanism, using a span, and
        only when the number is supplied on the item or in an <code>&lt;ab type="itemNum"&gt;</code> element.</xd:detail>
    </xd:doc>

    <xsl:template name="handle-item">
        <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
        <xsl:copy-of select="f:set-class-attribute-with(., if (not(..[@type = 'ordered']) and (@n or ./ab[@type='itemNum'][position() = 1])) then 'numberedItem' else '')"/>

        <xsl:choose>
            <!-- For ordered lists, the numbers are supplied by the browser -->
            <xsl:when test="..[@type = 'ordered']">
                <xsl:if test="@n and not(f:is-epub())">
                    <!-- The value attribute is no longer valid in HTML5, so exclude it for ePub3 -->
                    <xsl:attribute name="value">
                        <xsl:value-of select="@n"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:when>
            <!-- For unordered lists, we (optionally) supply the numbers -->
            <xsl:when test="./ab[@type='itemNum'][position() = 1]">
                <span class="itemNumber"><xsl:apply-templates select="./ab[@type='itemNum'][position() = 1]/node()"/></span>
            </xsl:when>
            <xsl:when test="@n">
                <span class="itemNumber"><xsl:copy-of select="f:convert-markdown(@n)"/></span><xsl:text> </xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template match="ab[@type='itemNum'][position() = 1]"/>


</xsl:stylesheet>
