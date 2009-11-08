# Perl script to test the the tei2xml.xsl stylesheet with Saxon.

$xsldir = "C:\\Users\\Jeroen\\Documents\\eLibrary\\Tools\\tei2html";  # location of xsl stylesheets
$saxon = "\"C:\\Program Files (x86)\\Java\\jre6\\bin\\java\" -jar C:\\Bin\\saxon\\saxon.jar "; # command to run the saxon processor (see http://saxon.sourceforge.net/, using Version 6.5.5)


$basename = "test";

# Since the XSLT processor cannot find files easily, we have to provide the imageinfo file with a full path in a parameter.
$fileImageParam = "";
if (-f "imageinfo.xml")
{
    $pwd = `pwd`;
    chop($pwd);

    $fileImageParam = "imageInfoFile=\"file:///$pwd/imageinfo.xml\"";
}

# Since the XSLT processor cannot find files easily, we have to provide the custom CSS file with a full path in a parameter.
$cssFileParam = "";
if (-f "custom.css.xml")
{
    print "Adding custom.css stylesheet...\n";

    $pwd = `pwd`;
    chop($pwd);

    $cssFileParam = "customCssFile=\"file:///$pwd/custom.css.xml\"";
}

system ("$saxon $basename.xml $xsldir/tei2html.xsl $fileImageParam $cssFileParam > test.html");
