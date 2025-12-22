# convertDraughtsDiagram.pl -- convert draughts diagrams to TEI format.

use strict;
use warnings;
use SgmlSupport qw/getAttrVal/;

if (!defined $ARGV[0]) {
    die "Usage: convertDraughtsDiagram.pl <filename>"
}
my $inputFile = $ARGV[0];

main();

# [DRAUGHTS]
#       +---+---+---+---+---+---+---+---+
#       |###|   |###|   |###|   |###|   |
#       +---+---+---+---+---+---+---+---+
#       |   |###|   |###|   |###|   |###|
#       +---+---+---+---+---+---+---+---+
#       |###|   |###|   |###|   |###|   |
#       +---+---+---+---+---+---+---+---+
#       |   |###|   |###|   |###|   |###|
#       +---+---+---+---+---+---+---+---+
#       |###|   |###|   |###|   |###|   |
#       +---+---+---+---+---+---+---+---+
#       |   |###|   |###|   |###|   |###|
#       +---+---+---+---+---+---+---+---+
#       |###|   |###|   |###|   |###|   |
#       +---+---+---+---+---+---+---+---+
#       |   |###|   |###|   |###|   |###|
#       +---+---+---+---+---+---+---+---+
# [/DRAUGHTS]

sub main {
    open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

    my $mode = 0;
    while (<INPUTFILE>) {
        my $line = $_;

        if ($line =~ m/\[DRAUGHTS\]/) {
            $line = "<table rend=draughts>\n";
            $mode = 1;
        }

        if ($line =~ m/\[\/DRAUGHTS]/) {
            $line = "</table>\n";
            $mode = 0;
        }

        #   |       white square            <cell>
        #   |#      black square            <cell rend=black>
        #   |w      white man               <cell>&#x26C0;
        #   |W      white king              <cell>&#x26C1;
        #   |k      black man               <cell>&#x26C2;
        #   |K      black king              <cell>&#x26C3;
        #   |0..9+  numbered square         <cell>        
        #   +---    horizontal line         (removed)

        if ($mode == 1) {
            $line =~ s/[:]/<cell rend=blank>/g;
            $line =~ s/[:]\s*\n/\n/g;

            $line =~ s/[|]\s*[#]+/<cell rend=black>/g;
            $line =~ s/[|]\s*\n/\n/g;
            $line =~ s/[|]/<cell>/g;

            $line =~ s/^\s*<cell/<row><cell/g;

            $line =~ s/<cell> *w */<cell rend=wp>\&#x26C0; /g;
            $line =~ s/<cell> *W */<cell rend=wp>\&#x26C1; /g;
            $line =~ s/<cell> *b */<cell rend=bp>\&#x26C2; /g;
            $line =~ s/<cell> *B */<cell rend=bp>\&#x26C3; /g;

            $line =~ s/<cell> *([0-9a-zA-Z]+)/<cell>$1/g;

            $line =~ s/([+]-+)+[+]\n?//g;
        }

        print $line;
    }
}
