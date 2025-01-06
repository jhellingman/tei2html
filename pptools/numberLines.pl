# numberLines.pl -- number lines of verse in a document.
#
# Numbers get the form id=v<sequence number>
#
# Uses special comments to indicate the start and end of lines to be numbered.
#
# <!-- START VERSE NUMBERS -->
# <!-- END VERSE NUMBERS -->


use strict;
use warnings;
use SgmlSupport qw/getAttrVal/;

my $inputFile   = $ARGV[0];

my $idPrefix = 'v';
my $lineNumber = 0;
my $addLineNumbers = 0;

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

while (<INPUTFILE>) {
    my $line = $_;

    if ($line =~ /<!-- START VERSE NUMBERS -->/) {
        $addLineNumbers = 1;
    }

    if ($line =~ /<!-- END VERSE NUMBERS -->/) {
        $addLineNumbers = 0;
    }

    if ($line =~ /<ab type=lineNum>([0-9]+).*<\/ab>/) {
        $lineNumber = $1;
    }

    if ($addLineNumbers == 1) {
        if ($line =~ /<l\b(.*?)>/) {
            my $before = $`;
            my $attrs = $1;
            my $after = $';

            print "$before<l id=$idPrefix$lineNumber$attrs>$after";
            $lineNumber++;
        } else {
            print $line;
        }
    } else {
        print $line;
    }
}
