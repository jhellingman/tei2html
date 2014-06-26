<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:f="urn:stylesheet-functions"
    version="2.0"
    exclude-result-prefixes="f xs xd"
    >

    <xd:doc type="stylesheet">
        <xd:short>Templates for splitting a TEI document in parts.</xd:short>
        <xd:detail><p>This stylesheet contains templates for splitting a TEI document in parts, specifically meant
        for generating ePub output.</p>
        
        <p>We need to split a TEI document into pieces, and in addition, also
        need to be able to consistently generate various types of lists
        of generated files, and cross-references both internal to a part
        and to other parts.</p>

        <p>To accomplish this, we use the "splitter" mode to obtain the parts,
        and hand through an "action" parameter to select the appropriate
        action once we land in the part to be handled. Once arrived at the
        level we wish to split at, we call the appropriate template to
        handle the content.</p>

        <p>The following actions are supported:</p>

        <table>
            <tr><td>[empty]     </td><td>Generate the (named) files with the content.</td></tr>
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

    <xsl:template match="/TEI.2/text" priority="2">
        <xsl:apply-templates mode="splitter"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Split text element.</xd:short>
        <xd:detail>Split the top-level text element of a TEI file.</xd:detail>
            <xd:param name="action">A coded action string, which indicates what end-result we expect from the splitter.</xd:param>
            <xd:param name="node">Node of which we want to know in which output file it will end-up (only relevant in <code>filename</code>-mode).</xd:param>
    </xd:doc>

    <xsl:template match="text" mode="splitter">
        <xsl:param name="action" select="''" as="xs:string"/>
        <xsl:param name="node"/>

        <xsl:apply-templates select="front" mode="splitter">
            <xsl:with-param name="action" select="$action"/>
            <xsl:with-param name="node" select="$node"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="body" mode="splitter">
            <xsl:with-param name="action" select="$action"/>
            <xsl:with-param name="node" select="$node"/>
        </xsl:apply-templates>

        <xsl:apply-templates select="back" mode="splitter">
            <xsl:with-param name="action" select="$action"/>
            <xsl:with-param name="node" select="$node"/>
        </xsl:apply-templates>

    </xsl:template>


    <xd:doc>
        <xd:short>Split body element.</xd:short>
        <xd:detail>Split the body element of a TEI file on div0 elements.</xd:detail>
    </xd:doc>

    <xsl:template match="body[div0]" mode="splitter">
        <xsl:param name="action" select="''" as="xs:string"/>
        <xsl:param name="node"/>

        <xsl:apply-templates select="div0" mode="splitter">
            <xsl:with-param name="action" select="$action"/>
            <xsl:with-param name="node" select="$node"/>
        </xsl:apply-templates>
    </xsl:template>


    <xd:doc>
        <xd:short>Split elements on div1 elements.</xd:short>
        <xd:detail>Split div0, front, back, and body elements of a TEI file on div1 elements. Here we can either have
        a sequence of non-div1 elements (we split no further) or a sequence of div1 elements (we may need to split further).</xd:detail>
    </xd:doc>

    <xsl:template match="div0 | front | back | body[div1]" mode="splitter">
        <xsl:param name="action" select="''" as="xs:string"/>
        <xsl:param name="node"/>

        <xsl:for-each-group select="node()" group-adjacent="not(self::div1)">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <!-- Sequence of non-div1 elements -->
                    <xsl:call-template name="div-fragment">
                        <xsl:with-param name="action" select="$action"/>
                        <xsl:with-param name="node" select="$node"/>
                        <xsl:with-param name="nodes" select="current-group()"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Sequence of div1 elements -->
                    <xsl:apply-templates select="current-group()" mode="splitter">
                        <xsl:with-param name="action" select="$action"/>
                        <xsl:with-param name="node" select="$node"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>


    <xd:doc>
        <xd:short>Split elements on (unnumbered) div elements.</xd:short>
        <xd:detail>Split front, back, and body elements of a TEI file on div elements. Here we can either have
        a sequence of non-div elements (we split no further) or a sequence of div elements (we may need to split further).</xd:detail>
    </xd:doc>

    <xsl:template match="front[div] | back[div] | body[div]" mode="splitter">
        <xsl:param name="action" select="''" as="xs:string"/>
        <xsl:param name="node"/>

        <xsl:for-each-group select="node()" group-adjacent="not(self::div)">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <!-- Sequence of non-div elements -->
                    <xsl:call-template name="div-fragment">
                        <xsl:with-param name="action" select="$action"/>
                        <xsl:with-param name="node" select="$node"/>
                        <xsl:with-param name="nodes" select="current-group()"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Sequence of div elements -->
                    <xsl:apply-templates select="current-group()" mode="splitter">
                        <xsl:with-param name="action" select="$action"/>
                        <xsl:with-param name="node" select="$node"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each-group>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle a fragment of a div0, div1, or div element.</xd:short>
        <xd:detail>Handle a fragment of a div0, div1, or div element. What we do depends on the action parameter being passed.</xd:detail>
        <xd:param name="action">A coded action string, which indicates what end-result we expect from the splitter.</xd:param>
        <xd:param name="node">Node of which we want to know in which output file it will end-up (only relevant in <code>filename</code>-mode).</xd:param>
        <xd:param name="nodes">The nodes that make up the fragment.</xd:param>
    </xd:doc>

    <xsl:template name="div-fragment">
        <xsl:param name="action" select="''" as="xs:string"/>
        <xsl:param name="node"/>
        <xsl:param name="nodes"/>

        <xsl:choose>
            <xsl:when test="$action = 'filename'">
                <xsl:call-template name="filename.div-fragment">
                    <xsl:with-param name="node" select="$node"/>
                    <xsl:with-param name="nodes" select="$nodes"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$action = 'manifest'">
                <xsl:call-template name="manifest.div-fragment">
                    <xsl:with-param name="nodes" select="$nodes"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$action = 'spine'">
                <xsl:call-template name="spine.div-fragment">
                    <xsl:with-param name="nodes" select="$nodes"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="content.div-fragment">
                    <xsl:with-param name="nodes" select="$nodes"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xd:doc>
        <xd:short>Split elements a <code>div1</code> or <code>div</code> element.</xd:short>
        <xd:detail>Split a <code>div1</code> or (unnumbered) <code>div</code> element of a TEI file on the <code>epubsplit</code> processing instruction.</xd:detail>
    </xd:doc>

    <xsl:template match="div1 | div" mode="splitter">
        <xsl:param name="action" select="''" as="xs:string"/>
        <xsl:param name="node"/>

        <xsl:choose>
            <xsl:when test="processing-instruction(epubsplit)">
                <xsl:for-each-group select="node()" group-adjacent="not(self::processing-instruction(epubsplit))">
                    <xsl:choose>
                        <xsl:when test="current-grouping-key()">
                            <!-- Sequence of non-div1 or div elements -->
                            <xsl:call-template name="div-fragment">
                                <xsl:with-param name="action" select="$action"/>
                                <xsl:with-param name="node" select="$node"/>
                                <xsl:with-param name="nodes" select="current-group()"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="choose-splitter-action">
                    <xsl:with-param name="action" select="$action"/>
                    <xsl:with-param name="node" select="$node"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Select the appropriate action.</xd:short>
        <xd:detail>Select the appropriate action for the node.</xd:detail>
        <xd:param name="action">A coded action string, which indicates what end-result we expect from the splitter.</xd:param>
        <xd:param name="node">Node of which we want to know in which output file it will end-up (only relevant in <code>filename</code>-mode).</xd:param>
    </xd:doc>

    <xsl:template name="choose-splitter-action">
        <xsl:param name="action" as="xs:string"/>
        <xsl:param name="node"/>

        <xsl:choose>
            <xsl:when test="$action = 'filename'">
                <xsl:call-template name="filename.div">
                    <xsl:with-param name="node" select="$node"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$action = 'manifest'">
                <xsl:call-template name="manifest.div"/>
            </xsl:when>
            <xsl:when test="$action = 'spine'">
                <xsl:call-template name="spine.div"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="content.div"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xd:doc>
        <xd:short>Determine the filename of a div-fragment.</xd:short>
        <xd:detail>Determine the filename of the file that contains a certain node.</xd:detail>
    </xd:doc>

    <xsl:template name="filename.div-fragment">
        <xsl:param name="node" as="element()"/>
        <xsl:param name="nodes"/>

        <xsl:param name="position" select="position()"/> <!-- that is, position of context group -->

        <!-- Does any of the nodes contains the node sought after? -->
        <xsl:for-each select="$nodes">
            <!--<xsl:message terminate="no">INFO:    locating node in: <xsl:value-of select="name()"/>[<xsl:value-of select="$position"/>]. Count: <xsl:value-of select="count(.)"/>/<xsl:value-of select="count($node)"/>.</xsl:message>
            <xsl:message terminate="no">Content: <xsl:value-of select="$node"/>.</xsl:message>-->

            <xsl:if test="descendant-or-self::*[generate-id() = generate-id($node)]">
                <xsl:call-template name="generate-filename-for">
                    <xsl:with-param name="node" select=".."/>
                    <xsl:with-param name="position" select="$position"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>

        <!-- Handle the case where we are referring to the div0 element itself (our parent) -->
        <xsl:if test="(generate-id(..) = generate-id($node)) and position() = 1">
            <xsl:call-template name="generate-filename-for">
                <xsl:with-param name="node" select=".."/>
                <xsl:with-param name="position" select="$position"/>
            </xsl:call-template>
        </xsl:if>

    </xsl:template>

    <xd:doc>
        <xd:short>Determine the filename of a division.</xd:short>
        <xd:detail>Determine the filename of the file that contains a certain node.</xd:detail>
    </xd:doc>

    <xsl:template name="filename.div">
        <xsl:param name="node" as="element()"/>

        <!-- Does this div1 or (unnumbered) div contain the node sought after? -->
        <xsl:if test="descendant-or-self::*[generate-id() = generate-id($node)]">
            <xsl:call-template name="generate-filename"/>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate an OPF manifest entry for a div-fragment.</xd:short>
        <xd:detail>Generate an OPF manifest entry for the file that contains a div-fragment. Also handle the case where
        an item in this fragment (typically a title page) refers to a media overlay.</xd:detail>
    </xd:doc>

    <xsl:template name="manifest.div-fragment">
        <xsl:param name="nodes"/>

        <item xmlns="http://www.idpf.org/2007/opf">
            <xsl:variable name="id"><xsl:call-template name="generate-id"/></xsl:variable>
            <xsl:attribute name="id">
                <xsl:call-template name="generate-id-for">
                    <xsl:with-param name="node" select=".."/>
                    <xsl:with-param name="position" select="position()"/>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="href">
                <xsl:call-template name="generate-filename-for">
                    <xsl:with-param name="node" select=".."/>
                    <xsl:with-param name="position" select="position()"/>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="media-type">application/xhtml+xml</xsl:attribute>

            <!-- Check-out for possible media overlays in the sequence of nodes; collect them all. -->
            <xsl:variable name="media-overlays">
                <xsl:for-each select="$nodes">
                    <xsl:if test="f:has-rend-value(., 'media-overlay')">
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
                    <xsl:message terminate="no">ERROR:   Ignoring second media-overlay for single file (id: <xsl:value-of select="$media-overlays[2]"/>).</xsl:message>
            </xsl:if>

        </item>
    </xsl:template>

    <xd:doc>
        <xd:short>Generate an OPF manifest entry for a division.</xd:short>
        <xd:detail>Generate an OPF manifest entry for the file that contains a division. Also handle the case where
        this division refers to a media overlay.</xd:detail>
    </xd:doc>

    <xsl:template name="manifest.div">
        <item xmlns="http://www.idpf.org/2007/opf">
            <xsl:variable name="id"><xsl:call-template name="generate-id"/></xsl:variable>
            <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
            <xsl:attribute name="href"><xsl:call-template name="generate-filename"/></xsl:attribute>
            <xsl:attribute name="media-type">application/xhtml+xml</xsl:attribute>

            <xsl:if test="f:has-rend-value(., 'media-overlay')">
                <xsl:attribute name="media-overlay"><xsl:value-of select="$id"/>overlay</xsl:attribute>
            </xsl:if>
        </item>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate a spine entry for a div-fragment.</xd:short>
        <xd:detail>Generate a spine entry for a div-fragment.</xd:detail>
    </xd:doc>

    <xsl:template name="spine.div-fragment">
        <xsl:param name="nodes"/>

        <itemref xmlns="http://www.idpf.org/2007/opf" linear="yes">
            <xsl:attribute name="idref">
                <xsl:call-template name="generate-id-for">
                    <xsl:with-param name="node" select=".."/>
                    <xsl:with-param name="position" select="position()"/>
                </xsl:call-template>
            </xsl:attribute>
        </itemref>
    </xsl:template>

    <xd:doc>
        <xd:short>Generate a spine entry for a division.</xd:short>
        <xd:detail>Generate a spine entry for a division.</xd:detail>
    </xd:doc>

    <xsl:template name="spine.div">
        <!-- filter out the cover, as we have placed it first already -->
        <xsl:if test="@id != 'cover'">
            <itemref xmlns="http://www.idpf.org/2007/opf" linear="yes">
                <xsl:attribute name="idref"><xsl:call-template name="generate-id"/></xsl:attribute>
            </itemref>
        </xsl:if>
    </xsl:template>


    <!-- content -->

    <xsl:template name="content.div-fragment">
        <xsl:param name="nodes"/>

        <xsl:variable name="filename">
            <xsl:call-template name="generate-filename-for">
                <xsl:with-param name="node" select=".."/>
                <xsl:with-param name="position" select="position()"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:result-document href="{$path}/{$filename}">
            <xsl:message terminate="no">INFO:    generated file: <xsl:value-of select="$path"/>/<xsl:value-of select="$filename"/>.</xsl:message>
            <html>
                <xsl:call-template name="generate-html-header"/>
                <body>
                    <div>
                        <xsl:call-template name="set-class-attribute-for-body"/>
                        <xsl:choose>
                            <xsl:when test="(parent::div0 or parent::div1 or parent::div) and position() = 1">
                                <div class="{name(..)}">
                                    <xsl:call-template name="generate-id-attribute-for">
                                        <xsl:with-param name="node" select=".."/>
                                    </xsl:call-template>
                                    <xsl:call-template name="generate-label">
                                        <xsl:with-param name="div" select=".."/>
                                    </xsl:call-template>
                                    <xsl:apply-templates select="$nodes"/>

                                    <xsl:if test="parent::div0">
                                        <xsl:call-template name="insert-footnotes">
                                            <xsl:with-param name="notes" select="$nodes//note[@place='foot' or @place='unspecified' or not(@place)]"/>
                                        </xsl:call-template>
                                    </xsl:if>
                                </div>
                            </xsl:when>
                            <xsl:when test="(parent::div1 or parent::div) and position() = last()">
                                <xsl:apply-templates select="$nodes"/>
                                <xsl:call-template name="insert-footnotes">
                                    <xsl:with-param name="div" select=".."/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="$nodes"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </body>
            </html>
        </xsl:result-document>

    </xsl:template>


    <xsl:template name="content.div">

        <xsl:variable name="filename"><xsl:call-template name="generate-filename"/></xsl:variable>

        <xsl:result-document href="{$path}/{$filename}">
            <xsl:message terminate="no">INFO:    generated file: <xsl:value-of select="$path"/>/<xsl:value-of select="$filename"/>.</xsl:message>
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


    <!-- Support functions -->

    <xsl:template name="generate-filename">
        <xsl:param name="extension" select="'xhtml'" as="xs:string"/>

        <xsl:choose>
            <xsl:when test="@id='cover'">
                <xsl:value-of select="'cover.xhtml'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$basename"/>
                <xsl:text>-</xsl:text>
                <xsl:call-template name="generate-id"/>
                <xsl:text>.</xsl:text>
                <xsl:value-of select="$extension"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="generate-filename-for">
        <xsl:param name="node" as="element()"/>
        <xsl:param name="extension" select="'xhtml'" as="xs:string"/>
        <xsl:param name="position"/>
        <xsl:choose>
            <xsl:when test="$node/@id='cover'">
                <xsl:value-of select="'cover.xhtml'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$basename"/>
                <xsl:text>-</xsl:text>
                <xsl:call-template name="generate-id-for">
                    <xsl:with-param name="node" select="$node"/>
                </xsl:call-template>
                <xsl:if test="$position">
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="$position"/>
                </xsl:if>
                <xsl:text>.</xsl:text>
                <xsl:value-of select="$extension"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="splitter-generate-filename-for">
        <xsl:param name="node" select="." as="element()"/>

        <xsl:apply-templates select="root($node)/TEI.2/text" mode="splitter">
            <xsl:with-param name="node" select="$node"/>
            <xsl:with-param name="action" select="'filename'"/>
        </xsl:apply-templates>
    </xsl:template>


    <xsl:template name="splitter-generate-url-for">
        <xsl:param name="node" select="." as="element()"/>

        <xsl:call-template name="splitter-generate-filename-for">
            <xsl:with-param name="node" select="$node"/>
        </xsl:call-template>
        <xsl:text>#</xsl:text>
        <xsl:call-template name="splitter-generate-id">
            <xsl:with-param name="node" select="$node"/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="splitter-generate-id">
        <xsl:param name="node" select="." as="element()"/>

        <xsl:choose>
            <xsl:when test="$node/@id">
                <xsl:value-of select="$node/@id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>x</xsl:text>
                <xsl:value-of select="generate-id($node)"/>
                <xsl:message terminate="no">WARNING: generated ID [x<xsl:value-of select="generate-id($node)"/>] is not stable between runs of XSLT.</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- Determine the class for the body, based on whether it is part of the front matter, body text or back matter of the book -->
    <xsl:template name="set-class-attribute-for-body">
        <xsl:attribute name="class">
            <xsl:choose>
                <xsl:when test="ancestor::front">front</xsl:when>
                <xsl:when test="ancestor::back">back</xsl:when>
                <xsl:otherwise>body</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>


</xsl:stylesheet>
