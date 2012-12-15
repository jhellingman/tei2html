# Perl script to test the the tei2html.xsl stylesheet with Saxon.

use strict;

my $xsldir = "C:\\Users\\Jeroen\\Documents\\eLibrary\\Tools\\tei2html";  # location of xsl stylesheets
my $saxon2 = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\saxonhe9\\saxon9he.jar ";

my $epubcheck     = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\epubcheck1.2\\epubcheck-1.2.jar ";
my $epubpreflight = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\epubcheck\\epubpreflight-0.1.0.jar ";

# See http://code.google.com/p/epubcheck/wiki/EPUBCheck30 for ePub3 checker
my $epubcheck3 = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\epubcheck3\\epubcheck-3.0b2.jar ";

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
if (-f "custom.css.xml")
{
    print "Adding custom.css stylesheet...\n";
    $cssFileParam = "customCssFile=\"file:/$pwd/custom.css.xml\"";
}

my $opfManifestFileParam = "";
if (-f "opf-manifest.xml")
{
    print "Adding additional elements for the OPF manifest...\n";
    $opfManifestFileParam = "opfManifestFile=\"file:/$pwd/opf-manifest.xml\"";
}

print "Add col and row attributes to tables...\n";
system ("$saxon2 test.xml $xsldir/normalize-table.xsl > test-normalized.xml");

system ("$saxon2 test-normalized.xml $xsldir/tei2html.xsl $fileImageParam $cssFileParam optionExternalLinks=\"Yes\" optionExternalLinksTable=\"No\" > test.html");
system ("$saxon2 test-normalized.xml $xsldir/tei2epub.xsl $fileImageParam $cssFileParam $opfManifestFileParam basename=\"test\" > tmp.xhtml");

system ("del test.epub");
chdir "epub";
system ("zip -Xr9Dq ../test.epub mimetype");
system ("zip -Xr9Dq ../test.epub * -x mimetype");
chdir "..";

system ("$epubcheck test.epub 2> test-epubcheck.err");
system ("$epubcheck3 test.epub 2> test-epubcheck3.err");
