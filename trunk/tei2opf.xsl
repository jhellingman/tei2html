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
        <xd:short>TEI stylesheet to create an ePub OPF file from a TEI document.</xd:short>
        <xd:detail>This stylesheet generates the OPF file from a TEI document.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2012, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc type="string">Filename of file with additional items to be added to the OPF file, such as custom fonts.</xd:doc>

    <xsl:param name="opfMetadataFile"/>
    <xsl:param name="opfManifestFile"/>
    <xsl:param name="useOggFallback" select="true()"/>

    <xd:doc>
        <xd:short>Generate the OPF file.</xd:short>
        <xd:detail>
            <p>Generate the OPF file, based on information found mainly in the <code>teiHeader</code>.</p>
        </xd:detail>
    </xd:doc>

    <xsl:template match="TEI.2" mode="opf">
        <xsl:result-document
                doctype-public=""
                doctype-system=""
                href="{$path}/{$basename}.opf"
                method="xml"
                indent="yes"
                encoding="UTF-8">
            <xsl:message terminate="no">INFO:    generated file: <xsl:value-of select="$path"/>/<xsl:value-of select="$basename"/>.opf.</xsl:message>

            <package>
                <xsl:attribute name="version">
                    <xsl:value-of select="if ($optionEPub3 = 'Yes') then '3.0' else '2.0'"/>
                </xsl:attribute>
                <xsl:attribute name="unique-identifier">idbook</xsl:attribute>

                <xsl:call-template name="metadata"/>
                <xsl:call-template name="manifest"/>
                <xsl:call-template name="spine"/>
                <xsl:call-template name="guide"/>
            </package>
        </xsl:result-document>
    </xsl:template>


    <!--== metadata ========================================================-->

    <xsl:template name="metadata">
        <metadata>
            <xsl:call-template name="metadata2"/>
            <xsl:if test="$optionEPub3 = 'Yes'">
                <xsl:call-template name="metadata3"/>
            </xsl:if>

            <!-- Insert additional metadata given verbatim in a file -->
            <xsl:if test="$opfMetadataFile">
                <xsl:message terminate="no">INFO:    Reading from "<xsl:value-of select="$opfMetadataFile"/>".</xsl:message>
                <xsl:copy-of select="document(normalize-space($opfMetadataFile))/opf:metadata/*"/>
            </xsl:if>
        </metadata>
    </xsl:template>

    <xsl:template name="metadata2">
        <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/title" mode="metadata"/>
        <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/author" mode="metadata"/>
        <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/respStmt" mode="metadata"/>
        <xsl:apply-templates select="teiHeader/fileDesc/publicationStmt" mode="metadata"/>
        <xsl:apply-templates select="teiHeader/fileDesc/publicationStmt/availability" mode="metadata"/>
        <xsl:if test="@lang">
            <dc:language>
                <xsl:if test="$optionEPubStrict != 'Yes'">
                    <xsl:attribute name="xsi:type">
                        <xsl:value-of select="'dcterms:RFC4646'"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="@lang"/>
            </dc:language>
        </xsl:if>

        <xsl:for-each select="teiHeader/profileDesc/textClass/keywords/list/item">
            <dc:subject><xsl:value-of select="."/></dc:subject>
        </xsl:for-each>

        <xsl:choose>
            <xsl:when test="teiHeader/fileDesc/publicationStmt/idno[@type ='ISBN']">
                <dc:identifier id="idbook">
                    <xsl:if test="$optionEPubStrict != 'Yes'">
                        <xsl:attribute name="opf:scheme" select="'ISBN'"/>
                    </xsl:if>
                    <xsl:value-of select="teiHeader/fileDesc/publicationStmt/idno[@type = 'ISBN']"/>
                </dc:identifier>
            </xsl:when>
            <xsl:when test="teiHeader/fileDesc/publicationStmt/idno[@type ='PGnum']">
                <dc:identifier id="idbook">
                    <xsl:if test="$optionEPubStrict != 'Yes'">
                        <xsl:attribute name="opf:scheme" select="'URI'"/>
                    </xsl:if>
                    <xsl:text>http://www.gutenberg.org/ebooks/</xsl:text>
                    <xsl:value-of select="teiHeader/fileDesc/publicationStmt/idno[@type = 'PGnum']"/>
                </dc:identifier>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no">WARNING: ePub needs a unique id.</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="f:isvalid(teiHeader/fileDesc/publicationStmt/date)">
            <dc:date>
                <xsl:if test="$optionEPubStrict != 'Yes'">
                    <xsl:attribute name="opf:event" select="'publication'"/>
                </xsl:if>
                <xsl:value-of select="teiHeader/fileDesc/publicationStmt/date"/>
            </dc:date>
        </xsl:if>
        <dc:date>
            <xsl:if test="$optionEPubStrict != 'Yes'">
                <xsl:attribute name="opf:event" select="'generation'"/>
            </xsl:if>
            <xsl:value-of select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
        </dc:date>

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

        <xsl:choose>
            <xsl:when test="//figure[@id='cover-image']">
                <meta name="cover" content="cover-image"/>
            </xsl:when>
            <xsl:when test="//figure[@id='titlepage-image']">
                <meta name="cover" content="titlepage-image"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no">WARNING: no suitable cover or title-page image found.</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="title" mode="metadata">
        <dc:title>
            <xsl:value-of select="."/>
        </dc:title>
    </xsl:template>

    <xsl:template match="author" mode="metadata">
        <dc:creator>
            <xsl:if test="$optionEPubStrict != 'Yes'">
                <xsl:attribute name="opf:role" select="'aut'"/>
                <xsl:attribute name="opf:file-as" select="."/>
            </xsl:if>
            <xsl:value-of select="."/>
        </dc:creator>
    </xsl:template>

    <xsl:template name="translate-contributor-role">
        <xsl:param name="role" select="resp"/>
        <xsl:choose>
            <!-- List taken from OPF Standard, 2.0, section 2.2.6 [http://www.openebook.org/2007/opf/OPF_2.0_final_spec.html],
                 derived from the MARC Code List for Relators  [http://www.loc.gov/marc/relators/relaterm.html] -->
            <xsl:when test="resp='Adapter'">adp</xsl:when>
            <xsl:when test="$role='Annotator'">ann</xsl:when>
            <xsl:when test="$role='Arranger'">arr</xsl:when>
            <xsl:when test="$role='Artist'">art</xsl:when>
            <xsl:when test="$role='Associated name'">asn</xsl:when>
            <xsl:when test="$role='Author'">aut</xsl:when>
            <xsl:when test="$role='Author in text extracts'">aqt</xsl:when>
            <xsl:when test="$role='Author in quotations'">aqt</xsl:when>
            <xsl:when test="$role='Author of afterword'">aft</xsl:when>
            <xsl:when test="$role='Author of postface'">aft</xsl:when>
            <xsl:when test="$role='Author of colophon'">aft</xsl:when>
            <xsl:when test="$role='Author of introduction'">aui</xsl:when>
            <xsl:when test="$role='Author of preface'">aui</xsl:when>
            <xsl:when test="$role='Author of foreword'">aui</xsl:when>
            <xsl:when test="$role='Bibliographic antecedent'">ant</xsl:when>
            <xsl:when test="$role='Book producer'">bkp</xsl:when>
            <xsl:when test="$role='Collaborator'">clb</xsl:when>
            <xsl:when test="$role='Commentator'">cmm</xsl:when>
            <xsl:when test="$role='Designer'">dsr</xsl:when>
            <xsl:when test="$role='Editor'">edt</xsl:when>
            <xsl:when test="$role='Illustrator'">ill</xsl:when>
            <xsl:when test="$role='Lyricist'">lyr</xsl:when>
            <xsl:when test="$role='Metadata contact'">mdc</xsl:when>
            <xsl:when test="$role='Musician'">mus</xsl:when>
            <xsl:when test="$role='Narrator'">nrt</xsl:when>
            <xsl:when test="$role='Other'">oth</xsl:when>
            <xsl:when test="$role='Photographer'">pht</xsl:when>
            <xsl:when test="$role='Printer'">prt</xsl:when>
            <xsl:when test="$role='Redactor'">red</xsl:when>
            <xsl:when test="$role='Reviewer'">rev</xsl:when>
            <xsl:when test="$role='Sponsor'">spn</xsl:when>
            <xsl:when test="$role='Thesis advisor'">ths</xsl:when>
            <xsl:when test="$role='Transcriber'">trc</xsl:when>
            <xsl:when test="$role='Translator'">trl</xsl:when>

            <!-- Related terms that are responsibility instead of role oriented -->
            <xsl:when test="$role='Transcription'">trc</xsl:when>

            <xsl:otherwise>
                <xsl:text>oth</xsl:text>
                <xsl:message terminate="no">WARNING: unknown contributor role: <xsl:value-of select="$role"/>.</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="respStmt" mode="metadata">
        <dc:contributor>
            <xsl:if test="$optionEPubStrict != 'Yes'">
                <xsl:attribute name="opf:role">
                    <xsl:call-template name="translate-contributor-role"/>
                </xsl:attribute>
                <xsl:attribute name="opf:file-as">
                    <xsl:value-of select="name"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="name"/>
        </dc:contributor>
    </xsl:template>

    <xsl:template match="publicationStmt" mode="metadata">
        <dc:publisher>
            <xsl:value-of select="publisher"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="pubPlace"/>
        </dc:publisher>
    </xsl:template>

    <xsl:template match="availability" mode="metadata">
        <dc:rights>
            <xsl:value-of select="."/>
        </dc:rights>
    </xsl:template>


    <!--== metadata3 (for ePub3) ===========================================-->

    <xsl:template name="metadata3">
        <xsl:variable name="epub-id"><xsl:value-of select="teiHeader/fileDesc/publicationStmt/idno[@type = 'epub-id']"/></xsl:variable>

        <dc:identifier id="pub-id"><xsl:value-of select="$epub-id"/></dc:identifier>
        <meta property="dcterms:identifier" id="dcterms-id"><xsl:value-of select="$epub-id"/></meta>
        <!-- <meta about="#pub-id" property="scheme">uuid</meta> --><!-- Removed to silence epubcheck 3.0 -->
        <meta property="dcterms:modified"><xsl:value-of select="f:utc-timestamp()"/></meta>

        <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/title" mode="metadata3"/>
        <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/author" mode="metadata3"/>
        <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/respStmt" mode="metadata3"/>
        <xsl:apply-templates select="teiHeader/fileDesc/publicationStmt" mode="metadata3"/>
        <xsl:apply-templates select="teiHeader/fileDesc/publicationStmt/availability" mode="metadata3"/>

        <xsl:for-each select="teiHeader/profileDesc/textClass/keywords/list/item">
            <meta property="dcterms:subject"><xsl:value-of select="."/></meta>
        </xsl:for-each>

        <xsl:call-template name="metadata-smil"/>
    </xsl:template>

    <xsl:template match="title" mode="metadata3">
        <meta property="dcterms:title"><xsl:value-of select="."/></meta>
    </xsl:template>

    <xsl:template match="author" mode="metadata3">
        <meta property="dcterms:creator"><xsl:value-of select="."/></meta>
    </xsl:template>

    <xsl:template match="respStmt" mode="metadata3">
        <meta property="dcterms:contributor"><xsl:value-of select="name"/></meta>
    </xsl:template>

    <xsl:template match="publicationStmt" mode="metadata3">
        <meta property="dcterms:publisher">
            <xsl:value-of select="publisher"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="pubPlace"/>
        </meta>
    </xsl:template>

    <xsl:template match="availability" mode="metadata3">
        <meta property="dcterms:rights"><xsl:value-of select="."/></meta>
    </xsl:template>


    <xsl:template name="metadata-smil">
        <xsl:if test="//*[contains(@rend, 'media-overlay(')]">
            <!-- Add up the durations for each audio fragment -->
            <xsl:for-each select="//*[contains(@rend, 'media-overlay(')]">
                <xsl:variable name="durations">
                    <xsl:variable name="filename" select="f:rend-value(., 'media-overlay')"/>
                    <xsl:apply-templates select="document($filename, .)" mode="metadata-smil"/>
                </xsl:variable>

                <meta property="media:duration" refines="#{@id}overlay">
                    <xsl:value-of select="f:secondsToTime(sum($durations/*))"/>
                </meta>
            </xsl:for-each>

            <!-- Find total duration -->
            <xsl:variable name="durations">
                <xsl:for-each select="//*[contains(@rend, 'media-overlay(')]">
                    <xsl:variable name="filename" select="f:rend-value(., 'media-overlay')"/>
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

    <xsl:template name="manifest">
        <manifest>
            <item id="ncx"
                 href="{$basename}.ncx"
                 media-type="application/x-dtbncx+xml"/>

            <!-- Store these in a list, from which we remove duplicates later-on -->
            <xsl:variable name="manifest-items">
                <xsl:if test="$optionEPub3 = 'Yes'">
                    <item id="epub3toc"
                         properties="nav"
                         href="{$basename}-nav.xhtml"
                         media-type="application/xhtml+xml"/>
                </xsl:if>

                <!--
                <xsl:if test="//pb">
                    <item id="pagemap"
                        href="pagemap.xml"
                        media-type="application/oebps-page-map+xml"/>
                </xsl:if>
                -->

                <!-- CSS Style Sheets -->
                <item id="css"
                     href="{$basename}.css"
                     media-type="text/css"/>

                <!-- Content Parts -->
                <xsl:apply-templates select="text" mode="manifest"/>

                <!-- Illustrations -->
                <xsl:apply-templates select="//figure" mode="manifest"/>
                <xsl:apply-templates select="//*[contains(@rend, 'image(')]" mode="manifest"/>
                <xsl:apply-templates select="//*[contains(@rend, 'link(')]" mode="manifest-links"/>

                <!-- Media overlays -->
                <xsl:apply-templates select="//*[contains(@rend, 'media-overlay(')]" mode="manifest"/>

                <!-- Include custom items in the manifest -->
                <xsl:if test="$opfManifestFile">
                    <xsl:message terminate="no">INFO:    Reading from "<xsl:value-of select="$opfManifestFile"/>".</xsl:message>
                    <xsl:apply-templates select="document(normalize-space($opfManifestFile))/opf:manifest" mode="copy-manifest"/>
                </xsl:if>
            </xsl:variable>

            <xsl:apply-templates select="$manifest-items" mode="undouble"/>
        </manifest>
    </xsl:template>


    <!--== main divisions ==-->

    <xsl:template match="text" mode="manifest">
        <xsl:apply-templates mode="splitter">
            <xsl:with-param name="action" select="'manifest'"/>
        </xsl:apply-templates>
    </xsl:template>


    <!--== figures ==-->

    <xsl:template match="figure" mode="manifest">
        <xsl:variable name="filename">
            <xsl:choose>
                <xsl:when test="f:has-rend-value(., 'image')">
                    <xsl:value-of select="f:rend-value(., 'image')"/>
                </xsl:when>
                <xsl:otherwise>images/<xsl:value-of select="@id"/>.jpg</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:call-template name="manifest-image-item">
            <xsl:with-param name="filename" select="$filename"/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template match="*" mode="manifest">
        <xsl:if test="f:has-rend-value(., 'image')">
            <xsl:variable name="filename">
                <xsl:value-of select="f:rend-value(., 'image')"/>
            </xsl:variable>

            <xsl:call-template name="manifest-image-item">
                <xsl:with-param name="filename" select="$filename"/>
            </xsl:call-template>
        </xsl:if>

        <xsl:if test="f:has-rend-value(., 'media-overlay')">
            <xsl:variable name="filename">
                <xsl:value-of select="f:rend-value(., 'media-overlay')"/>
            </xsl:variable>
            <xsl:call-template name="manifest-media-overlay-item">
                <xsl:with-param name="filename" select="$filename"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <xsl:template name="manifest-media-overlay-item">
        <xsl:param name="filename" as="xs:string"/>

        <!-- Entry for the .smil file itself. -->
        <item>
            <xsl:attribute name="id"><xsl:call-template name="generate-id"/>overlay</xsl:attribute>
            <xsl:attribute name="href"><xsl:value-of select="$filename"/></xsl:attribute>
            <xsl:attribute name="media-type">application/smil+xml</xsl:attribute>
        </item>

        <!-- Handle the .smil file itself for further entries -->
        <xsl:message terminate="no">INFO:    Reading from "<xsl:value-of select="$filename"/>".</xsl:message>
        <xsl:apply-templates mode="manifest-smil" select="document($filename, .)"/>
    </xsl:template>


    <xsl:template match="smil:audio[@src]" mode="manifest-smil">
        <xsl:variable name="basename"><xsl:value-of select="replace(@src, '\.mp3$', '')"/></xsl:variable>
        <xsl:variable name="id"><xsl:call-template name="generate-id"/></xsl:variable>

        <!--
        <xsl:message terminate="no">INFO:    adding audio: '<xsl:value-of select="@src"/>' duration: <xsl:value-of select="$duration"/>.</xsl:message>
        -->

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

    <!-- Enable access to the initial TEI file while handling the .smil file -->
    <xsl:variable name="teiFile" select="/"/>

    <xsl:template match="smil:text[@src]" mode="manifest-smil">
        <xsl:variable name="basename"><xsl:value-of select="replace(@src, '\.xhtml.*$', '')"/></xsl:variable>
        <xsl:variable name="fragmentid"><xsl:value-of select="replace(@src, '^.*\.xhtml#', '')"/></xsl:variable>

        <xsl:if test="not($teiFile//*[@id=$fragmentid])">
            <xsl:message terminate="no">WARNING: fragment id: '<xsl:value-of select="$fragmentid"/>' not present in text.</xsl:message>
        </xsl:if>
    </xsl:template>


    <xsl:function name="f:timeToSeconds" as="xs:double">
        <xsl:param name="time" as="xs:string"/>

        <!-- 00:00:00.000 -->
        <xsl:analyze-string select="$time" regex="^([0-9]+):([0-9]+):([0-9]+(\.[0-9]+)?)$">
            <xsl:matching-substring>
                <xsl:value-of select="number(regex-group(1)) * 3600 + number(regex-group(2)) * 60 + number(regex-group(3))"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:message terminate="no">WARNING: time: '<xsl:value-of select="$time"/>' not recognized.</xsl:message>
                <xsl:text>0</xsl:text>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>


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


    <xsl:template match="*" mode="manifest-links">
        <xsl:if test="f:has-rend-value(., 'link')">
            <xsl:variable name="filename">
                <xsl:value-of select="f:rend-value(., 'link')"/>
            </xsl:variable>

            <xsl:if test="matches($filename, '^[^:]+\.(jpg|png|gif|svg)$')">
                <xsl:call-template name="manifest-image-item">
                    <xsl:with-param name="filename" select="$filename"/>
                    <xsl:with-param name="how" select="'link'"/>
                </xsl:call-template>
                <!-- Also include wrapper HTML -->
                <item>
                    <xsl:attribute name="id"><xsl:call-template name="generate-id"/>wrapper</xsl:attribute>
                    <xsl:attribute name="href"><xsl:value-of select="$basename"/>-<xsl:call-template name="generate-id"/>.xhtml</xsl:attribute>
                    <xsl:attribute name="media-type">application/xhtml+xml</xsl:attribute>
                </item>
            </xsl:if>
        </xsl:if>
    </xsl:template>


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
            <xsl:if test="@id='cover-image'">
                <xsl:attribute name="properties">cover-image</xsl:attribute>
            </xsl:if>
            <xsl:attribute name="id"><xsl:call-template name="generate-id"/><xsl:value-of select="$how"/></xsl:attribute>
            <xsl:attribute name="href"><xsl:value-of select="$filename"/></xsl:attribute>
            <xsl:attribute name="media-type"><xsl:value-of select="$mimetype"/></xsl:attribute>
        </item>

    </xsl:template>


    <!-- Remove duplicated resources from the list (included because the ePub uses
         them more than once). -->
    <xsl:template match="opf:item" mode="undouble">
        <xsl:variable name="href" select="@href"/>
        <xsl:if test="not(preceding-sibling::opf:item[@href = $href])">
            <xsl:copy-of select="."/>
        </xsl:if>
    </xsl:template>

    <!-- Copy items from an included manifest-snippet -->

    <xsl:template match="opf:item" mode="copy-manifest">
        <xsl:copy-of select="."/>
    </xsl:template>

    <!--== spine ===========================================================-->

    <xsl:template name="spine">
        <spine toc="ncx">
            <!--
            <xsl:if test="//pb">
                <xsl:attribute name="page-map">pagemap</xsl:attribute>
            </xsl:if>
            -->

            <!-- make sure the cover comes first in the spine -->
            <xsl:if test="//div1[@id='cover']">
                <itemref xmlns="http://www.idpf.org/2007/opf" linear="no" idref="cover"/>
            </xsl:if>

            <xsl:apply-templates select="text" mode="spine"/>
        </spine>
    </xsl:template>


    <xsl:template match="text" mode="spine">
        <xsl:apply-templates mode="splitter">
            <xsl:with-param name="action" select="'spine'"/>
        </xsl:apply-templates>
    </xsl:template>

    <!--== guides ==========================================================-->

    <xsl:template name="get-cover-image">
        <xsl:variable name="figure" select="(if (//figure[@id = 'cover-image']) then //figure[@id = 'cover-image'] else //figure[@id = 'titlepage-image'])[1]"/>
        <xsl:choose>
            <xsl:when test="contains(/TEI.2/text/@rend, 'cover-image(')">
                <xsl:value-of select="substring-before(substring-after(/TEI.2/text/@rend, 'cover-image('), ')')"/>
            </xsl:when>
            <xsl:when test="contains($figure/@rend, 'image(')">
                <xsl:value-of select="substring-before(substring-after($figure/@rend, 'image('), ')')"/>
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
                        <xsl:call-template name="generate-filename-for">
                            <xsl:with-param name="node" select="key('id', 'cover')[1]"/>
                        </xsl:call-template>
                   </xsl:attribute>
                </reference>
            </xsl:if>

            <xsl:if test="$optionEPubStrict != 'Yes'">
                <!-- Name hinted by Mobipocket creator for use when ePub is converted to Mobi format -->
                <xsl:if test="//figure[@id = 'cover-image' or @id = 'titlepage-image']">
                    <reference type="other.ms-coverimage" title="{f:message('msgCoverImage')}">
                        <xsl:attribute name="href">
                            <xsl:call-template name="get-cover-image"/>
                        </xsl:attribute>
                    </reference>
                </xsl:if>
            </xsl:if>

            <xsl:if test="key('id', 'toc')">
                <reference type="toc" title="{f:message('msgTableOfContents')}">
                    <xsl:call-template name="generate-href-attribute">
                        <xsl:with-param name="target" select="key('id', 'toc')[1]"/>
                    </xsl:call-template>
                </reference>
            </xsl:if>

            <xsl:if test="key('id', 'loi')">
                <reference type="loi" title="{f:message('msgListOfIllustrations')}">
                    <xsl:call-template name="generate-href-attribute">
                        <xsl:with-param name="target" select="key('id', 'loi')[1]"/>
                    </xsl:call-template>
                </reference>
            </xsl:if>

            <xsl:if test="key('id', 'lot')">
                <reference type="lot" title="{f:message('msgListOfTables')}">
                    <xsl:call-template name="generate-href-attribute">
                        <xsl:with-param name="target" select="key('id', 'lot')[1]"/>
                    </xsl:call-template>
                </reference>
            </xsl:if>

            <xsl:if test="/TEI.2/text/front/titlePage">
                <reference type="title-page" title="{f:message('msgTitlePage')}">
                    <xsl:call-template name="generate-href-attribute">
                        <xsl:with-param name="target" select="/TEI.2/text/front/titlePage[1]"/>
                    </xsl:call-template>
                </reference>
            </xsl:if>

            <xsl:if test="//div1[@type='Dedication']">
                <reference type="dedication" title="{f:message('msgDedication')}">
                    <xsl:call-template name="generate-href-attribute">
                        <xsl:with-param name="target" select="(//div1[@type='Dedication'])[1]"/>
                    </xsl:call-template>
                </reference>
            </xsl:if>

            <xsl:if test="//div1[@type='Acknowledgements']">
                <reference type="acknowledgements" title="{f:message('msgAcknowledgements')}">
                    <xsl:call-template name="generate-href-attribute">
                        <xsl:with-param name="target" select="(//div1[@type='Acknowledgements'])[1]"/>
                    </xsl:call-template>
                </reference>
            </xsl:if>

            <xsl:if test="//div1[@type='Epigraph']">
                <reference type="epigraph" title="{f:message('msgEpigraph')}">
                    <xsl:call-template name="generate-href-attribute">
                        <xsl:with-param name="target" select="(//div1[@type='Epigraph'])[1]"/>
                    </xsl:call-template>
                </reference>
            </xsl:if>

            <xsl:if test="//div1[@type='Index']">
                <reference type="index" title="{f:message('msgIndex')}">
                    <xsl:call-template name="generate-href-attribute">
                        <xsl:with-param name="target" select="(//div1[@type='Index'])[1]"/>
                    </xsl:call-template>
                </reference>
            </xsl:if>

            <xsl:if test="//div1[@type='Bibliography']">
                <reference type="bibliography" title="{f:message('msgBibliography')}">
                    <xsl:call-template name="generate-href-attribute">
                        <xsl:with-param name="target" select="(//div1[@type='Bibliography'])[1]"/>
                    </xsl:call-template>
                </reference>
            </xsl:if>

            <xsl:if test="//div1[@type='Copyright']">
                <reference type="copyright-page" title="{f:message('msgCopyrightPage')}">
                    <xsl:call-template name="generate-href-attribute">
                        <xsl:with-param name="target" select="(//div1[@type='Copyright'])[1]"/>
                    </xsl:call-template>
                </reference>
            </xsl:if>

            <xsl:if test="//div1[@type='Glossary']">
                <reference type="glossary" title="{f:message('msgGlossary')}">
                    <xsl:call-template name="generate-href-attribute">
                        <xsl:with-param name="target" select="(//div1[@type='Glossary'])[1]"/>
                    </xsl:call-template>
                </reference>
            </xsl:if>

            <xsl:if test="//div1[@type='Preface']">
                <reference type="preface" title="{f:message('msgPreface')}">
                    <xsl:call-template name="generate-href-attribute">
                        <xsl:with-param name="target" select="(//div1[@type='Preface'])[1]"/>
                    </xsl:call-template>
                </reference>
            </xsl:if>

            <xsl:if test="/TEI.2/text/body/div0|/TEI.2/text/body/div1">
                <reference type="text" title="{f:message('msgText')}">
                    <xsl:call-template name="generate-href-attribute">
                        <xsl:with-param name="target" select="(/TEI.2/text/body/div0|/TEI.2/text/body/div1)[1]"/>
                    </xsl:call-template>
                </reference>
            </xsl:if>

            <xsl:if test="//divGen[@type='Colophon']">
                <reference type="colophon" title="{f:message('msgColophon')}">
                    <xsl:call-template name="generate-href-attribute">
                        <xsl:with-param name="target" select="(//divGen[@type='Colophon'])[1]"/>
                    </xsl:call-template>
                </reference>
            </xsl:if>

        </guide>

    </xsl:template>


    <!--== forget about all the rest =======================================-->

    <xsl:template match="*" mode="opf"/>

</xsl:stylesheet>
