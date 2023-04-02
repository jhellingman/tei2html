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
    <!ENTITY ndash      "&#x2013;">
    <!ENTITY prime      "&#x2032;">
    <!ENTITY Prime      "&#x2033;">
    <!ENTITY plusmn     "&#x00B1;">
    <!ENTITY frac14     "&#x00BC;">
    <!ENTITY frac12     "&#x00BD;">
    <!ENTITY frac34     "&#x00BE;">
    <!ENTITY hairsp     "&#x200A;">
    <!ENTITY hellip     "&#x2026;">

    <!ENTITY raquo      "&#187;">
    <!ENTITY laquo      "&#171;">
    <!ENTITY bdquo      "&#8222;">

    <!ENTITY fwperiod   "&#xFF0E;">

]>
<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="urn:stylesheet-functions"
                xmlns:i="http://gutenberg.ph/issues"
                xmlns:s="http://gutenberg.ph/segments"
                xmlns:tmp="urn:temporary"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="i f s tmp xd xs">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to perform various checks on a TEI file.</xd:short>
        <xd:detail><p>This stylesheet performs checks on a TEI file, to help find potential issues with both the text and tagging.</p>
        <p>Since the standard XSLT processor does not provide line and column information to report errors on, this stylesheet expects that all
        elements have a <code>@pos</code> attribute that contains the line and column the element appears on in the source file. This element
        should have the format <code>line:column</code>. I've made a small Perl script (<code>addPositionInfo.pl</code>) to add those attributes to
        elements in a pre-processing step.</p></xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2015&ndash;2017, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:include href="modules/functions.xsl"/>
    <xsl:include href="modules/log.xsl"/>
    <xsl:include href="modules/configuration.xsl"/>
    <xsl:include href="modules/segmentize.xsl"/>
    <xsl:include href="modules/numbers.xsl"/>

    <xsl:variable name="outputFormat" select="'html'"/>

    <xsl:variable name="root" select="/"/>

    <xsl:variable name="segments">
        <xsl:apply-templates mode="segmentize" select="/"/>
    </xsl:variable>

    <!-- Do not report periods in abbreviations (replace them by &fwperiod; replace them back later) -->
    <xsl:template match="abbr" mode="segments">
        <xsl:value-of select="replace(., '\.', '&fwperiod;')"/>
    </xsl:template>

    <!-- Add some space around end-note references to avoid some false positive "no space after punctuation" issues -->
    <xsl:template match="ref[@type='endNoteRef']" mode="segments">
        <xsl:text> {</xsl:text>
        <xsl:apply-templates mode="#current"/>
        <xsl:text>} </xsl:text>
    </xsl:template>


    <!-- Collect issues in structure [issue pos=""]Description of issue[/issue] -->
    <xsl:variable name="issues">
        <i:issues>
            <xsl:apply-templates mode="info" select="/"/>
            <xsl:apply-templates mode="checks" select="/"/>
            <xsl:apply-templates mode="check-langs" select="/"/>
            <xsl:apply-templates mode="check-types" select="/"/>
            <xsl:apply-templates mode="check-ids" select="/"/>

            <!-- Check textual issues on segments -->

            <xsl:apply-templates mode="checks" select="$segments//s:segment"/>
        </i:issues>
    </xsl:variable>


    <!-- ignore textual content in those modes -->
    <xsl:template mode="info checks check-ids check-types" match="text()" priority="-1"/>

    <!-- Recurse into nodes -->
    <xsl:template mode="info checks check-types check-ids" match="*">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>


    <xsl:template match="divGen[@type='checks']">
        <xsl:apply-templates select="/" mode="checks"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Determine potential problems in a TEI file.</xd:short>
        <xd:detail>
            <p>Issues are collected in two phases. First, using the mode <code>checks</code>, all
            issues are stored in a variable <code>issues</code>; then, the contents of this
            variable are processed using the mode <code>report</code>.</p>

            <p>Several textual issues are verified on a flattened representation of the text,
            collected in the variable <code>segments</code>. A segment roughly corresponds to
            a paragraph, but without further internal structure. Furthermore, list-items,
            table-cells, headers, etc., are also treated as segments.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="/">
        <xsl:variable name="unique-issues">
            <i:issues>
                <xsl:for-each-group select="$issues//i:issue" group-by="f:issue-grouping-key(.)">
                    <xsl:copy-of select="."/>
                </xsl:for-each-group>
            </i:issues>
        </xsl:variable>

        <xsl:call-template name="output-issues">
            <xsl:with-param name="issues" select="$unique-issues"/>
        </xsl:call-template>
        <xsl:apply-templates mode="report" select="$unique-issues"/>
    </xsl:template>


    <xsl:function name="f:issue-grouping-key" as="xs:string">
        <xsl:param name="issue" as="element(i:issue)"/>
        <xsl:sequence select="$issue/@pos || ':' || $issue/@target || ':' || string($issue)"/>
    </xsl:function>


    <xsl:function name="f:get-page" as="xs:string?">
        <xsl:param name="node" as="node()"/>
        <xsl:value-of select="($node/preceding::pb[@n]/@n)[last()]"/>
    </xsl:function>


    <xsl:template name="output-issues">
        <xsl:param name="issues" as="node()"/>

        <xsl:result-document
                doctype-public=""
                doctype-system=""
                href="issues.xml"
                method="xml"
                indent="yes"
                encoding="UTF-8">
            <!-- <xsl:message>INFO:    Generated file: issues.xml.</xsl:message> -->
            <xsl:copy-of select="$issues"/>
        </xsl:result-document>
    </xsl:template>


    <!-- INFO -->

    <xsl:template mode="info" match="titleStmt/title">
        <xsl:copy-of select="f:issue(., 'A01', 'Metadata', 'Info', 'Title: ' || . || '.')"/>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="info" match="titleStmt/author">
        <xsl:copy-of select="f:issue(., 'A01', 'Metadata', 'Info', 'Author: ' || . || '.')"/>
        <xsl:next-match/>
    </xsl:template>


    <!-- REPORT -->

    <xd:doc mode="report">
        <xd:short>Mode for reporting the found issues in an HTML table.</xd:short>
    </xd:doc>

    <xd:doc>
        <xd:short>Report the found issues as an HTML document.</xd:short>
    </xd:doc>

    <xsl:template mode="report" match="i:issues">
        <html>
            <head>
                <title>Checks of <xsl:value-of select="$root//titleStmt/title[1]"/></title>
                <style>
