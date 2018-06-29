<!DOCTYPE xsl:stylesheet [

    <!ENTITY nbsp       "&#160;">
    <!ENTITY ndash      "&#x2013;">

]>

<xsl:stylesheet version="2.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:tmp="urn:temporary-nodes"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f tmp xhtml xs xd">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to generate indexes.</xd:short>
        <xd:detail>
            <p>This stylesheet handles the <code>divGen</code> elements for indexes. Note that this code assumes the old <code>&lt;index&gt;</code> style
            tags of TEI P3; the more versatile construction of TEI P5 is not (yet) supported.</p>

            <p>The following are supported:</p>

            <table>
                <tr><td><code>&lt;divGen type="index"/&gt;</code></td>      <td>Generates an index.</td></tr>
                <tr><td><code>&lt;divGen type="IndexToc"/&gt;</code></td>   <td>Generates a one-line table of contents, specially designed for pre-existing indexes.</td></tr>
            </table>
        </xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2017, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Generate an index.</xd:short>
        <xd:detail>
            <p>Generate an index. This depends on <code>index</code> tags being used in the main text of the document.
            All these elements will be collected into a temporary structure, and then rendered to HTML.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="divGen[@type='Index' or @type='index']">
        <div class="div1">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <h2 class="main"><xsl:value-of select="f:message('msgIndex')"/></h2>

            <xsl:copy-of select="f:logInfo('Generating Index', ())"/>

            <!-- Collect all index entries into a temporary node structure and add page numbers to them. -->
            <xsl:variable name="index">
                <tmp:index>
                    <xsl:apply-templates select="//index" mode="collectEntries"/>
                </tmp:index>
            </xsl:variable>

            <xsl:apply-templates select="$index" mode="index"/>
        </div>
    </xsl:template>


    <xd:doc>
        <xd:short>Collect an index entry.</xd:short>
        <xd:detail>
            <p>Store an index entry in the temporary data-structure. Note that this template assumes the TEI P3 style entries.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="index[@level1]" mode="collectEntries">
        <tmp:entry href="{f:generate-href(.)}">
            <xsl:attribute name="level1"><xsl:value-of select="@level1"/></xsl:attribute>
            <xsl:attribute name="level2"><xsl:value-of select="@level2"/></xsl:attribute>
            <xsl:attribute name="level3"><xsl:value-of select="@level3"/></xsl:attribute>
            <xsl:attribute name="level4"><xsl:value-of select="@level4"/></xsl:attribute>
            <xsl:attribute name="index"><xsl:value-of select="@index"/></xsl:attribute>
            <xsl:attribute name="page">
                <xsl:choose>
                    <xsl:when test="preceding::pb[1]/@n and preceding::pb[1]/@n != ''">
                        <xsl:value-of select="preceding::pb[1]/@n"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>###</xsl:text>
                        <xsl:copy-of select="f:logWarning('No valid page number found preceding index entry ({1}).', (@level1))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </tmp:entry>
    </xsl:template>


    <xd:doc>
        <xd:short>Output a sorted index.</xd:short>
        <xd:detail>
            <p>Output a sorted index from elements stored in a temporary structure, taking care
            of two levels of index entries.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="tmp:index" mode="index">
        <xsl:for-each-group select="tmp:entry" group-by="lower-case(@level1)">
            <xsl:sort select="lower-case(@level1)"/>
            <p>
                <xsl:value-of select="@level1"/>
                <xsl:for-each-group select="current-group()" group-by="lower-case(@level2)">
                    <xsl:sort select="lower-case(@level2)"/>
                    <xsl:choose>
                        <xsl:when test="position() = 1"><xsl:text> </xsl:text></xsl:when>
                        <xsl:otherwise>; </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="@level2"/>
                    <xsl:call-template name="indexPageReferences"/>
                </xsl:for-each-group>
            </p>
        </xsl:for-each-group>
    </xsl:template>


    <xsl:template name="indexPageReferences">
        <!-- Group to suppress duplicate page numbers -->
        <xsl:variable name="pages">
            <tmp:pages>
                <xsl:for-each-group select="current-group()" group-by="@page">
                    <xsl:copy-of select="f:logDebug('Index page: {2} {1}.', (@href, @page))"/>
                    <tmp:page href="{@href}" page="{@page}"/>
                </xsl:for-each-group>
            </tmp:pages>
        </xsl:variable>

        <!-- Group to consolidate consecutive page numbers, i.e., 1, 2, 3, 4 becomes 1-4 -->
        <xsl:variable name="pages">
            <tmp:pages>
                <xsl:for-each-group select="$pages//tmp:page" group-adjacent="@page = preceding::tmp:page[1]/@page + 1 or @page = following::tmp:page[1]/@page - 1">
                    <xsl:choose>
                        <xsl:when test="current-grouping-key()">
                            <xsl:variable name="range">
                                <tmp:pages>
                                    <xsl:for-each select="current-group()">
                                        <tmp:page href="{@href}" page="{@page}"/>
                                    </xsl:for-each>
                                </tmp:pages>
                            </xsl:variable>
                            <xsl:copy-of select="f:logDebug('Page range: {1}-{2}.', ($range//tmp:page[1]/@page, $range//tmp:page[last()]/@page))"/>
                            <tmp:range
                                firstPage="{$range//tmp:page[1]/@page}"
                                firstHref="{$range//tmp:page[1]/@href}"
                                lastPage="{$range//tmp:page[last()]/@page}"
                                lastHref="{$range//tmp:page[last()]/@href}"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="current-group()">
                                <xsl:copy-of select="f:logDebug('Single page: {1}.', (@page))"/>
                                <tmp:page href="{@href}" page="{@page}"/>
                            </xsl:for-each>
                        </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each-group>
            </tmp:pages>
        </xsl:variable>

        <!-- Output the pages -->
        <xsl:for-each select="$pages//tmp:page | $pages//tmp:range ">
            <xsl:choose>
                <xsl:when test="position() = 1"><xsl:text> </xsl:text></xsl:when>
                <xsl:otherwise>, </xsl:otherwise>
            </xsl:choose>
            <xsl:copy-of select="f:logDebug('Output page: {1} : {2}.', (@page, @href))"/>
            <xsl:apply-templates select="." mode="index"/>
        </xsl:for-each>
    </xsl:template>


    <xsl:template match="tmp:page" mode="index">
        <a href="{@href}"><xsl:value-of select="@page"/></a>
    </xsl:template>


    <xsl:template match="tmp:range[@firstPage = @lastPage - 1]" mode="index">
        <a href="{@firstHref}"><xsl:value-of select="@firstPage"/></a>, <a href="{@lastHref}"><xsl:value-of select="@lastPage"/></a>
    </xsl:template>


    <xsl:template match="tmp:range" mode="index">
        <a href="{@firstHref}"><xsl:value-of select="@firstPage"/></a>&ndash;<a href="{@lastHref}"><xsl:value-of select="@lastPage"/></a>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle an index entry in the text.</xd:short>
        <xd:detail>
            <p>Handle an index entry in the text, by making sure it has an anchor.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="index">
        <a>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:apply-templates/>
        </a>
    </xsl:template>


    <!--====================================================================-->
    <!-- Special short table of contents for indexes -->

    <xd:doc>
        <xd:short>Generate a one-line table-of-contents for use with an index.</xd:short>
        <xd:detail>
            <p>Generate a one-line table-of-contents for use with an index. This shows all the letters separated by bars, to make faster navigation possible.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="divGen[@type='IndexToc']">
        <xsl:call-template name="genindextoc"/>
    </xsl:template>


    <xsl:template name="genindextoc">
        <div class="transcribernote indextoc" id="{f:generate-id(.)}">
            <xsl:apply-templates select="../div2/head | ../div3/head | ../div/head" mode="genindextoc"/>
        </div>
    </xsl:template>


    <xsl:template match="head" mode="genindextoc">
        <xsl:if test="position() != 1">
            <xsl:text> | </xsl:text>
        </xsl:if>
        <a href="{f:generate-href(.)}">
            <xsl:if test="contains(., '.')">
                <xsl:value-of select="substring-before(., '.')"/>
            </xsl:if>
            <xsl:if test="not(contains(., '.'))">
                <xsl:value-of select="."/>
            </xsl:if>
        </a>
    </xsl:template>


</xsl:stylesheet>

