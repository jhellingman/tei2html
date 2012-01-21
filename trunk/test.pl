# Perl script to test the the tei2html.xsl stylesheet with Saxon.

use strict;

my $xsldir = "C:\\Users\\Jeroen\\Documents\\eLibrary\\Tools\\tei2html";  # location of xsl stylesheets
my $saxon = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\saxon\\saxon.jar "; # command to run the saxon processor (see http://saxon.sourceforge.net/, using Version 6.5.5)
my $saxon2 = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\saxonhe9\\saxon9he.jar ";

my $epubcheck     = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\epubcheck1.2\\epubcheck-1.2.jar ";
my $epubpreflight = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\epubcheck\\epubpreflight-0.1.0.jar "; 

# See http://code.google.com/p/epubcheck/wiki/EPUBCheck30 for ePub3 checker
my $epubcheck3 = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\epubcheck3\\epubcheck-3.0b2.jar ";


my $basename = "test";

my $pwd = `pwd`;
chop($pwd);
$pwd =~ s/\\/\//g;


# Since the XSLT processor cannot find files easily, we have to provide the imageinfo file with a full path in a parameter.
my $fileImageParam = "";
if (-f "imageinfo.xml")
{
    print "Adding imageinfo.xml...\n";
    $fileImageParam = "imageInfoFile=\"file:/$pwd/imageinfo.xml\"";
}

# Since the XSLT processor cannot find files easily, we have to provide the custom CSS file with a full path in a parameter.
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



# system ("$saxon $basename.xml $xsldir/tei2dc.xsl  > test-dc.xml");

system ("$saxon2 $basename.xml $xsldir/tei2html.xsl $fileImageParam $cssFileParam optionExternalLinks=\"Yes\" optionExternalLinksTable=\"No\" > test.html");

system ("$saxon2 $basename.xml $xsldir/tei2epub.xsl $fileImageParam $cssFileParam $opfManifestFileParam basename=\"$basename\" > tmp.xhtml");
# system ("$saxon2 -T $basename.xml $xsldir/tei2epub.xsl $fileImageParam $cssFileParam basename=\"$basename\" > tmp.xhtml 2> trace.xml");

system ("del $basename.epub");
chdir "epub";
system ("zip -Xr9Dq ../$basename.epub mimetype");
system ("zip -Xr9Dq ../$basename.epub * -x mimetype");
chdir "..";

system ("$epubcheck $basename.epub 2> test-epubcheck.err");
system ("$epubcheck3 $basename.epub 2> test-epubcheck3.err");
# system ("$epubpreflight $basename.epub");
