<!DOCTYPE xsl:stylesheet [

    <!ENTITY lf         "&#x0A;">
    <!ENTITY cr         "&#x0D;">

]>
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


    <xd:doc>
        <xd:short>Key to quickly find <code>@rend</code> attributes on elements.</xd:short>
    </xd:doc>

    <xsl:key name="rend" match="*" use="concat(name(), ':', @rend)"/>


    <xd:doc>
        <xd:short>Key to quickly find <code>@style</code> attributes on elements.</xd:short>
    </xd:doc>

    <xsl:key name="style" match="*" use="@style"/>


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
            <xsl:copy-of select="f:logInfo('Generated CSS stylesheet: {1}/{2}.css', ($path, $basename))"/>
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
        <xsl:variable name="stylesheetname" as="xs:string">
            <xsl:choose>
                <xsl:when test="f:has-rend-value(/*[self::TEI.2 or self::TEI]/text/@rend, 'stylesheet')">
                    <xsl:value-of select="f:rend-value(/*[self::TEI.2 or self::TEI]/text/@rend, 'stylesheet')"/>
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

        <xsl:if test="//ab[@type='intra']">
            <xsl:value-of select="f:css-stylesheet('style/intralinear.css')"/>
        </xsl:if>

        <xsl:if test="//ditto or //seg[@copyOf]">
            <xsl:value-of select="f:css-stylesheet('style/special.css')"/>
        </xsl:if>

        <!-- Test covers align-with(...) and align-with-document(...) -->
        <xsl:if test="(//div|//div1|//div2|//div3|//div4|//div5|//div6)[contains(@rend, 'align-with')] or //lg[contains(@rend, 'align-with')]">
            <xsl:value-of select="f:css-stylesheet('style/aligned-text.css')"/>
        </xsl:if>

        <!-- Format-specific stylesheets. -->
        <xsl:if test="$outputformat = 'epub'">
            <xsl:value-of select="f:css-stylesheet('style/layout-epub.css')"/>
        </xsl:if>

        <xsl:if test="$outputformat = 'html'">
            <xsl:value-of select="f:css-stylesheet('style/layout-html.css')"/>
        </xsl:if>

        <!-- Debugging CSS stylesheet. -->
        <xsl:if test="f:isSet('debug')">
            <xsl:value-of select="f:css-stylesheet('style/debug.css')"/>
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
            <!-- <xsl:value-of select="'&lf;//&lt;![CDATA[&lf;'" disable-output-escaping="yes"/> -->
            <xsl:value-of select="f:css-stylesheet($customCssFile, .)" disable-output-escaping="yes"/>
            <!-- <xsl:value-of select="'&lf;//]]&gt;&lf;'" disable-output-escaping="yes"/> -->
        </xsl:if>

        <xsl:if test="//pgStyleSheet">
            <!-- Custom CSS embedded in PGTEI extension pgStyleSheet, copied verbatim -->
            <xsl:value-of select="string(//pgStyleSheet)"/>
        </xsl:if>

        <xsl:if test="//tagsDecl/rendition">
            <xsl:text>
/* CSS rules generated from rendition elements in TEI file */
</xsl:text>
            <xsl:apply-templates select="//tagsDecl/rendition" mode="rendition"/>
        </xsl:if>

        <!-- Generate CSS for rend attributes, overrides CSS from stylesheets, so should be last -->
        <xsl:text>
/* CSS rules generated from @rend attributes in TEI file */
</xsl:text>
        <xsl:apply-templates select="/" mode="css"/>
        
        <xsl:text>
/* CSS rules copied from @style attributes in TEI file */
</xsl:text>
        <xsl:apply-templates select="/" mode="style"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Convert a rendition element to a CSS rule.</xd:short>
        <xd:detail>
            <p>Convert a rendition element to a CSS rule. Rendition elements with a
            <code>@selector</code> attribute, the scope attribute will be ignored. Note that the
            <code>@selector</code> attribute may be expressed in terms of source (TEI) elements,
            and in that case may need to be translated in target (e.g. HTML) terms. For now,
            this is ignored.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="rendition[@selector]" mode="rendition">
        <xsl:value-of select="@selector"/>
        <xsl:text> {
</xsl:text>
            <xsl:value-of select="."/>
        <xsl:text>
}
</xsl:text>
    </xsl:template>


    <xd:doc>
        <xd:short>Convert a rendition element to a CSS rule.</xd:short>
        <xd:detail>
            <p>Convert a rendition element to a CSS rule. For rendition elements without
            a <code>@selector</code> attribute, the <code>@id</code> attribute will be converted 
            to a class selecter. If present, the <code>@scope</code> attribute will be translated
            to a CSS pseudo-element.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="rendition[@id]" mode="rendition">
        <xsl:text>
