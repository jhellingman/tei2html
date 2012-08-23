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

    <xsl:output
        doctype-public="-//W3C//DTD XHTML 1.1//EN"
        doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
        method="xml"
        encoding="utf-8"/>

    <xsl:include href="segmentize.xsl"/>

    <xd:doc>
        <xd:short>The keyword to generate a KWIC for.</xd:short>
        <xd:detail>The keyword(s) to generate a KWIC for. If omitted, a KWIC will be generated for all words
        in the document.</xd:detail>
    </xd:doc>

    <xsl:param name="keyword" select="''"/>


    <xsl:variable name="defaultlang" select="/TEI.2/@lang"/>


    <xd:doc>
        <xd:short>The lenght of the context to show.</xd:short>
        <xd:detail>The lenght of the context to show. This counts both words and non-words (spaces and punctuation marks).
        The preceding and following contexts are counted separately.</xd:detail>
    </xd:doc>

    <xsl:param name="contextSize" select="16"/>


    <xd:doc>
        <xd:short>Stopwords (per language).</xd:short>
        <xd:detail>Stopwords will be ignored when generating the KWIC. Stopwords can be provided in a single string, separated
        by a space. Internally this will be converted to a sequence.</xd:detail>
    </xd:doc>

    <xsl:param name="en-stopwords" select="'a about an are as at be by for from how I in is it of on or that the this to was what when where who will with'"/>
    <xsl:param name="nl-stopwords" select="'aan al alles als altijd andere ben bij daar dan dat de der deze die dit doch doen door dus een eens en er ge geen geweest haar had heb hebben heeft hem het hier hij hoe hun iemand iets ik in is ja je kan kon kunnen maar me meer men met mij mijn moet na naar niet niets nog nu of om omdat onder ons ook op over reeds te tegen toch toen tot u uit uw van veel voor want waren was wat werd wezen wie wil worden wordt zal ze zelf zich zij zijn zo zonder zou'"/>

    <!--
    <xsl:param name="en-stopwords" select="'@/Bin/dic/en.dic'"/>
    <xsl:param name="nl-stopwords" select="'@/Bin/dic/nl.dic'"/>
    -->

    <xsl:variable name="en-stopwords-sequence" select="f:load-stopwords($en-stopwords)"/>
    <xsl:variable name="nl-stopwords-sequence" select="f:load-stopwords($nl-stopwords)"/>


    <xd:doc>
        <xd:short>Load stopwords.</xd:short>
        <xd:detail>Function to load stopwords, either from a string, or from a file, if the string starts
        with an @-sign.</xd:detail>
    </xd:doc>

    <xsl:function name="f:load-stopwords" as="xs:string*">
        <xsl:param name="source"/>

        <xsl:sequence select="if (substring($source, 1, 1) = '@') then f:load-dictionary(substring($source, 2)) else tokenize($source, ' ')"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Load dictionary from a file.</xd:short>
        <xd:detail>Load a dictionary from a file, assumed to have one word per line, and encoded
        in the iso-8859-1 character set.</xd:detail>
    </xd:doc>

    <xsl:function name="f:load-dictionary" as="xs:string*">
        <xsl:param name="filename"/>

        <xsl:message terminate="no">Loading stopwords from file: <xsl:value-of select="$filename"/></xsl:message>
        <xsl:variable name="file-contents" as="xs:string" select="unparsed-text($filename, 'iso-8859-1')"/>
        <xsl:sequence select="tokenize($file-contents, '\r?\n')"/>
    </xsl:function>



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

                .lang
                {
                    padding-left: 2em;
                    font-weight: bold;
                    color: blue;
                }

                th.ph
                {
                    font-size: small;
                    color: gray;
                }

                .match
                {
                    font-weight: bold;
                    color: #D10000;
                }

                .sc
                {
                    font-variant: small-caps;
                }

                .uc
                {
                    text-transform: uppercase;
                }

                .ex
                {
                    letter-spacing: 0.2em;
                }

                .var2
                {
                    background-color: #80FFEE;
                }

                .var3
                {
                    background-color: #BFFF80;
                }

                .var4
                {
                    background-color: #FFFF80;
                }

                .var5
                {
                    background-color: #FFD780;
                }

                .var6, .var7, .var8, .var9, .var10, .var11, .var12
                {
                    background-color: #FF8080;
                    color: black;
                }

            </style>
        </head>
        <html>
            <h1>
                KWIC for <xsl:value-of select="TEI.2/teiHeader/fileDesc/titleStmt/title"/>

                <xsl:if test="$keyword != ''">
                    (<xsl:value-of select="$keyword"/>)
                </xsl:if>
            </h1>

            <xsl:call-template name="build-kwic"/>
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
            <xsl:call-template name="segmentize"/>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$keyword != ''">

                <!-- Build KWIC for searched word(s) -->
                <xsl:variable name="keywords" select="tokenize(fn:lower-case(f:strip_diacritics($keyword)), '\s+')"/>

                <xsl:call-template name="report-matches">
                    <xsl:with-param name="keyword" select="$keywords"/>
                    <xsl:with-param name="segments" select="$segments"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>

                <!-- Build KWIC for all words in document -->
                <xsl:variable name="matches">
                    <xsl:apply-templates mode="multi-kwic" select="$segments//w"/>
                </xsl:variable>

                <xsl:for-each-group select="$matches/match" group-by="@form">
                    <xsl:sort select="(current-group()[1])/@form" order="ascending"/>
                    <xsl:if test="fn:matches(current-group()[1]/@form, '^[\p{L}-]+$')">
                        <xsl:call-template name="report-matches2">
                            <xsl:with-param name="matches" select="current-group()"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:for-each-group>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="report-matches2">
        <xsl:param name="matches" as="element()*"/>

        <xsl:variable name="keyword" select="$matches[1]/word"/>

        <h2>
            <span class="cnt">Word:</span><xsl:text> </xsl:text>
            <xsl:value-of select="$keyword"/><xsl:text> </xsl:text>
            <span class="cnt"><xsl:value-of select="count($matches)"/></span>
        </h2>

        <xsl:variable name="variant-count">
            <xsl:variable name="groups">
                <xsl:for-each-group select="$matches" group-by="./word">.</xsl:for-each-group>
            </xsl:variable>
            <xsl:value-of select="string-length($groups)"/>
        </xsl:variable>

        <xsl:if test="$variant-count &gt; 1">
            <p><span class="cnt">Variants:</span>
                <xsl:for-each-group select="$matches" group-by="./word">
                    <xsl:sort select="count(current-group())" order="descending"/>

                    <xsl:text> </xsl:text><b class="var{position()}"><xsl:value-of select="current-group()[1]/word"/></b>
                    <xsl:text> </xsl:text><span class="cnt"><xsl:value-of select="count(current-group())"/></span>
                </xsl:for-each-group>
            </p>
        </xsl:if>

        <xsl:variable name="variants">
            <xsl:for-each-group select="$matches" group-by="./word">
                <xsl:sort select="count(current-group())" order="descending"/>
                    <w><xsl:value-of select="current-group()[1]/word"/></w>
            </xsl:for-each-group>
        </xsl:variable>

        <table>
            <tr>
                <th/>
                <th/>
                <th/>
                <th class="pn">Page</th>
            </tr>

            <xsl:apply-templates mode="output" select="$matches">
                <xsl:with-param name="variants" tunnel="yes" select="$variants/w"/>
                <xsl:sort select="fn:lower-case(f:strip_diacritics(following))" order="ascending"/>
            </xsl:apply-templates>
        </table>
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
                <xsl:apply-templates mode="single-kwic" select="$segments//w">
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

            <xsl:apply-templates mode="#current">
                <xsl:sort select="fn:lower-case(f:strip_diacritics(following))" order="ascending"/>
            </xsl:apply-templates>
        </table>
    </xsl:template>


    <xd:doc>
        <xd:short>Output a match.</xd:short>
        <xd:detail>Output an HTML table-row for a match.</xd:detail>
    </xd:doc>

    <xsl:template mode="output" match="match">
        <xsl:param name="variants" tunnel="yes" as="xs:string*"/>

        <tr>
            <td class="pre">
                <xsl:apply-templates mode="#current" select="preceding"/>
            </td>
            <td class="match var{index-of($variants, string(word))}">
                <xsl:apply-templates mode="#current" select="word"/>
            </td>
            <td class="post">
                <xsl:apply-templates mode="#current" select="following"/>
            </td>
            <td class="pn">
                <xsl:value-of select="@page"/>
            </td>
            <xsl:if test="@xml:lang != $defaultlang">
                <td class="lang">
                    <xsl:value-of select="@xml:lang"/>
                </td>
            </xsl:if>
        </tr>
    </xsl:template>


    <xd:doc>
        <xd:short>Output font styles.</xd:short>
        <xd:detail></xd:detail>
    </xd:doc>

    <xsl:template mode="output" match="i | b | sup | sub">
        <xsl:copy><xsl:value-of select="."/></xsl:copy>
    </xsl:template>


    <xd:doc>
        <xd:short>Output font styles (in span element).</xd:short>
        <xd:detail></xd:detail>
    </xd:doc>

    <xsl:template mode="output" match="span">
        <span class="{@class}"><xsl:value-of select="."/></span>
    </xsl:template>


    <xd:doc mode="single-kwic">
        <xd:short>Mode used to find matches.</xd:short>
        <xd:detail>This traverses the segments, looking for matching words.</xd:detail>
    </xd:doc>

    <xd:doc>
        <xd:short>Find a match in a segment.</xd:short>
        <xd:detail>Find a match in a segment.</xd:detail>
    </xd:doc>

    <xsl:template mode="single-kwic" match="segment">
        <xsl:apply-templates mode="#current" select="."/>
    </xsl:template>


    <xd:doc>
        <xd:short>Find a matching word.</xd:short>
        <xd:detail>Find a matching word, when a word is found, the preceding and following contexts are kept with the match.</xd:detail>
    </xd:doc>

    <xsl:template mode="single-kwic" match="w">
        <xsl:param name="keyword" required="yes"/>

        <xsl:if test="$keyword = @form">
            <match form="{@form}" page="{@page}" xml:lang="{@xml:lang}">
                <preceding><xsl:apply-templates mode="context" select="preceding-sibling::*[position() &lt; $contextSize]"/></preceding>
                <word><xsl:apply-templates mode="context" select="."/></word>
                <following><xsl:apply-templates mode="context" select="following-sibling::*[position() &lt; $contextSize]"/></following>
            </match>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Collect preceding and following contexts.</xd:short>
        <xd:detail>For every word the preceding and following contexts are kept with the match.</xd:detail>
    </xd:doc>

    <xsl:template mode="multi-kwic" match="w">
        <xsl:if test="not(f:is-stopword(., @xml:lang))">
            <match form="{@form}" page="{@page}" xml:lang="{@xml:lang}">
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
        <xd:detail>Copy matching words and non-words in the context, taking care to apply the correct text style.</xd:detail>
    </xd:doc>

    <xsl:template mode="context" match="w|nw">
        <xsl:choose>
            <xsl:when test="@style = 'i'"><i><xsl:value-of select="."/></i></xsl:when>
            <xsl:when test="@style = 'b'"><b><xsl:value-of select="."/></b></xsl:when>
            <xsl:when test="@style = 'sup'"><sup><xsl:value-of select="."/></sup></xsl:when>
            <xsl:when test="@style = 'sub'"><sub><xsl:value-of select="."/></sub></xsl:when>

            <xsl:when test="@style = 'sc'"><span class="sc"><xsl:value-of select="."/></span></xsl:when>
            <xsl:when test="@style = 'uc'"><span class="uc"><xsl:value-of select="."/></span></xsl:when>
            <xsl:when test="@style = 'ex'"><span class="ex"><xsl:value-of select="."/></span></xsl:when>

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
        <xd:short>Analyze text nodes.</xd:short>
        <xd:detail>Split segments into words (using the <code>segments</code> mode of segmentize.xsl,
        so this happens during segmenting the text).</xd:detail>
    </xd:doc>

    <xsl:template mode="segments" match="text()">
        <xsl:call-template name="analyze-text"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Collect words in <code>w</code> elements.</xd:short>
        <xd:detail>Collect words in <code>w</code> elements. In this element, the normalized version is kept
        in the <code>@form</code> attribute, the current language in the <code>@xml:lang</code> attribute, and the page on
        which it appears in the <code>@page</code> attribute.</xd:detail>
    </xd:doc>

    <xsl:template name="analyze-text">
        <xsl:variable name="lang" select="(ancestor-or-self::*/@lang|ancestor-or-self::*/@xml:lang)[last()]"/>
        <!-- <xsl:variable name="parent" select="name(ancestor-or-self::*[1])"/> -->
        <xsl:variable name="page" select="preceding::pb[1]/@n"/>
        <xsl:variable name="style" select="f:find-text-style(.)"/>

        <xsl:analyze-string select="." regex="{'[\p{L}\p{N}\p{M}-]+'}">
            <xsl:matching-substring>
                <w>
                    <xsl:attribute name="xml:lang" select="$lang"/>
                    <!-- <xsl:attribute name="parent" select="$parent"/> -->
                    <xsl:attribute name="style" select="$style"/>
                    <xsl:attribute name="page" select="$page"/>
                    <xsl:attribute name="form" select="fn:lower-case(f:strip_diacritics(.))"/>
                    <xsl:value-of select="."/>
                </w>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <nw>
                    <xsl:attribute name="style" select="$style"/>
                    <xsl:value-of select="."/>
                </nw>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>


    <xd:doc>
        <xd:short>Establish the current text style of a word.</xd:short>
        <xd:detail>Establish the current text style of a word, by looking at the first <code>hi</code> ancestor. This is somewhat crude,
        but works reasonably well for texts in my collection.</xd:detail>
        <xd:param name="node">The node for which to establish the text style.</xd:param>
    </xd:doc>

    <xsl:function name="f:find-text-style">
        <xsl:param name="node"/>
        <xsl:variable name="hi" select="$node/ancestor-or-self::hi[1]"/>
        <!-- Ignore hi elements if we are in a note, and the hi is outside the note -->
        <xsl:if test="$hi and not($hi/descendant::note)">
            <xsl:variable name="rend" select="$hi/@rend"/>
            <xsl:choose>
                <xsl:when test="$rend = 'bold'">b</xsl:when>
                <xsl:when test="$rend = 'sup'">sup</xsl:when>
                <xsl:when test="$rend = 'sub'">sub</xsl:when>
                <xsl:when test="$rend = 'ex'">ex</xsl:when>
                <xsl:when test="$rend = 'uc'">uc</xsl:when>
                <xsl:when test="$rend = 'sc'">sc</xsl:when>
                <xsl:otherwise>i</xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine whether a word is a stopword.</xd:short>
        <xd:detail>Determine whether a word appears in a list of stopwords for a particular language.</xd:detail>
        <xd:param name="word">The word to test.</xd:param>
        <xd:param name="lang">The language of the word (used to select the stopword list).</xd:param>
    </xd:doc>

    <xsl:function name="f:is-stopword" as="xs:boolean">
        <xsl:param name="word" as="xs:string"/>
        <xsl:param name="lang" as="xs:string"/>

        <xsl:variable name="baselang" select="if (contains($lang, '-')) then substring-before($lang, '-') else $lang"/>
        <xsl:variable name="word" select="lower-case($word)"/>

        <xsl:choose>
            <xsl:when test="$baselang = 'en'">
                <xsl:sequence select="$word = $en-stopwords-sequence"/>
            </xsl:when>
            <xsl:when test="$baselang = 'nl'">
                <xsl:sequence select="$word = $nl-stopwords-sequence"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
