# divn2div.pl -- change from numbered to unnumbered TEI divs.

use v5.36;

my $inputFile = $ARGV[0];

open(my $fh, '<', $inputFile or die "Could not open $inputFile";

print STDERR "Handling $inputFile\n";

my $previousLevel = 0;

while (<$fh>) {
    my $remainder = $_;

    if ($remainder =~ m/<(body|front|back)(.*?)>/i) {
        $previousLevel = 0;
    }

    while ($remainder =~ m/<div([0-9])(.*?)>/i) {
        my $before = $`;
        my $level = $1;
        my $attrs = $2;
        $remainder = $';

        my $close = $previousLevel - $level;
        $previousLevel = $level;
        for ( ; $close >= 0; $close--) {
            print $before . "</div>";
        }
        print "<div$attrs>";
    }
    print $remainder;
}

close $fh;

