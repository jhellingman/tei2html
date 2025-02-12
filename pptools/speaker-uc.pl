# speaker-uc.pl -- script to make heads and speakers in drama uppercase.

use strict;
use warnings;

my $inputFile = $ARGV[0];

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

print STDERR "Handling $inputFile\n";

while (<INPUTFILE>) {
    my $line = $_;
    $line = speakerUpperCase($line);
    $line = headUpperCase($line);
    print $line;
}

sub speakerUpperCase($) {
    my $remainder = shift;
    my $result = "";
    while ($remainder =~ /(<speaker>.*?<\/speaker>)/) {
        $result .= $`;
        $result .= upperCaseTextContent($1);
        $remainder = $';
    }
    $result .= $remainder;
    return $result;
}

sub headUpperCase($) {
    my $remainder = shift;
    my $result = "";
    while ($remainder =~ /(<head>.*?<\/head>)/) {
        $result .= $`;
        $result .= upperCaseTextContent($1);
        $remainder = $';
    }
    $result .= $remainder;
    return $result;
}

sub upperCaseTextContent() {
    my $remainder = shift;
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
