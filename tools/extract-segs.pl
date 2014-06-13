# Perl script to test the the extract-segs.xsl stylesheet with Saxon.

use strict;
use FindBin qw($Bin);

my $saxon           = "java -jar " . $Bin . "/lib/saxon9he.jar ";
my $xsldir          = $Bin . "/..";                    # location of xsl stylesheets

my $filename = $ARGV[0];

system ("$saxon \"$filename\" $xsldir/extract-segs.xsl");
