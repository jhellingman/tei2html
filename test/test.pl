# Perl script to test the the tei2html.xsl stylesheet with Saxon.

use strict;
use warnings;

use FindBin qw($Bin);

my $toolsdir    = $Bin . "/..";
my $xsldir      = $toolsdir;
my $libdir      = $toolsdir . "/tools/lib";
my $saxon       = "java -jar " . $libdir . "/saxon9he.jar ";
my $epubcheck   = "java -jar " . $libdir . "/epubcheck-3.0.1.jar ";
my $prince      = "\"C:\\Program Files (x86)\\Prince\\Engine\\bin\\prince.exe\"";


my $pwd = `pwd`;
chop($pwd);
$pwd =~ s/\\/\//g;


# Provide the imageinfo file with a full path in a parameter.
my $fileImageParam = "";
if (-f "imageinfo.xml") {
    print "Adding imageinfo.xml...\n";
    $fileImageParam = "imageInfoFile=\"file:/$pwd/imageinfo.xml\"";
}

# Provide the custom CSS file with a full path in a parameter.
my $cssFileParam = "";
if (-f "custom.css") {
    print "Adding custom.css stylesheet...\n";
    $cssFileParam = "customCssFile=\"file:/$pwd/custom.css\"";
}

my $configurationFileParam = '';
if (-f "tei2html.config") {
    print "Add custom configuration: tei2html.config ...\n";
    $configurationFileParam = "configurationFile=\"file:/$pwd/tei2html.config\"";
}

my $opfManifestFileParam = "";
if (-f "opf-manifest.xml") {
    print "Adding additional elements for the OPF manifest...\n";
    $opfManifestFileParam = "opfManifestFile=\"file:/$pwd/opf-manifest.xml\"";
}

my $opfMetadataFileParam = "";
if (-f "opf-metadata.xml") {
    print "Adding additional items to the OPF metadata...\n";
    $opfMetadataFileParam = "opfMetadataFile=\"file:/$pwd/opf-metadata.xml\"";
}

print "Add col and row attributes to tables...\n";
system ("$saxon test.xml $xsldir/preprocess.xsl > test-preprocessed.xml");

system ("$saxon -TP:htmlprofile.html test-preprocessed.xml $xsldir/tei2html.xsl $fileImageParam $cssFileParam $configurationFileParam > test.html");
system ("$saxon -TP:epubprofile.html test-preprocessed.xml $xsldir/tei2epub.xsl $fileImageParam $cssFileParam $configurationFileParam $opfManifestFileParam $opfMetadataFileParam basename=\"test\" > tmp.xhtml");

# system ("$saxon -T -traceout:htmltrace.txt test-preprocessed.xml $xsldir/tei2html.xsl $fileImageParam $cssFileParam $configurationFileParam > test.html");
# system ("$saxon -T -traceout:epubtrace.txt  test-preprocessed.xml $xsldir/tei2epub.xsl $fileImageParam $cssFileParam $configurationFileParam $opfManifestFileParam $opfMetadataFileParam basename=\"test\" > tmp.xhtml");

print "Convert to P5 and repeat the exercise...\n";
system ("$saxon test.xml $xsldir/p4top5.xsl > test-p5.xml");
system ("$saxon test-p5.xml $xsldir/preprocess.xsl > test-preprocessed-p5.xml");
system ("$saxon test-preprocessed-p5.xml $xsldir/tei2html.xsl $fileImageParam $cssFileParam $configurationFileParam > test-p5.html");


system ("del test.epub");
chdir "epub";
system ("zip -Xr9Dq ../test.epub mimetype");
system ("zip -Xr9Dq ../test.epub * -x mimetype");
chdir "..";

system ("$epubcheck test.epub 2> test-epubcheck.err");

system ("$saxon test-preprocessed.xml $xsldir/tei2html.xsl $fileImageParam $cssFileParam $configurationFileParam optionPrinceMarkup=\"Yes\" > test-prince.html");
system ("$prince test-prince.html -o test.pdf");
