#!/usr/bin/perl -w

#
# Report on a directory of .TEI files (old-fashioned SGML format)
#

use strict;
use warnings;

use Cwd;
use Date::Format;
use File::Basename;
use File::stat;
use File::Temp;
use File::chdir;
use File::Compare;
use Getopt::Long;
use XML::XPath;

binmode(STDOUT, ":utf8");
use open ':utf8';

my $force = 0;          # regenerate XML files.
my $forceMore = 0;      # regenerate XML files, even if they appear up-to-date.
my $makeHtml = 0;       # Generate HTML files.
my $makeEpub = 0;       # Generate Epub files.
my $makeChecks = 0;
my $download = 0;       # Download posted files from Project Gutenberg.
my $showHelp = 0;
my $onlyPosted = 0;     # Only report on posted files (version >= 1.0)
my $makeReports = 0;
my $makeSql = 0;


GetOptions(
    'f' => \$force,
    'm' => \$forceMore,
    'v' => \$makeChecks,
    'h' => \$makeHtml,
    'r' => \$makeReports,
    'e' => \$makeEpub,
    'd' => \$download,
    'q' => \$showHelp,
    'p' => \$onlyPosted,
    'sql' => \$makeSql,
    'help' => \$showHelp);

if ($showHelp == 1) {
    print "pgreport.pl -- create a report of all TEI files in a directory-structure.\n\n";
    print "Usage: pgreport.pl [-fmvhdq] <directory>\n\n";
    print "Options:\n";
    print "    f         force: regenerate XML files used to extract information from.\n";
    print "    m         force more: also force regeneration of indicated file types.\n";
    print "    v         run checks on TEI files.\n";
    print "    r         make word-usage report.\n";
    print "    h         produce derived HTML file for each TEI file.\n";
    print "    e         produce derived ePub file for each TEI file.\n";
    print "    d         download related .zip files from Project Gutenberg (based on PGNum id in TEI file).\n";
    print "    p         only report on posted files (version >= 1.0).\n";
    print "    q         print this help and exit.\n";
    print "\n";
    print "    sql       generate SQL files.\n";
    print "    help      print this help and exit.\n";

    exit(0);
}

my $gitRepoLocation = 'D:/Users/Jeroen/Documents/eLibrary/Git/GutenbergSource/';

if ($forceMore != 0) {
    $force = 1;
}

# Counters
my $totalFiles = 0;
my $totalWords = 0;
my $totalBytes = 0;

my %tagCounters = (
    'p' => 0,           # paragraphs
    'div' => 0,         # divisions (unspecified level)
    'div0' => 0,        # divisions (level 0)
    'div1' => 0,        # divisions (level 1)
    'div2' => 0,        # divisions (level 2)
    'div3' => 0,        # divisions (level 3)
    'lg' => 0,          # line-groups
    'l' => 0,           # lines of vers
    'sp' => 0,          # speakers
    'note' => 0,        # footnotes
    'corr' => 0,        # corrections
    'table' => 0,       # tables
    'row' => 0,         # rows
    'cell' => 0,        # cells
    'list' => 0,        # lists
    'item' => 0,        # items
    'formula' => 0,     # formulas
    'figure' => 0,      # figures
    'ref' => 0
    );     

my %excluded = (
        'TEI-template-NL', 1,
        'TEI-template-EN', 1
    );


my $preGetRepoCode = <<'EOF';

use strict;
use Cwd;
use File::chdir;

EOF

my $postGetRepoCode = <<'EOF';

sub getRepo($) {
    my $repo = shift;

    if (!-e $repo) {
        system ("git clone https://github.com/GutenbergSource/$repo.git\n");
    } elsif (-d $repo) {
        my $cwd = getcwd;
        chdir ($repo);
        system ("git clean -f -d -x\n");
        system ("git reset --hard\n");
        system ("git pull\n");
        chdir $cwd;
    }
}

EOF



main();


