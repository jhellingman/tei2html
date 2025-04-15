# addTrans.pl -- Add transcription to Greek and Cyrillic text
#
# Assumption: Greek sections are marked <GR>...</GR>; Cyrillic sections are marked <CY>/<RU>/<CYX>; other tool will actually convert to transcription.
#
# Output:                               <choice><orig><GR>...</GR></orig><reg><GRT>...</GRT></reg></choice>
#                                       <choice><orig><CY>...</CY></orig><reg><CYT>...</CYT></reg></choice>
# Alternative output to build HTML:     <span class=trans title="<GRTA>...</GRTA>"><GR>...</GR></span>
#

use strict;
use warnings;
use Getopt::Long;

my $useXml = 0;     # Output as XML (TEI); default is HTML.
my $utf8 = 0;       # Input file is utf8.

GetOptions(
    'u' => \$utf8,
    'x' => \$useXml
    );

main();

sub main {
    my $file = $ARGV[0];

    open(INPUTFILE, $file) || die("Could not open input file $file");
    if ($utf8 != 0) {
        binmode(INPUTFILE, ":utf8");
        binmode(STDOUT, ":utf8");
    }

    my $paragraph = "";

    while (<INPUTFILE>) {
        my $line = $_;

        # Deal with PGDP page separators.
        if ($_ =~ /-*File: ([0-9]+)\.png-*\\([^\\]*)(\\([^\\]+))?(\\([^\\]+))?(\\([^\\]+))?\\.*$/) {
            print "\n\n" . handleParagraph($paragraph);
            print "\n$line";
            $paragraph = "";
        } elsif ($line ne "\n") {
            chomp($line);
            $paragraph .= " " . $line;
        } else {
            print "\n\n" . handleParagraph($paragraph);
            $paragraph = "";
        }
    }

    if ($paragraph ne "") {
        print "\n\n" . handleParagraph($paragraph);
    }

    close INPUTFILE;
}

sub handleParagraph($) {
    my $paragraph = shift;

    if ($useXml == 0) {
        $paragraph =~ s/<GR>(.*?)<\/GR>/<span class=trans title=\"<GRTA>$1<\/GRTA>\"><GR>$1<\/GR><\/span>/g;
        $paragraph =~ s/<CY>(.*?)<\/CY>/<span class=trans title=\"<CYTA>$1<\/CYTA>\"><CY>$1<\/CY><\/span>/g;
        $paragraph =~ s/<RU>(.*?)<\/RU>/<span class=trans title=\"<RUTA>$1<\/RUTA>\"><RU>$1<\/RU><\/span>/g;
        $paragraph =~ s/<RUX>(.*?)<\/RUX>/<span class=trans title=\"<RUTA>$1<\/RUTA>\"><RUX>$1<\/RUX><\/span>/g;
    } else {
        $paragraph =~ s/<(GR)>(.*?)<\/GR>/rewriteTranscription($1, $2)/eg;
        $paragraph =~ s/<(CY)>(.*?)<\/CY>/rewriteTranscription($1, $2)/eg;
        $paragraph =~ s/<(RU)>(.*?)<\/RU>/rewriteTranscription($1, $2)/eg;
        $paragraph =~ s/<(RUX)>(.*?)<\/RUX>/rewriteTranscription($1, $2)/eg;
        $paragraph =~ s/<(SR)>(.*?)<\/SR>/rewriteTranscription($1, $2)/eg;
    }

    return $paragraph;
}

sub rewriteTranscription {
    my $code = shift;
    my $trans = shift;
    my $t = 'T';

    # Filter <pb> and <choice> tags from the transcription in $trans.
    my $clean = $trans;
    $clean =~ s/<pb.*?>//g;
    $clean =~ s/<choice><sic>.*?<\/sic><corr>(.*?)<\/corr><\/choice>/$1/g;
    
    return "<choice><orig><$code>$trans<\/$code><\/orig><reg type=\"trans\"><$code$t>$clean<\/$code$t><\/reg><\/choice>";
}