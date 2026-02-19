# convertCrossWord.pl -- convert cross-word to TEI format.

use strict;
use warnings;
use SgmlSupport qw/getAttrVal/;

my $inputFile = $ARGV[0];
my $fileHandle;

if (defined $inputFile) {
    open($fileHandle, '<', $inputFile) || die("Could not open $inputFile: $!");
} else {
    $fileHandle = \*STDIN;
}

#   [crossword]
#   | 1| 2| 3| 4| 5|  | 6| 7| 8| 9|  |
#   |##|10|  |  |  |##|11|  |  |  |##|
#   |12|  |  |##|13|14|  |##|15|  |16|
#   |17|  |##|18|  |  |  |19|##|20|  |
#   |21|  |22|  |##|  |##|23|24|  |  |
#   |  |##|25|  |  |  |  |  |  |##|  |
#   |26|27|  |  |##|  |##|28|  |29|  |
#   |30|  |##|31|32|  |33|  |##|34|  |
#   |35|  |36|##|37|  |  |##|38|  |  |
#   |##|39|  |40|  |##|41|42|  |  |##|
#   |43|  |  |  |  |  |  |  |  |  |  |
#   [/crossword]

my $mode = 0;
while (<$fileHandle>) {
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

        $line =~ s/<cell> *([0-9]+) *([A-Z]+)/<cell rend=solved><ab type=number>$1<\/ab> $2/g;
        $line =~ s/<cell> *([A-Z]+)/<cell rend=solved>$1/g;
    }
    print $line;
}

if (defined $inputFile) { 
    close $fileHandle;
}
