#!/usr/bin/perl -w

# idFormula.pl -- give formula-elements ids based on de page they are on and a sequence number.

use v5.36;

use Getopt::Long;
use SgmlSupport qw/getAttrVal/;

my $idAll = 0;      # Give a new id to all formulas, not just those who don't have one.
my $prefix = 'f';   # Prefix to use for a new id: format will be <prefix><page number>.<number on page>

GetOptions(
    'a' => \$idAll,
    'p=s' => \$prefix);

my $inputFile = $ARGV[0];
my $pageNumber = 0;
my $formulaNumber = 0;

open my $fh, '<', $inputFile or die "Could not open $inputFile: $!";

print STDERR "Adding ids to formula-elements in $inputFile\n";

while (<$fh>) {
    my $remainder = $_;
    while ($remainder =~ m/(<pb\b(.*?)>)/) {
        my $before = $`;
        my $pbTag = $1;
        my $pbAttrs = $2;
        $remainder = $';

        idElement($before, $pageNumber);
        $formulaNumber = 0;
        $pageNumber = getAttrVal('n', $pbAttrs);
        print $pbTag;
    }
    idElement($remainder, $pageNumber);
}

close $fh;


sub idElement($remainder, $pageNumber) {

    while ($remainder =~ m/(<formula\b(.*?)>)/) {
        my $before = $`;
        my $tag = $1;
        my $attrs = $2;
        $remainder = $';

        my $id = getAttrVal('id', $attrs);
        my $newTag = $tag;

        if ($idAll == 1) {
            $formulaNumber++;
            my $newAttrs = stripAttribute('id', $attrs);
            $newTag = "<formula id=$prefix$pageNumber.$formulaNumber$newAttrs>";
        } elsif ($id eq '' || $id eq 'fXXX') {
            $formulaNumber++;
            $newTag = "<formula id=$prefix$pageNumber.$formulaNumber$attrs>";
        }

        print STDERR "$tag    ->    $newTag\n";
        print $before;
        print $newTag;
    }
    print $remainder;
}

sub stripAttribute($attrName, $attrs) {
    if ($attrs =~ /$attrName\s*=\s*([\w.-]+)/i) {
        $attrs =~ s/$attrName\s*=\s*([\w.-]+)//i;
    } elsif ($attrs =~ /$attrName\s*=\s*\"(.*?)\"/i) {
        $attrs =~ s/$attrName\s*=\s*\"(.*?)\"//i;
    }
    $attrs =~ s/\s+/ /;
    return $attrs;
}
