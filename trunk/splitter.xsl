<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to split the result document into pieces, to be included
    into tei2html.xsl.

    We need to split a TEI document into pieces, and in addition, also
    need to be able to consistently generate various types of lists
    of generated files, and cross-references both internal to a part
    and to other parts.

    To accomplish this, we use the "splitter" mode to obtain the parts,
    and hand through an "action" parameter to select the appropriate
    action once we land in the part to be handled. Once arrived at the
    level we wish to split at, we call the appropriate template to
    handle the content.

    The following actions are supported:

    [empty]     Generate the (named) files with the content.

    filename    Generate the name of the file that contains the
                (transformed) element represented in $node.

    manifest    Generate a manifest (ODF) for ePub.

    spine       Generate the spine (ODF) for ePub.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0"
    exclude-result-prefixes="xs"
    >


    <xsl:template match="/TEI.2/text" priority="2">
        <xsl:apply-templates mode="splitter"/>
    </xsl:template>


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


    <xsl:template match="body[div0]" mode="splitter">
        <xsl:param name="action" select="''" as="xs:string"/>
        <xsl:param name="node"/>

        <xsl:apply-templates select="div0" mode="splitter">
            <xsl:with-param name="action" select="$action"/>
            <xsl:with-param name="node" select="$node"/>
        </xsl:apply-templates>
    </xsl:template>


    <xsl:template match="div0 | front | back | body[div1]" mode="splitter">
        <xsl:param name="action" select="''" as="xs:string"/>
        <xsl:param name="node"/>

        <xsl:for-each-group select="node()" group-adjacent="not(self::div1)">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <!-- Sequence of non-div1 elements -->
                    <xsl:call-template name="div0fragment">
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


    <xsl:template name="div0fragment">
        <xsl:param name="action" select="''" as="xs:string"/>
        <xsl:param name="node"/>
        <xsl:param name="nodes"/>

        <xsl:choose>
            <xsl:when test="$action = 'filename'">
                <xsl:call-template name="filename.div0fragment">
                    <xsl:with-param name="node" select="$node"/>
                    <xsl:with-param name="nodes" select="$nodes"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$action = 'manifest'">
                <xsl:call-template name="manifest.div0fragment">
                    <xsl:with-param name="nodes" select="$nodes"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$action = 'spine'">
                <xsl:call-template name="spine.div0fragment">
                    <xsl:with-param name="nodes" select="$nodes"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="content.div0fragment">
                    <xsl:with-param name="nodes" select="$nodes"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xsl:template match="div1" mode="splitter">
        <xsl:param name="action" select="''" as="xs:string"/>
        <xsl:param name="node"/>

        <xsl:choose>
            <xsl:when test="processing-instruction(epubsplit)">

                <xsl:for-each-group select="node()" group-adjacent="not(self::processing-instruction(epubsplit))">
                    <xsl:choose>
                        <xsl:when test="current-grouping-key()">
                            <!-- Sequence of non-div1 elements -->
                            <xsl:call-template name="div0fragment">
                                <xsl:with-param name="action" select="$action"/>
                                <xsl:with-param name="node" select="$node"/>
                                <xsl:with-param name="nodes" select="current-group()"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each-group>

            </xsl:when>
            <xsl:otherwise>

                <xsl:choose>
                    <xsl:when test="$action = 'filename'">
                        <xsl:call-template name="filename.div1">
                            <xsl:with-param name="node" select="$node"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$action = 'manifest'">
                        <xsl:call-template name="manifest.div1"/>
                    </xsl:when>
                    <xsl:when test="$action = 'spine'">
                        <xsl:call-template name="spine.div1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="content.div1"/>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>



    <!-- filename -->

    <xsl:template name="filename.div0fragment">
        <xsl:param name="node" as="element()"/>
        <xsl:param name="nodes"/>

        <xsl:param name="position" select="position()"/> <!-- that is, position of context group -->

        <!-- Does any of the nodes contains the node sought after? -->
        <xsl:for-each select="$nodes">
            <!--<xsl:message terminate="no">Info: locating node in: <xsl:value-of select="name()"/>[<xsl:value-of select="$position"/>]. Count: <xsl:value-of select="count(.)"/>/<xsl:value-of select="count($node)"/>.</xsl:message>
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

    <xsl:template name="filename.div1">
        <xsl:param name="node" as="element()"/>

        <!-- Does this div1 contain the node sought after? -->
        <xsl:if test="descendant-or-self::*[generate-id() = generate-id($node)]">
            <xsl:call-template name="generate-filename"/>
        </xsl:if>
    </xsl:template>


    <!-- manifest -->

    <xsl:template name="manifest.div0fragment">
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
        </item>
    </xsl:template>

    <xsl:template name="manifest.div1">
        <item xmlns="http://www.idpf.org/2007/opf">
            <xsl:variable name="id"><xsl:call-template name="generate-id"/></xsl:variable>
            <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
            <xsl:attribute name="href"><xsl:call-template name="generate-filename"/></xsl:attribute>
            <xsl:attribute name="media-type">application/xhtml+xml</xsl:attribute>
        </item>
    </xsl:template>


    <!-- spine -->

    <xsl:template name="spine.div0fragment">
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

    <xsl:template name="spine.div1">
        <!-- filter out the cover, as we have placed it first already -->
        <xsl:if test="@id != 'cover'">
            <itemref xmlns="http://www.idpf.org/2007/opf" linear="yes">
                <xsl:attribute name="idref"><xsl:call-template name="generate-id"/></xsl:attribute>
            </itemref>
        </xsl:if>
    </xsl:template>


    <!-- content -->

    <xsl:template name="content.div0fragment">
        <xsl:param name="nodes"/>

        <xsl:variable name="filename">
            <xsl:call-template name="generate-filename-for">
                <xsl:with-param name="node" select=".."/>
                <xsl:with-param name="position" select="position()"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:result-document href="{$path}/{$filename}">
            <xsl:message terminate="no">Info: generated file: <xsl:value-of select="$path"/>/<xsl:value-of select="$filename"/>.</xsl:message>
            <html>
                <xsl:call-template name="generate-html-header"/>

                <body>
                    <div>
                        <xsl:call-template name="set-class-attribute-for-body"/>
                        <xsl:choose>
                            <xsl:when test="(parent::div0 or parent::div1) and position() = 1">
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
                            <xsl:when test="parent::div1 and position() = last()">
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


    <xsl:template name="content.div1">

        <xsl:variable name="filename"><xsl:call-template name="generate-filename"/></xsl:variable>

        <xsl:result-document href="{$path}/{$filename}">
            <xsl:message terminate="no">Info: generated file: <xsl:value-of select="$path"/>/<xsl:value-of select="$filename"/>.</xsl:message>
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
        <xsl:value-of select="$basename"/>-<xsl:call-template name="generate-id"/>.<xsl:value-of select="$extension"/>
    </xsl:template>

    <xsl:template name="generate-filename-for">
        <xsl:param name="node" as="element()"/>
        <xsl:param name="extension" select="'xhtml'" as="xs:string"/>
        <xsl:param name="position"/>
        <xsl:value-of select="$basename"/>-<xsl:call-template name="generate-id-for"><xsl:with-param name="node" select="$node"/></xsl:call-template><xsl:if test="$position">-<xsl:value-of select="$position"/></xsl:if>.<xsl:value-of select="$extension"/>
    </xsl:template>


    <xsl:template name="splitter-generate-filename-for">
        <xsl:param name="node" select="." as="element()"/>

        <xsl:apply-templates select="/TEI.2/text" mode="splitter">
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
                <xsl:message terminate="no">Warning: generated ID [x<xsl:value-of select="generate-id($node)"/>] is not stable between runs of XSLT.</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- Determine the class for the body, based on wether it is part of the front matter, body text or back matter of the book -->
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
