
while (<>) {

    $a = $_;

    $a =~ s/<\/link>//g;
    $a =~ s/<\/meta>//g;
    $a =~ s/<\/img>//g;
    $a =~ s/<\/hr>//g;

    $a =~ s/<br\/>/<br>/g;

    print $a;
}
