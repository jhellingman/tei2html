# intralinear.pl -- convert intralinear text to ab-elements.

use strict;
use warnings;
use SgmlSupport qw/getAttrVal/;

if (!defined $ARGV[0]) {
    die "Usage: intralinear.pl -x <filename>"
}
my $inputFile = $ARGV[0];

main();

sub main {
    open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

    print STDERR "Processing $inputFile\n";

    print "\n\n<!-- DO NOT EDIT: DERIVED FILE!!! -->\n\n\n";

    my @langs = ( 'xx', 'en' );
    my $mode = 0;

    while (<INPUTFILE>) {
        my $line = $_;

        if ($line =~ m/<INTRA(.*?)>/) {
            my $attrs = $1;
            my $langs = getAttrVal('langs', $attrs);
            if ($langs ne '') {
                @langs = split(' ', $langs);
            }
            $line = '';
            $mode = 1;
        }

        if ($line =~ m/<\/INTRA>/) {
            $line = '';
            $mode = 0;
        }

        if ($mode == 1) {
            $line =~ s/\[\|([^|]+?)\]/\n<ab type=\"intra\"><ab type=\"top\">&nbsp;<\/ab> <ab type=\"bottom\" lang=\"$langs[1]\">$1<\/ab><\/ab>\n/g;
            $line =~ s/\[([^|]+?)\|\]/\n<ab type=\"intra\"><ab type=\"top\" lang=\"$langs[0]\">$1<\/ab> <ab type=\"bottom\">&nbsp;<\/ab><\/ab>\n/g;
            $line =~ s/\[([^|]+?)\|([^|]+?)\]/\n<ab type=\"intra\"><ab type=\"top\" lang=\"$langs[0]\">$1<\/ab> <ab type=\"bottom\" lang=\"$langs[1]\">$2<\/ab><\/ab>\n/g;
        }

        print $line;
    }
}
