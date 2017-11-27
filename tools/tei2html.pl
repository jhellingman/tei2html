# tei2html.pl -- process a TEI file.

use strict;

use File::Copy;
use File::stat;
use File::Temp qw(mktemp);
use File::Path qw(make_path remove_tree);
use FindBin qw($Bin);
use Getopt::Long;
use Cwd qw(abs_path);

use SgmlSupport qw/utf2numericEntities translateEntity/;

#==============================================================================
# Configuration

my $toolsdir        = $Bin;                                 # location of tools
my $xsldir          = abs_path($toolsdir . "/..");          # location of xsl stylesheets
my $patcdir         = $toolsdir . "/patc/transcriptions";   # location of patc transcription files.
my $catalog         = $toolsdir . "/pubtext/CATALOG";       # location of SGML catalog (required for nsgmls and sx)

my $java            = "java";
my $prince          = "\"C:\\Program Files (x86)\\Prince\\Engine\\bin\\prince.exe\"";
my $saxon           = "$java -Xss1024k -jar " . $toolsdir . "/lib/saxon9he.jar ";         # (see http://saxon.sourceforge.net/)
my $epubcheck       = "$java -jar " . $toolsdir . "/lib/epubcheck-4.0.2.jar ";  # (see https://github.com/IDPF/epubcheck)

#==============================================================================
# Arguments

my $makeText            = 0;
my $makeHtml            = 0;
my $makeHeatMap         = 0;
my $makePdf             = 0;
my $makeEpub            = 0;
my $makeReport          = 0;
my $makeP5              = 0;
my $makeXML             = 0;
my $makeKwic            = 0;
my $runChecks           = 0;
my $useUnicode          = 0;
my $showHelp            = 0;
my $customOption        = "";
my $customStylesheet    = "custom.css";
my $configurationFile   = "tei2html.config";
my $pageWidth           = 72;
my $makeZip             = 0;
my $noTranscription     = 0;
my $force               = 0;
my $debug               = 0;

GetOptions(
    't' => \$makeText,
    'T' => \$noTranscription,
    'h' => \$makeHtml,
    'm' => \$makeHeatMap,
    'e' => \$makeEpub,
    'k' => \$makeKwic,
    'D' => \$debug,
    'p' => \$makePdf,
    '5' => \$makeP5,
    'r' => \$makeReport,
    'x' => \$makeXML,
    'v' => \$runChecks,
    'u' => \$useUnicode,
    'f' => \$force,
    'z' => \$makeZip,
    'q' => \$showHelp,
    'C=s' => \$configurationFile,
    's=s' => \$customOption,
    'c=s' => \$customStylesheet,
    'w=i' => \$pageWidth);

my $filename = $ARGV[0];


# Metadata

my $pgNumber = "00000";
my $mainTitle = "";
my $shortTitle = "";
my $author = "";
my $language = "";
my $releaseDate = "";


if ($showHelp) {
    print "tei2html.pl -- process a TEI file to produce text, HTML, and ePub output\n\n";
    print "Usage: tei2html.pl [-thekprxvufzH] <inputfile.tei>\n\n";
    print "Options:\n";
    print "    t         Produce text output.\n";
    print "    h         Produce HTML output.\n";
    print "    e         Produce ePub output.\n";
    print "    k         Produce KWIC index of text.\n";
    print "    p         Produce PDF output.\n";
    print "    r         Produce word-usage report.\n";
    print "    x         Produce XML output.\n";
    print "    5         Convert XML output to P5 format.\n";
    print "    v         Run a number of checks, and produce a report.\n";
    print "    u         Use Unicode output (in the text version).\n";
    print "    f         Force generation of output file, even if it is newer than input.\n";
    print "    z         Produce ZIP file for Project Guteberg submission (IN DEVELOPMENT).\n";
    print "    q         Print this help and exit.\n";
    print "    T         Don't use transcription schemes.\n";
    print "    D         Debug mode.\n";
    print "    C=<file>  Use the given file as configuration file (default: tei2html.config).\n";
    print "    s=<value> Set the custom option (handed to XSLT processor).\n";
    print "    c=<file>  Set the custom CSS stylesheet (default: custom.css).\n";
    print "    w=<int>   Set the page width (default: 72 characters).\n";

    exit(0);
}

