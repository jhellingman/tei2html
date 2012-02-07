# tei2html.pl -- process a TEI file.

use strict;

use File::stat;
use File::Temp qw(mktemp);
use Getopt::Long;


#==============================================================================
# Configuration

my $toolsdir        = "C:\\Users\\Jeroen\\Documents\\eLibrary\\Tools\\tei2html\\tools";   # location of tools
my $patcdir         = $toolsdir . "\\patc\\transcriptions"; # location of patc transcription files.
my $xsldir          = "C:\\Users\\Jeroen\\Documents\\eLibrary\\Tools\\tei2html";  # location of xsl stylesheets
my $tmpdir          = "C:\\Temp";                       # place to drop temporary files
my $bindir          = "C:\\Bin";
my $catalog         = "C:\\Bin\\pubtext\\CATALOG";      # location of SGML catalog (required for nsgmls and sx)

my $prince          = "\"C:\\Program Files (x86)\\Prince\\Engine\\bin\\prince.exe\"";
my $saxon2          = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\saxonhe9\\saxon9he.jar "; # (see http://saxon.sourceforge.net/)

my $epubcheck       = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\epubcheck1.2\\epubcheck-1.2.jar ";
my $epubpreflight   = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\epubcheck\\epubpreflight-0.1.0.jar ";
my $epubcheck3      = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\epubcheck3\\epubcheck-3.0b2.jar ";

#==============================================================================
# Arguments

my $makeTXT             = 0;
my $makeHTML            = 0;
my $makePDF             = 0;
my $makeEPUB            = 0;
my $makeReport          = 0;
my $makeXML             = 0;
my $makeKwic            = 0;
my $runChecks           = 0;
my $customOption        = "";
my $customStylesheet    = "custom.css.xml";

GetOptions (
    't' => \$makeTXT,
    'h' => \$makeHTML,
    'e' => \$makeEPUB,
    'k' => \$makeKwic,
    'p' => \$makePDF,
    'r' => \$makeReport,
    'x' => \$makeXML,
    'v' => \$runChecks,
    's=s' => \$customOption,
    'c=s' => \$customStylesheet);

my $filename = $ARGV[0];

if ($makeTXT == 0 && $makeHTML == 0 && $makePDF == 0 && $makeEPUB == 0 && $makeReport == 0 && $makeXML == 0 && $makeKwic == 0 && $runChecks == 0) 
{
    # Revert to old default:
    $makeTXT = 1;
    $makeHTML = 1;
    $makeReport = 1;
}

if ($makeHTML == 1 || $makePDF == 1 || $makeEPUB == 1 || $makeReport == 1)
{
    $makeXML = 1;
}

#==============================================================================


my $nsgmlresult = 0;

my $tmpdir = $ENV{'TEMP'};


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
        }
    }
}
else
{
    processFile($filename);
}


