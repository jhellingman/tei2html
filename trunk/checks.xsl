<!DOCTYPE xsl:stylesheet [

    <!ENTITY tab        "&#x09;">
    <!ENTITY lf         "&#x0A;">
    <!ENTITY cr         "&#x0D;">
    <!ENTITY deg        "&#176;">
    <!ENTITY ldquo      "&#x201C;">
    <!ENTITY lsquo      "&#x2018;">
    <!ENTITY rdquo      "&#x201D;">
    <!ENTITY rsquo      "&#x2019;">
    <!ENTITY nbsp       "&#160;">
    <!ENTITY mdash      "&#x2014;">
    <!ENTITY prime      "&#x2032;">
    <!ENTITY Prime      "&#x2033;">
    <!ENTITY plusmn     "&#x00B1;">
    <!ENTITY frac14     "&#x00BC;">
    <!ENTITY frac12     "&#x00BD;">
    <!ENTITY frac34     "&#x00BE;">

    <!ENTITY raquo     "&#187;">
    <!ENTITY laquo     "&#171;">
    <!ENTITY bdquo     "&#8222;">

]>
<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:f="urn:stylesheet-functions"    
    xmlns:i="http://gutenberg.ph/issues"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="i f xhtml xs xd"
    version="2.0"
    >

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to perform various checks on a TEI file.</xd:short>
        <xd:detail>This stylesheet performs a number of checks on a TEI file, to help find potential issues with both the text and tagging.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2012, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xsl:include href="segmentize.xsl"/>


    <xsl:template match="divGen[@type='checks']">
        <xsl:apply-templates select="/" mode="checks"/>
    </xsl:template>


    <xsl:template match="/">

        <!-- page numbers in odd places -->

        <!-- division numbers in sequence -->


        <xsl:variable name="segments">
            <xsl:call-template name="segmentize"/>
        </xsl:variable>

        <!--
        <xsl:call-template name="output-segments">
            <xsl:with-param name="segments" select="$segments"/>
        </xsl:call-template>
        -->

        <!-- Collect issues in structure [issue pos=""]Description of issue[/issue] -->

        <xsl:variable name="issues">
            <i:issues>

                <xsl:call-template name="sequence-in-order">
                    <xsl:with-param name="nodes" select="//pb"/>
                </xsl:call-template>

                <xsl:apply-templates mode="checks"/>

                <!-- Check textual issues on segments -->
                <xsl:apply-templates mode="checks" select="$segments//segment"/>
            </i:issues>
        </xsl:variable>

        <html>
            <head>
                <title>Checks</title>
            </head>
            <body>
                <table>
                    <tr>
                        <th>Code</th>
                        <th>Line</th>
                        <th>Column</th>
                        <th>Issue</th>
                    </tr>
                    <xsl:apply-templates select="$issues//i:issue" mode="report">
                        <xsl:sort select="@code"/>
                    </xsl:apply-templates>
                </table>
            </body>
        </html>
    </xsl:template>

    <xsl:template mode="report" match="i:issue">
        <tr>
            <td><xsl:value-of select="@code"/></td>
            <td><xsl:value-of select="substring-before(@pos, ':')"/></td>
            <td><xsl:value-of select="substring-after(@pos, ':')"/></td>
            <td><xsl:value-of select="."/></td>
        </tr>
    </xsl:template>

    <!-- Information in TEI header -->

    <xsl:template mode="checks" match="publicationStmt">
        <xsl:if test="not(idno[@type='epub-id'])">
            <i:issue pos="{@pos}" code="H0001">No ePub-id present.</i:issue>
        </xsl:if>

        <xsl:if test="idno[@type='epub-id'] and not(matches(idno[@type='epub-id'], '^(urn:uuid:([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$'))">
            <i:issue pos="{@pos}" code="H0002">ePub-id does not use GUID format (urn:uuid:########-####-####-####-############).</i:issue>
        </xsl:if>

        <xsl:apply-templates mode="checks"/>
    </xsl:template>


    <!-- Numbering of divisions -->

    <xsl:template mode="checks" match="front | body | back">

        <xsl:if test="not(name() = 'body')">
            <xsl:call-template name="check-id-present"/>
        </xsl:if>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="nodes" select="div1"/>
        </xsl:call-template>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="nodes" select="div0"/>
        </xsl:call-template>

        <xsl:apply-templates mode="checks"/>
    </xsl:template>


    <!-- Types of divisions -->

    <xsl:variable name="expectedFrontDiv1Types" select="'Cover', 'Copyright', 'Epigraph', 'Introduction', 'Frontispiece', 'Dedication', 'Preface', 'Imprint', 'Introduction', 'Note', 'Contents', 'Bibliography', 'FrenchTitle', 'TitlePage'"/>
    <xsl:variable name="expectedBodyDiv0Types" select="'Part', 'Book', 'Issue'"/>
    <xsl:variable name="expectedBodyDiv1Types" select="'Chapter'"/>
    <xsl:variable name="expectedBackDiv1Types" select="'Cover', 'Index', 'Appendix', 'Bibliography', 'Epilogue', 'Contents', 'Imprint', 'Errata', 'Advertisements'"/>

    <xsl:template mode="checks" match="front/div1">
        <xsl:call-template name="check-div-type-present"/>
        <xsl:if test="not(@type = $expectedFrontDiv1Types)">
            <i:issue pos="{@pos}" code="C0001">Unexpected type for div1: <xsl:value-of select="@type"/></i:issue>
        </xsl:if>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="nodes" select="div2"/>
        </xsl:call-template>

        <xsl:apply-templates mode="checks"/>
    </xsl:template>

    <xsl:template mode="checks" match="body/div0">
        <xsl:call-template name="check-div-type-present"/>
        <xsl:call-template name="check-id-present"/>
        <xsl:if test="not(@type = $expectedBodyDiv0Types)">
            <i:issue pos="{@pos}" code="C0001">Unexpected type for div0: <xsl:value-of select="@type"/></i:issue>
        </xsl:if>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="nodes" select="div1"/>
        </xsl:call-template>

        <xsl:apply-templates mode="checks"/>
    </xsl:template>

    <xsl:template mode="checks" match="body/div1">
        <xsl:call-template name="check-div-type-present"/>
        <xsl:if test="not(@type = $expectedBodyDiv1Types)">
            <i:issue pos="{@pos}" code="C0001">Unexpected type for div1: <xsl:value-of select="@type"/></i:issue>
        </xsl:if>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="nodes" select="div2"/>
        </xsl:call-template>

        <xsl:apply-templates mode="checks"/>
    </xsl:template>

    <xsl:template mode="checks" match="back/div1">
        <xsl:call-template name="check-div-type-present"/>
        <xsl:if test="not(@type = $expectedBackDiv1Types)">
            <i:issue pos="{@pos}" code="C0001">Unexpected type for div1: <xsl:value-of select="@type"/></i:issue>
        </xsl:if>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="nodes" select="div2"/>
        </xsl:call-template>

        <xsl:apply-templates mode="checks"/>
    </xsl:template>

    <xsl:template name="check-div-type-present">
        <xsl:if test="not(@type)">
            <i:issue pos="{@pos}" code="C0002">No type specified for <xsl:value-of select="name()"/></i:issue>
        </xsl:if>
    </xsl:template>

    <xsl:template name="check-id-present">
        <xsl:if test="not(@id)">
            <i:issue pos="{@pos}" code="C0011">No id specified for <xsl:value-of select="name()"/></i:issue>
        </xsl:if>
    </xsl:template>

    <xsl:template mode="checks" match="div1">
        <xsl:call-template name="check-div-type-present"/>
        <xsl:call-template name="check-id-present"/>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="nodes" select="div2"/>
        </xsl:call-template>

        <xsl:apply-templates mode="checks"/>
    </xsl:template>

    <xsl:template mode="checks" match="div2">
        <xsl:call-template name="check-div-type-present"/>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="nodes" select="div3"/>
        </xsl:call-template>

        <xsl:apply-templates mode="checks"/>
    </xsl:template>


    <!-- divGen types -->

    <xsl:variable name="expectedDivGenTypes" select="'toc', 'Colophon', 'IndexToc'"/>

    <xsl:template mode="checks" match="divGen">
        <xsl:call-template name="check-div-type-present"/>
        <xsl:if test="not(@type = $expectedDivGenTypes)">
            <i:issue pos="{@pos}" code="C0006">Unexpected type for divGen: <xsl:value-of select="@type"/></i:issue>
        </xsl:if>
        <xsl:apply-templates mode="checks"/>
    </xsl:template>


    <!-- Elements not valid in TEI, but sometimes abused -->

    <xsl:template mode="checks" match="i | b | sc | uc | tt">
        <i:issue pos="{@pos}" code="T0001">Non-TEI element <xsl:value-of select="name()"/></i:issue>
        <xsl:apply-templates mode="checks"/>
    </xsl:template>


    <!-- Correction corrects nothing -->

    <xsl:template mode="checks" match="corr">
        <xsl:if test="string(.) = string(@sic)">
            <i:issue pos="{@pos}" code="T0002">Correction same as original text.</i:issue>
        </xsl:if>
        <xsl:apply-templates mode="checks"/>
    </xsl:template>


    <!-- Page-break sequence -->

    <xsl:template mode="checks" match="pb">
        <xsl:variable name="preceding" select="preceding::pb[1]/@n"/>

        <xsl:choose>
            <xsl:when test="not(@n)">
                <i:issue pos="{@pos}" code="C0003">Page break without page number.</i:issue>
            </xsl:when>

            <xsl:when test="not(f:is-number(@n) or f:is-roman(@n))">
                <i:issue pos="{@pos}" code="C0004">Page break <xsl:value-of select="@n"/> not numeric.</i:issue>
            </xsl:when>

            <xsl:when test="f:is-roman(@n) and f:is-roman($preceding)">
                <xsl:if test="not(f:from-roman(@n) = f:from-roman($preceding) + 1)">
                    <i:issue pos="{@pos}" code="C0005">Page break <xsl:value-of select="@n"/> out-of-sequence. (preceding: <xsl:value-of select="$preceding"/>)</i:issue>
                </xsl:if>
            </xsl:when>

            <xsl:when test="f:is-number(@n) and f:is-number($preceding)">
                <xsl:if test="not(@n = $preceding + 1)">
                    <i:issue pos="{@pos}" code="C0005">Page break <xsl:value-of select="@n"/> out-of-sequence. (preceding: <xsl:value-of select="if (not($preceding)) then 'not set' else $preceding"/>)</i:issue>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <!-- Generic sequence -->

    <xsl:template name="sequence-in-order">
        <xsl:param name="nodes"/>

        <xsl:for-each select="1 to count($nodes) - 1">
            <xsl:variable name="counter" select="."/>
            <xsl:call-template name="pair-in-order">
                <xsl:with-param name="first" select="$nodes[$counter]"/>
                <xsl:with-param name="second" select="$nodes[$counter + 1]"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="pair-in-order">
        <xsl:param name="first"/>
        <xsl:param name="second"/>

        <xsl:choose>
            <xsl:when test="not($first/@n)">
                <i:issue pos="{$first/@pos}" code="C0007">Element <xsl:value-of select="name($first)"/> without number.</i:issue>
            </xsl:when>

            <xsl:when test="not(f:is-number($first/@n) or f:is-roman($first/@n))">
                <i:issue pos="{$first/@pos}" code="C0008">Element <xsl:value-of select="name($first)"/>: n-attribute <xsl:value-of select="$first/@n"/> not numeric.</i:issue>
            </xsl:when>

            <xsl:when test="f:is-roman($first/@n) and f:is-roman($second/@n)">
                <xsl:if test="not(f:from-roman($second/@n) = f:from-roman($first/@n) + 1)">
                    <i:issue pos="{$second/@pos}" code="C0009">Element <xsl:value-of select="name($first)"/>: n-attribute value <xsl:value-of select="$second/@n"/> out-of-sequence. (preceding: <xsl:value-of select="$first/@n"/>)</i:issue>
                </xsl:if>
            </xsl:when>

            <xsl:when test="f:is-number($first/@n) and f:is-number($second/@n)">
                <xsl:if test="not($second/@n = $first/@n + 1)">
                    <i:issue pos="{$second/@pos}" code="C0010">Element <xsl:value-of select="name($first)"/>: n-attribute value <xsl:value-of select="$second/@n"/> out-of-sequence. (preceding: <xsl:value-of select="$first/@n"/>)</i:issue>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <!-- Text level checks, run on segments -->

    <xsl:template mode="checks" match="segment">

        <xsl:copy-of select="f:should-not-contain(., '\s+[.,:;!?]',                     'P0004', 'Space before punctuation mark.')"/>
        <xsl:copy-of select="f:should-not-contain(., '\s+[)&rdquo;&rsquo;]',            'P0005', 'Space before closing punctuation mark.')"/>
        <xsl:copy-of select="f:should-not-contain(., '[(&lsquo;&ldquo;&bdquo;]\s+',     'P0006', 'Space after opening punctuation mark.')"/>

        <xsl:copy-of select="f:should-not-contain(., ',[^\s&mdash;&rdquo;&rsquo;0-9)\]]',   'P0007', 'Missing space after comma.')"/>

        <xsl:call-template name="match-punctuation-pairs">
            <xsl:with-param name="string" select="."/>
            <xsl:with-param name="next" select="string(following-sibling::*[1])"/>
        </xsl:call-template>

        <xsl:apply-templates mode="checks"/>
    </xsl:template>


    <xsl:function name="f:should-not-contain">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="pattern" as="xs:string"/>
        <xsl:param name="code" as="xs:string"/>
        <xsl:param name="message" as="xs:string"/>

        <xsl:if test="matches($node, $pattern)">
            <i:issue pos="{$node/@pos}" code="{$code}"><xsl:value-of select="$message"/> in: <xsl:value-of select="f:match-fragment($node, $pattern)"/></i:issue>
        </xsl:if>
    </xsl:function>


    <xsl:template mode="checks" match="text()"/>

    <xd:doc>
        <xd:short>Verify paired punctuation marks match.</xd:short>
        <xd:detail>
            <p>Verify paired punctuation marks, such as parenthesis match and are not wrongly nested. This assumes that the 
            right single quote character (&rsquo;) is not being used for the apostrophe (hint: temporarily change those to
            something else). The paired punctuation marks supported are [], (), {}, &lsquo;&rsquo;, and &ldquo;&rdquo;.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="match-punctuation-pairs">
        <xsl:param name="string" as="xs:string"/>
        <xsl:param name="next" as="xs:string"/>

        <!-- Remove anything not a pairing punctionation mark -->
        <xsl:variable name="pairs" select="replace($string, '[^\[\](){}&lsquo;&rsquo;&rdquo;&ldquo;&laquo;&raquo;&bdquo;]', '')"/>

        <!--
        <xsl:message terminate="no">Checking string: <xsl:value-of select="$string"/> </xsl:message>
        <xsl:message terminate="no">Checking pairs:  <xsl:value-of select="$pairs"/> </xsl:message>
        -->

        <xsl:variable name="head" select="if (string-length($string) &lt; 40) then $string else concat(substring($string, 1, 37), '...')"/>

        <xsl:variable name="unclosed" select="f:unclosed-pairs($pairs, '')"/>
        <xsl:choose>
            <xsl:when test="substring($unclosed, 1, 10) = 'Unexpected'">
                <i:issue pos="{@pos}" code="P0002"><xsl:value-of select="$unclosed"/> in: <xsl:value-of select="$head"/></i:issue>
            </xsl:when>
            <xsl:when test="matches($unclosed, '^[&lsquo;&ldquo;&raquo;&bdquo;]+$')">
                <xsl:if test="not(starts-with($next, $unclosed))">
                    <i:issue pos="{@pos}" code="P0008">Unclosed punctuation: <xsl:value-of select="$unclosed"/> not re-openend in next paragraph. Current: <xsl:value-of select="$head"/> Next: <xsl:value-of select="substring($next, 1, 40)"/></i:issue>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$unclosed != ''">
                <i:issue pos="{@pos}" code="P0003">Unclosed punctuation: <xsl:value-of select="$unclosed"/> in: <xsl:value-of select="$head"/></i:issue>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <!-- The following two variables should list the openers and matching closers in the same order -->
    <!-- The current values work well for my 19th century Dutch books that use: &raquo;...&rdquo; -->

    <xsl:variable name="opener" select="'(', '[', '{', '&lsquo;', '&ldquo;', '&raquo;', '&bdquo;'"/>
    <xsl:variable name="closer" select="')', ']', '}', '&rsquo;', '&rdquo;', '&rdquo;', '&rdquo;'"/>
    <xsl:variable name="opener-string" select="string-join($opener, '')"/>
    <xsl:variable name="closer-string" select="string-join($closer, '')"/>

    <xsl:variable name="open-quotation-marks" select="'&lsquo;&ldquo;&raquo;&bdquo;'"/>

    <xd:doc>
        <xd:short>Find unclosed pairs of paired punctuation marks.</xd:short>
        <xd:detail>
            <p>Find unclosed pairs of paired punctuation marks in a string of punctuation marks using recursive calls. 
            This pushes open marks on a stack, and pops them when the closing mark comes by.
            When an unexpected closing mark is encountered, we return an error; when the string is fully consumed,
            the remainder of the stack is returned. Normally, this is expected to be empty.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:unclosed-pairs">
        <xsl:param name="pairs" as="xs:string"/>
        <xsl:param name="stack" as="xs:string"/>

        <xsl:variable name="head" select="substring($pairs, 1, 1)"/>
        <xsl:variable name="tail" select="substring($pairs, 2)"/>
        <xsl:variable name="expect" select="translate(substring($stack, 1, 1), $opener-string, $closer-string)"/>

        <!--
        <xsl:message terminate="no">Checking mark:   [<xsl:value-of select="$head"/>] : [<xsl:value-of select="$tail"/>]  (stack [<xsl:value-of select="$stack"/>], expect [<xsl:value-of select="$expect"/>]) </xsl:message>
        -->

        <xsl:sequence select="if (not($head))
                                then $stack
                                else if ($head = $opener)
                                    then f:unclosed-pairs($tail, concat($head, $stack))
                                    else if ($head = $expect)
                                        then f:unclosed-pairs($tail, substring($stack, 2))
                                        else concat(concat(concat('Unexpected closing punctuation: ', $head), if ($stack) then ' open: ' else ''), f:reverse($stack))"/>
    </xsl:function>


    <xsl:function name="f:line-number" as="xs:string*">
        <xsl:param name="node" as="node()"/>
        <xsl:if test="$node/@pos">
            <xsl:variable name="line" select="substring-before($node/@pos, ':')"/>
            <xsl:variable name="column" select="substring-after($node/@pos, ':')"/>

            <xsl:text>line </xsl:text><xsl:value-of select="$line"/> column <xsl:value-of select="$column"/>
        </xsl:if>
    </xsl:function>



    <xsl:function name="f:match-position" as="xs:integer">
        <xsl:param name="string" as="xs:string"/>
        <xsl:param name="pattern" as="xs:string"/>

        <xsl:sequence select="if (matches ($string, $pattern)) then string-length(tokenize($string, $pattern)[1]) else -1"/>
    </xsl:function>


    <xsl:function name="f:match-fragment" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:param name="pattern" as="xs:string"/>

        <xsl:variable name="match-position" select="f:match-position($string, $pattern)"/>

        <xsl:choose>
            <xsl:when test="$match-position = -1">
                <xsl:sequence select="''"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="start" select="if ($match-position - 20 &lt; 0) then 0 else $match-position - 20"/>
                <xsl:sequence select="substring($string, $start, 40)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xsl:function name="f:reverse" as="xs:string">
        <xsl:param name="string" as="xs:string"/>

        <xsl:sequence select="codepoints-to-string(reverse(string-to-codepoints($string)))"/>
    </xsl:function>

    <xd:doc>
        <xd:short>Convert a Roman number to an integer.</xd:short>
        <xd:detail>
            <p>Convert a Roman number to an integer. This function calls a recursive implementation, which 
            establishes the value of the first letter, and then adds or subtracts that value to/from the
            value of the tail, depending on whether the next character represent a higher or lower
            value.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:from-roman" as="xs:integer">
        <xsl:param name="roman" as="xs:string"/>

        <xsl:sequence select="f:from-roman-implementation($roman, 0)"/>
    </xsl:function>


    <xsl:function name="f:from-roman-implementation" as="xs:integer">
        <xsl:param name="roman" as="xs:string"/>
        <xsl:param name="value" as="xs:integer"/>

        <xsl:variable name="length" select="string-length($roman)"/>
      
        <xsl:choose>
            <xsl:when test="not($length) or $length = 0">
                <xsl:sequence select="$value"/>
            </xsl:when>
            
            <xsl:when test="$length = 1">
                <xsl:sequence select="$value + f:roman-value($roman)"/>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:variable name="head-value" select="f:roman-value(substring($roman, 1, 1))"/>
                <xsl:variable name="tail" select="substring($roman, 2, $length - 1)"/>
                
                <xsl:sequence select="if ($head-value &lt; f:roman-value(substring($roman, 2, 1)))
                    then f:from-roman-implementation($tail, $value - $head-value)
                    else f:from-roman-implementation($tail, $value + $head-value)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xsl:function name="f:is-number" as="xs:boolean">
        <xsl:param name="string"/>
        
        <xsl:sequence select="matches($string, '^[\d]+$', 'i')"/>
    </xsl:function>


    <xsl:function name="f:is-roman" as="xs:boolean">
        <xsl:param name="string"/>
        
        <xsl:sequence select="string-length($string) != 0 and matches($string, '^M{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})$', 'i')"/>
    </xsl:function>


    <xsl:function name="f:roman-value">
        <xsl:param name="character" as="xs:string"/>
        
        <xsl:sequence select="(1, 5, 10, 50, 100, 500, 1000)[index-of(('I', 'V', 'X', 'L', 'C', 'D', 'M'), upper-case($character))]"/>
    </xsl:function>


</xsl:stylesheet>