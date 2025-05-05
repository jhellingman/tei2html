# utf82ent.pl -- convert a UTF8-encoded file to HTML entities.

use utf8;
use HTML::Entities;

binmode(STDOUT, ":utf8");

$infile = $ARGV[0];
open (INPUTFILE, $infile) || die("Could not open input file $infile");
binmode(INPUTFILE, ":encoding(utf8)");

while (<INPUTFILE>) {
    my $input = $_;
    $input = encode_entities($input);

    $input =~ s/&lt;/</g;
    $input =~ s/&gt;/>/g;
    $input =~ s/&quot;/\"/g;
    $input =~ s/&amp;#/\&#/g;

    print $input;
}

close INPUTFILE;