#
# processFile -- process a TEI file.
#
sub processFile($)
{
    my $filename = shift;

    if ($filename eq "" || !($filename =~ /\.tei$/ || $filename =~ /\.xml$/))
    {
        die "File: '$filename' is not a .TEI file\n";
    }

    $filename =~ /^([A-Za-z0-9-]*?)(-([0-9]+\.[0-9]+))?\.(tei|xml)$/;
    my $basename    = $1;
    my $version     = $3;

    print "Processing TEI-file '$basename' version $version\n";

    if ($makeXML && $filename =~ /\.tei$/) 
    {
        sgml2xml($filename, $basename . ".xml");
    }

    if ($runChecks) 
    {
        runChecks($filename);
    }

    # convert from TEI P4 to TEI P5  (experimental)
    # system ("$saxon2 $basename.xml $xsldir/p4top5.xsl > $basename-p5.xml");

    # extract metadata
    system ("$saxon2 $basename.xml $xsldir/tei2dc.xsl > metadata.xml");

    # create PGTEI version
    # system ("$saxon2 $basename.xml $xsldir/tei2pgtei.xsl > $basename-pgtei.xml");

    collectImageInfo();

    my $pwd = `pwd`;
    chop($pwd);
    $pwd =~ s/\\/\//g;

    # Since the XSLT processor cannot find files easily, we have to provide the imageinfo file with a full path in a parameter.
    my $fileImageParam = "";
    if (-f "imageinfo.xml")
    {
        $fileImageParam = "imageInfoFile=\"file:/$pwd/imageinfo.xml\"";
    }

    # Since the XSLT processor cannot find files easily, we have to provide the custom CSS file with a full path in a parameter.
    my $cssFileParam = "";
    if (-f $customStylesheet)
    {
        print "Adding custom stylesheet: $customStylesheet ...\n";
        $cssFileParam = "customCssFile=\"file:/$pwd/$customStylesheet\"";
    }

    my $opfManifestFileParam = "";
    if (-f "opf-manifest.xml")
    {
        print "Adding additional elements for the OPF manifest...\n";
        $opfManifestFileParam = "opfManifestFile=\"file:/$pwd/opf-manifest.xml\"";
    }

    if ($makeHTML == 1)
    {
        if (isNewer($basename . ".html", $basename . ".xml"))
        {
            print "Skipping convertion to HTML ($basename.html newer than $basename.xml).\n";
        }
        else
        {
            my $tmpFile = mktemp('tmp-XXXXX');;
            print "Create HTML version...\n";
            system ("$saxon2 $basename.xml $xsldir/tei2html.xsl $fileImageParam $cssFileParam $customOption > $tmpFile");
            system ("perl $toolsdir/wipeids.pl $tmpFile > $basename.html");
            system ("tidy -m -wrap 72 -f $basename-tidy.err $basename.html");
            unlink($tmpFile);
        }
    }

    if ($makePDF == 1)
    {
        my $tmpFile1 = mktemp('tmp-XXXXX');;
        my $tmpFile2 = mktemp('tmp-XXXXX');;

        # Do the HTML transform again, but with an additional parameter to apply Prince specific rules in the XSLT transform.
        print "Create PDF version...\n";
        system ("$saxon2 $basename.xml $xsldir/tei2html.xsl $fileImageParam $cssFileParam $customOption optionPrinceMarkup=\"Yes\" > $tmpFile1");
        system ("perl $toolsdir/wipeids.pl $tmpFile1 > $tmpFile2");
        system ("sed \"s/^[ \t]*//g\" < $tmpFile2 > $basename-prince.html");
        system ("$prince $basename-prince.html $basename.pdf");

        unlink($tmpFile1);
        unlink($tmpFile2);
    }

    if ($makeEPUB == 1)
    {
        my $tmpFile = mktemp('tmp-XXXXX');;
        print "Create ePub version...\n";
        system ("mkdir epub");
        copyImages("epub\\images");
        system ("$saxon2 $basename.xml $xsldir/tei2epub.xsl $fileImageParam $cssFileParam $customOption $opfManifestFileParam basename=\"$basename\" > $tmpFile");

        system ("del $basename.epub");
        chdir "epub";
        system ("zip -Xr9Dq ../$basename.epub mimetype");
        system ("zip -Xr9Dq ../$basename.epub * -x mimetype");
        chdir "..";

        system ("$epubcheck $basename.epub 2> $basename-epubcheck.err");
        system ("$epubcheck3 $basename.epub 2> $basename-epubcheck3.err");
        unlink($tmpFile);
    }

    if ($makeTXT == 1)
    {
        my $tmpFile1 = mktemp('tmp-XXXXX');
        my $tmpFile2 = mktemp('tmp-XXXXX');

        print "Create text version...\n";
        system ("perl $toolsdir/exNotesHtml.pl $filename");
        system ("cat $filename.out $filename.notes > $tmpFile1");
        system ("perl $toolsdir/tei2txt.pl $tmpFile1 > $tmpFile2");
        system ("fmt -sw72 $tmpFile2 > $basename.txt");
        system ("gutcheck $basename.txt > $basename.gutcheck");
        system ("$bindir\\jeebies $basename.txt > $basename.jeebies");

        unlink("$filename.out");
        unlink("$filename.notes");
        unlink($tmpFile1);
        unlink($tmpFile2);

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
    }

    if ($makeReport == 1)
    {
        my $tmpFile = mktemp('tmp-XXXXX');
        print "Report on word usage...\n";
        system ("perl $toolsdir/ucwords.pl $basename.xml > $tmpFile");
        system ("perl $toolsdir/ent2ucs.pl $tmpFile > $basename-words.html");
        unlink($tmpFile);

        # Create a text heat map.
        if (-f "heatmap.xml")
        {
            print "Create text heat map...\n";
            system ("$saxon2 heatmap.xml $xsldir/tei2html.xsl customCssFile=\"file:style\\heatmap.css.xml\" > $basename-heatmap.html");
        }
    }

    if ($makeKwic == 1) 
    {
        print "Generate a KWIC index (this may take some time)...\n";
        system ("$saxon2 $basename.xml $xsldir/xml2kwic.xsl > $basename-kwic.html");
    }

    print " Done!\n";

    if ($nsgmlresult != 0)
    {
        print "WARNING: NSGML found validation errors in $filename.\n";
    }
}


