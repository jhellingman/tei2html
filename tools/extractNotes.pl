# extractNotes.pl -- extract notes from TEI tagged files
#
# Extract occurances of footnotes in TEI tagged files to a separate foot-note file, with links back to the
# original note locations. This code depends on valid TEI.

use strict;

my $inputFile = $ARGV[0];
my $outputFile = $inputFile . ".out";
my $notesFile = $inputFile . ".notes";

my $noteNumber = 0;
my $seqNumber = 0;
my $pageNumber = 0;


open(INPUTFILE, $inputFile) || die("Could not open $inputFile");
open(OUTPUTFILE, "> $outputFile") || die("Could not open $outputFile");
open(NOTESFILE, "> $notesFile") || die("Could not open $notesFile");

print NOTESFILE "\n\nNOTES\n\n";


my $prevPageNumber = "";

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

        $noteNumber = getAttrVal("n", $attributes);
        my $notePlace = getAttrVal("place", $attributes);

        print OUTPUTFILE $beforeNote;

        # match the last <pb> tag before the note
        if ($beforeNote =~ /.*<(pb\b.*?)>/) {
            my $tag = $1;
            $pageNumber = getAttrVal("n", $tag);
        }

        # Find the end of the note
        my $nestingLevel = 0;
        my $endFound = 0;
        while ($endFound == 0) {
            if ($remainder =~ m/<(\/?note)\b(.*?)>/) {
                my $beforeTag = $`;
                my $noteTag = $1;
                $remainder = $';

                if ($noteTag eq "note") {
                    $nestingLevel++;
                    $noteText .= $beforeTag . " ((";
                    print "WARNING: Nested notes on page $pageNumber rendered in-line (check for '((')\n";
                } elsif ($noteTag eq "\/note") {
                    if ($nestingLevel == 0) {
                        $endFound = 1;
                        $noteText .= $beforeTag;
                    } else {
                        $nestingLevel--;
                        $noteText .= $beforeTag . ")) ";
                    }
                }
            } else {
                # Get the next line
                $remainder .= <INPUTFILE>;
            }
        }

        if ($noteText =~ /^\W*$/) {
            print "WARNING: (almost) empty note '$noteText' on page $pageNumber (n=$noteNumber)\n";
        }

        if ($notePlace ne "margin") {
            $seqNumber++;
            print OUTPUTFILE " [$seqNumber]";
            print NOTESFILE "[$seqNumber] $noteText\n\n"
        } else {
            print OUTPUTFILE "[$noteText] ";
        }
    }

    # match the last <pb> tag after the note (or on the line if there is no note).
    if ($remainder =~ /.*<(pb.*?)>/) {
        my $tag = $1;
        $pageNumber = getAttrVal("n", $tag);
    }

    print OUTPUTFILE $remainder;
}


sub getAttrVal($$) {
    my $attrName = shift;
    my $attrs = shift;
    my $attrVal = "";

    if ($attrs =~ /$attrName\s*=\s*(\w+)/i) {
        $attrVal = $1;
    } elsif ($attrs =~ /$attrName\s*=\s*\"(.*?)\"/i) {
        $attrVal = $1;
    }
    return $attrVal;
}

