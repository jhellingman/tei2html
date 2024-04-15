
use strict;
use warnings;

use FindBin qw($Bin);

my $toolsdir    = $Bin;
my $saxon       = "java -jar " . $toolsdir . "/tools/lib/saxon9he.jar ";
my $xsltdoc     = $toolsdir . "/../XSLTdoc/xsl/xsltdoc.xsl";

system ("$saxon xsltdoc.config $xsltdoc > xsltdoc.log");
