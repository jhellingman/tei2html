
# The TEI Header #

The TEI header (`<teiHeader>`) contains information about the text and the sources it is derived from. This meta-data is grouped in various sections, in which it is often possible to distinguish information related to the electronic file from that related to the original source.

Tei2html uses the meta-data in the TEI header to construct the meta-data in the target formats, as well as the optional colophon. It is important to have the correctly specify the meta-data in the TEI header.

Preparing a TEI header is less work than it might seem, as you can normally work from a template, prepared with the most common elements already in place.

The TEI header contains four main sections:

```xml
    <teiHeader>
        <fileDesc>...</fileDesc>
        <encodingDesc>...</encodingDesc>
        <profileDesc>...</profileDesc>
        <revisionDesc>...</revisionDesc>
    </teiHeader>
```

## The File Description ##

The first element of the TEI header is the file description, `<fileDesc>`. This contains the most important meta-data in three main elements, the `<titleStmt>`, `<publicationStmt>`, and `<sourceDesc>`. Our template looks like this.

```xml
    <fileDesc>
        <titleStmt>
            <title>TITLE</title>
            <author>AUTHOR</author>
        </titleStmt>
        <publicationStmt>
            <publisher>Project Gutenberg</publisher>
            <pubPlace>Urbana, Illinois, USA.</pubPlace>
            <idno type="PGNum">12345</idno>
            <date>2010-01-31</date>
            <availability>
                <p>Some statements on the availability and copyright status of the work.</p>
            </availability>
        </publicationStmt>
        <sourceDesc>
        <bibl>
            <author>AUTHOR</author>
            <title>TITLE</title>
            <date>YEAR</date>
        </bibl>
        </sourceDesc>
    </fileDesc>
```

You might notice that the TEI header contains the title and author information twice. This is intentional, as one refers to the title of the file, and one to the title of the source. For the title given in the `<titleStmt>`, some TEI recommendations suggest to append �an electronic transcription� to the original title. We think that is unnecessary, and only use the original title as it is, or perhaps normalized in some fashion. For personal names, we always give them in the natural order, that is, without a comma, and optionally supply the vital dates in parentheses, for example, `<author>John Doe (1833-1901)</author>`. You may add other elements allowed by TEI in this statement if needed.

In the publication statement, we give some information on the publisher and its availability. For typical Project Gutenberg publications, the information in the template is fine.

The following specific values can be used in the <publicationStmt> element to register the various ways the text is known at Project Gutenberg and elsewhere.

| **ID type**                                   | **Used for**                                                                                                                                                                                                                              |
|:----------------------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `<idno type=PGNum>12345</idno>`               | The Project Gutenberg eBook number.                                                                                                                                                                                                       |
| `<idno type=PGDPProjectID>project1234</idno>` | The PGDP project number(s).                                                                                                                                                                                                               |
| `<idno type=PGClearance>1234name</idno>`      | The PG Clearance number.                                                                                                                                                                                                                  |
| `<idno type=OCLC></idno>`                     | OCLC catalog number (worldcat).                                                                                                                                                                                                           |
| `<idno type=OLN></idno>`                      | Open Library catalog number.                                                                                                                                                                                                              |
| `<idno type=LCCN></idno>`                     | Library of Congress Call Number.                                                                                                                                                                                                          |
| `<idno type=ISBN></idno>`                     | The ISBN. Since ISBNs refer to specific manifestations of a work, this number typically refers to the ISBN of the source digitized. ISBNs have been in use since 1972, so it is unlikely many Project Gutenberg books have such a number. |

The `<availability>` element should include a short reference to the copyright status of the work. For most texts in Project Gutenberg, the following phrase will be appropriate: _Not copyrighted in the United States. If you live elsewhere please check the laws of your country before downloading this ebook._

In the `<sourceDesc>`, the title and author information appears again. This time, you should use the exact title and author names as given on the title page of the original work used to prepare your Project Gutenberg text. If the title on the spine or cover of the book differs, this may be noted, but the title page is leading.


### Extensions to TEI ###

The `@nfc` attribute on `<title>` elements is used to indicate the number of non-filing characters, used when sorting a title. Counted should be all characters up to the character on which the title should be sorted, including spaces.

```xml
    <title nfc="4">The Return of the King</title>
    <title nfc="3">An Introduction to Mathematics</title>
```

The `@sortkey` attribute on `<author>` and related elements is used to supply a sort key for a name. Typically, such sort keys would drop accents, such that they will sort in the expected place in lists.

```xml
    <author sortkey="Rhijn, Rembrandt van">Rembrandt van Rhijn</author>
    <author sortkey="MacKenzee, John">John McKenzee</author>
    <author sortkey="Hotel, Desire l'">Desiré l'Hôtel</author>
```