.info {
    color: #00529B;
    background-color: #BDE5F8;
}
.success {
    color: #4F8A10;
    background-color: #DFF2BF;
}
.warning {
    color: #9F6000;
    background-color: #FEEFB3;
}
.error {
    color: #D8000C;
    background-color: #FFD2D2;
}
.trivial {
    color: gray;
}
                </style>
            </head>
            <body>

                <p>Found
                    <xsl:value-of select="count(i:issue[@level='Error'])"/> errors,
                    <xsl:value-of select="count(i:issue[@level='Warning'])"/> warnings,
                    <xsl:value-of select="count(i:issue[@level='Trivial'])"/> minor issues, and
                    <xsl:value-of select="count(i:issue[@level='Info'])"/> informational lines.</p>

                <table>
                    <tr>
                        <th>Level</th>
                        <th>Category</th>
                        <th>Line</th>
                        <th>Column</th>
                        <th>Page</th>
                        <th>Element</th>
                        <th>ID</th>
                        <th>Issue</th>
                    </tr>
                    <xsl:apply-templates select="i:issue" mode="report">
                        <xsl:sort select="f:key(.)"/>
                    </xsl:apply-templates>
                </table>
            </body>
        </html>
    </xsl:template>

    <xsl:function name="f:key">
        <xsl:param name="issue" as="element(i:issue)"/>

        <xsl:variable name="level">
            <xsl:choose>
                <xsl:when test="$issue/@level = 'Info'">1</xsl:when>
                <xsl:when test="$issue/@level = 'Error'">2</xsl:when>
                <xsl:when test="$issue/@level = 'Warning'">3</xsl:when>
                <xsl:otherwise>4</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="$level || '@' || $issue/@category || '@' || $issue/@code || '@' || $issue/@line"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Report an issue as a row in an HTML table.</xd:short>
    </xd:doc>

    <xsl:template mode="report" match="i:issue">
        <tr class="{lower-case(@level)}">
            <td><xsl:value-of select="@level"/></td>
            <td><xsl:value-of select="@category"/></td>
            <td><xsl:value-of select="substring-before(@pos, ':')"/></td>
            <td><xsl:value-of select="substring-after(@pos, ':')"/></td>
            <td><xsl:value-of select="@page"/></td>
            <td><xsl:value-of select="@element"/></td>
            <td><xsl:value-of select="@target"/></td>
            <td><xsl:value-of select="f:replaced-to-normal-symbols(.)"/></td>
        </tr>
    </xsl:template>


    <xsl:function name="f:issue">
        <xsl:param name="node"/>
        <xsl:param name="code"/>
        <xsl:param name="category"/>
        <xsl:param name="level"/>
        <xsl:param name="message"/>

        <i:issue
            pos="{$node/@pos}"
            code="{$code}"
            category="{$category}"
            target="{f:generate-id($node)}"
            level="{$level}"
            element="{if ($node/@sourceElement) then $node/@sourceElement else name($node)}"
            page="{if ($node/@sourcePage) then $node/@sourcePage else f:get-page($node)}"><xsl:value-of select="$message"/></i:issue>
    </xsl:function>


    <xsl:template match="*[@lang]" mode="check-langs">
        <xsl:if test="(ancestor::*[@lang])[1] = @lang">
            <xsl:copy-of select="f:issue(., 'L1', 'Compliance', 'Warning', 'Unnecessary @lang attribute.')"/>
        </xsl:if>
        <xsl:next-match/>
    </xsl:template>


    <xd:doc mode="checks">
        <xd:short>Mode for collecting issues in a simple intermediate structure.</xd:short>
    </xd:doc>


    <xd:doc>
        <xd:short>Check the information in the TEI-header is complete.</xd:short>
    </xd:doc>

    <xsl:template mode="checks" match="publicationStmt[not(idno[@type='epub-id'])]">
        <xsl:copy-of select="f:issue(., 'H01', 'Header', 'Error', 'No ePub-id present.')"/>
        <xsl:next-match/>
    </xsl:template>

    <xsl:variable name="guidFormat" select="'^(urn:uuid:([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$'"/>

    <xsl:template mode="checks" match="idno[@type='epub-id'][not(matches(., $guidFormat))]">
        <xsl:copy-of select="f:issue(., 'H02', 'Header', 'Error', 'ePub-id does not use GUID format (urn:uuid:########-####-####-####-############).')"/>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="titleStmt/author[not(@key) and not(. = ('Anonymous', 'Anoniem'))]" priority="1">
        <xsl:copy-of select="f:issue(., 'H03', 'Header', 'Warning', 'No @key attribute present for author ' || . || '.')"/>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="titleStmt/editor[not(@key)]" priority="1">
        <xsl:copy-of select="f:issue(., 'H04', 'Header', 'Warning', 'No @key attribute present for editor ' || . || '.')"/>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="titleStmt/respStmt/name[not(@key)]" priority="1">
        <xsl:copy-of select="f:issue(., 'H05', 'Header', 'Warning', 'No @key attribute present for name ' || . || '.')"/>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="titleStmt/author[not(@ref) and not(. = ('Anonymous', 'Anoniem'))]" priority="2">
        <xsl:copy-of select="f:issue(., 'H06', 'Header', 'Warning', 'No @ref attribute present for author ' || . || '.')"/>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="titleStmt/editor[not(@ref)]" priority="2">
        <xsl:copy-of select="f:issue(., 'H07', 'Header', 'Warning', 'No @ref attribute present for editor ' || . || '.')"/>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="titleStmt/respStmt[resp != 'Transcription']/name[not(@ref)]" priority="2">
        <xsl:copy-of select="f:issue(., 'H08', 'Header', 'Warning', 'No @ref attribute present for name ' || . || '.')"/>
        <xsl:next-match/>
    </xsl:template>

    <xsl:variable name="viafUrlFormat" select="'^https://viaf\.org/viaf/[0-9]+/$'"/>

    <xsl:template mode="checks" match="titleStmt/author[@ref and not(matches(@ref, $viafUrlFormat))]">
        <xsl:copy-of select="f:issue(., 'H09', 'Header', 'Error', 'The @ref attribute &ldquo;' || @ref || '&rdquo; on author ' || . || ' is not a valid viaf.org url.')"/>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="titleStmt/editor[@ref and not(matches(@ref, $viafUrlFormat))]">
        <xsl:copy-of select="f:issue(., 'H10', 'Header', 'Error', 'The @ref attribute &ldquo;' || @ref || '&rdquo; on editor ' || . || ' is not a valid viaf.org url.')"/>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="titleStmt/respStmt/name[@ref and not(matches(@ref, $viafUrlFormat))]">
        <xsl:copy-of select="f:issue(., 'H11', 'Header', 'Error', 'The @ref attribute &ldquo;' || @ref || '&rdquo; on name ' || . || ' is not a valid viaf.org url.')"/>
        <xsl:next-match/>
    </xsl:template>


    <!-- Various types of cross-references -->

    <xsl:template match="seg[@copyOf]" mode="checks">
        <xsl:if test="not(//*[@id = current()/@copyOf])">
            <xsl:copy-of select="f:issue(., 'X01', 'Reference', 'Error', 'The @copyOf attribute &ldquo;' || @copyOf || '&rdquo; of seg element has no matching @id.')"/>
        </xsl:if>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template match="ref[@type='noteRef']" mode="checks">
        <xsl:copy-of select="f:issue(., 'X02', 'Reference', 'Trivial', 'A ref with @type noteRef is better replaced with a note with a @sameAs attribute.')"/>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template match="ditto" mode="checks">
        <xsl:copy-of select="f:issue(., 'X03', 'Reference', 'Trivial', 'The non-standard ditto element is better replaced with a seg with a @copyOf attribute.')"/>
        <xsl:next-match/>
    </xsl:template>


    <!-- Tables, rows and cells. -->

    <xsl:template match="cell[@role='sumCurrency']" mode="checks">

        <!-- Sum a currency split over two columns, e.g., dollars and cents, using 1 dollar = 100 cents.
             The cell we match is the dollar amount; assume the cents are in the next cell. -->

        <xsl:copy-of select="f:report-non-number(.)"/>
        <xsl:copy-of select="f:report-non-number(following-sibling::cell[1])"/>

        <xsl:variable
            name="indicatedSum"
            select="f:extract-number(.)
                    + (f:extract-number(following-sibling::cell[1]) div 100.0)"/>
        <xsl:variable
            name="calculatedSum"
            select="f:column-aggregate(., 'sum')
                    + (f:column-aggregate(following-sibling::cell[1], 'sum') div 100.0)"/>

        <xsl:copy-of select="f:report-difference(., $indicatedSum, $calculatedSum)"/>
        <xsl:next-match/>
    </xsl:template>


    <xsl:template match="cell[@role='sumDecimal']" mode="checks">

        <!-- Difference with above is that the number in the second column is preceded by a decimal separator.
             This is also introduced when tables are normalized and used the align(decimal) rendition. -->

        <xsl:copy-of select="f:report-non-number(.)"/>
        <xsl:copy-of select="f:report-non-number(following-sibling::cell[1])"/>

        <xsl:variable
            name="indicatedSum"
            select="f:extract-number(.)
                    + (f:extract-number(following-sibling::cell[1]))"/>
        <xsl:variable
            name="calculatedSum"
            select="f:column-aggregate(., 'sum')
                    + (f:column-aggregate(following-sibling::cell[1], 'sum'))"/>

        <!-- <xsl:message expand-text="yes">Indicated: {$indicatedSum}; calculated: {$calculatedSum}</xsl:message> -->

        <xsl:copy-of select="f:report-difference(., $indicatedSum, $calculatedSum)"/>
        <xsl:next-match/>
    </xsl:template>


    <xsl:template match="cell[@role='sumSterling']" mode="checks">

        <!-- Sum a sterling amount split over three columns, i.e., pounds, shillings, and pence,
             using 1 pound = 20 shillings or 240 pence. The cell we match is the amount in pounds;
             assume shillings and pence are in the next two cells. -->

        <xsl:copy-of select="f:report-non-number(.)"/>
        <xsl:copy-of select="f:report-non-number(following-sibling::cell[1])"/>
        <xsl:copy-of select="f:report-non-number(following-sibling::cell[2])"/>

        <xsl:variable
            name="indicatedSum"
            select="f:extract-number(.)
                    + (f:extract-number(following-sibling::cell[1]) div 20.0)
                    + (f:extract-number(following-sibling::cell[2]) div 240.0)"/>
        <xsl:variable
            name="calculatedSum"
            select="f:column-aggregate(., 'sum')
                    + (f:column-aggregate(following-sibling::cell[1], 'sum') div 20.0)
                    + (f:column-aggregate(following-sibling::cell[2], 'sum') div 240.0)"/>

        <xsl:copy-of select="f:report-difference(., $indicatedSum, $calculatedSum)"/>
        <xsl:next-match/>
    </xsl:template>


    <xsl:template match="cell[@role='sumPeso']" mode="checks">

        <!-- Sum a Peso/Tomin/Grano amount split over three columns,
             using 1 peso = 8 tomins or 8 * 12 = 96 granos. The cell we match is the amount in pesos;
             assume tomins and granos are in the next two cells. -->

        <xsl:copy-of select="f:report-non-number(.)"/>
        <xsl:copy-of select="f:report-non-number(following-sibling::cell[1])"/>
        <xsl:copy-of select="f:report-non-number(following-sibling::cell[2])"/>

        <xsl:variable
            name="indicatedSum"
            select="f:extract-number(.)
                    + (f:extract-number(following-sibling::cell[1]) div 8.0)
                    + (f:extract-number(following-sibling::cell[2]) div 96.0)"/>
        <xsl:variable
            name="calculatedSum"
            select="f:column-aggregate(., 'sum')
                    + (f:column-aggregate(following-sibling::cell[1], 'sum') div 8.0)
                    + (f:column-aggregate(following-sibling::cell[2], 'sum') div 96.0)"/>

        <xsl:copy-of select="f:report-difference(., $indicatedSum, $calculatedSum)"/>
        <xsl:next-match/>
    </xsl:template>


    <xsl:template match="cell[@role=('sum', 'subtr', 'avg')]" mode="checks">

        <xsl:copy-of select="f:report-non-number(.)"/>
        <xsl:variable name="indicatedSum" select="f:extract-number(.)"/>
        <xsl:variable name="calculatedSum" select="f:column-aggregate(., @role)"/>
        <xsl:copy-of select="f:report-difference(., $indicatedSum, $calculatedSum)"/>
        <xsl:next-match/>
    </xsl:template>

    <xsl:function name="f:report-non-number">
        <xsl:param name="cell" as="element(cell)"/>
        <xsl:variable name="value"><xsl:apply-templates select="$cell" mode="remove-extra-content"/></xsl:variable>
        <xsl:if test="not(f:has-number($value))">
            <xsl:copy-of select="f:issue($cell, 'T1', 'Table', 'Error', 'The cell contents &ldquo;' || $value || '&rdquo;, marked as a ' || $cell/@role || ', is not recognized as a number.')"/>
        </xsl:if>
    </xsl:function>

    <xsl:function name="f:report-difference">
        <xsl:param name="cell" as="element(cell)"/>
        <xsl:param name="first" as="xs:double"/>
        <xsl:param name="second" as="xs:double"/>

        <xsl:variable name="value"><xsl:apply-templates select="$cell" mode="remove-extra-content"/></xsl:variable>
        <!-- Take precision into account -->
        <xsl:if test="abs($first - $second) > 0.0000000000001">
            <xsl:copy-of select="f:issue($cell, 'T2', 'Table', 'Warning',
                'Verify value &ldquo;' || normalize-space($value) || '&rdquo;: [' || $cell/@role || '] ' || $first || ' not equal to ' || $second || ' (difference: ' || $first - $second || ').')"/>
        </xsl:if>
    </xsl:function>

    <xsl:function name="f:column-aggregate">
        <xsl:param name="cell" as="element(cell)"/>
        <xsl:param name="role" as="xs:string"/>

        <xsl:variable name="col" select="if ($cell/@col) then $cell/@col else count($cell/preceding-sibling::cell)"/>
        <xsl:variable name="row" select="if ($cell/@row) then $cell/@row + 1 else count($cell/../preceding-sibling::row) + 1"/>
        <xsl:variable name="cells" select="if ($cell/@col)
            then $cell/../../row[not(@role='label' or @role='unit')]/cell[@row &lt; $row][@col = $col][not(@role=$cell/@role)][not(@role='label' or @role='unit')]
            else $cell/../../row[position() &lt; $row][not(@role='label' or @role='unit')]/cell[position() = $col][not(@role=$cell/@role)][not(@role='label' or @role='unit')]"/>
        <xsl:variable name="numbers" as="xs:double*">
            <xsl:for-each select="$cells"><xsl:sequence select="f:extract-number(.)"/></xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="if ($role='sum')
                              then sum($numbers)
                              else if ($role='avg')
                                   then avg($numbers)
                                   else f:subtr($numbers)"/>
    </xsl:function>

    <xsl:function name="f:extract-number" as="xs:double">
        <xsl:param name="node"/>
        <xsl:variable name="value"><xsl:apply-templates select="$node" mode="remove-extra-content"/></xsl:variable>
        <xsl:value-of select="f:parse-number($value)"/>
    </xsl:function>

    <xsl:function name="f:is-number" as="xs:boolean">
        <xsl:param name="value" as="xs:string"/>
        <xsl:sequence select="matches($value, f:get-setting('math.numberPattern'))"/>
    </xsl:function>

    <xsl:function name="f:has-number" as="xs:boolean">
        <xsl:param name="value" as="xs:string"/>
        <xsl:variable name="value" select="translate($value, f:get-setting('math.thousandsSeparator'), '')"/>
        <xsl:variable name="value" select="translate($value, f:get-setting('math.decimalSeparator'), '.')"/>
        <xsl:variable name="value" select="translate($value, translate($value, '.+-0123456789', ''), '')"/>
        <xsl:value-of select="$value castable as xs:double"/>
    </xsl:function>

    <xsl:function name="f:parse-number" as="xs:double">
        <xsl:param name="value" as="xs:string"/>
        <xsl:variable name="value" select="translate($value, f:get-setting('math.thousandsSeparator'), '')"/>
        <xsl:variable name="value" select="translate($value, f:get-setting('math.decimalSeparator'), '.')"/>
        <xsl:variable name="value" select="translate($value, translate($value, '.+-0123456789', ''), '')"/>
        <xsl:value-of select="if ($value castable as xs:double) then number($value) else 0.0"/>
    </xsl:function>

    <xsl:function name="f:subtr" as="xs:double">
        <xsl:param name="values" as="xs:double*"/>
        <xsl:variable name="head" as="xs:double" select="if ($values[1]) then $values[1] else 0.0"/>
        <xsl:variable name="tail" select="$values[position() != 1]"/>
        <xsl:value-of select="$head - sum($tail)"/>
    </xsl:function>

    <xsl:template match="@*|node()" mode="remove-extra-content">
        <xsl:copy>
            <xsl:apply-templates mode="remove-extra-content"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="note" mode="remove-extra-content"/>

    <xsl:template match="ref[@type='endNoteRef']" mode="remove-extra-content"/>

    <xd:doc>
        <xd:short>Check page numbering.</xd:short>
    </xd:doc>

    <xsl:template mode="checks" match="/">
        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="elements" select="//pb[not(ancestor::note)]"/>
        </xsl:call-template>
        <xsl:next-match/>
    </xsl:template>

    <!-- We allow a pb directly after a titlePage, due to the level this has in the TEI DTD -->
    <xsl:template mode="checks" match="front/pb[not(preceding::titlePage)] | body/pb | back/pb">
        <xsl:copy-of select="f:issue(., 'T14', 'Pagebreaks', 'Error', 'pb element directly under front, body, or back.')"/>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="text/pb">
        <xsl:copy-of select="f:issue(., 'T15', 'Pagebreaks', 'Error', 'pb element directly under text.')"/>
        <xsl:next-match/>
    </xsl:template>


    <xsl:template mode="checks" match="note">
        <xsl:if test=".//pb">
            <!-- first pb should be preceding pb + 1 in main text -->
            <xsl:variable name="n1" select="(.//pb/@n)[1]"/>
            <xsl:variable name="n0" select="./preceding::pb[1]/@n"/>
            <xsl:variable name="v1" select="if (f:is-roman($n1)) then f:from-roman($n1) else $n1"/>
            <xsl:variable name="v0" select="if (f:is-roman($n0)) then f:from-roman($n0) else $n0"/>

            <xsl:if test="f:is-integer($v0) and f:is-integer($v1) and ($v1 != $v0 + 1)">
                <xsl:copy-of select="f:issue(., 'S02', 'Pagebreaks', 'Error', 'Page break in note ' || @n || ': page ' || $n1 || ': out-of-sequence (preceding ' || $n0 || ').')"/>
            </xsl:if>

            <xsl:call-template name="sequence-in-order">
                <xsl:with-param name="elements" select=".//pb"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="note[not(@sameAs)]">
        <xsl:if test="not(.) or . = ''">
            <xsl:copy-of select="f:issue(., 'S03', 'Notes', 'Warning', 'Empty note.')"/>
        </xsl:if>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="note[@sameAs]">
        <xsl:if test=". != ''">
            <xsl:copy-of select="f:issue(., 'S04', 'Notes', 'Warning', 'Note with @sameAs attribute must be empty.')"/>
        </xsl:if>
        <xsl:next-match/>
    </xsl:template>


    <xd:doc>
        <xd:short>Check presence of various elements.</xd:short>
    </xd:doc>

    <xsl:template mode="checks" match="text">

        <!-- No double ids?-->
        <xsl:apply-templates select="//*[@id]" mode="doubleIds"/>

        <!-- Do we have a front, body, and back element? -->
        <xsl:if test="not(front) and not(ancestor::q)">
            <xsl:copy-of select="f:issue(., 'E04', 'Structure', 'Error', 'No front element!')"/>
        </xsl:if>

        <xsl:if test="not(body)">
            <xsl:copy-of select="f:issue(., 'E05', 'Structure', 'Error', 'No body element!')"/>
        </xsl:if>

        <xsl:if test="not(back) and not(ancestor::q)">
            <xsl:copy-of select="f:issue(., 'E06', 'Structure', 'Error', 'No back element!')"/>
        </xsl:if>

        <xsl:if test="not(//divGen[@type = ('toc', 'toca')] or //div[@id = 'toc'] or //div1[@id = 'toc'])">
            <xsl:copy-of select="f:issue(., 'E07', 'Structure', 'Warning', 'No table of contents present.')"/>
        </xsl:if>

        <xsl:if test="//divGen[@type = ('toc', 'toca')] and (//div[@id = 'toc'] or //div1[@id = 'toc'])">
            <xsl:copy-of select="f:issue(., 'E08', 'Structure', 'Warning', 'Both generated and original ToC present.')"/>
        </xsl:if>

        <xsl:next-match/>
    </xsl:template>


    <xsl:key name="id" match="*[@id]" use="@id"/>


    <xsl:template match="*[@id]" mode="doubleIds">
        <xsl:if test="count(key('id', @id)) &gt; 1">
            <xsl:copy-of select="f:issue(., 'E09', 'Structure', 'Warning', 'Same id used more than once.')"/>
        </xsl:if>
        <xsl:next-match/>
    </xsl:template>


    <xd:doc>
        <xd:short>Check presence of cover and title page.</xd:short>
    </xd:doc>

    <xsl:template mode="checks" match="front" priority="2">
        <!-- Do we have a cover that will be recognized as such? -->
        <xsl:if test="not(div1[@type='Cover' and @id='cover']/p/figure[@id='cover-image']) and not(./div[@type='Cover' and @id='cover']/p/figure[@id='cover-image'])">
            <xsl:copy-of select="f:issue(., 'E01', 'Structure', 'Warning', 'No cover defined (div1[@type=''Cover'' and @id=''cover'']/p/figure[@id=''cover-image'']).')"/>
        </xsl:if>

        <!-- Do we have a title-page that will be recognized as such? -->
        <xsl:if test="not(div1[@type='TitlePage' and @id='titlepage']/p/figure[@id='titlepage-image']) and not(./div[@type='TitlePage' and @id='titlepage']/p/figure[@id='titlepage-image'])">
            <xsl:copy-of select="f:issue(., 'E02', 'Structure', 'Warning', 'No title page defined (div1[@type=''TitlePage'' and @id=''titlepage'']/p/figure[@id=''titlepage-image'']).')"/>
        </xsl:if>
        <xsl:next-match/>
    </xsl:template>


    <xd:doc>
        <xd:short>Check presence of generated colophon.</xd:short>
    </xd:doc>

    <xsl:template mode="checks" match="back" priority="2">
        <xsl:if test="not(.//divGen[@type='Colophon'])">
            <xsl:copy-of select="f:issue(., 'E03', 'Structure', 'Error', 'No generated colophon in back-matter (divGen type=''Colophon'').')"/>
        </xsl:if>
        <xsl:next-match/>
    </xsl:template>


    <xd:doc>
        <xd:short>Check the numbering of divisions.</xd:short>
    </xd:doc>

    <xsl:template mode="checks" match="front | body | back" priority="1">

        <xsl:if test="not(name() = 'body')">
            <xsl:call-template name="check-id-present"/>
        </xsl:if>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="elements" select="div1"/>
        </xsl:call-template>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="elements" select="div0"/>
        </xsl:call-template>

        <xsl:next-match/>
    </xsl:template>


    <!-- Types of titleParts -->

    <xsl:variable name="expectedTitlePartTypes" as="xs:string*" select="'main', 'sub', 'series', 'volume'"/>

    <xsl:template mode="check-types" match="titlePart[@type and not(@type = $expectedTitlePartTypes)]">
        <xsl:copy-of select="f:issue(., 'T01', 'Types', 'Error', 'Unexpected type for titlePart: ' || @type || '.')"/>
        <xsl:next-match/>
    </xsl:template>


    <!-- Types of heads -->

    <xsl:variable name="expectedHeadTypes" as="xs:string*" select="'main', 'sub', 'super', 'label'"/>

    <xd:doc>
        <xd:short>Check the types of <code>head</code> elements.</xd:short>
    </xd:doc>

    <xsl:template mode="check-types" match="head[@type and not(@type = $expectedHeadTypes)]">
        <xsl:copy-of select="f:issue(., 'T02', 'Types', 'Error', 'Unexpected type for head: ' || @type || '.')"/>
        <xsl:next-match/>
    </xsl:template>


    <!-- Types of divisions -->

    <xsl:variable name="expectedFrontDiv1Types" as="xs:string*" select="
        'Advertisement',
        'Advertisements',
        'Bibliography',
        'CastList',
        'Contents',
        'Copyright',
        'Cover',
        'Dedication',
        'Epigraph',
        'Errata',
        'Foreword',
        'FrenchTitle',
        'Frontispiece',
        'Glossary',
        'Imprint',
        'Introduction',
        'Motto',
        'Note',
        'Notes',
        'Preface',
        'TitlePage'
        "/>

    <xsl:variable name="expectedBodyDiv0Types" as="xs:string*" select="'Book', 'Issue', 'Part', 'Volume'"/>

    <xsl:variable name="expectedBodyDiv1Types" as="xs:string*" select="
        'Act',
        'Scene',
        'Article',
        'Chapter',
        'Part',
        'Poem',
        'Story',
        'Tale'
        "/>

    <xsl:variable name="expectedBackDiv1Types" as="xs:string*" select="
        'Advertisement',
        'Advertisements',
        'Appendix',
        'Bibliography',
        'Conclusion',
        'Contents',
        'Cover',
        'Epilogue',
        'Errata',
        'Glossary',
        'Imprint',
        'Index',
        'Note',
        'Notes',
        'Spine',
        'Vocabulary'
        "/>

    <xd:doc>
        <xd:short>Check the types of <code>div1</code> divisions in front-matter.</xd:short>
    </xd:doc>

    <xsl:template mode="check-types" match="front/div1">
        <xsl:call-template name="check-div-type-present"/>
        <xsl:if test="not(@type = $expectedFrontDiv1Types)">
            <xsl:copy-of select="f:issue(., 'T03', 'Types', 'Error', 'Unexpected type for front-matter div1: ' || @type || '.')"/>
        </xsl:if>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="elements" select="div2"/>
        </xsl:call-template>

        <xsl:next-match/>
    </xsl:template>


    <xd:doc>
        <xd:short>Check the types of <code>div0</code> divisions in the body.</xd:short>
    </xd:doc>

    <xsl:template mode="check-types" match="body/div0">
        <xsl:call-template name="check-div-type-present"/>
        <xsl:call-template name="check-id-present"/>
        <xsl:if test="not(@type = $expectedBodyDiv0Types)">
            <xsl:copy-of select="f:issue(., 'T04', 'Types', 'Error', 'Unexpected type for body div0: ' || @type || '.')"/>
        </xsl:if>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="elements" select="div1"/>
        </xsl:call-template>

        <xsl:next-match/>
    </xsl:template>


    <xd:doc>
        <xd:short>Check the types of <code>div1</code> divisions in the body.</xd:short>
    </xd:doc>

    <xsl:template mode="check-types" match="body/div1">
        <xsl:call-template name="check-div-type-present"/>
        <xsl:if test="not(@type = $expectedBodyDiv1Types)">
            <xsl:copy-of select="f:issue(., 'T05', 'Types', 'Error', 'Unexpected type for body div1: ' || @type || '.')"/>
        </xsl:if>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="elements" select="div2"/>
        </xsl:call-template>

        <xsl:next-match/>
    </xsl:template>


    <xd:doc>
        <xd:short>Check the types of <code>div1</code> divisions in the back-matter.</xd:short>
    </xd:doc>

    <xsl:template mode="check-types" match="back/div1">
        <xsl:call-template name="check-div-type-present"/>
        <xsl:if test="not(@type = $expectedBackDiv1Types)">
            <xsl:copy-of select="f:issue(., 'T06', 'Types', 'Error', 'Unexpected type for back-matter div1: ' || @type || '.')"/>
        </xsl:if>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="elements" select="div2"/>
        </xsl:call-template>

        <xsl:next-match/>
    </xsl:template>


    <xsl:template name="check-div-type-present">
        <xsl:if test="not(@type)">
            <xsl:copy-of select="f:issue(., 'T07', 'Types', 'Error', 'No type specified for ' || name() || '.')"/>
        </xsl:if>
    </xsl:template>


    <xsl:template name="check-id-present">
        <xsl:if test="not(@id)">
            <xsl:copy-of select="f:issue(., 'T08', 'IDs', 'Error', 'No id specified for ' || name() || '.')"/>
        </xsl:if>
    </xsl:template>


    <xsl:template mode="checks" match="div1">
        <xsl:call-template name="check-div-type-present"/>
        <xsl:call-template name="check-id-present"/>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="elements" select="div2"/>
        </xsl:call-template>

        <xsl:next-match/>
    </xsl:template>


    <xsl:template mode="checks" match="div2">
        <xsl:call-template name="check-div-type-present"/>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="elements" select="div3"/>
        </xsl:call-template>

        <xsl:next-match/>
    </xsl:template>


    <!-- divGen types -->

    <xsl:variable name="expectedDivGenTypes" as="xs:string*" select="'toc', 'loi', 'Colophon', 'IndexToc', 'apparatus', 'Gallery', 'Inclusion'"/>

    <xsl:template mode="checks" match="divGen">
        <xsl:call-template name="check-div-type-present"/>
        <xsl:if test="not(@type = $expectedDivGenTypes)">
            <xsl:copy-of select="f:issue(., 'T09', 'IDs', 'Error', 'Unexpected type for &lt;divGen&gt;: ' || @type || '.')"/>
        </xsl:if>
        <xsl:next-match/>
    </xsl:template>


    <!-- Do we have a following divGen[@type='apparatus'] for this note? -->
    <xsl:template mode="checks" match="note[@place='apparatus']" priority="1">
        <xsl:if test="not(following::divGen[@type='apparatus'])">
            <xsl:copy-of select="f:issue(., 'T10', 'Types', 'Warning', 'No &lt;divGen type=''apparatus''&gt; following apparatus note.')"/>
        </xsl:if>
        <xsl:next-match/>
    </xsl:template>


    <!-- Types of stage instructions ('mix' is the default provided by the DTD) -->

    <xsl:variable name="expectedStageTypes" as="xs:string*" select="'mix', 'entrance', 'exit', 'setting'"/>

    <xd:doc>
        <xd:short>Check the types of <code>stage</code> elements.</xd:short>
    </xd:doc>

    <xsl:template mode="checks" match="stage">
        <xsl:if test="@type and not(@type = $expectedStageTypes)">
            <xsl:copy-of select="f:issue(., 'T11', 'Types', 'Error', 'Unexpected type for stage instruction: ' || @type || '.')"/>
         </xsl:if>
        <xsl:next-match/>
    </xsl:template>


    <!-- Types of ab (arbitrary block) elements -->

    <xsl:variable name="expectedAbTypes" as="xs:string*" select="
        'verseNum',
        'lineNum',
        'parNum',
        'tocPageNum',
        'tocDivNum',
        'divNum',
        'itemNum',
        'figNum',
        'keyRef',
        'lineNumRef',
        'endNoteNum',
        'textRef',
        'keyNum',
        'intra',
        'top',
        'bottom',
        'price',
        'phantom'"/>

    <xd:doc>
        <xd:short>Check the types of <code>ab</code> elements.</xd:short>
    </xd:doc>

    <xsl:template mode="checks" match="ab[@type and not(@type = $expectedAbTypes)]">
        <xsl:copy-of select="f:issue(., 'T12', 'Types', 'Error', 'Unexpected type for &lt;ab&gt; (arbitrary block) element: ' || @type || '.')"/>
        <xsl:next-match/>
    </xsl:template>


    <!-- Types of abbr (abbreviation) elements -->

    <xsl:variable name="expectedAbbrTypes" as="xs:string*" select="'acronym', 'initialism', 'compass', 'compound', 'degree', 'era', 'name', 'postal', 'temperature', 'time', 'timezone'"/>

    <xd:doc>
        <xd:short>Check the types of <code>abbr</code> elements.</xd:short>
    </xd:doc>

    <xsl:template mode="checks" match="abbr[@type and not(@type = $expectedAbbrTypes)]">
        <xsl:copy-of select="f:issue(., 'T13', 'Types', 'Error', 'Unexpected type for &lt;abbr&gt; (abbreviation) element: ' || @type || '.')"/>
        <xsl:next-match/>
    </xsl:template>


    <!-- Elements not valid in TEI, but sometimes abused while producing a text from HTML. -->

    <xsl:template mode="checks" match="i | b | g | sc | uc | tt | asc | margin | ditto">

        <!-- Only report on the first occurrence -->
        <xsl:variable name="name" select="name(.)"/>
        <xsl:if test='not(preceding::*[name(.) = $name])'>
            <xsl:variable name="count" select="count(//*[name(.) = $name])"/>
            <xsl:copy-of select="f:issue(., 'X01', 'Compliance', 'Error', 'Non-TEI element: ' || name() || ' (count: ' || $count || ').')"/>
        </xsl:if>
        <xsl:next-match/>
    </xsl:template>


    <xsl:template mode="checks" match="hi[@rend='sc'] | sc">
        <xsl:if test="string(.) = upper-case(string(.))">
            <xsl:copy-of select="f:issue(., 'X02', 'Formatting', 'Warning', 'Small caps style used for all-caps text: &ldquo;' || string(.) || '&rdquo;.')"/>
        </xsl:if>
        <xsl:next-match/>
    </xsl:template>


    <xsl:template mode="checks" match="hi[@rend='asc'] | asc" priority="2">
        <xsl:if test="string(.) = lower-case(string(.))">
            <xsl:copy-of select="f:issue(., 'X03', 'Formatting', 'Warning', 'All small caps style used for all lower-case text: &ldquo;' || string(.) || '&rdquo;.')"/>
        </xsl:if>
        <xsl:next-match/>
    </xsl:template>


    <xsl:template mode="checks" match="hi[@rend='ex'] | g">
        <xsl:if test="contains(lower-case(string(.)), 'ij')">
            <xsl:copy-of select="f:issue(., 'Y01', 'Formatting', 'Warning', 'Letter-spaced text contains digraph ij: &ldquo;' || string(.) || '&rdquo;.')"/>
        </xsl:if>
        <xsl:next-match/>
    </xsl:template>


    <!-- Correction corrects nothing -->

    <xsl:template mode="checks" match="corr[@sic]">
        <xsl:if test="string(.) = string(@sic)">
            <xsl:copy-of select="f:issue(., 'C01', 'Corrections', 'Warning', 'Correction &ldquo;' || @sic || '&rdquo; same as original text.')"/>
        </xsl:if>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="corr[sic]">
        <xsl:if test="string(corr) = string(sic)">
            <xsl:copy-of select="f:issue(., 'C02', 'Corrections', 'Warning', 'Correction &ldquo;' || string(sic) || '&rdquo; same as original text.')"/>
        </xsl:if>
        <xsl:next-match/>
    </xsl:template>


    <!-- Figures -->

    <xsl:template mode="checks" match="figure[@url]">
        <xsl:copy-of select="f:issue(., 'F01', 'Figures', 'Warning', 'Using non-standard attribute url &ldquo;' || @url || '&rdquo;.')"/>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="figure">
        <xsl:if test="not(head) and not(figDesc)">
            <xsl:copy-of select="f:issue(., 'F02', 'Figures', 'Trivial', 'Figure without head or figDesc will not have alt attribute in HTML output.')"/>
        </xsl:if>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="figure[figure]">
        <xsl:next-match/>
    </xsl:template>


    <!-- Lists -->

    <xsl:template mode="checks" match="list">
        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="elements" select="item"/>
        </xsl:call-template>
        <xsl:next-match/>
    </xsl:template>


    <!-- Generic sequence -->

    <xsl:template name="sequence-in-order">
        <xsl:param name="elements" as="element()*"/>

        <xsl:for-each select="1 to count($elements) - 1">
            <xsl:variable name="counter" select="."/>
            <xsl:call-template name="pair-in-order">
                <xsl:with-param name="first" select="$elements[$counter]"/>
                <xsl:with-param name="second" select="$elements[$counter + 1]"/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="pair-in-order">
        <xsl:param name="first" as="element()"/>
        <xsl:param name="second" as="element()"/>

        <xsl:choose>

            <!-- Not all div-types need to be numbered -->
            <xsl:when test="name($first) = 'div0' and not($first/@type=('Book', 'Issue', 'Part', 'Volume'))"/>
            <xsl:when test="name($first) = 'div1' and not($first/@type=('Chapter', 'Section', 'Act', 'Scene', 'Story', 'Appendix'))"/>
            <xsl:when test="name($first) = ('div2', 'div3') and not($first/@type=('Section', 'Subsection', 'Scene', 'Appendix'))"/>

            <!-- Don't care if items are not numbered -->
            <xsl:when test="name($first) = 'item' and not($first/@n)"/>

            <xsl:when test="not($first/@n)">
                <xsl:copy-of select="f:issue($first, 'N01', 'Numbering', 'Trivial', 'Element ' || name($first) || ' without number.')"/>
            </xsl:when>

            <xsl:when test="not(f:is-integer($first/@n) or f:is-roman($first/@n))">
                <xsl:copy-of select="f:issue($first, 'N02', 'Numbering', 'Warning', 'Element ' || name($first) || ': n-attribute ' || $first/@n || ' not numeric.')"/>
            </xsl:when>

            <xsl:when test="f:is-roman($first/@n) and f:is-roman($second/@n)">
                <xsl:if test="not(f:from-roman($second/@n) = f:from-roman($first/@n) + 1)">
                    <xsl:copy-of select="f:issue($second, 'S02', 'Numbering', 'Warning', 'Element ' || name($second) || ': n-attribute ' || $second/@n || ' out-of-sequence. (preceding: ' || $first/@n || ').')"/>
                </xsl:if>
            </xsl:when>

            <xsl:when test="f:is-integer($first/@n) and f:is-integer($second/@n)">
                <xsl:if test="not($second/@n = $first/@n + 1)">
                    <xsl:copy-of select="f:issue($second, 'S03', 'Numbering', 'Warning', 'Element ' || name($second) || ': n-attribute ' || $second/@n || ' out-of-sequence. (preceding: ' || $first/@n || ').')"/>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <!-- Check ids referenced but not present -->

    <xsl:template mode="check-ids" match="text">

        <!-- @target points to existing @id -->
        <xsl:for-each-group select="//*[@target]" group-by="@target">
            <xsl:variable name="target" select="./@target" as="xs:string"/>
            <xsl:variable name="target" select="f:strip-hash($target)"/>
            <xsl:if test="not(//*[@id=$target])">
                <xsl:copy-of select="f:issue(., 'I01', 'References', 'Error', 'Element ' || name(.) || ': target-attribute value ' || ./@target || ' not present as id.')"/>
            </xsl:if>
        </xsl:for-each-group>

        <!-- @rendition points to existing @rendition element -->
        <xsl:for-each-group select="//*[@rendition]" group-by="@rendition">
            <xsl:variable name="name" select="name(.)" as="xs:string"/>
            <xsl:variable name="node" select="."/>
            <xsl:variable name="root" select="/"/>
            <xsl:for-each select="tokenize(@rendition, ' ')">
                <xsl:variable name="id" select="." as="xs:string"/>
                <xsl:if test="not($root//rendition[@id=$id])">
                    <xsl:copy-of select="f:issue($node, 'I02', 'References', 'Error', 'Element ' || $name || ': rendition element ' || . || ' not present.')"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each-group>

        <!-- @sameAs points to existing @id on element -->
        <xsl:for-each-group select="//*[@sameAs]" group-by="@sameAs">
            <xsl:variable name="sameAs" select="./@sameAs" as="xs:string"/>
            <xsl:if test="not(//*[@id=$sameAs])">
                <xsl:copy-of select="f:issue(., 'I05', 'References', 'Error', 'Element ' || name(.) || ': sameAs-attribute value ' || ./@sameAs || ' not present as id of any element.')"/>
            </xsl:if>
        </xsl:for-each-group>

        <!-- @who points to existing @id on role -->
        <xsl:for-each-group select="//*[@who]" group-by="@who">
            <xsl:variable name="who" select="./@who" as="xs:string"/>
            <xsl:if test="not(//role[@id=$who])">
                <xsl:copy-of select="f:issue(., 'I03', 'References', 'Error', 'Element ' || name(.) || ': who-attribute value ' || ./@who || '  not present as id of role.')"/>
            </xsl:if>
        </xsl:for-each-group>

        <!-- @ident or @id of language not being used in the text. -->
        <xsl:for-each select="//language">
            <xsl:if test="@id or @ident">
                <xsl:variable name="ident" select="if (@ident) then @ident else @id" as="xs:string"/>
                <xsl:if test="not(//*[@lang=$ident]) and not(//*[@xml:lang=$ident])">
                    <xsl:copy-of select="f:issue(., 'I03', 'References', 'Error', 'Language ' || $ident || ': declared but not used.')"/>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

    </xsl:template>


    <!-- Text level checks, run on segments -->

    <xsl:template mode="checks" match="s:segment">

        <!-- prevent false positives for ellipses. -->
        <xsl:variable name="segment" select="replace(., '\.\.\.+', '&hellip;')" as="xs:string"/>

        <xsl:variable name="full-width-openers" select="'&#xFF08;&#xFF3B;&#xFF5B;'" as="xs:string"/>
        <xsl:variable name="full-width-closers" select="'&#xFF09;&#xFF3D;&#xFF5D;'" as="xs:string"/>

        <!-- Name some complex regular expressions. -->
        <xsl:variable name="space-after-opener-pattern" select="'[\[(' || $full-width-openers || $open-quotation-marks || ']\s+'" as="xs:string"/>
        <xsl:variable name="space-before-closer-pattern" select="'\s+[\])' || $full-width-closers || $close-quotation-marks || ']'" as="xs:string"/>
        <xsl:variable name="space-after-comma-pattern" select="',[^\s&nbsp;&mdash;&hellip;' || $full-width-closers || $close-quotation-marks || '0-9)\]]'" as="xs:string"/>
        <xsl:variable name="space-after-period-pattern" select="'\.[^\s&nbsp;.,:;&mdash;' || $full-width-closers || $close-quotation-marks || '0-9)\]]'" as="xs:string"/>
        <xsl:variable name="space-after-punctuation-pattern" select="'[:;][^\s&mdash;&hellip;' || $full-width-closers || $close-quotation-marks || ')\]]'" as="xs:string"/>
        <xsl:variable name="space-after-question-pattern" select="'[!?]+[^\s!?&mdash;&hellip;' || $full-width-closers || $close-quotation-marks || ')\]]'" as="xs:string"/>

        <xsl:copy-of select="f:spaced-abbreviations(., $segment)"/>

        <!-- Hide common abbreviations (so they won't cause false positives). -->
        <xsl:variable name="segment" select="f:hide-abbreviations($segment)"/>

        <xsl:copy-of select="f:should-not-contain(., $segment, '\s+[.,:;!?]',                       'Warning', 'P01', 'Space before punctuation mark')"/>
        <xsl:copy-of select="f:should-not-contain(., $segment, $space-before-closer-pattern,        'Warning', 'P02', 'Space before closing punctuation mark')"/>
        <xsl:copy-of select="f:should-not-contain(., $segment, $space-after-opener-pattern,         'Warning', 'P03', 'Space after opening punctuation mark')"/>

        <xsl:copy-of select="f:should-not-contain(., $segment, $space-after-comma-pattern,          'Warning', 'P04', 'Missing space after comma')"/>
        <xsl:copy-of select="f:should-not-contain(., $segment, $space-after-period-pattern,         'Warning', 'P05', 'Missing space after period')"/>

        <xsl:copy-of select="f:should-not-contain(., $segment, '[&mdash;&ndash;]-',                 'Warning', 'P06', 'Em-dash or en-dash followed by dash')"/>
        <xsl:copy-of select="f:should-not-contain(., $segment, '[&mdash;-]&ndash;',                 'Warning', 'P07', 'Em-dash or dash followed by en-dash')"/>
        <xsl:copy-of select="f:should-not-contain(., $segment, '[&ndash;-]&mdash;',                 'Warning', 'P08', 'En-dash or dash followed by em-dash')"/>
        <xsl:copy-of select="f:should-not-contain(., $segment, '--',                                'Warning', 'P09', 'Two dashes should be en-dash')"/>

        <xsl:copy-of select="f:should-not-contain(., $segment, $space-after-punctuation-pattern,    'Warning', 'P10', 'Missing space after colon or semi-colon')"/>
        <xsl:copy-of select="f:should-not-contain(., $segment, $space-after-question-pattern,       'Warning', 'P10', 'Missing space after question or exclamation mark')"/>

        <xsl:copy-of select="f:should-not-contain(., $segment, '''',                                'Warning', 'P14', 'Straight single quote')"/>
        <xsl:copy-of select="f:should-not-contain(., $segment, '&quot;',                            'Warning', 'P15', 'Straight double quote')"/>
        <xsl:copy-of select="f:should-not-contain(., $segment, '#',                                 'Warning', 'P16', 'Hash-sign')"/>
        <xsl:copy-of select="f:should-not-contain(., $segment, '[0-9]/[0-9]',                       'Warning', 'P17', 'Unhandled fraction')"/>
        <xsl:copy-of select="f:should-not-contain(., $segment, '[|]',                               'Warning', 'P18', 'Vertical Bar')"/>
        <xsl:copy-of select="f:should-not-contain(., $segment, 'O[.,][0-9]',                        'Warning', 'P19', 'Capital Oh for zero')"/>
        <xsl:copy-of select="f:should-not-contain(., $segment, 'l[.,][0-9]',                        'Warning', 'P19', 'Lower-case el for one')"/>

        <xsl:variable name="nfd-segment" select="normalize-unicode($segment, 'NFD')" as="xs:string"/>

        <!-- Greek script checks -->
        <xsl:variable name="final-sigma-mid-word-pattern" select="'&#x03C2;\p{L}'" as="xs:string"/>
        <xsl:variable name="sigma-end-word-pattern" select="'\p{L}\p{M}*&#x03C3;\P{L}'" as="xs:string"/>
        <xsl:variable name="nu-gamma-pattern" select="'[&#x39D;&#x3BD;][&#x393;&#x3B3;]'" as="xs:string"/>

        <xsl:copy-of select="f:should-not-contain(., $segment, $final-sigma-mid-word-pattern,       'Warning', 'P19', 'Greek: final sigma &#x03C2; in middle of word')"/>
        <xsl:copy-of select="f:should-not-contain(., $segment, $sigma-end-word-pattern,             'Warning', 'P20', 'Greek: Non-final sigma &#x03C3; at end of word')"/>
        <xsl:copy-of select="f:should-not-contain(., $segment, $nu-gamma-pattern,                   'Warning', 'P21', 'Greek: nu &#x3BD; followed by gamma &#x3B3;. Was &#x3B3;&#x3B3; intended?')"/>

        <!-- Hebrew script checks -->
        <xsl:variable name="final-hebrew-letter-mid-word-pattern" select="'[&#x05DA;&#x05DD;&#x05DF;&#x05E3;&#x05E5;]\p{M}*\p{L}'" as="xs:string"/>  <!-- Final Kaf, Mem, Nun, Pe, Tsadi -->
        <xsl:variable name="non-final-hebrew-letter-end-word-pattern" select="'[&#x05DB;&#x05DE;&#x05E0;&#x05E4;&#x05E6;]\p{M}*[^\p{L}\p{M}]'" as="xs:string"/>  <!-- Non-final Kaf, Mem, Nun, Pe, Tsadi -->

        <xsl:copy-of select="f:should-not-contain(., $segment, $final-hebrew-letter-mid-word-pattern, 'Warning', 'P22', 'Hebrew: final letter in middle of word')"/>
        <xsl:copy-of select="f:should-not-contain(., $segment, $non-final-hebrew-letter-end-word-pattern, 'Warning', 'P23', 'Hebrew: non-final Hebrew letter at end of word')"/>

        <xsl:call-template name="match-punctuation-pairs">
            <xsl:with-param name="string" select="$segment"/>
            <xsl:with-param name="next" select="string(following-sibling::*[1])"/>
        </xsl:call-template>

        <xsl:apply-templates mode="checks"/>
    </xsl:template>


    <xsl:function name="f:strip-hash" as="xs:string">
        <xsl:param name="target" as="xs:string"/>
        <xsl:value-of select="if (starts-with($target, '#')) then substring($target, 2) else $target"/>
    </xsl:function>


    <xsl:variable name="common-abbreviations" select="f:get-abbreviations()"/>


    <xsl:function name="f:get-abbreviations">
        <xsl:variable name="abbreviations" select="f:get-setting('text.abbr')"/>
        <xsl:variable name="abbrs">
            <tmp:abbrs>
                <xsl:analyze-string select="$abbreviations" regex=";" flags="s">
                    <xsl:non-matching-substring>
                        <tmp:abbr><xsl:value-of select="normalize-space(.)"/></tmp:abbr>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
                <xsl:for-each-group select="$root//abbr[not(@type) or @type != 'lemma']" group-by=".">
                    <tmp:abbr><xsl:value-of select="."/></tmp:abbr>
                </xsl:for-each-group>
            </tmp:abbrs>
        </xsl:variable>

        <!-- Sort by length, longest first, then alphabetical, case-insensitive, then capitals first. -->
        <tmp:abbrs>
            <xsl:for-each select="$abbrs//tmp:abbr">
                <xsl:sort select="string-length(.)" data-type="number" order="descending"/>
                <xsl:sort select="lower-case(.)"/>
                <xsl:sort select="."/>
                <tmp:abbr><xsl:value-of select="."/></tmp:abbr>
            </xsl:for-each>
        </tmp:abbrs>
    </xsl:function>


    <xsl:variable name="common-abbreviations-with-periods" select="f:get-abbreviations-with-periods()"/>


    <xsl:function name="f:get-abbreviations-with-periods">
        <tmp:abbrs>
            <xsl:for-each select="$common-abbreviations//tmp:abbr[contains(., '.')]">
                <tmp:abbr><xsl:value-of select="."/></tmp:abbr>
            </xsl:for-each>
        </tmp:abbrs>
    </xsl:function>

    <xsl:function name="f:hide-abbreviations" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:value-of select="f:hide-abbreviation($string, count($common-abbreviations-with-periods/tmp:abbr))"/>
    </xsl:function>

    <xsl:function name="f:hide-abbreviation" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:param name="n"/>

        <!-- <xsl:copy-of select="f:log-info('N: {1}; STRING: {2}', (string($n), $string))"/> -->

        <xsl:choose>
            <xsl:when test="$n &gt; 0">
                <xsl:variable name="result" as="xs:string">
                    <xsl:variable name="old" select="$common-abbreviations-with-periods/tmp:abbr[$n]"/>
                    <xsl:variable name="new" select="replace($old, '\.', '&fwperiod;')"/>
                    <xsl:variable name="pattern" select="replace($old, '([.+])', '[$1]')"/>

                    <!-- <xsl:copy-of select="f:log-info('OLD: {1}; NEW: {2}; PATTERN: {3}', ($old, $new, $pattern))"/> -->

                    <xsl:value-of select="replace(f:hide-abbreviation($string, $n - 1), $pattern, $new)"/>
                </xsl:variable>

                <xsl:value-of select="$result"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xsl:function name="f:spaced-abbreviations" as="node()*">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="string" as="xs:string"/>
        <xsl:for-each select="$common-abbreviations/tmp:abbr">
            <xsl:copy-of select="f:spaced-abbreviation($node, $string, .)"/>
        </xsl:for-each>
    </xsl:function>


    <xsl:function name="f:spaced-abbreviation" as="node()?">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="string" as="xs:string"/>
        <xsl:param name="abbr" as="xs:string"/>

        <xsl:if test="matches($abbr, '[A-Za-z-]+\.[A-Za-z-]+\.')">
            <xsl:variable name="pattern" select="replace($abbr, '\.', '\\.\\s+')"/>
            <xsl:variable name="pattern" select="replace($pattern, '\\s[+]$', '')"/>

            <xsl:if test="matches($string, $pattern)">
                <xsl:copy-of select="f:issue($node, 'P19', 'Punctuation', 'Warning', 'Spaced abbreviation ' || $abbr || ' in: ' || f:match-fragment($string, $pattern) || '.')"/>
            </xsl:if>
        </xsl:if>
    </xsl:function>


    <xsl:function name="f:should-not-contain">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="segment" as="xs:string"/>
        <xsl:param name="pattern" as="xs:string"/>
        <xsl:param name="level" as="xs:string"/>
        <xsl:param name="code" as="xs:string"/>
        <xsl:param name="message" as="xs:string"/>

        <xsl:if test="matches($segment, $pattern)">
            <xsl:copy-of select="f:issue($node, $code, 'Punctuation', $level, $message || ' in: ' || f:match-fragment($segment, $pattern) || '.')"/>
        </xsl:if>
    </xsl:function>


    <xsl:template mode="checks" match="text()"/>


    <!-- Support variables for matching-punctuation tests -->
    <xsl:variable name="pairs" select="f:get-setting('text.parentheses') || f:get-setting('text.quotes')"/>
    <xsl:variable name="pair-sequence" select="f:split-string($pairs)"/>
    <xsl:variable name="opener" select="$pair-sequence[position() mod 2 = 1]"/>
    <xsl:variable name="closer" select="$pair-sequence[position() mod 2 = 0]"/>
    <xsl:variable name="open-quotation-marks" select="string-join(f:split-string(f:get-setting('text.quotes'))[position() mod 2 = 1], '')"/>
    <xsl:variable name="close-quotation-marks" select="string-join(f:split-string(f:get-setting('text.quotes'))[position() mod 2 = 0], '')"/>
    <xsl:variable name="opener-string" select="string-join($opener, '')"/>
    <xsl:variable name="closer-string" select="string-join($closer, '')"/>


    <xd:doc>
        <xd:short>Verify paired punctuation marks match.</xd:short>
        <xd:detail>
            <p>Verify paired punctuation marks, such as parenthesis match and are not wrongly nested. This assumes that the
            right single quote character (&rsquo;) is not being used for the apostrophe (hint: temporarily change those to
            something else). The paired punctuation marks supported are taken from the configuration values <code>text.parentheses</code> and
            <code>text.quotes</code>.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="match-punctuation-pairs">
        <xsl:param name="string" as="xs:string"/>
        <xsl:param name="next" as="xs:string"/>

        <xsl:copy-of select="f:log-debug('QUOTES: {1} - {2}', ($opener-string, $closer-string))"/>

        <xsl:variable name="unspacedNext" select="translate($next, ' &tab;&cr;&lf;&nbsp;&hairsp;', '')" as="xs:string"/>
        <xsl:variable name="unclosed" select="f:unclosed-pairs(f:keep-only($string, $pairs), '')"/>

        <xsl:choose>
            <xsl:when test="substring($unclosed, 1, 10) = 'Unexpected'">
                <xsl:copy-of select="f:issue(., 'P11', 'Punctuation', 'Warning', $unclosed || ' in: ' || f:head-chars($string) || '.')"/>
            </xsl:when>
            <xsl:when test="f:contains-only($unclosed, $open-quotation-marks)">
                <xsl:if test="not(starts-with($unspacedNext, f:reverse($unclosed)))">
                    <xsl:copy-of select="f:issue(., 'P12', 'Punctuation', 'Warning',
                        'Unclosed quotation mark(s): ' || $unclosed || ' not re-opened in next paragraph. Current: ' || f:tail-chars($string) || ' Next: ' || f:head-chars($next) || '.')"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$unclosed != ''">
                <xsl:copy-of select="f:issue(., 'P13', 'Punctuation', 'Warning', 'Unclosed punctuation: ' || $unclosed || ' in: ' || f:head-chars($string) || '.')"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:function name="f:keep-only" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:param name="chars" as="xs:string"/>

        <xsl:value-of select="translate($string, translate($string, $chars, ''), '')"/>
    </xsl:function>


    <xsl:function name="f:contains-only" as="xs:boolean">
        <xsl:param name="string" as="xs:string"/>
        <xsl:param name="chars" as="xs:string"/>

        <xsl:sequence select="string-length(translate($string, translate($string, $chars, ''), '')) = string-length($string)"/>
    </xsl:function>



    <xsl:function name="f:split-string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:analyze-string select="$string" regex=".">
            <xsl:matching-substring>
                <xsl:sequence select="."/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>


    <xd:doc>
        <xd:short>Find unclosed pairs of paired punctuation marks.</xd:short>
        <xd:detail>
            <p>Find unclosed pairs of paired punctuation marks in a string of punctuation marks using recursive calls.
            This pushes open marks on a stack, and pops them when the closing mark comes by.
            When an unexpected closing mark is encountered, we return an error; when the string is fully consumed,
            the remainder of the stack is returned. Normally, this is expected to be empty.</p>
        </xd:detail>
    </xd:doc>

    <xsl:function name="f:unclosed-pairs" as="xs:string">
        <xsl:param name="pairs" as="xs:string"/>
        <xsl:param name="stack" as="xs:string"/>

        <xsl:variable name="head" select="substring($pairs, 1, 1)"/>
        <xsl:variable name="tail" select="substring($pairs, 2)"/>
        <xsl:variable name="expect" select="translate(substring($stack, 1, 1), $opener-string, $closer-string)"/>

        <xsl:sequence select="if (not($head))
                              then $stack
                              else if ($head = $opener)
                                   then f:unclosed-pairs($tail, $head || $stack)
                                   else if ($head = $expect)
                                        then f:unclosed-pairs($tail, substring($stack, 2))
                                        else 'Unexpected closing punctuation: ' || $head || (if ($stack) then ' open: ' else '') || f:reverse($stack)"/>
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


    <xsl:function name="f:head-chars" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:sequence select="if (string-length($string) &lt; 40) then $string else substring($string, 1, 37) || '...'"/>
    </xsl:function>


    <xsl:function name="f:tail-chars" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:sequence select="if (string-length($string) &lt; 40) then $string else '...' || substring($string, string-length($string) - 37, 37)"/>
    </xsl:function>


    <xsl:function name="f:reverse" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:sequence select="codepoints-to-string(reverse(string-to-codepoints($string)))"/>
    </xsl:function>


    <xsl:function name="f:generate-id" as="xs:string">
        <xsl:param name="node" as="element()"/>
        <xsl:value-of select="if ($node/@id) then $node/@id else 'x' || generate-id($node)"/>
    </xsl:function>


    <xsl:function name="f:replaced-to-normal-symbols" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:sequence select="translate($string,
            '&#xFF08;&#xFF09;&#xFF3B;&#xFF3D;&#xFF5B;&#xFF5B;&#xFF03;&fwperiod;',
            '()[]{}#.')"/>
    </xsl:function>


    <xsl:function name="f:is-magic" as="xs:string">
        <xsl:param name="table" as="element(table)"/>
        <xsl:variable name="n" select="count($table/row)"/>
        <xsl:variable name="s" select="$n * (($n * $n + 1) div 2)"/>

        <xsl:for-each select="$table/row">
            <xsl:if test="$n != count(./cell)">
                Not square
            </xsl:if>
        </xsl:for-each>

        <xsl:for-each select="1 to $n">
            <xsl:if test="$s != sum($table/row[.]/cell)">
                Row does not add up to constant
            </xsl:if>
            <xsl:if test="$s != sum($table/row/cell[.])">
                Column does not add up to constant
            </xsl:if>
        </xsl:for-each>

    </xsl:function>


</xsl:stylesheet>