<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet with various utily templates, to be imported in tei2html.xsl.

    Requires:
        localization.xsl    : templates for localizing strings.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:f="urn:stylesheet-functions"
    exclude-result-prefixes="f xs xd"
    version="2.0"
    >


    <xd:doc type="stylesheet">
        <xd:short>Utility templates and functions, used by tei2html</xd:short>
        <xd:detail>This stylesheet contains a number of utility templates and functions, used by tei2html and tei2epub.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <!-- ID Generation

    Use original ID's when possible to keep ID's stable between versions.
    We use generated ID's prepended with 'x' to avoid clashes with original
    ID's. Note that the target id generated here should also be generated
    on the element being referenced. We cannot use the id() function here,
    since we do not use a DTD.

    -->

    <xd:doc>
        <xd:short>Generate an HTML anchor.</xd:short>
        <xd:detail>Generate an HTML anchor with an <code>id</code> attribute for the current node.</xd:detail>
    </xd:doc>

    <xsl:template name="generate-anchor">
        <a>
            <xsl:call-template name="generate-id-attribute"/>
        </a>
    </xsl:template>

    <xd:doc>
        <xd:short>Generate an <code>id</code> attribute.</xd:short>
        <xd:detail>Generate an <code>id</code> attribute for the current node.</xd:detail>
    </xd:doc>

    <xsl:template name="generate-id-attribute">
        <xsl:attribute name="id">
            <xsl:call-template name="generate-id"/>
        </xsl:attribute>
    </xsl:template>

    <xd:doc>
        <xd:short>Generate an <code>id</code>-attribute.</xd:short>
        <xd:detail>Generate an <code>id</code>-attribute for a node (default: current node).</xd:detail>
        <xd:param name="node">The node for which the <code>id</code>-attribute is generated.</xd:param>
    </xd:doc>

    <xsl:template name="generate-id-attribute-for">
        <xsl:param name="node" select="." as="element()"/>
        <xsl:attribute name="id">
            <xsl:call-template name="generate-id-for">
                <xsl:with-param name="node" select="$node"/>
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>

    <xd:doc>
        <xd:short>Generate an <code>id</code>-value.</xd:short>
        <xd:detail>Generate an <code>id</code>-value for the current node.</xd:detail>
    </xd:doc>

    <xsl:template name="generate-id">
        <xsl:call-template name="generate-id-for">
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate a stable id for a node.</xd:short>
        <xd:detail>
            <p>We want to generate ids that are slightly more stable than those genrated by 
            <code>generate-id()</code>. The general idea is to use an explicit id if that is present, and 
            otherwise create an id based on the first ancestor node that does have an id. If,
            for example the third paragraph of a division with id '<code>ch2</code>' has no id of itself,
            we generate: "<code>ch2_p_3</code>" as an id. The second note in this division would receive
            the id "<code>ch2_note_2</code>".</p>

            <table>
                <tr><th>Language    </th><th>Safe ID syntax </th></tr>
                <tr><td>HTML:       </td><td><code>[A-Za-z][A-Za-z0-9_:.-]*</code></td></tr>
                <tr><td>CSS:        </td><td><code>-?[_a-zA-Z]+[_a-zA-Z0-9-]*</code></td></tr>
                <tr><td>Combined:   </td><td><code>[A-Za-z][A-Za-z0-9_-]*</code></td></tr>
            </table>
        </xd:detail>
        <xd:param name="node">The node for which the stable id is generated.</xd:param>
    </xd:doc>

    <xsl:function name="f:generate-id" as="xs:string">
        <xsl:param name="node" as="node()"/>

        <xsl:variable name="first" select="$node/ancestor-or-self::*[@id][1]"/>
        <xsl:variable name="baseid" select="if ($first) then $first/@id else 'ROOT'"/>
        <xsl:variable name="name" select="local-name($node)"/>
        <xsl:variable name="count" select="count($first//*[local-name() = $name] except $node/following::*[local-name() = $name])"/>
        <xsl:variable name="id" select="concat($baseid, '_', $name, '_', $count)"/>

        <xsl:message>Generated ID: <xsl:value-of select="$id"/>.</xsl:message>
        <xsl:value-of select="$id"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate an <code>id</code>-value.</xd:short>
        <xd:detail>
            <p>Generate an <code>id</code>-value for a node (by default the current node).</p>
            <p>The generated id will re-use the existing <code>id</code> attribute if present, or use the <code>generate-id()</code> function otherwise.
            Such generated id's will be prefixed with the letter 'x'</p>
        </xd:detail>
        <xd:param name="node">The node for which the <code>id</code>-value is generated.</xd:param>
        <xd:param name="position" type="string">A value appended after the generated <code>id</code>.</xd:param>
    </xd:doc>

    <xsl:template name="generate-id-for">
        <xsl:param name="node" select="." as="element()"/>
        <xsl:param name="position"/>

        <xsl:choose>
            <xsl:when test="$node/@id">
                <!-- Verify the id is valid for use in HTML and CSS 
                <xsl:if test="not(matches($node/@id,'^[A-Za-z][A-Za-z0-9_-]*$'))">
                    <xsl:message terminate="no">WARNING: Source contains an id [<xsl:value-of select="$node/@id"/>] that may cause problems in CSS.</xsl:message>
                </xsl:if>-->
                <xsl:value-of select="$node/@id"/>
            </xsl:when>
            <xsl:otherwise>x<xsl:value-of select="generate-id($node)"/></xsl:otherwise>
        </xsl:choose>

        <xsl:if test="$position">-<xsl:value-of select="$position"/></xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:short>Generate a <code>href</code>-attribute.</xd:short>
        <xd:detail>Generate a <code>href</code>-attribute to refer to a target element.</xd:detail>
        <xd:param name="target">The node the <code>href</code> will point to. Default: the current node.</xd:param>
    </xd:doc>

    <xsl:template name="generate-href-attribute">
        <xsl:param name="target" select="." as="element()"/>

        <xsl:attribute name="href">
            <xsl:call-template name="generate-href">
                <xsl:with-param name="target" select="$target"/>
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>

    <xd:doc>
        <xd:short>Generate a <code>href</code>-attribute for footnotes.</xd:short>
        <xd:detail>Generate a <code>href</code>-attribute when referring to footnotes.
        In the HTML set of utilities this is the same as <code>generate-href-attribute</code>
        but is included because in the ePub version, these need to be handled in
        a special way.</xd:detail>
        <xd:param name="target">The node the <code>href</code> will point to. Default: the current node.</xd:param>
    </xd:doc>

    <xsl:template name="generate-footnote-href-attribute">
        <xsl:param name="target" select="." as="element()"/>

        <xsl:attribute name="href">
            <xsl:call-template name="generate-footnote-href">
                <xsl:with-param name="target" select="$target"/>
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="generate-xref-table-href-attribute">
        <xsl:param name="target" select="." as="element()"/>

        <xsl:attribute name="href">
            <xsl:call-template name="generate-xref-table-href">
                <xsl:with-param name="target" select="$target"/>
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>

    <!--====================================================================-->
    <!-- Close and (re-)open paragraphs -->

    <xd:doc>
        <xd:short>Close a <code>p</code>-element in the output.</xd:short>
        <xd:detail><p>To accomodate the differences between the TEI and HTML paragraph model,
        we sometimes need to close (and reopen) paragraphs, as various elements
        are not allowed inside <code>p</code>-elements in HTML.</p>
        
        <p>The following cases need to be taken into account:</p>
        
        <ul>
            <li>We use the variable <code>$p.element</code> but it is not set the value <code>'p'</code></li>
            <li>We are actually inside a <code>p</code> element.</li>
            <li>We do not locally override the variable <code>$p.element</code>, for example when we need to nest special elements
            in a <code>p</code> element (see template handle-paragraph in block.xsl).</li>
        </ul>
        
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:needsclosepar" as="xs:boolean">
        <xsl:param name="element" as="element()"/>

        <xsl:variable name="output_p" select="$p.element = 'p'" as="xs:boolean"/>
        <xsl:variable name="parent_p" select="$element/parent::p or $element/parent::note" as="xs:boolean"/>
        <xsl:variable name="parent_does_not_contain_ditto" select="not($element/parent::p[.//ditto] or $element/parent::note[.//ditto])" as="xs:boolean"/>

        <xsl:value-of select="$output_p and $parent_p and $parent_does_not_contain_ditto"/>
    </xsl:function>

    <xsl:template name="closepar">
        <!-- insert </p> to close current paragraph as tables in paragraphs are illegal in HTML -->
        <xsl:if test="f:needsclosepar(.)">
            <xsl:text disable-output-escaping="yes">&lt;/p&gt;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xd:doc>
        <xd:short>Re-open a <code>p</code>-element in the output.</xd:short>
        <xd:detail>Re-open a previously closed <code>p</code>-element in the output.
        This generates an extra <code>p</code>-element in the output.</xd:detail>
    </xd:doc>

    <xsl:template name="reopenpar">
        <xsl:if test="f:needsclosepar(.)">
            <xsl:text disable-output-escaping="yes">&lt;p class="par"&gt;</xsl:text>
        </xsl:if>
    </xsl:template>

    <!--====================================================================-->
    <!-- Language tagging -->

    <xd:doc>
        <xd:short>Generate a lang attribute.</xd:short>
        <xd:detail>Generate a lang attribute. Depending on the output method (HTML or XML), 
        either the <code>lang</code> or the <code>xml:lang</code> attribute will be set on
        the output element if a lang attribute is present in the source.</xd:detail>
    </xd:doc>

    <xsl:template name="set-lang-attribute">
        <xsl:param name="lang" select="@lang" as="xs:string?"/>

        <xsl:if test="$lang">
            <xsl:choose>
                <xsl:when test="$outputmethod = 'xml'">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="f:fix-lang($lang)"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="lang"><xsl:value-of select="f:fix-lang($lang)"/></xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Normalize a language attribute.</xd:short>
        <xd:detail>Normalize language attributes used in the output to match
        valid language codes (see http://tools.ietf.org/html/rfc5646).</xd:detail>
    </xd:doc>

    <xsl:function name="f:fix-lang" as="xs:string">
        <xsl:param name="lang" as="xs:string"/>

        <xsl:choose>
            <!-- Strip endings with -x-..., such as in la-x-bio -->
            <xsl:when test="matches($lang, '^[a-z]{2}-x-')">
                <xsl:value-of select="substring($lang, 1, 2)"/>
            </xsl:when>
            <!-- Strip endings with -1900, such as in nl-1900 -->
            <xsl:when test="matches($lang, '^[a-z]{2}-\d{4}')">
                <xsl:value-of select="substring($lang, 1, 2)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$lang"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <!--====================================================================-->
    <!-- Shortcut for both id and language tagging -->

    <xd:doc>
        <xd:short>Generate both a lang and an id attribute.</xd:short>
        <xd:detail> </xd:detail>
    </xd:doc>

    <xsl:template name="set-lang-id-attributes">
        <xsl:call-template name="generate-id-attribute"/>
        <xsl:call-template name="set-lang-attribute"/>
    </xsl:template>

    <!--====================================================================-->
    <!-- Generate labels for heads in the correct language -->

    <xd:doc>
        <xd:short>Translate the <code>type</code>-attribute of a division.</xd:short>
        <xd:detail>
            <p>Translate the <code>type</code>-attribute of a division to a string in the currently active language.</p>
        </xd:detail>
        <xd:param name="type" type="string">The value of the <code>type</code>-attribute.</xd:param>
    </xd:doc>

    <xsl:function name="f:translate-div-type" as="xs:string">
        <xsl:param name="type" as="xs:string"/>
        <xsl:variable name="type" select="lower-case($type)"/>

        <xsl:choose>
            <xsl:when test="$type=''"><xsl:value-of select="''"/></xsl:when>
            <xsl:when test="$type='appendix'"><xsl:value-of select="f:message('msgAppendix')"/></xsl:when>
            <xsl:when test="$type='chapter'"><xsl:value-of select="f:message('msgChapter')"/></xsl:when>
            <xsl:when test="$type='part'"><xsl:value-of select="f:message('msgPart')"/></xsl:when>
            <xsl:when test="$type='book'"><xsl:value-of select="f:message('msgBook')"/></xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no">WARNING: Division's type attribute [<xsl:value-of select="$type"/>] not handled correctly in translate-div-type.</xsl:message>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xd:doc>
        <xd:short>Get the current UTC-time in a string.</xd:short>
        <xd:detail>
            <p>Get the current UTC-time in a string, format "YYYY-MM-DDThh:mm:ssZ"</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:utc-timestamp" as="xs:string">
        <xsl:variable name="utc-timestamp" select="adjust-dateTime-to-timezone(current-dateTime(), xs:dayTimeDuration('PT0H'))"/>
        <xsl:value-of select="format-dateTime($utc-timestamp, '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine a string has a valid value.</xd:short>
        <xd:detail>
            <p>Determine a string has a valid value, that is, not null, empty or '#####'</p>
        </xd:detail>
        <xd:param name="value" type="string">The value to be tested.</xd:param>
    </xd:doc>

    <xsl:function name="f:isValid" as="xs:boolean">
        <xsl:param name="value" as="xs:string?"/>
        <xsl:sequence select="$value and not($value = '' or $value = '#####')"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine whether a rendition ladder contains a certain value.</xd:short>
        <xd:detail>
            <p>Determine whether a rendition ladder contains a certain value. This takes care of handling the case where a key is a substring of another key.</p>
        </xd:detail>
        <xd:param name="rend">The rendition ladder to be tested.</xd:param>
        <xd:param name="key">The key to look for.</xd:param>
    </xd:doc>

    <xsl:function name="f:has-rend-value" as="xs:boolean">
        <xsl:param name="rend" as="xs:string?"/>
        <xsl:param name="key" as="xs:string"/>

        <xsl:value-of select="matches($rend, concat('(^|\W)', $key, '\(.+?\)'), 'i')"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Find the value for a key in a rendition ladder.</xd:short>
        <xd:detail>
            <p>Find the value for a key in a rendition ladder. This takes care of handling the case where a key is a substring of another key.
            If the rendition ladder is empty or doesn't contain the key, the result will be an empty string.</p>
        </xd:detail>
        <xd:param name="rend">The rendition ladder to be tested.</xd:param>
        <xd:param name="key">The key to find the value for. This should be a string matching <code>/[a-z0-9-]+/</code>, as otherwise the regular expression constructed from it will fail.</xd:param>
    </xd:doc>

    <xsl:function name="f:rend-value" as="xs:string">
        <xsl:param name="rend" as="xs:string?"/>
        <xsl:param name="key" as="xs:string"/>

        <xsl:variable name="regex" select="concat('(^|\W)', $key, '\((.+?)\)')"/>

        <xsl:variable name="result">
            <xsl:choose>
                <xsl:when test="not($rend)"/>
                <xsl:otherwise>
                    <xsl:analyze-string select="$rend" regex="{$regex}" flags="i">
                        <xsl:matching-substring>
                            <xsl:value-of select="regex-group(2)"/>
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="$result"/>
    </xsl:function>

</xsl:stylesheet>
