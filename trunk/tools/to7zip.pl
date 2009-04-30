#!/usr/bin/perl -w

use strict;
use File::Basename;

$totalOriginalSize = 0;
$totalResultSize = 0;
$archivesConverted = 0;


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

		print "Handling Archive: $file\n";


		if (-e "$path.7z")
		{
			print STDERR "Output archive \"$path.7z\" already exists.\n";
		}
		elsif (-e "c:\\temp\$base")
		{
			print STDERR "Directory \"C:\\Temp\\$base\" to extract files into already exists.\n";
		}
		else
		{
			system ("\"C:\\Program Files\\7-Zip\\7z\" x \"$file\" -oc:\\temp\\$base");
			system ("\"C:\\Program Files\\7-Zip\\7z\" a -mx9 \"$path.7z\" C:\\Temp\\$base\\*");
			system ("rmdir /S/Q C:\\Temp\\$base\\");

			my $originalSize = -s $file;
			my $resultSize = -s "$path.7z";

			$archivesConverted++;
			$totalOriginalSize += $originalSize;
			$totalResultSize += $resultSize;

		}
	}
}


## initial call ... $ARGV[0] is the first command line argument
list_recursively($ARGV[0]);

print "Number of archvies:        $archivesConverted\n";
print "Original size of archives: $totalOriginalSize\n";
print "New size of archives:      $totalResultSize\n";
