<?xml version="1.0" encoding="ISO-8859-1"?>

    <xsl:stylesheet
        xmlns="http://www.idpf.org/2007/opf"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        xmlns:dcterms="http://purl.org/dc/terms/"
        xmlns:opf="http://www.idpf.org/2007/opf"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:smil="http://www.w3.org/ns/SMIL"
        xmlns:f="urn:stylesheet-functions"
        xmlns:xd="http://www.pnp-software.com/XSLTdoc"
        exclude-result-prefixes="f xd xs smil"
        version="2.0">


    <xd:doc type="stylesheet">
        <xd:short>XSLT stylesheet to create an ePub OPF file from a TEI document.</xd:short>
        <xd:detail>This stylesheet generates the OPF file from a TEI document.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2012, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xsl:output name="opf"
        doctype-public=""
        doctype-system=""
        method="xml"
        indent="yes"
        encoding="utf-8"/>


    <xd:doc type="string">Filename of file with additional items to be added to the OPF file, such as custom fonts.</xd:doc>

    <xsl:param name="opfMetadataFile"/>
    <xsl:param name="opfManifestFile"/>
    <xsl:param name="useOggFallback" select="false()"/>

    <xd:doc>
        <xd:short>Generate the OPF file.</xd:short>
        <xd:detail>
            <p>Generate the OPF file, based on information found mainly in the <code>teiHeader</code>.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="TEI.2 | TEI" mode="opf">
        <xsl:result-document format="opf" href="{$path}/{$basename}.opf">
            <xsl:copy-of select="f:logInfo('Generated OPF file: {1}/{2}.opf.', ($path, $basename))"/>

            <package>
                <xsl:attribute name="version">
                    <xsl:value-of select="'3.0'"/>
                </xsl:attribute>
                <xsl:attribute name="unique-identifier">epub-id</xsl:attribute>

                <xsl:call-template name="metadata"/>
                <xsl:call-template name="manifest"/>
                <xsl:call-template name="spine"/>
                <xsl:call-template name="guide"/>
            </package>
        </xsl:result-document>
    </xsl:template>


    <!--== metadata ========================================================-->

    <xd:doc>
        <xd:short>Generate the metadata for in the OPF file.</xd:short>
        <xd:detail>
            <p>Generate the metadata for in the OPF file, based on information found mainly in the <code>teiHeader</code>.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="metadata">
        <metadata>
            <!-- ePub document ids -->
            <xsl:choose>
                <xsl:when test="teiHeader/fileDesc/publicationStmt/idno[@type = 'epub-id']">
                    <xsl:variable name="epub-id"><xsl:value-of select="teiHeader/fileDesc/publicationStmt/idno[@type = 'epub-id']"/></xsl:variable>

                    <dc:identifier id="epub-id"><xsl:value-of select="$epub-id"/></dc:identifier>
                    <meta refines="#epub-id" property="identifier-type">uuid</meta>
                    <meta property="dcterms:modified"><xsl:value-of select="f:utc-timestamp()"/></meta>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="f:logWarning('An ePub document needs a unique id.', ())"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="teiHeader/fileDesc/publicationStmt/idno[@type ='ISBN']">
                <dc:identifier id="isbn">
                    <xsl:value-of select="teiHeader/fileDesc/publicationStmt/idno[@type = 'ISBN']"/>
                </dc:identifier>
            </xsl:if>
            <xsl:if test="teiHeader/fileDesc/publicationStmt/idno[@type ='PGnum']">
                <dc:identifier id="pgnum">
                    <xsl:text>https://www.gutenberg.org/ebooks/</xsl:text>
                    <xsl:value-of select="teiHeader/fileDesc/publicationStmt/idno[@type = 'PGnum']"/>
                </dc:identifier>
                <meta refines="#pgnum" property="identifier-type">uri</meta>
            </xsl:if>

            <!-- Metadata from the titleStmt and publicationStmt -->
            <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/title" mode="metadata"/>
            <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/author" mode="metadata"/>
            <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/respStmt" mode="metadata"/>
            <xsl:apply-templates select="teiHeader/fileDesc/publicationStmt" mode="metadata"/>
            <xsl:apply-templates select="teiHeader/fileDesc/publicationStmt/availability" mode="metadata"/>

            <xsl:if test="@lang">
                <dc:language>
                    <xsl:value-of select="f:fix-lang(@lang)"/>
                </dc:language>
            </xsl:if>

            <xsl:for-each select="teiHeader/profileDesc/textClass/keywords/list/item">
                <dc:subject><xsl:value-of select="."/></dc:subject>
            </xsl:for-each>

            <xsl:if test="f:isValid(teiHeader/fileDesc/publicationStmt/date)">
                <dc:date>
                    <xsl:value-of select="teiHeader/fileDesc/publicationStmt/date"/>
                </dc:date>
            </xsl:if>

            <xsl:if test="teiHeader/fileDesc/notesStmt/note[@type='Description']">
                <dc:description><xsl:value-of select="teiHeader/fileDesc/notesStmt/note[@type='Description']"/></dc:description>
            </xsl:if>

            <!-- Support the Calibre tags for series and series volume -->
            <xsl:if test="teiHeader/fileDesc/seriesStmt/title">
                <meta name="calibre:series"><xsl:attribute name="content" select="teiHeader/fileDesc/seriesStmt/title"/></meta>
            </xsl:if>
            <xsl:if test="teiHeader/fileDesc/seriesStmt/biblScope[@type='vol']">
                <meta name="calibre:series_index"><xsl:attribute name="content" select="teiHeader/fileDesc/seriesStmt/biblScope"/></meta>
            </xsl:if>

            <!-- Identify the cover page -->
            <xsl:choose>
                <xsl:when test="//figure[@id='cover-image']">
                    <meta name="cover" content="cover-image"/>
                </xsl:when>
                <xsl:when test="//figure[@id='titlepage-image']">
                    <meta name="cover" content="titlepage-image"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="f:logWarning('No suitable cover or title-page image found.', ())"/>
                </xsl:otherwise>
            </xsl:choose>

            <!-- Retrieve additional metadata for audio overlays from SMIL files -->
            <xsl:call-template name="metadata-smil"/>


            <!-- Insert additional metadata given verbatim in a file -->
            <xsl:if test="$opfMetadataFile">
                <xsl:copy-of select="f:logInfo('Reading extra OPF metadata from: {1}.', ($opfMetadataFile))"/>
                <xsl:copy-of select="document(normalize-space($opfMetadataFile))/opf:metadata/*"/>
            </xsl:if>
        </metadata>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle title information in metadata.</xd:short>
        <xd:detail>
            <p>Handle title information in metadata.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="title" mode="metadata">
        <dc:title>
            <xsl:value-of select="."/>
        </dc:title>
    </xsl:template>

    <xsl:template match="title[@type='pgshort']" mode="metadata"/>


    <xd:doc>
        <xd:short>Handle author information in metadata.</xd:short>
        <xd:detail>
            <p>Handle author information in metadata.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="author" mode="metadata">

        <xsl:variable name="id" select="concat(f:generate-id(.), 'metadata')"/>

        <dc:creator id="{$id}">
            <xsl:value-of select="."/>
        </dc:creator>

        <meta property="role" refines="#{$id}" scheme="marc:relators"><xsl:value-of select="'aut'"/></meta>

        <!-- Assume we use the key attribute to store the sort-key; this is not strictly valid: the key could also be a key into some database. -->
        <xsl:if test="@key">
            <meta property="file-as" refines="#{$id}"><xsl:value-of select="@key"/></meta>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle information on other contributors in metadata.</xd:short>
        <xd:detail>
            <p>Handle information on other contributors in metadata.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="respStmt" mode="metadata">

        <xsl:variable name="id" select="concat(f:generate-id(.), 'metadata')"/>

        <dc:contributor id="{$id}">
            <xsl:value-of select="name"/>
        </dc:contributor>

        <xsl:if test="resp">
            <meta property="role" refines="#{$id}" scheme="marc:relators"><xsl:value-of select="f:translateRespCode(resp)"/></meta>
        </xsl:if>
        <xsl:if test="name/@key">
            <meta property="file-as" refines="#{$id}"><xsl:value-of select="name/@key"/></meta>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle publication details in metadata.</xd:short>
        <xd:detail>
            <p>Handle publication details in metadata.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="publicationStmt" mode="metadata">
        <dc:publisher>
            <xsl:value-of select="publisher"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="pubPlace"/>
        </dc:publisher>
    </xsl:template>


    <xd:doc>
        <xd:short>Handle rights in metadata.</xd:short>
        <xd:detail>
            <p>Handle rights in metadata. Just copy the availability statement over to the <code>dc:rights</code> element.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="availability" mode="metadata">
        <dc:rights>
            <xsl:value-of select="."/>
        </dc:rights>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate metadata related to media-overlays.</xd:short>
        <xd:detail>
            <p>Generate metadata related to media-overlays. Derive the durations from the references SMIL files.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="metadata-smil">
        <xsl:if test="//*[f:has-rend-value(@rend, 'media-overlay')]">
            <!-- Add up the durations for each audio fragment -->
            <xsl:for-each select="//*[f:has-rend-value(@rend, 'media-overlay')]">
                <xsl:variable name="durations">
                    <xsl:variable name="filename" select="f:rend-value(@rend, 'media-overlay')"/>
                    <xsl:apply-templates select="document($filename, .)" mode="metadata-smil"/>
                </xsl:variable>

                <meta property="media:duration" refines="#{@id}overlay">
                    <xsl:value-of select="f:secondsToTime(sum($durations/*))"/>
                </meta>
            </xsl:for-each>

            <!-- Find total duration -->
            <xsl:variable name="durations">
                <xsl:for-each select="//*[f:has-rend-value(@rend, 'media-overlay')]">
                    <xsl:variable name="filename" select="f:rend-value(@rend, 'media-overlay')"/>
                    <xsl:apply-templates select="document($filename, .)" mode="metadata-smil"/>
                </xsl:for-each>
            </xsl:variable>
            <meta property="media:duration">
                <xsl:value-of select="f:secondsToTime(sum($durations/*))"/>
            </meta>

            <!-- Add further required tag if media overlays are present -->
            <meta property="media:active-class">epub-media-overlay-active</meta>
        </xsl:if>
    </xsl:template>


    <xsl:template match="smil:audio[@src]" mode="metadata-smil">
        <xsl:variable name="clipBegin" select="f:timeToSeconds(@clipBegin)"/>
        <xsl:variable name="clipEnd" select="f:timeToSeconds(@clipEnd)"/>
        <xsl:variable name="duration" select="$clipEnd - $clipBegin"/>

        <duration><xsl:value-of select="$duration"/></duration>
    </xsl:template>


    <!--== manifest ========================================================-->

    <xd:doc>
        <xd:short>Generate the ePub manifest.</xd:short>
        <xd:detail>
            <p>Generate the ePub manifest. Collect names and other information on files that will be
            included in the ePub container.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="manifest">
        <manifest>
            <item id="ncx"
                 href="{$basename}.ncx"
                 media-type="application/x-dtbncx+xml"/>

            <!-- Store these in a list, from which we remove duplicates later-on -->
            <xsl:variable name="manifest-items">

                <item id="epub3toc"
                     properties="nav"
                     href="{$basename}-nav.xhtml"
                     media-type="application/xhtml+xml"/>

                <!-- CSS Style Sheets -->
                <item id="css"
                     href="{$basename}.css"
                     media-type="text/css"/>

                <!-- Content Parts -->
                <xsl:apply-templates select="text" mode="manifest"/>

                <!-- Illustrations -->
                <xsl:apply-templates select="//figure" mode="manifest"/>
                <xsl:apply-templates select="//*[f:has-rend-value(@rend, 'image')]" mode="manifest"/>
                <xsl:apply-templates select="//*[f:has-rend-value(@rend, 'link')]" mode="manifest-links"/>

                <!-- Automatically inserted illustrations in tables (i.e. braces for cells that span more than one row and contain only a brace) -->
                <xsl:apply-templates select="//cell" mode="manifest-braces"/>

                <!-- Media overlays -->
                <xsl:apply-templates select="//*[f:has-rend-value(@rend, 'media-overlay')]" mode="manifest"/>

                <!-- Include custom items in the manifest -->
                <xsl:if test="$opfManifestFile">
                    <xsl:copy-of select="f:logInfo('Reading extra OPF manifest items from: {1}.', ($opfManifestFile))"/>
                    <xsl:apply-templates select="document(normalize-space($opfManifestFile))/opf:manifest" mode="copy-manifest"/>
                </xsl:if>
            </xsl:variable>

            <xsl:apply-templates select="$manifest-items" mode="undouble"/>
        </manifest>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate manifest entries for the main divisions of the text.</xd:short>
        <xd:detail>
            <p>Generate manifest entries for the main. To make sure the divisions are determined in the
            same way as when they are generated, the same splitter templates are used to achieve this.
            See <code>splitter.xsl</code> for details.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="text" mode="manifest">
        <xsl:apply-templates mode="splitter">
            <xsl:with-param name="action" select="'manifest'"/>
        </xsl:apply-templates>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate a manifest entry for a figure.</xd:short>
        <xd:detail>
            <p>Generate a manifest entry for the referenced image file.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="figure" mode="manifest">
        <xsl:if test="f:isRendered(.)">
            <xsl:variable name="filename">
                <xsl:choose>
                    <xsl:when test="f:has-rend-value(@rend, 'image')">
                        <xsl:value-of select="f:rend-value(@rend, 'image')"/>
                    </xsl:when>
                    <xsl:otherwise>images/<xsl:value-of select="@id"/>.jpg</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:call-template name="manifest-image-item">
                <xsl:with-param name="filename" select="$filename"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate a manifest entry for referenced items.</xd:short>
        <xd:detail>
            <p>Generate a manifest entry for referenced images and media overlays.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="*" mode="manifest">
        <xsl:if test="f:has-rend-value(@rend, 'image')">
            <xsl:variable name="filename">
                <xsl:value-of select="f:rend-value(@rend, 'image')"/>
            </xsl:variable>

            <xsl:call-template name="manifest-image-item">
                <xsl:with-param name="filename" select="$filename"/>
            </xsl:call-template>
        </xsl:if>

        <xsl:if test="f:has-rend-value(@rend, 'media-overlay')">
            <xsl:variable name="filename">
                <xsl:value-of select="f:rend-value(@rend, 'media-overlay')"/>
            </xsl:variable>
            <xsl:call-template name="manifest-media-overlay-item">
                <xsl:with-param name="filename" select="$filename"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate manifest entries for media overlays.</xd:short>
        <xd:detail>
            <p>Generate a manifest entry for the SMIL file as well as the audio files
            referenced in the SMIL file.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template name="manifest-media-overlay-item">
        <xsl:param name="filename" as="xs:string"/>

        <!-- Entry for the .smil file itself. -->
        <item>
            <xsl:attribute name="id"><xsl:value-of select="f:generate-id(.)"/>overlay</xsl:attribute>
            <xsl:attribute name="href"><xsl:value-of select="$filename"/></xsl:attribute>
            <xsl:attribute name="media-type">application/smil+xml</xsl:attribute>
        </item>

        <!-- Handle the .smil file itself for further entries -->
        <xsl:copy-of select="f:logInfo('Reading media overlay information from: {1}.', ($filename))"/>
        <xsl:apply-templates mode="manifest-smil" select="document($filename, .)"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate manifest entries for audio files.</xd:short>
        <xd:detail>
            <p>Generate a manifest entry for audio files referenced in a SMIL file.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="smil:audio[@src]" mode="manifest-smil">
        <xsl:variable name="basename"><xsl:value-of select="replace(@src, '\.mp3$', '')"/></xsl:variable>
        <xsl:variable name="id" select="f:generate-id(.)"/>

        <xsl:copy-of select="f:logDebug('Adding audio: {1}; begin: {2}; end: {3}.', (@src, @clipBegin, @clipEnd))"/>

        <item>
            <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
            <xsl:attribute name="href"><xsl:value-of select="@src"/></xsl:attribute>
            <xsl:attribute name="media-type">audio/mpeg</xsl:attribute>
            <xsl:if test="$useOggFallback">
                <xsl:attribute name="fallback"><xsl:value-of select="$id"/>-ogg</xsl:attribute>
            </xsl:if>
        </item>

        <xsl:if test="$useOggFallback">
            <item>
                <xsl:attribute name="id"><xsl:value-of select="$id"/>-ogg</xsl:attribute>
                <xsl:attribute name="href"><xsl:value-of select="$basename"/>.ogg</xsl:attribute>
                <xsl:attribute name="media-type">audio/ogg</xsl:attribute>
            </item>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Enable access to the initial TEI file while handling the .smil file.</xd:short>
    </xd:doc>

    <xsl:variable name="teiFile" select="/"/>


    <xd:doc>
        <xd:short>Verify fragments mentioned in the .smil file are available in the text.</xd:short>
    </xd:doc>

    <xsl:template match="smil:text[@src]" mode="manifest-smil">
        <xsl:variable name="basename"><xsl:value-of select="replace(@src, '\.xhtml.*$', '')"/></xsl:variable>
        <xsl:variable name="fragmentid"><xsl:value-of select="replace(@src, '^.*\.xhtml#', '')"/></xsl:variable>

        <xsl:if test="not($teiFile//*[@id=$fragmentid])">
            <xsl:copy-of select="f:logWarning('Fragment id: {1} not present in text.', ($fragmentid))"/>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Calculate the number of seconds in a duration expressed as hh:mm:ss.sss.</xd:short>
    </xd:doc>

    <xsl:function name="f:timeToSeconds" as="xs:double">
        <xsl:param name="time" as="xs:string"/>

        <!-- 00:00:00.000 -->
        <xsl:analyze-string select="$time" regex="^([0-9]+):([0-9]+):([0-9]+(\.[0-9]+)?)$">
            <xsl:matching-substring>
                <xsl:value-of select="number(regex-group(1)) * 3600 + number(regex-group(2)) * 60 + number(regex-group(3))"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:copy-of select="f:logWarning('Time: {1} not recognized.', ($time))"/>
                <xsl:text>0</xsl:text>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>


    <xd:doc>
        <xd:short>Convert a number of seconds to a duration expressed as hh:mm:ss.</xd:short>
    </xd:doc>

    <xsl:function name="f:secondsToTime" as="xs:string">
        <xsl:param name="seconds" as="xs:double"/>

        <xsl:variable name="hours" select="floor($seconds div 3600)"/>
        <xsl:variable name="seconds" select="$seconds - $hours * 3600"/>
        <xsl:variable name="minutes" select="floor($seconds div 60)"/>
        <xsl:variable name="seconds" select="$seconds - $minutes * 60"/>

        <xsl:variable name="time">
            <xsl:value-of select="$hours"/>
            <xsl:text>:</xsl:text>
            <xsl:value-of select="if ($minutes &lt; 10) then concat('0', $minutes) else $minutes"/>
            <xsl:text>:</xsl:text>
            <xsl:value-of select="if ($seconds &lt; 10) then concat('0', $seconds) else $seconds"/>
        </xsl:variable>

        <xsl:value-of select="$time"/>
    </xsl:function>


    <xsl:template match="@*|node()" mode="manifest-smil">
        <xsl:apply-templates mode="manifest-smil"/>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate manifest entries for images linked to.</xd:short>
    </xd:doc>

    <xsl:template match="*" mode="manifest-links">
        <xsl:if test="f:has-rend-value(@rend, 'link')">
            <xsl:variable name="target">
                <xsl:value-of select="f:rend-value(@rend, 'link')"/>
            </xsl:variable>

            <!-- Only for local images: add the image to the manifest -->
            <xsl:if test="matches($target, '^[^:]+\.(jpg|png|gif|svg)$')">
                <xsl:call-template name="manifest-image-item">
                    <xsl:with-param name="filename" select="$target"/>
                    <xsl:with-param name="how" select="'link'"/>
                </xsl:call-template>
                <!-- Also add the generated wrapper HTML to the manifest -->
                <item id="{f:generate-id(.)}wrapper">
                    <xsl:attribute name="href"><xsl:value-of select="$basename"/>-<xsl:value-of select="f:generate-id(.)"/>.xhtml</xsl:attribute>
                    <xsl:attribute name="media-type">application/xhtml+xml</xsl:attribute>
                </item>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Generate manifest entries for images of braces automatically inserted in tables.</xd:short>
    </xd:doc>

    <xsl:template match="cell[@rows &gt; 1 and normalize-space(.) = '{']" mode="manifest-braces">
        <xsl:call-template name="manifest-image-item">
            <xsl:with-param name="filename" select="concat('images/lbrace', @rows, '.png')"/>
            <xsl:with-param name="how" select="'brace'"/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="cell[@rows &gt; 1 and normalize-space(.) = '}']" mode="manifest-braces">
        <xsl:call-template name="manifest-image-item">
            <xsl:with-param name="filename" select="concat('images/rbrace', @rows, '.png')"/>
            <xsl:with-param name="how" select="'brace'"/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="cell" mode="manifest-braces"/>


    <xsl:template name="manifest-image-item">
        <xsl:param name="filename" as="xs:string"/>
        <xsl:param name="how" select="''" as="xs:string"/>

        <xsl:variable name="mimetype">
            <xsl:choose>
                <xsl:when test="contains($filename, '.jpg') or contains($filename, '.jpeg')">image/jpeg</xsl:when>
                <xsl:when test="contains($filename, '.png')">image/png</xsl:when>
                <xsl:when test="contains($filename, '.gif')">image/gif</xsl:when>
                <xsl:when test="contains($filename, '.svg')">image/svg+xml</xsl:when>
            </xsl:choose>
        </xsl:variable>

        <item>
            <!-- Append $how after id to make it unique for linked images -->
            <xsl:if test="@id = 'cover-image'">
                <xsl:attribute name="properties">cover-image</xsl:attribute>
            </xsl:if>
            <xsl:attribute name="id"><xsl:value-of select="f:generate-id(.)"/><xsl:value-of select="$how"/></xsl:attribute>
            <xsl:attribute name="href"><xsl:value-of select="$filename"/></xsl:attribute>
            <xsl:attribute name="media-type"><xsl:value-of select="$mimetype"/></xsl:attribute>
        </item>

    </xsl:template>


    <xd:doc>
        <xd:short>Remove duplicated resources from the list (included because the ePub uses
         them more than once).</xd:short>
    </xd:doc>

    <xsl:template match="opf:item" mode="undouble">
        <xsl:variable name="href" select="@href"/>
        <xsl:if test="not(preceding-sibling::opf:item[@href = $href])">
            <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>


    <xd:doc>
        <xd:short>Copy items from an included manifest-snippet.</xd:short>
    </xd:doc>

    <xsl:template match="opf:item" mode="copy-manifest">
        <xsl:copy-of select="."/>
    </xsl:template>


    <!--== spine ===========================================================-->

    <xsl:template name="spine">
        <spine toc="ncx">

            <!-- make sure the cover comes first in the spine -->
            <xsl:if test="//div1[@id='cover'] | //div[@id='cover']">
                <itemref xmlns="http://www.idpf.org/2007/opf" linear="no" idref="cover"/>
            </xsl:if>

            <xsl:apply-templates select="text" mode="spine"/>

            <!-- Handle figures that contain links, as we generate a wrapper file for these -->
            <xsl:apply-templates select="//figure" mode="spine-links"/>
        </spine>
    </xsl:template>


    <xsl:template match="text" mode="spine">
        <xsl:apply-templates mode="splitter">
            <xsl:with-param name="action" select="'spine'"/>
        </xsl:apply-templates>
    </xsl:template>


    <xsl:template match="figure" mode="spine-links">
        <xsl:if test="f:has-rend-value(@rend, 'link')">
            <xsl:variable name="target">
                <xsl:value-of select="f:rend-value(@rend, 'link')"/>
            </xsl:variable>

            <!-- Only for local images: add the generated HTML wrapper to the spine -->
            <xsl:if test="matches($target, '^[^:]+\.(jpg|png|gif|svg)$')">
                <itemref xmlns="http://www.idpf.org/2007/opf" linear="no" idref="{concat(f:generate-id(.), 'wrapper')}"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <!--== guides ==========================================================-->

    <xsl:template name="get-cover-image">
        <xsl:variable name="figure" select="(if (//figure[@id = 'cover-image']) then //figure[@id = 'cover-image'] else //figure[@id = 'titlepage-image'])[1]"/>
        <xsl:choose>
            <xsl:when test="f:has-rend-value(/*[self::TEI.2 or self::TEI]/text/@rend, 'cover-image')">
                <xsl:value-of select="f:rend-value(/*[self::TEI.2 or self::TEI]/text/@rend, 'cover-image')"/>
            </xsl:when>
            <xsl:when test="f:has-rend-value($figure/@rend, 'image')">
                <xsl:value-of select="f:rend-value($figure/@rend, 'image')"/>
            </xsl:when>
            <xsl:otherwise>images/<xsl:value-of select="$figure/@id"/>.jpg</xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="guide">

        <!-- Include references to specific elements -->
        <guide>

            <xsl:if test="key('id', 'cover')">
                <reference type="cover" title="{f:message('msgCoverImage')}">
                    <xsl:attribute name="href">
                        <!-- We want a bare file name here to help some ePub readers -->
                        <xsl:value-of select="f:generate-filename(key('id', 'cover')[1])"/>
                   </xsl:attribute>
                </reference>
            </xsl:if>

            <xsl:if test="key('id', 'toc')">
                <reference
                    type="toc"
                    title="{f:message('msgTableOfContents')}"
                    href="{f:generate-href(key('id', 'toc')[1])}"/>
            </xsl:if>

            <xsl:if test="key('id', 'loi')">
                <reference
                    type="loi"
                    title="{f:message('msgListOfIllustrations')}"
                    href="{f:generate-href(key('id', 'loi')[1])}"/>
            </xsl:if>

            <xsl:if test="key('id', 'lot')">
                <reference
                    type="lot"
                    title="{f:message('msgListOfTables')}"
                    href="{f:generate-href(key('id', 'lot')[1])}"/>
            </xsl:if>

            <xsl:if test="/*[self::TEI.2 or self::TEI]/text/front/titlePage">
                <reference
                    type="title-page"
                    title="{f:message('msgTitlePage')}"
                    href="{f:generate-href((/*[self::TEI.2 or self::TEI]/text/front/titlePage)[1])}"/>
            </xsl:if>

            <xsl:if test="//div1[@type='Dedication'] | //div[@type='Dedication']">
                <reference
                    type="dedication"
                    title="{f:message('msgDedication')}"
                    href="{f:generate-href((//div1[@type='Dedication'] | //div[@type='Dedication'])[1])}"/>
            </xsl:if>

            <xsl:if test="//div1[@type='Acknowledgements'] | //div[@type='Acknowledgements']">
                <reference
                    type="acknowledgements"
                    title="{f:message('msgAcknowledgements')}"
                    href="{f:generate-href((//div1[@type='Acknowledgements'] | //div[@type='Acknowledgements'])[1])}"/>
            </xsl:if>

            <xsl:if test="//div1[@type='Epigraph'] | //div[@type='Epigraph']">
                <reference
                    type="epigraph"
                    title="{f:message('msgEpigraph')}"
                    href="{f:generate-href((//div1[@type='Epigraph'] | //div[@type='Epigraph'])[1])}"/>
            </xsl:if>

            <xsl:if test="//div1[@type='Index'] | //div[@type='Index']">
                <reference
                    type="index"
                    title="{f:message('msgIndex')}"
                    href="{f:generate-href((//div1[@type='Index'] | //div[@type='Index'])[1])}"/>
            </xsl:if>

            <xsl:if test="//div1[@type='Bibliography'] | //div[@type='Bibliography']">
                <reference
                    type="bibliography"
                    title="{f:message('msgBibliography')}"
                    href="{f:generate-href((//div1[@type='Bibliography'] | //div[@type='Bibliography'])[1])}"/>
            </xsl:if>

            <xsl:if test="//div1[@type='Copyright'] | //div[@type='Copyright']">
                <reference
                    type="copyright-page"
                    title="{f:message('msgCopyrightPage')}"
                    href="{f:generate-href((//div1[@type='Copyright'] | //div[@type='Copyright'])[1])}"/>
            </xsl:if>

            <xsl:if test="//div1[@type='Glossary'] | //div[@type='Glossary']">
                <reference
                    type="glossary"
                    title="{f:message('msgGlossary')}"
                    href="{f:generate-href((//div1[@type='Glossary'] | //div[@type='Glossary'])[1])}"/>
            </xsl:if>

            <xsl:if test="//div1[@type='Preface'] | //div[@type='Preface']">
                <reference
                    type="preface"
                    title="{f:message('msgPreface')}"
                    href="{f:generate-href((//div1[@type='Preface'] | //div[@type='Preface'])[1])}"/>
            </xsl:if>

            <xsl:if test="/*[self::TEI.2 or self::TEI]/text/body/div0 | /*[self::TEI.2 or self::TEI]/text/body/div1 | /*[self::TEI.2 or self::TEI]/text/body/div">
                <reference
                    type="text"
                    title="{f:message('msgText')}"
                    href="{f:generate-href((/*[self::TEI.2 or self::TEI]/text/body/div0 | /*[self::TEI.2 or self::TEI]/text/body/div1 | /*[self::TEI.2 or self::TEI]/text/body/div)[1])}"/>
            </xsl:if>

            <xsl:if test="//divGen[@type='Colophon']">
                <reference
                    type="colophon"
                    title="{f:message('msgColophon')}"
                    href="{f:generate-href((//divGen[@type='Colophon'])[1])}"/>
            </xsl:if>

        </guide>

    </xsl:template>


    <!--== forget about all the rest =======================================-->

    <xsl:template match="*" mode="opf"/>

</xsl:stylesheet>
