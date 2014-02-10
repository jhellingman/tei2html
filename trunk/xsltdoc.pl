
use strict;

use FindBin qw($Bin);

my $toolsdir    = $Bin;
my $xsldir      = $toolsdir;
my $saxon       = "java -jar " . $toolsdir . "/tools/lib/saxon9he.jar ";
my $xsltdoc     = $toolsdir . "/tools/lib/XSLTdoc_1.2.2/xsl/xsltdoc.xsl";

system ("$saxon xsltdoc.config $xsltdoc > xsltdoc.log");