.</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:if test="@scope">
            <!-- Translate scope to CSS pseudo-element -->
            <xsl:text>::</xsl:text>
            <xsl:value-of select="@scope"/>
        </xsl:if>
        <xsl:text> {
</xsl:text>
            <xsl:value-of select="."/>
        <xsl:text>
}
</xsl:text>
    </xsl:template>


    <xd:doc>
        <xd:short>Warn for invalid rendition elements.</xd:short>
    </xd:doc>

    <xsl:template match="rendition" mode="rendition">
        <xsl:copy-of select="f:logWarning('Rendition element without id or selector: {1}', (rendition))"/>
    </xsl:template>

    <xd:doc>
        <xd:short>Translate the <code>@rend</code> attributes to CSS.</xd:short>
        <xd:detail><p>Translate the <code>@rend</code> attributes, specified in a rendition-ladder syntax, to CSS.</p>

        <p>rendition-ladder syntax consists of a series of keys followed by the value between parentheses, e.g.,
        <code>font-size(large) color(red)</code>.</p></xd:detail>
        <xd:param name="rend">The <code>@rend</code> attribute to be translated.</xd:param>
        <xd:param name="name">The name of the element carrying this attribute.</xd:param>
    </xd:doc>

    <xsl:function name="f:translate-rend-ladder" as="xs:string">
        <xsl:param name="rend" as="xs:string?"/>
        <xsl:param name="name" as="xs:string"/>

        <xsl:variable name="rend" select="if ($rend) then $rend else ''" as="xs:string"/>

        <xsl:variable name="css">
            <xsl:analyze-string select="$rend" regex="([a-z][a-z0-9-]*)\((.*?)\)" flags="i">
                <xsl:matching-substring>
                    <xsl:value-of select="f:translate-rend-ladder-step(regex-group(1), regex-group(2), $name)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>

        <xsl:value-of select="normalize-space($css)"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Translate a single rend-ladder step to a CSS property.</xd:short>
        <xd:detail>Translate a single rend-ladder step to a CSS property. Filter those steps
        with a special meaning, so they will not be output as invalid CSS.</xd:detail>
        <xd:param name="property">The name of the property to be filtered.</xd:param>
        <xd:param name="value">The value of this property.</xd:param>
        <xd:param name="name">The name of the element carrying the rend attribute.</xd:param>
    </xd:doc>

    <xsl:function name="f:translate-rend-ladder-step" as="xs:string">
        <xsl:param name="property" as="xs:string"/>
        <xsl:param name="value" as="xs:string"/>
        <xsl:param name="name" as="xs:string"/>

        <xsl:variable name="css">
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
                <xsl:when test="$property='display' and $value='image-only'"/>  <!-- show image instead of head -->
                <xsl:when test="$property='display' and $value='castGroupTable'"/>  <!-- special rendering of castGroup -->
                <xsl:when test="$property='decimal-separator'"/>    <!-- for aligning columns of numbers -->

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
                <xsl:when test="$name = 'figure' and $property = 'float'"/>

                <!-- Table related special handling. With the rule
                     margin: 0px auto, the table is centered, while
                     display: table shrinks the bounding box to the content -->
                <xsl:when test="$name = 'table' and $property = 'align' and $value = 'center'">margin:0px auto; display:table; </xsl:when>
                <xsl:when test="$name = 'table' and $property = 'indent'">margin-left:<xsl:value-of select="$value"/>em; </xsl:when>

                <!-- Properties related to special font usage -->
                <xsl:when test="$property='font' and $value='fraktur'">font-family:'<xsl:value-of select="f:getSetting('css.frakturFont')"/>'; </xsl:when>
                <xsl:when test="$property='font' and $value='italic'">font-style:italic; </xsl:when>

                <xsl:when test="$property='align'">text-align:<xsl:value-of select="$value"/>; </xsl:when>
                <xsl:when test="$property='valign'">vertical-align:<xsl:value-of select="$value"/>; </xsl:when>
                <xsl:when test="$property='indent'">text-indent:<xsl:value-of select="$value"/>em; </xsl:when>

                <!-- Assume the rest is valid CSS -->
                <xsl:otherwise>
                    <xsl:value-of select="$property"/>:<xsl:value-of select="$value"/><xsl:text>; </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="$css"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate a class name for a rendition ladder.</xd:short>
        <xd:detail>Generate a class name for a rendition ladder. This class name is derived from the (generated) id
        of the first element having the specific <code>@rend</code> attribute value of this node.</xd:detail>
        <xd:param name="node">The node for which a class name is to be generated.</xd:param>
    </xd:doc>

    <xsl:function name="f:generate-class-name" as="xs:string">
        <xsl:param name="node" as="element()"/>
        <xsl:value-of select="f:generate-id(key('rend', concat(name($node), ':', $node/@rend), root($node))[1])"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate a class name for a style.</xd:short>
        <xd:detail>Generate a class name for a style. This class name is derived from the (generated) id
        of the first element having the specific <code>@style</code> attribute.</xd:detail>
        <xd:param name="node">The node for which a class name is to be generated.</xd:param>
    </xd:doc>

    <xsl:function name="f:generate-style-name" as="xs:string">
        <xsl:param name="node" as="element()"/>
        <xsl:value-of select="f:generate-id(key('style', $node/@style, root($node))[1])"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate a CSS selector for a rendition ladder.</xd:short>
        <xd:detail>Generate a CSS selector name for a rendition ladder. This is the same value as calculated
        in <code>f:generate-class-name()</code>, but with periods escaped to accomodate CSS.</xd:detail>
        <xd:param name="node">The node for which a CSS selector is to be generated.</xd:param>
    </xd:doc>

    <xsl:function name="f:generate-css-class-selector" as="xs:string">
        <xsl:param name="node" as="element()"/>
        <xsl:value-of select="replace(f:generate-class-name($node), '\.', '\\.')"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate a CSS selector for a style.</xd:short>
        <xd:detail>Generate a CSS selector name for a style. This is the same value as calculated
        in <code>f:generate-style-name()</code>, but with periods escaped to accomodate CSS.</xd:detail>
        <xd:param name="node">The node for which a CSS selector is to be generated.</xd:param>
    </xd:doc>

    <xsl:function name="f:generate-style-class-selector" as="xs:string">
        <xsl:param name="node" as="element()"/>
        <xsl:value-of select="replace(f:generate-style-name($node), '\.', '\\.')"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate the class for an element.</xd:short>
        <xd:detail><p>Generate the class for an element. This is determined from the following:</p>
            <ul>
                <li>The class generated for the rendition ladder and any explicit classes provided in the <code>@rend</code> attribute.</li>
                <li>The class generated for the <code>@style</code> attribute.</li>
                <li>The classes explicitly provided in the <code>@rendition</code> attribute.</li>
            </ul>
        </xd:detail>
        <xd:param name="node">The node for which a class is to be generated.</xd:param>
    </xd:doc>

    <xsl:function name="f:generate-class" as="xs:string">
        <xsl:param name="node" as="element()"/>

        <xsl:variable name="rend" select="$node/@rend" as="xs:string?"/>

        <xsl:variable name="class">
            <xsl:if test="f:has-rend-value($rend, 'class')">
                <xsl:value-of select="f:rend-value($rend, 'class')"/>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:if test="normalize-space(f:translate-rend-ladder($rend, name($node))) != ''">
                <xsl:value-of select="f:generate-class-name($node)"/>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:if test="normalize-space($node/@style) != ''">
                <xsl:value-of select="f:generate-style-name($node)"/>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:if test="normalize-space($node/@rendition) != ''">
                <!-- TODO: verify presence of rendition element ids given -->
                <xsl:value-of select="replace($node/@rendition, '#', '')"/>
            </xsl:if>
        </xsl:variable>
        <xsl:value-of select="normalize-space($class)"/>
        <xsl:copy-of select="f:logDebug('Generate class {1} with rend attribute {2}.', (normalize-space($class), $rend))"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate an optional class attribute for an element.</xd:short>
        <xd:detail>Generate an optional class attribute for an element. This is the result
        of the call to <code>f:generate-class()</code>, wrapped in an attribute.</xd:detail>
        <xd:param name="node">The node for which a class attribute is to be generated.</xd:param>
    </xd:doc>

    <xsl:function name="f:set-class-attribute" as="attribute()?">
        <xsl:param name="node" as="element()"/>

        <xsl:variable name="class" select="f:generate-class($node)"/>
        <xsl:if test="$class != ''">
            <xsl:attribute name="class" select="$class"/>
        </xsl:if>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate an optional class attribute for an element.</xd:short>
        <xd:detail>Generate an optional class attribute for an element. This is the result
        of the call to <code>f:generate-class()</code>, with the second argument appended,
        wrapped in an attribute.</xd:detail>
        <xd:param name="node">The node for which a class attribute is to be generated.</xd:param>
        <xd:param name="class">Classes to add to the generated class.</xd:param>
    </xd:doc>

    <xsl:function name="f:set-class-attribute-with" as="attribute()?">
        <xsl:param name="node" as="element()"/>
        <xsl:param name="class" as="xs:string"/>

        <xsl:variable name="class" select="normalize-space(concat($class, ' ', f:generate-class($node)))"/>
        <xsl:if test="$class != ''">
            <xsl:attribute name="class" select="$class"/>
        </xsl:if>
    </xsl:function>


    <xd:doc>
        <xd:short>Top level rule to generate CSS from <code>@rend</code> attributes.</xd:short>
        <xd:detail>The top level rule starts generating CSS rules for column-level rendering first,
        as those might be overridden by following row-level and cell-level rendering in tables.</xd:detail>
    </xd:doc>

    <xsl:template match="/" mode="css">

        <!-- We need to collect the column-related rendering rules first,
             so they can be overridden by later cell rendering rules -->
        <xsl:apply-templates select="*[self::TEI.2 or self::TEI]/text//column[@rend]" mode="css-column"/>

        <!-- Then follow the row-related rendering rules -->
        <xsl:apply-templates select="*[self::TEI.2 or self::TEI]/text//row[@rend]" mode="css-row"/>

        <!-- Handle the rest of the document (including table cells) -->
        <xsl:apply-templates select="*[self::TEI.2 or self::TEI]/facsimile" mode="css"/>
        <xsl:apply-templates select="*[self::TEI.2 or self::TEI]/teiHeader" mode="css"/>
        <xsl:apply-templates select="*[self::TEI.2 or self::TEI]/text" mode="css"/>

        <xsl:apply-templates select="*[self::TEI.2 or self::TEI]/text" mode="css-handheld"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Top level rule to copy CSS from <code>@style</code> attributes.</xd:short>
        <xd:detail>The top level rule starts copying CSS rules for column-level styles first,
        as those might be overridden by following row-level and cell-level styles in tables.</xd:detail>
    </xd:doc>

    <xsl:template match="/" mode="style">

        <!-- We need to collect the column-related rendering rules first,
             so they can be overridden by later cell rendering rules -->
        <xsl:apply-templates select="*[self::TEI.2 or self::TEI]/text//column[@style]" mode="style-column"/>

        <!-- Then follow the row-related rendering rules -->
        <xsl:apply-templates select="*[self::TEI.2 or self::TEI]/text//row[@style]" mode="style-row"/>

        <!-- Handle the rest of the document (including table cells) -->
        <xsl:apply-templates select="*[self::TEI.2 or self::TEI]/facsimile" mode="style"/>
        <xsl:apply-templates select="*[self::TEI.2 or self::TEI]/teiHeader" mode="style"/>
        <xsl:apply-templates select="*[self::TEI.2 or self::TEI]/text" mode="style"/>
    </xsl:template>


    <!-- Special modes for column and row CSS -->
    <xsl:template match="column[@rend]" mode="css-column">
        <xsl:call-template name="generate-css-rule"/>
    </xsl:template>

    <xsl:template match="row[@rend]" mode="css-row">
        <xsl:call-template name="generate-css-rule"/>
    </xsl:template>

    <xsl:template match="column[@style]" mode="style-column">
        <xsl:call-template name="generate-style-rule"/>
    </xsl:template>

    <xsl:template match="row[@style]" mode="style-row">
        <xsl:call-template name="generate-style-rule"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Exclude the column and row elements from default CSS processing.</xd:short>
        <xd:detail>The column and row elements are excluded, as we need to process them in an
        earlier stage, such that the corresponding CSS rules end up in the correct order.</xd:detail>
    </xd:doc>

    <xsl:template match="column | row" mode="css">
        <xsl:apply-templates mode="css"/>
    </xsl:template>

    <xsl:template match="column | row" mode="style">
        <xsl:apply-templates mode="style"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Low priority default template for generating css rules.</xd:short>
        <xd:detail>Low priority default template for generating css rules from the
         <code>@rend</code> attribute in css mode. Note that we exclude the column element in another
         rule.</xd:detail>
    </xd:doc>

    <xsl:template match="*[@rend]" mode="css" priority="-1">
        <xsl:call-template name="generate-css-rule"/>
        <xsl:apply-templates mode="css"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Low priority default template for copying css styles.</xd:short>
        <xd:detail>Low priority default template for copying css styles from the
         <code>@style</code> attribute in style mode. Note that we exclude the column element in another
         template.</xd:detail>
    </xd:doc>

    <xsl:template match="*[@style]" mode="style" priority="-1">
        <xsl:call-template name="generate-style-rule"/>
        <xsl:apply-templates mode="style"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate a CSS rule.</xd:short>
        <xd:detail>Generate a CSS rule from a <code>@rend</code> attribute. Using a key on <code>name():@rend</code>, we
        do so only for the first occurance of a <code>@rend</code> attribute on each element type.</xd:detail>
    </xd:doc>

    <xsl:template name="generate-css-rule">
        <xsl:if test="generate-id() = generate-id(key('rend', concat(name(), ':', @rend))[1])">
            <xsl:variable name="css-properties" select="normalize-space(f:translate-rend-ladder(@rend, name()))"/>
            <xsl:if test="$css-properties != ''">
                <!-- Use the id of the first element with this rend attribute as a class selector -->
                <xsl:text>
