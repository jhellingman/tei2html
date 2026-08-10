# idNotes.pl -- give footnotes ids based on de page and number they have

use v5.36;

use SgmlSupport qw/getAttrVal/;

my $inputFile = $ARGV[0];
my $pageNumber = 0;
my $appNoteNumber = 0;

open my $fh, '<', $inputFile or die "Could not open $inputFile: $!";

print STDERR "Adding ids to footnotes in $inputFile\n";

while (<$fh>) {
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

close $fh;


sub idNotes($remainder, $pageNumber) {

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
        my $noteSameAs = getAttrVal('sameAs', $noteAttrs);
        my $noteLangAttr = $noteLang ne '' ? " lang=\"$noteLang\"" : '';
        my $noteSameAsAttr = $noteSameAs ne '' ? " sameAs=$noteSameAs" : '';
        my $newNoteTag = $noteTag;
        if ($pageNumber =~ m/[clxvi]+/) {
            $spacer = ".";
        } else {
            $spacer = "";
        }
        if ($noteNumber =~ m/([0-9]+|[A-Z])/ and $noteId eq '' and ($notePlace eq '' or $notePlace eq 'foot')) {
            $newNoteTag = "<note n=$noteNumber id=n$spacer$pageNumber.$noteNumber$noteLangAttr$noteSameAsAttr>";
        }
        if ($noteId eq '' and $notePlace eq 'apparatus') {
            $appNoteNumber++;
            $newNoteTag = "<note place=apparatus id=an$pageNumber.$appNoteNumber$noteLangAttr$noteSameAsAttr>";
        }

        print STDERR "$noteTag    ->    $newNoteTag\n";
        print $before;
        print $newNoteTag;
    }
    print $remainder;
}