#
# runChecks -- run various checks on the file. To help error reporting, line/column information is
# added to the TEI file first.
#
sub runChecks($)
{
    my $filename = shift;
    $filename =~ /^(.*)\.(xml|tei)$/;
    my $basename = $1;
    my $extension = $2;
    my $newname = $basename . "-pos." . $extension;
    system ("perl -S addPositionInfo.pl \"$filename\" > \"$newname\"");

    if ($extension eq "tei") 
    {
		my $tmpFile = mktemp('tmp-XXXXX');

		# turn &apos; into &mlapos; (modifier letter apostrophe) to distinguish them from &rsquo;
		system ("sed \"s/\&apos;/\\&mlapos;/g\" < $newname > $tmpFile");

        sgml2xml($tmpFile, $basename . "-pos.xml");
        $newname = $basename . "-pos.xml";
		# unlink($tmpFile);
    }

    system ("$saxon2 \"$newname\" $xsldir/checks.xsl > \"$basename-checks.html\"");
}


#
# sgml2xml -- convert a file from SGML TEI to XML, also converting various notations if needed.
#
sub sgml2xml($$)
{
    my $sgmlFile = shift;
    my $xmlFile = shift;

    if (isNewer($xmlFile, $sgmlFile))
    {
        print "Skipping convertion to XML ($xmlFile newer than $sgmlFile).\n";
        return;
    }

    print "Convert SGML file '$sgmlFile' to XML file '$xmlFile'.\n";

    # Translate Latin-1 characters to entities
    my $tmpFile0 = mktemp('tmp-XXXXX');
    print "Convert Latin-1 characters to entities...\n";
    system ("patc -p $toolsdir/win2sgml.pat $sgmlFile $tmpFile0");

    $tmpFile0 = transcribeGreek($tmpFile0);
    $tmpFile0 = transcribeNotation($tmpFile0, "<AR>", "Arabic",                "$patcdir/arabic/ar2sgml.pat");
    $tmpFile0 = transcribeNotation($tmpFile0, "<AS>", "Assamese",              "$patcdir/indic/as2ucs.pat");
    $tmpFile0 = transcribeNotation($tmpFile0, "<BN>", "Bengali",               "$patcdir/indic/bn2ucs.pat");
    $tmpFile0 = transcribeNotation($tmpFile0, "<HB>", "Hebrew",                "$patcdir/hebrew/he2sgml.pat");
    $tmpFile0 = transcribeNotation($tmpFile0, "<SA>", "Sanskrit (Devanagari)", "$patcdir/indic/dn2ucs.pat");
    $tmpFile0 = transcribeNotation($tmpFile0, "<HI>", "Hindi (Devanagari)",    "$patcdir/indic/dn2ucs.pat");
    $tmpFile0 = transcribeNotation($tmpFile0, "<TL>", "Tagalog (Baybayin)",    "$patcdir/tagalog/tagalog.pat");
    $tmpFile0 = transcribeNotation($tmpFile0, "<TM>", "Tamil",                 "$patcdir/indic/tm2ucs.pat");

    print "Check SGML...\n";
    $nsgmlresult = system ("nsgmls -c \"$catalog\" -wall -E100000 -g -f $sgmlFile.err $tmpFile0 > $sgmlFile.nsgml");
    system ("rm $sgmlFile.nsgml");

    my $tmpFile1 = mktemp('tmp-XXXXX');
    my $tmpFile2 = mktemp('tmp-XXXXX');
    my $tmpFile3 = mktemp('tmp-XXXXX');
    my $tmpFile4 = mktemp('tmp-XXXXX');

    print "Convert SGML to XML...\n";
    # hide entities for parser
    system ("sed \"s/\\&/|xxxx|/g\" < $tmpFile0 > $tmpFile1");
    system ("sx -c $catalog -E100000 -xlower -xcomment -xempty -xndata  $tmpFile1 > $tmpFile2");
    system ("$saxon2 $tmpFile2 $xsldir/tei2tei.xsl > $tmpFile3");
    # restore entities
    system ("sed \"s/|xxxx|/\\&/g\" < $tmpFile3 > $tmpFile4");
    system ("perl $toolsdir/ent2ucs.pl $tmpFile4 > $xmlFile");

    unlink($tmpFile4);
    unlink($tmpFile3);
    unlink($tmpFile2);
    unlink($tmpFile1);
    unlink($tmpFile0);
}


