<!DOCTYPE xsl:stylesheet [

    <!ENTITY rsquo      "&#x2019;">

]><xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:tmp="urn:temporary-nodes"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f tmp map xd xhtml xs">

    <xd:doc type="stylesheet">
        <xd:short>Functions to handle cross-references.</xd:short>
        <xd:detail>This stylesheet contains a number of functions to handle cross-references.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2018, Jeroen Hellingman</xd:copyright>
    </xd:doc>


    <xd:doc>
        <xd:short>Translate a URL to an HTML class.</xd:short>
        <xd:detail>
            <p>Translate a URL to an HTML class, so URL dependent styling can be applied. See the documentation for <code>f:translate-xref-url</code>
            for short-hand url notations supported.</p>
        </xd:detail>
        <xd:param name="url" type="string">The URL to be translated.</xd:param>
    </xd:doc>

    <xsl:function name="f:translate-xref-class" as="xs:string">
        <xsl:param name="url" as="xs:string"/>

        <xsl:variable name="linkClasses" select="map{
            'bib':    'biblink',
            'ftp':    'ftplink',
            'https':  'seclink',
            'loc':    'loclink',
            'mailto': 'maillink',
            'oclc':   'catlink',
            'oln':    'catlink',
            'olw':    'catlink',
            'lccn':   'catlink',
            'pg':     'pglink',
            'pgi':    'pgilink',
            'qur':    'qurlink',
            'wp':     'wplink'
            }"/>

        <xsl:variable name="protocol" select="if (contains($url, ':')) then substring-before($url, ':') else ''"/>
        <xsl:choose>
            <xsl:when test="$linkClasses($protocol)"><xsl:value-of select="$linkClasses($protocol)"/></xsl:when>
            <xsl:when test="starts-with($url, 'audio/')">audiolink</xsl:when>
            <xsl:otherwise>exlink</xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xd:doc>
        <xd:short>Translate a URL to an HTML title attribute.</xd:short>
        <xd:detail>
            <p>Translate a URL to an HTML title attribute. See the documentation for <code>f:translate-xref-url</code>
            for short-hand url notations supported. Note that these titles will be localized in the main document language.</p>
        </xd:detail>
        <xd:param name="url" type="string">The URL to be translated.</xd:param>
    </xd:doc>

    <xsl:function name="f:translate-xref-title" as="xs:string" expand-text="yes">
        <xsl:param name="url" as="xs:string"/>

        <xsl:choose>
            <xsl:when test="starts-with($url, 'pg:')">{f:message('msgLinkToPg')}</xsl:when>
            <xsl:when test="starts-with($url, 'pgi:')">{f:message('msgLinkToPg')}</xsl:when>
            <xsl:when test="starts-with($url, 'oclc:')">{f:message('msgLinkToWorldCat')}</xsl:when>
            <xsl:when test="starts-with($url, 'oln:')">{f:message('msgLinkToOpenLibrary')}</xsl:when>
            <xsl:when test="starts-with($url, 'olw:')">{f:message('msgLinkToOpenLibrary')}</xsl:when>
            <xsl:when test="starts-with($url, 'lccn:')">{f:message('msgLinkToLibraryOfCongress')}</xsl:when>
            <xsl:when test="starts-with($url, 'wp:')">{f:message('msgLinkToWikipedia')}</xsl:when>
            <xsl:when test="starts-with($url, 'loc:')">{f:message('msgLinkToMap')}</xsl:when>
            <xsl:when test="starts-with($url, 'bib:')">{f:title-for-bible-link($url)}</xsl:when>
            <xsl:when test="starts-with($url, 'qur:')">{f:title-for-quran-link($url)}</xsl:when>
            <xsl:when test="starts-with($url, 'tia:')">{f:message('msgLinkToInternetArchive')}</xsl:when>
            <xsl:when test="starts-with($url, 'mailto:')">{f:message('msgEmailLink')}</xsl:when>
            <xsl:when test="starts-with($url, 'ftp:')">{f:message('msgFtpLink')}</xsl:when>

            <xsl:when test="starts-with($url, 'audio/')">
                <xsl:choose>
                    <xsl:when test="ends-with($url, '.mid') or ends-with($url, '.midi')">{f:message('msgLinkToMidiFile')}</xsl:when>
                    <xsl:when test="ends-with($url, '.mp3')">{f:message('msgLinkToMp3File')}</xsl:when>
                    <xsl:when test="ends-with($url, '.ly')">{f:message('msgLinkToLilypondFile')}</xsl:when>
                    <xsl:when test="ends-with($url, '.mscz')">{f:message('msgLinkToMuseScoreFile')}</xsl:when>
                    <xsl:otherwise>{f:message('msgAudioLink')}</xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>{f:message('msgExternalLink')}</xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xsl:variable name="prefixDefs" select="//listPrefixDef/prefixDef" as="element(prefixDef)*"/>


    <xd:doc>
        <xd:short>Translate a URL to an HTML href attribute.</xd:short>
        <xd:detail>
            <p>Translate a URL to a URL that can be used in a HTML href attribute.</p>

            <p>The following short-hand notations are supported:</p>

            <table>
                <tr><th>Shorthand notation</th>                 <th>Description</th></tr>
                <tr><td>pg:<i>[number]</i></td>                 <td>Link to a Project Gutenberg ebook.</td></tr>
                <tr><td>pgi:<i>[number]</i></td>                <td>Link to a Project Gutenberg ebook (internal, for example between multi-volume sets).</td></tr>
                <tr><td>oclc:<i>[id]</i></td>                   <td>Link to an OCLC (WorldCat) catalog entry.</td></tr>
                <tr><td>oln:<i>[id]</i></td>                    <td>Link to an Open Library catalog entry (at the item level).</td></tr>
                <tr><td>olw:<i>[id]</i></td>                    <td>Link to an Open Library catalog entry (at the abstract work level).</td></tr>
                <tr><td>lccn:<i>[id]</i></td>                   <td>Link to an Library of Congress catalog entry.</td></tr>
                <tr><td>wp:<i>[string]</i></td>                 <td>Link to a Wikipedia article.</td></tr>
                <tr><td>tia:<i>[string]</i></td>                <td>Link to an Internet Archive item.</td></tr>
                <tr><td>loc:<i>[coordinates]</i></td>           <td>Link to a geographical location (currently uses Google Maps).</td></tr>
                <tr><td>bib:<i>[book ch:vs@version]</i></td>    <td>Link to a verse in the Bible (currently uses the Bible gateway, selects the language of the main text, if available).</td></tr>
                <tr><td>qur:<i>[surah.verse]</i></td>           <td>Link to a verse in the Quran (currently uses quranwow.com).</td></tr>
                <tr><td>mailto:<i>[email address]</i></td>      <td>Link to an email address.</td></tr>
            </table>

            <p>In addition to these defaults, the patterns defined in the <code>//listPrefixDef/prefixDef</code> will be handled here.</p>

        </xd:detail>
        <xd:param name="url" type="string">The URL to be translated.</xd:param>
        <xd:param name="lang" type="string">The language of the resource to link to (if applicable).</xd:param>
    </xd:doc>


    <xsl:function name="f:translate-xref-url">
        <xsl:param name="url" as="xs:string"/>
        <xsl:param name="lang" as="xs:string"/>

        <xsl:choose>

            <!-- Link to Project Gutenberg book -->
            <xsl:when test="starts-with($url, 'pg:') or starts-with($url, 'pgi:')">
                <xsl:value-of select="f:translate-project-gutenberg-url($url)"/>
            </xsl:when>

            <!-- Link to OCLC (worldcat) catalog entry -->
            <xsl:when test="starts-with($url, 'oclc:')">
                <xsl:text>https://www.worldcat.org/oclc/</xsl:text><xsl:value-of select="substring-after($url, ':')"/>
            </xsl:when>

            <!-- Link to Open Library catalog entry (item level) -->
            <xsl:when test="starts-with($url, 'oln:')">
                <xsl:text>https://openlibrary.org/books/</xsl:text><xsl:value-of select="substring-after($url, ':')"/>
            </xsl:when>

            <!-- Link to Open Library catalog entry (abstract work level) -->
            <xsl:when test="starts-with($url, 'olw:')">
                <xsl:text>https://openlibrary.org/work/</xsl:text><xsl:value-of select="substring-after($url, ':')"/>
            </xsl:when>

            <!-- Link to Library of Congress catalog entry -->
            <xsl:when test="starts-with($url, 'lccn:')">
                <xsl:text>https://lccn.loc.gov/</xsl:text><xsl:value-of select="substring-after($url, ':')"/>
            </xsl:when>

            <!-- Link to Wikipedia article -->
            <xsl:when test="starts-with($url, 'wp:')">
                <xsl:text>https://</xsl:text><xsl:value-of select="substring($lang, 1, 2)"/><xsl:text>.wikipedia.org/wiki/</xsl:text><xsl:value-of select="substring-after($url, ':')"/>
            </xsl:when>

            <!-- Link to The Internet Archive -->
            <xsl:when test="starts-with($url, 'tia:')">
                <xsl:text>https://archive.org/details/</xsl:text><xsl:value-of select="substring-after($url, ':')"/>
            </xsl:when>

            <!-- Link to location on map, using coordinates -->
            <xsl:when test="starts-with($url, 'loc:')">
                <xsl:variable name="coordinates" select="substring-after($url, ':')"/>
                <xsl:variable name="latitude" select="substring-before($coordinates, ',')"/>
                <xsl:variable name="altitude" select="substring-after($coordinates, ',')"/>
                <xsl:text>https://maps.google.com/maps?q=</xsl:text><xsl:value-of select="$latitude"/>,<xsl:value-of select="$altitude"/>
            </xsl:when>

            <!-- Link to Bible citation -->
            <xsl:when test="starts-with($url, 'bib:')">
                <xsl:value-of select="f:url-for-bible-link($url, $lang)"/>
            </xsl:when>

            <!-- Link to Quran citation -->
            <xsl:when test="starts-with($url, 'qur:')">
                <xsl:value-of select="f:url-for-quran-link($url)"/>
            </xsl:when>

            <!-- Link to secure website (or https://) -->
            <xsl:when test="starts-with($url, 'https:')">
                <xsl:value-of select="$url"/>
            </xsl:when>

            <!-- Link to non-secure website (http://) -->
            <xsl:when test="starts-with($url, 'http:') or starts-with($url, 'https:') or starts-with($url, 'mailto:')">
                <xsl:copy-of select="f:log-warning('Link to non-secure HTTP website ({1}).', ($url))"/>
                <xsl:value-of select="$url"/>
            </xsl:when>

            <!-- Link to email address (mailto:) -->
            <xsl:when test="starts-with($url, 'mailto:')">
                <xsl:value-of select="$url"/>
            </xsl:when>

            <!-- Link to FTP server (ftp:) -->
            <xsl:when test="starts-with($url, 'ftp:')">
                <xsl:value-of select="$url"/>
            </xsl:when>

            <!-- Internal link to audio file -->
            <xsl:when test="starts-with($url, 'audio/')">
                <xsl:value-of select="$url"/>
            </xsl:when>

            <!-- Expand prefixes defined in //listPrefixDef/prefixDef -->
            <xsl:when test="substring-before($url, ':') = $prefixDefs/@ident">
                <xsl:value-of select="f:apply-prefix-def($url, $prefixDefs[@ident = substring-before($url, ':')][1])"/>
            </xsl:when>

            <!-- Link is a relative path -->
            <xsl:when test="not(contains($url, ':'))">
                <xsl:value-of select="$url"/>
            </xsl:when>

            <xsl:otherwise>
                <xsl:copy-of select="f:log-warning('URL &quot;{1}&quot; not understood.', ($url))"/>
                <xsl:value-of select="$url"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xd:doc>
        <xd:short>Apply a prefixDef to a short url.</xd:short>
        <xd:detail>
            <p>Apply a prefixDef to a short url. This directly feeds the match pattern and replacement pattern into
            the XSLT function, so may lead to a run-time error if those values in the document are not valid.</p>
        </xd:detail>
        <xd:param name="url" type="string">The URL to be expanded.</xd:param>
        <xd:param name="prefixDef" type="element(prefixDef)">The applicable prefixDef element.</xd:param>
    </xd:doc>

    <xsl:function name="f:apply-prefix-def" as="xs:string">
        <xsl:param name="url" as="xs:string"/>
        <xsl:param name="prefixDef" as="element(prefixDef)"/>
        <xsl:variable name="locator" select="substring-after($url, ':')" as="xs:string"/>

        <xsl:copy-of select="f:log-debug('URL {1}; pattern: {2}; replacement: {3}.', ($url, $prefixDef/@matchPattern, $prefixDef/@replacementPattern))"/>

        <xsl:value-of select="replace($locator, $prefixDef/@matchPattern, $prefixDef/@replacementPattern)"/>
    </xsl:function>


    <xsl:function name="f:translate-project-gutenberg-url" as="xs:string">
        <xsl:param name="url" as="xs:string"/>

        <xsl:choose>
            <xsl:when test="contains($url, '#')">
                <xsl:variable name="number" select="substring-before(substring-after($url, ':'), '#')"/>
                <xsl:variable name="anchor" select="substring-after($url, '#')"/>
                <xsl:value-of select="'https://www.gutenberg.org/files/' || $number || '/' || $number || '-h/' || $number || '-h.htm#' || $anchor"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text expand-text="yes">https://www.gutenberg.org/ebooks/{substring-after($url, ':')}</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <!-- References to the plays of Shakespeare have the following format:
            'shaks:'<play> <act>('.'<scene>('.'<line>)?)?('@'<edition>)?

         (See https://internetshakespeare.uvic.ca/Foyer/guidelines/abbreviations/)
    -->

    <xsl:variable name="playsShakespeare" select="map{
        '1H4'   : 'The First Part of King Henry the Fourth',
        '1H6'   : 'The First Part of King Henry the Sixth',
        '2H4'   : 'The Second Part of King Henry the Fourth',
        '2H6'   : 'The Second Part of King Henry the Sixth',
        '3H6'   : 'The Third Part of King Henry the Sixth',
        'Ado'   : 'Much Ado About Nothing',
        'Ant'   : 'Antony and Cleopatra',
        'AWW'   : 'All&rsquo;s Well That Ends Well',
        'AYL'   : 'As You Like It',
        'Cor'   : 'Coriolanus',
        'Cym'   : 'Cymbeline',
        'Edw'   : 'Edward III',
        'Err'   : 'The Comedy of Errors',
        'H5'    : 'King Henry the Fifth',
        'H8'    : 'King Henry the Eighth',
        'Ham'   : 'Hamlet',
        'JC'    : 'Julius Caesar',
        'Jn'    : 'King John',
        'LC'    : 'A Lover&rsquo;s Complaint',
        'LLL'   : 'Love&rsquo;s Labour&rsquo;s Lost',
        'Lr'    : 'King Lear',
        'Luc'   : 'The Rape of Lucrece',
        'Mac'   : 'Macbeth',
        'MM'    : 'Measure for Measure',
        'MND'   : 'A Midsummer Night&rsquo;s Dream',
        'MV'    : 'The Merchant of Venice',
        'Oth'   : 'Othello',
        'Per'   : 'Pericles',
        'PhT'   : 'The Phoenix and Turtle',
        'PP'    : 'The Passionate Pilgrim',
        'R2'    : 'King Richard the Second',
        'R3'    : 'King Richard the Third',
        'Rom'   : 'Romeo and Juliet',
        'Shr'   : 'The Taming of the Shrew',
        'Son'   : 'Sonnets',
        'STM'   : 'Sir Thomas More',
        'TGV'   : 'The Two Gentlemen of Verona',
        'Tim'   : 'Timon of Athens',
        'Tit'   : 'Titus Andronicus',
        'Tmp'   : 'The Tempest',
        'TN'    : 'Twelfth Night',
        'TNK'   : 'The Two Noble Kinsmen',
        'Tro'   : 'Troilus and Cressida',
        'Ven'   : 'Venus and Adonis',
        'Wiv'   : 'The Merry Wives of Windsor',
        'WT'    : 'The Winter&rsquo;s Tale'
        }"/>

    <xsl:variable name="editionsShakespeare" select="map{
        'F1'    : 'First Folio ed. (1623)',
        'F2'    : 'Second Folio ed. (1632)',
        'Q'     : 'Quarto ed.'
        }"/>

    <!-- Bible references have the following formats:
            'bib:'<book> <chapter>(':'<verse>('-'<verse>)?)?('@'<edition>)?
            'bib:'<book> <chapter>'-'<chapter>('@'<edition>)?
            'bib:'<book> <chapter>':'<verse>'-'<chapter>':'<verse>('@'<edition>)?
    -->

    <xsl:variable name="bibleRefPattern" select="'^bib:((?:[0-3] )?[A-Za-z]+)(?: ([0-9]+)(?:[:]([0-9]+)(?:[-]([0-9]+))?)?)?(?:[@]([A-Za-z0-9;]+))?$'"/>
    <xsl:variable name="bibleRefChapterRangePattern" select="'^bib:((?:[0-3] )?[A-Za-z]+) ([0-9]+)[-]([0-9]+)(?:[@]([A-Za-z0-9;]+))?$'"/>
    <xsl:variable name="bibleRefChapterVerseRangePattern" select="'^bib:((?:[0-3] )?[A-Za-z]+) ([0-9]+)[:]([0-9]+)[-]([0-9]+)[:]([0-9]+)(?:[@]([A-Za-z0-9;]+))?$'"/>

    <xsl:variable name="bibleBooks" select="map{
        'gn'     : 'Genesis',
        'ex'     : 'Exodus',
        'lv'     : 'Leviticus',
        'nm'     : 'Numbers',
        'dt'     : 'Deuteronomy',
        'jo'     : 'Joshua',
        'jdg'    : 'Judges',
        'ru'     : 'Ruth',
        '1 sm'   : '1 Samuel',
        '2 sm'   : '2 Samuel',
        '1 kgs'  : '1 Kings',
        '2 kgs'  : '2 Kings',
        '1 chr'  : '1 Chronicles',
        '2 chr'  : '2 Chronicles',
        'ezr'    : 'Ezra',
        'neh'    : 'Nehemiah',
        'est'    : 'Esther',
        'jb'     : 'Job',
        'ps'     : 'Psalm',
        'prv'    : 'Proverbs',
        'eccl'   : 'Ecclesiastes',
        'song'   : 'Song of Solomon',
        'is'     : 'Isaiah',
        'jer'    : 'Jeremiah',
        'lam'    : 'Lamentations',
        'ez'     : 'Ezekiel',
        'dn'     : 'Daniel',
        'hos'    : 'Hosea',
        'jl'     : 'Joel',
        'am'     : 'Amos',
        'ob'     : 'Obadiah',
        'jon'    : 'Jonah',
        'mi'     : 'Micah',
        'na'     : 'Nahum',
        'hb'     : 'Habakkuk',
        'zep'    : 'Zephaniah',
        'hg'     : 'Haggai',
        'zec'    : 'Zechariah',
        'mal'    : 'Malachi',

        'bar'    : 'Baruch',
        'sir'    : 'Ecclesiasticus',
        '1 esd'  : '1 Esdras',
        '2 esd'  : '2 Esdras',
        'jdt'    : 'Judith',
        '1 mc'   : '1 Maccabees',
        '2 mc'   : '2 Maccabees',
        'man'    : 'Manasseh',
        'sus'    : 'Susanna',
        'tb'     : 'Tobit',
        'ws'     : 'Wisdom of Solomon',

        'mt'     : 'Matthew',
        'mk'     : 'Mark',
        'lk'     : 'Luke',
        'jn'     : 'John',
        'acts'   : 'Acts of the Apostles',
        'rom'    : 'Romans',
        '1 cor'  : '1 Corinthians',
        '2 cor'  : '2 Corinthians',
        'gal'    : 'Galatians',
        'eph'    : 'Ephesians',
        'phil'   : 'Philippians',
        'col'    : 'Colossians',
        '1 thes' : '1 Thessalonians',
        '2 thes' : '2 Thessalonians',
        '1 tm'   : '1 Timothy',
        '2 tm'   : '2 Timothy',
        'ti'     : 'Titus',
        'phlm'   : 'Philemon',
        'heb'    : 'Hebrews',
        'jas'    : 'James',
        '1 pt'   : '1 Peter',
        '2 pt'   : '2 Peter',
        '1 jn'   : '1 John',
        '2 jn'   : '2 John',
        '3 jn'   : '3 John',
        'jude'   : 'Jude',
        're'     : 'Revelation'
        }"/>

    <xsl:variable name="bibleTranslations" select="map{
        'en': 'NRSV',
        'fr': 'LSG',
        'de': 'LUTH1545',
        'es': 'RVR1995',
        'nl': 'HTB',
        'la': 'VULGATE'
        }"/>


    <xsl:function name="f:validate-bible-link" as="xs:boolean">
        <xsl:param name="url" as="xs:string"/>
        <xsl:sequence select="matches($url, $bibleRefPattern)
                              or matches($url, $bibleRefChapterRangePattern)
                              or matches($url, $bibleRefChapterVerseRangePattern)"/>
    </xsl:function>


    <xsl:function name="f:tokenize-bible-ref" as="map(xs:string, xs:string?)">
        <xsl:param name="url" as="xs:string"/>

        <xsl:choose>
            <xsl:when test="matches($url, $bibleRefPattern)">
                <xsl:sequence select="f:tokenize-common-bible-ref($url)"/>
            </xsl:when>
            <xsl:when test="matches($url, $bibleRefChapterRangePattern)">
                <xsl:sequence select="f:tokenize-bible-ref-chapter-range($url)"/>
            </xsl:when>
            <xsl:when test="matches($url, $bibleRefChapterVerseRangePattern)">
                <xsl:sequence select="f:tokenize-bible-ref-chapter-verse-range($url)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="map{}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xsl:function name="f:localize-bible-book-title" as="xs:string">
        <xsl:param name="url" as="xs:string"/>
        <xsl:param name="book" as="xs:string?"/>

        <xsl:variable name="messageId" select="'bible.' || $bibleBooks(lower-case($book))"/>
        <xsl:if test="not($bibleBooks(lower-case($book)))">
            <xsl:message expand-text="yes">{f:log-error('Unknown Bible book &quot;{2}&quot; in reference &quot;{1}&quot;', ($url, $book))}</xsl:message>
        </xsl:if>

        <xsl:sequence select="if (f:is-message-available($messageId)) then f:message($messageId) else f:message('msgUnknownBibleBook')"/>
    </xsl:function>


    <xsl:function name="f:tokenize-common-bible-ref" as="map(xs:string, xs:string?)">
        <xsl:param name="url" as="xs:string"/>
        <xsl:variable name="parts" select="tokenize(replace($url, $bibleRefPattern, '$1,$2,$3,$4,$5'), ',')"/>

        <xsl:map>
            <xsl:map-entry key="'book'" select="$parts[1]"/>
            <xsl:map-entry key="'chapter'" select="$parts[2]"/>
            <xsl:map-entry key="'verse'" select="$parts[3]"/>
            <xsl:map-entry key="'toVerse'" select="$parts[4]"/>
            <xsl:map-entry key="'edition'" select="$parts[5]"/>
            <xsl:map-entry key="'bookTitle'" select="f:localize-bible-book-title($url, $parts[1])"/>
        </xsl:map>
    </xsl:function>

    <xsl:function name="f:tokenize-bible-ref-chapter-range" as="map(xs:string, xs:string?)">
        <xsl:param name="url" as="xs:string"/>
        <xsl:variable name="parts" select="tokenize(replace($url, $bibleRefChapterRangePattern, '$1,$2,$3,$4'), ',')"/>

        <xsl:map>
            <xsl:map-entry key="'book'" select="$parts[1]"/>
            <xsl:map-entry key="'chapter'" select="$parts[2]"/>
            <xsl:map-entry key="'toChapter'" select="$parts[3]"/>
            <xsl:map-entry key="'edition'" select="$parts[4]"/>
            <xsl:map-entry key="'bookTitle'" select="f:localize-bible-book-title($url, $parts[1])"/>
        </xsl:map>
    </xsl:function>

    <xsl:function name="f:tokenize-bible-ref-chapter-verse-range" as="map(xs:string, xs:string?)">
        <xsl:param name="url" as="xs:string"/>
        <xsl:variable name="parts" select="tokenize(replace($url, $bibleRefChapterVerseRangePattern, '$1,$2,$3,$4,$5,6'), ',')"/>

        <xsl:map>
            <xsl:map-entry key="'book'" select="$parts[1]"/>
            <xsl:map-entry key="'chapter'" select="$parts[2]"/>
            <xsl:map-entry key="'verse'" select="$parts[3]"/>
            <xsl:map-entry key="'toChapter'" select="$parts[4]"/>
            <xsl:map-entry key="'toVerse'" select="$parts[5]"/>
            <xsl:map-entry key="'edition'" select="$parts[6]"/>
            <xsl:map-entry key="'bookTitle'" select="f:localize-bible-book-title($url, $parts[1])"/>
        </xsl:map>
    </xsl:function>

    <xsl:function name="f:title-for-bible-link" as="xs:string">
        <xsl:param name="url" as="xs:string"/>

        <xsl:variable name="parts" select="f:tokenize-bible-ref($url)" as="map(xs:string, xs:string?)"/>

        <xsl:variable name="messageTemplate" select="
            if ($parts('chapter') and $parts('toChapter') and $parts('verse') and $parts('toVerse'))
            then 'msgLinkToBibleBookChapterVerseToChapterVerse'
            else if ($parts('chapter') and $parts('toChapter'))
                 then 'msgLinkToBibleBookChapterToChapter'
                 else if ($parts('chapter') and $parts('verse') and $parts('toVerse'))
                      then 'msgLinkToBibleBookChapterVerseToVerse'
                      else if ($parts('chapter') and $parts('verse'))
                           then 'msgLinkToBibleBookChapterVerse'
                           else if ($parts('chapter'))
                                then 'msgLinkToBibleBookChapter'
                                else 'msgLinkToBibleBook'"/>

        <xsl:value-of select="f:format-message($messageTemplate, $parts)"/>
    </xsl:function>


    <xsl:function name="f:url-for-bible-link" as="xs:string">
        <xsl:param name="url" as="xs:string"/>
        <xsl:param name="lang" as="xs:string"/>

        <xsl:if test="not(f:validate-bible-link($url))">
            <xsl:message expand-text="yes">{f:log-error('Unrecognized reference to Bible: {1}.', ($url))}</xsl:message>
        </xsl:if>

        <xsl:variable name="parts" select="f:tokenize-bible-ref($url)" as="map(xs:string, xs:string?)"/>

        <xsl:variable name="edition" select="if ($parts('edition')) then ($parts('edition')) else $bibleTranslations($lang)"/>
        <xsl:if test="not($edition)">
            <xsl:message expand-text="yes">{f:log-warning('No edition of Bible text known in language &quot;{1}&quot;.', ($lang))}</xsl:message>
        </xsl:if>

        <xsl:variable name="reference" select="
            if ($parts('chapter') and $parts('toChapter') and $parts('verse') and $parts('toVerse'))
            then $parts('book') || ' ' || $parts('chapter') || ':' || $parts('verse') || '-' || $parts('toChapter') || ':' || $parts('toVerse')
            else if ($parts('chapter') and $parts('toChapter'))
                 then $parts('book') || ' ' || $parts('chapter') || '-' || $parts('toChapter')
                 else if ($parts('chapter') and $parts('verse') and $parts('toVerse'))
                      then $parts('book') || ' ' || $parts('chapter') || ':' || $parts('verse') || '-' || $parts('toVerse')
                      else if ($parts('chapter') and $parts('verse'))
                           then $parts('book') || ' ' || $parts('chapter') || ':' || $parts('verse')
                           else if ($parts('chapter'))
                                then $parts('book') || ' ' || $parts('chapter')
                                else $parts('book')"/>

        <!-- Alternative sites

             https://biblehub.com/text/john/3-31.htm

             https://www.skepticsannotatedbible.com/
             SKAB: https://www.skepticsannotatedbible.com/col/1.html#3


             https://www.academic-bible.com/, see: https://www.academic-bible.com/en/online-bibles/hyperlinks-to-bible-text/
             www.academic-bible.com/bible-text/Gn2.2/LXX/
             https://www.bibelwissenschaft.de/bibelstelle/Jes/
             https://www.die-bibel.de/bibeln/online-bibeln/lesen/LU17/MAT.1/Matth%C3%A4us-1
             https://www.die-bibel.de/bibeln/online-bibeln/lesen/LXX/LV.2.2
             https://www.bibelwissenschaft.de/bibelstelle/Gn2-3/

        -->

        <xsl:text expand-text="yes">https://classic.biblegateway.com/passage/?search={iri-to-uri($reference)}{if ($edition != '') then '&amp;version=' || iri-to-uri($edition) else ''}</xsl:text>
    </xsl:function>


    <xsl:variable name="quranRefPattern" select="'^qur:([0-9]+)(?:[:.]([0-9]+)(?:[-]([0-9]+))?)?$'"/>


    <xsl:function name="f:title-for-quran-link" as="xs:string">
        <xsl:param name="url" as="xs:string"/>

        <xsl:variable name="urlParts" select="tokenize(replace($url, $quranRefPattern, '$1,$2,$3'), ',')"/>
        <xsl:variable name="chapter" select="$urlParts[1]"/>
        <xsl:variable name="verse" select="$urlParts[2]"/>
        <xsl:variable name="toVerse" select="$urlParts[3]"/>

        <xsl:value-of select="f:format-message(
                if ($toVerse)
                then 'msgLinkToQuranChapterVerseToVerse'
                else if ($verse)
                     then 'msgLinkToQuranChapterVerse'
                     else 'msgLinkToQuranChapter'
                     ,
                map{'chapter': $chapter, 'verse': $verse, 'toVerse': $toVerse})"/>
    </xsl:function>


    <xsl:function name="f:url-for-quran-link" as="xs:string">
        <xsl:param name="url" as="xs:string"/>

        <xsl:if test="not(matches($url, $quranRefPattern))">
            <xsl:message expand-text="yes">{f:log-error('Invalid reference to Quran: {1}.', ($url))}</xsl:message>
        </xsl:if>

        <xsl:variable name="urlParts" select="tokenize(replace($url, $quranRefPattern, '$1,$2,$3'), ',')"/>
        <xsl:variable name="chapter" select="$urlParts[1]"/>
        <xsl:variable name="verse" select="$urlParts[2]"/>
        <xsl:variable name="toVerse" select="$urlParts[3]"/>

        <!-- Alternative sites:

            <xsl:text expand-text="yes">https://www.quran.com/{iri-to-uri($chapter)}{if ($verse) then '/' || iri-to-uri($verse) else ''}</xsl:text>
            <xsl:text expand-text="yes">https://al-quran.info/#{iri-to-uri($chapter)}{if ($verse) then ':' || iri-to-uri($verse) else ''}</xsl:text>
        -->

        <xsl:text expand-text="yes">https://www.quranwow.com/#/ch/{iri-to-uri($chapter)}/t1/ar-allah/t2/en-pickthall/v/{if ($verse) then iri-to-uri($verse) else '1'}</xsl:text>
    </xsl:function>


</xsl:stylesheet>