.</xsl:text>
                <xsl:value-of select="f:generate-css-class-selector(.)"/>
                <xsl:text> {
</xsl:text>
                <xsl:value-of select="$css-properties"/>
                <xsl:text>
}
</xsl:text>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Copy a CSS rule.</xd:short>
        <xd:detail>Copy a CSS rule from a <code>@style</code> attribute. Using a key on <code>@style</code>, we
        do so only for the first occurance of a <code>@style</code> attribute.</xd:detail>
    </xd:doc>

    <xsl:template name="generate-style-rule">
        <xsl:if test="generate-id() = generate-id(key('style', @style)[1])">
            <xsl:variable name="style" select="normalize-space(@style)"/>
            <xsl:if test="$style != ''">
                <!-- Use the id of the first element with this style attribute as a class selector -->
                <xsl:text>
.</xsl:text>
                <xsl:value-of select="f:generate-style-class-selector(.)"/>
                <xsl:text> {
</xsl:text>
                <xsl:value-of select="$style"/>
                <xsl:text>
}
</xsl:text>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Ignore content in CSS modes.</xd:short>
    </xd:doc>

    <xsl:template match="text()" mode="css css-handheld style"/>


    <xd:doc>
        <xd:short>Generate CSS for handheld devices.</xd:short>
        <xd:detail>Generate CSS for handheld devices: specific usage tailored for Project Gutenberg ePub generation.</xd:detail>
    </xd:doc>

    <xsl:template match="text[not(ancestor::q)]" mode="css-handheld">
        <xsl:text>@media handheld {
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
        <xsl:variable name="uri" select="normalize-space($uri)" as="xs:string"/>

        <xsl:copy-of select="f:logInfo('Including CSS stylesheet: {1}', ($uri))"/>

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
                    <xsl:copy-of select="f:logError('Unable to find CSS stylesheet: {1}', ($uri))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Strip comments from the CSS -->
        <xsl:variable name="css" select='replace($css, "/\*(.|[\r\n])*?\*/", " ")' as="xs:string"/>

        <!-- Strip excessive space from the CSS -->
        <xsl:variable name="css" select='replace($css, "[ &#x9;]+", " ")' as="xs:string"/>

        <xsl:value-of select="$css"/>
    </xsl:function>

</xsl:stylesheet>
