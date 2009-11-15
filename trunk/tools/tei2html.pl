# tei2xml.pl -- process a TEI file.

$toolsdir   = "C:\\Users\\Jeroen\\Documents\\eLibrary\\Tools\\tei2html\\tools";   # location of tools
$patcdir    = $toolsdir . "\\patc\\transcriptions"; # location of patc transcription files.
$xsldir     = "C:\\Users\\Jeroen\\Documents\\eLibrary\\Tools\\tei2html";  # location of xsl stylesheets
$tmpdir     = "C:\\Temp";                       # place to drop temporary files
$bindir     = "C:\\Bin";
$catalog    = "C:\\Bin\\pubtext\\CATALOG";      # location of SGML catalog (required for nsgmls and sx)
$princedir  = "C:\\Program Files\\Prince\\engine\\bin"; # location of prince processor (see http://www.princexml.com/)

$saxon = "\"C:\\Program Files (x86)\\Java\\jre6\\bin\\java\" -jar C:\\Bin\\saxon\\saxon.jar "; # command to run the saxon processor (see http://saxon.sourceforge.net/, using Version 6.5.5)

$usePrince = 0;

#==============================================================================


$filename = $ARGV[0];

if ($filename eq "-p") 
{
    $usePrince = 1;
    $filename = $ARGV[1];
}


if ($filename eq "")
{
    my ($directory) = ".";
    my @files = ( );
    opendir(DIRECTORY, $directory) or die "Cannot open directory $directory!\n";
    @files = readdir(DIRECTORY);
    closedir(DIRECTORY);

    foreach my $file (@files)
    {
        if ($file =~ /^([A-Za-z0-9-]*?)(-([0-9]+\.[0-9]+))?\.tei$/)
        {
            processFile($file);
            #exit;
        }
    }
}
else
{
    processFile($filename);
}




