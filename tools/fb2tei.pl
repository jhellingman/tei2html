# fb2tei.pl -- covert fictionbook to TEI.

use strict;
use warnings;
use MIME::Base64;
use FindBin qw($Bin);

my $toolsdir        = $Bin;                                 # location of tools
my $xsldir          = $toolsdir . "/..";                    # location of xsl stylesheets
my $saxon           = "java -jar " . $toolsdir . "/lib/saxon9he.jar ";

my $filename = $ARGV[0];
$filename =~ /^(.*)\.fb2$/;
my $basename    = $1;

system ("$saxon $filename $xsldir/fb2tei.xsl > $basename.xml");

# convert extracted .hex files to binary
my @files = <*.hex>;
foreach my $file (@files) {
    convertFile($file);
}

system ("perl -S tei2html.pl -h $basename.xml");

sub convertFile($) {
    my $filename = shift;

    open INFILE, $filename or die "Unable to open file: $filename"; 
    my $string = join("", <INFILE>); 
    close INFILE;
    my $binary = decode_base64($string);

    $filename =~ /^(.*)\.hex$/;
    my $outputFilename = $1;

    open(OUTFILE, '>:raw', $outputFilename) or die "Unable to open: $outputFilename";
    print OUTFILE $binary ;
    close(OUTFILE);
}
