# extract-page.pl

use strict;
use FindBin qw($Bin);

my $saxon           = "java -jar " . $Bin . "/lib/saxon9he.jar ";
my $xsldir          = $Bin . "/..";                    # location of xsl stylesheets

my $filename = $ARGV[0];
my $page = $ARGV[1];

if ($page eq '')
{
    system ("$saxon \"$filename\" $xsldir/extract-page.xsl");
}
else
{
    system ("$saxon \"$filename\" $xsldir/extract-page.xsl n=\"$page\"");
}
