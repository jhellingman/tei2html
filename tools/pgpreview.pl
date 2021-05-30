# pgpreview.pl -- Create simple HTML preview of proofed pages.

use strict;
use warnings;

use Getopt::Long;
use SgmlSupport qw/sgml2utf utf2sgml pgdp2sgml/;
use HTML::Entities;

my $utf8 = 0;       # Input file is utf8.

GetOptions(
    'u' => \$utf8
    );

main();

sub main {
    my $file = $ARGV[0];
    my $projectName = $ARGV[1];
    my $useExtensions = 0;

    if (!defined $projectName && $file =~ /^(projectID[0-9a-f]+)/) {
        $projectName = $1;
    }

    if ($file eq '-x') {
        $useExtensions = 1;
        $file = $ARGV[1];
        $projectName = $ARGV[2];
        print STDERR "USING EXTENSIONS FOR FRANCK!\n";
    }

    open(INPUTFILE, $file) || die("Could not open input file $file");
    if ($utf8 != 0) {
        binmode(INPUTFILE, ":utf8");
    }

    printHtmlHead();

    my $paragraph = "";

    while (<INPUTFILE>) {
        my $line = trim($_);

        if ($line =~ /-*File: ([0-9]+)\.png-*\\([^\\]*)(\\([^\\]+))?(\\([^\\]+))?(\\([^\\]+))?\\.*$/ or $_ =~ /-*File: ([0-9]+)\.png-*$/) {
            print "\n\n<p>" . handleParagraph($paragraph, $useExtensions);
            if ($projectName ne '') {
                print "<hr>\n<b>File: <a href='https://www.pgdp.net/c/tools/page_browser.php?mode=image&project=$projectName&imagefile=$1.png'>$1.png</a></b>\n<hr>\n";
            } else {
                print "<hr>\n<b>File: $1.png</b>\n<hr>\n";
            }
            $paragraph = '';
        } elsif ($line =~ m/\[crossword\]/) {
            if ($paragraph ne "") {
                print "\n\n<p>" . handleParagraph($paragraph, $useExtensions);
                $paragraph = '';
            }
            handleCrossWord();
        } elsif ($line ne '') {
            $paragraph .= ' ' . $line;
        } else {
            if ($paragraph ne "") {
                print "\n\n<p>" . handleParagraph($paragraph, $useExtensions);
            }
            $paragraph = '';
        }
    }

    if ($paragraph ne '') {
        print "\n\n<p>" . encode_entities(handleParagraph($paragraph, $useExtensions));
    }

    printHtmlTail();

    close INPUTFILE;
}

