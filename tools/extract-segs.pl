# Perl script to test the the extract-segs.xsl stylesheet with Saxon.

use strict;
use FindBin qw($Bin);

my $saxon           = "java -jar " . $Bin . "/lib/saxon9he.jar ";
my $xsldir          = $Bin . "/..";                    # location of xsl stylesheets

my $filename = $ARGV[0];
my $tmpFile = "tmp-legacy";


system ("perl -S stripDocType.pl $filename > $tmpFile");

system ("$saxon \"$tmpFile\" $xsldir/extract-segs.xsl");


