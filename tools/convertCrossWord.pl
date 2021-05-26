# convertCrossWord.pl -- convert cross-word to TEI format.

use strict;
use warnings;
use SgmlSupport qw/getAttrVal/;

if (!defined $ARGV[0]) {
    die "Usage: convertCrossWord.pl <filename>"
}
my $inputFile = $ARGV[0];

main();

sub main {
    open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

    my $mode = 0;
    while (<INPUTFILE>) {
        my $line = $_;

        if ($line =~ m/\[crossword\]/) {
            $line = "<table rend=crossword>\n";
            $mode = 1;
        }

        if ($line =~ m/\[\/crossword]/) {
            $line = "</table>\n";
            $mode = 0;
        }

        #   |~      non-bordered cell       <cell rend=blank>
        #   |       bordered cell           <cell>
        #   |#      black cell              <cell rend=black>
        #   |%      shaded cell             <cell rend=shaded>

        if ($mode == 1) {
            $line =~ s/[:]/<cell rend=blank>/g;
            $line =~ s/[|]\s*[~]+/<cell rend=blank>/g;
            $line =~ s/[|]\s*[#]+/<cell rend=black>/g;
            $line =~ s/[|]\s*[%]+/<cell rend=shaded>/g;
            $line =~ s/[|]\s*\n/\n/g;
            $line =~ s/[|]/<cell>/g;

            $line =~ s/^\s*<cell/<row><cell/g;
        }

        print $line;
    }
}
