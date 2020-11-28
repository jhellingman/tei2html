<?xml version="1.0" encoding="iso-8859-1" ?>
<!DOCTYPE xsl:stylesheet [

    <!ENTITY deg        "&#176;">
    <!ENTITY ldquo      "&#x201C;">
    <!ENTITY lsquo      "&#x2018;">
    <!ENTITY rdquo      "&#x201D;">
    <!ENTITY rsquo      "&#x2019;">
    <!ENTITY raquo      "&#187;">
    <!ENTITY laquo      "&#171;">
    <!ENTITY bdquo      "&#8222;">
    <!ENTITY not        "&#x00AC;">

]>

<xsl:stylesheet version="3.0"
    xmlns:f="urn:stylesheet-functions"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f xd xhtml xs">

    <xd:doc type="stylesheet">
        <xd:short>TEI stylesheet to handle configurations.</xd:short>
        <xd:detail>This stylesheet is used to handle configurable options in the tei2html stylesheets.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2020, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xd:doc type="string">Name of custom configuration file.</xd:doc>
    <xsl:param name="configurationFile"/>

    <xd:doc type="string">Custom configuration (if available read from file else empty).</xd:doc>
    <xsl:variable name="custom-configuration" select="if ($configurationFile) then document($configurationFile, /) else $empty-configuration"/>

    <xsl:variable name="empty-configuration">
        <tei2html.config/>
    </xsl:variable>

    <xd:doc>
        <xd:short>The default configuration.</xd:short>
        <xd:detail>
            <p>The contents of this variable follow the structure for configuration files that
            can be used with documents.</p>
        </xd:detail>
    </xd:doc>

    <xsl:variable name="default-configuration">
        <tei2html.config>
            <debug>false</debug>                                            <!-- Use debug mode. -->            
            <logLevel>INFO WARNING ERROR DEBUG</logLevel>                   <!-- Log levels: DEBUG, INFO, WARNING, ERROR -->

            <debug.facsimile>false</debug.facsimile>

            <language>en-US</language>                                      <!-- Main language of text (if not specified explicitly) -->
            <defaultlanguage>en-US</defaultlanguage>                        <!-- Default language for localization -->

            <lb.preserve>true</lb.preserve>                                 <!-- Preserve linebreaks indicate with the lb element. -->
            <lb.hyphen.remove>false</lb.hyphen.remove>                      <!-- Remove hyphens before line-breaks. -->
            <lb.removable.hyphen>&not;</lb.removable.hyphen>                <!-- Character used for removable hyphen before line-break (DTA convention). -->
            <lb.hyphen>-</lb.hyphen>                                        <!-- Character used for non-removable hyphen before line-break. -->

            <toc.numberEntries>true</toc.numberEntries>                     <!-- Provide numbers with TOC entries. -->
            <toc.defaultEntries>false</toc.defaultEntries>                  <!-- Use generic heads in entries in the TOC, if no head is present -->

            <pg.includeHeaders>false</pg.includeHeaders>                    <!-- Include Project Gutenberg headers and footers. -->
            <pg.includeComments>false</pg.includeComments>                  <!-- Include references to Project Gutenberg in comments. -->

            <showParagraphNumbers>false</showParagraphNumbers>              <!-- Output paragraph numbers, using the value of the @n attribute. -->
            <includeAlignedDivisions>true</includeAlignedDivisions>         <!-- Include divisions indicated by "align-with-document()" -->
            <useRegularizedUnits>false</useRegularizedUnits>                <!-- Use the regularized units specified in the measure-tag. (false: both are shown, the original in the text, the regularized units in a
                                                                                 pop-up; true: regularized in text, original in pop-up) -->
            <outputExternalLinks>always</outputExternalLinks>               <!-- Generate external links, possible values: always | never | colophon -->
            <outputExternalLinksTable>false</outputExternalLinksTable>      <!-- Place external links in a separate table in the colophon. -->

            <punctuation.hanging>false</punctuation.hanging>                <!-- Use hanging punctuation (by generating the relevant CSS classes). -->

            <ditto.enable>true</ditto.enable>                               <!-- Use ditto marks in ditto (deprecated) or seg[@copyOf] elements. -->
            <ditto.mark>,,</ditto.mark>                                     <!-- The symbol to use as a ditto mark. May also be overridden by rend attribute ditto-mark() -->
            <ditto.repeat>word</ditto.repeat>                               <!-- How often to use a ditto mark, possible values: word | segment. May also be overridden by rend attribute ditto-repeat() -->

            <pageNumbers.show>true</pageNumbers.show>                       <!-- Show page numbers in the right margin -->
            <pageNumbers.before>[</pageNumbers.before>                      <!-- String to place before the page number in the right margin -->
            <pageNumbers.after>]</pageNumbers.after>                        <!-- String to place after the page number in the right margin -->

            <facsimile.enable>false</facsimile.enable>                      <!-- Output section with and links to facsimile images if required information is present. -->
            <facsimile.wrapper.enable>true</facsimile.wrapper.enable>       <!-- Generate HTML wrapper files for the images, and link to these instead of to the image. -->
            <facsimile.path>page-images</facsimile.path>                    <!-- Path where the HTML wrapper files will be generated. -->
            <facsimile.target></facsimile.target>                           <!-- Value of the target attribute of generated links in HTML (leave empty for default; _blank, _top, _parent, _self). -->

            <notes.foot.returnArrow>true</notes.foot.returnArrow>           <!-- Place a small up-arrow at the end of a footnote to return to the source location in the text. -->
            <notes.apparatus.textMarker>&deg;</notes.apparatus.textMarker>  <!-- Note marker used with text-critical notes (coded with place=apparatus) used at location in text. -->
            <notes.apparatus.noteMarker>&deg;</notes.apparatus.noteMarker>  <!-- Note marker used with text-critical notes (coded with place=apparatus) used before note, to return to text. -->
            <notes.apparatus.format>block</notes.apparatus.format>          <!-- How to format text-critical notes: as separate paragraphs or as a single block. Possible values: paragraphs | block -->

            <images.path></images.path>                                     <!-- Prefix of path to images, relative to HTML file -->
            <images.include>true</images.include>                           <!-- Include images in the generated output. -->
            <images.requireInfo>true</images.requireInfo>                   <!-- Require image-info to be present for an image (otherwise they won't be included in output) [TODO]. -->
            <images.scale>1.0</images.scale>                                <!-- Image scale factor: 1.0 is normal size; 0.5 is half size; 2.0 is double size. -->
            <images.maxSize>256</images.maxSize>                            <!-- Warn if image is large than this number of kilobytes. -->
            <images.maxWidth>720</images.maxWidth>                          <!-- Warn if image is wider than this number of pixels. -->
            <images.maxHeight>720</images.maxHeight>                        <!-- Warn if image is taller than this number of pixels. -->

            <text.parentheses>()[]{}</text.parentheses>                     <!-- Pairs of parentheses, first opening, then closing -->
            <text.quotes>&ldquo;&rdquo;&lsquo;&rsquo;&laquo;&raquo;&bdquo;&rdquo;</text.quotes> <!-- Pairs of quotation marks, first opening, then closing -->
            <text.curlyApos>true</text.curlyApos>                           <!-- Replace a plain apostrophe (') with a right single quote. -->
            <text.spaceQuotes>true</text.spaceQuotes>                       <!-- Insert a hair space between consecutive quotation marks. -->
            <text.useEllipses>true</text.useEllipses>                       <!-- Replace three consecutive periods with an ellipsis character. -->
            <text.abbr>i.e.; I.e.; e.g.; E.g.; A.D.; B.C.; P.M.; A.M.</text.abbr> <!-- Common abbreviations, list separated by semi-colons. -->

            <q.insertQuotes>false</q.insertQuotes>                          <!-- Insert quotation marks around <q> markup based on first two pairs in setting <text.quotes> -->
            <q.asDiv>true</q.asDiv>                                         <!-- Render the <q> element with a div if true, as a span otherwise. -->

            <beta.convert>false</beta.convert>                              <!-- Interprete beta-codes if the language is classical Greek (i.e., @xml:lang="grc"). -->
            <beta.caseSensitive>false</beta.caseSensitive>                  <!-- Beta-code is case sensitive (i.e., not using the * notation for capital letters) -->

            <css.stylesheet>style/arctic.css</css.stylesheet>               <!-- Default CSS stylesheet(s) to include; these are distributed with tei2html in the style directory. -->
            <css.useCommon>true</css.useCommon>                             <!-- Use the build-in stylesheets (for screen) -->
            <css.useCommonPrint>true</css.useCommonPrint>                   <!-- Use the build-in stylesheets (for print media) -->
            <css.inline>true</css.inline>                                   <!-- use an inline (embedded in HTML) stylesheet; ignored for ePub. -->
            <css.support>2</css.support>                                    <!-- Level of support for CSS: used to filter out newer features. Possible values: 2 | 3 -->
            <css.frakturFont>Walbaum-Fraktur</css.frakturFont>              <!-- The font to use when font(fraktur) is specified. -->
            <css.blackletterFont>UnifrakturMaguntia</css.blackletterFont>   <!-- The font to use when font(blackletter) is specified. -->

            <rendition.id.prefix></rendition.id.prefix>                     <!-- Prefix used for rendition IDs. -->

            <colophon.showEditDistance>true</colophon.showEditDistance>     <!-- Show the Levenshtein edit distance in the list of corrections made in the colophon. -->
            <colophon.showCorrections>true</colophon.showCorrections>       <!-- Show a list of corrections in the colophon. -->
            <colophon.showAbbreviations>true</colophon.showAbbreviations>   <!-- Show a list of abbreviations in the colophon. -->
            <colophon.showExternalReferences>true</colophon.showExternalReferences>   <!-- Show a section on external references in the colophon. -->
            <colophon.maxCorrectionCount>20</colophon.maxCorrectionCount>   <!-- Maximum number of indentical corrections that will be listed individually in the list of corrections. -->

            <math.decimalSeparator>.</math.decimalSeparator>
            <math.thousandsSeparator>,</math.thousandsSeparator>
            <math.numberPattern>^[0-9]{1,3}(,[0-9]{3})*(\.[0-9]+)?$</math.numberPattern>
            <math.label.position>right</math.label.position>
            <math.label.before>(</math.label.before>
            <math.label.after>)</math.label.after>
            <math.keepTexInComment>true</math.keepTexInComment>
    
            <math.mathJax.format>SVG+IMG</math.mathJax.format>                      <!-- Options: MathJax; MML; SVG; SVG+IMG -->
            <math.mathJax.configuration>TeX-MML-AM_SVG</math.mathJax.configuration> <!-- Options for MathJax format, e.g.: TeX-MML-AM_SVG TeX-MML-AM_CHTML, see https://docs.mathjax.org/en/latest/config-files.html#common-configurations -->

            <!-- Output format specific settings: these override the general settings defined above for a specific output format. Supported formats: "html" and "epub". -->
            <output format="html">
                <useMouseOverPopups>true</useMouseOverPopups>           <!-- Use mouse-over pop-ups on various items (links, etc) -->
            </output>
            <output format="epub">
                <useMouseOverPopups>false</useMouseOverPopups>
                <outputExternalLinks>always</outputExternalLinks>
                <outputExternalLinksTable>true</outputExternalLinksTable>

                <pageNumbers.show>false</pageNumbers.show>

                <math.mathJax.format>MML</math.mathJax.format>
            </output>
        </tei2html.config>
    </xsl:variable>


    <xd:doc>
        <xd:short>Combine the custom and default configuration into a single map for easy access.</xd:short>
        <xd:detail>
            <p>Combine the file-specific and default configuration into a map. The configuration file is specified in the variable <code>$configurationFile</code> 
            (default: <code>tei2html.config</code>).</p>
        </xd:detail>
    </xd:doc>

    <xsl:variable name="configuration-map" as="map(xs:string, xs:string)" 
        select="f:merge-configuration(
                    f:convert-configuration($default-configuration/tei2html.config),
                    f:convert-configuration($custom-configuration/tei2html.config))"/>

    <xsl:function name="f:merge-configuration" as="map(xs:string, xs:string)">
        <xsl:param name="default" as="map(xs:string, xs:string)"/>
        <xsl:param name="override" as="map(xs:string, xs:string)"/>

        <xsl:for-each select="map:keys($default)">
            <xsl:variable name="key" select="." as="xs:string"/>
            <xsl:if test="$default($key) = $override($key)">
                <xsl:message expand-text="true">INFO: Overriden configuration value of key '{$key}' same as default.</xsl:message>
            </xsl:if>
        </xsl:for-each>

        <xsl:sequence select="map:merge(($default, $override), map{'duplicates' : 'use-last'})"/>
    </xsl:function>

    <xd:doc>
        <xd:short>Get a value from the configuration.</xd:short>
        <xd:detail>
            <p>Get a value from the configuration-map. First try to get it from a local file as specified in the variable <code>$configurationFile</code> (default: <code>tei2html.config</code>), and if that fails, obtain
            the value from the default configuration included in this stylesheet. If that too fails, a message is logged to the console.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:get-setting" as="xs:string">
        <xsl:param name="key" as="xs:string"/>
        <xsl:sequence select="if (map:contains($configuration-map, $key)) then $configuration-map($key) else ''"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Get a boolean value from the configuration.</xd:short>
    </xd:doc>

    <xsl:function name="f:is-set" as="xs:boolean">
        <xsl:param name="key" as="xs:string"/>
        <xsl:sequence select="f:get-setting($key) = 'true'"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Combine configuration into a single map with the currently active values.</xd:short>
        <xd:detail>
            <p>Combine the generic and format-specific configuration into a single map, giving the format-specific configuration preference if it is set.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:convert-configuration" as="map(xs:string, xs:string)">
        <xsl:param name="configuration" as="element()"/>

        <xsl:variable name="base" as="map(xs:string, xs:string)">
            <xsl:map>
                <xsl:for-each select="$configuration/*[not(self::output)]">
                    <xsl:map-entry key="local-name(.)" select="string(.)"/>
                </xsl:for-each>
            </xsl:map>
        </xsl:variable>

        <xsl:variable name="specific" as="map(xs:string, xs:string)">
            <xsl:map>
                <xsl:for-each select="$configuration/output[@format=$outputformat]/*">
                    <xsl:map-entry key="local-name(.)" select="string(.)"/>
                </xsl:for-each>
            </xsl:map>
        </xsl:variable>

        <xsl:sequence select="map:merge(($base, $specific), map{'duplicates' : 'use-last'})"/>
    </xsl:function>

</xsl:stylesheet>