sub handleCrossWord() {
    print "<table class=crossword>\n";
    while (<INPUTFILE>) {
        my $line = $_;
        if ($line =~ m/\[\/crossword]/) {
            print "</table>\n";
            return;
        }
        $line =~ s/[:]/<td class=blank>/g;
        $line =~ s/[|]\s*[~]+/<td class=blank>/g;
        $line =~ s/[|]\s*[#]+/<td class=black>/g;
        $line =~ s/[|]\s*[%]+/<td class=shaded>/g;
        $line =~ s/[|]\s*\n/\n/g;
        $line =~ s/[|]/<td>/g;
        $line =~ s/^\s*<td/<tr><td/g;
        print $line;
    }
}

sub handleParagraph($$) {
    my $paragraph = shift;
    my $useExtensions = shift;

    # Remove over-zealous numeric entities
    $paragraph =~ s/\&\#39;/'/g;

    $paragraph = pgdp2sgml($paragraph, $useExtensions);

    # Replace dashes in number ranges by en-dashes
    $paragraph =~ s/([0-9])-([0-9])/$1\&ndash;$2/g;

    # Replace two dashes by em-dashes
    $paragraph =~ s/ *---? */\&mdash;/g;

    $paragraph = sgml2utf($paragraph);

    # Tag proofreader remarks:
    $paragraph =~ s/(\[\*.*?\])/<span class=remark>$1<\/span>/g;

    # Tag Greek sections (original)
    $paragraph =~ s/(\[GR:.*?\])/<span class=greek>$1<\/span>/g;

    # Tag incorrect Greek sections (WRONG!!!)
    $paragraph =~ s/(\[Greek:?.*?\])/<span class=error>$1<\/span>/g;

    # Tag Greek sections (WRONG!!!)
    $paragraph =~ s/(\[G[Rr].*?\])/<span class=error>$1<\/span>/g;

    # Tag Greek sections (after processing)
    $paragraph =~ s/<foreign lang=el>(.*?)<\/foreign>/<span class=greek>$1<\/span>/g;
    $paragraph =~ s/<foreign lang=grc>(.*?)<\/foreign>/<span class=greek>$1<\/span>/g;

    # Replace illustration markup:
    $paragraph =~ s/\[Ill?ustration:? ?(.*)\]/<span class=figure>[Illustration: $1]<\/span>/g;

    # Replace footnote indicators:
    $paragraph =~ s/\[([0-9]+)\]/<sup>$1<\/sup>/g;

    # Replace superscripts
    $paragraph =~ s/\^\{(.*?)\}/<sup>$1<\/sup>/g;
    $paragraph =~ s/\^([a-zA-Z0-9\*])/<sup>$1<\/sup>/g;

    # Replace subscripts
    $paragraph =~ s/_\{(.*?)\}/<sub>$1<\/sub>/g;
    $paragraph =~ s/_([a-zA-Z0-9\*])/<sub>$1<\/sub>/g;

    # Replace other formatting
    $paragraph =~ s/<sc>(.*?)<\/sc>/<span class=sc>$1<\/span>/g;
    $paragraph =~ s/<g>(.*?)<\/g>/<span class=ex>$1<\/span>/g;

    $paragraph =~ s/<tb>/<hr>/g;

    # Anything else between braces is probably wrong:
    $paragraph =~ s/(\^?\{.*?\})/<span class=error>$1<\/span>/g;

    # Remaining non-numeric entities are wrong (use negative look-ahead assertion)
    $paragraph =~ s/(\&(?!\#x?[0-9A-Za-z]{1,6}).*?;)/<span class=error>$1<\/span>/g;

    # Remaining short things between brackets are probably wrong
    $paragraph =~ s/(\[[^\]]{0,4}\])/<span class=error>$1<\/span>/g;


    $paragraph = utf2sgml($paragraph);

    # Trim superfluous spaces
    $paragraph =~ s/[\t ]+/ /g;
    $paragraph =~ s/^ +//;
    $paragraph =~ s/ +$//;

    # Remove TEI <corr> tags that might drop through.
    $paragraph =~ s/<\/?corr(.*?)>/ /g;

    return $paragraph;
}


sub printHtmlHead() {
    print <<"EOF";
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html lang='en'>
    <head>
    <title>DP Preview</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <style type='text/css'>
        BODY { font-size: 16pt; line-height: 22pt; font-family: 'Charis SIL'; }
        .figure { background-color: #FFFF5C; }
        .remark { background-color: #FFB442; }
        .sc { font-variant:small-caps; }
        .ex { letter-spacing:0.2em; background-color: #FFFF80; }
        .error { background-color: #FF8566; font-weight: bold; }
        .xref { background-color: #FFFF8C; }
        .code { font-weight: bold; color: gray; display: none; }

        .crossword { border-collapse: collapse; font-size: xx-small; }
        .crossword td { width: 20px; height: 21px; border: 1px solid black; vertical-align: top; }
        .crossword td.black { background-color: black; }
        .crossword td.blank { border: none; }
        .crossword td.shaded { background-color: #D3D3D3; }

        :lang(bo) { font-family: 'Yagpo Tibetan Uni', 'Qomolangma-Sarchung', 'Babelstone Tibetan', serif; }
        :lang(ar) { font-family: Scheherazade, serif; }
        :lang(he) { font-family: Shlomo, 'Ezra SIL', serif; font-size: 80% }
        :lang(syc) { font-family: 'Serto Jerusalem', serif; }
        :lang(grc) { font-family: 'Galatia SIL', serif; }
        :lang(sa) { font-family: 'Sanskrit 2003', serif;  }
    </style>
    </head>
    <body>
EOF
}


sub printHtmlTail() {
    print "</body></html>";
}


sub trim($) {
    my $s = shift; 
    $s =~ s/^\s+|\s+$//g;
    return $s;
}