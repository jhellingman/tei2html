<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    version="2.0"
    exclude-result-prefixes="f xs"
    >


    <xd:doc type="stylesheet">
        <xd:short>TEI stylesheet to create digital facsimile versions of TEI documents.</xd:short>
        <xd:detail><p>This stylesheet can be used to generate a digital facsimile edition of a TEI document,
        provided that page-images are available, and encoded in the <code>@facs</code> attribute of
        <code>pb</code>-elements.</p>
        
        <p>The stylesheet generates page-image wrapper pages and will take into account the
        case that pb-elements can be placed at the very end of a division (so that the next
        page will begin a new division), even though, strictly speaking, the page-break
        is still part of the previous division.</p></xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2012, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <!--
        <facsimile>
            <graphic id="f001" url="p001.gif"/>
            <graphic id="f002" url="p002.gif"/>
        </facsimile>
    -->


<xsl:template match="facsimile">
    <xsl:apply-templates/>
</xsl:template>


<xsl:template match="surface">
    <xsl:message terminate="no">WARNING: tei2html does not support the surface element.</xsl:message>
    <xsl:apply-templates/>
</xsl:template>


<xd:doc>
    <xd:short>Handle a graphic element in the facsimile.</xd:short>
    <xd:detail>Handle a graphic element, by generating a wrapper file for the referenced graphic.</xd:detail>
</xd:doc>

<xsl:template match="facsimile/graphic">
    <xsl:if test="not(preceding::graphic)">
        <xsl:call-template name="facsimile-css"/>
    </xsl:if>
    <xsl:call-template name="facsimile-wrapper"/>
</xsl:template>


<xd:doc>
    <xd:short>Output related CSS</xd:short>
    <xd:detail>Output related CSS for main, but only if needed by the source.</xd:detail>
</xd:doc>

<xsl:template match="facsimile/graphic" mode="css">
    <xsl:if test="not(preceding::graphic)">
        <xsl:call-template name="main-facsimile-css"/>
    </xsl:if>
</xsl:template>


<xsl:template match="pb" mode="css">
    <xsl:if test="@facs and not(starts-with(@facs, '#'))">
        <xsl:if test="not(preceding::pb[@facs])">
            <xsl:call-template name="main-facsimile-css"/>
        </xsl:if>
    </xsl:if>
</xsl:template>


<xsl:template name="main-facsimile-css">
.facslink
{
    background-image: url(images/page-image.png);
    padding-right: 10px;
}
</xsl:template>


<xd:doc>
    <xd:short>Generate a file-name for the HTML wrapper page.</xd:short>
    <xd:detail>The name is derived from the generated id, which in turn uses the element id, if present.</xd:detail>
</xd:doc>

<xsl:function name="f:facsimile-filename" as="xs:string">
    <xsl:param name="node" as="node()"/>

    <xsl:variable name="filename">
        <xsl:text>page-</xsl:text>
            <xsl:call-template name="generate-id-for">
                <xsl:with-param name="node" select="$node"/>
            </xsl:call-template>
        <xsl:text>.html</xsl:text>
    </xsl:variable>

    <xsl:sequence select="$filename"/>
</xsl:function>


<xd:doc>
    <xd:short>Get the path where facsimile images are stored from the configuration.</xd:short>
    <xd:detail>In this same location, page-image wrapper files will be generated for a digital facsimile.</xd:detail>
</xd:doc>

<xsl:function name="f:facsimile-path" as="xs:string">
    <xsl:sequence select="f:getConfiguration('facsimilePath')"/>
</xsl:function>


<xd:doc>
    <xd:short>Handle a pb-element with a @facs-attribute.</xd:short>
    <xd:detail>Handle a pb-element with a @facs-attribute, but only if this refers directly to
    a page-image (otherwise, it will be handled by the graphic element referred to).</xd:detail>
</xd:doc>

<xsl:template match="pb" mode="facsimile">
    <xsl:if test="@facs and not(starts-with(@facs, '#'))">
        <xsl:if test="not(preceding::pb[@facs])">
            <xsl:call-template name="facsimile-css"/>
        </xsl:if>

        <xsl:call-template name="facsimile-wrapper"/>
    </xsl:if>
</xsl:template>


