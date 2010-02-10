#!/usr/bin/perl -w

#
# Convert various types of archives to 7zip archives.
#

use strict;
use File::Basename;

my $sevenZip = "\"C:\\Program Files\\7-Zip\\7z\"";
my $temp = "C:\\Temp";

my $errorCount = 0;
my $totalOriginalSize = 0;
my $totalResultSize = 0;
my $archivesConverted = 0;


sub list_recursively($)
{
    my ($directory) = @_;
    my @files = (  );

    unless (opendir(DIRECTORY, $directory))
    {
        print "Cannot open directory $directory!\n";
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

        my $tempDir = "$temp\\$base";

        if (-e "$path.7z")
        {
            print STDERR "Skipping $file: output \"$path.7z\" exists.\n";
        }
        elsif (-e $tempDir)
        {
            print STDERR "Skipping $file: temporary directory \"$tempDir\" exists.\n";
        }
        else
        {
            print "Converting archive: $file\n";

            my $returnCode = system ("$sevenZip x -aou -r \"$file\" -o$tempDir");
            if ($returnCode != 0) 
            {
                $errorCount++;
                print STDERR "ERROR: 7z returned $returnCode while extracting $file.\n";
                system ("rmdir /S/Q $tempDir\\");
            }
            else
            {
                my $packDir = $tempDir;

                # Sometimes, an archive contains a single folder with the same name as the archive 
                # itself, and everything else is stored inside that folder. In that case, we 
                # include the contents of the folder, but not the folder itself.
                if (-d "$tempDir\\$base")
                {
                    my @files = <C:\\Temp\\$base>;
                    my $fileCount = @files;
                    if ($fileCount == 1) 
                    {
                        print "Including contents of top-level single directory\n";
                        $packDir = "$tempDir\\$base";
                    }
                }

                # Before recompressing the files, we could do the following:
                # 1. Run pngcrush on all .png image files
                # 2. Run gif optimizer on all .gif image files
                # 3. Run jpeg optimizer on all jpeg image files

                # Further compression improvements will be possible by using the PPMd
                # method for text (and html) files.

                # We should drop typical OS generated files such as Thumbs.db or desktop.ini

                my $returnCode = system ("$sevenZip a -mx9 -r \"$path.7z\" $packDir\\*");
                if ($returnCode != 0) 
                {
                    $errorCount++;
                    print STDERR "ERROR: 7z returned $returnCode while creating $path.7z.\n";
                }
                system ("rmdir /S/Q $tempDir\\");

                my $originalSize = -s $file;
                my $resultSize = -s "$path.7z";

                $archivesConverted++;
                $totalOriginalSize += $originalSize;
                $totalResultSize += $resultSize;
            }
        }
    }
}


sub main()
{
    ## initial call ... $ARGV[0] is the first command line argument
    list_recursively($ARGV[0]);

    print "Number of archives:        $archivesConverted\n";
    print "Number of errors:          $errorCount\n";
    print "Original size of archives: $totalOriginalSize bytes\n";
    print "New size of archives:      $totalResultSize bytes\n";
    print "Space saved:               " . ($totalOriginalSize - $totalResultSize) . " bytes\n";
}


main();
