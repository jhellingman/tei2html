<xsl:stylesheet 
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="f fn xd xs"
    >

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to produce a KWIC from a TEI document</xd:short>
        <xd:detail>This stylesheet produces a KWIC from a TEI document. It shows all occurances of all words
        in the document in their context in alphabetical order. The output can become rather big, as a rule-of-thumb, 
        30 to 40 times the size of the original. Furthermore, the processing time can be considerable.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:output omit-xml-declaration="yes" indent="yes"/>


    <xd:doc>
        <xd:short>The keyword to generate a KWIC for.</xd:short>
        <xd:detail>The keyword to generate a KWIC for. If omitted, a KWIC will be generated for all words 
        in the document. TODO</xd:detail>
    </xd:doc>

    <xsl:param name="keyword" select="''"/>


    <xd:doc>
        <xd:short>The lenght of the context to show.</xd:short>
        <xd:detail>The lenght of the context to show. This counts both words and non-words (spaces and punctuation marks).
        The preceding and following contexts are counted separately.</xd:detail>
    </xd:doc>

    <xsl:param name="contextSize" select="16"/>


    <xd:doc>
        <xd:short>Generate the HTML output.</xd:short>
        <xd:detail>Generate the HTML output.</xd:detail>
    </xd:doc>

    <xsl:template match="/">
        <head>
            <title>KWIC for <xsl:value-of select="TEI.2/teiHeader/fileDesc/titleStmt/title"/></title>
            <style>

                table
                {
                    margin-left: auto; 
                    margin-right: auto;
                }

                .tag
                {
                    font-size: xx-small;
                    color: grey;
                }

                .cnt
                {
                    font-size: small;
                    color: grey;
                }

                .pre, .pn
                {
                    text-align: right;
                }

                th.ph
                {
                    font-size: small;
                    color: gray;
                }

                .match
                {
                    font-weight: bold;
                }

            </style>
        </head>
        <html>
            <h1>KWIC for <xsl:value-of select="TEI.2/teiHeader/fileDesc/titleStmt/title"/></h1>

            <xsl:call-template name="build-kwic"/>
        </html>
    </xsl:template>


    <xd:doc mode="words">
        <xd:short>Mode used to collect a word-list.</xd:short>
        <xd:detail>Words are collected by splitting text into words with analyze-string at the text level.</xd:detail>
    </xd:doc>

    <xd:doc mode="segments">
        <xd:short>Mode used to collect segments.</xd:short>
        <xd:detail>The generic segment-element will replace a range of higher-level structural elements, such as paragraphs.</xd:detail>
    </xd:doc>

    <xd:doc mode="flatten-segments">
        <xd:short>Mode used to flatten segments.</xd:short>
        <xd:detail>Segments are flattened by grouping segment and non-segment elements; the non-segments will be wrapped into a new segment, and the contained segments will be handled recursively.</xd:detail>
    </xd:doc>

    <xd:doc>
        <xd:short>Generate the KWIC</xd:short>
        <xd:detail>Generate the KWIC. This template build a KWIC in the following steps.
        <ol>
            <li>Collect all words that appear in the document.</li>
            <li>Collect all segments in the document, to provide meaningful contexts.</li>
            <li>Flatten the segments.</li>
            <li>Loop over the list of words, and find matches for each word.</li>
        </ol>
        </xd:detail>
    </xd:doc>

    <xsl:template name="build-kwic">

        <!-- Collect all words with their language in a variable -->
        <xsl:variable name="words">
            <words>
                <xsl:apply-templates mode="words"/>
            </words>
        </xsl:variable>

        <!-- Collect all segments -->
        <xsl:variable name="segments">
            <segment>
                <xsl:apply-templates mode="segments"/>
            </segment>
        </xsl:variable>

        <!-- Flatten segments -->
        <xsl:variable name="segments">
            <segments>
                <xsl:apply-templates mode="flatten-segments" select="$segments"/>
            </segments>
        </xsl:variable>

        <!--
        <xsl:result-document 
                doctype-public=""
                doctype-system=""
                href="kwic-segments.xml"
                method="xml" 
                indent="yes"
                encoding="UTF-8">
            <xsl:message terminate="no">Info: generated file: kwic-segments.xml.</xsl:message>
            <xsl:copy-of select="$segments"/>
        </xsl:result-document>
        -->

        <xsl:for-each-group select="$words/words/w" group-by="@form">
            <xsl:sort select="(current-group()[1])/@form" order="ascending"/>
            <xsl:if test="fn:matches(@form, '^[\p{L}-]+$')">
                <xsl:variable name="keyword" select="(current-group()[1])/@form"/>
                <h2><xsl:value-of select="current-group()[1]"/><xsl:text> </xsl:text><span class="cnt"><xsl:value-of select="count(current-group())"/></span></h2>

                <xsl:call-template name="report-matches">
                    <xsl:with-param name="segments" select="$segments"/>
                    <xsl:with-param name="keyword" select="$keyword"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>


    <xd:doc>
        <xd:short>Flatten segments.</xd:short>
        <xd:detail>Flatten segments, that is, make sure segments are not nested.</xd:detail>
    </xd:doc>

    <xsl:template mode="flatten-segments" match="segment">
        <xsl:for-each-group select="node()" group-adjacent="not(self::segment)">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <!-- Sequence of non-segment elements -->
                    <segment>
                        <xsl:copy-of select="current-group()"/>
                    </segment>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Sequence of segment elements -->
                    <xsl:for-each select="current-group()">
                        <xsl:apply-templates select="." mode="flatten-segments"/>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>


    <xd:doc mode="output">
        <xd:short>Mode used to output the matches.</xd:short>
        <xd:detail>This produces the HTML to report the matches found.</xd:detail>
    </xd:doc>

    <xd:doc>
        <xd:short>Find and report matches.</xd:short>
        <xd:detail>Find and report matches. The matches are first collected in a variable, using the mode <code>kwic</code>, and then reported, using the mode <code>output</code>.</xd:detail>
        <xd:param name="segments">The document being processed, split in to segments.</xd:param>
        <xd:param name="keyword">The keyword for which the KWIC is generated.</xd:param>
    </xd:doc>

    <xsl:template name="report-matches">
        <xsl:param name="segments"/>
        <xsl:param name="keyword"/>

        <xsl:variable name="matches">
            <matches>
                <xsl:apply-templates mode="kwic" select="$segments//w">
                    <xsl:with-param name="keyword" select="$keyword"/>
                </xsl:apply-templates>
            </matches>
        </xsl:variable>

        <xsl:apply-templates mode="output" select="$matches"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Output matches.</xd:short>
        <xd:detail>Output an HTML table for the matches.</xd:detail>
    </xd:doc>

    <xsl:template mode="output" match="matches">
        <table>
            <tr>
                <th/>
                <th/>
                <th/>
                <th class="pn">Page</th>
            </tr>

            <xsl:apply-templates mode="output">
                <xsl:sort select="fn:lower-case(f:strip_diacritics(following))" order="ascending"/>
            </xsl:apply-templates>
        </table>
    </xsl:template>


    <xd:doc>
        <xd:short>Output a match.</xd:short>
        <xd:detail>Output an HTML table-row for a match.</xd:detail>
    </xd:doc>

    <xsl:template mode="output" match="match">
        <tr>
            <td class="pre">
                <xsl:apply-templates mode="output" select="preceding"/>
            </td>
            <td class="match">
                <xsl:apply-templates mode="output" select="word"/>
            </td>
            <td class="post">
                <xsl:apply-templates mode="output" select="following"/>
            </td>
            <td class="pn">
                <xsl:value-of select="word/w/@page"/>
            </td>
        </tr>
    </xsl:template>


    <xd:doc>
        <xd:short>Output a word.</xd:short>
        <xd:detail></xd:detail>
    </xd:doc>

    <xsl:template mode="output" match="w">
        <xsl:value-of select="."/>
    </xsl:template>


    <xd:doc>
        <xd:short>Output a non-word.</xd:short>
        <xd:detail></xd:detail>
    </xd:doc>

    <xsl:template mode="output" match="nw">
        <xsl:value-of select="."/>
    </xsl:template>


    <xd:doc>
        <xd:short>Output a tag.</xd:short>
        <xd:detail></xd:detail>
    </xd:doc>

    <xsl:template mode="output" match="t">
        <span class="tag"><xsl:value-of select="@name"/></span>
    </xsl:template>


    <xd:doc mode="kwic">
        <xd:short>Mode used to find matches.</xd:short>
        <xd:detail>This traverses the segments, looking for matching words.</xd:detail>
    </xd:doc>

    <xd:doc>
        <xd:short>Find a match in a segment.</xd:short>
        <xd:detail>Find a match in a segment.</xd:detail>
    </xd:doc>

    <xsl:template mode="kwic" match="segment">
        <xsl:apply-templates mode="kwic" select="."/>
    </xsl:template>


    <xd:doc>
        <xd:short>Find a matching word.</xd:short>
        <xd:detail>Find a matching word, when a word is found, the preceding and following contexts are kept with the match.</xd:detail>
    </xd:doc>

    <xsl:template mode="kwic" match="w">
        <xsl:param name="keyword" required="yes"/>

        <xsl:if test="$keyword = @form">
            <match>
                <preceding><xsl:apply-templates mode="context" select="preceding-sibling::*[position() &lt; $contextSize]"/></preceding>
                <word><xsl:apply-templates mode="context" select="."/></word>
                <following><xsl:apply-templates mode="context" select="following-sibling::*[position() &lt; $contextSize]"/></following>
            </match>
        </xsl:if>
    </xsl:template>


    <xd:doc mode="context">
        <xd:short>Mode used to copy the context of a match.</xd:short>
        <xd:detail>Only used to copy preceding and following contexts when a match is found.</xd:detail>
    </xd:doc>

    <xd:doc>
        <xd:short>Copy matching words and non-words in the context.</xd:short>
        <xd:detail>Copy matching words and non-words in the context.</xd:detail>
    </xd:doc>

    <xsl:template mode="context" match="w|nw|t">
        <xsl:copy-of select="."/>
    </xsl:template>


    <xd:doc>
        <xd:short>Report word-usage.</xd:short>
        <xd:detail>Report word-usage, grouped by language and word-form.</xd:detail>
        <xd:param name="words">The node-tree with all the words to be reported.</xd:param>
    </xd:doc>

    <xsl:template name="report-usage">
        <xsl:param name="words" as="element()"/>
        <usage>
            <xsl:for-each-group select="$words/w" group-by="@xml:lang">
                <words xml:lang="{(current-group()[1])/@xml:lang}">
                    <xsl:for-each-group select="current-group()" group-by="@form">
                        <xsl:sort select="(current-group()[1])/@form" order="ascending"/>
                        <group>
                            <xsl:for-each-group select="current-group()" group-by=".">
                                <xsl:sort select="(current-group()[1])" order="ascending"/>
                                <word count="{count(current-group())}">
                                    <xsl:value-of select="current-group()[1]"/>
                                </word>
                            </xsl:for-each-group>
                        </group>
                    </xsl:for-each-group>
                </words>
            </xsl:for-each-group>
        </usage>
    </xsl:template>


    <xd:doc>
        <xd:short>Split a string into words.</xd:short>
        <xd:detail>Split a string into words, using a regular expression syntax.</xd:detail>
        <xd:param name="string">The string to be split in words.</xd:param>
    </xd:doc>

    <xsl:function name="f:words" as="xs:string*">
        <xsl:param name="string" as="xs:string"/>
        <xsl:analyze-string select="$string" regex="{'[\p{L}\p{N}\p{M}-]+'}">
            <xsl:matching-substring>
                <xsl:sequence select="."/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>


    <xd:doc>
        <xd:short>Remove diacritics from a string.</xd:short>
        <xd:detail>Remove diacritics form a string to produce a string suitable for sorting purposes. This function
        use the Unicode NFD normalization form to separate diacritics from the letters carrying them, and might
        result too much being removed in some scripts (in particular Indic scripts).</xd:detail>
        <xd:param name="string">The string to processed.</xd:param>
    </xd:doc>

    <xsl:function name="f:strip_diacritics" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:value-of select="fn:replace(fn:normalize-unicode($string, 'NFD'), '\p{M}', '')"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Ignore the TEI header.</xd:short>
        <xd:detail>Ignore the TEI header, as we are not interested in the words that appear there.</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="teiHeader"/>

    <xd:doc>
        <xd:short>Ignore notes.</xd:short>
        <xd:detail>Ignore notes. Notes will be lifted from their context, and handled separately.</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="note"/>


    <xd:doc mode="segment-notes">
        <xd:short>Mode used to lift notes out of their context.</xd:short>
        <xd:detail>Mode used to lift notes out of their context, into a separate context.</xd:detail>
    </xd:doc>

    <xd:doc>
        <xd:short>Segmentize the text.</xd:short>
        <xd:detail>Segmentize the text. Here we also handle the notes separately.</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="TEI.2/text">
        <xsl:apply-templates mode="segments"/>
        <xsl:apply-templates mode="segment-notes" select="//note"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Segmentize notes.</xd:short>
        <xd:detail>Segmentize notes. Special handling at this level only, can use mode <code>segments</code> for elements inside notes.</xd:detail>
    </xd:doc>

    <xsl:template mode="segment-notes" match="note">
        <segment>
            <xsl:apply-templates mode="segments"/>
        </segment>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle high-level structure.</xd:short>
        <xd:detail>Handle high-level structure. These are typically further divided in segments, so we need not introduce a segment for them.</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="front | back | body | div0 | div1 | div2 | div3 | div4 | div5 | div6 | lg | table | row">
        <xsl:apply-templates mode="segments"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle segment structure.</xd:short>
        <xd:detail>Introduce a segment for each of these elements that contain text.</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="p | head | cell | l | item | titlePage">
        <segment>
            <xsl:apply-templates mode="segments"/>
        </segment>
    </xsl:template>

    <xd:doc>
        <xd:short>Analyze text nodes.</xd:short>
        <xd:detail>Analyze text nodes of segments in the same way as we analyzed them when generating the word-list.</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="text()">
        <xsl:call-template name="analyze-text"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Do not collect words in the <code>teiHeader</code>.</xd:short>
        <xd:detail>For our analysis, we are not interested in the <code>teiHeader</code>.</xd:detail>
    </xd:doc>

    <xsl:template mode="words" match="teiHeader"/>


    <xd:doc>
        <xd:short>Ignore elements when collecting notes.</xd:short>
        <xd:detail>We are not interested in certain low level elements when analysing our text.</xd:detail>
    </xd:doc>

    <xsl:template mode="words" match="pb | hi | index">
        <xsl:apply-templates mode="words"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Replace paragraph boundaries with a pilcrow.</xd:short>
        <xd:detail>Replace paragraph boundaries with a pilcrow. (Intended to show these when not segmenting, currently not used.)</xd:detail>
    </xd:doc>

    <xsl:template mode="words" match="p">
        <t name="&#182;"/>
        <xsl:apply-templates mode="words"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Replace element boundaries with explicit tags.</xd:short>
        <xd:detail>Replace element boundaries with explicit tags. (Intended to show these when not segmenting, currently not used.)</xd:detail>
    </xd:doc>

    <xsl:template mode="words" match="*">
        <xsl:choose>
            <xsl:when test="normalize-space(.) = ''">
                <t name="&lt;{name()}/&gt;"/>
            </xsl:when>
            <xsl:otherwise>
                <t name="&lt;{name()}&gt;"/>
                <xsl:apply-templates mode="words"/>
                <t name="&lt;/{name()}&gt;"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Collect words in <code>w</code> elements.</xd:short>
        <xd:detail>Collect words in <code>w</code> elements. In this element, the normalized version is kept
        in the <code>@form</code> attribute, and the current language in the <code>@xml:lang</code> attribute.</xd:detail>
    </xd:doc>

    <xsl:template mode="words" match="text()">
        <xsl:call-template name="analyze-text"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Collect words in <code>w</code> elements.</xd:short>
        <xd:detail>Collect words in <code>w</code> elements. In this element, the normalized version is kept
        in the <code>@form</code> attribute, and the current language in the <code>@xml:lang</code> attribute.</xd:detail>
    </xd:doc>

    <xsl:template name="analyze-text">
        <xsl:variable name="lang" select="(ancestor-or-self::*/@lang|ancestor-or-self::*/@xml:lang)[last()]"/>
        <xsl:variable name="parent" select="name(ancestor-or-self::*[1])"/>
        <xsl:variable name="page" select="preceding::pb[1]/@n"/>

        <xsl:analyze-string select="." regex="{'[\p{L}\p{N}\p{M}-]+'}">
            <xsl:matching-substring>
                <w>
                    <xsl:attribute name="xml:lang" select="$lang"/>
                    <xsl:attribute name="parent" select="$parent"/>
                    <xsl:attribute name="page" select="$page"/>
                    <xsl:attribute name="form" select="fn:lower-case(f:strip_diacritics(.))"/>
                    <xsl:value-of select="."/>
                </w>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <nw>
                    <xsl:value-of select="."/>
                </nw>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

</xsl:stylesheet>
