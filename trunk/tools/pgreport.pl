#!/usr/bin/perl -w

#
# Report / process on the Project Gutenberg files.
#

use strict;
use warnings;

binmode(STDOUT, ":utf8");
use open ':utf8';

use File::Basename;
use File::Temp;
use Cwd;
use XML::XPath;

use Date::Format;

my $reportFile = "pgreport.txt";

open(REPORTFILE, "> $reportFile") || die("Could not open $reportFile");

my %excluded = 
	(
		"AlberunisIndia", 1,
		"TEI-template-NL", 1,
		"TEI-template-EN", 1,
		"1917-Inhoud", 1
	);

my $sevenZip = "\"C:\\Program Files\\7-Zip\\7z\"";

my $errorCount = 0;
my $totalOriginalSize = 0;
my $totalResultSize = 0;
my $archivesConverted = 0;

my $outputPath = "project-gutenberg-report.txt";
my $logFile = "project-gutenberg-report.log";

sub main();

main();

sub main()
{
    ## initial call ... $ARGV[0] is the first command line argument
    listRecursively($ARGV[0]);
}


sub listRecursively($);

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
    my $fileDate = time2str("%Y-%m-%d", (stat $fullName)[9]);

    my ($fileName, $filePath, $suffix) = fileparse($fullName, '.tei');

    $fileName =~ /^([A-Za-z0-9-]*?)(-([0-9]+\.[0-9]+))?$/;
    my $baseName    = $1;
    my $version     = $3;

    logError("---------------------");
    logError("File:       $fileName$suffix");

    logMessage("---------------------");
    logMessage("File:       $fileName$suffix");
    logMessage("Version:    $version");
    logMessage("Size:       " . formatBytes($fileSize));
    logMessage("Date:       $fileDate");
    logMessage("Path:       $filePath");

    if (-e $filePath . "/metadata.xml") 
    {
        # logMessage("METADATA");
    }

	my $xmlFileName = $filePath . "$baseName.xml";

	if (defined ($version) && $version > 0.0 && !$excluded{$baseName} == 1)
	{
		if (!-e $xmlFileName || -M $xmlFileName > 1)
		{
			my $cwd = getcwd;
			chdir ($filePath);
			system ("perl -S tei2html.pl -x -f $fileName$suffix");
			chdir ($cwd);
		}

		if (-e $xmlFileName)
		{
			# logMessage("XML File:   $xmlFileName");
			my $xpath = XML::XPath->new(filename => $xmlFileName);

			my $title = $xpath->find('/TEI.2/teiHeader/fileDesc/titleStmt/title');
			my $authors = $xpath->find('/TEI.2/teiHeader/fileDesc/titleStmt/author');
			my $pgNum = $xpath->find('/TEI.2/teiHeader/fileDesc/publicationStmt/idno[@type="PGnum"]');
			my $epubId = $xpath->find('/TEI.2/teiHeader/fileDesc/publicationStmt/idno[@type="epub-id"]');
			my $postedDate = $xpath->find('/TEI.2/teiHeader/fileDesc/publicationStmt/date');

			logMessage("Title:      $title");
			# logMessage("Authors:    " . $authors);
			for my $author ($authors->get_nodelist()) 
			{
				logMessage("Author:     " . $author->string_value());
			}

			logMessage("ePub ID:    $epubId");
			logMessage("PG Number:  $pgNum");
			logMessage("Posted:     $postedDate");
		}
	}
}

sub logError($)
{
    my $logMessage = shift;
    $errorCount++;
    print STDERR "ERROR: $logMessage\n";
}

sub logMessage($)
{
    my $logMessage = shift;
    print REPORTFILE "$logMessage\n";
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
