# addTrans.pl -- Add transcription to Greek and Cyrillic text
#
# Assumption: Greek sections are marked <GR>...</GR>; Cyrillic sections are marked <CY>/<RU>/<CYX>; another tool will actually convert to transcription.
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
    my $file = shift @ARGV;

    my $fileHandle;
    if (defined $file) {
        open($fileHandle, '<', $file) or die "Could not open '$file': $!";
    } else {
        $fileHandle = *STDIN;
    }

    if ($utf8) {
        binmode($fileHandle, ':encoding(UTF-8)');
        binmode(STDOUT, ':encoding(UTF-8)');
    }

    my $paragraph = '';

    while (<$fileHandle>) {
        my $line = $_;

        # Deal with PGDP page separators.
        if ($_ =~ /-*File: ([0-9]+)\.png-*\\([^\\]*)(\\([^\\]+))?(\\([^\\]+))?(\\([^\\]+))?\\.*$/) {
            print "\n\n" . handleParagraph($paragraph);
            print "\n$line";
            $paragraph = '';
        } elsif ($line ne "\n") {
            chomp($line);
            $paragraph .= ' ' . $line;
        } else {
            print "\n\n" . handleParagraph($paragraph);
            $paragraph = '';
        }
    }

    if ($paragraph ne '') {
        print "\n\n" . handleParagraph($paragraph);
    }

    close $fileHandle;
}

sub handleParagraph {
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

        $paragraph =~ s/<(BO)>(.*?)<\/BO>/keepTranscription($1, $2)/eg;
    }

    return $paragraph;
}

# Create a choice element of both the original script and a transcription. Filter the encoding, and put it between <xxT>...</xxT> tags, 
# so that in a later face this will encoding be coverted to the proper Latin script transcription.
sub rewriteTranscription {
    my $code = shift;
    my $trans = shift;
    my $t = 'T';

    # Filter <pb> and <choice> tags from the transcription in $trans.
    my $clean = $trans;
    $clean =~ s/<pb.*?>//g;
    $clean =~ s/<choice>\s*<sic>.*?<\/sic>\s*<corr>(.*?)<\/corr>\s*<\/choice>/$1/g;
    
    return "<choice><orig><$code>$trans<\/$code><\/orig><reg type=\"trans\"><$code$t>$clean<\/$code$t><\/reg><\/choice>";
}

# Create a choice element of both the original script and the encoding. Filter the encoding. Used when the encoding can directly
# be used as the Latin transcription.
sub keepTranscription {
    my $code = shift;
    my $trans = shift;

    # Filter <pb> and <choice> tags from the transcription in $trans.
    my $clean = $trans;
    $clean =~ s/<pb.*?>//g;
    $clean =~ s/<choice>\s*<sic>.*?<\/sic>\s*<corr>(.*?)<\/corr>\s*<\/choice>/$1/g;
    
    return "<choice><orig><$code>$trans<\/$code><\/orig><reg type=\"trans\">$clean<\/reg><\/choice>";
}
