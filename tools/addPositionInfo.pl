# addPositionInfo.pl -- add linenumber and column info to SGML/XML files

use strict;
use warnings;

my $file = shift @ARGV;

my $fileHandle;
if (defined $file) {
    open($fileHandle, '<', $file) or die "Could not open '$file': $!";
} else {
    $fileHandle = *STDIN;
}

my $lineNumber = 0;

while (<$fileHandle>) {
    my $remainder = $_;
    $lineNumber++;
    my $column = 0;

    while ($remainder =~ m/<([a-z][a-z0-9.:_-]*)(.*?)(\/?)>/i) {
        my $before = $`;
        my $tag = $1;
        my $attrs = $2;
        my $slash = $3;
        $remainder = $';
        $column += length "$before";

        $attrs = "$attrs pos='$lineNumber:$column'";
        print "$before<$tag$attrs$slash>";

        # Do not count length of added POS attribute, as it is not in the source.
        $column += length "<$tag$attrs$slash>";
    }
    print $remainder;
}

if (defined $file) { 
    close $fileHandle;
}
