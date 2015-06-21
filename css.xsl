<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to generate css, to be imported in tei2html.xsl.
    Note that the templates for css mode are often integrated
    with the content templates, to keep these together with
    the layout code.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="f xd xs"
    version="2.0"
    >

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to generate a CSS stylesheet to accompany HTML or ePub output.</xd:short>
        <xd:detail>This stylesheet formats generates a CSS stylesheet from TEI. According to the requirements
        of ePub, <code>@style</code> attributes are not allowed in the generated XHTML, so all CSS
        rules are collected from the TEI file, and put together in a separate CSS file. Further templates in
        the <code>css</code> mode are integrated in the other stylesheets, to keep them together with
        related HTML generating templates.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xsl:key name="rend" match="*" use="concat(name(), ':', @rend)"/>


    <xd:doc>
        <xd:short>Embed CSS stylesheets.</xd:short>
        <xd:detail>
            <p>Embed the standard and generated CSS stylesheets in the HTML output.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="embed-css-stylesheets">

        <xsl:if test="f:isSet('useCommonStylesheets')">
            <style type="text/css">
                <xsl:call-template name="common-css-stylesheets"/>

                <!-- Standard Aural CSS stylesheet -->
                <xsl:value-of select="f:css-stylesheet('style/aural.css')"/>
            </style>
        </xsl:if>

        <!-- Pull in CSS sheet for print (when using Prince). -->
        <xsl:if test="f:isSet('useCommonPrintStylesheets') and $optionPrinceMarkup = 'Yes'">
            <style type="text/css" media="print">
                <xsl:value-of select="f:css-stylesheet('style/print.css')"/>
            </style>
        </xsl:if>

        <style type="text/css">
            <xsl:call-template name="custom-css-stylesheets"/>
        </style>
    </xsl:template>


    <xd:doc>
        <xd:short>Collect all CSS used into a single (external) .css file.</xd:short>
        <xd:detail>
            <p>Collect the standard and generated CSS stylesheets in a single external .css file.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="external-css-stylesheets">
        <xsl:result-document
                href="{$path}/{$basename}.css"
                method="text"
                encoding="UTF-8">
            <xsl:message terminate="no">INFO:    Generated file: <xsl:value-of select="$path"/>/<xsl:value-of select="$basename"/>.css.</xsl:message>
            <xsl:call-template name="common-css-stylesheets"/>
            <xsl:call-template name="custom-css-stylesheets"/>
        </xsl:result-document>
    </xsl:template>


    <xd:doc>
        <xd:short>Collect the common CSS stylesheets.</xd:short>
        <xd:detail>
            <p>Copy the standard CSS stylesheets.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="common-css-stylesheets">
        <xsl:variable name="stylesheetname">
            <xsl:choose>
                <xsl:when test="f:has-rend-value(/TEI.2/text/@rend, 'stylesheet')">
                    <xsl:value-of select="f:rend-value(/TEI.2/text/@rend, 'stylesheet')"/>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="f:getSetting('defaultStylesheet')"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Standard CSS stylesheet. -->
        <xsl:value-of select="f:css-stylesheet('style/layout.css')"/>

        <!-- Stylesheets for various types of elements, only included when needed. -->
        <xsl:if test="//titlePage">
            <xsl:value-of select="f:css-stylesheet('style/titlepage.css')"/>
        </xsl:if>

        <xsl:if test="//figure">
            <xsl:value-of select="f:css-stylesheet('style/figure.css')"/>
        </xsl:if>

        <xsl:if test="//table">
            <xsl:value-of select="f:css-stylesheet('style/table.css')"/>
        </xsl:if>

        <xsl:if test="//lg or //sp or //castList">
            <xsl:value-of select="f:css-stylesheet('style/verse.css')"/>
        </xsl:if>

        <!-- Test covers align-with(...) and align-with-document(...) -->
        <xsl:if test="//div[contains(@rend, 'align-with')] or //lg[contains(@rend, 'align-with')]">
            <xsl:value-of select="f:css-stylesheet('style/aligned-text.css')"/>
        </xsl:if>

        <xsl:if test="//ditto or //table[contains(@rend, 'intralinear')]">
            <xsl:value-of select="f:css-stylesheet('style/special.css')"/>
        </xsl:if>

        <!-- Format-specific stylesheets. -->
        <xsl:if test="$outputformat = 'epub'">
            <xsl:value-of select="f:css-stylesheet('style/layout-epub.css')"/>
        </xsl:if>

        <xsl:if test="$outputformat = 'html'">
            <xsl:value-of select="f:css-stylesheet('style/layout-html.css')"/>
        </xsl:if>

        <!-- Supplement CSS stylesheet. -->
        <xsl:value-of select="f:css-stylesheet($stylesheetname)"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Collect the custom and generated CSS stylesheets.</xd:short>
        <xd:detail>
            <p>Copy the custom and generated CSS stylesheets.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="custom-css-stylesheets">
        <xsl:if test="$customCssFile">
            <!-- Custom CSS stylesheet, overrides build in stylesheets, so should come later -->
            <xsl:value-of select="f:css-stylesheet($customCssFile, .)"/>
        </xsl:if>

        <xsl:if test="//pgStyleSheet">
            <!-- Custom CSS embedded in PGTEI extension pgStyleSheet, copied verbatim -->
            <xsl:value-of select="string(//pgStyleSheet)"/>
        </xsl:if>

        <!-- Generate CSS for rend attributes, overrides all other CSS, so should be last -->
        <xsl:text>
        /* CSS rules generated from @rend attributes in TEI file */
        </xsl:text>
        <xsl:apply-templates select="/" mode="css"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Translate the <code>@rend</code> attributes to CSS.</xd:short>
        <xd:detail>Translate the <code>@rend</code> attributes, specified in a rendition-ladder syntax, to CSS.</xd:detail>
        <xd:param name="rend">The <code>@rend</code> attribute to be translated.</xd:param>
        <xd:param name="name">The name of the element carrying this attribute.</xd:param>
    </xd:doc>

    <xsl:template name="translate-rend-attribute">
        <xsl:param name="rend" select="normalize-space(@rend)"/>
        <xsl:param name="name" select="name()"/>

        <!-- A rendition ladder is straighfowardly converted to CSS, by taking the
             characters before the "(" as the css property, and the characters
             between "(" and ")" as the value. We convert an entire string
             by first handling the head, and then recursively the tail -->

        <xsl:if test="$rend != ''">
            <xsl:call-template name="filter-css-property">
                <xsl:with-param name="property" select="substring-before($rend, '(')"/>
                <xsl:with-param name="value" select="substring-before(substring-after($rend, '('), ')')"/>
            </xsl:call-template>

            <xsl:call-template name="translate-rend-attribute">
                <xsl:with-param name="rend" select="normalize-space(substring-after($rend, ')'))"/>
                <xsl:with-param name="name" select="$name"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Filter CSS properties with special meanings.</xd:short>
        <xd:detail>Filter those CSS properties with a special meaning, so they will not
        be output to CSS.</xd:detail>
        <xd:param name="property">The name of the property to be filtered.</xd:param>
        <xd:param name="value">The value of this property.</xd:param>
    </xd:doc>

    <xsl:template name="filter-css-property">
        <xsl:param name="property"/>
        <xsl:param name="value"/>

        <xsl:choose>
            <!-- Drop properties without values -->
            <xsl:when test="normalize-space($value)=''"/>

            <!-- Properties handled otherwise -->
            <xsl:when test="$property='class'"/>                <!-- pass-through CSS class -->
            <xsl:when test="$property='cover-image'"/>          <!-- cover-image for ePub versions -->
            <xsl:when test="$property='media-overlay'"/>        <!-- media overlay for ePub versions -->
            <xsl:when test="$property='link'"/>                 <!-- external link (for example on image) -->
            <xsl:when test="$property='image'"/>                <!-- in-line image -->
            <xsl:when test="$property='image-alt'"/>            <!-- alt text for image -->
            <xsl:when test="$property='summary'"/>              <!-- summary text for table, etc. -->
            <xsl:when test="$property='title'"/>                <!-- title text for links, etc. -->
            <xsl:when test="$property='label'"/>                <!-- label (for head, etc.) -->
            <xsl:when test="$property='columns'"/>              <!-- number of columns to use on list, table, etc. -->
            <xsl:when test="$property='item-order'"/>           <!-- way to split a list into multiple columns: row-first or column-first (default) -->
            <xsl:when test="$property='stylesheet'"/>           <!-- stylesheet to load (only on top-level text element) -->
            <xsl:when test="$property='position'"/>             <!-- position in text -->
            <xsl:when test="$property='toc-head'"/>             <!-- head to be used in table of contents -->
            <xsl:when test="$property='toc'"/>                  <!-- indicates how to include a head in the toc -->
            <xsl:when test="$property='align-with'"/>           <!-- indicates to align one division with another in a table -->
            <xsl:when test="$property='align-with-document'"/>  <!-- indicates to align one division with another in a table -->
            <xsl:when test="$property='tocMaxLevel'"/>          <!-- the maximum level (depth) of a generated table of contents -->
            <xsl:when test="$property='display' and $value='image-only'"/>  <!-- show image in stead of head -->

            <!-- Properties used to render verse -->
            <xsl:when test="$property='hemistich'"/>            <!-- render text given in value invisible (i.e. white) to indent with width of previous line -->

            <!-- Properties related to decorative initials -->
            <xsl:when test="$property='initial-image'"/>
            <xsl:when test="$property='initial-offset'"/>
            <xsl:when test="$property='initial-width'"/>
            <xsl:when test="$property='initial-height'"/>
            <xsl:when test="$property='dropcap'"/>
            <xsl:when test="$property='dropcap-offset'"/>

            <!-- Figure related special handling. -->
            <xsl:when test="name() = 'figure' and $property = 'float'"/>

            <!-- Table related special handling. With the rule
                 margin: 0px auto, the table is centered, while
                 display: table shrinks the bounding box to the content -->
            <xsl:when test="name() = 'table' and $property = 'align' and $value = 'center'">margin:0px auto; display:table;</xsl:when>
            <xsl:when test="name() = 'table' and $property = 'indent'">margin-left:<xsl:value-of select="$value"/>em;</xsl:when>

            <!-- Properties related to special font usage -->
            <xsl:when test="$property='font' and $value='fraktur'">font-family:'Walbaum-Fraktur';</xsl:when>
            <xsl:when test="$property='font' and $value='italic'">font-style:italic;</xsl:when>

            <xsl:when test="$property='align'">text-align:<xsl:value-of select="$value"/>;</xsl:when>
            <xsl:when test="$property='valign'">vertical-align:<xsl:value-of select="$value"/>;</xsl:when>
            <xsl:when test="$property='indent'">text-indent:<xsl:value-of select="$value"/>em;</xsl:when>

            <!-- Assume the rest is valid CSS -->
            <xsl:otherwise>
                <xsl:value-of select="$property"/>:<xsl:value-of select="$value"/>;
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate a CSS class name.</xd:short>
        <xd:detail>Generate a CSS class name. This class name is derived from the
        generated id of the first element having this <code>@rend</code> attribute value.</xd:detail>
        <xd:param name="rend">The <code>@rend</code> attribute for which a class name is generated.</xd:param>
        <xd:param name="node">The node carrying this attribute.</xd:param>
    </xd:doc>

    <xsl:template name="generate-rend-class-name">
        <xsl:param name="rend" select="@rend"/>
        <xsl:param name="node" select="."/>

        <xsl:text>x</xsl:text><xsl:value-of select="generate-id(key('rend', concat(name($node), ':', $rend))[1])"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate a CSS class attribute.</xd:short>
        <xd:detail>The same as above, but now wrapped up in an attribute</xd:detail>
        <xd:param name="rend">The <code>@rend</code> attribute for which a class name is generated.</xd:param>
        <xd:param name="node">The node carrying this attribute.</xd:param>
    </xd:doc>

    <xsl:template name="generate-rend-class-attribute">
        <xsl:param name="rend" select="@rend"/>
        <xsl:param name="node" select="."/>

        <xsl:attribute name="class">
            <xsl:call-template name="generate-rend-class-name">
                <xsl:with-param name="rend" select="$rend"/>
                <xsl:with-param name="node" select="$node"/>
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>


    <xd:doc>
        <xd:short>Optionally generate a CSS class name.</xd:short>
        <xd:detail>As before, but we only need to insert a class name in the output, if
         there is a matching CSS rule, or an explicit class
         declaration in the <code>@rend</code> attribute.</xd:detail>
        <xd:param name="rend">The <code>@rend</code> attribute for which a class name is generated.</xd:param>
        <xd:param name="node">The node carrying this attribute.</xd:param>
    </xd:doc>

    <xsl:template name="generate-rend-class-name-if-needed">
        <xsl:param name="rend" select="@rend"/>
        <xsl:param name="node" select="."/>

        <xsl:if test="f:has-rend-value($rend, 'class')">
            <xsl:value-of select="f:rend-value($rend, 'class')"/>
            <xsl:text> </xsl:text>
        </xsl:if>

        <xsl:variable name="css-properties">
            <xsl:call-template name="translate-rend-attribute">
                <xsl:with-param name="rend" select="normalize-space($rend)"/>
                <xsl:with-param name="name" select="name($node)"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:if test="normalize-space($css-properties) != ''">
            <xsl:call-template name="generate-rend-class-name">
                <xsl:with-param name="rend" select="$rend"/>
                <xsl:with-param name="node" select="$node"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Optionally generate a CSS class attribute.</xd:short>
        <xd:detail>The same as above, but now wrapped up in an attribute</xd:detail>
        <xd:param name="rend">The <code>@rend</code> attribute for which a class name is generated.</xd:param>
        <xd:param name="node">The node carrying this attribute.</xd:param>
    </xd:doc>

    <xsl:template name="generate-rend-class-attribute-if-needed">
        <xsl:param name="rend" select="@rend"/>
        <xsl:param name="node" select="."/>

        <xsl:variable name="class">
            <xsl:call-template name="generate-rend-class-name-if-needed">
                <xsl:with-param name="rend" select="$rend"/>
                <xsl:with-param name="node" select="$node"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:if test="normalize-space($class) != ''">
            <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Top level rule to generate CSS from <code>@rend</code> attributes.</xd:short>
        <xd:detail>The top level rule starts generating CSS rules for column-level rendering first,
        as those might be overridden by following row-level and cell-level rendering in tables.</xd:detail>
    </xd:doc>

    <xsl:template match="/" mode="css">

        <!-- We need to collect the column-related rendering rules first,
             so they can be overridden by later cell rendering rules -->
        <xsl:apply-templates select="TEI.2/text//column[@rend]" mode="css-column"/>

        <!-- Then follow the row-related rendering rules -->
        <xsl:apply-templates select="TEI.2/text//row[@rend]" mode="css-row"/>

        <!-- Handle the rest of the document (including table cells) -->
        <xsl:apply-templates select="/TEI.2/facsimile" mode="css"/>
        <xsl:apply-templates select="/TEI.2/teiHeader" mode="css"/>
        <xsl:apply-templates select="/TEI.2/text" mode="css"/>

        <xsl:apply-templates select="/TEI.2/text" mode="css-handheld"/>
    </xsl:template>


    <!-- Special modes for column and row CSS -->
    <xsl:template match="column[@rend]" mode="css-column">
        <xsl:call-template name="generate-css-rule"/>
    </xsl:template>

    <xsl:template match="row[@rend]" mode="css-row">
        <xsl:call-template name="generate-css-rule"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Exclude the column and row elements from default CSS processing.</xd:short>
        <xd:detail>The column and row elements are excluded, as we need to process them in an
        earlier stage, such that the corresponding CSS rules end up in the correct order.</xd:detail>
    </xd:doc>

    <xsl:template match="column | row" mode="css">
        <xsl:apply-templates mode="css"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Low priority default rule for generating the css rules.</xd:short>
        <xd:detail>Low priority default rule for generating the css rules from the
         rend attribute in css mode. Note that we exclude the column element in another
         rule.</xd:detail>
    </xd:doc>

    <xsl:template match="*[@rend]" mode="css" priority="-1">
        <xsl:call-template name="generate-css-rule"/>
        <xsl:apply-templates mode="css"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate a CSS rule.</xd:short>
        <xd:detail>Generate a CSS rule from a <code>@rend</code> attribute. Using a key on <code>name():@rend</code>, we
        do so only for the first occurance of a <code>@rend</code> attribute on an element.</xd:detail>
    </xd:doc>

    <xsl:template name="generate-css-rule">
        <xsl:if test="generate-id() = generate-id(key('rend', concat(name(), ':', @rend))[1])">

            <xsl:variable name="css-properties">
                <xsl:call-template name="translate-rend-attribute">
                    <xsl:with-param name="rend" select="normalize-space(@rend)"/>
                    <xsl:with-param name="name" select="name()"/>
                </xsl:call-template>
            </xsl:variable>

            <xsl:if test="normalize-space($css-properties) != ''">
                <!-- Use the id of the first element with this rend attribute as a class selector -->
                <xsl:text>
