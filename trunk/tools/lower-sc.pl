# lower-sc.pl -- make words between <sc>...</sc> lowercase;

use warnings;
use strict;
use Encode qw(encode decode);

my $encoding = 'latin-1';

my $infile = $ARGV[0]; 
open(INPUTFILE, $infile) || die("Could not open input file $infile");

while (<INPUTFILE>)
{
    my $remainder = $_;
    while ($remainder =~ /<sc>(.*?)<\/sc>/)
    {
        print $`;
        $remainder = $';
        my $smallcaps = decode($encoding, $1);
        print "<sc>" . lc($smallcaps) . "</sc>";
    }
    print $remainder;
}
