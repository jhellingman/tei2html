#!/usr/bin/perl -w

use v5.36;
use open qw(:std :utf8); 

my $file = shift @ARGV;

my $fileHandle;
if (defined $file) {
    open $fileHandle, '<', $file or die "Could not open '$file': $!";
} else {
    $fileHandle = *STDIN;
}

while (<$fileHandle>) {

    my $line = $_;

    $line =~ s/<\/link>//g;
    $line =~ s/<\/meta>//g;
    $line =~ s/<\/img>//g;
    $line =~ s/<\/hr>//g;

    $line =~ s/<br\/>/<br>/g;

    $line =~ s/<style><\/style>//g;

    print $line;
}
