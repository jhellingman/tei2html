# idNotes.pl -- give footnotes ids based on de page and number they have

use strict;
use warnings;
use SgmlSupport qw/getAttrVal/;

my $inputFile = $ARGV[0];
my $pageNumber = 0;
my $appNoteNumber = 0;

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
        $appNoteNumber = 0;
        $pageNumber = getAttrVal('n', $pbAttrs);
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

        my $spacer = "";

        my $noteNumber = getAttrVal('n', $noteAttrs);
        my $notePlace = getAttrVal('place', $noteAttrs);
        my $noteId = getAttrVal('id', $noteAttrs);
        my $noteLang = getAttrVal('lang', $noteAttrs);
        my $noteLangAttr = $noteLang ne '' ? " lang=\"$noteLang\"" : '';
        my $newNoteTag = $noteTag;
        if ($pageNumber =~ m/[clxvi]+/) {
            $spacer = ".";
        } else {
            $spacer = "";
        }
        if ($noteNumber =~ m/([0-9]+|[A-Z])/ and $noteId eq '' and ($notePlace eq '' or $notePlace eq 'foot')) {
            $newNoteTag = "<note n=$noteNumber id=n$spacer$pageNumber.$noteNumber$noteLangAttr>";
        }
        if ($noteId eq '' and $notePlace eq 'apparatus') {
            $appNoteNumber++;
            $newNoteTag = "<note place=apparatus id=an$pageNumber.$appNoteNumber$noteLangAttr>";
        }

        print STDERR "$noteTag    ->    $newNoteTag\n";
        print $before;
        print $newNoteTag;
    }
    print $remainder;
}
