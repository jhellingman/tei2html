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
        $paragraph =~ s/<GR>(.*?)<\/GR>/<choice><orig><GR>$1<\/GR><\/orig><reg type=\"trans\"><GRT>$1<\/GRT><\/reg><\/choice>/g;
        $paragraph =~ s/<CY>(.*?)<\/CY>/<choice><orig><CY>$1<\/CY><\/orig><reg type=\"trans\"><CYT>$1<\/CYT><\/reg><\/choice>/g;
        $paragraph =~ s/<RU>(.*?)<\/RU>/<choice><orig><RU>$1<\/RU><\/orig><reg type=\"trans\"><RUT>$1<\/RUT><\/reg><\/choice>/g;
        $paragraph =~ s/<RUX>(.*?)<\/RUX>/<choice><orig><RUX>$1<\/RUX><\/orig><reg type=\"trans\"><RUXT>$1<\/RUXT><\/reg><\/choice>/g;
        $paragraph =~ s/<SR>(.*?)<\/SR>/<choice><orig><SR>$1<\/SR><\/orig><reg type=\"trans\"><SRT>$1<\/SRT><\/reg><\/choice>/g;
    }

    return $paragraph;
}