sub main {
    my $reportFile = 'pgreport.txt';
    my $xmlFile = 'pgreport.xml';
    my $gitFile = 'getRepos.pl';

    open(REPORTFILE, "> $reportFile") || die("Could not open $reportFile");
    open(XMLFILE, "> $xmlFile") || die("Could not open $xmlFile");
    open(GITFILE, "> $gitFile") || die("Could not open $gitFile");
    print GITFILE $preGetRepoCode;

    my $directory = $ARGV[0];
    if (! defined $directory) {
        $directory = '.';
    }

    print XMLFILE "<?xml version=\"1.0\"?>\n";
    print XMLFILE "<?xml-stylesheet type=\"text/xsl\" href=\"pgreport.xsl\"?>\n";
    print XMLFILE "<pgreport>\n";

    listRecursively($directory);

    print XMLFILE "</pgreport>\n";
    close XMLFILE;

    logTotals();

    close REPORTFILE;
    print GITFILE $postGetRepoCode;
    close GITFILE;
}


sub logTotals {
    logMessage("---------------------");
    logMessage("Files:      $totalFiles");
    logMessage("Words:      $totalWords");
    logMessage("Bytes:      $totalBytes");

    logMessage("---------------------");
    foreach my $tag (sort keys %tagCounters) {
        logMessage("Tag $tag:     " . $tagCounters{$tag});
    }
    logMessage("---------------------");
}


sub listRecursively {
    my ($directory) = @_;
    my @files = (  );

    unless (opendir(DIRECTORY, $directory)) {
        logError("Cannot open directory $directory!");
        exit;
    }

    # Read the directory, ignoring special entries "." and ".."
    @files = grep (!/^\.\.?$/, readdir(DIRECTORY));

    closedir(DIRECTORY);

    foreach my $file (@files) {
        my $path = $directory . '/' . $file;
        if (-f $path) {
            handleFile($path);
        } elsif (-d $path) {
            listRecursively($path);
        }
    }
}


sub handleFile {
    my ($file) = @_;
    if ($file =~ m/^(.*)\.(tei)$/) {
        handleTeiFile($file);
    }
}


