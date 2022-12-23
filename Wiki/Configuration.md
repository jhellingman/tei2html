# Introduction #

Currently, there are several options to change the generated output. These can be configured by
using a file named `tei2html.config` in which various parameters can be set. If you add such a file to
the directory where you TEI file is located, the tei2html perl script will automatically pick it up.

It is only necessary to specify those items that differ from the default in your configuration file.

# Current Status #

The default configuration file is:

```xml
<tei2html.config>
    <debug>false</debug>                                            <!-- Use debug mode. -->
    <logLevel>INFO WARNING ERROR DEBUG</logLevel>                   <!-- Log levels: DEBUG, INFO, WARNING, ERROR -->

    <language>en-US</language>                                      <!-- Main language of text (if not specified explicitly) -->
    <defaultlanguage>en-US</defaultlanguage>                        <!-- Default language for localization -->

    <lb.preserve>true</lb.preserve>                                 <!-- Preserve linebreaks indicate with the lb element. -->
    <lb.hyphen.remove>false</lb.hyphen.remove>                      <!-- Remove hyphens before line-breaks. -->
    <lb.removable.hyphen>&not;</lb.removable.hyphen>                <!-- Character used for removable hyphen before line-break (DTA convention). -->
    <lb.hyphen>-</lb.hyphen>                                        <!-- Character used for non-removable hyphen before line-break. -->

    <defaultStylesheet>style/arctic.css</defaultStylesheet>         <!-- Stylesheet to include. -->
    <useCommonStylesheets>true</useCommonStylesheets>               <!-- Use the build-in stylesheets (for screen) -->
    <useCommonPrintStylesheets>true</useCommonPrintStylesheets>     <!-- Use the build-in stylesheets (for print media) -->
    <inlineStylesheet>true</inlineStylesheet>                       <!-- use an inline (embedded in HTML) stylesheet; ignored for ePub. -->
    <numberTocEntries>true</numberTocEntries>                       <!-- Provide numbers with TOC entries. -->
    <showParagraphNumbers>false</showParagraphNumbers>              <!-- Output paragraph numbers, using the value of the @n attribute. -->
    <includePGHeaders>false</includePGHeaders>                      <!-- Include Project Gutenberg headers and footers. -->
    <includePGComments>false</includePGComments>                    <!-- Include references to Project Gutenberg in comments. -->
    <includeAlignedDivisions>true</includeAlignedDivisions>         <!-- Include divisions indicated by "align-with-document()" -->
    <defaultTocEntries>false</defaultTocEntries>                    <!-- Use generic heads in entries in the TOC, if no head is present -->
    <useRegularizedUnits>false</useRegularizedUnits>                <!-- Use the regularized units specified in the measure-tag. (false: both are shown, the original in the text, the regularized units in a
                                                                         pop-up; true: regularized in text, original in pop-up) -->
    <outputExternalLinks>always</outputExternalLinks>               <!-- Generate external links, possible values: always | never | colophon -->
    <outputExternalLinksTable>false</outputExternalLinksTable>      <!-- Place external links in a separate table in the colophon. -->
    <useHangingPunctuation>false</useHangingPunctuation>            <!-- Use hanging punctuation (by generating the relevant CSS classes). -->
    <useFootnoteReturnArrow>true</useFootnoteReturnArrow>           <!-- Place a small up-arrow at the end of a footnote to return to the source location in the text. -->

    <ditto.enable>true</ditto.enable>                               <!-- Use ditto marks in ditto or seg[@copyOf] elements. -->
    <ditto.mark>,,</ditto.mark>                                     <!-- The symbol to use as a ditto mark. May also be overridden by rend attribute ditto-mark() -->
    <ditto.repeat>word</ditto.repeat>                               <!-- TODO: How often to use a ditto mark, possible values: word | segment. May also be overridden by rend attribute ditto-repeat() -->

    <pageNumbers.show>true</pageNumbers.show>                       <!-- Show page numbers in the right margin -->
    <pageNumbers.before>[</pageNumbers.before>                      <!-- String to place before the page number in the right margin -->
    <pageNumbers.after>]</pageNumbers.after>                        <!-- String to place after the page number in the right margin -->

    <facsimile.enable>false</facsimile.enable>                      <!-- Output section with and links to facsimile images if required information is present. -->
    <facsimile.wrapper.enable>true</facsimile.wrapper.enable>       <!-- Generate HTML wrapper files for the images, and link to these. -->
    <facsimile.path>page-images</facsimile.path>                    <!-- Path where the wrapper files will be generated. -->
    <facsimile.external>false</facsimile.external>                  <!-- TODO: Set to true if the URL points to an external location. -->
    <facsimile.target></facsimile.target>                           <!-- TODO: Value of the target attribute of generated URLs (leave empty for default; _blank, _top, _parent, _self). -->

    <notes.apparatus.textMarker>&deg;</notes.apparatus.textMarker>  <!-- Note marker used with text-critical notes (coded with place=apparatus) used at location in text. -->
    <notes.apparatus.noteMarker>&deg;</notes.apparatus.noteMarker>  <!-- Note marker used with text-critical notes (coded with place=apparatus) used before note, to return to text. -->
    <notes.apparatus.format>block</notes.apparatus.format>          <!-- How to format text-critical notes: as separate paragraphs or as a single block. Possible values: paragraphs | block -->

    <images.include>true</images.include>                           <!-- Include images in the generated output. -->
    <images.requireInfo>true</images.requireInfo>                   <!-- Require image-info to be present for an image (otherwise they won't be included in output) [TODO]. -->

    <text.parentheses>()[]{}</text.parentheses>                     <!-- Pairs of parentheses, first opening, then closing -->
    <text.quotes>&ldquo;&rdquo;&lsquo;&rsquo;&laquo;&raquo;&bdquo;&rdquo;</text.quotes> <!-- Pairs of quotation marks, first opening, then closing -->
    <text.insertQuotes>false</text.insertQuotes>                    <!-- Insert quotation marks around <q> markup [TODO] based on first four pairs in setting <text.quotes> -->
    <text.curlyApos>true</text.curlyApos>                           <!-- Replace a plain apostrophe (') with a right single quote. -->
    <text.spaceQuotes>true</text.spaceQuotes>                       <!-- Insert a hair space between consecutive quotation marks. -->
    <text.useEllipses>true</text.useEllipses>                       <!-- Replace three consecutive periods with an ellipsis character. -->
    <text.abbr>i.e.; I.e.; e.g.; E.g.; A.D.; B.C.; P.M.; A.M.</text.abbr> <!-- Common abbreviations, list separated by semi-colons. -->

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
```

This can also be found `configuration.xsl`.

# Future Ideas #

  * Use Mouseover pop-ups. (for showing corrections, etc.)
  * Include images (Y/N/All/Important)
  * Image path (`<path>`)
  * Footnote location (Page/Chapter/Work)
  * Generate colophon (Y/N)
  * Generate a table of contents (Front/Back/None)
  * Additional CSS stylesheets (`<name>`)
  * Generate marginal page-numbers (Y/N)
  * Generate links to page-images (Y/N)

# Things that can be handled via CSS #

  * Default table alignment (Left/Right/Center)
  * Default verse alignment (Left/Right/Center)