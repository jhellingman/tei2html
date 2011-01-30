# numberParagraphs.pl -- number the paragraphs in a document.
#
# 1. numbers get the form n=<chapter number|first letter of id>.<sequence number>
# 2. chapter number derived from n attribute of <div#>

use strict;
use Roman;          # Roman.pm version 1.1 by OZAWA Sakuro <ozawa@aisoft.co.jp>

my $inputFile   = $ARGV[0];

my $divNumber = 0;
my $parNumber = 0;

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

while (<INPUTFILE>)
{
    my $line = $_;

    if ($line =~ /<div1(.*?)>/) 
    {
        my $attrs = $1;
        my $newDivNumber = getAttrVal("n", $attrs);
        if ($newDivNumber ne "") 
        {
            $newDivNumber = isroman($newDivNumber) ? arabic($newDivNumber) : $newDivNumber;
        }
        else
        {
            $newDivNumber = getAttrVal("id", $attrs);
            if ($newDivNumber ne "")
            {
                $newDivNumber = substr($newDivNumber, 0, 1);
            }
        }

        $divNumber = $newDivNumber ne "" ? $newDivNumber : $divNumber++;

        $parNumber = 0;
        # print STDERR "DIV1:$divNumber; ";
    }
    
    my $remainder = $line;

    while ($remainder =~ m/<p\b(.*?)>/)
    {
        my $before = $`;
        my $attrs = $1;
        $remainder = $';
        $parNumber++;

        my $currentNumber = getAttrVal("n", $attrs);
        if ($currentNumber eq "") 
        {
            $currentNumber = ($divNumber ne "" && $divNumber ne "0") ? "$divNumber.$parNumber" : $parNumber;
            $attrs = $attrs . " n=$currentNumber";
        }
        # print STDERR "P:$currentNumber; ";
        print "$before<p$attrs>";
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

    if ($attrs =~ /$attrName\s*=\s*([\w.]+)/i)
    {
        $attrVal = $1;
    }
    elsif ($attrs =~ /$attrName\s*=\s*\"(.*?)\"/i)
    {
        $attrVal = $1;
    }
    return $attrVal;
}
