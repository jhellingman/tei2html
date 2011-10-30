# pgpp.pl

use strict;
use SgmlSupport qw/pgdp2sgml/;


my $file = $ARGV[0];
my $useExtensions = 0;

if ($file eq "-x")
{
    $useExtensions = 1;
    $file = $ARGV[1];
    print STDERR "USING EXTENSIONS FOR FRANCK!\n";
}


open(INPUTFILE, $file) || die("Could not open input file $file");


while (<INPUTFILE>)
{
    # Replace ampersands (if they are not likely entities):
    $_ =~ s/\& /\&amp; /g;
    $_ =~ s/\&$/\&amp;/g;
    $_ =~ s/\&c\. /\&amp;c. /g;

    # Replace PGDP page-separators (preserving proofers):
    # $_ =~ s/^-*File: 0*([0-9]+)\.png-*\\([^\\]+)\\([^\\]+)\\([^\\]+)\\([^\\]+)\\.*$/<pb n=\1 resp="\2|\3|\4|\5">/g;
    $_ =~ s/^-*File: 0*([0-9]+)\.(png|jpg)-*\\([^\\]+)\\([^\\]?)\\([^\\]+)\\([^\\]+)\\.*$/<pb n=\1>/g;
    # For DP-EU:
    $_ =~ s/^-*File: 0*([0-9]+)\.(png|jpg)-*\\([^\\]+)\\([^\\]+)\\.*$/<pb n=\1>/g;
    # For omitted proofer names.
    $_ =~ s/^-*File: 0*([0-9]+)\.(png|jpg)-*$/<pb n=\1>/g;

    # Replace footnote indicators:
    $_ =~ s/\[([0-9]+)\]/<note n=\1><\/note>/g;

    # Mark beginning of paragraphs:
    $_ =~ s/\n\n([A-Z0-9"'([])/\n\n<p>\1/g;

    # Replace illustration markup:
    $_ =~ s/\[Illustration: (.*)\]/<figure id=pXXX>\n<head>\1<\/head>\n<\/figure>/g;

    # Replace dashes in number ranges by en-dashes
    $_ =~ s/([0-9])-([0-9])/\1\&ndash;\2/g;

    # Replace two dashes by em-dashes
    $_ =~ s/--/\&mdash;/g;

    # Replace superscripts
    $_ =~ s/\^\{(.*?)\}/<hi rend=sup>\1<\/hi>/g;
    $_ =~ s/\^([a-zA-Z0-9\*])/<hi rend=sup>\1<\/hi>/g;

    # Replace subscripts
    $_ =~ s/_\{(.*?)\}/<hi rend=sub>\1<\/hi>/g;
    $_ =~ s/_([a-zA-Z0-9\*])/<hi rend=sub>\1<\/hi>/g;

    # Replace italics tag
    $_ =~ s/<i>/<hi>/g;
    $_ =~ s/<\/i>/<\/hi>/g;

    # Replace special accented letters
    # $_ =~ s/\[=([aieouAIEOU])\]/\&\1macr;/g;
    $_ = pgdp2sgml($_, $useExtensions);

    print;
}
