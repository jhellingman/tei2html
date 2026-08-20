#!/usr/bin/perl -w

# wipeIds.pl -- wipe superfluous ids from an HTML document.

use v5.36;

use SgmlSupport qw/getAttrVal/;

my $inputFile = $ARGV[0];
open my $fh, '<', $inputFile or die "Could not open $inputFile: $!";

my %refHash = ();

# Collect IDs being referenced in the file.
while (<$fh>) {
    my $line = $_;
    my $remainder = $line;
    while ($remainder =~ m/<(.*?)>/) {
        my $tag = $1;
        $remainder = $';
        my $href = getAttrVal('href', $tag);

        if ($href =~ m/^#([a-z][a-z0-9._-]*)$/i) {
            my $ref = $1;
            $refHash{$ref}++;
        }

        # Handle IDs referenced in in-line CSS.
        if ($tag =~ m/^style\b/i) {
            my $css = '';

            # parse CSS rules for ID selectors until </style>
            while (<$fh>) {
                if ($_ =~ m/<\/style>/si) {
                    $css .= $`;
                    $remainder = $';
                    last;
                } else {
                    $css .= $_;
                }
            }

            my @refs = $css =~ m/#([a-z][a-z0-9._-]+)/gsi;
            foreach my $ref (@refs) {
                $refHash{$ref}++;
            }
        }
    }
}

close $fh;

open my $fh2, '<', $inputFile or die "Could not open $inputFile: $!";

# Remove all unused IDs.
while (<$fh2>) {
    my $remainder = $_;
    my $output = '';
    while ($remainder =~ m/<(.*?)>/) {
        $output .= $`;
        my $tag = $1;
        $remainder = $';
        my $id = getAttrVal('id', $tag);

        if ($id ne '') {
            if (!$refHash{$id}) {
                $tag =~ s/id=\"$id\"//;
            }
        }
        $tag =~ s/\s+/ /g;
        $tag =~ s/\s+$//;

        $output .= "<$tag>";
    }
    $output .= $remainder;

    # remove useless (in HTML) namespace declarations.
    $output =~ s/xmlns(:\w+)?=\"(.*?)\"//g;

    # normalize <br></br> tags:
    $output =~ s/<br><\/br>/<br\/>/g;

    # Remove empty anchors:
    $output =~ s/<a><\/a>//g;

    # Remove multiple spaces:
    $output =~ s/[\t ]+/ /g;

    # Remove end-of-line spaces:
    $output =~ s/[\t ]*$//g;

    # Remove initial spaces:
    $output =~ s/^[\t ]*//g;

    if ($output !~ /^[\t ]*$/) {
        print $output;
    }
}

close $fh2;
