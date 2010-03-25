#!/usr/bin/perl -w

#
# Convert various types of archives to 7zip archives.
#

use strict;
use File::Basename;

my $sevenZip = "\"C:\\Program Files\\7-Zip\\7z\"";
my $temp = $ENV{'TMP'};
if (!$temp)
{
    $temp = $ENV{'TMPDIR'};
}
if (!$temp)
{
    $temp = "D:\\Temp";
}

my $errorCount = 0;
my $totalOriginalSize = 0;
my $totalResultSize = 0;
my $archivesConverted = 0;


main();

sub main()
{
    ## initial call ... $ARGV[0] is the first command line argument
    list_recursively($ARGV[0]);

    print "Number of archives:        $archivesConverted\n";
    print "Number of errors:          $errorCount\n";
    print "Original size of archives: $totalOriginalSize bytes (" . formatBytes($totalOriginalSize) . ")\n";
    print "New size of archives:      $totalResultSize bytes (" . formatBytes($totalResultSize) . ")\n";
    my $savedBytes = $totalOriginalSize - $totalResultSize;
    my $percentage = ($savedBytes / $totalOriginalSize) * 100;
    print "Space saved:               $savedBytes bytes (" . formatBytes($savedBytes) . "; $percentage %)\n";
}



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
                    my @files = <$tempDir\\$base>;
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
                # 4. Remove unwanted files, such as Thumbs.db, desktop.ini, *.bak, ~* files.
                # 5. Unpack contained archives into their own directory, taking care
                #    not to create unneccessary directory levels.

                if (1 == 1) 
                {
                    # Further compress images in the archive if possible
                    system ("perl optimg.pl \"$packDir\"");
                }

                # Further compression improvements will be possible by using the PPMd
                # method for text (and html) files.

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




sub formatBytes($)
{
    my $num = shift;
    my $kb = 1024;
    my $mb = (1024 * 1024);
    my $gb = (1024 * 1024 * 1024);

    ($num > $gb) ? return sprintf("%d GB", $num/$gb) :
    ($num > $mb) ? return sprintf("%d MB", $num/$mb) :
    ($num > $kb) ? return sprintf("%d KB", $num/$kb) :
    return $num . ' B';
}