if ($makeText == 0 && $makeHtml == 0 && $makePdf == 0 && $makeEpub == 0 && $makeReport == 0 && $makeXML == 0 && $makeKwic == 0 && $runChecks == 0 && $makeP5 == 0) {
    # Revert to old default:
    $makeText = 1;
    $makeHtml = 1;
    $makeReport = 1;
}

if ($makeHtml == 1 || $makePdf == 1 || $makeEpub == 1 || $makeReport == 1 || $makeKwic == 1 || $makeP5 == 1) {
    $makeXML = 1;
}

#==============================================================================



my $tmpBase = 'tmp';
my $tmpCount = 0;


if ($filename eq "") {
    my ($directory) = ".";
    my @files = ( );
    opendir(DIRECTORY, $directory) or die "Cannot open directory $directory!\n";
    @files = readdir(DIRECTORY);
    closedir(DIRECTORY);

    foreach my $file (@files) {
        if ($file =~ /^([A-Za-z0-9-]*?)(-([0-9]+\.[0-9]+))?\.tei$/) {
            processFile($file);
        }
    }
} else {
    processFile($filename);
}


#
# processFile -- process a TEI file.
#
sub processFile($) {
    my $filename = shift;

    if ($filename eq "" || !($filename =~ /\.tei$/ || $filename =~ /\.xml$/)) {
        die "File: '$filename' is not a .TEI file\n";
    }

    $filename =~ /^([A-Za-z0-9-]*?)(-([0-9]+\.[0-9]+))?\.(tei|xml)$/;
    my $basename = $1;
    my $version  = $3;

    if ($version >= 1.0) {
        $makeText = 0;
    } else {
        $runChecks  = 1;
    }

    print "Processing TEI-file '$basename' version $version\n";

    extractMetadata($filename);
    extractEntities($filename);

    if ($makeXML && $filename =~ /\.tei$/) {
        tei2xml($filename, $basename . ".xml");
    }

    if ($runChecks) {
        runChecks($filename);
    }

    my $xmlfilename = "$basename-normalized.xml";
    if ($force != 0 || !isNewer($xmlfilename, $basename . ".xml")) {
        print "Add col and row attributes to tables...\n";
        system ("$saxon $basename.xml $xsldir/normalize-table.xsl > $xmlfilename");
    }

    if ($makeP5 != 0) {
        print "Convert from TEI P4 to TEI P5 (experimental)\n";
        system ("$saxon $xmlfilename $xsldir/p4top5.xsl > $basename-p5.xml");
    }

    # extract metadata
    system ("$saxon $xmlfilename $xsldir/tei2dc.xsl > metadata.xml");

    # create PGTEI version
    # system ("$saxon $xmlfilename $xsldir/tei2pgtei.xsl > $basename-pgtei.xml");

    collectImageInfo();
    $makeHtml   && makeHtml($basename);
    $makePdf    && makePdf($basename);
    $makeEpub   && makeEpub($basename);
    $makeText   && makeText($filename, $basename);
    $makeReport && makeReport($basename);

    if ($makeKwic == 1) {
        print "Generate a KWIC index (this may take some time)...\n";
        system ("$saxon $basename.xml $xsldir/xml2kwic.xsl > $basename-kwic.html");
    }

    if ($makeZip == 1 && $pgNumber > 0) {
        print "Prepare a zip file for (re-)submission to Project Gutenberg\n";
        makeZip($basename);
    }

    print "=== Done! ==================================================================\n";
}


sub makeHtml($) {
    my $basename = shift;
    my $xmlFile = $basename . ".xml";
    my $htmlFile = $basename . ".html";

    if ($force == 0 && isNewer($htmlFile, $xmlFile)) {
        print "Skipping convertion to HTML ($htmlFile newer than $xmlFile).\n";
        return;
    }

    my $tmpFile = temporaryFile('html', '.html');
    my $saxonParameters = determineSaxonParameters();
    print "Create HTML version...\n";
    system ("$saxon $xmlFile $xsldir/tei2html.xsl $saxonParameters basename=\"$basename\" > $tmpFile");
    system ("perl $toolsdir/wipeids.pl $tmpFile > $htmlFile");
    system ("tidy -m -wrap $pageWidth -f $basename-tidy.err $htmlFile");
    $debug || unlink($tmpFile);
}


