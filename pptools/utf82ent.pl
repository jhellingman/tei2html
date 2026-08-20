#!/usr/bin/perl -w

# utf82ent.pl -- convert a UTF8-encoded file to HTML entities.

use v5.36;

use utf8;
use HTML::Entities;

binmode(STDOUT, ":utf8");

my $infile = $ARGV[0];
open my $fh, '<', $infile or die "Could not open input file $infile: $!";
binmode($fh, ":encoding(utf8)");

while (<$fh>) {
    my $input = $_;
    $input = encode_entities($input);

    $input =~ s/&lt;/</g;
    $input =~ s/&gt;/>/g;
    $input =~ s/&quot;/\"/g;
    $input =~ s/&amp;#/\&#/g;

    print $input;
}

close $fh;
