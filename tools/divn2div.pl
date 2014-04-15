# divn2div.pl -- change from numbered to unnumbered TEI divs.

use strict;

my $inputFile = $ARGV[0];

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

print STDERR "Handling $inputFile\n";

my $previousLevel = 0;

while (<INPUTFILE>)
{
    my $remainder = $_;

    if ($remainder =~ m/<(body|front|back)(.*?)>/i)
    {
        $previousLevel = 0;
    }

    while ($remainder =~ m/<div([0-9])(.*?)>/i)
    {
        my $before = $`;
        my $level = $1;
        my $attrs = $2;
        $remainder = $';

        my $close = $previousLevel - $level;
        $previousLevel = $level;
        for ( ; $close >= 0; $close--)
        {
            print "</div>";
        }
        print "<div$attrs>";
    }
    print $remainder;
}
