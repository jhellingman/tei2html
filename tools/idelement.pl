# idelement.pl -- give elements ids based on de page they are on and a sequence number

use strict;
use warnings;

use Getopt::Long;
use SgmlSupport qw/getAttrVal/;

my $elementName = "lg";
my $idPrefix = "lg";
my $force = 0;
my $showHelp = 0;

GetOptions(
    'f' => \$force,
    'n=s' => \$elementName,
    'p=s' => \$idPrefix,
    'help' => \$showHelp,
    );

if ($showHelp == 1 || !defined $ARGV[0]) {
    my $help = <<'END_HELP';
idelement.pl -- give elements ids based on de page they are on and a sequence number.

Usage: idElement.pl [-fnp] <inputfile.tei>

Options:
    f           Force: use a new id, even if an id is already present.
    n=<string>  Name of element to give ids.
    p=<string>  Prefix of newly generated ids.
END_HELP

    print $help;
    exit 0;
}


my $inputFile = $ARGV[0];
my $pageNumber = 0;
my $elementNumber = 0;

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

print STDERR "Adding ids to $elementName-elements in $inputFile\n";

while (<INPUTFILE>) {
    my $remainder = $_;
    while ($remainder =~ m/(<pb\b(.*?)>)/) {
        my $before = $`;
        my $pbTag = $1;
        my $pbAttrs = $2;
        $remainder = $';

        idElement($before, $pageNumber);
        $elementNumber = 0;
        $pageNumber = getAttrVal('n', $pbAttrs);
        print $pbTag;
    }
    idElement($remainder, $pageNumber);
}


sub idElement {
    my $remainder = shift;
    my $pageNumber = shift;

    while ($remainder =~ m/(<$elementName\b(.*?)>)/) {
        my $before = $`;
        my $tag = $1;
        my $attrs = $2;
        $remainder = $';

        my $id = getAttrVal('id', $attrs);
        my $newTag = $tag;
        if ($id eq '' || $force != 0) {
            if ($force != 0) {
                $attrs = stripAttrVal('id', $attrs);
            }
            $elementNumber++;
            $newTag = "<$elementName id=$idPrefix$pageNumber.$elementNumber$attrs>";
        }

        print STDERR "$tag    ->    $newTag\n";
        print $before;
        print $newTag;
    }
    print $remainder;
}


sub stripAttrVal {
    my $attrName = shift;
    my $attrs = shift;

    $attrs =~ s/$attrName\s*=\s*([\w.-]+)\s*//gi;
    $attrs =~ s/$attrName\s*=\s*\"(.*?)\"\s*//gi;
    $attrs =~ s/\s*\z//gi;

    return $attrs;
}