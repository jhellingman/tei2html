# idFormula.pl -- give formula-elements ids based on de page and number they have

use strict;
use warnings;
use SgmlSupport qw/getAttrVal/;

my $inputFile = $ARGV[0];
my $pageNumber = 0;
my $lgNumber = 0;

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

print STDERR "Adding ids to formula-elements in $inputFile\n";

while (<INPUTFILE>) {
    my $remainder = $_;
    while ($remainder =~ m/(<pb\b(.*?)>)/) {
        my $before = $`;
        my $pbTag = $1;
        my $pbAttrs = $2;
        $remainder = $';

        idElement($before, $pageNumber);
        $lgNumber = 0;
        $pageNumber = getAttrVal('n', $pbAttrs);
        print $pbTag;
    }
    idElement($remainder, $pageNumber);
}

sub idElement($$) {
    my $remainder = shift;
    my $pageNumber = shift;

    while ($remainder =~ m/(<formula\b(.*?)>)/) {
        my $before = $`;
        my $tag = $1;
        my $attrs = $2;
        $remainder = $';

        my $id = getAttrVal('id', $attrs);
        my $newTag = $tag;
        if ($id eq '' || $id eq 'fXXX') {
            $lgNumber++;
            $newTag = "<formula id=f$pageNumber.$lgNumber$attrs>";
        }

        print STDERR "$tag    ->    $newTag\n";
        print $before;
        print $newTag;
    }
    print $remainder;
}
