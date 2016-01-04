#!/usr/bin/perl -w

#
# Check the consistency of files.
#

use strict;
use File::Basename;
use File::Temp;

my $zip = "zip";
my $sevenZip = "\"C:\\Program Files\\7-Zip\\7z\"";
# $sevenZip = "7z";

my $logFile = "checkArchives.log";

sub main();

main();

sub main()
{
    ## initial call ... $ARGV[0] is the first command line argument
    list_recursively($ARGV[0]);
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
        if (-f "$directory/$file")
        {
            handle_file("$directory/$file");
        }
        elsif (-d "$directory/$file")
        {
            list_recursively("$directory/$file");
        }
    }
}


sub handle_file($)
{
    my ($file) = @_;

    if ($file =~ m/^(.*)\.(7z)$/)
    {
        my $returnCode = system ("$sevenZip t \"$file\" 1>>$logFile");
    }

    if ($file =~ m/^(.*)\.(zip)$/)
    {
        my $returnCode = system ("$zip -T \"$file\" 1>>$logFile");
    }
}
