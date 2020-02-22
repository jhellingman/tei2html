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

    <!ENTITY blackCircle      "&#x25CF;">

]>

<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:i="http://gutenberg.ph/issues"
    xmlns:msg="http://www.gutenberg.ph/2006/schemas/messages"
    xmlns:s="http://gutenberg.ph/segments"
    xmlns:tmp="urn:temporary"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="i f msg s tmp xd xhtml xs">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to perform various checks on a TEI file.</xd:short>
        <xd:detail><p>This stylesheet performs a number of checks on a TEI file, to help find potential issues with both the text and tagging.</p>
        <p>Since the standard XSLT processor does not provide line and column information to report errors on, this stylesheet expects that all
        elements are provided with a <code>pos</code> element that contains the line and column the element appears on in the source file. This element
        should have the format <code>line:column</code>. A small Perl script (<code>addPositionInfo.pl</code>) is available to add those attributes to
        elements as a pre-processing step.</p></xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2015&ndash;2017, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:include href="log.xsl"/>
    <xsl:include href="configuration.xsl"/>
    <xsl:include href="segmentize.xsl"/>
    <xsl:include href="numbers.xsl"/>

    <xsl:variable name="outputformat" select="'html'"/>

    <xsl:variable name="root" select="/"/>

    <xsl:variable name="segments">
        <xsl:apply-templates mode="segmentize" select="/"/>
    </xsl:variable>

    <!-- Collect issues in structure [issue pos=""]Description of issue[/issue] -->
    <xsl:variable name="issues">
        <i:issues>
            <xsl:apply-templates mode="info" select="/"/>
            <xsl:apply-templates mode="checks" select="/"/>
            <xsl:apply-templates mode="check-ids" select="/"/>

            <!-- Check textual issues on segments -->

            <xsl:apply-templates mode="checks" select="$segments//s:segment"/>
        </i:issues>
    </xsl:variable>


    <!-- ignore textual content in those modes -->
    <xsl:template mode="info checks check-ids" match="text()" priority="-1"/>


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
        <!--
        <xsl:call-template name="output-segments">
            <xsl:with-param name="segments" select="$segments"/>
        </xsl:call-template>
        -->

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


    <!-- Make sure periods in abbreviations are not reported (replace them by &blackCircle;; replace them back later) -->
    <xsl:template match="abbr" mode="segments">
        <xsl:value-of select="replace(., '\.', '&blackCircle;')"/>
    </xsl:template>

    <xsl:template mode="info" match="titleStmt/title">
        <i:issue pos="{@pos}" code="A01" category="Metadata" target="{f:generate-id(.)}" level="Info" element="{name(.)}" page="{f:get-page(.)}">Title: <xsl:value-of select="."/>.</i:issue>
        <xsl:apply-templates mode="info"/>
    </xsl:template>

    <xsl:template mode="info" match="titleStmt/author">
        <i:issue pos="{@pos}" code="A02" category="Metadata" target="{f:generate-id(.)}" level="Info" element="{name(.)}" page="{f:get-page(.)}">Author: <xsl:value-of select="."/>.</i:issue>
        <xsl:apply-templates mode="info"/>
    </xsl:template>

    <xsl:template name="output-issues">
        <xsl:param name="issues" as="node()"/>

        <xsl:result-document
                doctype-public=""
                doctype-system=""
                href="issues.xml"
                method="xml"
                indent="yes"
                encoding="UTF-8">
            <xsl:message>INFO:    Generated file: issues.xml.</xsl:message>
            <xsl:copy-of select="$issues"/>
        </xsl:result-document>
    </xsl:template>


    <xd:doc mode="report">
        <xd:short>Mode for reporting the found issues in an HTML table.</xd:short>
    </xd:doc>

    <xd:doc>
        <xd:short>Report the found issues as a HTML document.</xd:short>
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
        <xd:short>Report an issue as a row in a HTML table.</xd:short>
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


    <xd:doc mode="checks">
        <xd:short>Mode for collecting issues in a simple intermediate structure.</xd:short>
    </xd:doc>


    <xd:doc>
        <xd:short>Check the information in the TEI-header is complete.</xd:short>
    </xd:doc>

    <xsl:template mode="checks" match="publicationStmt[not(idno[@type='epub-id'])]">
        <i:issue pos="{@pos}" code="H01" category="Header" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">No ePub-id present.</i:issue>
        <xsl:apply-templates mode="checks"/>
    </xsl:template>

    <xsl:variable name="guidFormat" select="'^(urn:uuid:([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$'"/>

    <xsl:template mode="checks" match="idno[@type='epub-id'][not(matches(., $guidFormat))]">
        <i:issue pos="{@pos}" code="H02" category="Header" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">ePub-id does not use GUID format (urn:uuid:########-####-####-####-############).</i:issue>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="titleStmt/author[not(@key) and not(. = ('Anonymous', 'Anoniem'))]" priority="1">
        <i:issue pos="{@pos}" code="H03" category="Header" target="{f:generate-id(.)}" level="Warning" element="{name(.)}" page="{f:get-page(.)}">No @key attribute present for author <xsl:value-of select="."/>.</i:issue>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="titleStmt/editor[not(@key)]" priority="1">
        <i:issue pos="{@pos}" code="H04" category="Header" target="{f:generate-id(.)}" level="Warning" element="{name(.)}" page="{f:get-page(.)}">No @key attribute present for editor <xsl:value-of select="."/>.</i:issue>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="titleStmt/respStmt/name[not(@key)]" priority="1">
        <i:issue pos="{@pos}" code="H05" category="Header" target="{f:generate-id(.)}" level="Warning" element="{name(.)}" page="{f:get-page(.)}">No @key attribute present for name <xsl:value-of select="."/>.</i:issue>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="titleStmt/author[not(@ref) and not(. = ('Anonymous', 'Anoniem'))]" priority="2">
        <i:issue pos="{@pos}" code="H06" category="Header" target="{f:generate-id(.)}" level="Warning" element="{name(.)}" page="{f:get-page(.)}">No @ref attribute present for author <xsl:value-of select="."/>.</i:issue>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="titleStmt/editor[not(@ref)]" priority="2">
        <i:issue pos="{@pos}" code="H07" category="Header" target="{f:generate-id(.)}" level="Warning" element="{name(.)}" page="{f:get-page(.)}">No @ref attribute present for editor <xsl:value-of select="."/>.</i:issue>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="titleStmt/respStmt[resp != 'Transcription']/name[not(@ref)]" priority="2">
        <i:issue pos="{@pos}" code="H08" category="Header" target="{f:generate-id(.)}" level="Warning" element="{name(.)}" page="{f:get-page(.)}">No @ref attribute present for name <xsl:value-of select="."/>.</i:issue>
        <xsl:next-match/>
    </xsl:template>

    <xsl:variable name="viafUrlFormat" select="'^https://viaf\.org/viaf/[0-9]+/$'"/>

    <xsl:template mode="checks" match="titleStmt/author[@ref and not(matches(@ref, $viafUrlFormat))]">
        <i:issue pos="{@pos}" code="H09" category="Header" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">The @ref attribute &ldquo;<xsl:value-of select="@ref"/>&rdquo; on author <xsl:value-of select="."/> is not a valid viaf.org url.</i:issue>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="titleStmt/editor[@ref and not(matches(@ref, $viafUrlFormat))]">
        <i:issue pos="{@pos}" code="H10" category="Header" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">The @ref attribute &ldquo;<xsl:value-of select="@ref"/>&rdquo; on editor <xsl:value-of select="."/> is not a valid viaf.org url.</i:issue>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="titleStmt/respStmt/name[@ref and not(matches(@ref, $viafUrlFormat))]">
        <i:issue pos="{@pos}" code="H11" category="Header" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">The @ref attribute &ldquo;<xsl:value-of select="@ref"/>&rdquo; on name <xsl:value-of select="."/> is not a valid viaf.org url.</i:issue>
        <xsl:next-match/>
    </xsl:template>


    <xsl:template match="seg[@copyOf]" mode="checks">
        <xsl:if test="not(//*[@id = current()/@copyOf])">
            <i:issue pos="{@pos}" code="H12" category="Reference" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">The @copyOf attribute &ldquo;<xsl:value-of select="@copyOf"/>&rdquo; of seg element has no matching @id.</i:issue>
        </xsl:if>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template match="ref[@type='noteref']" mode="checks">
        <i:issue pos="{@pos}" code="H13" category="Reference" target="{f:generate-id(.)}" level="Trivial" element="{name(.)}" page="{f:get-page(.)}">A ref with @type noteref is better replaced with a note with a @sameAs attribute.</i:issue>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template match="ditto" mode="checks">
        <i:issue pos="{@pos}" code="H14" category="Compliance" target="{f:generate-id(.)}" level="Trivial" element="{name(.)}" page="{f:get-page(.)}">The non-standard ditto element is better replaced with a seg with a @copyOf attribute.</i:issue>
        <xsl:next-match/>
    </xsl:template>


    <xsl:template match="cell[@role='sumCurrency']" mode="checks">

        <!-- Sum a currency split over two columns, e.g., dollars and cents, using 1 dollar = 100 cents.
             The cell we match is the dollar amount; the cents are assumed to be in the next cell -->

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

    </xsl:template>


    <xsl:template match="cell[@role='sumSterling']" mode="checks">

        <!-- Sum a sterling amount split over three columns, i.e., pounds, shillings, and pence,
             using 1 pound = 20 shillings or 240 pence. The cell we match is the amount in pounds;
             the shillings and pence are assumed to be in the next two cells. -->

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

    </xsl:template>


    <xsl:template match="cell[@role='sumPeso']" mode="checks">

        <!-- Sum a Peso/Tomin/Grano amount split over three columns,
             using 1 peso = 8 tomins or 8 * 12 = 96 granos. The cell we match is the amount in pesos;
             the tomins and granos are assumed to be in the next two cells. -->

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
            <i:issue
                pos="{$cell/@pos}"
                code="T1"
                category="Table"
                target="{f:generate-id($cell)}"
                level="Error"
                element="{name($cell)}"
                page="{f:get-page($cell)}">The cell contents &ldquo;<xsl:value-of select="$value"/>&rdquo;, marked as a <xsl:value-of select="$cell/@role"/>, is not recognized as a number.</i:issue>
        </xsl:if>
    </xsl:function>

    <xsl:function name="f:report-difference">
        <xsl:param name="cell" as="element(cell)"/>
        <xsl:param name="first" as="xs:double"/>
        <xsl:param name="second" as="xs:double"/>

        <xsl:variable name="value"><xsl:apply-templates select="$cell" mode="remove-extra-content"/></xsl:variable>
        <!-- Take precision into account -->
        <xsl:if test="abs($first - $second) > 0.0000000000001">
            <i:issue
                pos="{$cell/@pos}"
                code="T2"
                category="Table"
                target="{f:generate-id($cell)}"
                level="Warning"
                element="{name($cell)}"
                page="{f:get-page($cell)}">Verify value &ldquo;<xsl:value-of select="normalize-space($value)"/>&rdquo;: [<xsl:value-of select="$cell/@role"/>] <xsl:value-of select="$first"/> not equal to <xsl:value-of select="$second"/> (difference: <xsl:value-of select="$first - $second"/>).</i:issue>
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


    <xd:doc>
        <xd:short>Check page numbering.</xd:short>
    </xd:doc>

    <xsl:template mode="checks" match="/">
        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="elements" select="//pb[not(ancestor::note)]"/>
        </xsl:call-template>
        <xsl:apply-templates mode="checks"/>
        <xsl:next-match/>
    </xsl:template>

    <!-- We allow a pb directly after a titlePage, due to the level this has in the TEI DTD -->
    <xsl:template mode="checks" match="front/pb[not(preceding::titlePage)] | body/pb | back/pb">
        <i:issue pos="{@pos}" code="T14" category="Pagebreaks" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">pb element directly under front, body, or back.</i:issue>

        <xsl:apply-templates mode="checks"/>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="text/pb">
        <i:issue pos="{@pos}" code="T15" category="Pagebreaks" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">pb element directly under text.</i:issue>

        <xsl:apply-templates mode="checks"/>
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
                <i:issue pos="{@pos}" code="S01" category="Pagebreaks" target="{f:generate-id(.)}" level="Warning" element="{name(.)}" page="{f:get-page(.)}">Page break in note <xsl:value-of select="@n"/>: page <xsl:value-of select="$n1"/>: out-of-sequence (preceding <xsl:value-of select="$n0"/>).</i:issue>
            </xsl:if>

            <xsl:call-template name="sequence-in-order">
                <xsl:with-param name="elements" select=".//pb"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates mode="checks"/>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="note[not(@sameAs)]">
        <xsl:if test="not(.) or . = ''">
            <i:issue pos="{@pos}" code="S03" category="Notes" target="{f:generate-id(.)}" level="Warning" element="{name(.)}" page="{f:get-page(.)}">Empty note.</i:issue>
        </xsl:if>
        <xsl:apply-templates mode="checks"/>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="note[@sameAs]">
        <xsl:if test=". != ''">
            <i:issue pos="{@pos}" code="S04" category="Notes" target="{f:generate-id(.)}" level="Warning" element="{name(.)}" page="{f:get-page(.)}">Note with @sameAs attribute must be empty.</i:issue>
        </xsl:if>
        <xsl:apply-templates mode="checks"/>
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
            <i:issue pos="{@pos}" code="E04" category="Structure" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">No front element!</i:issue>
        </xsl:if>

        <xsl:if test="not(body)">
            <i:issue pos="{@pos}" code="E05" category="Structure" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">No body element!</i:issue>
        </xsl:if>

        <xsl:if test="not(back) and not(ancestor::q)">
            <i:issue pos="{@pos}" code="E06" category="Structure" target="{f:generate-id(.)}" level="Warning" element="{name(.)}" page="{f:get-page(.)}">No back element!</i:issue>
        </xsl:if>

        <xsl:if test="not(//divGen[@type = ('toc', 'toca')] or //div[@id = 'toc'] or //div1[@id = 'toc'])">
            <i:issue pos="{@pos}" code="E07" category="Structure" target="{f:generate-id(.)}" level="Warning" element="{name(.)}" page="{f:get-page(.)}">No table of contents present.</i:issue>
        </xsl:if>

        <xsl:if test="//divGen[@type = ('toc', 'toca')] and (//div[@id = 'toc'] or //div1[@id = 'toc'])">
            <i:issue pos="{@pos}" code="E08" category="Structure" target="{f:generate-id(.)}" level="Warning" element="{name(.)}" page="{f:get-page(.)}">Both genererated and original ToC present.</i:issue>
        </xsl:if>

        <xsl:apply-templates mode="checks"/>
    </xsl:template>


    <xsl:key name="id" match="*[@id]" use="@id"/> 


    <xsl:template match="*[@id]" mode="doubleIds">
        <xsl:if test="count(key('id', @id)) &gt; 1">
            <i:issue pos="{@pos}" code="E09" category="Structure" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">Same id used more than once.</i:issue>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Check presence of cover and title page.</xd:short>
    </xd:doc>

    <xsl:template mode="checks" match="front" priority="2">
        <!-- Do we have a cover that will be recognized as such? -->
        <xsl:if test="not(div1[@type='Cover' and @id='cover']/p/figure[@id='cover-image']) and not(./div[@type='Cover' and @id='cover']/p/figure[@id='cover-image'])">
            <i:issue pos="{@pos}" code="E01" category="Structure" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">No cover defined (div1[@type='Cover' and @id='cover']/p/figure[@id='cover-image']).</i:issue>
        </xsl:if>

        <!-- Do we have a title-page that will be recognized as such? -->
        <xsl:if test="not(div1[@type='TitlePage' and @id='titlepage']/p/figure[@id='titlepage-image']) and not(./div[@type='TitlePage' and @id='titlepage']/p/figure[@id='titlepage-image'])">
            <i:issue pos="{@pos}" code="E02" category="Structure" target="{f:generate-id(.)}" level="Warning" element="{name(.)}" page="{f:get-page(.)}">No title page defined (div1[@type='TitlePage' and @id='titlepage']/p/figure[@id='titlepage-image']).</i:issue>
        </xsl:if>
        <xsl:apply-templates mode="checks"/>
        <xsl:next-match/>
    </xsl:template>


    <xd:doc>
        <xd:short>Check presence of generated colophon.</xd:short>
    </xd:doc>

    <xsl:template mode="checks" match="back" priority="2">
        <xsl:if test="not(.//divGen[@type='Colophon'])">
            <i:issue pos="{@pos}" code="E03" category="Structure" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">No generated colophon in backmatter (divGen type="Colophon").</i:issue>
        </xsl:if>
        <xsl:apply-templates mode="checks"/>
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

        <xsl:apply-templates mode="checks"/>
    </xsl:template>


    <!-- Types of titleParts -->

    <xsl:variable name="expectedTitlePartTypes" select="'main', 'sub', 'series', 'volume'"/>

    <xsl:template mode="checks" match="titlePart[@type and not(@type = $expectedTitlePartTypes)]">
        <i:issue pos="{@pos}" code="T01" category="Types" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">Unexpected type for titlePart: <xsl:value-of select="@type"/></i:issue>
    </xsl:template>


    <!-- Types of heads -->

    <xsl:variable name="expectedHeadTypes" select="'main', 'sub', 'super', 'label'"/>

    <xd:doc>
        <xd:short>Check the types of <code>head</code> elements.</xd:short>
    </xd:doc>

    <xsl:template mode="checks" match="head[@type and not(@type = $expectedHeadTypes)]">
        <i:issue pos="{@pos}" code="T02" category="Types" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">Unexpected type for head: <xsl:value-of select="@type"/></i:issue>
    </xsl:template>


    <!-- Types of divisions -->

    <xsl:variable name="expectedFrontDiv1Types" select="'Cover', 'Copyright', 'Epigraph', 'Foreword', 'Introduction', 'Frontispiece', 'Dedication', 'Preface', 'Imprint', 'Introduction', 'Note', 'Motto', 'Contents', 'Bibliography', 'FrenchTitle', 'TitlePage', 'Advertisement', 'Advertisements', 'Glossary', 'Errata'" as="xs:string*"/>
    <xsl:variable name="expectedBodyDiv0Types" select="'Part', 'Book', 'Issue'" as="xs:string*"/>
    <xsl:variable name="expectedBodyDiv1Types" select="'Chapter', 'Poem', 'Story', 'Article', 'Letter'" as="xs:string*"/>
    <xsl:variable name="expectedBackDiv1Types" select="'Cover', 'Spine', 'Notes', 'Index', 'Appendix', 'Bibliography', 'Conclusion', 'Epilogue', 'Contents', 'Imprint', 'Errata', 'Glossary', 'Vocabulary', 'Advertisement', 'Advertisements'" as="xs:string*"/>

    <xd:doc>
        <xd:short>Check the types of <code>div1</code> divisions in frontmatter.</xd:short>
    </xd:doc>

    <xsl:template mode="checks" match="front/div1">
        <xsl:call-template name="check-div-type-present"/>
        <xsl:if test="not(@type = $expectedFrontDiv1Types)">
            <i:issue pos="{@pos}" code="T03" category="Types" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">Unexpected type for frontmatter div1: <xsl:value-of select="@type"/></i:issue>
        </xsl:if>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="elements" select="div2"/>
        </xsl:call-template>

        <xsl:apply-templates mode="checks"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Check the types of <code>div0</code> divisions in the body.</xd:short>
    </xd:doc>

    <xsl:template mode="checks" match="body/div0">
        <xsl:call-template name="check-div-type-present"/>
        <xsl:call-template name="check-id-present"/>
        <xsl:if test="not(@type = $expectedBodyDiv0Types)">
            <i:issue pos="{@pos}" code="T04" category="Types" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">Unexpected type for body div0: <xsl:value-of select="@type"/></i:issue>
        </xsl:if>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="elements" select="div1"/>
        </xsl:call-template>

        <xsl:apply-templates mode="checks"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Check the types of <code>div1</code> divisions in the body.</xd:short>
    </xd:doc>

    <xsl:template mode="checks" match="body/div1">
        <xsl:call-template name="check-div-type-present"/>
        <xsl:if test="not(@type = $expectedBodyDiv1Types)">
            <i:issue pos="{@pos}" code="T05" category="Types" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">Unexpected type for body div1: <xsl:value-of select="@type"/></i:issue>
        </xsl:if>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="elements" select="div2"/>
        </xsl:call-template>

        <xsl:apply-templates mode="checks"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Check the types of <code>div1</code> divisions in the backmatter.</xd:short>
    </xd:doc>

    <xsl:template mode="checks" match="back/div1">
        <xsl:call-template name="check-div-type-present"/>
        <xsl:if test="not(@type = $expectedBackDiv1Types)">
            <i:issue pos="{@pos}" code="T06" category="Types" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">Unexpected type for backmatter div1: <xsl:value-of select="@type"/></i:issue>
        </xsl:if>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="elements" select="div2"/>
        </xsl:call-template>

        <xsl:apply-templates mode="checks"/>
    </xsl:template>


    <xsl:template name="check-div-type-present">
        <xsl:if test="not(@type)">
            <i:issue pos="{@pos}" code="T07" category="Types" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">No type specified for <xsl:value-of select="name()"/></i:issue>
        </xsl:if>
    </xsl:template>


    <xsl:template name="check-id-present">
        <xsl:if test="not(@id)">
            <i:issue pos="{@pos}" code="T08" category="IDs" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">No id specified for <xsl:value-of select="name()"/></i:issue>
        </xsl:if>
    </xsl:template>


    <xsl:template mode="checks" match="div1">
        <xsl:call-template name="check-div-type-present"/>
        <xsl:call-template name="check-id-present"/>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="elements" select="div2"/>
        </xsl:call-template>

        <xsl:apply-templates mode="checks"/>
    </xsl:template>


    <xsl:template mode="checks" match="div2">
        <xsl:call-template name="check-div-type-present"/>

        <xsl:call-template name="sequence-in-order">
            <xsl:with-param name="elements" select="div3"/>
        </xsl:call-template>

        <xsl:apply-templates mode="checks"/>
    </xsl:template>


    <!-- divGen types -->

    <xsl:variable name="expectedDivGenTypes" select="'toc', 'loi', 'Colophon', 'IndexToc', 'apparatus', 'Gallery'" as="xs:string*"/>

    <xsl:template mode="checks" match="divGen">
        <xsl:call-template name="check-div-type-present"/>
        <xsl:if test="not(@type = $expectedDivGenTypes)">
            <i:issue pos="{@pos}" code="T09" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">Unexpected type for &lt;divGen&gt;: <xsl:value-of select="@type"/></i:issue>
        </xsl:if>
        <xsl:apply-templates mode="checks"/>
    </xsl:template>


    <!-- Do we have a following divGen[@type='apparatus'] for this note? -->
    <xsl:template mode="checks" match="note[@place='apparatus']" priority="1">
        <xsl:if test="not(following::divGen[@type='apparatus'])">
            <i:issue pos="{@pos}" code="T10" category="Types" target="{f:generate-id(.)}" level="Warning" element="{name(.)}" page="{f:get-page(.)}">No &lt;divGen type="apparatus"&gt; following apparatus note.</i:issue>
        </xsl:if>
        <xsl:apply-templates mode="checks"/>
        <xsl:next-match/>
    </xsl:template>


    <!-- Types of stage instructions ('mix' is the default provided by the DTD) -->

    <xsl:variable name="expectedStageTypes" select="'mix', 'entrance', 'exit', 'setting'"/>

    <xd:doc>
        <xd:short>Check the types of <code>stage</code> elements.</xd:short>
    </xd:doc>

    <xsl:template mode="checks" match="stage">
        <xsl:if test="@type and not(@type = $expectedStageTypes)">
            <i:issue pos="{@pos}" code="T11" category="Types" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">Unexpected type for stage instruction: <xsl:value-of select="@type"/></i:issue>
        </xsl:if>
        <xsl:apply-templates mode="checks"/>
    </xsl:template>


    <!-- Types of ab (arbitrary block) elements -->

    <xsl:variable name="expectedAbTypes" select="'verseNum', 'lineNum', 'parNum', 'tocPageNum', 'tocDivNum', 'divNum', 'itemNum', 'figNum', 'keyRef', 'lineNumRef', 'textRef', 'keyNum', 'intra', 'top', 'bottom', 'price'" as="xs:string*"/>

    <xd:doc>
        <xd:short>Check the types of <code>ab</code> elements.</xd:short>
    </xd:doc>

    <xsl:template mode="checks" match="ab[@type and not(@type = $expectedAbTypes)]">
        <i:issue pos="{@pos}" code="T12" category="Types" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">Unexpected type for &lt;ab&gt; (arbitrary block) element: <xsl:value-of select="@type"/></i:issue>
        <xsl:apply-templates mode="checks"/>
        <xsl:next-match/>
    </xsl:template>


    <!-- Types of abbr (abbreviation) elements -->

    <xsl:variable name="expectedAbbrTypes" select="'acronym', 'initialism', 'compass', 'compound', 'degree', 'era', 'name', 'postal', 'temperature', 'time', 'timezone'" as="xs:string*"/>

    <xd:doc>
        <xd:short>Check the types of <code>abbr</code> elements.</xd:short>
    </xd:doc>

    <xsl:template mode="checks" match="abbr[@type and not(@type = $expectedAbbrTypes)]">
        <i:issue pos="{@pos}" code="T13" category="Types" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">Unexpected type for &lt;abbr&gt; (abbreviation) element: <xsl:value-of select="@type"/></i:issue>
        <xsl:apply-templates mode="checks"/>
        <xsl:next-match/>
    </xsl:template>


    <!-- Elements not valid in TEI, but sometimes abused while producing a text from HTML. -->

    <xsl:template mode="checks" match="i | b | g | sc | uc | tt | asc">
        <i:issue pos="{@pos}" code="X01" category="Compliance" target="{f:generate-id(.)}" level="Error" element="{name(.)}" page="{f:get-page(.)}">Non-TEI element <xsl:value-of select="name()"/></i:issue>
        <xsl:apply-templates mode="checks"/>
        <xsl:next-match/>
    </xsl:template>


    <xsl:template mode="checks" match="hi[@rend='sc'] | sc">
        <xsl:if test="string(.) = upper-case(string(.))">
            <i:issue pos="{@pos}" code="X02" category="Formatting" target="{f:generate-id(.)}" level="Warning" element="{name(.)}" page="{f:get-page(.)}">Small caps style used for all-caps text: &ldquo;<xsl:value-of select="string(.)"></xsl:value-of>&rdquo;</i:issue>
        </xsl:if>
        <xsl:apply-templates mode="checks"/>
        <xsl:next-match/>
    </xsl:template>


    <xsl:template mode="checks" match="hi[@rend='asc'] | asc" priority="2">
        <xsl:if test="string(.) = lower-case(string(.))">
            <i:issue pos="{@pos}" code="X02" category="Formatting" target="{f:generate-id(.)}" level="Warning" element="{name(.)}" page="{f:get-page(.)}">All small caps style used for all lower-case text: &ldquo;<xsl:value-of select="string(.)"></xsl:value-of>&rdquo;</i:issue>
        </xsl:if>
        <xsl:apply-templates mode="checks"/>
        <xsl:next-match/>
    </xsl:template>


    <xsl:template mode="checks" match="hi[@rend='ex'] | g">
        <xsl:if test="contains(lower-case(string(.)), 'ij')">
            <i:issue pos="{@pos}" code="Y01" category="Formatting" target="{f:generate-id(.)}" level="Warning" element="{name(.)}" page="{f:get-page(.)}">Letterspaced text contains diagraph ij: <xsl:value-of select="string(.)"/>.</i:issue>
        </xsl:if>
        <xsl:apply-templates mode="checks"/>
        <xsl:next-match/>
    </xsl:template>


    <!-- Correction corrects nothing -->

    <xsl:template mode="checks" match="corr[@sic]">
        <xsl:if test="string(.) = string(@sic)">
            <i:issue pos="{@pos}" code="C01" category="Corrections" target="{f:generate-id(.)}" level="Warning" element="{name(.)}" page="{f:get-page(.)}">Correction &ldquo;<xsl:value-of select="@sic"></xsl:value-of>&rdquo; same as original text.</i:issue>
        </xsl:if>
        <xsl:apply-templates mode="checks"/>
    </xsl:template>

    <xsl:template mode="checks" match="corr[sic]">
        <xsl:if test="string(corr) = string(sic)">
            <i:issue pos="{@pos}" code="C01" category="Corrections" target="{f:generate-id(.)}" level="Warning" element="{name(.)}" page="{f:get-page(.)}">Correction &ldquo;<xsl:value-of select="string(corr)"></xsl:value-of>&rdquo; same as original text.</i:issue>
        </xsl:if>
        <xsl:apply-templates mode="checks"/>
    </xsl:template>


    <!-- Figures -->

    <xsl:template mode="checks" match="figure[@url]">
        <i:issue pos="{@pos}" code="F01" category="Compliance" target="{f:generate-id(.)}" level="Warning" element="{name(.)}" page="{f:get-page(.)}">Using non-standard attribute url &ldquo;<xsl:value-of select="@url"></xsl:value-of>&rdquo;.</i:issue>
        <xsl:apply-templates mode="checks"/>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="figure">
        <xsl:if test="not(head) and not(figDesc)">
            <i:issue pos="{@pos}" code="F02" category="Figures" target="{f:generate-id(.)}" level="Trivial" element="{name(.)}" page="{f:get-page(.)}">Figure without head or figDesc will not have alt attribute in output.</i:issue>
        </xsl:if>
        <xsl:apply-templates mode="checks"/>
        <xsl:next-match/>
    </xsl:template>

    <xsl:template mode="checks" match="figure[figure]">
        <xsl:apply-templates mode="checks"/>
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

            <xsl:when test="name($first) = 'div0' and not($first/@type=('Part'))"/>
            <xsl:when test="name($first) = 'div1' and not($first/@type=('Chapter', 'Appendix'))"/>
            <xsl:when test="name($first) = 'div2' and not($first/@type=('Section', 'Appendix'))"/>

            <xsl:when test="not($first/@n)">
                <i:issue pos="{$first/@pos}" code="N01" category="Numbering" target="{f:generate-id($first)}" level="Trivial" element="{name($first)}" page="{f:get-page($first)}">Element <xsl:value-of select="name($first)"/> without number.</i:issue>
            </xsl:when>

            <xsl:when test="not(f:is-integer($first/@n) or f:is-roman($first/@n))">
                <i:issue pos="{$first/@pos}" code="N02" category="Numbering" target="{f:generate-id($first)}" level="Warning" element="{name($first)}" page="{f:get-page($first)}">Element <xsl:value-of select="name($first)"/>: n-attribute <xsl:value-of select="$first/@n"/> not numeric.</i:issue>
            </xsl:when>

            <xsl:when test="f:is-roman($first/@n) and f:is-roman($second/@n)">
                <xsl:if test="not(f:from-roman($second/@n) = f:from-roman($first/@n) + 1)">
                    <i:issue pos="{$second/@pos}" code="S01" category="Numbering" target="{f:generate-id($second)}" level="Warning" element="{name($first)}" page="{f:get-page($first)}">Element <xsl:value-of select="name($first)"/>: n-attribute value <xsl:value-of select="$second/@n"/> out-of-sequence. (preceding: <xsl:value-of select="$first/@n"/>)</i:issue>
                </xsl:if>
            </xsl:when>

            <xsl:when test="f:is-integer($first/@n) and f:is-integer($second/@n)">
                <xsl:if test="not($second/@n = $first/@n + 1)">
                    <i:issue pos="{$second/@pos}" code="S02" category="Numbering" target="{f:generate-id($second)}" level="Warning" element="{name($first)}" page="{f:get-page($first)}">Element <xsl:value-of select="name($first)"/>: n-attribute value <xsl:value-of select="$second/@n"/> out-of-sequence. (preceding: <xsl:value-of select="$first/@n"/>)</i:issue>
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
                <i:issue
                    pos="{./@pos}"
                    code="I01"
                    category="References"
                    target="{f:generate-id(.)}"
                    level="Error"
                    page="{f:get-page(.)}"
                    element="{name(.)}">Element <xsl:value-of select="name(.)"/>: target-attribute value <xsl:value-of select="./@target"/> not present as id.</i:issue>
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
                    <i:issue
                        pos="{$node/@pos}"
                        code="I02"
                        category="References"
                        target="{f:generate-id($node)}"
                        level="Error"
                        page="{f:get-page($node)}"
                        element="{$name}">Element <xsl:value-of select="$name"/>: rendition element <xsl:value-of select="."/> not present.</i:issue>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each-group>

        <!-- @sameAs points to existing @id on element -->
        <xsl:for-each-group select="//*[@sameAs]" group-by="@sameAs">
            <xsl:variable name="sameAs" select="./@sameAs" as="xs:string"/>
            <xsl:if test="not(//*[@id=$sameAs])">
                <i:issue
                    pos="{./@pos}"
                    code="I05"
                    category="References"
                    target="{f:generate-id(.)}"
                    level="Error"
                    page="{f:get-page(.)}"
                    element="{name(.)}">Element <xsl:value-of select="name(.)"/>: sameAs-attribute value <xsl:value-of select="./@sameAs"/> not present as id of any element.</i:issue>
            </xsl:if>
        </xsl:for-each-group>

        <!-- @who points to existing @id on role -->
        <xsl:for-each-group select="//*[@who]" group-by="@who">
            <xsl:variable name="who" select="./@who" as="xs:string"/>
            <xsl:if test="not(//role[@id=$who])">
                <i:issue
                    pos="{./@pos}"
                    code="I03"
                    category="References"
                    target="{f:generate-id(.)}"
                    level="Error"
                    page="{f:get-page(.)}"
                    element="{name(.)}">Element <xsl:value-of select="name(.)"/>: who-attribute value <xsl:value-of select="./@who"/> not present as id of role.</i:issue>
            </xsl:if>
        </xsl:for-each-group>

        <!-- @id of language not being used in the text -->
        <xsl:for-each select="//language">
            <xsl:if test="@id">
                <xsl:variable name="id" select="@id" as="xs:string"/>
                <xsl:if test="not(//*[@lang=$id])">
                    <i:issue
                        pos="{./@pos}"
                        code="I04"
                        category="References"
                        target="{f:generate-id(.)}"
                        level="Warning"
                        page="{f:get-page(.)}"
                        element="{name(.)}">Language <xsl:value-of select="$id"/> (<xsl:value-of select="."/>) declared but not used.</i:issue>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

    </xsl:template>

    <!-- Text level checks, run on segments -->

    <xsl:template mode="checks" match="s:segment">

        <!-- prevent false positives for ellipses. -->
        <xsl:variable name="segment" select="replace(., '\.\.\.+', '&hellip;')" as="xs:string"/>

        <!-- Name some complex regular expressions. -->
        <xsl:variable name="space-after-opener-pattern" select="'[\[(' || $open-quotation-marks || ']\s+'" as="xs:string"/>
        <xsl:variable name="space-before-closer-pattern" select="'\s+[\])' || $close-quotation-marks || ']'" as="xs:string"/>
        <xsl:variable name="space-after-comma-pattern" select="',[^\s&nbsp;&mdash;&hellip;' || $close-quotation-marks || '0-9)\]]'" as="xs:string"/>
        <xsl:variable name="space-after-period-pattern" select="'\.[^\s&nbsp;.,:;&mdash;' || $close-quotation-marks || '0-9)\]]'" as="xs:string"/>
        <xsl:variable name="space-after-punctuation-pattern" select="'[:;!?][^\s&mdash;&hellip;!' || $close-quotation-marks || ')\]]'" as="xs:string"/>

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

        <xsl:copy-of select="f:should-not-contain(., $segment, $space-after-punctuation-pattern,    'Warning', 'P10', 'Missing space after punctuation mark')"/>

        <xsl:copy-of select="f:should-not-contain(., $segment, '''',                                'Warning', 'P14', 'Straight single quote')"/>
        <xsl:copy-of select="f:should-not-contain(., $segment, '&quot;',                            'Warning', 'P15', 'Straight double quote')"/>
        <xsl:copy-of select="f:should-not-contain(., $segment, '#',                                 'Warning', 'P16', 'Hash-sign')"/>
        <xsl:copy-of select="f:should-not-contain(., $segment, '[0-9]/[0-9]',                       'Warning', 'P17', 'Unhandled fraction')"/>
        <xsl:copy-of select="f:should-not-contain(., $segment, '[|]',                               'Warning', 'P18', 'Vertical Bar')"/>


        <xsl:variable name="nfd-segment" select="normalize-unicode($segment, 'NFD')" as="xs:string"/>

        <!-- Greek script checks -->
        <xsl:variable name="final-sigma-mid-word-pattern" select="'&#x03C2;\p{L}'" as="xs:string"/>
        <xsl:variable name="sigma-end-word-pattern" select="'&#x03C3;\P{L}'" as="xs:string"/>
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
        <xsl:value-of select="if (substring($target, 1, 1) = '#') then substring($target, 2) else $target"/>
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

        <!-- Sort by length, longest first, then alphabetical, case-insensitive, then capitals first -->
        <tmp:abbrs>
            <xsl:for-each select="$abbrs//tmp:abbr">
                <xsl:sort select="string-length(.)" data-type="number" order="descending"/>
                <xsl:sort select="lower-case(.)" data-type="text" order="ascending"/>
                <xsl:sort select="." data-type="text" order="ascending"/>
                <tmp:abbr><xsl:value-of select="."/></tmp:abbr>
            </xsl:for-each>
        </tmp:abbrs>
    </xsl:function>


    <xsl:function name="f:hide-abbreviations" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:value-of select="f:hide-abbreviation($string, count($common-abbreviations/tmp:abbr))"/>
    </xsl:function>

    <xsl:function name="f:hide-abbreviation" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:param name="n"/>

        <xsl:variable name="old" select="$common-abbreviations/tmp:abbr[$n]"/>
        <xsl:variable name="new" select="replace($old, '\.', '&blackCircle;')"/>
        <xsl:variable name="pattern" select="replace($old, '\.', '\\.')"/>

        <xsl:variable name="result" as="xs:string">
            <xsl:choose>
                <xsl:when test="$n > 0">
                    <xsl:value-of select="replace(f:hide-abbreviation($string, $n - 1), $pattern, $new)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$string"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="$result"/>
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
                <i:issue
                    pos="{$node/@pos}"
                    level="Warning"
                    code="P19"
                    category="Punctuation"
                    target="{f:generate-id($node)}"
                    page="{$node/@sourcePage}"
                    element="{$node/@sourceElement}">
                        Spaced abbreviation <xsl:value-of select="$abbr"/> in: <xsl:value-of select="f:match-fragment($string, $pattern)"/></i:issue>
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
            <i:issue
                pos="{$node/@pos}"
                level="{$level}"
                code="{$code}"
                category="Punctuation"
                target="{f:generate-id($node)}"
                page="{$node/@sourcePage}"
                element="{$node/@sourceElement}">
                    <xsl:value-of select="$message"/> in: <xsl:value-of select="f:match-fragment($segment, $pattern)"/></i:issue>
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
                <i:issue
                    pos="{@pos}"
                    code="P11"
                    category="Punctuation"
                    target="{f:generate-id(.)}"
                    level="Warning"
                    element="{./@sourceElement}"
                    page="{./@sourcePage}"><xsl:value-of select="$unclosed"/> in: <xsl:value-of select="f:head-chars($string)"/></i:issue>
            </xsl:when>
            <xsl:when test="f:contains-only($unclosed, $open-quotation-marks)">
                <xsl:if test="not(starts-with($unspacedNext, f:reverse($unclosed)))">
                    <i:issue
                        pos="{@pos}"
                        code="P12"
                        category="Punctuation"
                        target="{f:generate-id(.)}"
                        level="Warning"
                        element="{./@sourceElement}"
                        page="{./@sourcePage}">Unclosed quotation mark(s): <xsl:value-of select="$unclosed"/> not re-openend in next paragraph.
                        Current: <xsl:value-of select="f:tail-chars($string)"/>
                        Next: <xsl:value-of select="f:head-chars($next)"/>
                    </i:issue>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$unclosed != ''">
                <i:issue
                    pos="{@pos}"
                    code="P13"
                    category="Punctuation"
                    target="{f:generate-id(.)}"
                    level="Warning"
                    element="{./@sourceElement}"
                    page="{./@sourcePage}">Unclosed punctuation: <xsl:value-of select="$unclosed"/> in: <xsl:value-of select="f:head-chars($string)"/></i:issue>
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
            '&#xFF08;&#xFF09;&#xFF3B;&#xFF3D;&#xFF5B;&#xFF5B;&#xFF03;&blackCircle;', 
            '()[]{}#.')"/>
    </xsl:function>


</xsl:stylesheet>