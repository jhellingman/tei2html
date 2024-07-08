<!DOCTYPE xsl:stylesheet [

    <!ENTITY nbsp       "&#160;">

]>

<xsl:stylesheet version="3.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:f="urn:stylesheet-functions"
                xmlns:img="http://www.gutenberg.ph/2006/schemas/imageinfo"
                xmlns:xd="http://www.pnp-software.com/XSLTdoc"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="f img xd xs">

    <xd:doc type="stylesheet">
        <xd:short>TEI stylesheet to handle figures.</xd:short>
        <xd:detail>This stylesheet handles TEI figure elements; part of tei2html.xsl.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2016, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc type="string">
        The imageInfoFile is an XML file that contains information on the dimensions of images.
        An external tool generates this file, and the name of this file will be provided
        to the XSLT processor as a parameter.
    </xd:doc>

    <xsl:param name="imageInfoFile" as="xs:string?"/>

    <xsl:variable name="imageInfo" select="document(f:normalize-filename($imageInfoFile))" as="node()?"/>

    <xd:doc>
        <xd:short>Determine the file name for an image.</xd:short>
        <xd:detail>
            <p>Derive a file name from the <code>@id</code> attribute, and assume that the extension
            is <code>.jpg</code>, unless the <code>@rend</code> attribute provides alternative name with
            the rendition-ladder notation <code>image()</code>.</p>
        </xd:detail>
        <xd:param name="node" type="node()">The figure or graphic element for which the file name needs to be determined.</xd:param>
        <xd:param name="format" type="string">The default file-extension of the image file.</xd:param>
    </xd:doc>

    <xsl:function name="f:determine-image-filename" as="xs:string">
        <xsl:param name="node" as="element()"/>
        <xsl:param name="format" as="xs:string"/>

        <xsl:if test="$node/@url">
            <xsl:copy-of select="f:log-warning('Using non-standard attribute url {1} on {2}.', ($node/@url, local-name($node)))"/>
        </xsl:if>

        <xsl:sequence select="
            if (f:has-rend-value($node/@rend, 'image'))
            then f:rend-value($node/@rend, 'image')
            else if ($node/@url)
                 then $node/@url
                 else if ($node/@target)
                      then $node/@target
                      else if ($node/@id)
                           then 'images/' || $node/@id || $format
                           else ''"/>
    </xsl:function>


    <xsl:function name="f:determine-image-filename" as="xs:string">
        <xsl:param name="node" as="element()"/>
        <xsl:sequence select="f:determine-image-filename($node, if (f:is-inline($node)) then '.png' else '.jpg')"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine the alternate text for an image.</xd:short>
        <xd:param name="node" type="node()">The figure or graphic element for which the alternate text needs to be determined.</xd:param>
        <xd:param name="default" type="string">The default alternate text.</xd:param>
    </xd:doc>

    <xsl:function name="f:determine-image-alt-text" as="xs:string">
        <xsl:param name="node" as="element()"/>
        <xsl:param name="default" as="xs:string"/>

        <xsl:sequence select="
            if (f:has-rend-value($node/@rend, 'image-alt'))
            then f:rend-value($node/@rend, 'image-alt')
            else if ($node/figDesc)
                 then $node/figDesc[1]
                 else if ($node/head)
                      then $node/head[1]
                      else $default"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Determine whether an image should be included in the output.</xd:short>
        <xd:param name="url" type="string">The URL of the image-file to verify.</xd:param>
    </xd:doc>

    <xsl:function name="f:is-image-included" as="xs:boolean">
        <xsl:param name="url" as="xs:string"/>

        <xsl:variable name="is-image-included" select="f:is-set('images.include') and (f:is-image-present($url) or not(f:is-set('images.requireInfo')))"/>
        <xsl:if test="not($is-image-included)">
            <xsl:copy-of select="f:log-warning('Image {1} will not be included in output file!', ($url))"/>
        </xsl:if>
        <xsl:sequence select="$is-image-included"/>
    </xsl:function>


    <xsl:function name="f:is-image-excluded" as="xs:boolean">
        <xsl:param name="url" as="xs:string"/>
        <xsl:sequence select="not(f:is-image-included($url))"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Verify an image is present in the imageinfo file.</xd:short>
    </xd:doc>

    <xsl:function name="f:is-image-present" as="xs:boolean">
        <xsl:param name="file" as="xs:string"/>

        <xsl:sequence select="boolean($imageInfo/img:images/img:image[@path=$file])"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Warn if an image linked to is not present in the imageinfo file.</xd:short>
    </xd:doc>

    <xsl:function name="f:warn-missing-linked-image">
        <xsl:param name="url" as="xs:string"/>

        <xsl:if test="not(f:is-image-present($url))">
            <xsl:copy-of select="f:log-warning('Linked image {1} not in image-info file {2}.', ($url, normalize-space($imageInfoFile)))"/>
        </xsl:if>
    </xsl:function>


    <xd:doc>
        <xd:short>Insert an image in the output (step 1).</xd:short>
        <xd:detail>
            <p>Insert all the required output for an inline image in HTML.</p>

            <p>This template generates the elements surrounding the actual image tag in the output.</p>
        </xd:detail>
        <xd:param name="alt" type="string">The text to be placed on the HTML alt attribute.</xd:param>
        <xd:param name="defaultformat" type="string">The default file-extension of the image file.</xd:param>
    </xd:doc>


    <xsl:template name="output-image-with-optional-link">
        <xsl:context-item as="element()" use="required"/>
        <xsl:param name="alt" as="xs:string"/>
        <xsl:param name="filename" as="xs:string"/>

        <!-- Should we link to an external image? -->
        <xsl:choose>
            <xsl:when test="f:has-rend-value(@rend, 'link')">
                <xsl:variable name="url" select="f:rend-value(@rend, 'link')"/>
                <xsl:copy-of select="f:warn-missing-linked-image($url)"/>
                <a>
                    <xsl:choose>
                        <xsl:when test="f:is-epub() and matches($url, '^[^:]+\.(jpg|png|gif|svg)$')">
                            <!-- cannot directly link to image file in ePub, so generate wrapper HTML and link to that. -->
                            <xsl:call-template name="generate-image-wrapper">
                                <xsl:with-param name="imagefile" select="$url"/>
                            </xsl:call-template>
                            <xsl:attribute name="href"><xsl:value-of select="$basename"/>-<xsl:value-of select="f:generate-id(.)"/>.xhtml</xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="href"><xsl:value-of select="$url"/></xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:copy-of select="f:output-image(., $filename, $alt)"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="f:output-image(., $filename, $alt)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:function name="f:output-image">
        <xsl:param name="file" as="xs:string"/>
        <xsl:param name="alt" as="xs:string"/>
        <xsl:copy-of select="f:output-image-tag($file, $alt, '', '')"/>
    </xsl:function>


    <xsl:function name="f:output-image">
        <xsl:param name="node" as="element()"/>
        <xsl:param name="file" as="xs:string"/>
        <xsl:param name="alt" as="xs:string"/>

        <xsl:choose>
            <xsl:when test="f:has-rend-value($node/@rend, 'hover-overlay')">
                <div class="{f:generate-id($node) || 'overlay'}">
                    <xsl:copy-of select="f:output-image-tag($file, $alt, $node/@rend, 'img-front')"/>
                    <xsl:copy-of select="f:output-image-tag(f:rend-value($node/@rend, 'hover-overlay'), $alt, '', 'img-back')"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="f:output-image-tag($file, $alt, $node/@rend, '')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate an image tag.</xd:short>
        <xd:detail>
            <p>Generate the actual <code>img</code>-element for the output HTML. This will look up the height and
            width of the image in the imageinfo file, and set the <code>height</code> and <code>width</code> attributes
            if found. If the <code>rend</code> parameter explicitly gives a dimension, this will override the
            value in the imageinfo file. The <code>alt</code> attribute is filled if present.</p>
        </xd:detail>
        <xd:param name="file" type="string">The name of the image file.</xd:param>
        <xd:param name="alt" type="string">The text to be placed on the HTML alt attribute.</xd:param>
        <xd:param name="rend" type="string?">The rendition ladder, as provided on the figure element.</xd:param>
        <xd:param name="class" type="string?">An additional class to set.</xd:param>
    </xd:doc>

    <xsl:function name="f:output-image-tag">
        <xsl:param name="file" as="xs:string"/>
        <xsl:param name="alt" as="xs:string"/>
        <xsl:param name="rend" as="xs:string?"/>
        <xsl:param name="class" as="xs:string?"/>

        <xsl:variable name="width" select="f:rend-value($rend, 'width')"/>
        <xsl:variable name="height" select="f:rend-value($rend, 'height')"/>

        <xsl:variable name="width" select="if ($width) then $width else f:image-width($file)"/>
        <xsl:variable name="height" select="if ($height) then $height else f:image-height($file)"/>

        <xsl:variable name="width" select="substring-before($width, 'px')"/>
        <xsl:variable name="height" select="substring-before($height, 'px')"/>
        <xsl:variable name="fileSize" select="f:image-file-size($file)"/>

        <xsl:variable name="maxWidth" select="f:get-setting('images.maxWidth')"/>
        <xsl:variable name="maxHeight" select="f:get-setting('images.maxHeight')"/>
        <xsl:variable name="maxFileSize" select="f:get-setting('images.maxSize')"/>

        <xsl:if test="$width = ''">
            <xsl:copy-of select="f:log-warning('Image {1} not in image-info file {2}.', ($file, normalize-space($imageInfoFile)))"/>
        </xsl:if>
        <xsl:if test="$width != '' and number($width) > xs:double($maxWidth)">
            <xsl:copy-of select="f:log-warning('Image {1} width more than {3} pixels ({2} px).', ($file, $width, $maxWidth))"/>
        </xsl:if>
        <xsl:if test="$height != '' and number($height) > xs:double($maxHeight)">
            <xsl:copy-of select="f:log-warning('Image {1} height more than {3} pixels ({2} px).', ($file, $height, $maxHeight))"/>
        </xsl:if>
        <xsl:if test="$fileSize != '' and number($fileSize) > xs:double($maxFileSize) * 1024">
            <xsl:copy-of select="f:log-warning('Image {1} file-size larger than {3} kB ({2} kB).', ($file, xs:string(ceiling(number($fileSize) div 1024)), $maxFileSize))"/>
        </xsl:if>
        <xsl:if test="$alt = ''">
            <xsl:copy-of select="f:log-warning('Image {1} has no alt-text defined.', ($file))"/>
        </xsl:if>

        <img src="{$file}">
            <xsl:attribute name="alt"><xsl:value-of select="$alt"/></xsl:attribute>
            <xsl:if test="$class != ''"><xsl:attribute name="class"><xsl:value-of select="$class"/></xsl:attribute></xsl:if>
            <xsl:if test="$width != ''"><xsl:attribute name="width"><xsl:value-of select="$width"/></xsl:attribute></xsl:if>
            <xsl:if test="$height != ''"><xsl:attribute name="height"><xsl:value-of select="$height"/></xsl:attribute></xsl:if>
        </img>
    </xsl:function>


    <xd:doc>
        <xd:short>Generate an image wrapper for ePub.</xd:short>
        <xd:detail>
            <p>Since images may not appear stand-alone in an ePub file, this generates
            an HTML wrapper for (mostly large) images linked to from a smaller image using
            <code>link()</code> in the <code>@rend</code> attribute.</p>
        </xd:detail>
        <xd:param name="imagefile" type="string">The name of the image file (this parameter may be left empty).</xd:param>
    </xd:doc>

    <xsl:template name="generate-image-wrapper">
        <xsl:context-item as="element()" use="required"/>
        <xsl:param name="imagefile" as="xs:string"/>

        <xsl:variable name="filename"><xsl:value-of select="$basename"/>-<xsl:value-of select="f:generate-id(.)"/>.xhtml</xsl:variable>
        <xsl:variable name="alt" select="f:determine-image-alt-text(., '')"/>

        <xsl:result-document href="{$path}/{$filename}">
            <xsl:copy-of select="f:log-info('Generated image wrapper file: {1}/{2}.', ($path, $filename))"/>
            <html>
                <xsl:call-template name="generate-html-header"/>
                <body>
                    <div class="figure">
                        <img src="{$imagefile}" alt="{$alt}"/>
                        <xsl:apply-templates/>
                    </div>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle an in-line image.</xd:short>
        <xd:detail>
            <p>Special handling of figures marked as inline using the rend attribute.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="figure[f:is-inline(.)]">
        <xsl:copy-of select="f:show-debug-tags(.)"/>

        <xsl:variable name="alt" select="f:determine-image-alt-text(., '')" as="xs:string"/>
        <xsl:variable name="filename" select="f:determine-image-filename(.)" as="xs:string"/>

        <xsl:if test="f:is-image-included($filename)">
            <span>
                <xsl:copy-of select="f:set-figure-class(.)"/>
                <xsl:call-template name="output-image-with-optional-link">
                    <xsl:with-param name="filename" select="$filename"/>
                    <xsl:with-param name="alt" select="$alt"/>
                </xsl:call-template>
            </span>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate CSS code related to images.</xd:short>
        <xd:detail>
            <p>In the CSS for each image, we register its length and width, to help HTML rendering.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="figure" mode="css">
        <xsl:variable name="filename" select="f:determine-image-filename(.)" as="xs:string"/>

        <xsl:if test="f:is-image-included($filename)">
            <xsl:call-template name="generate-css-rule"/>
            <xsl:copy-of select="f:output-image-width-css(., $filename)"/>
            <xsl:apply-templates mode="css"/>
        </xsl:if>
    </xsl:template>


    <xsl:template match="figure[f:has-rend-value(./@rend, 'hover-overlay')]" mode="css">
        <xsl:variable name="filename" select="f:determine-image-filename(.)" as="xs:string"/>

        <xsl:variable name="width" select="f:image-width($filename)" as="xs:string?"/>
        <xsl:variable name="height" select="f:image-height($filename)" as="xs:string?"/>
        <xsl:variable name="selector" select="f:escape-css-selector(f:generate-id(.) || 'overlay')"/>

        <xsl:if test="f:is-image-included($filename)"><xsl:text expand-text="yes">
