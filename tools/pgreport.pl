#!/usr/bin/perl -w

#
# Report / process a directory of .TEI files (old-fashioned SGML format)
#

use strict;
use warnings;

use Cwd;
use Date::Format;
use File::Basename;
use File::stat;
use File::Temp;
use Getopt::Long;
use XML::XPath;

binmode(STDOUT, ":utf8");
use open ':utf8';

my $force = 0;  # force generation of XML files, even if up-to-date.

GetOptions(
    'f' => \$force);

my $totalFiles = 0;
my $totalPages = 0;
my $totalWords = 0;
my $totalBytes = 0;

my %excluded =
    (
        "TEI-template-NL", 1,
        "TEI-template-EN", 1
    );


sub listRecursively($);
sub main();


main();


sub main()
{
    my $reportFile = "pgreport.txt";
    my $xmlFile = "pgreport.xml";

    open(REPORTFILE, "> $reportFile") || die("Could not open $reportFile");
    open(XMLFILE, "> $xmlFile") || die("Could not open $xmlFile");

    my $directory = $ARGV[0];
    if (! defined $directory)
    {
        $directory = ".";
    }

    print XMLFILE "<?xml version=\"1.0\"?>\n";
    print XMLFILE "<?xml-stylesheet type=\"text/xsl\" href=\"pgreport.xsl\"?>\n";
    print XMLFILE "<pgreport>\n";

    listRecursively($directory);

    print XMLFILE "</pgreport>\n";
    close XMLFILE;

    logTotals();

    close REPORTFILE;
}


sub logTotals()
{
    logMessage("---------------------");
    logMessage("Files:      $totalFiles");
    logMessage("Words:      $totalWords");
    logMessage("Bytes:      $totalBytes");
}


sub listRecursively($)
{
    my ($directory) = @_;
    my @files = (  );

    unless (opendir(DIRECTORY, $directory))
    {
        logError("Cannot open directory $directory!");
        exit;
    }

    # Read the directory, ignoring special entries "." and ".."
    @files = grep (!/^\.\.?$/, readdir(DIRECTORY));

    closedir(DIRECTORY);

    foreach my $file (@files)
    {
        if (-f "$directory\\$file")
        {
            handleFile("$directory\\$file");
        }
        elsif (-d "$directory\\$file")
        {
            listRecursively("$directory\\$file");
        }
    }
}


sub handleFile($)
{
    my ($file) = @_;

    if ($file =~ m/^(.*)\.(tei)$/)
    {
        handleTeiFile($file);
    }
}


