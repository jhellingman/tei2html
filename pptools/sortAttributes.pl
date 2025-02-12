#
# sortAttributes.pl -- reorder attributes in SGML/XML files
#

use strict;
use warnings;

my $inputFile = $ARGV[0];

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

print STDERR "Sorting attributes in $inputFile\n";

while (<INPUTFILE>) {
    my $remainder = $_;
    while ($remainder =~ m/<([a-z][a-z0-9._-]*)(.*?)>/i) {
        my $before = $`;
        my $tag = $1;
        my $attrs = $2;
        $remainder = $';

        $attrs = reorderAttributes($attrs);

        print "$before<$tag$attrs>";
    }
    print $remainder;
}


sub reorderAttributes {
    my $attrs = shift;

    my $idValue = '';
    my $rendValue = '';
    my %attrHash = ();

    while ($attrs =~ /=/) {
        my $key = '';
        my $value = '';
        if ($attrs =~ /^\s*([a-z][a-z0-9._-]*)\s*=\s*([a-z0-9._-]+)/i) {
            $key = $1;
            $value = $2;
            $attrs = $';
        } elsif ($attrs =~ /^\s*([a-z][a-z0-9._-]*)\s*=\s*\"(.*?)\"/i) {
            $key = $1;
            $value = $2;
            $attrs = $';
        } else {
            print STDERR "Unexpected format of attributes: $attrs\n";
            exit;
        }

        if ($key eq 'id') {
            # id attribute should come first.
            $idValue = $value;
        } elsif ($key eq 'rend') {
            # rend attribute should come last.
            $rendValue = $value;
        } else {
            $attrHash{$key} = $value;
        }
    }

    my $result = '';
    if ($idValue ne '') {
        $result = ' id=' . optionalQuotes($idValue);
    }

    my @attrList = keys %attrHash;

    @attrList = sort {lc($a) cmp lc($b)} @attrList;
    foreach my $attr (@attrList) {
        $result .= ' ' . $attr . '=' . optionalQuotes($attrHash{$attr});
    }

    if ($rendValue ne '') {
        $result .= ' rend=' . optionalQuotes($rendValue);
    }

    return $result;
}


sub trim {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}


sub optionalQuotes {
    my $value = shift;

    if ($value =~ /^[a-z0-9._-]+$/i) {
        return $value
    }
    return "\"$value\"";
}
