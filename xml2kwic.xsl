<!DOCTYPE xsl:stylesheet [

    <!ENTITY prime       "&#x2032;">
    <!ENTITY tcomma      "&#x02BB;">
    <!ENTITY startMark   "&#xFF08;&#x2D35;">
    <!ENTITY endMark     "&#x2D35;&#xFF09;">

]>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:f="urn:stylesheet-functions"
    xmlns:s="http://gutenberg.ph/segments"
    xmlns:k="http://gutenberg.ph/kwic"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="f fn xd xs s k">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to produce a KWIC from a TEI document</xd:short>
        <xd:detail>This stylesheet produces a KWIC from a TEI document. It shows all occurrences of all words
        in the document in their context in alphabetical order. The output can become rather big, as a rule-of-thumb,
        30 to 40 times the size of the original. Furthermore, the processing time can be considerable.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011-2019, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:output
        doctype-public="-//W3C//DTD XHTML 1.1//EN"
        doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
        method="xml"
        encoding="utf-8"/>

    <xsl:include href="modules/segmentize.xsl"/>

    <xsl:param name="output-segments" select="false()"/>

    <xd:doc>
        <xd:short>The keyword(s) to generate a KWIC for.</xd:short>
        <xd:detail>The keyword(s) to generate a KWIC for. If omitted, a KWIC will be generated for all words
        in the document.</xd:detail>
    </xd:doc>

    <xsl:param name="keyword" select="''"/>

    <xd:doc>
        <xd:short>The language(s) to generate a KWIC for.</xd:short>
        <xd:detail>The language(s) to generate a KWIC for. If omitted, a KWIC will be generated for all languages
        in the document. Use ISO-639 codes separated by spaces.</xd:detail>
    </xd:doc>

    <xsl:param name="select-language" select="''"/>

    <xsl:variable name="select-language-sequence" select="tokenize($select-language, ' ')"/>

    <xsl:variable name="default-language" select="/*[self::TEI.2 or self::TEI]/@lang"/>


    <xsl:param name="case-sensitive" select="'false'" as="xs:string"/>

    <xsl:param name="use-normalized-form" select="'true'" as="xs:string"/>

    <xsl:param name="min-variant-count" select="1" as="xs:integer"/>


    <!-- Values: 'following' or 'preceding' -->
    <xsl:param name="sort-context" select="'following'"/>


    <xd:doc>
        <xd:short>Sort potentially mixed-up characters together.</xd:short>
        <xd:detail>Sort (sequences of) characters that are often mixed-up (such as b and h, or rn and m) together.
        The resulting KWIC will only include words that include the mixed-up characters and appear in at least two
        variants.</xd:detail>
    </xd:doc>

    <xsl:param name="mixup" select="''"/>

    <xsl:variable name="mixup-sequence" select="tokenize($mixup, ' ')"/>


    <xd:doc>
        <xd:short>The length of the context to show.</xd:short>
        <xd:detail>The length of the context to show. This counts both words and non-words (spaces and punctuation marks).
        The preceding and following contexts are counted separately.</xd:detail>
    </xd:doc>

    <xsl:param name="context-size" select="16"/>


    <xd:doc>
        <xd:short>The name of the file that contains stopwords.</xd:short>
    </xd:doc>

    <xsl:param name="stopword-file" select="'locale/stopwords.xml'" as="xs:string"/>

    <xsl:variable name="stopwords" as="map(xs:string, xs:string*)">
        <xsl:map>
            <xsl:for-each select="document($stopword-file)//words">
                <xsl:map-entry key="xs:string(@lang)" select="tokenize(., ' ')"/>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>


    <xd:doc>
        <xd:short>Determine whether a word is a stop-word.</xd:short>
        <xd:detail>Determine whether a word appears in the list of stop-words for a given language.</xd:detail>
        <xd:param name="word">The word to test.</xd:param>
        <xd:param name="lang">The (declared) language of the word (used to select the stop-word list).</xd:param>
    </xd:doc>

    <xsl:function name="f:is-stopword" as="xs:boolean">
        <xsl:param name="word" as="xs:string"/>
        <xsl:param name="lang" as="xs:string"/>

        <xsl:variable name="lang" select="if (not(exists($stopwords($lang))) and contains($lang, '-')) then substring-before($lang, '-') else $lang"/>
        <xsl:variable name="word" select="lower-case($word)"/>

        <xsl:sequence select="$stopwords($lang) = $word"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate the HTML output.</xd:short>
        <xd:detail>Generate the HTML output.</xd:detail>
    </xd:doc>

    <xsl:template match="/">
        <html>
            <head>
                <meta charset="UTF-8"/>
                <title>KWIC for <xsl:value-of select="*[self::TEI.2 or self::TEI]/teiHeader/fileDesc/titleStmt/title[not(@type) or @type='main']"/></title>
                <style>

                    table {
                        margin-left: auto;
                        margin-right: auto;
                    }

                    .tag {
                        font-size: xx-small;
                        color: grey;
                    }

                    .cnt {
                        font-size: small;
                        color: grey;
                    }

                    .pre, .pn {
                        text-align: right;
                    }

                    .lang {
                        padding-left: 2em;
                        font-weight: bold;
                        color: blue;
                    }

                    th.ph {
                        font-size: small;
                        color: gray;
                    }

                    .match {
                        font-weight: bold;
                        color: #D10000;
                    }

                    .sc {
                        font-variant: small-caps;
                    }

                    .asc {
                        font-variant: small-caps;
                        text-transform: lowercase;
                    }

                    .uc {
                        text-transform: uppercase;
                    }

                    .ex {
                        letter-spacing: 0.2em;
                    }

                    .tt {
                        font-family: monospace;
                    }

                    .green {
                        color: green;
                        font-weight: bold;
                    }

                    .ref {
                        color: blue;
                        text-decoration: underline;
                    }

                    .notemark {
                        color: green;
                        font-weight: bold;
                        vertical-align: super;
                        font-size: smaller;
                    }

                    .var1 {
                        background-color: white;
                    }

                    .var2 {
                        background-color: #80FFEE;
                    }

                    .var3 {
                        background-color: #BFFF80;
                    }

                    .var4 {
                        background-color: #FFFF80;
                    }

                    .var5 {
                        background-color: #FFD780;
                    }

                    .var6, .var7, .var8, .var9, .var10, .var11, .var12 {
                        background-color: #FF8080;
                        color: black;
                    }

                    .ix {
                        background-color: yellow;
                    }

                    .nt {
                        background-color: #ffccff;
                    }

                    .fig {
                        background-color: #d9ffb3;
                    }

                    .tbl {
                        background-color: #ccffff;
                    }

                </style>
            </head>
            <body>
                <h1>
                    KWIC for <xsl:value-of select="*[self::TEI.2 or self::TEI]/teiHeader/fileDesc/titleStmt/title[not(@type) or @type='main']"/>

                    <xsl:if test="$keyword != ''">
                        (<xsl:value-of select="$keyword"/>)
                    </xsl:if>
                </h1>

                <xsl:call-template name="build-kwic"/>
            </body>
        </html>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate the KWIC</xd:short>
        <xd:detail>Generate the KWIC. This template build a KWIC in the following steps.
        <ol>
            <li>Segmentize the text.</li>
            <li>Collect all words that appear in the document.</li>
            <li>Loop over the list of words, and find matches for each word.</li>
        </ol>
        </xd:detail>
    </xd:doc>

    <xsl:template name="build-kwic">
        <xsl:variable name="segments">
            <xsl:apply-templates mode="segmentize" select="/"/>
        </xsl:variable>

        <xsl:if test="$output-segments">
            <xsl:call-template name="output-segments">
                <xsl:with-param name="segments" select="$segments"/>
            </xsl:call-template>
        </xsl:if>

        <xsl:choose>
            <xsl:when test="$keyword != ''">

                <!-- Build KWIC for searched word(s) only -->
                <xsl:variable name="keywords" select="tokenize(f:normalize-string($keyword), '\s+')"/>

                <xsl:call-template name="report-single-match">
                    <xsl:with-param name="keyword" select="$keywords"/>
                    <xsl:with-param name="segments" select="$segments"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>

                <!-- Build KWIC for all words in document -->
                <xsl:variable name="matches">
                    <xsl:apply-templates mode="multi-kwic" select="$segments//k:w"/>
                </xsl:variable>

                <xsl:for-each-group select="$matches/k:match" group-by="@form">
                    <xsl:sort select="(current-group()[1])/@form" order="ascending"/>
                    <xsl:if test="fn:matches(current-group()[1]/@form, '^[\p{L}\p{M}&prime;-]+$')">
                        <xsl:call-template name="report-multiple-matches">
                            <xsl:with-param name="matches" select="current-group()"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:for-each-group>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="report-multiple-matches">
        <xsl:param name="matches" as="element()*"/>

        <xsl:variable name="keyword" select="$matches[1]/k:word"/>
        <xsl:variable name="baseword" select="f:normalize-string($keyword)"/>
        <xsl:variable name="variant-count" select="f:count-variants($matches)"/>

        <xsl:if test="f:should-report-match($baseword, $variant-count)">
            <h2>
                <span class="cnt">Word:</span><xsl:text> </xsl:text>
                <xsl:value-of select="$baseword"/><xsl:text> </xsl:text>
                <xsl:if test="count($matches) &gt; 1">
                    <span class="cnt"><xsl:value-of select="count($matches)"/></span>
                </xsl:if>
            </h2>

            <xsl:if test="$variant-count &gt; 1 or $baseword != $keyword">
                <xsl:copy-of select="f:output-variants($matches, $variant-count)"/>
            </xsl:if>

            <xsl:variable name="variants">
                <xsl:for-each-group select="$matches" group-by="./k:word">
                    <xsl:sort select="count(current-group())" order="descending"/>
                    <k:w><xsl:value-of select="current-group()[1]/k:word"/></k:w>
                </xsl:for-each-group>
            </xsl:variable>

            <table>
                <xsl:call-template name="table-headers"/>
                <xsl:apply-templates mode="output" select="$matches">
                    <xsl:with-param name="variants" tunnel="yes" select="$variants/k:w"/>
                    <xsl:sort select="f:context-sort-key(k:preceding, k:following)" order="ascending"/>
                </xsl:apply-templates>
            </table>
        </xsl:if>
    </xsl:template>


    <xsl:function name="f:context-sort-key" as="xs:string">
        <xsl:param name="preceding" as="xs:string"/>
        <xsl:param name="following" as="xs:string"/>

        <xsl:choose>
            <xsl:when test="$sort-context = 'preceding'">
                <xsl:value-of select="f:reverse(f:normalize-string($preceding))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="f:normalize-string($following)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xsl:function name="f:reverse">
        <xsl:param name="string" as="xs:string"/>
        <!-- TODO: split the string with a regular expression, taking into account combining diacritics -->
        <xsl:sequence select="codepoints-to-string(reverse(string-to-codepoints($string)))"/>
    </xsl:function>


    <xsl:function name="f:should-report-match" as="xs:boolean">
        <xsl:param name="word" as="xs:string"/>
        <xsl:param name="variant-count" as="xs:integer"/>

        <xsl:sequence select="if ($mixup = '')
                                  then $variant-count >= $min-variant-count
                                  else ($variant-count >= 2 and contains($word, $mixup-sequence[1]))"/>
    </xsl:function>


    <xsl:template name="table-headers">
        <tr>
            <th/>
            <th/>
            <th/>
            <th class="pn">Page</th>
        </tr>
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

    <xsl:template name="report-single-match">
        <xsl:param name="segments"/>
        <xsl:param name="keyword"/>

        <xsl:variable name="matchlist">
            <k:matches>
                <xsl:apply-templates mode="single-kwic" select="$segments//k:w">
                    <xsl:with-param name="keyword" select="$keyword"/>
                </xsl:apply-templates>
            </k:matches>
        </xsl:variable>

        <xsl:variable name="matches" select="$matchlist/k:matches/k:match"/>

        <h2>
            <span class="cnt">Query:</span><xsl:text> </xsl:text>
            <xsl:value-of select="$keyword"/><xsl:text> </xsl:text>
            <xsl:if test="count($matches) &gt; 1">
                <span class="cnt"><xsl:value-of select="count($matches)"/></span>
            </xsl:if>
        </h2>

        <xsl:variable name="variant-count" select="f:count-variants($matches)"/>

        <xsl:if test="$variant-count &gt; 1">
            <xsl:copy-of select="f:output-variants($matches, $variant-count)"/>
        </xsl:if>

        <xsl:variable name="variants">
            <xsl:for-each-group select="$matches" group-by="./k:word">
                <xsl:sort select="count(current-group())" order="descending"/>
                <k:w><xsl:value-of select="current-group()[1]/k:word"/></k:w>
            </xsl:for-each-group>
        </xsl:variable>

        <xsl:apply-templates mode="output" select="$matchlist">
            <xsl:with-param name="variants" tunnel="yes" select="$variants/k:w"/>
            <xsl:sort select="f:context-sort-key(k:preceding, k:following)" order="ascending"/>
        </xsl:apply-templates>
    </xsl:template>


    <xsl:function name="f:count-variants" as="xs:integer">
        <xsl:param name="matches"/>

        <xsl:variable name="groups">
            <xsl:for-each-group select="$matches" group-by="./k:word">.</xsl:for-each-group>
        </xsl:variable>
        <xsl:sequence select="string-length($groups)"/>
    </xsl:function>


    <xsl:function name="f:output-variants">
        <xsl:param name="matches"/>
        <xsl:param name="variant-count" as="xs:integer"/>

        <p><span class="cnt"><xsl:value-of select="if ($variant-count &gt; 1) then 'Variants' else 'Variant'"/>:</span>
            <xsl:for-each-group select="$matches" group-by="./k:word">
                <xsl:sort select="count(current-group())" order="descending"/>

                <xsl:text> </xsl:text><b class="var{position()}"><xsl:value-of select="current-group()[1]/k:word"/></b>
                <xsl:if test="count(current-group()) &gt; 1">
                    <xsl:text> </xsl:text><span class="cnt"><xsl:value-of select="count(current-group())"/></span>
                </xsl:if>
            </xsl:for-each-group>
        </p>
    </xsl:function>


    <xd:doc>
        <xd:short>Output matches.</xd:short>
        <xd:detail>Output an HTML table for the matches.</xd:detail>
    </xd:doc>

    <xsl:template mode="output" match="k:matches">
        <table>
            <xsl:call-template name="table-headers"/>
            <xsl:apply-templates mode="#current">
                <xsl:sort select="f:context-sort-key(k:preceding, k:following)" order="ascending"/>
            </xsl:apply-templates>
        </table>
    </xsl:template>


    <xd:doc>
        <xd:short>Output a match.</xd:short>
        <xd:detail>Output an HTML table-row for a match.</xd:detail>
    </xd:doc>

    <xsl:template mode="output" match="k:match">
        <xsl:param name="variants" tunnel="yes" as="xs:string*"/>

        <tr>
            <xsl:if test="@category = 'index'"><xsl:attribute name="class" select="'ix'"/></xsl:if>
            <xsl:if test="@category = 'note'"><xsl:attribute name="class" select="'nt'"/></xsl:if>
            <xsl:if test="@category = 'figure'"><xsl:attribute name="class" select="'fig'"/></xsl:if>
            <xsl:if test="@category = 'table'"><xsl:attribute name="class" select="'tbl'"/></xsl:if>

            <td class="pre">
                <xsl:apply-templates mode="#current" select="k:preceding"/>
            </td>
            <td class="match var{index-of($variants, string(k:word))}">
                <xsl:apply-templates mode="#current" select="k:word"/>
            </td>
            <td class="post">
                <xsl:apply-templates mode="#current" select="k:following"/>
            </td>
            <td class="pn">
                <xsl:value-of select="@page"/>
            </td>
            <xsl:if test="@xml:lang != $default-language">
                <td class="lang">
                    <xsl:value-of select="@xml:lang"/>
                </td>
            </xsl:if>
        </tr>
    </xsl:template>


    <xd:doc>
        <xd:short>Output a match (in right-to-left script).</xd:short>
        <xd:detail>Output an HTML table-row for a match, using special processing to deal with bidirectional text.</xd:detail>
    </xd:doc>

    <xsl:template mode="output" match="k:match[k:word/k:w/@dir='rtl']">
        <xsl:param name="variants" tunnel="yes" as="xs:string*"/>

        <tr>
            <xsl:if test="@category = 'index'"><xsl:attribute name="class" select="'ix'"/></xsl:if>
            <xsl:if test="@category = 'note'"><xsl:attribute name="class" select="'nt'"/></xsl:if>
            <xsl:if test="@category = 'figure'"><xsl:attribute name="class" select="'fig'"/></xsl:if>
            <xsl:if test="@category = 'table'"><xsl:attribute name="class" select="'tbl'"/></xsl:if>

            <td class="pre">
                <xsl:apply-templates mode="drop-rtl-at-end" select="k:preceding"/>
                <xsl:apply-templates mode="copy-rtl-at-start" select="k:following"/>
            </td>
            <td class="match var{index-of($variants, string(k:word))}">
                <xsl:apply-templates mode="#current" select="k:word"/>
            </td>
            <td class="post">
                <xsl:apply-templates mode="copy-rtl-at-end" select="k:preceding"/>
                <xsl:apply-templates mode="drop-rtl-at-start" select="k:following"/>
            </td>
            <td class="pn">
                <xsl:value-of select="@page"/>
            </td>
            <xsl:if test="@xml:lang != $default-language">
                <td class="lang">
                    <xsl:value-of select="@xml:lang"/>
                </td>
            </xsl:if>
        </tr>
    </xsl:template>


    <xd:doc>
        <xd:short>Output font styles.</xd:short>
    </xd:doc>

    <xsl:template mode="output" match="i | b | sup | sub">
        <xsl:copy><xsl:value-of select="."/></xsl:copy>
    </xsl:template>


    <xd:doc>
        <xd:short>Output font styles (in span element).</xd:short>
    </xd:doc>

    <xsl:template mode="output" match="span">
        <span class="{@class}"><xsl:value-of select="."/></span>
    </xsl:template>


    <xd:doc>
        <xd:short>Reorder multi-directional scripts.</xd:short>
        <xd:detail>
            <p>Reorder multi-directional scripts, such that the display order is correct. Based on
            the idea presented in the article <hi><a href="https://www.sketchengine.eu/wp-content/uploads/2015/03/Displaying_Bidirectional_Text_2007.pdf">Displaying Bidirectional Text Concordances in KWICformat</a></hi>.</p>

            <p>The normal assumption here is that the text runs from left to right (e.g. Latin script); we also assume that a single word is either RTL or LTR.</p>

            <ol>
                <li>If the keyword contains no right-to-left (RTL) characters, no further processing is needed.</li>
                <li>Find a sequence of RTL tokens from the end of the preceding context, and remove it.</li>
                <li>Find a sequence of RTL tokens from the beginning of the following context, and remove it.</li>
                <li>Move the stripped sequences to the opposite side of the opposite context.</li>
            </ol>

            <p>This is handled using the modes drop-rtl-at-end, copy-rtl-at-end, drop-rtl-at-start, and copy-rtl-at-start when generating the output.</p>
        </xd:detail>
    </xd:doc>


    <xsl:template mode="drop-rtl-at-end" match="k:w[@dir='ltr']" priority="1">
        <xsl:apply-templates mode="output" select="."/>
    </xsl:template>

    <xsl:template mode="drop-rtl-at-end" match="k:w[following-sibling::k:w[@dir='ltr']]" priority="2">
        <xsl:apply-templates mode="output" select="."/>
    </xsl:template>

    <xsl:template mode="drop-rtl-at-end" match="k:nw[preceding-sibling::k:w[1][@dir!='rtl'] or following-sibling::k:w[@dir='ltr']]" priority="3">
        <xsl:apply-templates mode="output" select="."/>
    </xsl:template>

    <xsl:template mode="drop-rtl-at-end" match="k:nw|k:w"/>


    <xsl:template mode="copy-rtl-at-end" match="k:w[@dir='ltr']" priority="1"/>

    <xsl:template mode="copy-rtl-at-end" match="k:w[following-sibling::k:w[@dir='ltr']]" priority="2"/>

    <xsl:template mode="copy-rtl-at-end" match="k:nw[preceding-sibling::k:w[1][@dir!='rtl'] or following-sibling::k:w[@dir='ltr']]" priority="3"/>

    <xsl:template mode="copy-rtl-at-end" match="k:nw|k:w">
        <xsl:apply-templates mode="output" select="."/>
    </xsl:template>


    <xsl:template mode="drop-rtl-at-start" match="k:w[@dir='ltr']" priority="1">
        <xsl:apply-templates mode="output" select="."/>
    </xsl:template>

    <xsl:template mode="drop-rtl-at-start" match="k:w[preceding-sibling::k:w[@dir='ltr']]" priority="2">
        <xsl:apply-templates mode="output" select="."/>
    </xsl:template>

    <xsl:template mode="drop-rtl-at-start" match="k:nw[following-sibling::k:w[1][@dir!='rtl'] or preceding-sibling::k:w[@dir='ltr']]" priority="3">
        <xsl:apply-templates mode="output" select="."/>
    </xsl:template>

    <xsl:template mode="drop-rtl-at-start" match="k:nw|k:w"/>


    <xsl:template mode="copy-rtl-at-start" match="k:w[@dir='ltr']" priority="1"/>

    <xsl:template mode="copy-rtl-at-start" match="k:w[preceding-sibling::k:w[@dir='ltr']]" priority="2"/>

    <xsl:template mode="copy-rtl-at-start" match="k:nw[following-sibling::k:w[1][@dir!='rtl'] or preceding-sibling::k:w[@dir='ltr']]" priority="3"/>

    <xsl:template mode="copy-rtl-at-start" match="k:nw|k:w">
        <xsl:apply-templates mode="output" select="."/>
    </xsl:template>


    <!-- Not all Unicode regular expressions are supported in XSLT (https://www.regular-expressions.info/unicode.html), also,
         for this tool, we use a simplified approximation of handling bidirectional script. -->

    <xsl:function name="f:is-right-to-left" as="xs:boolean">
        <xsl:param name="word" as="xs:string"/>
        <!-- <xsl:sequence select="matches($word, '\p{Bidi_Class:Right_to_Left}|\p{Bidi_Class:Arabic_Letter}')"/> -->
        <!-- <xsl:sequence select="matches($word, '\p{Letter}') and matches($word, '\p{Arabic}|\p{Hebrew}|\p{Syriac}|\p{Thaana}')"/> -->
        <xsl:sequence select="matches($word, '\p{L}') and matches($word, '[&#x0590;-&#x07BF;]')"/>
    </xsl:function>

    <xsl:function name="f:is-left-to-right" as="xs:boolean">
        <xsl:param name="word" as="xs:string"/>
        <!-- <xsl:sequence select="matches($word, '\p{Bidi_Class:Left_To_Right}')"/> -->
        <!-- <xsl:sequence select="matches($word, '\p{Letter}') and not(matches($word, '\p{Arabic}|\p{Hebrew}|\p{Syriac}|\p{Thaana}'))"/> -->
        <xsl:sequence select="matches($word, '\p{L}') and not(matches($word, '[&#x0590;-&#x07BF;]'))"/>
    </xsl:function>


    <xd:doc mode="single-kwic">
        <xd:short>Mode used to find matches.</xd:short>
        <xd:detail>This traverses the segments, looking for matching words.</xd:detail>
    </xd:doc>

    <xd:doc>
        <xd:short>Find a match in a segment.</xd:short>
        <xd:detail>Find a match in a segment.</xd:detail>
    </xd:doc>

    <xsl:template mode="single-kwic" match="s:segment">
        <xsl:apply-templates mode="#current" select="."/>
    </xsl:template>


    <xd:doc>
        <xd:short>Find a matching word.</xd:short>
        <xd:detail>Find a matching word, when a word is found, the preceding and following contexts are kept with the match.</xd:detail>
    </xd:doc>

    <xsl:template mode="single-kwic" match="k:w">
        <xsl:param name="keyword" required="yes"/>

        <xsl:if test="$keyword = @form">
            <k:match form="{@form}" page="{@page}" category="{@category}" xml:lang="{@xml:lang}">
                <k:preceding><xsl:copy-of select="preceding-sibling::*[position() &lt; $context-size]"/></k:preceding>
                <k:word><xsl:copy-of select="."/></k:word>
                <k:following><xsl:copy-of select="following-sibling::*[position() &lt; $context-size]"/></k:following>
            </k:match>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Collect preceding and following contexts.</xd:short>
        <xd:detail>
            <p>For every word the preceding and following contexts are kept with the match.</p>

            <p>A significant improvement in speed and memory usage can be obtained here by already rendering the preceding
            and following context, instead of doing this during the output phase. This is not done, as it complicates the
            handling of bidirectional text. For large files, please run Saxon with sufficient memory (java -Xms3072m -Xmx3072m).</p>
        </xd:detail>
    </xd:doc>

    <xsl:template mode="multi-kwic" match="k:w">
        <xsl:if test="not(f:is-stopword(., @xml:lang)) and f:is-selected-language(@xml:lang)">
            <k:match form="{@form}" page="{@page}" category="{@category}" xml:lang="{@xml:lang}">
                <k:preceding><xsl:copy-of select="preceding-sibling::*[position() &lt; $context-size]"/></k:preceding>
                <k:word><xsl:copy-of select="."/></k:word>
                <k:following><xsl:copy-of select="following-sibling::*[position() &lt; $context-size]"/></k:following>
            </k:match>
        </xsl:if>
    </xsl:template>


    <xd:doc mode="context">
        <xd:short>Mode used to copy the context of a match.</xd:short>
        <xd:detail>Only used to copy preceding and following contexts when a match is found.</xd:detail>
    </xd:doc>

    <xd:doc>
        <xd:short>Copy matching words and non-words in the context.</xd:short>
        <xd:detail>Copy matching words and non-words in the context, taking care to apply the correct text style.</xd:detail>
    </xd:doc>

    <xsl:template mode="output" match="k:w|k:nw">

        <xsl:choose>
            <xsl:when test="@ref and normalize-space(.) = ''"><span class="ref"><xsl:value-of select="."/></span></xsl:when>

            <xsl:when test="normalize-space(.) = ''"><xsl:value-of select="."/></xsl:when>

            <xsl:when test="@ref and @style = 'i'"><i class="ref"><xsl:value-of select="."/></i></xsl:when>
            <xsl:when test="@ref and @style = 'b'"><b class="ref"><xsl:value-of select="."/></b></xsl:when>
            <xsl:when test="@ref and @style = 'sup'"><sup class="ref"><xsl:value-of select="."/></sup></xsl:when>
            <xsl:when test="@ref and @style = 'sub'"><sub class="ref"><xsl:value-of select="."/></sub></xsl:when>

            <xsl:when test="@style = 'i'"><i><xsl:value-of select="."/></i></xsl:when>
            <xsl:when test="@style = 'b'"><b><xsl:value-of select="."/></b></xsl:when>
            <xsl:when test="@style = 'sup'"><sup><xsl:value-of select="."/></sup></xsl:when>
            <xsl:when test="@style = 'sub'"><sub><xsl:value-of select="."/></sub></xsl:when>

            <xsl:when test="@ref and @style = 'sc'"><span class="sc ref"><xsl:value-of select="."/></span></xsl:when>
            <xsl:when test="@ref and @style = 'asc'"><span class="asc ref"><xsl:value-of select="."/></span></xsl:when>
            <xsl:when test="@ref and @style = 'uc'"><span class="uc ref"><xsl:value-of select="."/></span></xsl:when>
            <xsl:when test="@ref and @style = 'ex'"><span class="ex ref"><xsl:value-of select="."/></span></xsl:when>
            <xsl:when test="@ref and @style = 'tt'"><span class="tt ref"><xsl:value-of select="."/></span></xsl:when>

            <xsl:when test="@style = 'sc'"><span class="sc"><xsl:value-of select="."/></span></xsl:when>
            <xsl:when test="@style = 'asc'"><span class="asc"><xsl:value-of select="."/></span></xsl:when>
            <xsl:when test="@style = 'uc'"><span class="uc"><xsl:value-of select="."/></span></xsl:when>
            <xsl:when test="@style = 'ex'"><span class="ex"><xsl:value-of select="."/></span></xsl:when>
            <xsl:when test="@style = 'tt'"><span class="tt"><xsl:value-of select="."/></span></xsl:when>

            <xsl:when test="@style = 'green'"><span class="green"><xsl:value-of select="."/></span></xsl:when>
            <xsl:when test="@style = 'notemark'"><span class="notemark"><xsl:value-of select="."/></span></xsl:when>

            <xsl:when test="@ref"><span class="ref"><xsl:value-of select="."/></span></xsl:when>

            <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Split a string into words.</xd:short>
        <xd:detail>Split a string into words, using a regular expression syntax.</xd:detail>
        <xd:param name="string">The string to be split in words.</xd:param>
    </xd:doc>

    <xsl:function name="f:words" as="xs:string*">
        <xsl:param name="string" as="xs:string"/>
        <xsl:analyze-string select="$string" regex="{'[\p{L}\p{N}\p{M}&prime;-]+'}">
            <xsl:matching-substring>
                <xsl:sequence select="."/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>


    <xd:doc>
        <xd:short>Normalize a word, based on the current settings.</xd:short>
    </xd:doc>

    <xsl:function name="f:normalize-string" as="xs:string">
        <xsl:param name="string" as="xs:string"/>

        <xsl:variable name="string" select="if ($case-sensitive = 'true') then $string else lower-case($string)"/>
        <xsl:variable name="string" select="f:strip-diacritics-and-marks($string)"/>
        <xsl:variable name="string" select="f:normalize-ligatures($string)"/>
        <xsl:variable name="string" select="f:normalize-special-letters($string)"/>
        <xsl:variable name="string" select="f:normalize-mixup-characters($string)"/>

        <xsl:sequence select="$string"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Remove diacritics from a string.</xd:short>
        <xd:detail>Remove diacritics form a string to produce a string suitable for sorting purposes. This function
        uses the Unicode NFD normalization form to separate diacritics from the letters carrying them, and might
        result too much being removed in some scripts (in particular Indic scripts, where vowel-signs are stripped).</xd:detail>
        <xd:param name="string">The string to processed.</xd:param>
    </xd:doc>

    <xsl:function name="f:strip-diacritics-and-marks" as="xs:string">
        <xsl:param name="string" as="xs:string"/>

        <xsl:variable name="string" select="fn:replace($string, '[&#x0640;&#x02BE;&#x02BC;&#x02BF;&#x02b9;&tcomma;&prime;-]', '')" as="xs:string"/>
        <xsl:variable name="string" select="f:mask-indic-vowel-signs($string)" as="xs:string"/>
        <xsl:variable name="string" select="fn:replace(fn:normalize-unicode($string, 'NFD'), '\p{M}', '')" as="xs:string"/>
        <xsl:variable name="string" select="f:restore-indic-vowel-signs($string)" as="xs:string"/>

        <xsl:sequence select="$string"/>
    </xsl:function>


    <xsl:function name="f:mask-indic-vowel-signs" as="xs:string">
        <xsl:param name="string" as="xs:string"/>

        <!-- Devanagari vowel signs and virama -->
        <xsl:variable name="devanagari" select="'&#x093a;&#x093b;&#x093e;-&#x094d;'" as="xs:string"/>

        <!-- Bengali vowel signs and virama -->
        <xsl:variable name="bengali" select="'&#x09be;-&#x09c4;&#x09c7;-&#x09c8;&#x09cb;-&#x09cd;'" as="xs:string"/>

        <!-- Gujarati vowel signs and virama -->
        <xsl:variable name="gujarati" select="'&#x0abe;-&#x0ac5;&#x0ac7;-&#x0ac9;&#x0acb;-&#x0acd;'" as="xs:string"/>

        <!-- Tibetan vowel signs and subjoined consonants -->
        <xsl:variable name="tibetan" select="'&#x0f71;-&#x0f7d;&#x0f90;-&#x0f97;&#x0f99;-&#x0fbc;'" as="xs:string"/>

        <xsl:variable name="result">
            <xsl:analyze-string select="$string" regex="{'[' || $devanagari || $bengali || $gujarati || $tibetan || ']'}">
                <xsl:matching-substring>
                    <xsl:value-of select="'&startMark;' || string-to-codepoints(.) || '&endMark;'"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
         
        <xsl:sequence select="string-join($result, '')"/>
    </xsl:function>


    <xsl:function name="f:restore-indic-vowel-signs" as="xs:string">
        <xsl:param name="string" as="xs:string"/>

        <xsl:variable name="result">
            <xsl:analyze-string select="$string" regex="&startMark;([0-9]+)&endMark;">
                <xsl:matching-substring>
                    <xsl:value-of select="codepoints-to-string(xs:integer(regex-group(1)))"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>

        <xsl:sequence select="string-join($result, '')"/>
    </xsl:function>


    <xsl:function name="f:normalize-ligatures" as="xs:string">
        <xsl:param name="string" as="xs:string"/>

        <xsl:variable name="string" select="fn:replace($string, '&#x00df;', 'ss')"/> <!-- German eszet -->
        <xsl:variable name="string" select="fn:replace($string, '&#x1E9E;', 'SS')"/> <!-- German capital eszet -->
        <xsl:variable name="string" select="fn:replace($string, '&#x00c6;', 'AE')"/> <!-- AE ligature -->
        <xsl:variable name="string" select="fn:replace($string, '&#x00e6;', 'ae')"/> <!-- ae ligature -->

        <xsl:variable name="string" select="fn:replace($string, '&#x0132;', 'IJ')"/> <!-- Dutch IJ -->
        <xsl:variable name="string" select="fn:replace($string, '&#x0133;', 'ij')"/> <!-- Dutch ij -->
        <xsl:variable name="string" select="fn:replace($string, '&#x0152;', 'OE')"/> <!-- OE ligature -->
        <xsl:variable name="string" select="fn:replace($string, '&#x0153;', 'oe')"/> <!-- oe ligature -->

        <xsl:variable name="string" select="fn:replace($string, '&#xA734;', 'AO')"/> <!-- Ligature AO (Old Icelandic) -->
        <xsl:variable name="string" select="fn:replace($string, '&#xA735;', 'ao')"/> <!-- Ligature ao (Old Icelandic) -->

        <xsl:variable name="string" select="fn:replace($string, '&#x1EFA;', 'LL')"/> <!-- ligature Ll (older Welsh) -->
        <xsl:variable name="string" select="fn:replace($string, '&#x1EFB;', 'll')"/> <!-- Ligature ll (older Welsh) -->

        <xsl:sequence select="$string"/>
    </xsl:function>


    <xsl:function name="f:normalize-special-letters" as="xs:string">
        <xsl:param name="string" as="xs:string"/>

        <xsl:variable name="string" select="fn:replace($string, '&#x00D8;', 'O')"/> <!-- Latin capital letter O with stroke -->
        <xsl:variable name="string" select="fn:replace($string, '&#x00F8;', 'o')"/> <!-- Latin small letter o with stroke -->
        <xsl:variable name="string" select="fn:replace($string, '&#x00D0;', 'D')"/> <!-- Latin capital letter Eth -->
        <xsl:variable name="string" select="fn:replace($string, '&#x00F0;', 'd')"/> <!-- Latin small letter eth -->

        <xsl:variable name="string" select="fn:replace($string, '&#x0110;', 'D')"/> <!-- Latin capital letter D with stroke -->
        <xsl:variable name="string" select="fn:replace($string, '&#x0111;', 'd')"/> <!-- Latin small letter d with stroke -->
        <xsl:variable name="string" select="fn:replace($string, '&#x0126;', 'H')"/> <!-- Latin capital letter H with stroke -->
        <xsl:variable name="string" select="fn:replace($string, '&#x0127;', 'h')"/> <!-- Latin small letter h with stroke -->
        <xsl:variable name="string" select="fn:replace($string, '&#x0141;', 'L')"/> <!-- Latin capital letter L with stroke -->
        <xsl:variable name="string" select="fn:replace($string, '&#x0142;', 'l')"/> <!-- Latin small letter l with stroke -->
        <xsl:variable name="string" select="fn:replace($string, '&#x0166;', 'T')"/> <!-- Latin capital letter T with stroke -->
        <xsl:variable name="string" select="fn:replace($string, '&#x0167;', 't')"/> <!-- Latin small letter t with stroke -->
        <xsl:variable name="string" select="fn:replace($string, '&#x017F;', 's')"/> <!-- Latin small letter long s -->

        <xsl:variable name="string" select="fn:replace($string, '&#x207F;', 'n')"/> <!-- Superscript Latin small letter n -->

        <!-- Hebrew script -->
        <xsl:variable name="string" select="fn:replace($string, '&#xFB21;', '&#x05D0;')"/> <!-- Hebrew letter wide alef -> alef -->
        <xsl:variable name="string" select="fn:replace($string, '&#xFB22;', '&#x05D3;')"/> <!-- Hebrew letter wide dalet -> dalet -->
        <xsl:variable name="string" select="fn:replace($string, '&#xFB23;', '&#x05D4;')"/> <!-- Hebrew letter wide he -> he -->
        <xsl:variable name="string" select="fn:replace($string, '&#xFB24;', '&#x05DB;')"/> <!-- Hebrew letter wide kaf -> kaf -->
        <xsl:variable name="string" select="fn:replace($string, '&#xFB25;', '&#x05DC;')"/> <!-- Hebrew letter wide lamed -> lamed -->
        <xsl:variable name="string" select="fn:replace($string, '&#xFB26;', '&#x05DD;')"/> <!-- Hebrew letter wide final mem -> final mem -->
        <xsl:variable name="string" select="fn:replace($string, '&#xFB27;', '&#x05E8;')"/> <!-- Hebrew letter wide resh -> resh -->
        <xsl:variable name="string" select="fn:replace($string, '&#xFB28;', '&#x05EA;')"/> <!-- Hebrew letter wide tav -> tav -->

        <xsl:sequence select="$string"/>
    </xsl:function>


    <xsl:function name="f:normalize-mixup-characters" as="xs:string">
        <xsl:param name="string" as="xs:string"/>

        <!-- replace all potentially mixed-up characters in the list whith the first in the sequence -->
        <xsl:sequence select="if ($mixup-sequence[2])
            then f:multi-replace($string, $mixup-sequence[position() > 1], $mixup-sequence[1])
            else $string"/>
    </xsl:function>

    <xd:doc>
        <xd:short>Replace the occurences of multiple patterns in a string with a single replacement.</xd:short>
    </xd:doc>

    <xsl:function name="f:multi-replace" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:param name="patterns" as="xs:string*"/>
        <xsl:param name="replacement" as="xs:string"/>

        <xsl:iterate select="$patterns">
            <xsl:param name="string" select="$string" as="xs:string"/>
            <xsl:on-completion select="$string"/>
            <xsl:next-iteration>
                <xsl:with-param name="string" select="replace($string, ., $replacement)"/>
            </xsl:next-iteration>
        </xsl:iterate>
    </xsl:function>


    <xd:doc>
        <xd:short>Analyze text nodes.</xd:short>
        <xd:detail>Split segments into words (using the <code>segments</code> mode of <code>segmentize.xsl</code>,
        so this happens during segmenting the text).</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="text()">
        <xsl:call-template name="analyze-text"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Introduce slashes between lines of verse.</xd:short>
        <xd:detail>Introduce slashes between lines of verse, overrides template in <code>segmentize.xsl</code>.</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="l" priority="2">
        <xsl:if test="preceding-sibling::l">
            <k:nw style="green"><xsl:text> / </xsl:text></k:nw>
        </xsl:if>
        <xsl:apply-templates mode="#current"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Put transliteration between brackets.</xd:short>
        <xd:detail>Introduce brackets around transliterations, normally represented in <code>choice</code> elements;
        overrides template in <code>segmentize.xsl</code>.</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="choice[orig]" priority="2">
        <xsl:apply-templates mode="segments" select="orig"/>
        <k:nw style="green"><xsl:text> [</xsl:text></k:nw>
        <xsl:apply-templates mode="segments" select="reg"/>
        <k:nw style="green"><xsl:text>] </xsl:text></k:nw>
    </xsl:template>


    <xd:doc>
        <xd:short>Show note-markers.</xd:short>
    </xd:doc>

    <xsl:template mode="segments" match="note" priority="2">
        <k:nw style="notemark"><xsl:value-of select="@n"/></k:nw>
    </xsl:template>


    <xd:doc>
        <xd:short>Collect words in <code>w</code> elements.</xd:short>
        <xd:detail>Collect words in <code>w</code> elements. In this element, the normalized version is kept
        in the <code>@form</code> attribute, the current language in the <code>@xml:lang</code> attribute, and the page on
        which it appears in the <code>@page</code> attribute.</xd:detail>
    </xd:doc>

    <xsl:template name="analyze-text">
        <xsl:variable name="lang" select="(ancestor-or-self::*/@lang|ancestor-or-self::*/@xml:lang)[last()]"/>
        <xsl:variable name="page" select="preceding::pb[1]/@n"/>
        <xsl:variable name="style" select="f:find-text-style(.)"/>
        <xsl:variable name="category" select="f:category(.)"/>
        <xsl:variable name="inReference" select="if (ancestor-or-self::ref[@target] or ancestor-or-self::xref[@url]) then 'true' else 'false'"/>
        <xsl:variable name="reference" select="if (ancestor-or-self::ref[@target]) then '#' || ancestor-or-self::ref[@target] else ancestor-or-self::xref[@url]"/>

        <xsl:analyze-string select="." regex="{'[\p{L}\p{N}\p{M}&prime;-]+'}">
            <xsl:matching-substring>
                <k:w>
                    <xsl:attribute name="xml:lang" select="$lang"/>
                    <xsl:if test="$style != ''">
                        <xsl:attribute name="style" select="$style"/>
                    </xsl:if>
                    <xsl:attribute name="page" select="$page"/>
                    <xsl:if test="$category != ''">
                        <xsl:attribute name="category" select="$category"/>
                    </xsl:if>
                    <xsl:if test="$inReference = 'true'">
                        <xsl:attribute name="ref" select="$reference"/>
                    </xsl:if>
                    <xsl:attribute name="form" select="f:normalize-string(.)"/>
                    <xsl:attribute name="dir" select="if (f:is-right-to-left(.)) then 'rtl' else 'ltr'"/>
                    <xsl:value-of select="."/>
                </k:w>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <k:nw>
                    <xsl:if test="$style != ''">
                        <xsl:attribute name="style" select="$style"/>
                    </xsl:if>
                    <xsl:value-of select="."/>
                </k:nw>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>


    <xsl:function name="f:category" as="xs:string">
        <xsl:param name="node" as="node()"/>

        <xsl:sequence select="if ($node/ancestor-or-self::*[@type='Index'])
                              then 'index'
                              else if ($node/ancestor-or-self::figure)
                                   then 'figure'
                                   else if ($node/ancestor-or-self::note)
                                        then 'note'
                                        else if ($node/ancestor-or-self::table)
                                             then 'table'
                                             else ''"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Establish the current text style of a word.</xd:short>
        <xd:detail>Establish the current text style of a word, by looking at the first <code>hi</code> ancestor. This is somewhat crude,
        but works reasonably well for texts in my collection.</xd:detail>
        <xd:param name="node">The node for which to establish the text style.</xd:param>
    </xd:doc>

    <xsl:function name="f:find-text-style" as="xs:string?">
        <xsl:param name="node" as="node()"/>
        <xsl:variable name="hi" select="$node/ancestor-or-self::*[local-name(.) = ('hi', 'i', 'b', 'ex', 'sc', 'asc', 'uc', 'tt', 'sup', 'sub')][1]"/>
        <!-- Ignore hi elements if we are in a note, and the hi is outside the note -->
        <xsl:if test="$hi and not($hi/descendant::note)">
            <xsl:variable name="rend" select="$hi/@rend"/>
            <xsl:variable name="name" select="local-name($hi)"/>
            <xsl:choose>
                <xsl:when test="$name = 'asc'">asc</xsl:when>
                <xsl:when test="$name = 'b'">b</xsl:when>
                <xsl:when test="$name = 'ex'">ex</xsl:when>
                <xsl:when test="$name = 'sc'">sc</xsl:when>
                <xsl:when test="$name = 'sub'">sub</xsl:when>
                <xsl:when test="$name = 'sup'">sup</xsl:when>
                <xsl:when test="$name = 'tt'">tt</xsl:when>
                <xsl:when test="$name = 'uc'">uc</xsl:when>

                <xsl:when test="$rend = 'asc'">asc</xsl:when>
                <xsl:when test="$rend = 'bold'">b</xsl:when>
                <xsl:when test="$rend = 'ex'">ex</xsl:when>
                <xsl:when test="$rend = 'sc'">sc</xsl:when>
                <xsl:when test="$rend = 'sub'">sub</xsl:when>
                <xsl:when test="$rend = 'sup'">sup</xsl:when>
                <xsl:when test="$rend = 'tt'">tt</xsl:when>
                <xsl:when test="$rend = 'uc'">uc</xsl:when>

                <xsl:otherwise>i</xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>


    <xsl:function name="f:is-selected-language" as="xs:boolean">
        <xsl:param name="lang" as="xs:string"/>

        <xsl:variable name="baselang" select="if (contains($lang, '-')) then substring-before($lang, '-') else $lang"/>

        <xsl:sequence select="$select-language = '' or $baselang = $select-language-sequence"/>
    </xsl:function>


    <xsl:function name="f:contains-mixup-character" as="xs:boolean">
        <xsl:param name="word" as="xs:string"/>

        <xsl:sequence select="if ($mixup = '') then true() else contains(f:strip-diacritics-and-marks($word), $mixup-sequence[1])"/>
    </xsl:function>

</xsl:stylesheet>
