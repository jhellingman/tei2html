#!/usr/bin/perl -w

#
# Convert various types of archives to 7zip archives.
#

use strict;
use File::Basename;
use File::Temp;

my $sevenZip = "\"C:\\Program Files\\7-Zip\\7z\"";

my $errorCount = 0;
my $totalOriginalSize = 0;
my $totalResultSize = 0;
my $archivesConverted = 0;

my $outputPath = "to7zip-output";
my $logFile = "to7zip.log";

sub main();

main();

sub main()
{
    ## initial call ... $ARGV[0] is the first command line argument
    list_recursively($ARGV[0]);

    print "Number of archives:        $archivesConverted\n";
    if ($errorCount > 0)
    {
        print "Number of errors:          $errorCount\n";
    }
    if ($archivesConverted > 0)
    {
        print "Original size of archives: $totalOriginalSize bytes (" . formatBytes($totalOriginalSize) . ")\n";
        print "New size of archives:      $totalResultSize bytes (" . formatBytes($totalResultSize) . ")\n";
        my $savedBytes = $totalOriginalSize - $totalResultSize;
        my $percentage = $totalOriginalSize != 0 ? ($savedBytes / $totalOriginalSize) * 100 : 0;
        print "Space saved:               $savedBytes bytes (" . formatBytes($savedBytes) . "; $percentage %)\n";
    }
}

sub list_recursively($);

sub list_recursively($)
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
            handle_file("$directory\\$file");
        }
        elsif (-d "$directory\\$file")
        {
            list_recursively("$directory\\$file");
        }
    }
}


sub handle_file($)
{
    my ($file) = @_;

    if ($file =~ m/^(.*)\.(zip|rar|tar|tar\.gz)$/)
    {
        my $path = $1;
        my $extension = $2;
        my $base = basename($file, '.' . $extension);
        my $outputArchive = "$outputPath\\$path.7z";

        if (-e "$outputArchive")
        {
            logMessage("Skipping $file: output \"$outputArchive\" exists.");
            # No early return as we are still counting the sizes (probably results from a previous run)
        }
        else
        {
            logMessage("Converting: $file.");

            my $tmpDir = File::Temp->newdir();
            my $tmpDirName = $tmpDir->dirname;

            my $returnCode = system ("$sevenZip x -aou -r \"$file\" -o$tmpDirName 1>>$logFile");
            if ($returnCode != 0)
            {
                logError("7z returned $returnCode while extracting $file.");
            }
            else
            {
                my $packDir = $tmpDirName;

                # Sometimes, an archive contains a single folder with the same name as the archive
                # itself, and everything else is stored inside that folder. In that case, we
                # include the contents of the folder, but not the folder itself.
                if (-d "$tmpDirName\\$base")
                {
                    my @files = <$tmpDirName\\$base>;
                    my $fileCount = @files;
                    if ($fileCount == 1)
                    {
                        logMessage("Lifting contents from single top-level directory.");
                        $packDir = "$tmpDirName\\$base";
                    }
                }

                # Before recompressing the files, we could do the following:
                # 1. Run pngcrush on all .png image files
                # 2. Run gif optimizer on all .gif image files
                # 3. Run jpeg optimizer on all jpeg image files
                # 4. Remove unwanted files, such as Thumbs.db, desktop.ini, *.bak, ~* files.
                # 5. Unpack contained archives into their own directory, taking care
                #    not to create unneccessary directory levels.

                if (1 == 1)
                {
                    # Further compress images in the archive if possible
                    system ("perl optimg.pl \"$packDir\" 1>>$logFile");
                }

                # Further compression improvements will be possible by using the PPMd
                # method for text (and html) files.

                # print "Creating output archive: $path.7z\n";
                my $returnCode = system ("$sevenZip a -mx9 -r \"$outputArchive\" $packDir\\* 1>>$logFile");
                if ($returnCode != 0)
                {
                    logError("7z returned $returnCode while creating $outputArchive.");
                }
            }
        }

        my $originalSize = -s $file;
        my $resultSize = -s $outputArchive;
        $archivesConverted++;
        $totalOriginalSize += $originalSize;
        $totalResultSize += $resultSize;
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
    print "$logMessage\n";
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