<xd:doc>
    <xd:short>Create a CSS file for wrapper pages.</xd:short>
    <xd:detail>Create a CSS file for wrapper pages. The calling template needs to make sure this is generated
    only once per document.</xd:detail>
</xd:doc>

<xsl:template name="facsimile-css">
    <xsl:variable name="facsimile-css-file" select="concat(f:facsimile-path(), '/facsimile.css')"/>

    <xsl:result-document href="{$facsimile-css-file}" method="text" encoding="UTF-8">
        <xsl:message terminate="no">INFO:    generated file: <xsl:value-of select="$facsimile-css-file"/>.</xsl:message>
            
            body
            {
                text-align: center;
            }

    </xsl:result-document>
</xsl:template>


<xd:doc>
    <xd:short>Create the HTML file for a wrapper page.</xd:short>
    <xd:detail>Create the HTML file for a wrapper page.</xd:detail>
</xd:doc>

<xsl:template name="facsimile-wrapper">
    <xsl:variable name="facsimile-file" select="concat(f:facsimile-path(), concat('/', f:facsimile-filename(.)))"/>

    <xsl:result-document href="{$facsimile-file}">
        <xsl:message terminate="no">INFO:    generated file: <xsl:value-of select="$facsimile-file"/>.</xsl:message>
        <xsl:call-template name="facsimile-html"/>
    </xsl:result-document>
</xsl:template>


<xd:doc>
    <xd:short>Create the wrapper HTML content for a page.</xd:short>
    <xd:detail>Create the wrapper HTML content for a page, calling a template for each of the main parts of
    that page.</xd:detail>
</xd:doc>

<xsl:template name="facsimile-html">
    <html>
        <xsl:call-template name="facsimile-html-head"/>
        <body>
            <xsl:call-template name="facsimile-head"/>
            <xsl:choose>
                <xsl:when test="name() = 'graphic'">
                    <xsl:call-template name="facsimile-navigation-graphic"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="facsimile-navigation"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="facsimile-image"/>
        </body>
    </html>
</xsl:template>


<xd:doc>
    <xd:short>Create HTML head-elements for a page.</xd:short>
    <xd:detail>Create HTML head-elements for a page.</xd:detail>
</xd:doc>

<xsl:template name="facsimile-html-head">
    <head>
        <title>
            <!-- TODO: neat method to render title for this and similar cases -->
            <xsl:value-of select="$author"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="$title"/>
            <xsl:if test="@n">
                <xsl:text>, </xsl:text>
                <xsl:value-of select="f:message('msgPage')"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="@n"/>
            </xsl:if>
        </title>
        <link rel="stylesheet" type="text/css" href="facsimile.css" />
    </head>
</xsl:template>


<xd:doc>
    <xd:short>Create the title for a page.</xd:short>
    <xd:detail>Create the title for a page.</xd:detail>
</xd:doc>

<xsl:template name="facsimile-head">
    <div class="facsimile-head">
        <h2>
            <xsl:value-of select="$author"/>
            <xsl:text>, </xsl:text>
            <i><xsl:value-of select="$title"/></i>
            <xsl:if test="@n">
                <xsl:text>, </xsl:text>
                <xsl:value-of select="f:message('msgPage')"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="@n"/>
            </xsl:if>
        </h2>
    </div>
</xsl:template>


<xd:doc>
    <xd:short>Create navigation-elements for a page.</xd:short>
    <xd:detail>Create navigation elements for a page: one set is based on the sequence of pages, the other on
    the content-structure of the document.</xd:detail>
</xd:doc>

<xsl:template name="facsimile-navigation">
    <div class="facsimile-navigation">
        <xsl:call-template name="pager-navigation"/>
        <xsl:call-template name="breadcrumb-navigation"/>
    </div>
</xsl:template>


<xsl:template name="facsimile-navigation-graphic">
    <div class="facsimile-navigation">
        <xsl:call-template name="pager-navigation-graphic"/>
        <xsl:variable name="value" select="concat('#', @id)"/>
        <xsl:call-template name="breadcrumb-navigation">
            <xsl:with-param name="pb" select="//pb[@facs = $value][1]"/>
        </xsl:call-template>
        <!-- TODO: handle case where no matching pb is found -->
    </div>
</xsl:template>


