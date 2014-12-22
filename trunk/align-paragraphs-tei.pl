
use strict;

use FindBin qw($Bin);

my $toolsdir    = $Bin;
my $xsldir      = $toolsdir;
my $saxon       = "java -jar " . $toolsdir . "/tools/lib/saxon9he.jar ";

system ("$saxon test.xml $xsldir/align-paragraphs-tei.xsl > align-paragraphs-output.xml");


my $pwd = `pwd`;
chop($pwd);
$pwd =~ s/\\/\//g;

# Provide the imageinfo file with a full path in a parameter.
my $fileImageParam = "";
if (-f "imageinfo.xml")
{
    print "Adding imageinfo.xml...\n";
    $fileImageParam = "imageInfoFile=\"file:/$pwd/imageinfo.xml\"";
}

# Provide the custom CSS file with a full path in a parameter.
my $cssFileParam = "";
if (-f "custom.css")
{
    print "Adding custom.css stylesheet...\n";
    $cssFileParam = "customCssFile=\"file:/$pwd/custom.css\"";
}

system ("$saxon align-paragraphs-output.xml $xsldir/tei2html.xsl $fileImageParam $cssFileParam > align-paragraphs-output.html");
