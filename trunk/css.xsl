<!DOCTYPE xsl:stylesheet>
<!--

    Stylesheet to generate css, to be imported in tei2html.xsl.
    Note that the templates for css mode are mostly integrated
    with the content templates, to keep these together with
    the layout code.

    Requires:
        localization.xsl    : templates for localizing strings.

-->

<xsl:stylesheet
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    exclude-result-prefixes="xd"
    version="2.0"
    >

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to generate a CSS stylesheet to accompany HTML or ePub output.</xd:short>
        <xd:detail>This stylesheet formats generates a CSS stylesheet from TEI. According to the requirements
        of ePub, <code>@style</code> attributes are not allowed in the generated XHTML, so all CSS
        rules are collected from the TEI file, and put together in a separate CSS file. Further templates in
        the <code>css</code> mode are integrated in the other stylesheets, to keep them together with
        related HTML generating templates.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2011, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xsl:key name="rend" match="*" use="concat(name(), ':', @rend)"/>


    <xd:doc>
        <xd:short>Translate the <code>@rend</code> attributes to CSS.</xd:short>
        <xd:detail>Translate the <code>@rend</code> attributes, specified in a rendition-ladder syntax, to CSS.</xd:detail>
        <xd:param name="rend">The <code>@rend</code> attribute to be translated.</xd:param>
        <xd:param name="name">The name of the element carrying this attribute.</xd:param>
    </xd:doc>

    <xsl:template name="translate-rend-attribute">
        <xsl:param name="rend" select="normalize-space(@rend)"/>
        <xsl:param name="name" select="name()"/>

        <!-- A rendition ladder is straighfowardly converted to CSS, by taking the
             characters before the "(" as the css property, and the characters
             between "(" and ")" as the value. We convert an entire string
             by simply doing the head, and then recursively the tail -->

        <xsl:if test="$rend != ''">
            <xsl:call-template name="filter-css-property">
                <xsl:with-param name="property" select="substring-before($rend, '(')"/>
                <xsl:with-param name="value" select="substring-before(substring-after($rend, '('), ')')"/>
            </xsl:call-template>

            <xsl:call-template name="translate-rend-attribute">
                <xsl:with-param name="rend" select="normalize-space(substring-after($rend, ')'))"/>
                <xsl:with-param name="name" select="$name"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Filter CSS properties with special meanings.</xd:short>
        <xd:detail>Filter those CSS properties with a special meaning, so they will not
        be output to CSS.</xd:detail>
        <xd:param name="property">The name of the property to be filtered.</xd:param>
        <xd:param name="value">The value of this property.</xd:param>
    </xd:doc>

    <xsl:template name="filter-css-property">
        <xsl:param name="property"/>
        <xsl:param name="value"/>

        <xsl:choose>
            <!-- Drop properties without values -->
            <xsl:when test="normalize-space($value)=''"/>

            <!-- Properties handled otherwise -->
            <xsl:when test="$property='class'"/>        <!-- pass-through CSS class -->
            <xsl:when test="$property='cover-image'"/>  <!-- cover-image for ePub versions -->
            <xsl:when test="$property='media-overlay'"/> <!-- media overlay for ePub versions -->
            <xsl:when test="$property='link'"/>         <!-- external link (for example on image) -->
            <xsl:when test="$property='image'"/>        <!-- in-line image -->
            <xsl:when test="$property='image-alt'"/>    <!-- alt text for image -->
            <xsl:when test="$property='summary'"/>      <!-- summary text for table, etc. -->
            <xsl:when test="$property='title'"/>        <!-- title text for links, etc. -->
            <xsl:when test="$property='label'"/>        <!-- label (for head, etc.) -->
            <xsl:when test="$property='columns'"/>      <!-- number of columns to use on list, table, etc. -->
            <xsl:when test="$property='stylesheet'"/>   <!-- stylesheet to load (only on top-level text element) -->
            <xsl:when test="$property='position'"/>     <!-- position in text -->
            <xsl:when test="$property='toc-head'"/>     <!-- head to be used in table of contents -->
            <xsl:when test="$property='toc'"/>          <!-- indicates how to include a head in the toc -->
            <xsl:when test="$property='align-with'"/>   <!-- indicates to align one division with another in a table -->
            <xsl:when test="$property='align-with-document'"/>   <!-- indicates to align one division with another in a table -->
            <xsl:when test="$property='tocMaxLevel'"/>  <!-- the maximum level (depth) of a generated table of contents -->
            <xsl:when test="$property='display' and $value='image-only'"/>  <!-- show image iso head -->

            <!-- Properties used to render verse -->
            <xsl:when test="$property='hemistich'"/>    <!-- render text given in value invisible (i.e. white) to indent with width of previous line -->

            <!-- Properties related to decorative initials -->
            <xsl:when test="$property='initial-image'"/>
            <xsl:when test="$property='initial-offset'"/>
            <xsl:when test="$property='initial-width'"/>
            <xsl:when test="$property='initial-height'"/>
            <xsl:when test="$property='dropcap'"/>
            <xsl:when test="$property='dropcap-offset'"/>

            <!-- Figure related special handling. -->
            <xsl:when test="name() = 'figure' and $property = 'float'"/>

            <!-- Table related special handling. With the rule
                 margin: 0px auto, the table is centered, while
                 display: table shrinks the bounding box to the content -->
            <xsl:when test="name() = 'table' and $property = 'align' and $value = 'center'">margin:0px auto; display:table;</xsl:when>
            <xsl:when test="name() = 'table' and $property = 'indent'">margin-left:<xsl:value-of select="$value"/>em;</xsl:when>

            <!-- Properties related to special font usage -->
            <xsl:when test="$property='font' and $value='fraktur'">font-family:'Walbaum-Fraktur';</xsl:when>
            <xsl:when test="$property='font' and $value='italic'">font-style:italic;</xsl:when>

            <xsl:when test="$property='align'">text-align:<xsl:value-of select="$value"/>;</xsl:when>
            <xsl:when test="$property='valign'">vertical-align:<xsl:value-of select="$value"/>;</xsl:when>
            <xsl:when test="$property='indent'">text-indent:<xsl:value-of select="$value"/>em;</xsl:when>

            <!-- Assume the rest is valid CSS -->
            <xsl:otherwise>
                <xsl:value-of select="$property"/>:<xsl:value-of select="$value"/>;
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xd:doc>
        <xd:short>Generate a CSS class name.</xd:short>
        <xd:detail>Generate a CSS class name. This class name is derived from the
        generated id of the first element having this <code>@rend</code> attribute value.</xd:detail>
        <xd:param name="rend">The <code>@rend</code> attribute for which a class name is generated.</xd:param>
        <xd:param name="node">The node carrying this attribute.</xd:param>
    </xd:doc>

    <xsl:template name="generate-rend-class-name">
        <xsl:param name="rend" select="@rend"/>
        <xsl:param name="node" select="."/>

        <xsl:text>x</xsl:text><xsl:value-of select="generate-id(key('rend', concat(name($node), ':', $rend))[1])"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate a CSS class attribute.</xd:short>
        <xd:detail>The same as above, but now wrapped up in an attribute</xd:detail>
        <xd:param name="rend">The <code>@rend</code> attribute for which a class name is generated.</xd:param>
        <xd:param name="node">The node carrying this attribute.</xd:param>
    </xd:doc>

    <xsl:template name="generate-rend-class-attribute">
        <xsl:param name="rend" select="@rend"/>
        <xsl:param name="node" select="."/>

        <xsl:attribute name="class">
            <xsl:call-template name="generate-rend-class-name">
                <xsl:with-param name="rend" select="$rend"/>
                <xsl:with-param name="node" select="$node"/>
            </xsl:call-template>
        </xsl:attribute>
    </xsl:template>


    <xd:doc>
        <xd:short>Optionally generate a CSS class name.</xd:short>
        <xd:detail>As before, but we only need to insert a class name in the output, if
         there is a matching CSS rule, or an explicit class
         declaration in the <code>@rend</code> attribute.</xd:detail>
        <xd:param name="rend">The <code>@rend</code> attribute for which a class name is generated.</xd:param>
        <xd:param name="node">The node carrying this attribute.</xd:param>
    </xd:doc>

    <xsl:template name="generate-rend-class-name-if-needed">
        <xsl:param name="rend" select="@rend"/>
        <xsl:param name="node" select="."/>

        <xsl:if test="contains($rend, 'class(')"><xsl:value-of select="substring-before(substring-after($rend, 'class('), ')')"/><xsl:text> </xsl:text></xsl:if>

        <xsl:variable name="css-properties">
            <xsl:call-template name="translate-rend-attribute">
                <xsl:with-param name="rend" select="normalize-space($rend)"/>
                <xsl:with-param name="name" select="name($node)"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:if test="normalize-space($css-properties) != ''">
            <xsl:call-template name="generate-rend-class-name">
                <xsl:with-param name="rend" select="$rend"/>
                <xsl:with-param name="node" select="$node"/>
            </xsl:call-template>
        </xsl:if>

    </xsl:template>


    <xd:doc>
        <xd:short>Optionally generate a CSS class attribute.</xd:short>
        <xd:detail>The same as above, but now wrapped up in an attribute</xd:detail>
        <xd:param name="rend">The <code>@rend</code> attribute for which a class name is generated.</xd:param>
        <xd:param name="node">The node carrying this attribute.</xd:param>
    </xd:doc>

    <xsl:template name="generate-rend-class-attribute-if-needed">
        <xsl:param name="rend" select="@rend"/>
        <xsl:param name="node" select="."/>

        <xsl:variable name="class">
            <xsl:call-template name="generate-rend-class-name-if-needed">
                <xsl:with-param name="rend" select="$rend"/>
                <xsl:with-param name="node" select="$node"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:if test="normalize-space($class) != ''">
            <xsl:attribute name="class"><xsl:value-of select="normalize-space($class)"/></xsl:attribute>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Top level rule to generate CSS from <code>@rend</code> attributes.</xd:short>
        <xd:detail>The top level rule starts generating CSS rules for column-level rendering first,
        as those might be overridden by following row-level and cell-level rendering in tables.</xd:detail>
    </xd:doc>

    <xsl:template match="/" mode="css">

        <!-- We need to collect the column-related rendering rules first,
             so they can be overridden by later cell rendering rules -->
        <xsl:apply-templates select="TEI.2/text//column[@rend]" mode="css-column"/>

        <!-- Then follow the row-related rendering rules -->
        <xsl:apply-templates select="TEI.2/text//row[@rend]" mode="css-row"/>

        <!-- Handle the rest of the document -->
        <xsl:apply-templates select="/TEI.2/facsimile" mode="css"/>
        <xsl:apply-templates select="/TEI.2/text" mode="css"/>
    </xsl:template>


    <!-- Special modes for column and row CSS -->
    <xsl:template match="column[@rend]" mode="css-column">
        <xsl:call-template name="generate-css-rule"/>
    </xsl:template>

    <xsl:template match="row[@rend]" mode="css-row">
        <xsl:call-template name="generate-css-rule"/>
    </xsl:template>


    <!-- Exclude the column and row elements from default processing -->
    <xsl:template match="column | row" mode="css">
        <xsl:apply-templates mode="css"/>
    </xsl:template>


    <!-- Low priority default rule for generating the css rules from the
         rend attribute in css mode. Note how we exclude the column element here -->
    <xsl:template match="*[@rend]" mode="css" priority="-1">
        <xsl:call-template name="generate-css-rule"/>
        <xsl:apply-templates mode="css"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate a CSS rule.</xd:short>
        <xd:detail>Generate a CSS rule from a <code>@rend</code> attribute. Using a key on <code>name():@rend</code>, we
        do so only for the first occurance of a <code>@rend</code> attribute on an element.</xd:detail>
    </xd:doc>

    <xsl:template name="generate-css-rule">
        <xsl:if test="generate-id() = generate-id(key('rend', concat(name(), ':', @rend))[1])">

            <xsl:variable name="css-properties">
                <xsl:call-template name="translate-rend-attribute">
                    <xsl:with-param name="rend" select="normalize-space(@rend)"/>
                    <xsl:with-param name="name" select="name()"/>
                </xsl:call-template>
            </xsl:variable>

            <xsl:if test="normalize-space($css-properties) != ''">
                <!-- Use the id of the first element with this rend attribute as a class selector -->
                <xsl:text>
.</xsl:text>
                <xsl:call-template name="generate-rend-class-name"/>
                <xsl:text>
{
</xsl:text>
                    <xsl:value-of select="normalize-space($css-properties)"/>
                    <xsl:if test="false()">/* node='<xsl:value-of select="name()"/>' rend='<xsl:value-of select="normalize-space(@rend)"/>' count='<xsl:value-of select="count(key('rend', concat(name(), ':', @rend)))"/>' */</xsl:if>
                <xsl:text>
}
</xsl:text>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <!-- Ignore content in css-mode -->
    <xsl:template match="text()" mode="css"/>


</xsl:stylesheet>