<xsl:template name="pager-navigation">
    <!-- Note: some pb elements do not have a @facs attribute, typically those in footnotes; we can ignore those. -->
    <div class="pager-navigation">
        <xsl:if test="preceding::pb[@facs]">
            <a href="{f:facsimile-filename(preceding::pb[@facs][1])}"><xsl:value-of select="f:message('msgPrevious')"/></a>
            <xsl:text> | </xsl:text>
        </xsl:if>

        <xsl:value-of select="f:message('msgPage')"/>
        <xsl:text> </xsl:text>
        <xsl:if test="@n">
            <xsl:value-of select="@n"/>
        </xsl:if>

        <xsl:if test="following::pb[@facs]">
            <xsl:text> | </xsl:text>
            <a href="{f:facsimile-filename(following::pb[@facs][1])}"><xsl:value-of select="f:message('msgNext')"/></a>
        </xsl:if>
    </div>
</xsl:template>


<xsl:template name="pager-navigation-graphic">
    <div class="pager-navigation">
        <xsl:if test="preceding::graphic">
            <a href="{f:facsimile-filename(preceding::graphic[1])}"><xsl:value-of select="f:message('msgPrevious')"/></a>
            <xsl:text> | </xsl:text>
        </xsl:if>

        <xsl:value-of select="f:message('msgPage')"/>
        <xsl:text> </xsl:text>
        <xsl:if test="@n">
            <xsl:value-of select="@n"/>
        </xsl:if>

        <xsl:if test="following::graphic">
            <xsl:text> | </xsl:text>
            <a href="{f:facsimile-filename(following::graphic[1])}"><xsl:value-of select="f:message('msgNext')"/></a>
        </xsl:if>
    </div>
</xsl:template>


<xd:doc>
    <xd:short>Find out in which div-elements a given pd-element is at the end.</xd:short>
    <xd:detail>Find out in which div-elements a given pd-element is at the end, which means, there is no content following it.
    This is done in the following steps:
    
    <ol>
        <li>Select all relevant (div-element) ancestors.</li>
        <li>Select all content following the pb that is a descendent of the same ancestor.</li>
        <li>Determine the length of text of that content.</li>
        <li>Include the div-element in the result, if that length is zero.</li>
    </ol>
    </xd:detail>
</xd:doc>

<xsl:function name="f:is-pb-at-end-of-div">
    <xsl:param name="pb"/>

    <xsl:variable name="div-parent" select="($pb/ancestor::front | $pb/ancestor::body | $pb/ancestor::back | $pb/ancestor::div0 | $pb/ancestor::div1 | $pb/ancestor::div2 | $pb/ancestor::div3)"/>

    <xsl:for-each select="$div-parent">
        <!-- Need to store parent-id as we cannot access the context node in the second line below. -->
        <xsl:variable name="parent-id" select="generate-id(.)"/>
        <xsl:variable name="following-pb" select="$pb/following::node()[ancestor::*[generate-id() = $parent-id]]"/>
        <xsl:variable name="following-pb-length" select="string-length(normalize-space(string-join($following-pb, '')))"/>
        <xsl:if test="$following-pb-length = 0">
            <xsl:sequence select="."/>
        </xsl:if>
    </xsl:for-each>
</xsl:function>


<xd:doc>
    <xd:short>Create bread-crumb navigation for the page.</xd:short>
    <xd:detail>Create bread-crumb navigation for the current page. Some complexity arises as we need to take into
    account that sometimes the pb-element is placed at the very end of a division, and the page being displayed
    this shows the beginning of the next division.
    </xd:detail>
</xd:doc>

