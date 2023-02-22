# fixPb.pl -- fix (renumber) page-breaks in a TEI file.
#
# 1. sequence of numbers
# 2. average size of pages with large deviations

use strict;
use warnings;

use Roman;              # Roman.pm version 1.1 by OZAWA Sakuro <ozawa@aisoft.co.jp>
use Getopt::Long;
use POSIX qw/floor/;

use SgmlSupport qw/getAttrVal/;

my $splitColumns = 0;
my $columnNumbers = 0;
my $useRoman = 0;
my $first = 0;
my $last = 0;
my $offset = 0;
my $new = 0;
my $showHelp = 0;
my $divisor = 1;

GetOptions(
    'c' => \$columnNumbers,
    'r' => \$useRoman,
    's' => \$splitColumns,
    'd=i' => \$divisor,
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

if ($showHelp == 1) {
    my $help = <<'END_HELP';

fixPb.pl -- fix (renumber) page-breaks in a TEI file.

Usage: fixPb.pl [-cdflnors] <inputfile.tei>

Options:
    c         Deal with split columns: <pb>'s are retained, but numbered #a and #b.
    r         Use Roman numerals.
    s         Deal with split columns. Every second <pb> is replaced with <cb>.
                After each page, the offset will be decreased by one, to restore
                the original page-numbering.
    d=<int>   Divide the page number by the indicated value (default 1).
    f=<int>   First page to adjust (based on @n attribute).
    l=<int>   Last page (this last page will not be adjusted).
    n=<int>   New number of first page; will be used to calculate the offset.
    o=<int>   Offset, will be added to the original page number.
END_HELP

    print $help;
    exit 0;
}

my @letters = qw(a b c d e f g h i j k l m n o p q r s t u v w x y z);
my %idsUsed;

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

        if (isNumber($currentPage) && $cp == $first) {
            $seenFirst = 1;
        }
        if (isNumber($currentPage) && $cp == $last) {
            $seenLast = 1;
        }
        if ($seenFirst && !$seenLast && isNumber($currentPage)) {
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

    my $dot = '';

    if ($splitColumns and $secondColumn) {
        $secondColumn = 0;
        $offset -= 1;
        return "<cb>";
    }

    if ($columnNumbers and $secondColumn) {
        $secondColumn = 0;
        $offset -= 1;
        my $newCurrentPage = $currentPage + $offset;
        if ($useRoman != 0) {
            $newCurrentPage = roman($newCurrentPage);
            $dot = '.';
        }
        my $newId = makeId("pb$dot$newCurrentPage");
        return "<pb id=$newId n=$newCurrentPage$facs>";
    }

    my $newCurrentPage = $currentPage + $offset;
    $newCurrentPage = floor($newCurrentPage / $divisor);
    if ($useRoman != 0) {
        $newCurrentPage = roman($newCurrentPage);
        $dot = '.';
    }
    $secondColumn = 1;
    my $newId = makeId("pb$dot$newCurrentPage");
    return "<pb id=$newId n=$newCurrentPage$facs>";
}


sub makeId {
    my $n = shift;
    my $letter = '';
    if (defined $idsUsed{$n}) {
        $letter = $letters[$idsUsed{$n}];
        $idsUsed{$n}++;
    } else {
        $idsUsed{$n} = 0;
    }
    return $n . $letter;
}


sub isNumber {
    my $str = shift;
    return $str =~ /^[0-9]+$/;
}


print STDERR "NOTE: Total number of pages: $numberOfPages\n";
print STDERR "NOTE: Total size of pages:   $totalPageSize\n";
my $averagePageSize = $totalPageSize/$numberOfPages;
print STDERR "NOTE: Average size of page:  $averagePageSize\n";