.{$selector} {{
    width: {$width};
    height: {$height};
    position: relative;
    margin-bottom: 4px;
}}
.{$selector} .img-back {{
    display: none;
    position: absolute;
    top: 0;
    left: 0;
    z-index: 99;
}}
.{$selector}:hover .img-back {{
    display: inline;
}}
.{$selector}:hover .img-front {{
    display: none;
}}
</xsl:text></xsl:if>
        <xsl:next-match/>
    </xsl:template>


    <xsl:template match="figure[f:is-inline(.)]" mode="css">
        <xsl:variable name="filename" select="f:determine-image-filename(.)" as="xs:string"/>

        <xsl:if test="f:is-image-included($filename)">
            <xsl:call-template name="generate-css-rule"/>
            <xsl:copy-of select="f:output-image-width-css(., $filename)"/>
            <xsl:apply-templates mode="css"/>
        </xsl:if>
    </xsl:template>


    <xsl:function name="f:output-image-width-css">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="file" as="xs:string"/>
        <xsl:variable name="width" select="f:image-width($file)" as="xs:string?"/>
        <xsl:variable name="selector" select="f:escape-css-selector(f:generate-id($node) || 'width')"/>

        <xsl:if test="$width != ''"><xsl:text expand-text="yes">
.{$selector} {{
width:{$width};
}}
</xsl:text></xsl:if>
    </xsl:function>


    <xsl:function name="f:image-width" as="xs:string?">
        <xsl:param name="file" as="xs:string"/>
        <xsl:variable name="width" select="$imageInfo/img:images/img:image[@path=$file]/@width" as="xs:string?"/>
        <xsl:sequence select="f:round-dimension(f:adjust-dimension($width, number(f:get-setting('images.scale'))))"/>
    </xsl:function>

    <xsl:function name="f:image-height" as="xs:string?">
        <xsl:param name="file" as="xs:string"/>
        <xsl:variable name="height" select="$imageInfo/img:images/img:image[@path=$file]/@height" as="xs:string?"/>
        <xsl:sequence select="f:round-dimension(f:adjust-dimension($height, number(f:get-setting('images.scale'))))"/>
    </xsl:function>

    <xsl:function name="f:image-file-size" as="xs:string?">
        <xsl:param name="file" as="xs:string"/>
        <xsl:variable name="fileSize" select="$imageInfo/img:images/img:image[@path=$file]/@filesize"/>
        <xsl:sequence select="$fileSize"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Handle a figure element.</xd:short>
        <xd:detail>
            <p>This template handles the figure element. It takes care of positioning figure annotations (title, legend, etc.) and in-line loading of the image in HTML.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="figure">
        <xsl:copy-of select="f:show-debug-tags(.)"/>

        <xsl:variable name="alt" select="f:determine-image-alt-text(., '')" as="xs:string"/>
        <xsl:variable name="filename" select="f:determine-image-filename(.)" as="xs:string"/>

        <xsl:if test="f:is-image-included($filename)">
            <xsl:if test="not(f:rend-value(@rend, 'position') = ('abovehead', 'belowtrailer'))">
                <!-- Render a figure outside the paragraph context if its position is 'abovehead' or 'belowtrailer'. -->
                <xsl:call-template name="closepar"/>
            </xsl:if>
            <div class="figure">
                <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
                <xsl:copy-of select="f:set-figure-class(.)"/>

                <xsl:call-template name="figure-head-top"/>
                <xsl:call-template name="figure-annotations-top"/>

                <xsl:call-template name="output-image-with-optional-link">
                    <xsl:with-param name="filename" select="$filename"/>
                    <xsl:with-param name="alt" select="$alt"/>
                </xsl:call-template>

                <xsl:call-template name="figure-annotations-bottom"/>
                <xsl:apply-templates/>
            </div>
            <xsl:if test="not(f:rend-value(@rend, 'position') = ('abovehead', 'belowtrailer'))">
                <xsl:call-template name="reopenpar"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xsl:function name="f:set-figure-class">
        <xsl:param name="node" as="element(figure)"/>

        <xsl:variable name="filename" select="f:determine-image-filename($node)" as="xs:string"/>
        <xsl:variable name="width" select="f:image-width($filename)" as="xs:string?"/>
        <xsl:variable name="class">
            <xsl:text>figure </xsl:text>
            <xsl:if test="f:rend-value($node/@rend, 'float') = 'left'">floatLeft </xsl:if>
            <xsl:if test="f:rend-value($node/@rend, 'float') = 'right'">floatRight </xsl:if>

            <!-- Add the class that sets the width, if known. -->
            <xsl:if test="$width != ''"><xsl:value-of select="f:generate-id($node)"/><xsl:text>width</xsl:text></xsl:if>
        </xsl:variable>
        <xsl:copy-of select="f:set-class-attribute-with($node, $class)"/>
    </xsl:function>


    <xd:doc>
        <xd:short>Handle a figure head that should be placed above the figure.</xd:short>
    </xd:doc>

    <xsl:template name="figure-head-top">
        <xsl:context-item as="element()" use="required"/>

        <xsl:if test="head[f:position-annotation(@rend) = 'figTop']">
            <xsl:apply-templates select="head[f:position-annotation(@rend) = 'figTop']" mode="figAnnotation"/>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle figure annotations that should be placed directly above the figure.</xd:short>
    </xd:doc>

    <xsl:template name="figure-annotations-top">
        <xsl:context-item as="element()" use="required"/>

        <xsl:if test="p[f:has-top-position-annotation(@rend)]">

            <xsl:variable name="filename" select="f:determine-image-filename(.)" as="xs:string"/>
            <xsl:variable name="width" select="f:image-width($filename)" as="xs:string?"/>

            <div>
                <xsl:attribute name="class">
                    <xsl:text>figAnnotation </xsl:text>
                    <xsl:if test="$width != ''"><xsl:value-of select="f:generate-id(.)"/><xsl:text>width</xsl:text></xsl:if>
                </xsl:attribute>

                <xsl:if test="p[f:position-annotation(@rend) = 'figTopLeft']">
                    <span>
                        <xsl:copy-of select="f:set-class-attribute-with(p[f:position-annotation(@rend) = 'figTopLeft'][1], 'figTopLeft')"/>
                        <xsl:apply-templates select="p[f:position-annotation(@rend) = 'figTopLeft']" mode="figAnnotation"/>
                    </span>
                </xsl:if>
                <xsl:if test="p[f:position-annotation(@rend) = 'figTop']">
                    <span>
                        <xsl:copy-of select="f:set-class-attribute-with(p[f:position-annotation(@rend) = 'figTop'][1], 'figTop')"/>
                        <xsl:apply-templates select="p[f:position-annotation(@rend) = 'figTop']" mode="figAnnotation"/>
                    </span>
                </xsl:if>
                <xsl:if test="not(p[f:position-annotation(@rend) = 'figTop'])">
                    <span class="figTop"><xsl:text>&nbsp;</xsl:text></span>
                </xsl:if>
                <xsl:if test="p[f:position-annotation(@rend) = 'figTopRight']">
                    <span>
                        <xsl:copy-of select="f:set-class-attribute-with(p[f:position-annotation(@rend) = 'figTopRight'][1], 'figTopRight')"/>
                        <xsl:apply-templates select="p[f:position-annotation(@rend) = 'figTopRight']" mode="figAnnotation"/>
                    </span>
                </xsl:if>
            </div>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle figure annotations that should be placed directly below the figure.</xd:short>
    </xd:doc>

    <xsl:template name="figure-annotations-bottom">
        <xsl:context-item as="element()" use="required"/>

        <xsl:if test="p[f:has-bottom-position-annotation(@rend)]">

            <xsl:variable name="filename" select="f:determine-image-filename(.)" as="xs:string"/>
            <xsl:variable name="width" select="f:image-width($filename)" as="xs:string?"/>

            <div>
                <xsl:attribute name="class">
                    <xsl:text>figAnnotation </xsl:text>
                    <xsl:if test="$width != ''"><xsl:value-of select="f:generate-id(.)"/><xsl:text>width</xsl:text></xsl:if>
                </xsl:attribute>

                <xsl:if test="p[f:position-annotation(@rend) = 'figBottomLeft']">
                    <span>
                        <xsl:copy-of select="f:set-class-attribute-with(p[f:position-annotation(@rend) = 'figBottomLeft'][1], 'figBottomLeft')"/>
                        <xsl:apply-templates select="p[f:position-annotation(@rend) = 'figBottomLeft']" mode="figAnnotation"/>
                    </span>
                </xsl:if>
                <xsl:if test="p[f:position-annotation(@rend) = 'figBottom']">
                    <span>
                        <xsl:copy-of select="f:set-class-attribute-with(p[f:position-annotation(@rend) = 'figBottom'][1], 'figBottom')"/>
                        <xsl:apply-templates select="p[f:position-annotation(@rend) = 'figBottom']" mode="figAnnotation"/>
                    </span>
                </xsl:if>
                <xsl:if test="not(p[f:position-annotation(@rend) = 'figBottom'])">
                    <span class="figTop"><xsl:text>&nbsp;</xsl:text></span>
                </xsl:if>
                <xsl:if test="p[f:position-annotation(@rend) = 'figBottomRight']">
                    <span>
                        <xsl:copy-of select="f:set-class-attribute-with(p[f:position-annotation(@rend) = 'figBottomRight'][1], 'figBottomRight')"/>
                        <xsl:apply-templates select="p[f:position-annotation(@rend) = 'figBottomRight']" mode="figAnnotation"/>
                    </span>
                </xsl:if>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:function name="f:has-position-annotation" as="xs:boolean">
        <xsl:param name="rend" as="xs:string?"/>
        <xsl:sequence select="f:position-annotation($rend) != ''"/>
    </xsl:function>

    <xsl:function name="f:has-top-position-annotation" as="xs:boolean">
        <xsl:param name="rend" as="xs:string?"/>
        <xsl:sequence select="f:top-position-annotation($rend) != ''"/>
    </xsl:function>

    <xsl:function name="f:has-bottom-position-annotation" as="xs:boolean">
        <xsl:param name="rend" as="xs:string?"/>
        <xsl:sequence select="f:bottom-position-annotation($rend) != ''"/>
    </xsl:function>

    <xsl:function name="f:position-annotation" as="xs:string">
        <xsl:param name="rend" as="xs:string?"/>
        <xsl:variable name="position" select="f:rend-value($rend, 'position')"/>
        <xsl:value-of select="if ($position = ('figTopLeft', 'figTop', 'figTopRight', 'figBottomLeft', 'figBottom', 'figBottomRight')) then $position else ''"/>
    </xsl:function>

    <xsl:function name="f:top-position-annotation" as="xs:string">
        <xsl:param name="rend" as="xs:string?"/>
        <xsl:variable name="position" select="f:rend-value($rend, 'position')"/>
        <xsl:value-of select="if ($position = ('figTopLeft', 'figTop', 'figTopRight')) then $position else ''"/>
    </xsl:function>

    <xsl:function name="f:bottom-position-annotation" as="xs:string">
        <xsl:param name="rend" as="xs:string?"/>
        <xsl:variable name="position" select="f:rend-value($rend, 'position')"/>
        <xsl:value-of select="if ($position = ('figBottomLeft', 'figBottom', 'figBottomRight')) then $position else ''"/>
    </xsl:function>

    <xsl:template match="figure/head[not(f:has-position-annotation(@rend))]">
        <p class="figureHead"><xsl:apply-templates/></p>
    </xsl:template>


    <xd:doc>
        <xd:short>Figure heads that should go above are handled elsewhere.</xd:short>
    </xd:doc>

    <xsl:template match="figure/head[f:has-position-annotation(@rend)]"/>


    <xd:doc>
        <xd:short>Paragraphs that are placed around a picture with an explicit position are handled elsewhere.</xd:short>
    </xd:doc>

    <xsl:template match="p[f:has-position-annotation(@rend)]"/>


    <xsl:template match="figure/head[f:has-position-annotation(@rend)]" mode="figAnnotation">
        <p class="figureHead"><xsl:apply-templates/></p>
    </xsl:template>


    <xsl:template match="p[f:has-position-annotation(@rend)]" mode="figAnnotation">
        <xsl:apply-templates/>
    </xsl:template>


    <xd:doc>
        <xd:short>The figDesc element is not rendered (but used as an attribute value).</xd:short>
    </xd:doc>

    <xsl:template match="figDesc"/>


    <xd:doc>
        <xd:short>Handle a TEI P5 graphic element. (UNDER DEVELOPMENT)</xd:short>
        <xd:detail>
            <p>The TEI P5 specification uses an alternative model for including figures; allowing more
            than one graphic element to be encoded in a figure.</p>

            <p>To co-exist with the TEI P3 specification, the code only assumes the P5 model when a
            figure element contains a graphic element.</p>
        </xd:detail>
    </xd:doc>


    <xsl:template match="graphic">
        <!-- handle both P3 @url and P5 @target convention -->
        <xsl:variable name="url" select="if (@url) then @url else @target"/>

        <xsl:if test="f:is-image-included($url)">
            <xsl:copy-of select="f:output-image($url, if (../figDesc) then ../figDesc else '')"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="graphic" mode="css">
        <xsl:variable name="url" select="if (@url) then @url else @target"/>
        <xsl:if test="f:is-image-included($url)">
            <xsl:copy-of select="f:output-image-width-css(., $url)"/>
        </xsl:if>
    </xsl:template>






    <xsl:template match="figureGroup"> <!-- For now, we use a self-invented element: figureGroup. This should become match="figure[figure]" -->
        <div>
            <xsl:copy-of select="f:set-class-attribute-with(., 'figureGroup')"/>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:choose>
                <xsl:when test="f:rend-value(@rend, 'direction') = 'horizontal'">
                    <table class="figureGroupTable">
                        <tr>
                            <xsl:for-each select="figure | figureGroup">
                                <td>
                                    <xsl:apply-templates select="."/>
                                </td>
                            </xsl:for-each>
                        </tr>
                    </table>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="figure | figureGroup"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="node()[not(self::figure)][not(self::figureGroup)]"/>
        </div>
    </xsl:template>

    <xsl:template match="figureGroup/head">
        <p class="figureHead"><xsl:apply-templates/></p>
    </xsl:template>

    <xsl:template match="figure[graphic]">
        <div>
            <xsl:copy-of select="f:set-class-attribute-with(., 'figureGroup')"/>
            <xsl:copy-of select="f:set-lang-id-attributes(.)"/>
            <xsl:variable name="class">
                <xsl:text>figure </xsl:text>
                <xsl:variable name="widestImage" select="f:widest-image(graphic/@url)"/>
                <xsl:if test="f:image-width($widestImage) != ''">
                    <xsl:value-of select="f:generate-id(graphic[@url = $widestImage][1])"/><xsl:text>width</xsl:text>
                </xsl:if>
            </xsl:variable>
            <xsl:copy-of select="f:set-class-attribute-with(., $class)"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>


    <xsl:function name="f:widest-image" as="xs:string?">
        <xsl:param name="files" as="xs:string*"/>
        <xsl:variable name="maxWidth" select="f:max-width($imageInfo/img:images/img:image[@path=$files]/@width)" as="xs:string?"/>
        <xsl:value-of select="$imageInfo/img:images/img:image[@path=$files and @width=$maxWidth][1]/@path"/>
    </xsl:function>


    <xsl:function name="f:max-width" as="xs:string">
        <xsl:param name="widths" as="xs:string*"/>
        <xsl:value-of select="max(for $width in $widths return translate($width, 'px', '')) || 'px'"/>
     </xsl:function>





    <xsl:template match="figure[figure]" mode="css">
        <!-- the outer figure typically has no image attached to it -->
        <xsl:if test="@rend">
            <xsl:call-template name="generate-css-rule"/>
        </xsl:if>
        <xsl:apply-templates mode="css"/>
    </xsl:template>





    <xsl:function name="f:count-graphics" as="xs:integer">
        <xsl:param name="node" as="node()"/>

        <xsl:sequence select="count($node//graphic) - count($node//note[@place='foot' or not(@place)]//graphic)"/>
    </xsl:function>


    <xsl:function name="f:contains-figure" as="xs:boolean">
        <xsl:param name="node" as="node()"/>
        <!-- $node contains a figure element (either directly or within some other element, but excluding
             elements that get lifted out of the context of this node (for example: footnotes) -->
        <xsl:sequence select="count($node//figure) - count($node//note[not(@place) or @place='foot']//figure) > 0"/>
    </xsl:function>

</xsl:stylesheet>
