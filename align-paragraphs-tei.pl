
use strict;

use FindBin qw($Bin);

my $toolsdir    = $Bin;
my $xsldir      = $toolsdir;
my $saxon       = "java -jar " . $toolsdir . "/tools/lib/saxon9he.jar ";

system ("$saxon test.xml $xsldir/align-paragraphs-tei.xsl > align-paragraphs-output.xml");
