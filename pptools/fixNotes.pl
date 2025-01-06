# fixNotes.pl -- fix (renumber) notes in text files

use strict;
use warnings;
my $inputFile          = $ARGV[0];
my $firstNoteNumber    = $ARGV[1];

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

print STDERR "Verifying and renumbering notes in $inputFile\n";

my $nPreviousNoteNumber = 0;
my $nNewNoteNumber = $firstNoteNumber;

while (<INPUTFILE>) {
    my $line = $_;
    my $remainder = $line;
    while ($remainder =~ m/\[([0-9]*)\]/) {
        my $before = $`;
        my $nOriginalNoteNumber = $1;
        $remainder = $';

        print STDERR "Seen [$nOriginalNoteNumber]\n";

        if ($nOriginalNoteNumber != $nPreviousNoteNumber + 1) {
            if ($nOriginalNoteNumber == 1) {
                print STDERR "Restarting new note count with $firstNoteNumber (notes section reached)\n";
                $nNewNoteNumber = $firstNoteNumber;
            } else {
                print STDERR "Note numbers not in order: $nOriginalNoteNumber follows $nPreviousNoteNumber\n";
            }
        }
        $nPreviousNoteNumber = $nOriginalNoteNumber;

        print $before . "[" . $nNewNoteNumber . "]";

        $nNewNoteNumber++;
    }
    print $remainder;
}
