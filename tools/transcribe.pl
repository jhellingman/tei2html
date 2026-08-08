# transcribe.pl -- Replace Greek and Cyrillic with Latin transcription.

use v5.36;

use File::stat;
use File::Temp qw(mktemp);

my $home      = $ENV{'TEI2HTML_HOME'};
my $toolsdir  = $home . "/tools";                    	# location of tools
my $patcdir   = $toolsdir . "/patc/transcriptions";  	# location of patc transcription files.

main();

sub main {

    my $infile = $ARGV[0];

    $infile =~ /^([A-Za-z0-9-]*?)(-([0-9]+\.[0-9]+))?\.(tei|xml)$/;
    my $basename = $1;
    my $version = $2;
    my $extension = $4;

    my $outfile = $basename . "-transcribed" . $version . "." . $extension;

    my $tmpFile1 = mktemp('tmp-XXXXX');
    my $tmpFile2 = mktemp('tmp-XXXXX');
    my $tmpFile3 = mktemp('tmp-XXXXX');

    adjustNotationTags($infile, $tmpFile1);

    system ("patc -p $patcdir/greek/grt2sgml8.pat $tmpFile1 $tmpFile2");
    system ("patc -p $patcdir/cyrillic/cyt2sgml.pat $tmpFile2 $tmpFile3");
    system ("patc -p $patcdir/indic/dn2latn8.pat $tmpFile3 $outfile");

    unlink($tmpFile1);
    unlink($tmpFile2);
    unlink($tmpFile3);
}

sub adjustNotationTags($inputFileName, $outputFileName) {

    open my $inputFile, '<', $inputFileName or die "Could not open input file '$inputFileName': $!";
    open my $outputFile, '>', $outputFileName or die "Could not open output file '$outputFileName': $!";

    while (<$inputFile>) {

        $_ =~ s/<GR>/<GRT>/g;
        $_ =~ s/<\/GR>/<\/GRT>/g;

        $_ =~ s/<CY>/<CYT>/g;
        $_ =~ s/<\/CY>/<\/CYT>/g;

        $_ =~ s/<RU>/<RUT>/g;
        $_ =~ s/<\/RU>/<\/RUT>/g;

        $_ =~ s/<RUX>/<RUXT>/g;
        $_ =~ s/<\/RUX>/<\/RUXT>/g;

        print $outputFile;
    }
    close $outputFile;
}