sub makePdf($) {
    my $basename = shift;
    my $xmlFile = $basename . ".xml";
    my $pdfFile = $basename . ".pdf";

    my $tmpFile1 = temporaryFile('pdf', '.html');
    my $tmpFile2 = temporaryFile('pdf', '.html');
    my $saxonParameters = determineSaxonParameters();

    # Do the HTML transform again, but with an additional parameter to apply Prince specific rules in the XSLT transform.
    print "Create PDF version...\n";
    system ("$saxon $xmlFile $xsldir/tei2html.xsl $saxonParameters optionPrinceMarkup=\"Yes\" > $tmpFile1");
    system ("perl $toolsdir/wipeids.pl $tmpFile1 > $tmpFile2");
    system ("sed \"s/^[ \t]*//g\" < $tmpFile2 > $basename-prince.html");
    system ("$prince $basename-prince.html $pdfFile");

    $debug || unlink($tmpFile1);
    $debug || unlink($tmpFile2);
}


sub makeEpub() {
    my $basename = shift;
    my $xmlFile = $basename . ".xml";
    my $epubFile = $basename . ".epub";

    if ($force == 0 && isNewer($epubFile, $xmlFile)) {
        print "Skipping convertion to ePub ($epubFile newer than $xmlFile).\n";
        return;
    }

    my $tmpFile = temporaryFile('epub', '.html');
    my $saxonParameters = determineSaxonParameters();
    print "Create ePub version...\n";
    system ("mkdir epub");
    copyImages("epub/images");
    copyAudio("epub/audio");
    copyFonts("epub/fonts");

    system ("$saxon $xmlFile $xsldir/tei2epub.xsl $saxonParameters basename=\"$basename\" > $tmpFile");

    system ("del $epubFile");
    chdir "epub";
    system ("zip -Xr9Dq ../$epubFile mimetype");
    system ("zip -Xr9Dq ../$epubFile * -x mimetype");
    chdir "..";

    system ("$epubcheck $epubFile 2> $basename-epubcheck.err");
    $debug || unlink($tmpFile);
    $debug || remove_tree("epub")
}


sub makeText($$) {
    my $filename = shift;
    my $basename = shift;

    my $tmpFile1 = temporaryFile('txt', '.txt');
    my $tmpFile2 = temporaryFile('txt', '.txt');

    print "Create text version...\n";
    system ("perl $toolsdir/extractNotes.pl $filename");
    system ("cat $filename.out $filename.notes > $tmpFile1");
    system ("perl $toolsdir/tei2txt.pl " . ($useUnicode == 1 ? "-u " : "") . " -w $pageWidth $tmpFile1 > $tmpFile2");

    if ($useUnicode == 1) {
        # Use our own script to wrap lines, as fmt cannot deal with unicode text.
        system ("perl -S wraplines.pl $tmpFile2 > $basename.txt");
    } else {
        # system ("perl -S wraplines.pl $tmpFile2 > $basename.txt");
        system ("fmt -sw$pageWidth $tmpFile2 > $basename.txt");
    }
    system ("gutcheck $basename.txt > $basename.gutcheck");
    system ("jeebies $basename.txt > $basename.jeebies");

    # Check the version in the Processed directory as well.
    if (-f "Processed\\$basename.txt") {
        system ("gutcheck Processed\\$basename.txt > $basename-final.gutcheck");
    }

    $debug || unlink("$filename.out");
    $debug || unlink("$filename.notes");
    $debug || unlink($tmpFile1);
    $debug || unlink($tmpFile2);

    # check for required manual intervetions
    my $containsError = system ("grep -q \"\\[ERROR:\" $basename.txt");
    if ($containsError == 0) {
        print "NOTE: Please check $basename.txt for [ERROR: ...] messages.\n";
    }
    my $containsTable = system ("grep -q \"TABLE\" $basename.txt");
    if ($containsTable == 0) {
        print "NOTE: Please check $basename.txt for TABLEs.\n";
    }
    my $containsFigure = system ("grep -q \"FIGURE\" $basename.txt");
    if ($containsFigure == 0) {
        print "NOTE: Please check $basename.txt for FIGUREs.\n";
    }
}


