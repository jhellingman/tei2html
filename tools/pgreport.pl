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
my $makeChecks = 0;
my $download = 0;       # Download posted files from Project Gutenberg.

GetOptions(
    'f' => \$force,
    'm' => \$forceMore,
    'v' => \$makeChecks,
    'h' => \$makeHtml,
    'd' => \$download);

my $gitRepoLocation = 'D:/Users/Jeroen/Documents/eLibrary/Git/GutenbergSource/';

if ($forceMore != 0) {
    $force = 1;
}

# Counters
my $totalFiles = 0;
my $totalWords = 0;
my $totalBytes = 0;

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

    my ($fileName, $filePath, $suffix) = fileparse($fullName, '.tei');

    $fileName =~ /^([A-Za-z0-9-]*?)(-([0-9]+\.[0-9]+))?$/;
    my $baseName    = $1;
    my $version     = $3;

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
    print XMLFILE "      <path>$filePath</path>\n";
    print XMLFILE "    </file>\n";

    $totalFiles++;
    $totalBytes += $fileSize;

    my $processScript = $filePath . 'process.pl';
    my $specialProcessing = 0;
    if (-e $processScript) {
        logMessage('Note:       process.pl present; files in this directory may require special processing.');
        $specialProcessing = 1;
    }

    my $xmlFileName = $filePath . "$baseName.xml";
    my $htmlFileName = $filePath . "$baseName.html";
    my $wordsFileName = $filePath . "$baseName-words.html";

    if (!$excluded{$baseName} == 1 && defined($version)) {
        my $checksFileName = $filePath . "$baseName-$version-checks.html";
        if ($force != 0
                || !-e $xmlFileName
                || !-e $wordsFileName
                || !-e $checksFileName
                || ($makeHtml != 0 && !-e $htmlFileName)
                || isNewer($fullName, $xmlFileName)) {
            my $cwd = getcwd;
            chdir ($filePath);
            if ($specialProcessing == 1) {
                # system ("perl -S process.pl");
            } else {
                my $forceFlag = $forceMore == 0 ? '' : ' -f ';
                if ($makeHtml != 0) {
                    system ("perl -S tei2html.pl -h -r -v $forceFlag $fileName$suffix");
                } else {
                    system ("perl -S tei2html.pl -x -r -v $forceFlag $fileName$suffix");
                }
            }
            chdir ($cwd);
        }

        my $coverImageFile = "cover.jpg";
        my $titlePageImageFile = "titlepage.png";
        if (-e $xmlFileName) {
            # Use eval, so we can recover from fatal parse errors in XML:XPath.
            eval {
                my $xpath = XML::XPath->new(filename => $xmlFileName);

                my $title = $xpath->find('/TEI.2/teiHeader/fileDesc/titleStmt/title');
                my $titleNfc = $xpath->find('/TEI.2/teiHeader/fileDesc/titleStmt/title/@nfc');
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

                if ($download == 1 && isValid($pgNum->string_value())) {
                    downloadFromPG($pgNum, $filePath);
                }

                my $repo = $pgSrc->string_value();
                if (isValid($repo)) {
                    print GITFILE "getRepo('$pgSrc');\n";

                    # Check: is git repo up-to-date?
                    my $localFile = "$fileName$suffix";
                    my $gitRepoFile = $gitRepoLocation . $pgSrc . "/" . $localFile;
                    if (defined ($gitRepoFile) && compare($gitRepoFile, $fullName) != 0) {
                        print "COMPARE: Git repo differs: $localFile <> $gitRepoFile\n";
                        print "         Size in Git:  " . (-s $gitRepoFile) . " bytes\n";
                        print "         Size locally: " . (-s $fullName) . " bytes\n";
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

                print XMLFILE "    <description>" . escapeXml($description) . "</description>\n";
                for my $keyword ($keywords->get_nodelist()) {
                    print XMLFILE "    <keyword>" . escapeXml($keyword->string_value()) . "</keyword>\n";
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

        # words-file
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
    my $htmlFile = $pgNum . '-h.htm';

    my $textUrl = 'http://www.gutenberg.org/files/' . $pgNum . '/' . $textFile;
    my $text8Url = 'http://www.gutenberg.org/files/' . $pgNum . '/' . $text8File;
    my $htmlUrl = 'http://www.gutenberg.org/files/' . $pgNum . '/' . $pgNum . '-h/' . $htmlFile;

    {
        local $CWD = $destinationPath;
        if (!-e $textFile) {
            system ("wget $textUrl");
        }
        if (!-e $text8File) {
            system ("wget $text8Url");
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

    return (-e $file1 && -e $file2 && stat($file1)->mtime > stat($file2)->mtime)
}
