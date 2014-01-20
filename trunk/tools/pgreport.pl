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

my $reportFile = "pgreport.txt";

open(REPORTFILE, "> $reportFile") || die("Could not open $reportFile");

my %excluded =
    (
        "TEI-template-NL", 1,
        "TEI-template-EN", 1
    );

my $sevenZip = "\"C:\\Program Files\\7-Zip\\7z\"";

my $directory = $ARGV[0];

sub listRecursively($);

listRecursively($directory);

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

    logMessage("---------------------");
    logMessage("File:       $fileName$suffix");
    if (defined ($version))
    {
        logMessage("Version:    $version");
    }
    logMessage("File Size:  " . formatBytes($fileSize));
    logMessage("Date:       $fileDate");
    logMessage("Path:       $filePath");

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
                my $pgNum = $xpath->find('/TEI.2/teiHeader/fileDesc/publicationStmt/idno[@type="PGnum"]');
                my $epubId = $xpath->find('/TEI.2/teiHeader/fileDesc/publicationStmt/idno[@type="epub-id"]');
                my $pgClearance = $xpath->find('/TEI.2/teiHeader/fileDesc/publicationStmt/idno[@type="PGclearance"]');
                my $postedDate = $xpath->find('/TEI.2/teiHeader/fileDesc/publicationStmt/date');
                my $language = $xpath->find('/TEI.2/@lang');

                logMessage("Title:      $title");
                for my $author ($authors->get_nodelist())
                {
                    logMessage("Author:     " . $author->string_value());
                }
                logMessage("Language:   $language");
                logMessage("ePub ID:    $epubId");
                logMessage("PG Number:  $pgNum");
                logMessage("Clearance:  $pgClearance");
                logMessage("Posted:     $postedDate");

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
                }

                1;
            }
            or do
            {
                logMessage("Note:       Problem parsing $xmlFileName.");
                logError("Problem parsing $xmlFileName");
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
                        logMessage("Words:      $wordCount");
                        last;
                    }
                }
                close WORDSFILE;
            }
        }
    }
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
