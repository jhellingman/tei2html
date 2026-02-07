# extractNotes.pl -- extract notes from TEI tagged files
#
# Extract occurrences of footnotes in TEI tagged files to a separate foot-note file, with links back to the
# original note locations. This code depends on valid TEI following a few formatting conventions (i.e. tags 
# are always on a single line).

use strict;
use warnings;

use SgmlSupport qw/getAttrVal/;

my $inputFile = $ARGV[0];
my $outputFile = 'tmp-' . $inputFile . '.out';
my $notesFile = 'tmp-' . $inputFile . '.notes';

my $noteNumber = 0;
my $seqNumber = 0;
my $pageNumber = 0;


open(INPUTFILE, $inputFile) || die("Could not open $inputFile");
open(OUTPUTFILE, "> $outputFile") || die("Could not open $outputFile");
open(NOTESFILE, "> $notesFile") || die("Could not open $notesFile");

print NOTESFILE "\n\nNOTES\n\n";


my %mapNoteIdToSeqNumber;

while (<INPUTFILE>) {
    my $line = $_;
    my $remainder = $line;

    # Skip TeiHeader;
    if ($remainder =~ m/<(teiHeader\b.*?)>/) {
        while ($remainder !~ m/<\/teiHeader>/) {
            $remainder = <INPUTFILE>;
        }
    }

    while ($remainder =~ m/<(note\b.*?)>/) {
        my $beforeNote = $`;
        my $attributes = $1;
        $remainder = $';
        my $noteText = '';

        $noteNumber = getAttrVal('n', $attributes);
        my $notePlace = getAttrVal('place', $attributes);
        my $sameAs = getAttrVal('sameAs', $attributes);
        my $id = getAttrVal('id', $attributes);

        print OUTPUTFILE $beforeNote;

        # match the last <pb> tag before the note
        if ($beforeNote =~ /.*<(pb\b.*?)>/) {
            my $tag = $1;
            $pageNumber = getAttrVal('n', $tag);
        }

        # Find the end of the note
        my $nestingLevel = 0;
        my $endFound = 0;
        my $followingSpace = '';
        while ($endFound == 0) {
            if ($remainder =~ m/<(\/?note)\b(.*?)>([ ]*)/) {
                my $beforeTag = $`;
                my $noteTag = $1;
                my $innerAttributes = $2;
                $followingSpace = $3;
                $remainder = $';

                if ($noteTag eq 'note') {
                    $nestingLevel++;
                    $noteText .= $beforeTag . ' ((';
                    my $innerNoteNumber = getAttrVal('n', $innerAttributes);
                    print "WARNING: Nested note $innerNoteNumber on page $pageNumber rendered in-line (check for '((')\n";
                } elsif ($noteTag eq '/note') {
                    if ($nestingLevel == 0) {
                        $endFound = 1;
                        $noteText .= $beforeTag;
                    } else {
                        $nestingLevel--;
                        $noteText .= $beforeTag . ")) $followingSpace";
                    }
                }
            } else {
                # Get the next line
                $remainder .= <INPUTFILE>;
            }
        }

        if ($noteText =~ /^\W*$/ and $sameAs eq '') {
            print "WARNING: (almost) empty note '$noteText' on page $pageNumber (n=$noteNumber)\n";
        }

        if ($sameAs ne '') {
            # Lookup sequence number of original note.
            my $seqNumber = $mapNoteIdToSeqNumber{$sameAs};
            if (defined $seqNumber) {
                print OUTPUTFILE "[$mapNoteIdToSeqNumber{$sameAs}]$followingSpace";
            } else {
                print STDERR "WARNING: Note with id $sameAs not found (assumed to be earlier in the text.)\n";
            }
        } elsif ($notePlace eq 'margin' || $notePlace eq 'left' || $notePlace eq 'right' || $notePlace eq 'cut-in-left' || $notePlace eq 'cut-in-right') {
            print OUTPUTFILE "[$noteText] ";
        } else {
            $seqNumber++;
            print OUTPUTFILE " [$seqNumber]$followingSpace";
            print NOTESFILE "[$seqNumber] $noteText\n\n";

            if ($id ne '') {
                # Store sequence number of this note.
                $mapNoteIdToSeqNumber{$id} = $seqNumber;
            }
        }
    }

    # match the last <pb> tag after the note (or on the line if there is no note).
    if ($remainder =~ /.*<(pb.*?)>/) {
        my $tag = $1;
        $pageNumber = getAttrVal('n', $tag);
    }

    print OUTPUTFILE $remainder;
}
