#
# filter-nsgmls-errors.pl: filter the output of NSGMLS.
#

use strict;
use warnings;

my $inputFile = $ARGV[0];

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

# print STDERR "Filter output of NSGMLS in $inputFile\n";

my @lines = ();
while (<INPUTFILE>) {
    push (@lines, $_);
}
close (INPUTFILE);


my %undefinedElements = {};

foreach my $line (@lines) {

    if ($line =~ /^nsgmls\:([a-zA-Z0-9.-]+)\:([0-9]+)\:([0-9]+)\: (start tag was here)/) {
        my $fileName = $1;
        my $lineNumber = $2;
        my $position = $3;
        my $message = $4;

        print "  $fileName:$lineNumber:$position: $message\n";
    }

    # Only interested in errors, warnings and cross-reference issues:
    if ($line =~ /^nsgmls\:([a-zA-Z0-9.-]+)\:([0-9]+)\:([0-9]+)\:[EWX]\: /) {

        my $fileName = $1;
        my $lineNumber = $2;
        my $position = $3;
        my $message = $';

        # Not interested in undefined elements, except for the first time
        if ($message =~ /element \"([a-zA-Z0-9]+)\" undefined/) {
            my $element = $1;
            if ($undefinedElements{$element}) {
                next;
            }
            $undefinedElements{$element} = 1;
        }

        # Not interested in the following: "X0102" is not a function name
        if ($line =~ /\"X?([0-9A-Z]+)\" is not a function name/) {
            next;
        }

        # Not interested in undefined entities
        if ($line =~ /general entity \"([0-9A-Za-z._-]+)\" not defined and no default entity/) {
            next;
        }

        # Not interested in unsupported characters
        if ($line =~ /is not a character number in the document character set/) {
            next;
        }

        # Not interested in warning about content model
        if ($line =~ /content model is mixed but does not allow \#PCDATA everywhere/) {
            next;
        }

        # Ignore our temporary "POS" attribute
        if ($line =~ /there is no attribute \"POS\"/) {
            next;
        }

        print "  $fileName:$lineNumber:$position: $message";
    }
}
