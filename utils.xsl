<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet with various utily templates, to be imported in tei2html.xsl.

    Requires:
        localization.xsl    : templates for localizing strings.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="urn:stylesheet-functions"
    exclude-result-prefixes="f xs"
    version="2.0"
    >


    <!-- ID Generation

    Use original ID's when possible to keep ID's stable between versions.
    We use generated ID's prepended with 'x' to avoid clashes with original
    ID's. Note that the target id generated here should also be generated
    on the element being referenced. We cannot use the id() function here,
    since we do not use a DTD.

    -->

    <xsl:template name="generate-anchor">
        <a>
            <xsl:call-template name="generate-id-attribute"/>
        </a>
    </xsl:template>

    <xsl:template name="generate-id-attribute">
        <xsl:attribute name="id">
            <xsl:call-template name="generate-id"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="generate-id-attribute-for">
        <xsl:param name="node" select="." as="element()"/>
        <xsl:attribute name="id">
            <xsl:call-template name="generate-id-for">
                <xsl:with-param name="node" select="$node"/>
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="generate-id">
        <xsl:call-template name="generate-id-for">
            <xsl:with-param name="node" select="."/>
        </xsl:call-template>
    </xsl:template>

    <!--
        We want to generate ids that are slightly more stable than using generate-id().
        The general idea is to use an explicit id if that is present, and otherwise create
        an id based on the path to the first ancestor node that does have an id. If,
        for example the third paragraph of a division with id 'ch2' has no id of itself,
        we generate: "ch2_p_3" as an id. The second note in this paragraph would receive
        the id "ch2_p_3_note_2".

        Safe ID syntax:
            HTML:       [A-Za-z][A-Za-z0-9_:.-]*
            CSS:        -?[_a-zA-Z]+[_a-zA-Z0-9-]*
            Combined:   [A-Za-z][A-Za-z0-9_-]*
    -->

    <xsl:template name="generate-stable-id-for">
        <xsl:param name="node" select="."/>

        <xsl:variable name="node-name" select="name($node)"/>
        <xsl:choose>

            <!-- We have an explicit id, use that -->
            <xsl:when test="$node/@id">
                <xsl:message terminate="no">! <xsl:value-of select="$node-name"/> #<xsl:value-of select="$node/@id"/></xsl:message>
                <!-- Verify the id is valid for use in HTML and CSS -->
                <xsl:if test="not(matches($node/@id,'^[A-Za-z][A-Za-z0-9_-]*$'))">
                    <xsl:message terminate="no">Warning: source contains id [<xsl:value-of select="$node/@id"/>] that may cause problems in CSS.</xsl:message>
                </xsl:if>
                <xsl:value-of select="$node/@id"/>
            </xsl:when>

            <!-- We have reached the root without finding an explicit id -->
            <xsl:when test="not($node/..)">
                <xsl:message terminate="no">ROOT</xsl:message>
                <xsl:text>root</xsl:text>
            </xsl:when>

            <!-- We have no explicit id: get the stable id of our parent and append ".<node-name>.<count>" -->
            <xsl:otherwise>
                <xsl:call-template name="generate-stable-id-for">
                    <xsl:with-param name="node" select="$node/.."/>
                </xsl:call-template>
                <xsl:text>_</xsl:text><xsl:value-of select="$node-name"/>
                <!-- TODO: fix following to count correctly in recursive calls. -->
                <xsl:variable name="position" select="count($node/preceding-sibling::*[name(current()) = $node-name])"/>
                <xsl:if test="$position > 0">
                    <xsl:text>_</xsl:text><xsl:value-of select="$position"/>
                </xsl:if>

                <xsl:message terminate="no">- <xsl:value-of select="$node-name"/> [<xsl:value-of select="$position"/>]</xsl:message>

            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="generate-id-for">
        <xsl:param name="node" select="." as="element()"/>
        <xsl:param name="position"/>
        <!--
        <xsl:call-template name="generate-stable-id-for">
            <xsl:with-param name="node" select="$node" />
        </xsl:call-template>
        -->
        <xsl:choose>
            <xsl:when test="$node/@id">
                <!-- Verify the id is valid for use in HTML and CSS -->
                <xsl:if test="not(matches($node/@id,'^[A-Za-z][A-Za-z0-9_-]*$'))">
                    <xsl:message terminate="no">Warning: source contains id [<xsl:value-of select="$node/@id"/>] that may cause problems in CSS.</xsl:message>
                </xsl:if>
                <xsl:value-of select="$node/@id"/>
            </xsl:when>
            <xsl:otherwise>x<xsl:value-of select="generate-id($node)"/></xsl:otherwise>
        </xsl:choose>

        <xsl:if test="$position">-<xsl:value-of select="$position"/></xsl:if>
    </xsl:template>

    <xsl:template name="generate-href-attribute">
        <xsl:param name="target" select="." as="element()"/>

        <xsl:attribute name="href">
            <xsl:call-template name="generate-href">
                <xsl:with-param name="target" select="$target"/>
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="generate-footnote-href-attribute">
        <xsl:param name="target" select="."/>

        <xsl:attribute name="href">
            <xsl:call-template name="generate-footnote-href">
                <xsl:with-param name="target" select="$target"/>
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>


    <!--====================================================================-->
    <!-- Close and Open paragraphs

    To accomodate the differences between the TEI and HTML paragraph model,
    we sometimes need to close (and reopen) paragraphs, as various elements
    are not allowed inside p elements in HTML.

    -->

    <xsl:template name="closepar">
        <!-- insert </p> to close current paragraph as tables in paragraphs are illegal in HTML -->
        <xsl:if test="parent::p or parent::note">
            <xsl:text disable-output-escaping="yes">&lt;/p&gt;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template name="reopenpar">
        <xsl:if test="parent::p or parent::note">
            <xsl:text disable-output-escaping="yes">&lt;p&gt;</xsl:text>
        </xsl:if>
    </xsl:template>

    <!--====================================================================-->
    <!-- Language tagging -->

    <xsl:template name="set-lang-attribute">
        <xsl:if test="@lang">
            <xsl:choose>
                <xsl:when test="$outputmethod = 'xml'">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="@lang"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="lang"><xsl:value-of select="@lang"/></xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <!--====================================================================-->
    <!-- Shortcut for both id and language tagging -->

    <xsl:template name="set-lang-id-attributes">
        <xsl:call-template name="generate-id-attribute"/>
        <xsl:call-template name="set-lang-attribute"/>
    </xsl:template>

    <!--====================================================================-->
    <!-- Generate labels for heads in the correct language -->

    <xsl:function name="f:translate-div-type" as="xs:string">
        <xsl:param name="type"/>
        <xsl:variable name="type" select="lower-case($type)"/>

        <xsl:choose>
            <xsl:when test="$type=''"><xsl:value-of select="''"/></xsl:when>
            <xsl:when test="$type='appendix'"><xsl:value-of select="f:message('msgAppendix')"/></xsl:when>
            <xsl:when test="$type='chapter'"><xsl:value-of select="f:message('msgChapter')"/></xsl:when>
            <xsl:when test="$type='part'"><xsl:value-of select="f:message('msgPart')"/></xsl:when>
            <xsl:when test="$type='book'"><xsl:value-of select="f:message('msgBook')"/></xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no">Warning: division's type attribute [<xsl:value-of select="$type"/>] not handled correctly in translate-div-type.</xsl:message>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
