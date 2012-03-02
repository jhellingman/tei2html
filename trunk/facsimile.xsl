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
        <xd:detail>This stylesheet can be used to generate a digital facsimile edition of a TEI document,
        provided that page-images are available, and encoded in the <code>@facs</code> attribute of
        <code>pb</code>-elements. [STILL UNDER DEVELOPMENT; MUCH TODO]</xd:detail>
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

</xsl:template>

<xsl:template match="surface">

</xsl:template>

<xsl:template match="graphic">

</xsl:template>


<xsl:variable name="base-path">
    <xsl:value-of select="base-uri()"/>
</xsl:variable>


<xsl:variable name="facsimile-path">page-images</xsl:variable>


<xsl:function name="f:facsimile-filename" as="xs:string">
    <xsl:param name="pb" as="node()"/>

    <xsl:variable name="filename">
        <xsl:text>page-</xsl:text>
            <xsl:call-template name="generate-id-for">
                <xsl:with-param name="node" select="$pb"/>
            </xsl:call-template>
        <xsl:text>.html</xsl:text>
    </xsl:variable>

    <xsl:sequence select="$filename"/>
</xsl:function>


<xsl:template match="pb" mode="facsimile">
    <xsl:call-template name="facsimile-wrapper"/>
</xsl:template>


<!-- To be called in context of pb element -->

<xsl:template name="facsimile-wrapper">
    <xsl:if test="@facs">
        <xsl:variable name="facsimile-file" select="concat($facsimile-path, concat('/', f:facsimile-filename(.)))"/>

        <!-- Generate a wrapper file for the page image -->
        <xsl:result-document href="{$facsimile-file}">
            <xsl:message terminate="no">Info: generated file: <xsl:value-of select="$facsimile-file"/>.</xsl:message>
            <xsl:call-template name="facsimile-html"/>
        </xsl:result-document>
    </xsl:if>
</xsl:template>


<xsl:template name="facsimile-html">
    <html>
        <xsl:call-template name="facsimile-html-head"/>
        <body>
            <xsl:call-template name="facsimile-head"/>
            <xsl:call-template name="facsimile-navigation"/>
            <xsl:call-template name="facsimile-image"/>
        </body>
    </html>
</xsl:template>


<xsl:template name="facsimile-html-head">
    <head>
        <title>
            <!-- TODO: neat method to render title for this and similar cases -->
            <xsl:value-of select="$title"/>
            <xsl:text> by </xsl:text>
            <xsl:value-of select="$author"/>
            <xsl:if test="@n">
                <xsl:text>, Page </xsl:text>
                <xsl:value-of select="@n"/>
            </xsl:if>
        </title>
        <!-- TODO: generate CSS file (only once!) and include it -->
    </head>
</xsl:template>


<xsl:template name="facsimile-head">
    <div class="facsimile-head">
        <h2>
            <xsl:value-of select="$title"/>
            <xsl:text> by </xsl:text>
            <xsl:value-of select="$author"/>
            <xsl:if test="@n">
                <xsl:text>, Page </xsl:text>
                <xsl:value-of select="@n"/>
            </xsl:if>
        </h2>
    </div>
</xsl:template>


<xsl:template name="facsimile-navigation">
    <div class="facsimile-navigation">
        <xsl:call-template name="breadcrumb-navigation"/>

        <!-- Note: some pb elements do not have a @facs attribute, typically those in footnotes; we can ignore those. -->
        <div class="pager-navigation">
            <xsl:if test="preceding::pb[@facs]">
                <a href="{f:facsimile-filename(preceding::pb[@facs][1])}">Previous</a>
                <xsl:text> | </xsl:text>
            </xsl:if>

            <xsl:text>Page </xsl:text>
            <xsl:if test="@n">
                <xsl:value-of select="@n"/>
            </xsl:if>

            <xsl:if test="following::pb[@facs]">
                <xsl:text> | </xsl:text>
                <a href="{f:facsimile-filename(following::pb[@facs][1])}">Next</a>
            </xsl:if>
        </div>
    </div>
</xsl:template>


<xsl:template name="breadcrumb-navigation">

    <!-- Where are we in the document structure at the top of this page?
         Collect this information in a sequence of anchors: <a href="">Text</a>
    -->

    <!-- TODO: puzzle out what works best with our conventions for PB element placement (probably going to next pb) -->

    <!-- TODO: generate link back to generated HTML file (need to find out from name of TEI source somehow) -->

    <xsl:variable name="breadcrumbs">
        <xsl:apply-templates select="ancestor::front | ancestor::body | ancestor::back | ancestor::div0 | ancestor::div1 | ancestor::div2 | ancestor::div3" mode="breadcrumbs"/>
    </xsl:variable>

    <!-- TODO: unpack base-path to guess output file-name (convention) -->
    <div><xsl:value-of select="$base-path"/></div>

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
        <xsl:call-template name="generate-href-attribute"/>
        <xsl:choose>
            <xsl:when test="name() = 'front'">Front Matter</xsl:when>
            <xsl:when test="name() = 'back'">Back Matter</xsl:when>
            <xsl:otherwise>Body Matter</xsl:otherwise>
        </xsl:choose>
    </a>
</xsl:template>


<xsl:template match="div0 | div1 | div2 | div3" mode="breadcrumbs">
    <a>
        <xsl:call-template name="generate-href-attribute"/>
        <!-- TODO: neatly render head for this purpose -->
        <xsl:value-of select="head"/>
    </a>
</xsl:template>


<xsl:template name="facsimile-image">
    <div class="facsimile-image">
        <xsl:choose>
            <!-- Reference to graphic in facsimile-element elsewhere -->
            <xsl:when test="starts-with(@facs, '#')">
                <!-- TODO: warning message if graphic not present -->
                <xsl:if test="//graphic[@id = substring(@facs, 2)]">
                    <img src="{//graphic[@id = substring(@facs, 2)][1]//@url}" alt="Page image {@n}"/>
                </xsl:if>
            </xsl:when>
            <!-- Direct reference to image file -->
            <xsl:otherwise>
                <img src="{@facs}" alt="Page image {@n}"/>
            </xsl:otherwise>
        </xsl:choose>
    </div>
</xsl:template>


</xsl:stylesheet>