sub handleTeiFile {
    my $fullName = shift;

    my $fileSize = -s $fullName;
    my $fileDate = time2str("%Y-%m-%d", stat($fullName)->mtime);
    my $fileDateTime = time2str("%Y-%m-%d %H:%M:%S", stat($fullName)->mtime);

    my ($fileName, $filePath, $suffix) = fileparse($fullName, '.tei');

    $fileName =~ /^([A-Za-z0-9-]*?)(-([0-9]+\.[0-9]+))?$/;
    my $baseName    = $1;
    my $version     = $3;
    if ($onlyPosted != 0 && $version < 1.0) {
        return;
    }

    print STDERR "---------------------\n";
    print STDERR "$fullName\n";

    print XMLFILE "  <book>\n";

    logMessage("---------------------");
    logMessage("File:       $fileName$suffix");
    print XMLFILE "    <file>\n";
    print XMLFILE "      <name>$fileName$suffix</name>\n";
    print XMLFILE "      <baseName>$baseName</baseName>\n";
    if (defined ($version)) {
        logMessage("Version:    $version");
        print XMLFILE "      <version>$version</version>\n";
    }
    logMessage("File Size:  " . formatBytes($fileSize));
    print XMLFILE "      <size>$fileSize</size>\n";
    logMessage("Date:       $fileDate");
    print XMLFILE "      <date>$fileDate</date>\n";
    logMessage("Path:       $filePath");
    print XMLFILE "      <dateTime>$fileDateTime</dateTime>\n";
    print XMLFILE "      <path>$filePath</path>\n";

    if (-e $filePath . 'Processed/' . $baseName . '-utf8.txt') {
        print XMLFILE "      <encoding>UTF8</encoding>\n";
    } else {
        print XMLFILE "      <encoding>Latin-1</encoding>\n";
    }

    print XMLFILE "    </file>\n";

    $totalFiles++;
    $totalBytes += $fileSize;

    my $processScript = $filePath . 'process.pl';
    my $specialProcessing = 0;
    if (-e $processScript) {
        logMessage('Note:       process.pl present; files in this directory may require special processing.');
        $specialProcessing = 1;
    }

    my $xmlFileName      = $filePath . "$baseName.xml";
    my $textFileName     = $filePath . "$baseName.txt";
    my $utf8TextFileName = $filePath . "$baseName-utf8.txt";
    my $htmlFileName     = $filePath . "$baseName.html";
    my $epubFileName     = $filePath . "$baseName.epub";
    my $wordsFileName    = $filePath . "$baseName-words.html";
    my $checksFileName   = $filePath . "$baseName-checks.html";

    # Determine needs
    my $needXml     = isNewer($fullName, $xmlFileName);
    my $needHtml    = $makeHtml != 0 && isNewer($fullName, $htmlFileName);
    my $needReports = $makeReports != 0 && isNewer($fullName, $wordsFileName);
    my $needChecks  = $makeChecks != 0 && isNewer($fullName, $checksFileName);
    my $needEpub    = $makeEpub != 0 && isNewer($fullName, $epubFileName);

    if (!$excluded{$baseName} == 1 && defined($version)) {
        if ($force != 0
                || $needXml != 0
                || $needHtml != 0
                || $needReports != 0
                || $needChecks != 0
                || $needEpub != 0) {
            my $cwd = getcwd;
            chdir ($filePath);
            if ($specialProcessing == 1) {
                # system ("perl -S process.pl");
            } else {
                my $forceFlag  = $forceMore   == 0 ? '' : ' -f ';
                my $htmlFlag   = $needHtml    == 0 ? '' : ' -h ';
                my $epubFlag   = $needEpub    == 0 ? '' : ' -e ';
                my $reportFlag = $needReports == 0 ? '' : ' -r ';
                my $checksFlag = $needChecks  == 0 ? '' : ' -v ';
                my $sqlFlag    = $makeSql     == 0 ? '' : ' --sql ';
                system ("perl -S tei2html.pl -x -l=1 $sqlFlag $checksFlag $reportFlag $htmlFlag $epubFlag $forceFlag $fileName$suffix");
            }
            chdir ($cwd);
        }

        my $coverImageFile = "cover.jpg";
        my $titlePageImageFile = "titlepage.png";
        if (-e $xmlFileName) {
            # Use eval, so we can recover from fatal parse errors in XML:XPath.
            eval {
                my $xpath = XML::XPath->new(filename => $xmlFileName);

                my $title = $xpath->find('/TEI.2/teiHeader/fileDesc/titleStmt/title[not(@type)]');
                my $shortTitle = $xpath->find('/TEI.2/teiHeader/fileDesc/titleStmt/title[@type="short"]');
                my $titleNfc = $xpath->find('/TEI.2/teiHeader/fileDesc/titleStmt/title[not(@type)]/@nfc');
                my $authors = $xpath->find('/TEI.2/teiHeader/fileDesc/titleStmt/author');
                my $editors = $xpath->find('/TEI.2/teiHeader/fileDesc/titleStmt/editor');
                my $respRoles = $xpath->find('/TEI.2/teiHeader/fileDesc/titleStmt/respStmt/resp');
                my $respNames = $xpath->find('/TEI.2/teiHeader/fileDesc/titleStmt/respStmt/name');
                my $originalDate = $xpath->find('/TEI.2/teiHeader/fileDesc/sourceDesc/bibl/date[1]');
                my $pageCount = $xpath->find('count(//pb[not(ancestor::note)])');
                my $pgNum = $xpath->find('/TEI.2/teiHeader/fileDesc/publicationStmt/idno[@type="PGnum"]');
                my $pgSrc = $xpath->find('/TEI.2/teiHeader/fileDesc/publicationStmt/idno[@type="PGSrc"]');
                my $pgphNum = $xpath->find('/TEI.2/teiHeader/fileDesc/publicationStmt/idno[@type="PGPH"]');
                my $epubId = $xpath->find('/TEI.2/teiHeader/fileDesc/publicationStmt/idno[@type="epub-id"]');
                my $pgClearance = $xpath->find('/TEI.2/teiHeader/fileDesc/publicationStmt/idno[@type="PGclearance"]');
                my $projectId = $xpath->find('/TEI.2/teiHeader/fileDesc/publicationStmt/idno[@type="PGDPProjectId"]');
                my $postedDate = $xpath->find('/TEI.2/teiHeader/fileDesc/publicationStmt/date');
                my $language = $xpath->find('/TEI.2/@lang');
                my $description = $xpath->find('/TEI.2/teiHeader/fileDesc/notesStmt/note[@type="Description"]');
                my $keywords = $xpath->find('/TEI.2/teiHeader/profileDesc/textClass/keywords/list/item');

                logMessage("Title:      $title");

                my $nfcAttr = ' nfc="0"';
                if (defined $titleNfc) {
                    $nfcAttr = ' nfc="' . escapeXml($titleNfc) . '"';
                }
                print XMLFILE "    <title$nfcAttr>" . escapeXml($title) . "</title>\n";

                for my $author ($authors->get_nodelist()) {
                    logMessage("Author:     " . $author->string_value());
                    my $keyAttr = getAttr('key', $author);
                    my $refAttr = getAttr('ref', $author);
                    print XMLFILE "    <author$keyAttr$refAttr>" . escapeXml($author->string_value()) . "</author>\n";
                }
                for my $editor ($editors->get_nodelist()) {
                    logMessage("Editor:     " . $editor->string_value());
                    my $keyAttr = getAttr('key', $editor);
                    my $refAttr = getAttr('ref', $editor);
                    print XMLFILE "    <editor$keyAttr$refAttr>" . escapeXml($editor->string_value()) . "</editor>\n";
                }
                for my $respName ($respNames->get_nodelist()) {
                    logMessage("Contributor:     " . $respName->string_value());
                    my $keyAttr = getAttr('key', $respName);
                    my $refAttr = getAttr('ref', $respName);
                    print XMLFILE "    <contributor$keyAttr$refAttr>" . escapeXml($respName->string_value()) . "</contributor>\n";
                }

                logMessage("Orig. Date: $originalDate");
                print XMLFILE "    <date>$originalDate</date>\n";
                logMessage("Pages:      $pageCount");
                print XMLFILE "    <pageCount>$pageCount</pageCount>\n";
                logMessage("Language:   $language");
                print XMLFILE "    <language>$language</language>\n";
                logMessage("ePub ID:    $epubId");
                print XMLFILE "    <epubid>$epubId</epubid>\n";
                logMessage("PG Number:  $pgNum");
                print XMLFILE "    <pgnumber>$pgNum</pgnumber>\n";
                print XMLFILE "    <pgsource>$pgSrc</pgsource>\n";


                logMessage("Counts");
                my $counter = $xpath->find('count(TEI.2/text//p)');
                $tagCounters{'p'} += $counter->string_value();
                logMessage("  p:        " . $counter->string_value());

                $counter = $xpath->find('count(TEI.2/text//div)');
                $tagCounters{'div'} += $counter->string_value();
                logMessage("  div:      " . $counter->string_value());

                $counter = $xpath->find('count(TEI.2/text//div0)');
                $tagCounters{'div0'} += $counter->string_value();
                logMessage("  div0:     " . $counter->string_value());

                $counter = $xpath->find('count(TEI.2/text//div1)');
                $tagCounters{'div1'} += $counter->string_value();
                logMessage("  div1:     " . $counter->string_value());

                $counter = $xpath->find('count(TEI.2/text//div2)');
                $tagCounters{'div2'} += $counter->string_value();
                logMessage("  div2:     " . $counter->string_value());

                $counter = $xpath->find('count(TEI.2/text//div3)');
                $tagCounters{'div3'} += $counter->string_value();
                logMessage("  div3:     " . $counter->string_value());

                $counter = $xpath->find('count(TEI.2/text//lg)');
                $tagCounters{'lg'} += $counter->string_value();
                logMessage("  lg:       " . $counter->string_value());

                $counter = $xpath->find('count(TEI.2/text//sp)');
                $tagCounters{'sp'} += $counter->string_value();
                logMessage("  sp:       " . $counter->string_value());

                $counter = $xpath->find('count(TEI.2/text//l)');
                $tagCounters{'l'} += $counter->string_value();
                logMessage("  l:        " . $counter->string_value());

                $counter = $xpath->find('count(TEI.2/text//note[not(@place) or @place="foot" or @place="unspecified"])');
                $tagCounters{'note'} += $counter->string_value();
                logMessage("  note:     " . $counter->string_value());

                $counter = $xpath->find('count(TEI.2/text//corr)');
                $tagCounters{'corr'} += $counter->string_value();
                logMessage("  corr:     " . $counter->string_value());

                $counter = $xpath->find('count(TEI.2/text//table)');
                $tagCounters{'table'} += $counter->string_value();
                logMessage("  table:    " . $counter->string_value());

                $counter = $xpath->find('count(TEI.2/text//row)');
                $tagCounters{'row'} += $counter->string_value();
                logMessage("  row:      " . $counter->string_value());

                $counter = $xpath->find('count(TEI.2/text//cell)');
                $tagCounters{'cell'} += $counter->string_value();
                logMessage("  cell:     " . $counter->string_value());

                $counter = $xpath->find('count(TEI.2/text//list)');
                $tagCounters{'list'} += $counter->string_value();
                logMessage("  list:     " . $counter->string_value());

                $counter = $xpath->find('count(TEI.2/text//item)');
                $tagCounters{'item'} += $counter->string_value();
                logMessage("  item:     " . $counter->string_value());

                $counter = $xpath->find('count(TEI.2/text//formula)');
                $tagCounters{'formula'} += $counter->string_value();
                logMessage("  formula:  " . $counter->string_value());

                $counter = $xpath->find('count(TEI.2/text//figure)');
                $tagCounters{'figure'} += $counter->string_value();
                logMessage("  figure:   " . $counter->string_value());

                $counter = $xpath->find('count(TEI.2/text//ref)');
                $tagCounters{'ref'} += $counter->string_value();
                logMessage("  ref:      " . $counter->string_value());

                if ($download == 1 && isValid($pgNum->string_value())) {
                    downloadFromPG($pgNum, $filePath);
                }

                my $repo = $pgSrc->string_value();
                if (isValid($repo)) {
                    print GITFILE "getRepo('$pgSrc');\n";

                    # Check: is git repo up-to-date? (TODO: fails for multi-volume repos)
                    my $localFile = "$fileName$suffix";
                    my $gitRepoFile = $gitRepoLocation . $pgSrc . "/" . $localFile;
                    if (defined ($gitRepoFile) && compare($gitRepoFile, $fullName) != 0) {
                        print "WARNING: Git repo differs: $localFile <> $gitRepoFile\n";
                        print "WARNING: Size in Git:  " . (-s $gitRepoFile) . " bytes\n";
                        print "WARNING: Size locally: " . (-s $fullName) . " bytes\n";
                    }
                }
                print XMLFILE "    <pgphnumber>$pgphNum</pgphnumber>\n";
                if (isValid($projectId->string_value())) {
                    print XMLFILE "    <projectId>$projectId</projectId>\n";
                }
                logMessage("Clearance:  $pgClearance");
                print XMLFILE "    <clearance>" . escapeXml($pgClearance) . "</clearance>\n";
                logMessage("Posted:     $postedDate");
                print XMLFILE "    <postedDate>$postedDate</postedDate>\n";

                if (isValid($description->string_value())) {
                    print XMLFILE "    <description>" . escapeXml($description) . "</description>\n";
                }
                for my $keyword ($keywords->get_nodelist()) {
                    if (isValid($keyword->string_value())) {
                        print XMLFILE "    <keyword>" . escapeXml($keyword->string_value()) . "</keyword>\n";
                    }
                }

                # Find out whether we have a cover image:
                my $coverImage = $xpath->find('//figure[@id="cover-image"]')->string_value();
                if ($coverImage ne '') {
                    my $coverImageRend = $xpath->find('//figure[@id="cover-image"]/@rend')->string_value();
                    if ($coverImageRend =~ /image\((.*?)\)/) {
                        $coverImageFile = $1;
                    }
                    logMessage("Cover:      $coverImageFile");
                    print XMLFILE "    <cover>$coverImageFile</cover>\n";
                }

                # Find out whether we have a title-page image:
                my $titlePageImage = $xpath->find('//figure[@id="titlepage-image"]')->string_value();
                if ($titlePageImage ne '') {
                    my $titlePageImageRend = $xpath->find('//figure[@id="titlepage-image"]/@rend')->string_value();
                    if ($titlePageImageRend =~ /image\((.*?)\)/) {
                        $titlePageImageFile = $1;
                    }
                    logMessage("Title Page: $titlePageImageFile");
                    print XMLFILE "    <titlePage>$titlePageImageFile</titlePage>\n";
                }

                $xpath->cleanup();

                1;
            } or do {
                logMessage("Note:       Problem parsing $xmlFileName.");
                logError("Problem parsing $xmlFileName");
            };
        }

        my $imageInfoFileName = $filePath . "imageinfo.xml";
        if (-e $imageInfoFileName) {
            # Use eval, so we can recover from fatal parse errors in XML:XPath.
            eval {
                my $xpath = XML::XPath->new(filename => $imageInfoFileName);

                my $imageCount = $xpath->find('count(//image)');
                logMessage("Images:     $imageCount");
                print XMLFILE "    <imageCount>$imageCount</imageCount>\n";

                my $coverWidth = $xpath->find('//image[@path="' . $coverImageFile . '"]/@width');
                my $coverHeight = $xpath->find('//image[@path="' . $coverImageFile . '"]/@height');
                logMessage("Cover size: $coverWidth by $coverHeight");
                print XMLFILE "    <coverSize><width>$coverWidth</width><height>$coverHeight</height></coverSize>\n";

                my $titlePageWidth = $xpath->find('//image[@path="' . $titlePageImageFile . '"]/@width');
                my $titlePageHeight = $xpath->find('//image[@path="' . $titlePageImageFile . '"]/@height');
                logMessage("Title page size: $titlePageWidth by $titlePageHeight");
                print XMLFILE "    <titlePageSize><width>$titlePageWidth</width><height>$titlePageHeight</height></titlePageSize>\n";

                $xpath->cleanup();

                1;
            } or do {
                logMessage("Note:       Problem parsing $imageInfoFileName.");
                logError("Problem parsing $imageInfoFileName");
            };
        }


        my $metadataFile = $filePath . "metadata.xml";
        if (-e $metadataFile) {
            # Use eval, so we can recover from fatal parse errors in XML:XPath.
            eval {
                my $xpath = XML::XPath->new(filename => $metadataFile);

                $xpath->set_namespace('rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#');
                $xpath->set_namespace('dc' => 'http://purl.org/dc/elements/1.1/');

                my $rights = $xpath->find('/rdf:RDF/rdf:Description/dc:rights');
                print XMLFILE "    <rights>" . escapeXml($rights->string_value()) . "</rights>\n";

                $xpath->cleanup();

                1;
            } or do {
                logMessage("Note:       Problem parsing $metadataFile.");
                logError("Problem parsing $metadataFile");
            };
        }


        # Words file
        my $wordsFileName = $filePath . "$baseName-words.html";
        if (-e $wordsFileName) {
            if (open(WORDSFILE, "<:encoding(iso-8859-1)", $wordsFileName)) {
                while (<WORDSFILE>) {
                    my $line =  $_;
                    if ($line =~ /<td id=textWordCount>([0-9]+)/) {
                        my $wordCount = $1;
                        $totalWords += $wordCount;
                        logMessage("Words:      $wordCount");
                        print XMLFILE "    <wordCount>$wordCount</wordCount>\n";
                        last;
                    }
                }
                close WORDSFILE;
            }
        }

        # Issues file
        my $issuesFileName = $filePath . "issues.xml";
        if (-e $issuesFileName) {
            # Use eval, so we can recover from fatal parse errors in XML:XPath.
            eval {
                my $xpath = XML::XPath->new(filename => $issuesFileName);

                my $errorCount = $xpath->find('count(//i:issue[@level=\'Error\'])');
                my $warningCount = $xpath->find('count(//i:issue[@level=\'Warning\'])');
                my $trivialCount = $xpath->find('count(//i:issue[@level=\'Trivial\'])');

                logMessage("Errors:     $errorCount");
                logMessage("Warnings:   $warningCount");
                logMessage("Trivials:   $trivialCount");

                print XMLFILE "    <errors>" . $errorCount . "</errors>\n";
                print XMLFILE "    <warnings>" . $warningCount . "</warnings>\n";
                print XMLFILE "    <trivials>" . $trivialCount . "</trivials>\n";

                $xpath->cleanup();

                1;
            } or do {
                logMessage("Note:       Problem parsing $issuesFileName.");
                logError("Problem parsing $issuesFileName");
            };
        }
    }

    print XMLFILE "  </book>\n";
}


