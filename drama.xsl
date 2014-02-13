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

    Stylesheet to format inline elements, to be imported in tei2html.xsl.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="xd"
    version="2.0"
    >

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to convert the verse and drama in a TEI file to HTML</xd:short>
        <xd:detail>This stylesheet to convert the verse and drama elements in a TEI file to HTML.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2013, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <!--====================================================================-->
    <!-- Poetry -->

    <xd:doc>
        <xd:short>Format an lg element.</xd:short>
        <xd:detail>Determine whether we need to align with another verse, or just deal with the simple case.</xd:detail>
    </xd:doc>

    <xsl:template match="lg">
        <xsl:choose>
            <xsl:when test="contains(@rend, 'display(none)')"/>
            <xsl:when test="contains(@rend, 'align-with(')">
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
        <xsl:call-template name="closepar"/>
        <div>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:attribute name="class">
                <xsl:if test="not(parent::lg) and not(parent::sp)">lgouter<xsl:text> </xsl:text></xsl:if>
                <xsl:if test="parent::lg or parent::sp">lg<xsl:text> </xsl:text></xsl:if>
                <xsl:if test="ancestor::note[@place='foot' or @place='undefined' or not(@place)]">footnote<xsl:text> </xsl:text></xsl:if>
                <xsl:call-template name="generate-rend-class-name-if-needed"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </div>
        <xsl:call-template name="reopenpar"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Format two aligned lg elements.</xd:short>
        <xd:detail>Format two aligned lg elements: determine which two verses need to be aligned.</xd:detail>
    </xd:doc>

    <xsl:template name="handleAlignedLg">
        <xsl:variable name="otherid" select="substring-before(substring-after(@rend, 'align-with('), ')')"/>
        <xsl:message terminate="no">INFO:    Align verse <xsl:value-of select="@id"/> with verse <xsl:value-of select="$otherid"/></xsl:message>
        <xsl:call-template name="align-verses">
            <xsl:with-param name="a" select="."/>
            <xsl:with-param name="b" select="//*[@id=$otherid]"/>
        </xsl:call-template>
    </xsl:template>


    <xd:doc>
        <xd:short>Format a head in an lg element.</xd:short>
        <xd:detail>Format a head in an lg element. Represented as an h4 level head in HTML.</xd:detail>
    </xd:doc>

    <xsl:template match="lg/head">
        <h4>
            <xsl:call-template name="generate-rend-class-attribute-if-needed"/>
            <xsl:apply-templates/>
        </h4>
    </xsl:template>


    <xd:doc>
        <xd:short>Format a line of verse.</xd:short>
        <xd:detail>Format a line of verse. This takes care of adding line-numbers, and dealing with hemistich.
        A line number is given a span with the class linenum, and leaves it to the CSS to place it at the proper
        location. A hemistich is handled by adding a span with the class hemistich, which is supposed to contain the text
        of the previous line of the hemistichs, and leaves it to the CSS stylesheet to color that text white, so that
        it is rendered invisible (and the current of the hemistich shows up indented the correct way).</xd:detail>
    </xd:doc>

    <xsl:template match="l">
        <p>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:attribute name="class">line <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>

            <xsl:if test="@n">
                <span class="linenum"><xsl:value-of select="@n"/></span>
            </xsl:if>

            <xsl:if test="contains(@rend, 'hemistich(')">
                <span class="hemistich">
                    <xsl:value-of select="substring-before(substring-after(@rend, 'hemistich('), ')')"/>
                    <xsl:text> </xsl:text>
                </span>
            </xsl:if>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- linebreaks specific to an edition are not represented in the output -->
    <xsl:template match="lb[@ed]">
        <a>
            <xsl:call-template name="generate-id-attribute"/>
        </a>
    </xsl:template>

    <!-- linebreaks not linked to a specific edition are to be output -->
    <xsl:template match="lb">
        <br>
            <xsl:call-template name="generate-id-attribute"/>
        </br>
    </xsl:template>


    <!--====================================================================-->
    <!-- code to align two verses  -->

    <xd:doc>
        <xd:short>Align two verses.</xd:short>
        <xd:detail>Align two verses in a table. Here the assumption is that both verses have
        the same number of elements. We simply iterate through both, and place them side-by-side.
        Note that the rend attribute on the lg elements will be ignored. Linenumbers will be inserted
        from either of both verses to be aligned, in a separate column.</xd:detail>
    </xd:doc>

    <xsl:template name="align-verses">
        <xsl:param name="a"/>
        <xsl:param name="b"/>

        <xsl:variable name="hasNumbers" select="$a/*[@n] | $b/*[@n]"/>

        <xsl:message terminate="no">INFO:    Elements in first: <xsl:value-of select="count($a/*)"/>; elements in second <xsl:value-of select="count($b/*)"/>.</xsl:message>

        <xsl:if test="count($a/*) != count($b/*)">
            <xsl:message terminate="no">WARNING: Number of elements in verses to align does not match!</xsl:message>
        </xsl:if>

        <table class="alignedverse">
            <xsl:for-each select="$a/*">
                <xsl:variable name="position" select="count(preceding-sibling::*) + 1"/>
                <tr>
                    <xsl:if test="$hasNumbers">
                        <td class="linenumbers">
                            <xsl:choose>
                                <xsl:when test="@n">
                                    <span class="linenum"><xsl:value-of select="@n"/></span>
                                </xsl:when>
                                <xsl:when test="$b/*[$position]/@n">
                                    <span class="linenum"><xsl:value-of select="$b/*[$position]/@n"/></span>
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


    <xsl:template mode="alignedverse" match="head">
        <span class="h4"><xsl:apply-templates/></span>
    </xsl:template>

    <xsl:template mode="alignedverse" match="lg">
        <xsl:apply-templates select="."/>
    </xsl:template>

    <xsl:template mode="alignedverse" match="l">
        <p>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:attribute name="class">line <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:apply-templates select="*|text()"/>
        </p>
    </xsl:template>


    <!--====================================================================-->
    <!-- Drama -->

    <xsl:template match="sp">
        <div>
            <xsl:attribute name="class">sp <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- Speaker -->
    <xsl:template match="speaker">
        <p>
            <xsl:attribute name="class">speaker <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- Stage directions -->
    <xsl:template match="stage">
        <p>
            <xsl:attribute name="class">stage <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="stage[@type='exit']">
        <p>
            <xsl:attribute name="class">stage alignright <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="stage[@rend='inline' or contains(@rend, 'position(inline)')]">
        <span>
            <xsl:attribute name="class">stage <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <!-- Cast lists -->
    <xsl:template match="castList">
        <ul>
            <xsl:attribute name="class">castlist <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </ul>
    </xsl:template>

    <xsl:template match="castList/head">
        <li>
            <xsl:attribute name="class">castlist <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="set-lang-id-attributes"/>
            <h4><xsl:apply-templates/></h4>
        </li>
    </xsl:template>

    <xsl:template match="castGroup">
        <li>
            <xsl:attribute name="class">castlist <xsl:call-template name="generate-rend-class-name-if-needed"/></xsl:attribute>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates select="head"/>
            <ul class="castGroup">
                <xsl:apply-templates select="castItem"/>
            </ul>
        </li>
    </xsl:template>

    <xsl:template match="castGroup/head">
        <b>
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </b>
    </xsl:template>

    <xsl:template match="castItem">
        <li class="castitem">
            <xsl:call-template name="set-lang-id-attributes"/>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

</xsl:stylesheet>
