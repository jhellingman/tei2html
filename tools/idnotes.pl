# idnotes.pl -- give footnotes ids base on de page and number they have

use strict;

my $inputFile = $ARGV[0];
my $pageNumber = 0;

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

print STDERR "Adding ids to footnotes in $inputFile\n";

while (<INPUTFILE>) {
    my $remainder = $_;
    while ($remainder =~ m/(<pb\b(.*?)>)/) {
        my $before = $`;
        my $pbTag = $1;
        my $pbAttrs = $2;
        $remainder = $';

        idNotes($before, $pageNumber);
        $pageNumber = getAttrVal("n", $pbAttrs);
        print $pbTag;
    }
    idNotes($remainder, $pageNumber);
}

sub idNotes($$) {
    my $remainder = shift;
    my $pageNumber = shift;

    while ($remainder =~ m/(<note\b(.*?)>)/) {
        my $before = $`;
        my $noteTag = $1;
        my $noteAttrs = $2;
        $remainder = $';

        my $noteNumber = getAttrVal("n", $noteAttrs);
        my $notePlace = getAttrVal("place", $noteAttrs);
        my $noteId = getAttrVal("id", $noteAttrs);
        my $newNoteTag = $noteTag;
        if ($noteNumber =~ m/([0-9]+|[A-Z])/ and $noteId eq '' and ($notePlace eq '' or $notePlace eq 'foot')) {
            $newNoteTag = "<note n=$noteNumber id=n$pageNumber.$noteNumber>";
        }

        print STDERR "$noteTag    ->    $newNoteTag\n";
        print $before;
        print $newNoteTag;
    }
    print $remainder;
}


#
# getAttrVal: Get an attribute value from a tag (if the attribute is present)
#
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
