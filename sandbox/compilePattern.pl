
use strict;

use FindBin qw($Bin);

my $toolsdir    = $Bin;
my $xsldir      = $toolsdir;
my $saxon       = "java -jar " . $toolsdir . "/../tools/lib/saxon9he.jar ";

system ("$saxon dummy.xml compilePatterns.xsl > compiledTest.xsl");

system ("$saxon dummy.xml compiledTest.xsl");
