# fixPb.pl -- fix (renumber) page breaks in TEI tagged files
#
# 1. sequence of numbers
# 2. average size of pages with large deviations

use strict;
use Roman;          # Roman.pm version 1.1 by OZAWA Sakuro <ozawa@aisoft.co.jp>

my $inputFile   = $ARGV[0];
my $firstChange = $ARGV[1];
my $offset      = $ARGV[2];
my $useRoman     = $ARGV[3];

my $previousPage = 0;
my $currentPage = 0;
my $currentPageSize = 0;
my $totalPageSize = 0;
my $numberOfPages = 1;

my $seenFirst = 0;

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

print STDERR "Verifying $inputFile\n";

while (<INPUTFILE>)
{
    my $line = $_;
    my $remainder = $line;
    while ($remainder =~ m/<pb(.*?)>/)
    {
        my $before = $`;
        my $attrs = $1;
        $remainder = $';
        $currentPageSize += length $before;
        # print "NOTE: Page $currentPage contains $currentPageSize bytes.\n";
        $totalPageSize += $currentPageSize;
        $numberOfPages++;
        $currentPageSize = 0;
        $previousPage = $currentPage;
        $currentPage = getAttrVal("n", $attrs);
        #$currentRend = getAttrVal("rend", $pbAttrs);
        # print "TEST: $currentPage";

        my $cp = isroman($currentPage) ? arabic($currentPage) : $currentPage;
        my $pp = isroman($previousPage) ? arabic($previousPage) : $previousPage;

        if (isnum($currentPage) && $cp == $firstChange) 
        {
            $seenFirst = 1;
        }

        if ($seenFirst && isnum($currentPage)) 
        {
            my $newCurrentPage = $currentPage + $offset;
            if ($useRoman eq "R") 
            {
                $newCurrentPage = uc(roman($newCurrentPage));
            }
            print "$before<pb id=pb$newCurrentPage n=$newCurrentPage>";
        }
        else
        {
            print "$before<pb$attrs>";
        }
    }
    $currentPageSize += length $remainder;
    print $remainder;
}


sub isnum($)
{
    my $str = shift;
    return $str =~ /^[0-9]+$/;
}


# print STDERR "NOTE: Page $currentPage contains $currentPageSize bytes.\n";
# print STDERR "\n";
print STDERR "NOTE: Total number of pages: $numberOfPages\n";
print STDERR "NOTE: Total size of pages:   $totalPageSize\n";
my $averagePageSize = $totalPageSize/$numberOfPages;
print STDERR "NOTE: Average size of page:  $averagePageSize\n";



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
