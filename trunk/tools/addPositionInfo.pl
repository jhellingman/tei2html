# addPositionInfo.pl -- add linenumber and column info to SGML/XML files

use strict;

my $inputFile = $ARGV[0];

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

print STDERR "Adding pos attributes to $inputFile\n";

my $lineNumber = 0;

while (<INPUTFILE>)
{
    my $remainder = $_;
    $lineNumber++;
    my $column = 0;

    while ($remainder =~ m/<([a-z][a-z0-9.:_-]*)(.*?)>/i)
    {
        my $before = $`;
        my $tag = $1;
        my $attrs = $2;
        $remainder = $';
        $column += length "$before";

        # Filter out special transcription tags.
        if ($tag ne 'GR') 
        {
            $attrs = " pos='$lineNumber:$column'$attrs";
        }
        print "$before<$tag$attrs>";

        # Do not count added attribute, as it is not in the source.
        $column += length "<$tag$attrs>";
    }
    print $remainder;
}
