<!DOCTYPE xsl:stylesheet [

    <!ENTITY tab        "&#x09;">
    <!ENTITY lf         "&#x0A;">
    <!ENTITY cr         "&#x0D;">
    <!ENTITY deg        "&#176;">
    <!ENTITY ldquo      "&#x201C;">
    <!ENTITY lsquo      "&#x2018;">
    <!ENTITY rsquo      "&#x2019;">
    <!ENTITY bdquo      "&#x201E;">
    <!ENTITY laquo      "&#xAB;">
    <!ENTITY raquo      "&#xBB;">
    <!ENTITY nbsp       "&#160;">
    <!ENTITY mdash      "&#x2014;">
    <!ENTITY prime      "&#x2032;">
    <!ENTITY Prime      "&#x2033;">
    <!ENTITY plusmn     "&#x00B1;">
    <!ENTITY frac14     "&#x00BC;">
    <!ENTITY frac12     "&#x00BD;">
    <!ENTITY frac34     "&#x00BE;">
    <!ENTITY asterism   "&#x2042;">
]>

<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="urn:stylesheet-functions"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="f xd xs">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to format block-level elements, to be imported in tei2html.xsl.</xd:short>
        <xd:detail>This stylesheet formats block-level elements from TEI.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2015, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Start a paragraph with a decorative initial.</xd:short>
        <xd:detail>
            <p>Start a paragraph with a decorative initial. Decorative initials are encoded
            within the <code>rend</code> attribute on the paragraph level, using the value
            <code>initial-image()</code>.</p>

            <p>To properly show an initial in HTML that may stick over the text, we need
            to use several tricks in CSS.</p>

            <ol>
                <li>Set the initial as background picture on the paragraph.</li>
                <li>Create a small div, which we float to the left, to give the initial
                the space it needs.</li>
                <li>Set the padding-top to a value such that the initial actually appears
                to stick over the paragraph.</li>
                <li>Set the initial as background picture to the float, such that if the
                paragraph is too small to contain the entire initial, the float will. We
                need to take care to adjust the background position to match the
                padding-top, such that the two background images will align exactly.</li>
                <li>Remove the initial letter from the paragraph, and make it invisible,
                such that it re-appears when no CSS is available.</li>
                <li>Remove opening quotation marks when they appear before
                the initial letter.</li>
            </ol>

            <p>The following rendition-ladder values are used in this process:</p>

            <table>
                <tr><td>initial-image</td><td>Name of the image file to use as initial.</td></tr>
                <tr><td>initial-width</td><td>The width to reserve for the initial.</td></tr>
                <tr><td>initial-height</td><td>The height to reserve for the initial.</td></tr>
                <tr><td>initial-offset</td><td>The distance the initial will stick out above the paragraph.</td></tr>
            </table>

            <p>In some rendering engines, these tricks do not yield the desired results,
            so we fall back to a more robust method, using a floating image.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="p[f:has-rend-value(@rend, 'initial-image')]">
        <xsl:call-template name="handle-initial-image"/>
    </xsl:template>


    <!-- Can also be called for lines of verse, see drama.xsl. -->
    <xsl:template name="handle-initial-image">
        <xsl:context-item as="element()" use="required"/>
        <xsl:choose>
            <xsl:when test="f:use-initial-image-with-float()">
                <xsl:call-template name="initial-image-with-float"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="initial-image-with-css"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:function name="f:use-initial-image-with-float" as="xs:boolean">
        <xsl:sequence select="f:is-pdf() or f:is-epub() or f:is-set('pg.compliant')"/>
    </xsl:function>


    <xsl:template name="initial-image-with-css">
        <xsl:context-item as="element()" use="required"/>
        <xsl:element name="{$p.element}">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:attribute name="class">
                <xsl:if test="$p.element != 'p'"><xsl:text>par </xsl:text></xsl:if>
                <xsl:if test="self::l"><xsl:text>line </xsl:text></xsl:if>
                <xsl:value-of select="f:generate-class-name(.)"/>
            </xsl:attribute>
            <span>
                <xsl:attribute name="class"><xsl:value-of select="f:generate-class-name(.)"/>init</xsl:attribute>
                <xsl:value-of select="f:replaced-initial(f:text-without-notes(.))"/>
            </span>
            <xsl:call-template name="initial-image-paragraph-remainder"/>
        </xsl:element>
    </xsl:template>


    <xsl:function name="f:text-without-notes" as="xs:string">
        <xsl:param name="node"/>
        <xsl:variable name="text">
            <xsl:apply-templates select="$node" mode="strip-notes"/>
        </xsl:variable>
        <xsl:sequence select="$text"/>
    </xsl:function>

    <xsl:template mode="strip-notes" match="note">
        <xsl:copy-of select="f:log-debug('stripping note (n={0}; place={1}; content={2}).', (@n, @place, string(.)))"/>
    </xsl:template>


    <xsl:template name="initial-image-paragraph-remainder">
        <xsl:context-item as="element()" use="required"/>
        <xsl:choose>
            <xsl:when test="node()[1][self::note]">
                <!-- Deal with a marginal note right at the start of a paragraph -->
                <xsl:apply-templates select="node()[1]"/>
                <xsl:apply-templates select="node()[2]" mode="remove-initial"/>
                <xsl:apply-templates select="node()[position() > 2]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="node()[1]" mode="remove-initial"/>
                <xsl:apply-templates select="node()[position() > 1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>A list of open quotation marks, used when handling decorative initials.</xd:doc>

    <xsl:variable name="open-quotation-mark" select="('&ldquo;', '&lsquo;', '&rsquo;', '&bdquo;', '&laquo;', '&raquo;')" as="xs:string*"/>

    <xsl:function name="f:replaced-initial" as="xs:string">
        <xsl:param name="text" as="xs:string"/>
        <xsl:variable name="text" select="replace($text, '^\s+', '')"/>

        <xsl:value-of select="if (substring($text, 1, 1) = $open-quotation-mark) then substring($text, 1, 2) else substring($text, 1, 1)"/>
    </xsl:function>

    <xsl:function name="f:remove-initial" as="xs:string">
        <xsl:param name="text" as="xs:string"/>
        <xsl:variable name="text" select="replace($text, '^\s+', '')"/>

        <xsl:value-of select="if (substring($text, 1, 1) = $open-quotation-mark) then substring($text, 3) else substring($text, 2)"/>
    </xsl:function>


    <xsl:template name="initial-image-with-float">
        <xsl:context-item as="element()" use="required"/>

        <div class="figure floatLeft">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:copy-of select="f:output-image(f:rend-value(@rend, 'initial-image'), f:replaced-initial(f:text-without-notes(.)))"/>
        </div>
        <xsl:element name="{$p.element}">
            <xsl:attribute name="class">
                <xsl:if test="$p.element != 'p'"><xsl:text>par </xsl:text></xsl:if>
                <xsl:if test="self::l"><xsl:text>line </xsl:text></xsl:if>
                <xsl:text>first</xsl:text>
            </xsl:attribute>
            <xsl:call-template name="initial-image-paragraph-remainder"/>
        </xsl:element>
    </xsl:template>


    <xd:doc mode="css">
        <xd:short>Mode to generate CSS.</xd:short>
    </xd:doc>

    <xd:doc>
        <xd:short>Generate the CSS related to a decorative initial.</xd:short>
    </xd:doc>

    <xsl:template match="p[f:has-rend-value(@rend, 'initial-image')]" mode="css">
        <xsl:call-template name="handle-initial-image-css"/>
    </xsl:template>

    <xsl:template name="handle-initial-image-css">
        <xsl:context-item as="element()" use="required"/>
        <xsl:if test="not(f:use-initial-image-with-float())">
            <xsl:if test="generate-id() = generate-id(key('rend', name() || ':' || @rend)[1])">
                <xsl:variable name="css-properties" select="f:translate-rend-ladder(@rend, name())"/>
                <xsl:variable name="scale-factor" select="xs:decimal(f:get-setting('images.scale'))" as="xs:decimal"/>

                <xsl:text>&lf;.</xsl:text><xsl:value-of select="f:generate-css-class-selector(.)"/><xsl:text> {&lf;</xsl:text>
                <xsl:text>background: url(</xsl:text><xsl:value-of select="f:rend-value(@rend, 'initial-image')"/><xsl:text>) no-repeat top left;&lf;</xsl:text>
                <xsl:if test="f:has-rend-value(@rend, 'initial-offset')">
                    <xsl:text>padding-top: </xsl:text><xsl:value-of select="f:rend-value(@rend, 'initial-offset')"/><xsl:text>;&lf;</xsl:text>
                </xsl:if>
                <xsl:if test="$scale-factor != 1.0">
                    <xsl:text>background-size: </xsl:text><xsl:value-of select="f:rend-value(@rend, 'initial-width')"/><xsl:text>;&lf;</xsl:text>
                </xsl:if>

                <xsl:if test="normalize-space($css-properties) != ''">
                    <xsl:value-of select="normalize-space($css-properties)"/>
                </xsl:if>
                <xsl:text>}&lf;</xsl:text>

                <xsl:text>&lf;.</xsl:text><xsl:value-of select="f:generate-css-class-selector(.)"/><xsl:text>init {&lf;</xsl:text>
                <xsl:text>float: left;&lf;</xsl:text>
                <xsl:text>width: </xsl:text><xsl:value-of select="f:rend-value(@rend, 'initial-width')"/><xsl:text>;&lf;</xsl:text>
                <xsl:text>height: </xsl:text><xsl:value-of select="f:rend-value(@rend, 'initial-height')"/><xsl:text>;&lf;</xsl:text>
                <xsl:text>background: url(</xsl:text><xsl:value-of select="f:rend-value(@rend, 'initial-image')"/><xsl:text>) no-repeat;&lf;</xsl:text>
                <xsl:if test="f:has-rend-value(@rend, 'initial-offset')">
                    <xsl:text>background-position: 0 -</xsl:text><xsl:value-of select="f:rend-value(@rend, 'initial-offset')"/><xsl:text>;&lf;</xsl:text>
                </xsl:if>
                <xsl:if test="$scale-factor != 1.0">
                    <xsl:text>background-size: </xsl:text><xsl:value-of select="f:rend-value(@rend, 'initial-width')"/><xsl:text>;&lf;</xsl:text>
                </xsl:if>
                <xsl:text>text-align: right;&lf;</xsl:text>
                <xsl:text>visibility: hidden;&lf;</xsl:text>
                <xsl:text>font-size: 1px;&lf;</xsl:text>
                <xsl:text>}&lf;</xsl:text>
            </xsl:if>
        </xsl:if>
        <xsl:apply-templates mode="css"/>
    </xsl:template>


    <xd:doc mode="css-handheld">
        <xd:short>Mode to generate CSS for hand-held devices.</xd:short>
    </xd:doc>

    <xd:doc>
        <xd:short>Generate the CSS related to a decorative initial (for use on hand-held devices).</xd:short>
    </xd:doc>

    <!-- Override decorative initials for handheld devices. -->
    <xsl:template match="p[f:has-rend-value(@rend, 'initial-image')]" mode="css-handheld">
        <xsl:if test="generate-id() = generate-id(key('rend', name() || ':' || @rend)[1])">

            <xsl:text>&lf;.</xsl:text><xsl:value-of select="f:generate-css-class-selector(.)"/><xsl:text> {&lf;</xsl:text>
            <xsl:text>background-image: none;&lf;</xsl:text>
            <xsl:text>padding-top: 0;&lf;</xsl:text>
            <xsl:text>}&lf;</xsl:text>

            <xsl:text>&lf;.</xsl:text><xsl:value-of select="f:generate-css-class-selector(.)"/><xsl:text>init {&lf;</xsl:text>
            <xsl:text>float: none;&lf;</xsl:text>
            <xsl:text>width: auto;&lf;</xsl:text>
            <xsl:text>height: auto;&lf;</xsl:text>
            <xsl:text>background-image: none;&lf;</xsl:text>
            <xsl:text>text-align: right;&lf;</xsl:text>
            <xsl:text>color: inherit;&lf;</xsl:text>
            <xsl:text>font-size: inherit;&lf;</xsl:text>
            <xsl:text>}&lf;</xsl:text>

        </xsl:if>
        <xsl:apply-templates mode="css-handheld"/>
    </xsl:template>


    <xd:doc mode="remove-initial">
        <xd:short>Mode to remove the first letter (and any preceding quotation marks) from a paragraph.</xd:short>
        <xd:detail>This mode is also used with the <code>hi</code> element in <code>inline.xsl</code>, where it
        is used as an additional possible mode. This code is tricky, as it wants to deal with text nodes that
        may be embedded in multiple surrounding elements, but only the first one.</xd:detail>
    </xd:doc>

    <xd:doc>
        <xd:short>Remove the first letter of a paragraph.</xd:short>
        <xd:detail>Remove the first letter of a paragraph. This means we want to remove the first letter
        of this text node only if it is the first text node in a paragraph. To verify this, it is not enough
        to just look at the <code>position()</code> (as it may be nested several levels deep), But actually will
        have to determine what text is part of the current paragraph and before the current node.</xd:detail>
    </xd:doc>

    <xsl:template match="text()" mode="remove-initial">
        <!-- Get text of the current paragraph before the current node: we only want to remove the initial if this is empty (ignoring any notes that are lifted out of the text-flow). -->
        <xsl:variable name="paragraph-so-far" select="(./preceding::node()[not(ancestor-or-self::note)][./ancestor::p[1] is current()/ancestor::p[1]])[1]"/>
        <xsl:copy-of select="f:log-debug('paragraph so-far: {1}', ($paragraph-so-far))"/>

        <xsl:choose>
            <xsl:when test="string-length($paragraph-so-far) = 0 and position() = 1">
                <xsl:copy-of select="f:log-debug('removing initial letter from: {1}', (.))"/>
                <xsl:value-of select="f:process-text(f:remove-initial(.), f:get-current-lang(.))"/>
             </xsl:when>
            <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Remove the first letter of a paragraph (intermediate element).</xd:short>
        <xd:detail>While removing the first letter of a paragraph, we may encounter an
        intermediate element. We currently do handle <code>hi</code> and <code>foreign</code> elements;
        warn for all other types of elements when we encounter them.</xd:detail>
    </xd:doc>

    <xsl:template match="*" mode="remove-initial">
        <xsl:choose>
            <xsl:when test="position() = 1">
                <xsl:copy-of select="f:log-warning('Skipping processing of {1} element while removing initial from paragraph with decorative initial.', (name(.)))"/>
                <xsl:apply-templates mode="remove-initial"/>
            </xsl:when>
            <xsl:otherwise><xsl:apply-templates select="."/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Use a simple drop-cap at the start of a paragraph.</xd:short>
        <xd:detail>Use a simple drop-cap at the start of a paragraph. Provide a unique class name for the drop-cap, as well as a generic one.
        Some CSS implementations do not handle the <code>:first-letter</code> pseudo-selector correctly, so we provide a span for this.</xd:detail>
    </xd:doc>

    <xsl:template match="p[f:has-rend-value(@rend, 'dropcap')]">
        <xsl:element name="{$p.element}">
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:attribute name="class">
                <xsl:if test="$p.element != 'p'"><xsl:text>par </xsl:text></xsl:if>
                <xsl:value-of select="f:generate-class-name(.)"/>
            </xsl:attribute>
            <span>
                <xsl:attribute name="class"><xsl:value-of select="f:generate-class-name(.)"/>dc initdropcap</xsl:attribute>
                <xsl:value-of select="f:replaced-initial(f:text-without-notes(.))"/>
            </span>
            <span>
                <xsl:attribute name="class"><xsl:value-of select="f:generate-class-name(.)"/>adc afterdropcap</xsl:attribute>
                <xsl:call-template name="initial-image-paragraph-remainder"/>
            </span>
        </xsl:element>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate CSS for drop-cap.</xd:short>
        <xd:detail>Generate CSS for drop-cap. Note that the exact size to be used for a drop-cap depends on the specific
        font being used, and the number of lines desired to be occupied by the drop-cap. This needs to be tweaked when the
        choice for a font, font-size, and line-spacing has been made.</xd:detail>
    </xd:doc>

    <xsl:template match="p[f:has-rend-value(@rend, 'dropcap')]" mode="css">

        <!-- Only generate the CSS-class once if multiple paragraphs have the same @rend value. -->
        <xsl:if test="not(preceding::p[@rend = current()/@rend])">
            <xsl:variable name="css-properties" select="f:translate-rend-ladder(@rend, name())"/>
            <xsl:variable name="ccs-selector" select="f:generate-css-class-selector(.)"/>

            <xsl:text>&lf;.</xsl:text><xsl:value-of select="$ccs-selector"/><xsl:text> {&lf;</xsl:text>
            <xsl:text>text-indent: 0;&lf;</xsl:text>

            <xsl:if test="normalize-space($css-properties) != ''">
                <xsl:value-of select="normalize-space($css-properties)"/>
            </xsl:if>
            <xsl:text>}&lf;</xsl:text>

            <xsl:text>&lf;.</xsl:text><xsl:value-of select="$ccs-selector"/><xsl:text>dc {&lf;</xsl:text>
            <xsl:text>float: left;&lf;</xsl:text>
            <xsl:if test="f:has-rend-value(@rend, 'dropcap-offset')">
                <xsl:text>margin-top: -</xsl:text><xsl:value-of select="f:rend-value(@rend, 'dropcap-offset')"/><xsl:text>;&lf;</xsl:text>
            </xsl:if>
            <xsl:if test="f:has-rend-value(@rend, 'dropcap-height')">
                <xsl:text>height: </xsl:text><xsl:value-of select="f:rend-value(@rend, 'dropcap-height')"/><xsl:text>;&lf;</xsl:text>
            </xsl:if>
            <xsl:text>font-size: </xsl:text><xsl:value-of select="f:rend-value(@rend, 'dropcap')"/><xsl:text>;&lf;</xsl:text>
            <xsl:text>margin-left: 0;&lf;</xsl:text>
            <xsl:text>margin-bottom: 5px;&lf;</xsl:text>
            <xsl:text>margin-right: 3px;&lf;</xsl:text>
            <xsl:text>}&lf;</xsl:text>

            <xsl:text>.</xsl:text><xsl:value-of select="$ccs-selector"/><xsl:text>adc {&lf;</xsl:text>
            <xsl:text>/* empty */&lf;</xsl:text>
            <xsl:text>}&lf;</xsl:text>
        </xsl:if>

        <xsl:apply-templates mode="css"/>
    </xsl:template>

</xsl:stylesheet>
