#!/usr/bin/perl -w

# speaker-uc.pl -- script to make heads and speakers in drama uppercase.

use v5.36;

my $inputFile = $ARGV[0];

open my $fh, '<', $inputFile or die "Could not open $inputFile: $!";

print STDERR "Handling $inputFile\n";

while (<$fh>) {
    my $line = $_;
    $line = speakerUpperCase($line);
    $line = headUpperCase($line);
    print $line;
}

sub speakerUpperCase($remainder) {
    my $result = "";
    while ($remainder =~ /(<speaker>.*?<\/speaker>)/) {
        $result .= $`;
        $result .= upperCaseTextContent($1);
        $remainder = $';
    }
    $result .= $remainder;
    return $result;
}

sub headUpperCase($remainder) {
    my $result = "";
    while ($remainder =~ /(<head>.*?<\/head>)/) {
        $result .= $`;
        $result .= upperCaseTextContent($1);
        $remainder = $';
    }
    $result .= $remainder;
    return $result;
}

sub upperCaseTextContent($remainder) {
    my $result = "";
    while ($remainder =~ /(<.*?>)/) {
        $result .= uc($`);
        $result .= $1;
        $remainder = $';
    }
    $result .= uc($remainder);

    $result =~ s/\&IJLIG;/\&IJlig;/g;
    $result =~ s/\&APOS;/\&apos;/g;

    return $result;
}
