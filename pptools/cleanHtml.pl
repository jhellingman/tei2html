
use strict;
use warnings;

while (<>) {

    my $line = $_;

    $line =~ s/<\/link>//g;
    $line =~ s/<\/meta>//g;
    $line =~ s/<\/img>//g;
    $line =~ s/<\/hr>//g;

    $line =~ s/<br\/>/<br>/g;

    $line =~ s/<style><\/style>//g;

    print $line;
}
