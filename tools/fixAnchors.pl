# fixAnchors.pl -- provide Anchors with sequential numbers per page in TEI tagged files
#
# 1. sequence of numbers
# 2. average size of pages with large deviations

use strict;
use Roman;          # Roman.pm version 1.1 by OZAWA Sakuro <ozawa@aisoft.co.jp>

my $inputFile   = $ARGV[0];
my $currentPage = 0;
my $currentAnchor = 1;
my $prefix = "a";


open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

print STDERR "Fixing anchors in $inputFile\n";

while (<INPUTFILE>)
{
    my $line = $_;
    my $remainder = $line;
    while ($remainder =~ m/<pb(.*?)>/)
    {
        my $before = $`;
        my $attrs = $1;
        $remainder = $';
        handleAnchors($before);
        print "<pb$1>";
        $currentAnchor = 1;
        $currentPage = getAttrVal("n", $attrs);
        my $currentPage = isroman($currentPage) ? arabic($currentPage) : $currentPage;
    }
    handleAnchors($remainder);
}


sub handleAnchors($) {
    my $remainder = shift;
    while ($remainder =~ m/<anchor(.*?)>/)
    {
        my $before = $`;
        my $attrs = $1;
        $remainder = $';
        print $before;
        print "<anchor id=$prefix$currentPage.$currentAnchor>";
        if ($remainder =~ m/<ab type=lineNum>([0-9]+)<\/ab>/) {
            my $lineNum = $1;
            if ($lineNum != $currentAnchor) {
                print STDERR "WARNING: anchor at $currentPage.$currentAnchor doesn't match lineNum: $lineNum\n";
            }
        }
        $currentAnchor++;
    }
    print $remainder;
}

sub isnum($)
{
    my $str = shift;
    return $str =~ /^[0-9]+$/;
}



#
# getAttrVal: Get an attribute value from a tag (if the attribute is present)
#
sub getAttrVal($$)
{
    my $attrName = shift;
    my $attrs = shift;
    my $attrVal = "";

    if ($attrs =~ /$attrName\s*=\s*(\w+)/i)
    {
        $attrVal = $1;
    }
    elsif ($attrs =~ /$attrName\s*=\s*\"(.*?)\"/i)
    {
        $attrVal = $1;
    }
    return $attrVal;
}