sub handleTeiFile($)
{
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
    if (defined ($version))
    {
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

    my $processScript = $filePath . "process.pl";
    my $specialProcessing = 0;
    if (-e $processScript)
    {
        logMessage("Note:       process.pl present; files in this directory may require special processing.");
        $specialProcessing = 1;
    }

    my $xmlFileName = $filePath . "$baseName.xml";

    if (!$excluded{$baseName} == 1 && defined($version))
    {
        if ($force != 0 || !-e $xmlFileName || isNewer($fullName, $xmlFileName))
        {
            my $cwd = getcwd;
            chdir ($filePath);
            if ($specialProcessing == 1)
            {
                # system ("perl -S process.pl");
            }
            else
            {
                system ("perl -S tei2html.pl -x -r -f $fileName$suffix");
            }
            chdir ($cwd);
        }

        if (-e $xmlFileName)
        {
            # Use eval, so we can recover from fatal parse errors in XML:XPath.
            eval
            {
                my $xpath = XML::XPath->new(filename => $xmlFileName);

                my $title = $xpath->find('/TEI.2/teiHeader/fileDesc/titleStmt/title');
                my $authors = $xpath->find('/TEI.2/teiHeader/fileDesc/titleStmt/author');
                my $originalDate = $xpath->find('/TEI.2/teiHeader/fileDesc/sourceDesc/bibl/date[1]');
                my $pageCount = $xpath->find('count(//pb[not(ancestor::note)])');
                my $pgNum = $xpath->find('/TEI.2/teiHeader/fileDesc/publicationStmt/idno[@type="PGnum"]');
                my $epubId = $xpath->find('/TEI.2/teiHeader/fileDesc/publicationStmt/idno[@type="epub-id"]');
                my $pgClearance = $xpath->find('/TEI.2/teiHeader/fileDesc/publicationStmt/idno[@type="PGclearance"]');
                my $projectId = $xpath->find('/TEI.2/teiHeader/fileDesc/publicationStmt/idno[@type="PGDPProjectId"]');
                my $postedDate = $xpath->find('/TEI.2/teiHeader/fileDesc/publicationStmt/date');
                my $language = $xpath->find('/TEI.2/@lang');
                my $description = $xpath->find('/TEI.2/teiHeader/fileDesc/notesStmt/note[@type="Description"]');
                my $keywords = $xpath->find('/TEI.2/teiHeader/profileDesc/textClass/keywords/list/item');


                logMessage("Title:      $title");
                print XMLFILE "    <title>" . escapeXml($title) . "</title>\n";

                for my $author ($authors->get_nodelist())
                {
                    logMessage("Author:     " . $author->string_value());
                    print XMLFILE "    <author>" . escapeXml($author->string_value()) . "</author>\n";
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
                print XMLFILE "    <projectId>$projectId</projectId>\n";
                logMessage("Clearance:  $pgClearance");
                print XMLFILE "    <clearance>" . escapeXml($pgClearance) . "</clearance>\n";
                logMessage("Posted:     $postedDate");
                print XMLFILE "    <postedDate>$postedDate</postedDate>\n";

                print XMLFILE "    <description>" . escapeXml($description) . "</description>\n";
                for my $keyword ($keywords->get_nodelist())
                {
                    print XMLFILE "    <keyword>" . escapeXml($keyword->string_value()) . "</keyword>\n";
                }

                # Find out whether we have a cover image:
                my $coverImage = $xpath->find('//figure[@id="cover-image"]')->string_value();
                if ($coverImage ne "")
                {
                    my $coverImageFile = "cover.jpg";
                    my $coverImageRend = $xpath->find('//figure[@id="cover-image"]/@rend')->string_value();
                    if ($coverImageRend =~ /image\((.*?)\)/)
                    {
                        $coverImageFile = $1;
                    }
                    logMessage("Cover:      $coverImageFile");
                    print XMLFILE "    <cover>$coverImageFile</cover>\n";
                }

                1;
            }
            or do
            {
                logMessage("Note:       Problem parsing $xmlFileName.");
                logError("Problem parsing $xmlFileName");
            };
        }

        my $imageInfoFileName = $filePath . "imageinfo.xml";
        if (-e $imageInfoFileName)
        {
            # Use eval, so we can recover from fatal parse errors in XML:XPath.
            eval
            {
                my $xpath = XML::XPath->new(filename => $imageInfoFileName);

                my $imageCount = $xpath->find('count(//image)');

                logMessage("Images:     $imageCount");
                print XMLFILE "    <imageCount>$imageCount</imageCount>\n";

                1;
            }
            or do
            {
                logMessage("Note:       Problem parsing $imageInfoFileName.");
                logError("Problem parsing $imageInfoFileName");
            };
        }


        # words-file
        my $wordsFileName = $filePath . "$baseName-words.html";
        if (-e $wordsFileName)
        {
            if (open(WORDSFILE, "<:encoding(iso-8859-1)", $wordsFileName))
            {
                while (<WORDSFILE>)
                {
                    my $line =  $_;
                    if ($line =~ /<td id=textWordCount>([0-9]+)/)
                    {
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
    }

    print XMLFILE "  </book>\n";
}


sub escapeXml($)
{
    my $data = shift;

    $data =~ s/&/&amp;/sg;
    $data =~ s/</&lt;/sg;
    $data =~ s/>/&gt;/sg;
    $data =~ s/"/&quot;/sg;

    return $data;
}


#
# Write HTML entry.
#
sub writeHtmlEntry()
{

}


sub logError($)
{
    my $message = shift;
    print STDERR "ERROR: $message\n";
}


sub logMessage($)
{
    my $message = shift;
    print REPORTFILE "$message\n";
}


sub formatBytes($)
{
    my $num = shift;
    my $kb = 1024;
    my $mb = (1024 * 1024);
    my $gb = (1024 * 1024 * 1024);

    ($num > $gb) ? return sprintf("%d GB", $num / $gb) :
    ($num > $mb) ? return sprintf("%d MB", $num / $mb) :
    ($num > $kb) ? return sprintf("%d KB", $num / $kb) :
    return $num . ' B';
}


#
# isNewer -- determine whether the first file exists and is newer than the second file
#
sub isNewer($$)
{
    my $file1 = shift;
    my $file2 = shift;

    return (-e $file1 && -e $file2 && stat($file1)->mtime > stat($file2)->mtime)
}
