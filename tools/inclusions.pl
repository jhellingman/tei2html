
use strict;
use warnings;

use FindBin qw($Bin);

my $toolsdir    = $Bin;
my $xsldir      = "$toolsdir/..";
my $saxon       = "java -jar " . $toolsdir . "/lib/saxon9he.jar ";

my $filename = $ARGV[0];

$filename =~ /^([A-Za-z0-9-]*?)(-([0-9]+\.[0-9]+))?\.(tei|xml)$/;
my $basename    = $1;
my $version     = $3;

system ("$saxon $filename $xsldir/inclusions.xsl > $basename" . "-with-includes.xml");

