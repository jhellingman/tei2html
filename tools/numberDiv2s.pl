# numberDiv2s.pl -- number the div2 elements in a document.
#
# 1. numbers get the form n=<chapter number|first letter of id>.<sequence number>
# 2. chapter number derived from n attribute of <div1>

use strict;
use warnings;
use Roman;                      # Roman.pm version 1.1 by OZAWA Sakuro <ozawa@aisoft.co.jp>
use SgmlSupport qw/getAttrVal/;

my $inputFile   = $ARGV[0];

my $div1Number = 0;
my $div2Number = 0;

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
        }

        $div1Number = $newDivNumber ne '' ? $newDivNumber : $div1Number++;

        $div2Number = 0;
        print STDERR "DIV1:$div1Number\n";
    }
    
    my $remainder = $line;

    while ($remainder =~ m/<div2(.*?)>/) {
        my $before = $`;
        my $attrs = $1;
        $remainder = $';
        $div2Number++;

        my $currentNumber = getAttrVal('n', $attrs);
        if ($currentNumber eq '') {
            $currentNumber = ($div1Number ne '' && $div1Number ne '0') ? "$div1Number.$div2Number" : $div2Number;
            $attrs = $attrs . " id=$currentNumber";
        }
        print STDERR "DIV2:$currentNumber\n";
        print "$before<div2$attrs>";
    }
    print $remainder;
}


sub isnum($) {
    my $str = shift;
    return $str =~ /^[0-9]+$/;
}
