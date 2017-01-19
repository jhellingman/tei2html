# intralinear.pl -- convert intralinear text to ab-elements.

use strict;

my $inputFile = $ARGV[0];

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

print STDERR "Processing $inputFile\n";

my @langs = ( "xx", "en" );

my $mode = 0;

print "\n\n<!-- DO NOT EDIT: DERIVED FILE!!! -->\n\n\n";

while (<INPUTFILE>) {
    my $line = $_;

    if ($line =~ m/<INTRA(.*?)>/) {
        my $attrs = $1;
        my $langs = getAttrVal("langs", $attrs);
        if ($langs ne '') {
            @langs = split(' ', $langs);
        }
        $line = "";
        $mode = 1;
    }

    if ($line =~ m/<\/INTRA>/) {
        $line = "";
        $mode = 0;
    }

    if ($mode == 1) {
        $line =~ s/\[(.*?)\|(.*?)\]/\n<ab type=\"intra\"><ab type=\"top\" lang=\"$langs[0]\">\1<\/ab><ab type=\"bottom\" lang=\"$langs[1]\">\2<\/ab><\/ab>\n/g;
    }

    print $line;
}


#
# getAttrVal: Get an attribute value from a tag (if the attribute is present)
#
sub getAttrVal($$) {
    my $attrName = shift;
    my $attrs = shift;
    my $attrVal = "";

    if ($attrs =~ /$attrName\s*=\s*(\w+)/i) {
        $attrVal = $1;
    } elsif ($attrs =~ /$attrName\s*=\s*\"(.*?)\"/i) {
        $attrVal = $1;
    }
    return $attrVal;
}