sub makeReport($) {
    my $basename = shift;

    my $tmpFile = temporaryFile('report', '.html');
    my $options = $debug ? " -v " : "";
    $options .= $makeHeatMap ? " -m " : "";

    print "Report on word usage...\n";
    system ("perl $toolsdir/ucwords.pl $options $basename.xml > $tmpFile");
    system ("perl $toolsdir/ent2ucs.pl $tmpFile > $basename-words.html");
    $debug || unlink($tmpFile);

    # Create a text heat map.
    if (-f "heatmap.xml") {
        print "Create text heat map...\n";
        system ("$saxon heatmap.xml $xsldir/tei2html.xsl customCssFile=\"file:$xsldir/style/heatmap.css\" > $basename-heatmap.html");
    }
}


sub determineSaxonParameters() {
    my $pwd = `pwd`;
    chop($pwd);
    $pwd =~ s/\\/\//g;

    # Since the XSLT processor cannot find files easily, we have to provide the imageinfo file with a full path as a parameter.
    my $fileImageParam = "";
    if (-f "imageinfo.xml") {
        $fileImageParam = "imageInfoFile=\"file:/$pwd/imageinfo.xml\"";
    }

    # Since the XSLT processor cannot find files easily, we have to provide the custom CSS file with a full path in a parameter.
    my $cssFileParam = "";
    if (-f $customStylesheet || -f $customStylesheet . ".xml") {
        print "Adding custom stylesheet: $customStylesheet ...\n";
        $cssFileParam = "customCssFile=\"file:/$pwd/$customStylesheet\"";
    }

    my $configurationFileParam = "";
    if (-f $configurationFile) {
        print "Adding custom configuration: $configurationFile ...\n";
        $configurationFileParam = "configurationFile=\"file:/$pwd/$configurationFile\"";
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

    return "$customOption $fileImageParam $cssFileParam $configurationFileParam $opfManifestFileParam $opfMetadataFileParam ";
}


#
# makeZip -- Prepare a zip file for (re-)submission to Project Gutenberg.
#
sub makeZip($) {
    my $basename = shift;

    if (!-f $pgNumber) {
        mkdir $pgNumber;
    }

    if (!-d $pgNumber) {
        print "Failed to create directory $pgNumber, not making zip file.\n";
    }

    # Copy text version to final location

    my $textFilename = "Processed/" . $basename . ".txt";

    if (-f $textFilename) {
        copy($textFilename, $pgNumber . "/" . $pgNumber . ".txt");

        # TODO: append PG header and footer.
    }

    # Copy HTML version to final location
    if (-f $basename . ".html") {
        my $htmlDirectory = $pgNumber . "/" . $pgNumber . "-h";
        if (!-f $htmlDirectory) {
            mkdir $htmlDirectory;
        }
        copy($basename . ".html", $htmlDirectory . "/" . $pgNumber . ".html");
        copyImages("$htmlDirectory/images");
    }

    # Zip the whole structure.
    system ("zip -Xr9Dq $pgNumber.zip $pgNumber");
}


#
# extractMetadata -- try to extract some metadata from TEI file.
#
sub extractMetadata($) {
    my $file = shift;
    open(PGFILE, $file) || die("Could not open input file $file");

    # Skip upto start of actual text.
    while (<PGFILE>) {
        my $line = $_;
        if ($line =~ /<TEI.2 lang=\"?([a-z][a-z]).*?\"?>/) {
            $language = $1;
        }
        if ($line =~ /<idno type=\"?PGnum\"?>([0-9]+)<\/idno>/) {
            $pgNumber = $1;
            next;
        }
        if ($line =~ /<author\b.*?>(.*?)<\/author>/) {
            if ($author eq "") {
                $author = $1;
            } else {
                $author .= ", " . $1;
            }
            next;
        }
        if ($line =~ /<date>(.*?)<\/date>/) {
            $releaseDate = $1;
            next;
        }
        if ($line =~ /<title>(.*?)<\/title>/) {
            $mainTitle = $1;
            next;
        }
        if ($line =~ /<title type=\"?short\"?>(.*?)<\/title>/) {
            $shortTitle = $1;
            next;
        }
        if ($line =~ /<title type=\"?pgshort\"?>(.*?)<\/title>/) {
            $shortTitle = $1;
            next;
        }

        # All relevant metadata should be in or before the publicationStmt.
        if ($line =~ /<\/publicationStmt>/) {
            last;
        }
    }
    close(PGFILE);

    if (length($mainTitle) <= 26 && $shortTitle != "") {
        $shortTitle = $mainTitle;
    }

    if (length($shortTitle) > 26 ) {
        print "WARNING: short title too long (should be less than 27 characters)\n";
    }

    print "----------------------------------------------------------------------------\n";
    print "Author:       $author\n";
    print "Title:        $mainTitle\n";
    print "Short title:  $shortTitle\n";
    print "Language:     $language\n";
    print "Ebook #:      $pgNumber\n";
    print "Release Date: $releaseDate\n";
    print "----------------------------------------------------------------------------\n";
}


#
# extractEntities -- Extract a list of entities used.
#
sub extractEntities($) {
    my $file = shift;
    my %entityHash = ();
    my $entityPattern = "\&([a-z0-9._-]+);";

    open(PGFILE, $file) || die("Could not open input file $file");

    while (<PGFILE>) {
        my $remainder = $_;
        while ($remainder =~ /$entityPattern/i) {
            $remainder = $';
            my $entity = $1;
            $entityHash{$entity}++;
        }
    }

    delete @entityHash{ qw(lt gt amp quot availability.en availability.nl) };

    # Report found entities:
    if (keys %entityHash > 0) {
        print "<!DOCTYPE TEI.2 PUBLIC \"-//TEI//DTD TEI Lite 1.0//EN\" [\n\n";
        my @entityList = sort keys %entityHash;
        foreach my $entity (@entityList) {

            my $translation = utf2numericEntities(translateEntity($entity));
            my $paddedEntity = sprintf "%s%-*s", $entity, 12 - length $entity, ' ';
            my $paddedTranslation = sprintf "\"%s\"%-*s", $translation, 20 - length $translation, ' ';
            my $count = $entityHash{$entity};
            print "    <!ENTITY $paddedEntity CDATA $paddedTranslation -- $count -->\n";
        }
        print "\n]>\n\n";
    }
}


#
# runChecks -- run various checks on the file. To help error reporting, line/column information is
# added to the TEI file first.
#
sub runChecks($) {
    my $filename = shift;
    print "Running checks on $filename.\n";

    $filename =~ /^(.*)\.(xml|tei)$/;
    my $basename = $1;
    my $extension = $2;
    my $newname = $basename . "-pos." . $extension;

    my $transcribedFile = transcribe($filename);

    system ("perl -S addPositionInfo.pl \"$transcribedFile\" > \"$newname\"");

    if ($extension eq "tei") {
        my $tmpFile = temporaryFile('checks', '.tei');

        # turn &apos; into &mlapos; (modifier letter apostrophe) to distinguish them from &rsquo;
        system ("sed \"s/\&apos;/\\&mlapos;/g\" < $newname > $tmpFile");
        $debug || unlink ($newname);

        tei2xml($tmpFile, $basename . "-pos.xml");
        $newname = $basename . "-pos.xml";
        $debug || unlink($tmpFile);
        $debug || unlink($tmpFile . ".err");
    }

    system ("$saxon \"$newname\" $xsldir/checks.xsl " . determineSaxonParameters() . " > \"$basename-checks.html\"");
    if ($filename ne $transcribedFile) {
        $debug || unlink ($transcribedFile);
    }
    $debug || unlink ($newname);
}


#
# isNewer -- determine whether the first file exists and is newer than the second file
#
sub isNewer($$) {
    my $file1 = shift;
    my $file2 = shift;

    return (-e $file1 && -e $file2 && stat($file1)->mtime > stat($file2)->mtime)
}


#
# temporaryFile -- create a temporary file
#
sub temporaryFile($$) {
    my $phase = shift;
    my $extension = shift;
    $tmpCount++;
    return $tmpBase . "-" . $tmpCount . "-" . $phase . $extension;
}


#
# collectImageInfo -- collect some information about images in the imageinfo.xml file.
#
# add -c to called script arguments to also collect contour information with this script.
#
sub collectImageInfo() {
    if (-d "images") {
        print "Collect image dimensions...\n";
        system ("perl $toolsdir/imageinfo.pl images > imageinfo.xml");
    } elsif (-d "Processed/images") {
        print "Collect image dimensions...\n";
        system ("perl $toolsdir/imageinfo.pl -s Processed/images > imageinfo.xml");
    }
}


#
# copyImages -- copy image files for use in ePub.
#
sub copyImages($) {
    my $destination = shift;

    if (-d $destination) {
        # Destination exists, prevent copying into it.
        print "Warning: Destination exists; not copying images again\n";
        return;
    }

    if (-d "images") {
        system ("cp -r -u images " . $destination);
    } elsif (-d "Processed/images") {
        system ("cp -r -u Processed/images " . $destination);
    }

    # Remove redundant icon images (not used in the ePub)
    if (-f "epub\\images\\book.png") {
        system ("del epub\\images\\book.png");
    }
    if (-f "epub\\images\\card.png") {
        system ("del epub\\images\\card.png");
    }
    if (-f "epub\\images\\external.png") {
        system ("del epub\\images\\external.png");
    }
    if (-f "epub\\images\\new-cover-tn.jpg") {
        system ("del epub\\images\\new-cover-tn.jpg");
    }
}


#
# copyAudio -- copy audio files for use in ePub.
#
sub copyAudio($) {
    my $destination = shift;

    if (-d "audio") {
        system ("cp -r -u audio " . $destination);
    } elsif (-d "Processed/audio") {
        system ("cp -r -u Processed/audio " . $destination);
    }
}


#
# copyFonts -- copy fonts files for use in ePub.
#
sub copyFonts($) {
    my $destination = shift;

    if (-d "fonts") {
        system ("cp -r -u fonts " . $destination);
    } elsif (-d "Processed/fonts") {
        system ("cp -r -u Processed/fonts " . $destination);
    }
}


#
# tei2xml -- convert a file from SGML TEI to XML, also converting various notations if needed.
#
sub tei2xml($$) {
    my $sgmlFile = shift;
    my $xmlFile = shift;

    if ($force == 0 && isNewer($xmlFile, $sgmlFile)) {
        print "Skipping convertion to XML ($xmlFile newer than $sgmlFile).\n";
        return;
    }

    print "Convert SGML file '$sgmlFile' to XML file '$xmlFile'.\n";

    # Convert Latin-1 characters to entities
    my $tmpFile0 = temporaryFile('entities', '.tei');
    print "Convert Latin-1 characters to entities...\n";
    system ("patc -p $toolsdir/patc/win2sgml.pat $sgmlFile $tmpFile0");

    # Convert <INTRA> notation.
    my $containsIntralinear = system ("grep -q \"<INTRA\" $sgmlFile");
    if ($containsIntralinear == 0) {
        my $tmpFileA = temporaryFile('intra', '.tei');
        print "Convert <INTRA> notation to standard TEI <ab>-elements...\n";
        system ("perl $toolsdir/intralinear.pl $tmpFile0 > $tmpFileA");
        $debug || unlink($tmpFile0);
        $tmpFile0 = $tmpFileA;
    }

    $tmpFile0 = transcribe($tmpFile0);

    print "Check SGML...\n";
    my $nsgmlresult = system ("nsgmls -c \"$catalog\" -wall -E100000 -g -f $sgmlFile.err $tmpFile0 > $sgmlFile.nsgml");
    if ($nsgmlresult != 0) {
        print "WARNING: NSGML found validation errors in $sgmlFile.\n";
    }
    system ("rm $sgmlFile.nsgml");

    my $tmpFile1 = temporaryFile('hide-entities', '.tei');
    my $tmpFile2 = temporaryFile('sx', '.xml');
    my $tmpFile3 = temporaryFile('restore-entities', '.xml');
    my $tmpFile4 = temporaryFile('ucs', '.xml');

    print "Convert SGML to XML...\n";
    
    # hide entities for parser
    system ("sed \"s/\\&/|xxxx|/g\" < $tmpFile0 > $tmpFile1");
    system ("sx -c \"$catalog\" -E100000 -xlower -xcomment -xempty -xndata  $tmpFile1 > $tmpFile2");
    
    # apply proper case to tags.
    system ("$saxon -versionmsg:off $tmpFile2 $xsldir/tei2tei.xsl > $tmpFile3");

    # restore entities
    system ("sed \"s/|xxxx|/\\&/g\" < $tmpFile3 > $tmpFile4");
    system ("perl $toolsdir/ent2ucs.pl $tmpFile4 > $xmlFile");

    $debug || unlink($tmpFile4);
    $debug || unlink($tmpFile3);
    $debug || unlink($tmpFile2);
    $debug || unlink($tmpFile1);
    $debug || unlink($tmpFile0);
}


#
# transcribe -- transcribe foreign scripts in special notations to entities.
#
sub transcribe($) {
    my $currentFile = shift;

    if ($noTranscription == 0) {
        $currentFile = addTranscriptions($currentFile);

        $currentFile = transcribeNotation($currentFile, "<AR>",  "Arabic",                "$patcdir/arabic/ar2sgml.pat");
        $currentFile = transcribeNotation($currentFile, "<UR>",  "Urdu",                  "$patcdir/arabic/ur2sgml.pat");
        $currentFile = transcribeNotation($currentFile, "<AS>",  "Assamese",              "$patcdir/indic/as2ucs.pat");
        $currentFile = transcribeNotation($currentFile, "<BN>",  "Bengali",               "$patcdir/indic/bn2ucs.pat");
        $currentFile = transcribeNotation($currentFile, "<HE>",  "Hebrew",                "$patcdir/hebrew/he2sgml.pat");
        $currentFile = transcribeNotation($currentFile, "<SA>",  "Sanskrit (Devanagari)", "$patcdir/indic/dn2ucs.pat");
        $currentFile = transcribeNotation($currentFile, "<HI>",  "Hindi (Devanagari)",    "$patcdir/indic/dn2ucs.pat");
        $currentFile = transcribeNotation($currentFile, "<TL>",  "Tagalog (Baybayin)",    "$patcdir/tagalog/tagalog.pat");
        $currentFile = transcribeNotation($currentFile, "<TA>",  "Tamil",                 "$patcdir/indic/ta2ucs.pat");
        $currentFile = transcribeNotation($currentFile, "<SY>",  "Syriac",                "$patcdir/syriac/sy2sgml.pat");
        $currentFile = transcribeNotation($currentFile, "<CO>",  "Coptic",                "$patcdir/coptic/co2sgml.pat");
    }
    return $currentFile;
}


#
# addTranscriptions -- add a transcription of Greek or Cyrillic script in choice elements.
#
sub addTranscriptions($) {
    my $currentFile = shift;

    # Check for presence of Greek or Cyrillic
    my $containsGreek = system ("grep -q -e \"<EL>\\|<GR>\\|<CY>\\|<RU>\\|<RUX>\" $currentFile");
    if ($containsGreek == 0) {
        my $tmpFile1 = temporaryFile('greek', '.xml');
        my $tmpFile2 = temporaryFile('greek', '.xml');
        my $tmpFile3 = temporaryFile('greek', '.xml');
        my $tmpFile4 = temporaryFile('greek', '.xml');
        my $tmpFile5 = temporaryFile('greek', '.xml');

        print "Add a transcription of Greek or Cyrillic script in choice elements...\n";
        system ("perl $toolsdir/addTrans.pl -x $currentFile > $tmpFile1");
        system ("patc -p $patcdir/greek/grt2sgml.pat $tmpFile1 $tmpFile2");
        system ("patc -p $patcdir/greek/gr2sgml.pat $tmpFile2 $tmpFile3");
        system ("patc -p $patcdir/cyrillic/cyt2sgml.pat $tmpFile3 $tmpFile4");
        system ("patc -p $patcdir/cyrillic/cy2sgml.pat $tmpFile4 $tmpFile5");

        $debug || unlink($tmpFile1);
        $debug || unlink($tmpFile2);
        $debug || unlink($tmpFile3);
        $debug || unlink($tmpFile4);
        $debug || unlink($currentFile);
        $currentFile = $tmpFile5;
    }
    return $currentFile;
}


#
# transcribeNotation -- transcribe some specific notation using patc.
#
sub transcribeNotation($$$$) {
    my $currentFile = shift;
    my $tag = shift;
    my $name = shift;
    my $patternFile = shift;

    # Check for presence of notation (indicated by a given tag).
    my $containsNotation = system ("grep -q \"$tag\" $currentFile");
    if ($containsNotation == 0) {
        my $tmpFile = temporaryFile('notation', '.xml');

        print "Converting $name transcription...\n";
        system ("patc -p $patternFile $currentFile $tmpFile");

        $debug || unlink($currentFile);
        $currentFile = $tmpFile;
    }
    return $currentFile;
}