.</xsl:text>
                <xsl:call-template name="generate-rend-class-name"/>
                <xsl:text>
{
</xsl:text>
                    <xsl:value-of select="normalize-space($css-properties)"/>
                    <xsl:if test="false()">/* node='<xsl:value-of select="name()"/>' rend='<xsl:value-of select="normalize-space(@rend)"/>' count='<xsl:value-of select="count(key('rend', concat(name(), ':', @rend)))"/>' */</xsl:if>
                <xsl:text>
}
</xsl:text>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <!-- Ignore content in css-mode -->
    <xsl:template match="text()" mode="css css-handheld"/>


    <!-- Generate CSS for handheld devices: specific usage tailored for Project Gutenberg ePub generation -->
    <xsl:template match="text[not(ancestor::q)]" mode="css-handheld">
        <xsl:text>@media handheld
{
</xsl:text>
        <xsl:apply-templates select="*" mode="css-handheld"/>
        <xsl:text>
}
</xsl:text>
    </xsl:template>


    <xd:doc>
        <xd:short>Load a CSS stylesheet.</xd:short>
        <xd:detail>
            <p>Get the content of a CSS stylesheet (for example, to embed in an HTML document).</p>
        </xd:detail>
        <xd:param name="uri">The (relative) URI of the CSS stylesheet.</xd:param>
        <xd:param name="node">The node of a document relative to which the URI will be resolved.</xd:param>
    </xd:doc>

    <xsl:function name="f:css-stylesheet" as="xs:string">
        <xsl:param name="uri" as="xs:string"/>
        <xsl:param name="node" as="node()"/>

        <xsl:variable name="uri" select="normalize-space($uri)"/>
        <xsl:variable name="uri" select="resolve-uri($uri, base-uri($node))"/>
        <xsl:value-of select="f:css-stylesheet($uri)"/>
    </xsl:function>


     <xd:doc>
        <xd:short>Load a CSS stylesheet from resolved URI.</xd:short>
        <xd:detail>
            <p>Get the content of a CSS stylesheet (for example, to embed in an HTML document). This will first check
            for the presence of the indicated file, and then open it. Handles both plain CSS files as well as CSS files
            wrapped in a top-level XML element.</p>
        </xd:detail>
        <xd:param name="uri">The (relative) URI of the CSS stylesheet.</xd:param>
    </xd:doc>

    <xsl:function name="f:css-stylesheet" as="xs:string">
        <xsl:param name="uri" as="xs:string"/>
        <xsl:variable name="uri" select="normalize-space($uri)"/>

        <xsl:message terminate="no">INFO:    Including CSS stylesheet: <xsl:value-of select="$uri"/></xsl:message>

        <xsl:variable name="css">
            <xsl:choose>
                <xsl:when test="ends-with($uri, '.css') and unparsed-text-available($uri)">
                    <xsl:value-of select="replace(unparsed-text($uri), '&#xD;?&#xA;', '&#xA;')"/>
                </xsl:when>
                <xsl:when test="ends-with($uri, '.xml') and unparsed-text-available($uri)">
                    <xsl:value-of select="document($uri)/*/node()"/>
                </xsl:when>
                <xsl:when test="unparsed-text-available(concat($uri, '.xml'))">
                    <xsl:value-of select="document(concat($uri, '.xml'))/*/node()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="no">ERROR:   Unable to find CSS stylesheet: <xsl:value-of select="$uri"/></xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Strip comments from the CSS -->
        <xsl:variable name="css" select='replace($css, "/\*(.|[\r\n])*?\*/", " ")'/>

        <!-- Strip excessive space from the CSS -->
        <xsl:variable name="css" select='replace($css, "[ &#x9;]+", " ")'/>

        <xsl:value-of select="$css"/>
    </xsl:function>

</xsl:stylesheet>