<xsl:template name="breadcrumb-navigation">
    <xsl:param name="pb" select="."/>

    <!-- Get the highest-level division of which the pb is at the end -->
    <xsl:variable name="ending-div" select="f:is-pb-at-end-of-div($pb)[1]"/>
    <xsl:if test="$ending-div">
        <xsl:message terminate="no">page-break <xsl:value-of select="$pb/@n"/> is at the end of a division, so will use next division.</xsl:message>
    </xsl:if>

    <xsl:choose>
        <xsl:when test="$ending-div">
            <xsl:call-template name="breadcrumb-navigation-for-node">
                <!-- Find first of following div0, div1, div2, div3 -->
                <xsl:with-param name="node" select="($ending-div/following::div0 | $ending-div/following::div1 | $ending-div/following::div2 | $ending-div/following::div3)[1]"/>
                <xsl:with-param name="pb" select="$pb"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="breadcrumb-navigation-for-node">
                <xsl:with-param name="node" select="$pb"/>
                <xsl:with-param name="pb" select="$pb"/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<xd:doc>
    <xd:short>Create bread-crumb navigation for a node.</xd:short>
    <xd:detail>Create bread-crumb navigation for the the given node (and related pb-element, which may or may not be the same
    element. The bread-crumbs will contain all ancestor div-elements, and the front, body, or back matter.</xd:detail>
</xd:doc>

<xsl:template name="breadcrumb-navigation-for-node">
    <xsl:param name="node" select="."/>
    <xsl:param name="pb" select="."/>

    <xsl:variable name="breadcrumbs">
        <!-- No problem $node and $pb are same node in default case: XSLT union will make sure it is used only once -->
        <xsl:apply-templates select="$node/ancestor::front | $node/ancestor::body | $node/ancestor::back | $node/ancestor::div0 | $node/ancestor::div1 | $node/ancestor::div2 | $node/ancestor::div3 | $node | $pb" mode="breadcrumbs">
            <!-- Sort by depth of node, to make sure the pb element is last in line -->
            <xsl:sort select="count(ancestor::*)"/>
        </xsl:apply-templates>
    </xsl:variable>

    <div class="breadcrumb-navigation">
        <xsl:for-each select="$breadcrumbs/*">
            <xsl:if test="position() > 1">
                <xsl:text> &gt; </xsl:text>
            </xsl:if>
            <xsl:copy-of select="."/>
        </xsl:for-each>
    </div>
</xsl:template>


<xsl:template match="front | body | back" mode="breadcrumbs">
    <a>
        <xsl:attribute name="href">
            <xsl:text>../</xsl:text><xsl:value-of select="$basename"/>.html<xsl:call-template name="generate-href"/>
        </xsl:attribute>

        <xsl:choose>
            <xsl:when test="name() = 'front'"><xsl:value-of select="f:message('msgFrontMatter')"/></xsl:when>
            <xsl:when test="name() = 'back'"><xsl:value-of select="f:message('msgBackMatter')"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="f:message('msgBodyMatter')"/></xsl:otherwise>
        </xsl:choose>
    </a>
</xsl:template>


<xsl:template match="div0 | div1 | div2 | div3" mode="breadcrumbs">
    <a>
        <xsl:attribute name="href">
            <xsl:text>../</xsl:text><xsl:value-of select="$basename"/>.html<xsl:call-template name="generate-href"/>
        </xsl:attribute>

        <!-- TODO: neatly render head for this purpose, and handle case it is missing -->
        <xsl:value-of select="head"/>
    </a>
</xsl:template>


<xsl:template match="pb" mode="breadcrumbs">
    <a>
        <xsl:attribute name="href">
            <xsl:text>../</xsl:text><xsl:value-of select="$basename"/>.html<xsl:call-template name="generate-href"/>
        </xsl:attribute>

        <xsl:value-of select="f:message('msgPage')"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@n"/>
    </a>
</xsl:template>


<xsl:template name="facsimile-image">
    <div class="facsimile-image">
        <xsl:choose>
            <!-- graphic-element that references an image file -->
            <xsl:when test="@url">
                <img src="{@url}" alt="{f:message('msgPageImage')} {@n}"/>
            </xsl:when>
            <!-- pb-element that references a graphic-element elsewhere -->
            <xsl:when test="starts-with(@facs, '#')">
                <!-- TODO: warning message if graphic not present -->
                <xsl:if test="//graphic[@id = substring(@facs, 2)]">
                    <img src="{//graphic[@id = substring(@facs, 2)][1]//@url}" alt="{f:message('msgPageImage')} {@n}"/>
                </xsl:if>
            </xsl:when>
            <!-- pb-element that directly references an image file -->
            <xsl:otherwise>
                <img src="{@facs}" alt="{f:message('msgPageImage')} {@n}"/>
            </xsl:otherwise>
        </xsl:choose>
    </div>
</xsl:template>


</xsl:stylesheet>
