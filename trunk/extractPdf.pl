#!/usr/bin/perl -w

#
# Extract images from JPEG files in directories.
#

use strict;
use File::Basename;

my $pdfimages = "pdfimages.exe"; # See http://www.foolabs.com/xpdf/download.html
my $pdfcount = 1000;

sub list_recursively($);

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
    if ($file =~ m/^(.*)\.(pdf)$/)
    {
        my $path = $1;
        my $extension = $2;
        my $base = basename($file, '.' . $extension);
        my $dirname = dirname($file);

        my $newfile = $dirname . '\\' . $base . '-copy.' . $extension;

        print "Extracting images from PDF: $file\n";

        if ($extension eq 'pdf')
        {
            $pdfcount++;
            # print "$pdfimages -j $file $pdfcount\n";
            my $returnCode = system ("$pdfimages -j \"$file\" $pdfcount");
        }
    }
}


sub main()
{
    ## initial call ... $ARGV[0] is the first command line argument
    list_recursively($ARGV[0]);
}


main();
