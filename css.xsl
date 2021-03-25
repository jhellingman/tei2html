<!DOCTYPE xsl:stylesheet [

    <!ENTITY lf         "&#x0A;">
    <!ENTITY cr         "&#x0D;">

]>

<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="f xd xhtml xs">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to generate a CSS stylesheet to accompany HTML or ePub output.</xd:short>
        <xd:detail>This stylesheet formats generates a CSS stylesheet from TEI. According to the requirements
        of ePub, <code>@style</code> attributes are not allowed in the generated XHTML, so all CSS
        rules are collected from the TEI file, and put together in a separate CSS file. Further templates in
        the <code>css</code> mode are integrated in the other stylesheets, to keep them together with
        related HTML generating templates.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011-2020, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Key to quickly find <code>@rend</code> attributes on elements.</xd:short>
    </xd:doc>

    <xsl:key name="rend" match="*" use="name() || ':' || @rend"/>


    <xd:doc>
        <xd:short>Key to quickly find <code>@style</code> attributes on elements.</xd:short>
    </xd:doc>

    <xsl:key name="style" match="*" use="@style"/>

    <xsl:variable name="css2properties" as="xs:string*">
        <xsl:sequence select="('azimuth', 'background-attachment', 'background-color', 'background-image', 'background-position', 'background-repeat', 'background', 'border-collapse', 'border-color',
            'border-spacing', 'border-style', 'border-top', 'border-right', 'border-bottom', 'border-left', 'border-top-color', 'border-right-color', 'border-bottom-color',
            'border-left-color', 'border-top-style', 'border-right-style', 'border-bottom-style', 'border-left-style', 'border-top-width', 'border-right-width', 'border-bottom-width',
            'border-left-width', 'border-width', 'border', 'bottom', 'caption-side', 'clear', 'clip', 'color', 'content', 'counter-increment', 'counter-reset', 'cue-after',
            'cue-before', 'cue', 'cursor', 'direction', 'display', 'elevation', 'empty-cells', 'float', 'font-family', 'font-size', 'font-style', 'font-variant', 'font-weight',
            'font', 'height', 'left', 'letter-spacing', 'line-height', 'list-style-image', 'list-style-position', 'list-style-type', 'list-style', 'margin-right', 'margin-left',
            'margin-top', 'margin-bottom', 'margin', 'max-height', 'max-width', 'min-height', 'min-width', 'orphans', 'outline-color', 'outline-style', 'outline-width', 'outline',
            'overflow', 'padding-top', 'padding-right', 'padding-bottom', 'padding-left', 'padding', 'page-break-after', 'page-break-before', 'page-break-inside', 'pause-after',
            'pause-before', 'pause', 'pitch-range', 'pitch', 'play-during', 'position', 'quotes', 'richness', 'right', 'speak-header', 'speak-numeral', 'speak-punctuation', 'speak',
            'speech-rate', 'stress', 'table-layout', 'text-align', 'text-decoration', 'text-indent', 'text-transform', 'top', 'unicode-bidi', 'vertical-align', 'visibility',
            'voice-family', 'volume', 'white-space', 'widows', 'width', 'word-spacing', 'z-index')"/>
    </xsl:variable>


    <xd:doc>
        <xd:short>Embed CSS stylesheets.</xd:short>
        <xd:detail>
            <p>Embed the standard (common) and generated (custom) CSS stylesheets in the HTML output.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="embed-css-stylesheets">
        <xsl:variable name="css">
            <xsl:call-template name="generate-css"/>
        </xsl:variable>

        <xsl:call-template name="output-embedded-css">
            <xsl:with-param name="css" select="$css"/>
        </xsl:call-template>

        <!-- Pull in CSS sheet for print (when using Prince). -->
        <xsl:if test="f:is-set('css.useCommonPrint') and $optionPrinceMarkup = 'Yes'">
            <style type="text/css" media="print">
                <xsl:value-of select="f:css-stylesheet('style/print.css')"/>
            </style>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Output embedded CSS stylesheets.</xd:short>
        <xd:detail>
            <p>Output embedded CSS stylesheets. Because CSS can include the &gt; symbol
            (the direct descendant selector), we need to make sure that this is not escaped,
            that is, place the generated CSS in a CDATA block, and then hide this again in
            CSS comments for some older browsers.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="output-embedded-css">
        <xsl:param name="css" as="xs:string"/>

        <xsl:text disable-output-escaping="yes">
            &lt;style type="text/css"&gt; /* &lt;![CDATA[ */
        </xsl:text>
        <xsl:value-of select="$css" disable-output-escaping="yes"/>
        <xsl:text disable-output-escaping="yes">
            /* ]]&gt; */ &lt;/style&gt;
        </xsl:text>
    </xsl:template>


    <xd:doc>
        <xd:short>Collect all CSS used into a single (external) .css file.</xd:short>
        <xd:detail>
            <p>Collect the standard and generated CSS stylesheets in a single external .css file.
            This is typically used when generating an ePub file.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="external-css-stylesheets">
        <xsl:result-document
                href="{$path}/{$basename}.css"
                method="text"
                encoding="UTF-8">
            <xsl:copy-of select="f:log-info('Generated CSS stylesheet: {1}/{2}.css', ($path, $basename))"/>
            <xsl:call-template name="generate-css"/>
        </xsl:result-document>
    </xsl:template>


    <xsl:template name="generate-css">
        <xsl:if test="f:is-set('css.useCommon')">
            <xsl:call-template name="common-css-stylesheets"/>
        </xsl:if>
        <xsl:call-template name="custom-css-stylesheets"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Collect the common CSS stylesheets.</xd:short>
        <xd:detail>
            <p>Copy the standard CSS stylesheets.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="common-css-stylesheets">

        <!-- Standard CSS stylesheets, always included. -->
        <xsl:value-of select="f:css-stylesheet('style/normalize.css')"/>
        <xsl:value-of select="f:css-stylesheet('style/layout.css')"/>
        <xsl:value-of select="f:css-stylesheet('style/list.css')"/>

        <!-- Stylesheets for various types of elements, only included when needed. -->
        <xsl:if test="//titlePage">
            <xsl:value-of select="f:css-stylesheet('style/titlepage.css')"/>
        </xsl:if>

        <xsl:if test="//figure">
            <xsl:value-of select="f:css-stylesheet('style/figure.css')"/>
        </xsl:if>

        <xsl:if test="//formula">
            <xsl:value-of select="f:css-stylesheet('style/formulas.css')"/>
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

        <xsl:if test="//divGen[@type='TagUsage']">
            <xsl:value-of select="f:css-stylesheet('style/tagusage.css')"/>
        </xsl:if>

        <!-- Test covers align-with(...) and align-with-document(...) -->
        <xsl:if test="(//div|//div1|//div2|//div3|//div4|//div5|//div6)[contains(@rend, 'align-with')] or //lg[contains(@rend, 'align-with')]">
            <xsl:value-of select="f:css-stylesheet('style/aligned-text.css')"/>
        </xsl:if>

        <!-- Format-specific stylesheets. -->
        <xsl:if test="f:is-epub()">
            <xsl:value-of select="f:css-stylesheet('style/layout-epub.css')"/>
        </xsl:if>

        <xsl:if test="f:is-html()">
            <xsl:value-of select="f:css-stylesheet('style/layout-html.css')"/>
        </xsl:if>

        <!-- Debugging CSS stylesheet. -->
        <xsl:if test="f:is-set('debug')">
            <xsl:value-of select="f:css-stylesheet('style/debug.css')"/>
        </xsl:if>

        <!-- Standard Aural CSS stylesheet (uses CSS 3 CSS Speech Module (RC) -->
        <xsl:if test="f:is-set('useCommonAural')">
            <xsl:value-of select="f:css-stylesheet('style/aural.css')"/>
        </xsl:if>

        <!-- Supplement CSS stylesheets as specified in the rend-attribute on the main text element. -->
        <xsl:variable name="stylesheet" as="xs:string">
            <xsl:choose>
                <xsl:when test="f:has-rend-value(/*[self::TEI.2 or self::TEI]/text/@rend, 'stylesheet')">
                    <xsl:value-of select="f:rend-value(/*[self::TEI.2 or self::TEI]/text/@rend, 'stylesheet')"/>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="f:get-setting('css.stylesheet')"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:for-each select="tokenize($stylesheet, ',')">
            <xsl:value-of select="f:css-stylesheet(normalize-space(.))"/>
        </xsl:for-each>
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
            and in that case may need to be translated in target (<i>i.e.</i> HTML) terms. For now,
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
        <xsl:copy-of select="f:log-warning('Rendition element without id or selector: {1}', (rendition))"/>
    </xsl:template>

    <xd:doc>
        <xd:short>Translate the <code>@rend</code> attributes to CSS.</xd:short>
        <xd:detail><p>Translate the <code>@rend</code> attributes, specified in a rendition-ladder syntax, to CSS.</p>

        <p>rendition-ladder syntax consists of a series of keys followed by the value between parentheses, <i>e.g.</i>,
        <code>font-size(large) color(red)</code>.</p></xd:detail>
        <xd:param name="rend">The <code>@rend</code> attribute to be translated.</xd:param>
        <xd:param name="name">The name of the element carrying this attribute.</xd:param>
    </xd:doc>

    <xsl:variable name="rendition-ladder-pattern" select="'([a-z][a-z0-9-]*)\((.*?)\)'"/>
    <xsl:variable name="class-name-pattern" select="'^[a-zA-Z][a-zA-Z0-9-]+$'"/>

    <xsl:function name="f:translate-rend-ladder" as="xs:string">
        <xsl:param name="rend" as="xs:string?"/>
        <xsl:param name="name" as="xs:string"/>

        <xsl:variable name="rend" select="if ($rend) then $rend else ''" as="xs:string"/>

        <xsl:variable name="css">
            <xsl:analyze-string select="$rend" regex="{$rendition-ladder-pattern}" flags="i">
                <xsl:matching-substring>
                    <xsl:value-of select="f:translate-rend-ladder-step(regex-group(1), regex-group(2), $name)"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:variable name="fragment" select="normalize-space(.)"/>
                    <xsl:if test="$fragment != '' and not(matches($fragment, $class-name-pattern))">
                        <xsl:message expand-text="yes">WARNING: part of rendition ladder not understood: '{.}'</xsl:message>
                    </xsl:if>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>

        <xsl:value-of select="normalize-space($css)"/>
    </xsl:function>


    <xsl:function name="f:extract-class-from-rend-ladder" as="xs:string">
        <xsl:param name="rend" as="xs:string?"/>
        <xsl:param name="name" as="xs:string"/>

        <xsl:variable name="rend" select="if ($rend) then $rend else ''" as="xs:string"/>

        <xsl:variable name="class">
            <xsl:analyze-string select="$rend" regex="{$rendition-ladder-pattern}" flags="i">
                <xsl:matching-substring>
                    <!-- ignore rendition-ladder elements here -->
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:if test="matches(normalize-space(.), $class-name-pattern)">
                        <xsl:value-of select="f:filter-class(., $name)"/>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>

        <xsl:value-of select="$class"/>
    </xsl:function>

    <xsl:function name="f:filter-class" as="xs:string">
        <xsl:param name="class" as="xs:string"/>
        <xsl:param name="element" as="xs:string"/>

        <xsl:variable name="class">
            <xsl:choose>
                <!-- Filter rendition values handled in a special way elsewhere -->
                <xsl:when test="$class = ('hide', 'display', 'inline')"/>

                <xsl:when test="$element = 'hi' and $class = ('rm', 'it', 'italic', 'b', 'bold', 'sc', 'asc', 'ex', 'g', 'bi', 'tt', 'bold-italic', 'sup', 'sub', 'underline', 'overline', 'overtilde')"/>
                <xsl:when test="$element = 'q' and $class = 'block'"/>
                <xsl:when test="$element = 'p' and $class = 'noindent'"/>

                <!-- Assume the rest can be copied to the class-attribute in HTML -->
                <xsl:otherwise>
                    <xsl:value-of select="$class"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="$class"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Translate a single rend-ladder step to a CSS property.</xd:short>
        <xd:detail>Translate a single rend-ladder step to a CSS property. Filter those steps
        with a special meaning, so they will not be output as invalid CSS.</xd:detail>
        <xd:param name="property">The name of the property to be filtered.</xd:param>
        <xd:param name="value">The value of this property.</xd:param>
        <xd:param name="element">The name of the element carrying the rend attribute.</xd:param>
    </xd:doc>

    <xsl:function name="f:translate-rend-ladder-step" as="xs:string">
        <xsl:param name="property" as="xs:string"/>
        <xsl:param name="value" as="xs:string"/>
        <xsl:param name="element" as="xs:string"/>

        <xsl:variable name="css">
            <xsl:choose>
                <!-- Drop properties without values -->
                <xsl:when test="normalize-space($value)=''"/>

                <!-- Non-CSS properties handled otherwise -->
                <xsl:when test="$property='align-with'"/>           <!-- indicates to align one division with another in a table -->
                <xsl:when test="$property='align-with-document'"/>  <!-- indicates to align one division with another in a table -->
                <xsl:when test="$property='class'"/>                <!-- pass-through CSS class -->
                <xsl:when test="$property='columns'"/>              <!-- number of columns to use on list, table, etc. -->
                <xsl:when test="$property='cover-image'"/>          <!-- cover-image for ePub versions -->
                <xsl:when test="$property='decimal-separator'"/>    <!-- for aligning columns of numbers -->
                <xsl:when test="$property='display' and $value='castGroupTable'"/>  <!-- special rendering of castGroup -->
                <xsl:when test="$property='display' and $value='image-only'"/>  <!-- show image instead of head -->
                <xsl:when test="$property='ditto-mark'"/>           <!-- Ditto mark to be used in tables, default: ,, -->
                <xsl:when test="$property='ditto-repeat'"/>         <!-- How often ditto mark will be repeated in tables: word (default) or segment -->
                <xsl:when test="$property='image'"/>                <!-- in-line image -->
                <xsl:when test="$property='image-alt'"/>            <!-- alt text for image -->
                <xsl:when test="$property='item-order'"/>           <!-- way to split a list or table into multiple columns: row-mayor (default) or column-mayor -->
                <xsl:when test="$property='label'"/>                <!-- label (for head, etc.) -->
                <xsl:when test="$property='link'"/>                 <!-- external link (for example on image) -->
                <xsl:when test="$property='media-overlay'"/>        <!-- media overlay for ePub versions -->
                <xsl:when test="$property='position'"/>             <!-- position in text -->
                <xsl:when test="$property='stylesheet'"/>           <!-- stylesheet to load (only on top-level text element) -->
                <xsl:when test="$property='summary'"/>              <!-- summary text for table, etc. -->
                <xsl:when test="$property='title'"/>                <!-- title text for links, etc. -->
                <xsl:when test="$property='toc'"/>                  <!-- indicates how to include a head in the toc -->
                <xsl:when test="$property='toc-head'"/>             <!-- head to be used in table of contents -->
                <xsl:when test="$property='tocMaxLevel'"/>          <!-- the maximum level (depth) of a generated table of contents -->

                <!-- Non-CSS properties used to render verse -->
                <xsl:when test="$property='hemistich'"/>            <!-- render text given in value invisible (i.e. white) to indent with width of previous line -->

                <!-- Non-CSS properties related to decorative initials -->
                <xsl:when test="$property='dropcap'"/>
                <xsl:when test="$property='dropcap-height'"/>
                <xsl:when test="$property='dropcap-offset'"/>
                <xsl:when test="$property='initial-height'"/>
                <xsl:when test="$property='initial-image'"/>
                <xsl:when test="$property='initial-offset'"/>
                <xsl:when test="$property='initial-width'"/>

                <!-- divGen related special handling. -->
                <xsl:when test="$element = 'divGen' and $property = 'include'"/>

                <!-- Figure related special handling. -->
                <xsl:when test="$element = 'figure' and $property = 'float'"/>

                <!-- Table related special handling. With the rule
                     margin: 0px auto, the table is centered, while
                     display: table shrinks the bounding box to the content -->
                <xsl:when test="$element = 'table' and $property = 'align' and $value = 'center'">margin:0px auto; display:table; </xsl:when>
                <xsl:when test="$element = 'table' and $property = 'indent'">margin-left:<xsl:value-of select="f:indent-value($value)"/>; </xsl:when>

                <!-- Line-breaks with indents need to be handled specially (drama.xsl), so should be removed here. -->
                <xsl:when test="$element='lb' and $property='indent'"/>

                <!-- Properties related to special font usage -->
                <xsl:when test="$property='font' and $value='fraktur'">font-family:'<xsl:value-of select="f:get-setting('css.frakturFont')"/>'; </xsl:when>
                <xsl:when test="$property='font' and $value='blackletter'">font-family:'<xsl:value-of select="f:get-setting('css.blackletterFont')"/>'; </xsl:when>

                <xsl:when test="$property='font' and $value='italic'">font-style:italic; </xsl:when>

                <xsl:when test="$property='align'">text-align:<xsl:value-of select="$value"/>; </xsl:when>
                <xsl:when test="$property='valign'">vertical-align:<xsl:value-of select="$value"/>; </xsl:when>
                <xsl:when test="$property='indent'">text-indent:<xsl:value-of select="f:indent-value($value)"/>; </xsl:when>

                <!-- Filter out CSS3 stuff (for Project Gutenberg submissions) -->
                <xsl:when test="f:get-setting('css.support') = '2' and
                    $property = ('writing-mode')">
                    <xsl:copy-of select="f:log-info('Ignoring CCS3 property ''{1}''', $property)"/>
                </xsl:when>

                <!-- Assume the rest can straightforwardly be translated to CSS -->
                <xsl:otherwise>
                    <xsl:if test="not($property = $css2properties)">
                        <xsl:copy-of select="f:log-warning('''{1}'' is not a CSS2.1 property', $property)"/>
                    </xsl:if>
                    <xsl:value-of select="$property"/>:<xsl:value-of select="$value"/><xsl:text>; </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="$css"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Handle indent values without a unit (assume em).</xd:short>
        <xd:detail>Use without units should be deprecated, but historically we have a lot of texts specifying an indent as
        just a number, which is here assumed to mean a value in ems.</xd:detail>
    </xd:doc>

    <xsl:function name="f:indent-value" as="xs:string">
        <xsl:param name="value" as="xs:string"/>
        <xsl:value-of select="if (matches($value, '^[0-9]+(\.[0-9]+)?$')) then $value || 'em' else $value"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate a class name for a rendition ladder.</xd:short>
        <xd:detail>Generate a class name for a rendition ladder. This class name is derived from the (generated) id
        of the first element having the specific <code>@rend</code> attribute value of this node.</xd:detail>
        <xd:param name="node">The node for which a class name is to be generated.</xd:param>
    </xd:doc>

    <xsl:function name="f:generate-class-name" as="xs:string">
        <xsl:param name="node" as="element()"/>
        <xsl:value-of select="f:generate-id(key('rend', name($node) || ':' || $node/@rend, root($node))[1])"/>
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
        <xsl:value-of select="f:escape-css-selector(f:generate-class-name($node))"/>
    </xsl:function>


    <xsl:function name="f:escape-css-selector" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:value-of select="replace($string, '\.', '\\.')"/>
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
                <li>The classes explicitly provided in the <code>@rendition</code> attribute. Note that some works use a prefix
                on the ids of the rendition elements. This can be provided in the configuration file (<code>rendition.id.prefix</code>);
                the default value is the empty string..</li>
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
            <xsl:value-of select="f:extract-class-from-rend-ladder($rend, name($node))"/>
            <xsl:text> </xsl:text>
            <xsl:if test="normalize-space(f:translate-rend-ladder($rend, name($node))) != ''">
                <xsl:value-of select="f:generate-class-name($node)"/>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:if test="normalize-space($node/@style) != ''">
                <xsl:value-of select="f:generate-style-name($node)"/>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:if test="normalize-space($node/@rendition) != ''">
                <xsl:variable name="prefix" select="f:get-setting('rendition.id.prefix')"/>
                <xsl:for-each select="tokenize($node/@rendition, ' ')">
                    <xsl:variable name="renditionId" select="$prefix || replace(., '#', '')"/>
                    <xsl:if test="not($node/ancestor::node()[last()]//tagsDecl/rendition[@id = $renditionId or @xml:id = $renditionId])">
                        <xsl:copy-of select="f:log-warning('Reference to non-existing rendition element with id: {1}', ($renditionId))"/>
                    </xsl:if>
                    <xsl:value-of select="$renditionId"/>
                    <xsl:text> </xsl:text>
                </xsl:for-each>
            </xsl:if>
        </xsl:variable>
        <xsl:value-of select="normalize-space($class)"/>
        <xsl:copy-of select="f:log-debug('Generate class {1} with rend attribute {2}.', (normalize-space($class), $rend))"/>
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

        <xsl:variable name="class" select="normalize-space($class || ' ' || f:generate-class($node))"/>
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
        <xsl:apply-templates select="*[self::TEI.2 or self::TEI]/teiHeader" mode="css-column"/>
        <xsl:apply-templates select="*[self::TEI.2 or self::TEI]/text" mode="css-column"/>

        <!-- Then follow the row-related rendering rules -->
        <xsl:apply-templates select="*[self::TEI.2 or self::TEI]/teiHeader" mode="css-row"/>
        <xsl:apply-templates select="*[self::TEI.2 or self::TEI]/text" mode="css-row"/>

        <!-- Handle the rest of the document (including table cells) -->
        <xsl:apply-templates select="*[self::TEI.2 or self::TEI]/teiHeader" mode="css"/>
        <xsl:apply-templates select="*[self::TEI.2 or self::TEI]/facsimile" mode="css"/>
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
        <xsl:apply-templates select="*[self::TEI.2 or self::TEI]/text" mode="style-column"/>

        <!-- Then follow the row-related rendering rules -->
        <xsl:apply-templates select="*[self::TEI.2 or self::TEI]/text" mode="style-row"/>

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
        <xsl:apply-templates mode="css-row"/>
    </xsl:template>

    <xsl:template match="column[@style]" mode="style-column">
        <xsl:call-template name="generate-style-rule"/>
    </xsl:template>

    <xsl:template match="row[@style]" mode="style-row">
        <xsl:call-template name="generate-style-rule"/>
        <xsl:apply-templates mode="style-row"/>
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
        <xsl:if test="generate-id() = generate-id(key('rend', name() || ':' || @rend)[1])">
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
        <xd:short>Ignore document text() nodes in CSS modes.</xd:short>
    </xd:doc>

    <xsl:template match="text()" mode="css css-row css-column css-handheld style style-row style-column"/>


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

        <xsl:copy-of select="f:log-info('Including CSS stylesheet: {1}', ($uri))"/>

        <xsl:variable name="css">
            <xsl:choose>
                <xsl:when test="ends-with($uri, '.css') and unparsed-text-available($uri)">
                    <xsl:value-of select="replace(unparsed-text($uri), '&#xD;?&#xA;', '&#xA;')"/>
                </xsl:when>
                <xsl:when test="ends-with($uri, '.xml') and unparsed-text-available($uri)">
                    <xsl:value-of select="document($uri)/*/node()"/>
                </xsl:when>
                <xsl:when test="unparsed-text-available($uri || '.xml')">
                    <xsl:value-of select="document($uri || '.xml')/*/node()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="f:log-error('Unable to find CSS stylesheet: {1}', ($uri))"/>
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