#
# isNewer -- determine whether the first file exists and is newer than the second file
#
sub isNewer($$)
{
    my $file1 = shift;
    my $file2 = shift;

    return (-e $file1 && -e $file2 && stat($file1)->mtime > stat($file2)->mtime) 
}


#
# transcribeGreek -- transcribe Greek in a specific notation to Greek script, and add transcription in choice elements.
#
sub transcribeGreek($)
{
    my $currentFile = shift;

    # Check for presence of Greek transcription
    my $containsGreek = system ("grep -q \"<GR>\" $currentFile");
    if ($containsGreek == 0)
    {
        my $tmpFile1 = mktemp('tmp-XXXXX');;
        my $tmpFile2 = mktemp('tmp-XXXXX');;
        my $tmpFile3 = mktemp('tmp-XXXXX');;

        print "Converting Greek transcription...\n";
        print "Adding Greek transcription in choice elements...\n";
        system ("perl $toolsdir/gr2trans.pl -x $currentFile > $tmpFile1");
        system ("patc -p $patcdir/greek/grt2sgml.pat $tmpFile1 $tmpFile2");
        system ("patc -p $patcdir/greek/gr2sgml.pat $tmpFile2 $tmpFile3");

        unlink($tmpFile1);
        unlink($tmpFile2);
        unlink($currentFile);
        $currentFile = $tmpFile3;
    }
    return $currentFile;
}


#
# transcribeNotation -- transcribe some specific notation using patc.
#
sub transcribeNotation($$$$)
{
    my $currentFile = shift;
    my $tag = shift;
    my $name = shift;
    my $patternFile = shift;

    # Check for presence of transcription notation
    my $containsNotation = system ("grep -q \"$tag\" $currentFile");
    if ($containsNotation == 0)
    {
        my $tmpFile = mktemp('tmp-XXXXX');;

        print "Converting $name transcription...\n";
        system ("patc -p $patternFile $currentFile $tmpFile");

        unlink($currentFile);
        $currentFile = $tmpFile;
    }
    return $currentFile;
}


#
# collectImageInfo -- collect some information about images in the imageinfo.xml file.
#
# add -c to called script arguments to also collect contour information with this script.
#
sub collectImageInfo()
{
    if (-d "images")
    {
        print "Collect image dimensions...\n";
        system ("perl $toolsdir/imageinfo.pl images > imageinfo.xml");
    }
    elsif (-d "Gutenberg\\images")
    {
        print "Collect image dimensions...\n";
        system ("perl $toolsdir/imageinfo.pl -s Gutenberg\\images > imageinfo.xml");
    }
}

#
# copyImages
#
sub copyImages()
{
    my $destination = shift;

    if (-d "images")
    {
        system ("cp -r -u images " . $destination);
    }
    elsif (-d "Gutenberg\\images")
    {
        system ("cp -r -u Gutenberg\\images " . $destination);
    }
}
