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
        <xsl:param name="id-prefix" as="xs:string" tunnel="yes"/>
        <xsl:variable name="context" select="." as="element(lg)"/>

        <xsl:call-template name="closepar"/>
        <div>
            <xsl:copy-of select="f:set-lang-id-attributes(., $id-prefix)"/>
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
        <xsl:variable name="context" select="." as="element(lg)"/>
        <xsl:variable name="otherid" select="substring-before(substring-after(@rend, 'align-with('), ')')"/>
        <xsl:copy-of select="f:logInfo('Align verse {1} with verse {2}.', (@id, $otherid))"/>
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
        A line number is given a span with the class <code>lineNum</code>, and leaves it to the CSS to place it at the proper
        location. A hemistich is handled by adding a span with the class hemistich, which is supposed to contain the text
        of the previous line of the hemistichs, and leaves it to the CSS stylesheet to color that text white, so that
        it is rendered invisible (and the current of the hemistich shows up indented the correct way).</xd:detail>
    </xd:doc>

    <xsl:template match="l">
        <xsl:param name="id-prefix" as="xs:string" tunnel="yes"/>

        <xsl:element name="{$p.element}">
            <xsl:copy-of select="f:set-lang-id-attributes(., $id-prefix)"/>

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
                    <xsl:value-of select="f:rend-value(@rend, 'hemistich')"/>
                    <xsl:text> </xsl:text>
                </span>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>


    <xd:doc>
        <xd:short>Format an edition-specific line-break.</xd:short>
        <xd:detail>Format an edition-specific line-break. Line-breaks specific to an edition are not represented in the output</xd:detail>
    </xd:doc>

    <xsl:template match="lb[@ed]">
        <xsl:param name="id-prefix" as="xs:string" tunnel="yes"/>

        <a id="{f:generate-id(., $id-prefix)}"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Format a line-break.</xd:short>
        <xd:detail>Format a line-break. Line-breaks not linked to a specific edition are to be output.</xd:detail>
    </xd:doc>

    <xsl:template match="lb">
        <xsl:param name="id-prefix" as="xs:string" tunnel="yes"/>

        <br id="{f:generate-id(., $id-prefix)}"/>
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

        <xsl:copy-of select="f:logInfo('Elements in first: {1}; elements in second: {2}', (xs:string(count($a/*)), xs:string(count($b/*))))"/>
        <xsl:if test="count($a/*) != count($b/*)">
            <xsl:copy-of select="f:logWarning('Number of elements in verses to align does not match!', ())"/>
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
        <xsl:param name="id-prefix" as="xs:string" tunnel="yes"/>

        <xsl:element name="{$p.element}">
            <xsl:copy-of select="f:set-lang-id-attributes(., $id-prefix)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'line')"/>
            <xsl:apply-templates select="*|text()"/>
        </xsl:element>
    </xsl:template>


    <!--====================================================================-->
    <!-- Drama -->

    <xsl:template match="sp">
        <xsl:param name="id-prefix" as="xs:string" tunnel="yes"/>

        <div>
            <xsl:copy-of select="f:set-lang-id-attributes(., $id-prefix)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'sp')"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- Speaker -->
    <xsl:template match="speaker">
        <xsl:param name="id-prefix" as="xs:string" tunnel="yes"/>

        <xsl:element name="{$p.element}">
            <xsl:copy-of select="f:set-lang-id-attributes(., $id-prefix)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'speaker')"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!-- Stage directions -->
    <xsl:template match="stage">
        <xsl:param name="id-prefix" as="xs:string" tunnel="yes"/>

        <xsl:element name="{$p.element}">
            <xsl:copy-of select="f:set-lang-id-attributes(., $id-prefix)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'stage')"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="stage[@type='exit']">
        <xsl:param name="id-prefix" as="xs:string" tunnel="yes"/>

        <xsl:element name="{$p.element}">
            <xsl:copy-of select="f:set-lang-id-attributes(., $id-prefix)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'stage alignright')"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="stage[@rend='inline' or f:rend-value(@rend, 'position') = 'inline']">
        <xsl:param name="id-prefix" as="xs:string" tunnel="yes"/>

        <span>
            <xsl:copy-of select="f:set-lang-id-attributes(., $id-prefix)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'stage')"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- Cast lists -->
    <xsl:template match="castList">
        <xsl:param name="id-prefix" as="xs:string" tunnel="yes"/>

        <ul>
            <xsl:copy-of select="f:set-lang-id-attributes(., $id-prefix)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'castlist')"/>
            <xsl:apply-templates/>
        </ul>
    </xsl:template>

    <xsl:template match="castList/head">
        <xsl:param name="id-prefix" as="xs:string" tunnel="yes"/>

        <li>
            <xsl:copy-of select="f:set-lang-id-attributes(., $id-prefix)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'castlist')"/>
            <h4><xsl:apply-templates/></h4>
        </li>
    </xsl:template>

    <xsl:template match="castGroup">
        <xsl:param name="id-prefix" as="xs:string" tunnel="yes"/>

        <li>
            <xsl:copy-of select="f:set-lang-id-attributes(., $id-prefix)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'castlist')"/>
            <xsl:apply-templates select="head"/>
            <ul class="castGroup">
                <xsl:apply-templates select="castItem"/>
            </ul>
        </li>
    </xsl:template>

    <xsl:template match="castGroup/head">
        <xsl:param name="id-prefix" as="xs:string" tunnel="yes"/>

        <b>
            <xsl:copy-of select="f:set-lang-id-attributes(., $id-prefix)"/>
            <xsl:apply-templates/>
        </b>
    </xsl:template>

    <xsl:template match="castItem">
        <xsl:param name="id-prefix" as="xs:string" tunnel="yes"/>

        <li>
            <xsl:copy-of select="f:set-lang-id-attributes(., $id-prefix)"/>
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
        <xsl:param name="id-prefix" as="xs:string" tunnel="yes"/>

        <li>
            <xsl:copy-of select="f:set-lang-id-attributes(., $id-prefix)"/>
            <xsl:copy-of select="f:set-class-attribute-with(., 'castlist')"/>
            <xsl:variable name="count" select="count(.//castItem)"/>
            <xsl:variable name="this" select="."/>
            <table class="castGroupTable">
                <xsl:for-each select="castItem | castGroup">
                    <tr>
                        <td><xsl:apply-templates select="." mode="castGroupTable"/></td>
                        <xsl:if test="position() = 1">
                            <td rowspan="{$count}" class="castGroupBrace">
                                <xsl:copy-of select="f:outputImage('images/rbrace' || $count || '.png', '}')"/>
                            </td>
                            <td rowspan="{$count}"><xsl:apply-templates select="$this/*[self::head or self::roleDesc]" mode="castGroupTable"/></td>
                        </xsl:if>
                    </tr>
                </xsl:for-each>
            </table>
        </li>
    </xsl:template>

    <xsl:template match="castGroup/head" mode="castGroupTable">
        <xsl:param name="id-prefix" as="xs:string" tunnel="yes"/>

        <span>
            <xsl:copy-of select="f:set-lang-id-attributes(., $id-prefix)"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="castGroup/roleDesc" mode="castGroupTable">
        <xsl:param name="id-prefix" as="xs:string" tunnel="yes"/>

        <span>
            <xsl:copy-of select="f:set-lang-id-attributes(., $id-prefix)"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="castItem" mode="castGroupTable">
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>