sub processFile
{
    my $filename = shift;

    if ($filename eq "" || $filename !~ /\.tei$/)
    {
        die "File: '$filename' is not a .TEI file\n";
    }

    $filename =~ /^([A-Za-z0-9-]*?)(-([0-9]+\.[0-9]+))?\.tei$/;
    my $basename = $1;
    my $version = $3;
    my $currentname = $filename;

    print "Processing TEI-file '$basename' version $version\n";


    # Translate Latin-1 characters to entities
    print "Converting Latin-1 characters to entities...\n";
    system ("patc -p $toolsdir/win2sgml.pat $currentname tmp.asc");
    $currentname = "tmp.asc";


    # Check for presence of Greek transcription
    my $containsGreek = system ("grep -q \"<GR>\" $currentname");
    if ($containsGreek == 0)
    {
        print "Converting Greek transcription...\n";
        print "Adding Greek transcription in choice elements...\n";
        system ("perl $toolsdir/gr2trans.pl -x $currentname > tmp.el.1");
        system ("patc -p $patcdir/greek/grt2sgml.pat tmp.el.1 tmp.el.2");
        system ("patc -p $patcdir/greek/gr2sgml.pat tmp.el.2 tmp.el");
        $currentname = "tmp.el";
    }

    # Check for presence of Assamese transcription
    my $containsAssamese = system ("grep -q \"<AS>\" $currentname");
    if ($containsAssamese == 0)
    {
        print "Converting Assamese transcription...\n";
        system ("patc -p $patcdir/indic/as2ucs.pat $currentname tmp.as");
        $currentname = "tmp.as";
    }

    # Check for presence of Bengali transcription
    my $containsAssamese = system ("grep -q \"<BN>\" $currentname");
    if ($containsAssamese == 0)
    {
        print "Converting Assamese transcription...\n";
        system ("patc -p $patcdir/indic/bn2ucs.pat $currentname tmp.bn");
        $currentname = "tmp.bn";
    }

    # Check for presence of Arabic transcription
    my $containsArabic = system ("grep -q \"<AR>\" $currentname");
    if ($containsArabic == 0)
    {
        print "Converting Arabic transcription...\n";
        system ("patc -p $patcdir/arabic/ar2sgml.pat $currentname tmp.ar");
        $currentname = "tmp.ar";
    }

    # Check for presence of Hebrew transcription
    my $containsHebrew = system ("grep -q \"<HB>\" $currentname");
    if ($containsHebrew == 0)
    {
        print "Converting Hebrew transcription...\n";
        system ("patc -p $patcdir/hebrew/he2sgml.pat $currentname tmp.hb");
        $currentname = "tmp.hb";
    }

    # Check for presence of Tagalog transcription
    my $containsTagalog = system ("grep -q \"<TL>\" $currentname");
    if ($containsTagalog == 0)
    {
        print "Converting Tagalog (Baybayin) transcription...\n";
        system ("patc -p $patcdir/tagalog/tagalog.pat $currentname tmp.tl");
        $currentname = "tmp.tl";
    }

    # Check for presence of Tamil transcription
    my $containsTagalog = system ("grep -q \"<TM>\" $currentname");
    if ($containsTagalog == 0)
    {
        print "Converting Tamil transcription...\n";
        system ("patc -p $patcdir/indic/tm2ucs.pat $currentname tmp.tm");
        $currentname = "tmp.tm";
    }



    print "Check SGML...\n";
    my $nsgmlresult = system ("nsgmls -c \"$catalog\" -wall -E5000 -g -f $basename.err $currentname > $basename.nsgml");
    system ("rm $basename.nsgml");


    print "Convert SGML to XML...\n";
    # hide entities for parser
    system ("sed \"s/\\&/|xxxx|/g\" < $currentname > tmp.1");
    system ("sx -c $catalog -E10000 -xlower -xcomment -xempty -xndata  tmp.1 > tmp.2");
    system ("$saxon tmp.2 $xsldir/tei2tei.xsl > tmp.3");
    # restore entities
    system ("sed \"s/|xxxx|/\\&/g\" < tmp.3 > tmp.4");
    system ("perl $toolsdir/ent2ucs.pl tmp.4 > $basename.xml");

    # convert from TEI P4 to TEI P5  (experimental)
    # system ("$saxon $basename.xml $xsldir/p4top5.xsl > $basename-p5.xml");

    # collect information about images.
    if (-d "images")
    {
        print "Collect image dimensions...\n";
        # add -c to also collect contour information with this script.
        # Need to use older perl as this requires the image-magick integration, which lags behind Perl.
        system ("perl $toolsdir/imageinfo.pl images > imageinfo.xml");
    }

    # Since the XSLT processor cannot find files easily, we have to provide the imageinfo file with a full path in a parameter.
    $fileImageParam = "";
    if (-f "imageinfo.xml")
    {
        $pwd = `pwd`;
        chop($pwd);
        $pwd =~ s/\\/\//g;

        $fileImageParam = "imageInfoFile=\"file:/$pwd/imageinfo.xml\"";
    }

    # Since the XSLT processor cannot find files easily, we have to provide the custom CSS file with a full path in a parameter.
    $cssFileParam = "";
    if (-f "custom.css.xml")
    {
        print "Adding custom.css stylesheet...\n";

        $pwd = `pwd`;
        chop($pwd);
        $pwd =~ s/\\/\//g;

        $cssFileParam = "customCssFile=\"file:/$pwd/custom.css.xml\"";
    }


    print "Create HTML version...\n";
    system ("$saxon $basename.xml $xsldir/tei2html.xsl $fileImageParam $cssFileParam > tmp.5");
    system ("perl $toolsdir/wipeids.pl tmp.5 > $basename.html");
    system ("tidy -m -wrap 72 -f tidy.err $basename.html");

    if ($usePrince == 1) 
    {
        # Do the HTML transform again, but with an additional parameter to apply Prince specific rules in the XSLT transform.

        print "Create PDF version...\n";
        $optionPrinceMarkup = "optionPrinceMarkup=\"Yes\"";
        system ("$saxon $basename.xml $xsldir/tei2html.xsl $fileImageParam $cssFileParam $optionPrinceMarkup > tmp.5");
        system ("perl $toolsdir/wipeids.pl tmp.5 > tmp.5a");
        system ("sed \"s/^[ \t]*//g\" < tmp.5a > tmp5b.html");
        system ("tidy -qe tmp5b.html");
        system ("$princedir/prince tmp5b.html $basename.pdf");
        system ("rm tmp.5a tmp5b.html");
    }

    print "Report on word usage...\n";
    system ("perl $toolsdir/ucwords.pl tmp.4 > tmp.4a");
    system ("perl $toolsdir/ent2ucs.pl tmp.4a > $basename-words.html");

    # Create a text heat map.
    if (-f "heatmap.xml")
    {
        print "Create text heat map...\n";
        system ("$saxon heatmap.xml $xsldir/tei2html.xsl customCssFile=\"file:style\\heatmap.css.xml\" > $basename-heatmap.html");
    }

    print "Create text version...\n";
    system ("perl $toolsdir/exNotesHtml.pl $filename");
    system ("cat $filename.out $filename.notes > tmp.6");
    system ("perl $toolsdir/tei2txt.pl tmp.6 > tmp.7");
    system ("fmt -sw72 tmp.7 > out.txt");
    system ("gutcheck out.txt > $basename.gutcheck");
    system ("$bindir\\jeebies out.txt > $basename.jeebies");
    system ("cat out.txt > $basename.txt");


    # check for required manual intervetions
    my $containsError = system ("grep -q \"\\[ERROR:\" $basename.txt");
    if ($containsError == 0)
    {
        print "NOTE: Please check $basename.txt for [ERROR: ...] messages.\n";
    }
    my $containsTable = system ("grep -q \"TABLE\" $basename.txt");
    if ($containsTable == 0)
    {
        print "NOTE: Please check $basename.txt for TABLEs.\n";
    }
    my $containsFigure = system ("grep -q \"FIGURE\" $basename.txt");
    if ($containsFigure == 0)
    {
        print "NOTE: Please check $basename.txt for FIGUREs.\n";
    }


    print "Clean up...";
    system ("rm tmp.* $filename.out $filename.notes out.txt");
    print " Done!\n";


    if ($nsgmlresult != 0)
    {
        print "WARNING: NSGML found validation errors in $filename.\n";
    }
}