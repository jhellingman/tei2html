# fixNotes.pl -- fix (renumber) notes in text files

$inputFile          = $ARGV[0];
$firstNoteNumber    = $ARGV[1];

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

print STDERR "Verifying and remnumbering notes in $inputFile\n";

$nPreviousNoteNumber = 0;
$nNewNoteNumber = $firstNoteNumber;

while (<INPUTFILE>)
{
    $line = $_;
    $remainder = $line;
    while ($remainder =~ m/\[([0-9]*)\]/)
    {
        $before = $`;
        $nOriginalNoteNumber = $1;
        $remainder = $';

        print STDERR "Seen [$nOriginalNoteNumber]\n";

        if ($nOriginalNoteNumber != $nPreviousNoteNumber + 1) 
        {
            if ($nOriginalNoteNumber == 1) 
            {
                print STDERR "Restarting new note count with $firstNoteNumber (notes section reached)\n";
                $nNewNoteNumber = $firstNoteNumber;
            }
            else
            {
                print STDERR "Note numbers not in order: $nOriginalNoteNumber follows $nPreviousNoteNumber\n";
            }
        }
        $nPreviousNoteNumber = $nOriginalNoteNumber;

        print $before . "[" . $nNewNoteNumber . "]";

        $nNewNoteNumber++;
    }
    print $remainder;
}
