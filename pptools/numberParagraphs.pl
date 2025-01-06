# numberParagraphs.pl -- number the paragraphs in a document.
#
# 1. numbers get the form n=<chapter number|first letter of id>.<sequence number>
# 2. chapter number derived from n attribute of <div#>

use strict;
use warnings;
use Roman;                          # Roman.pm version 1.1 by OZAWA Sakuro <ozawa@aisoft.co.jp>
use SgmlSupport qw/getAttrVal/;

my $inputFile   = $ARGV[0];

my $divNumber = 0;
my $parNumber = 0;

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

while (<INPUTFILE>) {
    my $line = $_;

    if ($line =~ /<div1(.*?)>/) {
        my $attrs = $1;
        my $newDivNumber = getAttrVal('n', $attrs);
        if ($newDivNumber ne '') {
            $newDivNumber = isroman($newDivNumber) ? arabic($newDivNumber) : $newDivNumber;
        } else {
            $newDivNumber = getAttrVal('id', $attrs);
            if ($newDivNumber ne '') {
                $newDivNumber = substr($newDivNumber, 0, 1);
            }
        }

        $divNumber = $newDivNumber ne '' ? $newDivNumber : $divNumber++;

        $parNumber = 0;
        # print STDERR "DIV1:$divNumber; ";
    }
    
    my $remainder = $line;

    while ($remainder =~ m/<p\b(.*?)>/) {
        my $before = $`;
        my $attrs = $1;
        $remainder = $';
        $parNumber++;

        my $currentNumber = getAttrVal('n', $attrs);
        if ($currentNumber eq '') {
            $currentNumber = ($divNumber ne '' && $divNumber ne '0') ? "$divNumber.$parNumber" : $parNumber;
            $attrs = $attrs . " n=$currentNumber";
        }
        # print STDERR "P:$currentNumber; ";
        print "$before<p$attrs>";
    }
    print $remainder;
}
