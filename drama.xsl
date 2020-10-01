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

<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f xd xhtml xs">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to convert the verse and drama in a TEI file to HTML</xd:short>
        <xd:detail>This stylesheet to convert the verse and drama elements in a TEI file to HTML.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2014, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <!--====================================================================-->
    <!-- Poetry -->

    <xd:doc>
        <xd:short>Format an lg element.</xd:short>
        <xd:detail>Determine whether we need to align with another verse, or just deal with the simple case.</xd:detail>
    </xd:doc>

    <xsl:template match="lg">
        <xsl:choose>
            <xsl:when test="f:rend-value(@rend, 'display') = 'none'"/>
            <xsl:when test="f:has-rend-value(@rend, 'align-with')">
                <xsl:call-template name="handleAlignedLg"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="handleLg"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Format a normal lg element.</xd:short>
        <xd:detail>Format an lg element. top-level lg elements get class=lgouter, nested lg elements get class=lg.
        This we use (using CSS) to center the entire poem on the screen, and still keep the left side
        of all stanzas aligned.</xd:detail>
    </xd:doc>

    <xsl:template name="handleLg">
        <xsl:context-item as="element(lg)" use="required"/>

        <xsl:call-template name="closepar"/>
        <div>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:variable name="class">
                <xsl:if test="not(parent::lg) and not(parent::sp)">lgouter<xsl:text> </xsl:text></xsl:if>
                <xsl:if test="parent::lg or parent::sp">lg<xsl:text> </xsl:text></xsl:if>
                <xsl:if test="ancestor::note[@place='foot' or @place='undefined' or not(@place)]">footnote<xsl:text> </xsl:text></xsl:if>
            </xsl:variable>
            <xsl:copy-of select="f:set-class-attribute-with(., $class)"/>
            <xsl:apply-templates/>
        </div>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Format two aligned lg elements.</xd:short>
        <xd:detail>Format two aligned lg elements: determine which two verses need to be aligned.</xd:detail>
    </xd:doc>

    <xsl:template name="handleAlignedLg">
        <xsl:context-item as="element(lg)" use="required"/>
        <xsl:variable name="otherid" select="f:rend-value(@rend, 'align-with')"/>
        <xsl:copy-of select="f:log-info('Align verse {1} with verse {2}.', (@id, $otherid))"/>
        <xsl:call-template name="align-verses">
            <xsl:with-param name="a" select="."/>
            <xsl:with-param name="b" select="//*[@id=$otherid]"/>
        </xsl:call-template>
    </xsl:template>


    <xd:doc>
        <xd:short>Format a head in an lg element.</xd:short>
        <xd:detail>Format a <code>head</code> in an <code>lg</code> element. Represented as an h4 level head in HTML.</xd:detail>
    </xd:doc>

    <xsl:template match="lg/head">
        <h4>
            <xsl:copy-of select="f:set-class-attribute(.)"/>
            <xsl:apply-templates/>
        </h4>
    </xsl:template>


    <xd:doc>
        <xd:short>Format a line of verse.</xd:short>
        <xd:detail>Format a line of verse. This takes care of adding line-numbers, and dealing with hemistich.
        A line number is given a span with the class <code>lineNum</code>, and leaves it to the CSS to place
        it at the proper location. A hemistich is handled by adding a span with the class <code>hemistich</code>,
        which is supposed to contain the text of the previous part of the hemistich, and leaves it to the CSS
        stylesheet to hide that text and the current line of the hemistich shows up indented the correct way).</xd:detail>
    </xd:doc>

    <xsl:template match="l">
        <xsl:element name="{$p.element}">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>

            <xsl:variable name="class">
                <xsl:text>line </xsl:text>
                <xsl:value-of select="f:hanging-punctuation-class(.)"/>
            </xsl:variable>
            <xsl:copy-of select="f:set-class-attribute-with(., $class)"/>

            <xsl:if test="@n">
                <span class="lineNum"><xsl:value-of select="@n"/></span>
            </xsl:if>

            <xsl:if test="f:has-rend-value(@rend, 'hemistich')">
                <span class="hemistich">
                    <xsl:copy-of select="f:handle-hemistich-value(.)"/>
                </span>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:function name="f:handle-hemistich-value">
        <xsl:param name="node" as="element()"/>
        <xsl:variable name="value" select="f:rend-value($node/@rend, 'hemistich')" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="starts-with($value, '^')">
                <!-- Hemistich value points to n lines above (one if parameter is empty) -->
                <xsl:variable name="n" select="if ($value = '^') then 1 else xs:integer(substring($value, 2))" as="xs:integer"/>
                <xsl:variable name="target-node" select="$node/preceding::l[$n]"/>
                <xsl:variable name="content">
                    <!-- We can have a hemistich that recursively builds up from previous hemistiches. -->
                    <xsl:if test="f:has-rend-value($target-node/@rend, 'hemistich')">
                        <xsl:copy-of select="f:handle-hemistich-value($target-node)"/>
                    </xsl:if>
                    <xsl:apply-templates select="$target-node/node()"/>
                </xsl:variable>
                <xsl:if test="not($content)">
                    <xsl:copy-of select="f:log-error('No previous line found for hemistich', ())"/>
                </xsl:if>
                <xsl:if test="$content//stage or $content//ab">
                    <xsl:copy-of select="f:log-warning('Hemistich contains stage instruction or ab', ())"/>
                </xsl:if>
                <xsl:copy-of select="f:copy-without-ids($content)"/>
            </xsl:when>
            <xsl:when test="starts-with($value, '#')">
                <!-- Hemistich value gives ID of element with content to use -->
                <xsl:variable name="target-id" select="substring($value, 2)" as="xs:string"/>
                <xsl:variable name="target-node" select="root($node)//*[@id=$target-id]"/>
                <xsl:choose>
                    <xsl:when test="$node/@id = $target-id">
                        <xsl:copy-of select="f:log-error('Element referenced itself in hemistich (id={1})', ($target-id))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="content">
                            <!-- We can have a hemistich that recursively builds up from previous hemistiches; note
                                 also that we sometimes refer to a part of a previous line (to exclude stage directions, etc.), so we need to recurse from the line itself. -->
                            <xsl:variable name="hemistich-line" select="$target-node/ancestor-or-self::l"/>
                            <xsl:if test="f:has-rend-value($hemistich-line/@rend, 'hemistich')">
                                <xsl:copy-of select="f:handle-hemistich-value($hemistich-line)"/>
                            </xsl:if>
                            <xsl:apply-templates select="$target-node/node()"/>
                        </xsl:variable>
                        <xsl:if test="not($content)">
                            <xsl:copy-of select="f:log-error('Element referenced in hemistich not found (id={1})', ($target-id))"/>
                        </xsl:if>
                        <xsl:if test="$content//stage or $content//ab">
                            <xsl:copy-of select="f:log-warning('Hemistich contains stage instruction or ab', ())"/>
                        </xsl:if>
                        <xsl:copy-of select="f:copy-without-ids($content)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- Hemistich value gives the literal string content to use width of -->
                <xsl:value-of select="f:rend-value($node/@rend, 'hemistich')"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text> </xsl:text>
    </xsl:function>


    <!-- See block.xsl for called templates -->
    <xsl:template match="l[f:has-rend-value(@rend, 'initial-image')]">
        <xsl:call-template name="handle-initial-image"/>
    </xsl:template>

    <xsl:template match="l[f:has-rend-value(@rend, 'initial-image')]" mode="css">
        <xsl:call-template name="handle-initial-image-css"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Format an edition-specific line-break.</xd:short>
        <xd:detail>Format an edition-specific line-break. Line-breaks specific to an edition are not represented in the output</xd:detail>
    </xd:doc>

    <xsl:template match="lb[@ed]">
        <a id="{f:generate-id(.)}"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Format a line-break.</xd:short>
        <xd:detail>Format a line-break. Line-breaks not linked to a specific edition are to be output.</xd:detail>
    </xd:doc>

    <xsl:template match="lb">
        <xsl:choose>
            <xsl:when test="f:is-set('lb.preserve')">
                <br id="{f:generate-id(.)}"/>
                <xsl:if test="f:has-rend-value(@rend, 'indent')">
                    <span class="indent{f:generate-id(.)}"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <a id="{f:generate-id(.)}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="lb" mode="css">
        <xsl:if test="f:is-set('lb.preserve') and f:has-rend-value(@rend, 'indent')">
