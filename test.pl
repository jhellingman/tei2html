# Perl script to test the the tei2html.xsl stylesheet with Saxon.

use strict;

my $xsldir = "C:\\Users\\Jeroen\\Documents\\eLibrary\\Tools\\tei2html";  # location of xsl stylesheets
my $saxon = "\"C:\\Program Files (x86)\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\saxon\\saxon.jar "; # command to run the saxon processor (see http://saxon.sourceforge.net/, using Version 6.5.5)
my $saxon2 = "\"C:\\Program Files (x86)\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\saxonhe9\\saxon9he.jar "; # command to run the saxon processor (see http://saxon.sourceforge.net/, using Version 6.5.5)
my $sevenzip = "\"C:\\Program Files\\7-Zip\\7z.exe\"";


my $epubcheck = "\"C:\\Program Files (x86)\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\epubcheck\\epubcheck-1.0.4.jar "; # command to run the saxon processor (see http://saxon.sourceforge.net/, using Version 6.5.5)


my $basename = "test";

# Since the XSLT processor cannot find files easily, we have to provide the imageinfo file with a full path in a parameter.
my $fileImageParam = "";
if (-f "imageinfo.xml")
{
    my $pwd = `pwd`;
    chop($pwd);
    $pwd =~ s/\\/\//g;

    $fileImageParam = "imageInfoFile=\"file:/$pwd/imageinfo.xml\"";
}

# Since the XSLT processor cannot find files easily, we have to provide the custom CSS file with a full path in a parameter.
my $cssFileParam = "";
if (-f "custom.css.xml")
{
    print "Adding custom.css stylesheet...\n";

    my $pwd = `pwd`;
    chop($pwd);
    $pwd =~ s/\\/\//g;

    $cssFileParam = "customCssFile=\"file:/$pwd/custom.css.xml\"";
}



# system ("$saxon $basename.xml $xsldir/tei2dc.xsl  > test-dc.xml");

system ("$saxon $basename.xml $xsldir/tei2html.xsl $fileImageParam $cssFileParam > test.html");

system ("$saxon2 $basename.xml $xsldir/tei2epub.xsl $fileImageParam $cssFileParam basename=\"$basename\" > tmp.xhtml");


system ("$sevenzip a -tzip -mx=0 $basename.epub .\\ePub\\mimetype");
system ("$sevenzip a -tzip -mx=7 -x!mimetype $basename.epub .\\ePub\\*");

system ("$epubcheck $basename.epub");
