# fixPb.pl -- fix (renumber) page-breaks in a TEI file.
#
# 1. sequence of numbers
# 2. average size of pages with large deviations

use strict;
use warnings;

use Roman;              # Roman.pm version 1.1 by OZAWA Sakuro <ozawa@aisoft.co.jp>
use Getopt::Long;

use SgmlSupport qw/getAttrVal/;

my $splitColumns = 0;
my $useRoman = 0;
my $first = 0;
my $last = 0;
my $offset = 0;
my $new = 0;
my $showHelp = 0;

GetOptions(
    's' => \$splitColumns,
    'r' => \$useRoman,
    'f=i' => \$first,
    'l=i' => \$last,
    'o=i' => \$offset,
    'n=i' => \$new,
    'help' => \$showHelp,
    );

my $inputFile   = $ARGV[0];

if ($new != 0) {
    $offset = -($first - $new);
}

if ($showHelp == 1 || ($offset == 0 && !$useRoman)) {
    my $help = <<'END_HELP';

fixPb.pl -- fix (renumber) page-breaks in a TEI file.

Usage: fixPb.pl [-srfloi] <inputfile.tei>

Options:
    s         Deal with split columns. Every second <pb> is replaced with <cb>. 
                After each page, the offset will be decreased by one, to restore
                the original page-numbering.
    r         Use Roman numerals.
    f=<int>   First page to adjust (based on @n attribute).
    l=<int>   Last page (this last page will not be adjusted).
    o=<int>   Offset, will be added to the original page number.
    n=<int>   New number of first page; will be used to calculate the offset.
END_HELP

    print $help;
    exit 0;
}

my $previousPage = 0;
my $currentPage = 0;
my $currentPageSize = 0;
my $totalPageSize = 0;
my $numberOfPages = 1;

my $seenFirst = 0;
my $seenLast = 0;
my $secondColumn = 0;

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

print STDERR "Verifying $inputFile\n";

while (<INPUTFILE>) {
    my $line = $_;
    my $remainder = $line;
    while ($remainder =~ m/<pb(.*?)>/) {
        my $before = $`;
        my $attrs = $1;
        $remainder = $';
        $currentPageSize += length $before;
        $totalPageSize += $currentPageSize;
        $numberOfPages++;
        $currentPageSize = 0;
        $previousPage = $currentPage;
        $currentPage = getAttrVal('n', $attrs);
        my $facs = getAttrVal('facs', $attrs);
        $facs = $facs ? " facs=\"$facs\"" : '';

        my $cp = isroman($currentPage) ? arabic($currentPage) : $currentPage;
        my $pp = isroman($previousPage) ? arabic($previousPage) : $previousPage;

        if (isnum($currentPage) && $cp == $first) {
            $seenFirst = 1;
        }
        if (isnum($currentPage) && $cp == $last) {
            $seenLast = 1;
        }
        if ($seenFirst && !$seenLast && isnum($currentPage)) {
            print $before;
            print nextPageBreak($currentPage, $facs);
        } else {
            print "$before<pb$attrs>";
        }
    }
    $currentPageSize += length $remainder;
    print $remainder;
}


sub nextPageBreak {
    my $currentPage = shift;
    my $facs = shift;

    if ($splitColumns and $secondColumn) {
        $secondColumn = 0;
        $offset -= 1;
        return "<cb>";
    }
    else {
        my $dot = '';
        my $newCurrentPage = $currentPage + $offset;
        if ($useRoman) {
            $newCurrentPage = roman($newCurrentPage);
            $dot = '.';
        }
        $secondColumn = 1;
        return "<pb id=pb$dot$newCurrentPage n=$newCurrentPage$facs>";
    }
}


sub isnum {
    my $str = shift;
    return $str =~ /^[0-9]+$/;
}


print STDERR "NOTE: Total number of pages: $numberOfPages\n";
print STDERR "NOTE: Total size of pages:   $totalPageSize\n";
my $averagePageSize = $totalPageSize/$numberOfPages;
print STDERR "NOTE: Average size of page:  $averagePageSize\n";

