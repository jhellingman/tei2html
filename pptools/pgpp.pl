# pgpp.pl -- Project Gutenberg Post-Processing: first steps of post-processing a text from PGDP for PG.

use strict;
use warnings;
use HTML::Entities;
use Getopt::Long;
use SgmlSupport qw/pgdp2sgml/;

my $useExtensions = 0;
my $mindTranscriptions = 0;
my $showHelp = 0;

GetOptions(
    'x' => \$useExtensions,
    'm' => \$mindTranscriptions,
    'q' => \$showHelp,
    'help' => \$showHelp);

if ($showHelp == 1) {
    print "pgpp.pl -- Project Gutenberg Post-Processing: first steps of post-processing a text from PGDP for PG.\n\n";
    print "Usage: pgpp.pl [-xmq] <file>\n\n";
    print "Options:\n";
    print "    x         Use extensions as defined for Franck's Etymological Dictionary.\n";
    print "    m         Don't apply super-script and sub-script markings that might harm transcriptions.\n";
    print "    q         Print this help and exit.\n";

    exit(0);
}

my $file = $ARGV[0];

open(INPUTFILE, '<:encoding(UTF-8)', $file) || die("Could not open input file $file");

while (<INPUTFILE>) {

    # Replace ampersands (if they are not likely to start entities):
    $_ =~ s/\& /\&amp; /g;
    $_ =~ s/\&$/\&amp;/g;
    $_ =~ s/\&([^a-zA-Z0-9_])/\&amp;$1/g;
    $_ =~ s/\&c\./\&amp;c./g;
    $_ =~ s/\&c([^a-zA-Z0-9_-])/\&amp;c$1/g;

    # Replace PGDP page-separators (preserving proofreader names):
    # $_ =~ s/^-*File: (0*)([0-9]+)\.png-*\\([^\\]+)\\([^\\]+)\\([^\\]+)\\([^\\]+)\\.*$/<pb n=\1 resp="\2|\3|\4|\5">/g;
    $_ =~ s/^-*File: ([0fp]*)([0-9]+)\.(png|jpg)-*\\([^\\]+)\\([^\\]?)\\([^\\]+)\\([^\\]+)\\.*$/<pb n=$2 facs="f:$1$2">/g;
    # For DP-EU:
    $_ =~ s/^-*File: ([0fp]*)([0-9]+)\.(png|jpg)-*\\([^\\]+)\\([^\\]+)\\.*$/<pb n=$2 facs="f:$1$2">/g;
    # For omitted proofreader names.
    $_ =~ s/^-*File: ([0fp]*)([0-9]+)\.(png|jpg)-*$/<pb n=$2 facs="f:$1$2">/g;

    # Replace footnote indicators:
    $_ =~ s/\[([0-9]+)\]/<note n=$1><\/note>/g;

    # Mark beginning of paragraphs:
    $_ =~ s/\n\n([A-Z0-9"'([])/\n\n<p>$1/g;

    # Replace illustration markup:
    $_ =~ s/\[Illustration: (.*)\]/<figure id=pXXX>\n<head>$1<\/head>\n<\/figure>/g;

    # Replace dashes in number ranges by en-dashes
    $_ =~ s/([0-9])-([0-9])/$1\&ndash;$2/g;

    # Replace two dashes by em-dashes
    $_ =~ s/--/\&mdash;/g;

    if ($mindTranscriptions == 0) {

        # Replace superscripts
        $_ =~ s/\^\{(.*?)\}/<hi rend=sup>$1<\/hi>/g;
        $_ =~ s/\^([a-zA-Z0-9\*])/<hi rend=sup>$1<\/hi>/g;

        # Replace subscripts
        $_ =~ s/_\{(.*?)\}/<hi rend=sub>$1<\/hi>/g;
        $_ =~ s/_([a-zA-Z0-9\*])/<hi rend=sub>$1<\/hi>/g;
    }

    # Replace italics tag
    $_ =~ s/<i>/<hi>/g;
    $_ =~ s/<\/i>/<\/hi>/g;

    # Replace special accented letters
    # $_ =~ s/\[=([aieouAIEOU])\]/\&\1macr;/g;
    $_ = pgdp2sgml($_, $useExtensions);

    # Replace unicode characters beyond U+00FF with entities
    print encode_entities($_, '^\n\x20-\xff');
}
