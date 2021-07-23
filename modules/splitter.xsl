<!DOCTYPE xsl:stylesheet [

    <!ENTITY ldquo      "&#x201C;">
    <!ENTITY rdquo      "&#x201D;">

]>

<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f xd xhtml xs">

    <xd:doc type="stylesheet">
        <xd:short>Templates for splitting a TEI document in parts.</xd:short>
        <xd:detail><p>This stylesheet contains templates for splitting a TEI document in parts, specifically meant
        for generating ePub output.</p>

        <p>We need to split a TEI document into pieces, and in addition, also
        need to be able to consistently generate various types of lists
        of generated files, and cross-references both internal to a part
        and to other parts.</p>

        <p>To accomplish this, we use the &ldquo;splitter&rdquo; mode to obtain the parts,
        and hand through an &ldquo;action&rdquo; parameter to select the appropriate
        action once we land in the part to be handled. Once arrived at the
        level we wish to split at, we call the appropriate template to
        handle the content.</p>

        <p>The following actions are supported:</p>

        <table>
            <tr><td>content     </td><td>Generate the (named) files with the content.</td></tr>
            <tr><td>filename    </td><td>Generate the name of the file that contains the (transformed) element represented in $node.</td></tr>
            <tr><td>manifest    </td><td>Generate the manifest (ODF) for ePub.</td></tr>
            <tr><td>spine       </td><td>Generate the spine (ODF) for ePub.</td></tr>
        </table>
        </xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2012, 2014, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Split a TEI document.</xd:short>
        <xd:detail>Split a TEI document into parts, entering the splitter in default mode.</xd:detail>
    </xd:doc>

    <xsl:template match="/*[self::TEI.2 or self::TEI]/text" priority="2">
        <xsl:apply-templates mode="splitter" select=".">
            <xsl:with-param name="splitter-action" select="'content'" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>


    <xd:doc mode="splitter">
        <xd:short>Mode used to split divisions into files for ePub.</xd:short>
    </xd:doc>


    <xd:doc>
        <xd:short>Split text element.</xd:short>
        <xd:detail>Split the top-level <code>text</code> element (not to be confused with a text node) of a TEI file.</xd:detail>
    </xd:doc>

    <xsl:template match="text" mode="splitter">

        <xsl:call-template name="epubPGHeader"/>
        <xsl:apply-templates select="front" mode="splitter"/>
        <xsl:apply-templates select="body" mode="splitter"/>
        <xsl:apply-templates select="back" mode="splitter"/>
        <xsl:call-template name="epubPGFooter"/>

    </xsl:template>


    <xd:doc>
        <xd:short>Split <code>body</code> element.</xd:short>
        <xd:detail>Split the <code>body</code> element of a TEI file on <code>div0</code> elements.</xd:detail>
    </xd:doc>

    <xsl:template match="body[div0]" mode="splitter">
        <xsl:apply-templates select="div0" mode="splitter"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Split elements on <code>div1</code> elements.</xd:short>
        <xd:detail>Split <code>div0</code>, <code>front</code>, <code>back</code>, and <code>body</code> elements of a TEI file on <code>div1</code> elements. Here we can either have
        a sequence of non-<code>div1</code> elements (we split no further) or a sequence of <code>div1</code> elements (we may need to split further).</xd:detail>
    </xd:doc>

    <xsl:template match="div0 | front | back | body[div1]" mode="splitter">
        <xsl:for-each-group select="node()" group-adjacent="not(self::div1)">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <!-- Sequence of non-div1 elements -->
                    <xsl:call-template name="div-fragment">
                        <xsl:with-param name="splitter-fragment-nodes" select="current-group()" tunnel="yes"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Sequence of div1 elements -->
                    <xsl:apply-templates select="current-group()" mode="splitter"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>


    <xd:doc>
        <xd:short>Split elements on (unnumbered) <code>div</code> elements.</xd:short>
        <xd:detail>Split <code>front</code>, <code>back</code>, and <code>body</code> elements of a TEI file on <code>div</code> elements. Here we can either have
        a sequence of non-<code>div</code> elements (we split no further) or a sequence of <code>div</code> elements (we may need to split further).</xd:detail>
    </xd:doc>

    <xsl:template match="front[div] | back[div] | body[div]" mode="splitter">
        <xsl:for-each-group select="node()" group-adjacent="not(self::div)">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <!-- Sequence of non-div elements -->
                    <xsl:call-template name="div-fragment">
                        <xsl:with-param name="splitter-fragment-nodes" select="current-group()" tunnel="yes"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Sequence of div elements -->
                    <xsl:apply-templates select="current-group()" mode="splitter"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle a fragment of a div0, div1, or div element.</xd:short>
        <xd:detail>Handle a fragment of a div0, div1, or div element. What we do depends on the action parameter being passed.</xd:detail>
        <xd:param name="splitter-action">A coded action string, which indicates what end-result we expect from the splitter.</xd:param>
    </xd:doc>

    <xsl:template name="div-fragment">
        <xsl:context-item as="element()" use="required"/>
        <xsl:param name="splitter-action" as="xs:string" tunnel="yes"/>

        <xsl:choose>
            <xsl:when test="$splitter-action = 'filename'">
                <xsl:call-template name="filename.div-fragment"/>
            </xsl:when>
            <xsl:when test="$splitter-action = 'manifest'">
                <xsl:call-template name="manifest.div-fragment"/>
            </xsl:when>
            <xsl:when test="$splitter-action = 'spine'">
                <xsl:call-template name="spine.div-fragment"/>
            </xsl:when>
            <xsl:when test="$splitter-action = 'content'">
                <xsl:call-template name="content.div-fragment"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="f:log-error('Unknown splitter-action {1} in div-fragment.', ($splitter-action))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Split a <code>div1</code> or <code>div</code> element.</xd:short>
        <xd:detail>Split a <code>div1</code> or (unnumbered) <code>div</code> element of a TEI file on the <code>epubsplit</code> processing instruction.</xd:detail>
    </xd:doc>

    <xsl:template match="div1 | div" mode="splitter">
        <xsl:choose>
            <xsl:when test="processing-instruction(epubsplit)">
                <xsl:for-each-group select="node()" group-adjacent="not(self::processing-instruction(epubsplit))">
                    <xsl:if test="current-grouping-key()">
                        <!-- Sequence of elements -->
                        <xsl:call-template name="div-fragment">
                            <xsl:with-param name="splitter-fragment-nodes" select="current-group()" tunnel="yes"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="choose-splitter-action"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Select the appropriate action.</xd:short>
        <xd:detail>Select the appropriate action for the node.</xd:detail>
        <xd:param name="splitter-action">A coded action string, which indicates what end-result we expect from the splitter.</xd:param>
    </xd:doc>

    <xsl:template name="choose-splitter-action">
        <xsl:context-item as="element()" use="required"/>
        <xsl:param name="splitter-action" as="xs:string" tunnel="yes"/>

        <xsl:choose>
            <xsl:when test="$splitter-action = 'filename'">
                <xsl:call-template name="filename.div"/>
            </xsl:when>
            <xsl:when test="$splitter-action = 'manifest'">
                <xsl:call-template name="manifest.div"/>
            </xsl:when>
            <xsl:when test="$splitter-action = 'spine'">
                <xsl:call-template name="spine.div"/>
            </xsl:when>
            <xsl:when test="$splitter-action = 'content'">
                <xsl:call-template name="content.div"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="f:log-error('Unknown splitter-action {1} in choose-splitter-action.', ($splitter-action))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!--========= Filename =========-->

    <xd:doc>
        <xd:short>Determine the filename of a div-fragment.</xd:short>
        <xd:detail>Determine the filename of the file that contains a certain node. We traverse the document tree, as it will be split, and
        look for the specific node the target node appears in. Only in that case, we generate the filename; in all other cases this template
        will generate nothing. The end result is a string containing the filename of the file the target node appears in.</xd:detail>
    </xd:doc>

    <xsl:template name="filename.div-fragment">
        <xsl:context-item as="element()" use="required"/>
        <xsl:param name="splitter-target-node" as="element()" tunnel="yes"/>
        <xsl:param name="splitter-fragment-nodes" as="node()*" tunnel="yes"/>

        <xsl:variable name="position" select="position()"/> <!-- that is, position of context group -->
        <xsl:variable name="target-id" select="generate-id($splitter-target-node)"/>

        <!-- Is our parent or does this fragment contain the node sought after? -->
        <xsl:if test="($position = 1 and generate-id(..) = $target-id)
                      or (some $node in $splitter-fragment-nodes 
                          satisfies generate-id($node) = $target-id or $node//*[generate-id() = $target-id])">
            <xsl:value-of select="f:generate-nth-filename(.., $position)"/>
            <!-- <xsl:message expand-text="yes">DEBUG: Found fragment {$position}: {name($splitter-target-node)}#{$splitter-target-node/@id} in {f:generate-nth-filename(.., $position)}</xsl:message> -->
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Determine the filename of a division.</xd:short>
        <xd:detail>Determine the filename of the file that contains a certain node.</xd:detail>
    </xd:doc>

    <xsl:template name="filename.div">
        <xsl:context-item as="element()" use="required"/>
        <xsl:param name="splitter-target-node" as="element()" tunnel="yes"/>

        <xsl:variable name="target-id" select="generate-id($splitter-target-node)"/>

        <!-- Is this or does this element contain the node sought after? -->
        <xsl:if test="generate-id(.) = $target-id or .//*[generate-id() = $target-id]">
            <xsl:value-of select="f:generate-filename(.)"/>
            <!-- <xsl:message expand-text="yes">DEBUG: Found element: {name($splitter-target-node)}#{$splitter-target-node/@id} in {f:generate-filename(.)}</xsl:message> -->
        </xsl:if>
    </xsl:template>


    <!--========= Manifest =========-->

    <xd:doc>
        <xd:short>Generate an OPF manifest entry for a div-fragment.</xd:short>
        <xd:detail>Generate an OPF manifest entry for the file that contains a div-fragment. Also handle the case where
        an item in this fragment (typically a title page) refers to a media overlay.</xd:detail>
    </xd:doc>

    <xsl:template name="manifest.div-fragment">
        <xsl:context-item as="element()" use="required"/>
        <xsl:param name="splitter-fragment-nodes" as="node()*" tunnel="yes"/>

        <item xmlns="http://www.idpf.org/2007/opf">
            <xsl:variable name="id" select="f:generate-id(.)"/>
            <xsl:attribute name="id">
                <xsl:value-of select="f:generate-nth-id(.., position())"/>
            </xsl:attribute>
            <xsl:attribute name="href">
                <xsl:value-of select="f:generate-nth-filename(.., position())"/>
            </xsl:attribute>
            <xsl:attribute name="media-type">application/xhtml+xml</xsl:attribute>

            <xsl:if test="f:containsMathML($splitter-fragment-nodes)">
                <xsl:attribute name="properties" select="'mathml'"/>
            </xsl:if>

            <!-- Check-out for possible media overlays in the sequence of nodes; collect them all. -->
            <xsl:variable name="media-overlays">
                <xsl:for-each select="$splitter-fragment-nodes">
                    <xsl:if test="f:has-rend-value(@rend, 'media-overlay')">
                        <xsl:value-of select="$id"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>

            <!-- Only use the first media overlay, we cannot have more than one (typically on the title page).  -->
            <xsl:if test="$media-overlays[1] != ''">
                <xsl:attribute name="media-overlay"><xsl:value-of select="$media-overlays[1]"/>overlay</xsl:attribute>
            </xsl:if>

            <!-- Warn for extra media overlays -->
            <xsl:if test="$media-overlays[2]">
                <xsl:copy-of select="f:log-error('Ignoring second media-overlay for single file (id: {1}).', ($media-overlays[2]))"/>
            </xsl:if>
        </item>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate an OPF manifest entry for a division.</xd:short>
        <xd:detail>Generate an OPF manifest entry for the file that contains a division. Also handle the case where
        this division refers to a media overlay.</xd:detail>
    </xd:doc>

    <xsl:template name="manifest.div">
        <xsl:context-item as="element()" use="required"/>
        <item xmlns="http://www.idpf.org/2007/opf">
            <xsl:variable name="id" select="f:generate-id(.)"/>
            <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
            <xsl:attribute name="href"><xsl:value-of select="f:generate-filename(.)"/></xsl:attribute>
            <xsl:attribute name="media-type">application/xhtml+xml</xsl:attribute>

            <xsl:if test="f:containsMathML(.)">
                <xsl:attribute name="properties" select="'mathml'"/>
            </xsl:if>

            <xsl:if test="f:has-rend-value(@rend, 'media-overlay')">
                <xsl:attribute name="media-overlay"><xsl:value-of select="$id"/>overlay</xsl:attribute>
            </xsl:if>
        </item>
    </xsl:template>


    <xsl:function name="f:containsMathML" as="xs:boolean">
        <xsl:param name="nodes" as="node()*"/>

        <xsl:sequence select="f:get-setting('math.mathJax.format') = 'MML'
            and (some $node in $nodes satisfies $node//formula[@notation='TeX'][not(f:is-trivial-math(.))])"/>
    </xsl:function>

    <!--========= Spine =========-->

    <xd:doc>
        <xd:short>Generate a spine entry for a div-fragment.</xd:short>
        <xd:detail>Generate a spine entry for a div-fragment.</xd:detail>
    </xd:doc>

    <xsl:template name="spine.div-fragment">
        <xsl:context-item as="element()" use="required"/>
        <itemref xmlns="http://www.idpf.org/2007/opf" linear="yes">
            <xsl:attribute name="idref">
                <xsl:value-of select="f:generate-nth-id(.., position())"/>
            </xsl:attribute>
        </itemref>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate a spine entry for a division.</xd:short>
        <xd:detail>Generate a spine entry for a division.</xd:detail>
    </xd:doc>

    <xsl:template name="spine.div">
        <xsl:context-item as="element()" use="required"/>
        <!-- filter out the cover, as we have placed it first already -->
        <xsl:if test="@id != 'cover'">
            <itemref xmlns="http://www.idpf.org/2007/opf" linear="yes" idref="{f:generate-id(.)}"/>
        </xsl:if>
    </xsl:template>


    <!--========= Content =========-->

    <xd:doc>
        <xd:short>Generate the content for a div-fragment.</xd:short>
    </xd:doc>

    <xsl:template name="content.div-fragment">
        <xsl:context-item as="element()" use="required"/>
        <xsl:param name="splitter-fragment-nodes" as="node()*" tunnel="yes"/>

        <xsl:variable name="filename" select="f:generate-nth-filename(.., position())" as="xs:string"/>

        <xsl:result-document href="{$path}/{$filename}">
            <xsl:copy-of select="f:log-info('Generated file [{3}.{4}]: {1}/{2}.', ($path, $filename, name(..), string(position())))"/>
            <html>
                <xsl:call-template name="generate-html-header"/>
                <body>
                    <div>
                        <xsl:call-template name="set-class-attribute-for-body"/>
                        <xsl:choose>
                            <xsl:when test="(parent::div0 or parent::div1 or parent::div) and position() = 1">
                                <div class="{name(..)}" id="{f:generate-id(..)}">
                                    <xsl:call-template name="generate-label">
                                        <xsl:with-param name="div" select=".."/>
                                    </xsl:call-template>
                                    <xsl:apply-templates select="$splitter-fragment-nodes"/>

                                    <xsl:if test="parent::div0">
                                        <xsl:call-template name="insert-footnotes">
                                            <xsl:with-param name="notes" select="$splitter-fragment-nodes//note[f:is-footnote(.)]"/>
                                        </xsl:call-template>
                                    </xsl:if>
                                </div>
                            </xsl:when>
                            <xsl:when test="(parent::div1 or parent::div) and position() = last()">
                                <xsl:apply-templates select="$splitter-fragment-nodes"/>
                                <xsl:call-template name="insert-footnotes">
                                    <xsl:with-param name="div" select=".."/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="$splitter-fragment-nodes"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate the content for a division.</xd:short>
    </xd:doc>

    <xsl:template name="content.div">
        <xsl:context-item as="element()" use="required"/>
        <xsl:variable name="filename" select="f:generate-filename(.)" as="xs:string"/>

        <xsl:result-document href="{$path}/{$filename}">
            <xsl:copy-of select="f:log-info('Generated file [{3}]: {1}/{2}.', ($path, $filename, name(.)))"/>
            <html>
                <xsl:call-template name="generate-html-header"/>
                <body>
                    <div>
                        <xsl:call-template name="set-class-attribute-for-body"/>
                        <xsl:apply-templates select="."/>
                    </div>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>


    <!--========= Utility functions =========-->

    <xd:doc>
        <xd:short>Generate a filename.</xd:short>
        <xd:detail>Generate a filename for use in an ePub file.</xd:detail>
    </xd:doc>

    <xsl:function name="f:generate-filename" as="xs:string">
        <xsl:param name="node" as="element()"/>

        <xsl:value-of select="if ($node/@id = 'cover') 
                              then 'cover.xhtml' 
                              else $basename || '-' || f:generate-id($node) || '.xhtml'"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate a filename with number.</xd:short>
        <xd:detail>Generate a filename for use in an ePub file. This function is used when a single element is split-up in multiple
        parts.</xd:detail>
    </xd:doc>

    <xsl:function name="f:generate-nth-filename" as="xs:string">
        <xsl:param name="node" as="element()"/>
        <xsl:param name="position" as="xs:integer"/>

        <xsl:value-of select="if ($node/@id = 'cover' and $position = 1)
                              then 'cover.xhtml'
                              else $basename || '-' || f:generate-id($node) || '-' || $position || '.xhtml'"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine the name of the file a certain element appears in.</xd:short>
        <xd:detail>Determine the name of the file a certain element appears in. This function is used to establish
        in which file a certain element has ended up.</xd:detail>
    </xd:doc>

    <xsl:function name="f:determine-filename" as="xs:string">
        <xsl:param name="node" as="element()"/>

        <!-- Elements included in the teiHeader appear in the generated colophon (if they appear at all) -->
        <xsl:variable name="node" select="if ($node/ancestor-or-self::teiHeader) then root($node)//divGen[@type='Colophon'] else $node"/>

        <xsl:variable name="filename">
            <xsl:apply-templates select="root($node)/*[self::TEI.2 or self::TEI]/text" mode="splitter">
                <xsl:with-param name="splitter-target-node" select="$node" tunnel="yes"/>
                <xsl:with-param name="splitter-action" select="'filename'" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:variable>

        <xsl:value-of select="if ($filename = '')
            then f:log-error('Unable to determine filename for {1} with generated id: {2} (parent: {3}; id: {4})', 
                                (name($node), f:generate-id($node), name($node/ancestor::*[@id][1]), $node/ancestor::*[@id][1]/@id))
            else $filename"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine the url for an element.</xd:short>
        <xd:detail>Determine the url for an element within the scope of an ePub file.</xd:detail>
    </xd:doc>

    <xsl:function name="f:determine-url" as="xs:string">
        <xsl:param name="node" as="element()"/>

        <xsl:value-of select="f:determine-filename($node) || '#' || f:generate-id($node)"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine the class for the body.</xd:short>
        <xd:detail>Determine the class for the body, based on whether it is part of the front matter, body text or back matter of the book.</xd:detail>
    </xd:doc>

    <xsl:template name="set-class-attribute-for-body">
        <xsl:attribute name="class">
            <xsl:choose>
                <xsl:when test="ancestor::front">front</xsl:when>
                <xsl:when test="ancestor::back">back</xsl:when>
                <xsl:otherwise>body</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>


    <xd:doc>
        <xd:short>Output the Project Gutenberg header.</xd:short>
    </xd:doc>

    <xsl:template name="epubPGHeader">
        <xsl:param name="splitter-action" as="xs:string" tunnel="yes"/>

        <xsl:if test="f:is-set('pg.includeHeaders')">
            <xsl:choose>
                <xsl:when test="$splitter-action = 'spine'">
                    <itemref xmlns="http://www.idpf.org/2007/opf" linear="yes" idref="pgheader"/>
                </xsl:when>
                <xsl:when test="$splitter-action = 'content'">
                    <xsl:result-document href="{$path}/pgheader.xhtml">
                        <xsl:copy-of select="f:log-info('Generated file [{3}]: {1}/{2}.', ($path, 'pgheader.xhtml', name(.)))"/>
                        <html>
                            <xsl:call-template name="generate-html-header"/>
                            <body>
                                <xsl:variable name="header"><xsl:call-template name="PGHeader"/></xsl:variable>
                                <xsl:apply-templates select="$header" mode="adjust-pg-footer-links"/>
                            </body>
                        </html>
                    </xsl:result-document>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Output the Project Gutenberg footer.</xd:short>
    </xd:doc>

    <xsl:template name="epubPGFooter">
        <xsl:param name="splitter-action" as="xs:string" tunnel="yes"/>

        <xsl:if test="f:is-set('pg.includeHeaders')">
            <xsl:choose>
                <xsl:when test="$splitter-action = 'spine'">
                    <itemref xmlns="http://www.idpf.org/2007/opf" linear="yes" idref="pgfooter"/>
                </xsl:when>
                <xsl:when test="$splitter-action = 'content'">
                    <xsl:result-document href="{$path}/pgfooter.xhtml">
                        <xsl:copy-of select="f:log-info('Generated file [{3}]: {1}/{2}.', ($path, 'pgfooter.xhtml', name(.)))"/>
                        <html>
                            <xsl:call-template name="generate-html-header"/>
                            <body>
                                <xsl:variable name="footer"><xsl:call-template name="PGFooter"/></xsl:variable>
                                <xsl:apply-templates select="$footer" mode="adjust-pg-footer-links"/>
                            </body>
                        </html>
                    </xsl:result-document>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:template>


    <xd:doc mode="adjust-pg-footer-links">
        <xd:short>Mode used to adjust links in the PG footer and header in the ePub.</xd:short>
    </xd:doc>

    <xd:doc>
        <xd:short>Replace links in the header and footer with links to the correct file in the ePub.</xd:short>
    </xd:doc>

    <xsl:template match="xhtml:a/@href[starts-with(., '#pglicense')]" mode="adjust-pg-footer-links">
        <xsl:attribute name="href" select="'pgfooter.xhtml' || ."/>
    </xsl:template>

    <xsl:template match="@*|node()" mode="adjust-pg-footer-links">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>


</xsl:stylesheet>