.indent<xsl:value-of select="f:generate-id(.)"/> {
    padding-left: <xsl:value-of select="f:indent-value(f:rend-value(@rend, 'indent'))"/>;
}
</xsl:if>
        <xsl:next-match/>
    </xsl:template>


    <!--====================================================================-->
    <!-- code to align two verses  -->

    <xd:doc mode="alignedverse">
        <xd:short>Mode used to format lines in aligned verse.</xd:short>
        <xd:detail>This mode takes care the heads and lines are properly wrapped in <code>span</code> and <code>p</code>-element in the HTML output.</xd:detail>
    </xd:doc>

    <xd:doc>
        <xd:short>Align two verses.</xd:short>
        <xd:detail>Align two verses in a table. Here the assumption is that both verses have
        the same number of elements. We simply iterate through both, and place them side-by-side.
        Note that the <code>@rend</code> attribute on the <code>lg</code> elements will be ignored. Line numbers will be inserted
        from either of both verses to be aligned, in a separate column.</xd:detail>
    </xd:doc>

    <xsl:template name="align-verses">
        <xsl:param name="a" as="element(lg)"/>
        <xsl:param name="b" as="element(lg)"/>

        <xsl:variable name="hasNumbers" select="$a/*[@n] | $b/*[@n]"/>

        <xsl:copy-of select="f:log-info('Elements in first: {1}; elements in second: {2}', (xs:string(count($a/*)), xs:string(count($b/*))))"/>
        <xsl:if test="count($a/*) != count($b/*)">
            <xsl:copy-of select="f:log-warning('Number of elements in verses to align does not match!', ())"/>
        </xsl:if>

        <table class="alignedverse">
            <xsl:for-each select="$a/*">
                <xsl:variable name="position" select="count(preceding-sibling::*) + 1"/>
                <tr>
                    <xsl:if test="$hasNumbers">
                        <td class="lineNumbers">
                            <xsl:choose>
                                <xsl:when test="@n">
                                    <span class="lineNum"><xsl:value-of select="@n"/></span>
                                </xsl:when>
                                <xsl:when test="$b/*[$position]/@n">
                                    <span class="lineNum"><xsl:value-of select="$b/*[$position]/@n"/></span>
                                </xsl:when>
                            </xsl:choose>
                        </td>
                    </xsl:if>
                    <td class="first"><xsl:apply-templates mode="alignedverse" select="."/></td>
                    <td class="second"><xsl:apply-templates mode="alignedverse" select="$b/*[$position]"/></td>
                </tr>
            </xsl:for-each>
        </table>

    </xsl:template>


    <xd:doc>
        <xd:short>Format a head in aligned verse.</xd:short>
        <xd:detail>Since we cannot have an <code>h2</code>-elements inside tables in HTML, we place the head in
        a span, and give it the CSS-class <code>h2</code>, so we can make it look like a head.</xd:detail>
    </xd:doc>

    <xsl:template mode="alignedverse" match="head">
        <span class="h4"><xsl:apply-templates/></span>
    </xsl:template>


    <xd:doc>
        <xd:short>Format a line-group in aligned verse.</xd:short>
    </xd:doc>

    <xsl:template mode="alignedverse" match="lg">
        <xsl:apply-templates select="."/>
    </xsl:template>


    <xd:doc>
        <xd:short>Format a line in aligned verse.</xd:short>
    </xd:doc>

    <xsl:template mode="alignedverse" match="l">
        <xsl:element name="{$p.element}">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'line')"/>
            <xsl:apply-templates select="*|text()"/>
        </xsl:element>
    </xsl:template>


    <!--====================================================================-->
    <!-- Drama -->

    <xsl:template match="sp">
        <div>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'sp')"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- Speaker -->
    <xsl:template match="speaker">
        <xsl:element name="{$p.element}">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'speaker')"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!-- When a speaker immediately followed by an inline stage instruction, join them together. -->
    <xsl:template match="speaker[f:followed-by-inline-stage(.)]">
        <xsl:element name="{$p.element}">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <span>
                <xsl:copy-of select="f:set-class-attribute-with(., 'speaker')"/>
                <xsl:apply-templates/>
            </span>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="./following-sibling::node()[1][self::stage[f:is-inline(.)]]" mode="inline-stage"/>
        </xsl:element>
    </xsl:template>

    <!-- Stage directions -->
    <xsl:template match="stage">
        <xsl:if test="parent::l or parent::p">
            <xsl:copy-of select="f:log-warning('Non-inline stage instruction part of line or paragraph: {1}', (.))"/>
        </xsl:if>
        <xsl:element name="{$p.element}">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'stage')"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="stage[@type='exit']">
        <xsl:element name="{$p.element}">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'stage alignright')"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="stage[f:is-inline(.)]">
        <xsl:if test="not(f:preceded-by-speaker(.))">
            <xsl:apply-templates select="." mode="inline-stage"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="stage[f:is-inline(.)]" mode="inline-stage">
        <span>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'stage')"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:function name="f:followed-by-inline-stage" as="xs:boolean">
        <xsl:param name="node" as="element()"/>
        <xsl:sequence select="boolean($node/following-sibling::node()[1][self::stage[f:is-inline(.)]])"/>
    </xsl:function>

    <xsl:function name="f:preceded-by-speaker" as="xs:boolean">
        <xsl:param name="node" as="element()"/>
        <xsl:sequence select="boolean($node/preceding-sibling::node()[1][self::speaker])"/>
    </xsl:function>


    <!-- Cast lists -->
    <xsl:template match="castList">
        <ul>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'castlist')"/>
            <xsl:apply-templates/>
        </ul>
    </xsl:template>

    <xsl:template match="castList/head">
        <li>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'castlist')"/>
            <h4><xsl:apply-templates/></h4>
        </li>
    </xsl:template>

    <xsl:template match="castGroup">
        <li>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'castlist')"/>
            <xsl:apply-templates select="head"/>
            <ul class="castGroup">
                <xsl:apply-templates select="castItem"/>
            </ul>
        </li>
    </xsl:template>

    <xsl:template match="castGroup/head">
        <b>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </b>
    </xsl:template>

    <xsl:template match="castItem">
        <li>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'castitem')"/>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xd:doc>
        <xd:short>Render a castGroup with a brace on the right.</xd:short>
        <xd:detail><p>Render a castGroup as a table with a brace on the right, followed by some description common to all the castItems in the group, which text is to be encoded in the head. This assumes an image file named <code>rbrace<i>N</i></code> is present, where <i>N</i> is the number of castItems in the castGroup.</p>

        <p>This was specially implemented to render the cast-lists, as found in the works of Shakespeare, in the same way as in the original work, without having
        to add significant presentation-oriented tagging to the TEI source files. See also the stylesheet for <code>itemGroup</code> in list.xsl.</p></xd:detail>
    </xd:doc>

    <xsl:template match="castGroup[f:rend-value(@rend, 'display') = 'castGroupTable']" mode="#default castGroupTable">
        <li>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'castlist')"/>
            <xsl:variable name="count" select="count(.//castItem)"/>
            <xsl:variable name="this" select="."/>
            <table class="castGroupTable">
                <xsl:for-each select="castItem | castGroup">
                    <tr>
                        <td><xsl:apply-templates select="." mode="castGroupTable"/></td>
                        <xsl:if test="position() = 1">
                            <td rowspan="{$count}" class="castGroupBrace">
                                <xsl:copy-of select="f:output-image('images/rbrace' || $count || '.png', '}')"/>
                            </td>
                            <td rowspan="{$count}"><xsl:apply-templates select="$this/*[self::head or self::roleDesc]" mode="castGroupTable"/></td>
                        </xsl:if>
                    </tr>
                </xsl:for-each>
            </table>
        </li>
    </xsl:template>

    <xsl:template match="castGroup/head" mode="castGroupTable">
        <span>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="castGroup/roleDesc" mode="castGroupTable">
        <span>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="castItem" mode="castGroupTable">
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>