sub downloadFromPG {
    my $pgNum = shift;
    my $path = shift;

    # Construct destination path:
    my $destinationPath = $path . '/Processed';

    my $textFile = $pgNum . '.txt';
    my $text8File = $pgNum . '-8.txt';
    my $text0File = $pgNum . '-0.txt';
    my $htmlFile = $pgNum . '-h.htm';

    my $textUrl = 'https://www.gutenberg.org/files/' . $pgNum . '/' . $textFile;
    my $text8Url = 'https://www.gutenberg.org/files/' . $pgNum . '/' . $text8File;
    my $text0Url = 'https://www.gutenberg.org/files/' . $pgNum . '/' . $text0File;
    my $htmlUrl = 'https://www.gutenberg.org/files/' . $pgNum . '/' . $pgNum . '-h/' . $htmlFile;

    {
        local $CWD = $destinationPath;
        if (!-e $textFile) {
            system ("wget $textUrl");
        }
        if (!-e $text8File) {
            system ("wget $text8Url");
        }
        if (!-e $text0File) {
            system ("wget $text0Url");
        }
        if (!-e $htmlFile) {
            system ("wget $htmlUrl");
        }
    }
}


sub getAttr {
    my $attr = shift;
    my $node = shift;
    my $value = $node->find('@' . $attr);
    my $valueAttr = '';
    if ($value->size() > 0) {
        $valueAttr = escapeXml($value->string_value());
        $valueAttr = " $attr=\"" . $valueAttr . '"';
    }
    return $valueAttr;
}


sub escapeXml {
    my $data = shift;

    $data =~ s/&/&amp;/sg;
    $data =~ s/</&lt;/sg;
    $data =~ s/>/&gt;/sg;
    $data =~ s/"/&quot;/sg;

    return $data;
}


sub logError {
    my $message = shift;
    print STDERR "ERROR: $message\n";
}


sub logMessage {
    my $message = shift;
    print REPORTFILE "$message\n";
}


sub isValid {
    my $value = shift;
    return defined $value && $value ne '' && $value ne '#####';
}


sub formatBytes {
    my $num = shift;
    my $kb = 1024;
    my $mb = (1024 * 1024);
    my $gb = (1024 * 1024 * 1024);

    ($num > $gb) ? return sprintf('%d GB', $num / $gb) :
    ($num > $mb) ? return sprintf('%d MB', $num / $mb) :
    ($num > $kb) ? return sprintf('%d KB', $num / $kb) :
    return $num . ' B';
}


#
# isNewer -- determine whether the first file exists and is newer than the second file
#
sub isNewer {
    my $file1 = shift;
    my $file2 = shift;

    if (!-e $file2) {
        return 1;
    }

    return (-e $file1 && stat($file1)->mtime > stat($file2)->mtime)
}
