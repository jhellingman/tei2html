#!/usr/bin/perl -w

#
# Test JPEG files in directories.
#

use strict;
use warnings;
use File::Basename;
use Image::Magick;

sub list_recursively($);

sub list_recursively($) {
    my ($directory) = @_;
    my @files = (  );

    unless (opendir(DIRECTORY, $directory)) {
        print "Cannot open directory $directory!\n";
        exit;
    }

    # Read the directory, ignoring special entries "." and ".."
    @files = grep (!/^\.\.?$/, readdir(DIRECTORY));

    closedir(DIRECTORY);

    foreach my $file (@files) {
        if (-f "$directory\\$file") {
            handle_file("$directory\\$file");
        } elsif (-d "$directory\\$file") {
            list_recursively("$directory\\$file");
        }
    }
}


sub handle_file($) {
    my ($file) = @_;
    if ($file =~ m/^(.*)\.(jpg|png|gif)$/) {
        my $image = new Image::Magick;
        my $error = $image->Read($file);
        if ($error) {
            print "BROKEN $file\n";
        } else {
            print "OK     $file\n";
        }
    }
}


sub main() {
    ## initial call ... $ARGV[0] is the first command line argument
    my $file = $ARGV[0];

    if (!defined $file) {
        $file = ".";
    }
    if (-d $file) {
        list_recursively($file);
    } else {
        handle_file($file);
    }
}


main();
