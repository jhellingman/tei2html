# tei2html.pl -- process a TEI file.

use strict;
use warnings;

use File::Copy;
use File::stat;
use File::Temp qw(mktemp);
use File::Path qw(make_path remove_tree);
use FindBin qw($Bin);
use Getopt::Long;
use Cwd qw(abs_path);

use SgmlSupport qw/utf2numericEntities translateEntity/;

my $javaOptions = '-Xms3072m -Xmx3072m -Xss1024k ';

#==============================================================================
# Configuration

my $toolsdir        = $Bin;                                 # location of tools
my $xsldir          = abs_path($toolsdir . "/..");          # location of xsl stylesheets
my $patcdir         = $toolsdir . "/patc/transcriptions";   # location of patc transcription files.
my $catalog         = $toolsdir . "/pubtext/CATALOG";       # location of SGML catalog (required for nsgmls and sx)

my $java            = "java $javaOptions";
my $prince          = "\"C:\\Program Files (x86)\\Prince\\Engine\\bin\\prince.exe\"";   # see https://www.princexml.com/
my $saxon           = "$java -jar " . $toolsdir . "/lib/saxon9he.jar ";                 # see http://saxon.sourceforge.net/
my $epubcheck       = "$java -jar " . $toolsdir . "/lib/epubcheck-4.0.2.jar ";          # see https://github.com/IDPF/epubcheck
my $jeebies         = "C:\\Bin\\jeebies";                                               # see http://gutcheck.sourceforge.net/
my $gutcheck        = "gutcheck";
my $nsgmls          = "nsgmls";                                                         # see http://www.jclark.com/sp/
my $sx              = "sx";

#==============================================================================
# Arguments

my $makeText            = 0;
my $explicitMakeText    = 0;
my $makeHtml            = 0;
my $makeHeatMap         = 0;
my $makePdf             = 0;
my $makeEpub            = 0;
my $epubVersion         = "3.0.1";
my $makeWordlist        = 0;
my $makeXML             = 0;
my $makeP5              = 0;
my $makePGTEI           = 0;
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
my $trace               = 0;
my $profile             = 0;
my $useTidy             = 0;
my $kwicLanguages       = "";
my $kwicWords           = "";
my $kwicCaseSensitive   = "no";
my $kwicMixup           = "";
my $kwicVariants        = 1;

GetOptions(
    't' => \$explicitMakeText,
    'h' => \$makeHtml,
    'e' => \$makeEpub,
    'k' => \$makeKwic,
    'p' => \$makePdf,
    'x' => \$makeXML,
    '5' => \$makeP5,
    'r' => \$makeWordlist,
    'v' => \$runChecks,
    'u' => \$useUnicode,
    'f' => \$force,
    'z' => \$makeZip,
    'q' => \$showHelp,
    'C=s' => \$configurationFile,
    's=s' => \$customOption,
    'c=s' => \$customStylesheet,
    'w=i' => \$pageWidth,
    'pagewidth=i' => \$pageWidth,
    'debug' => \$debug,
    'trace' => \$trace,
    'profile' => \$profile,
    'heatmap' => \$makeHeatMap,
    'epubversion=s' => \$epubVersion,
    'notranscription' => \$noTranscription,
    'kwiclang=s' => \$kwicLanguages,
    'kwicword=s' => \$kwicWords,
    'kwiccasesensitive=s' => \$kwicCaseSensitive,
    'kwicmixup=s' => \$kwicMixup,
    'kwicvariants=i' => \$kwicVariants,
    'help' => \$showHelp,
    'tidy'=> \$useTidy);

my $inputFile = '';
if (defined $ARGV[0]) {
    $inputFile = $ARGV[0];
}

# Metadata

my $pgNumber = "00000";
my $mainTitle = "";
my $shortTitle = "";
my $author = "";
my $language = "";
my $releaseDate = "";


if ($showHelp == 1) {
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
    print "    z         Produce ZIP file for Project Gutenberg submission (IN DEVELOPMENT).\n";
    print "    q         Print this help and exit.\n";
    print "    notranscription       Don't use transcription schemes.\n";
    print "    debug                 Debug mode.\n";
    print "    trace                 Trace mode.\n";
    print "    profile               Profile mode.\n";
    print "    heatmap               Generate a heatmap version.\n";
    print "    kwiclang=<languages>  Languages to be shown in KWIC, use ISO-639 codes, separated by spaces.\n";
    print "    kwicword=<words>      Words to be shown in KWIC, separate words by spaces.\n";
    print "    kwiccase=<yes/no>     Be case-sensitive in KWIC.\n";
    print "    kwicmixup=<string>    Letters that can be mixed-up in KWIC, separate letters by spaces.\n";
    print "    kwicvariants=<number> Report only words with at least this many variant spellings.\n";
    print "    C=<file>  Use the given file as configuration file (default: tei2html.config).\n";
    print "    s=<value> Set the custom option (handed to XSLT processor).\n";
    print "    c=<file>  Set the custom CSS stylesheet (default: custom.css).\n";
    print "    w=<int>   Set the page width (default: 72 characters).\n";

    exit(0);
}

if ($explicitMakeText == 0 && $makeHtml == 0 && $makePdf == 0 && $makeEpub == 0 && $makeWordlist == 0 && $makeXML == 0 && $makeKwic == 0 && $runChecks == 0 && $makeP5 == 0) {
    # Revert to old default:
    $makeText = 1;
    $makeHtml = 1;
    $makeWordlist = 1;
    $runChecks = 1;
}

if ($debug == 1) {
    print "Called with params: $ARGV\n";
}

#==============================================================================

my $tmpBase = 'tmp';
my $tmpCount = 0;

processFiles();


sub processFiles {
    if ($inputFile eq '') {
        my ($directory) = '.';
        my @files = ();
        opendir(DIRECTORY, $directory) or die "Cannot open directory $directory!\n";
        @files = readdir(DIRECTORY);
        closedir(DIRECTORY);

        foreach my $file (@files) {
            if ($file =~ /^([A-Za-z0-9-]*?)(-([0-9]+\.[0-9]+))?\.tei$/) {
                processFile($file);
            }
        }
    }
    else {
        processFile($inputFile);
    }
}


#
# processFile -- process a TEI file.
#
sub processFile($) {
    my $filename = shift;

    if ($filename eq "" || !($filename =~ /\.tei$/ || $filename =~ /\.xml$/)) {
        die "File: '$filename' doesn't look like a TEI file\n";
    }
    print "Processing TEI file $filename\n";

    $filename =~ /^([A-Za-z0-9-]*?)(?:-([0-9]+\.[0-9]+))?\.(tei|xml)$/;
    my $basename = $1;
    my $version = $2;
    my $format = $3;

    if ($basename eq '') {
        $filename =~ /^(.+)\.(tei|xml)$/;
        $basename = $1;
        $version = '0.0';
        $format = $2;
    }

    if (!defined $version) {
        $version = '0.0';
    }

    if ($version >= 1.0) {
        $makeText = 0;
    }
    if ($explicitMakeText == 1) {
        $makeText = 1;
    }

    extractMetadata($filename);
    extractEntities($filename);

    makeQrCode($pgNumber);
    collectImageInfo();

    my $xmlFilename = $format eq 'tei' ? $basename . '.xml' : $filename;
    if ($format eq 'tei') {
        tei2xml($filename, $xmlFilename);
    }

    my $normalizedXmlFilename = "$basename-normalized.xml";
    normalizeXml($xmlFilename, $normalizedXmlFilename);

    makeMetadata($normalizedXmlFilename);
    makeReadme($normalizedXmlFilename);

    $runChecks && runChecks($filename);
    $makeWordlist && makeWordlist($basename, $normalizedXmlFilename);

    $makeHtml && makeHtml($basename, $normalizedXmlFilename);
    $makeEpub && makeEpub($basename, $normalizedXmlFilename);
    $makePdf  && makePdf($basename,  $normalizedXmlFilename);
    $makeKwic && makeKwic($basename, $normalizedXmlFilename);
    $makeText && makeText($basename, $filename);
    $makeP5   && makeP5($basename, $normalizedXmlFilename);

    $makePGTEI && system ("$saxon $normalizedXmlFilename $xsldir/tei2pgtei.xsl > $basename-pgtei.xml");

    if ($makeZip == 1 && $pgNumber > 0) {
        print "Prepare a zip file for (re-)submission to Project Gutenberg\n";
        makeZip($basename);
    }

    print "=== Done! ==================================================================\n";
}


sub normalizeXml($$) {
    my $xmlFilename = shift;
    my $normalizedXmlFilename = shift;

    if ($force == 0 && isNewer($normalizedXmlFilename, $xmlFilename)) {
        print "Skipping conversion to normalized XML ($normalizedXmlFilename newer than $xmlFilename).\n";
        return;
    }

    print "Normalize tables and add col and row attributes to cells...\n";
    system ("$saxon $xmlFilename $xsldir/normalize-table.xsl > $normalizedXmlFilename");
}


sub makeP5($$) {
    my $basename = shift;
    my $xmlFilename = shift;
    my $p5XmlFilename = $basename . '-p5.xml';

    if ($force == 0 && isNewer($p5XmlFilename, $xmlFilename)) {
        print "Skipping conversion to TEI P5 XML ($p5XmlFilename newer than $xmlFilename).\n";
        return;
    }

    print "Convert from TEI P4 to TEI P5 (experimental)\n";
    system ("$saxon $xmlFilename $xsldir/p4top5.xsl > $p5XmlFilename");
}


sub makeMetadata($) {
    my $normalizedXmlFilename = shift;

    if ($force != 0 || isNewer($normalizedXmlFilename, 'metadata.xml')) {
        print "Extract metadata to metadata.xml...\n";
        system ("$saxon $normalizedXmlFilename $xsldir/tei2dc.xsl > metadata.xml");
    }
}


sub makeReadme($) {
    my $normalizedXmlFilename = shift;

    if ($force != 0 || isNewer($normalizedXmlFilename, 'README.md')) {
        print "Extract metadata to README.md...\n";
        system ("$saxon $normalizedXmlFilename $xsldir/tei2readme.xsl > README.md");
    }
}


sub makeKwic($$) {
    my $basename = shift;
    my $xmlFilename = shift;
    my $kwicFilename = determineKwicFilename($basename);

    if ($force == 0 && isNewer($kwicFilename, $xmlFilename)) {
        print "Skipping creation of KWIC ($kwicFilename newer than $xmlFilename).\n";
        return;
    }

    my $saxonParameters = determineSaxonParameters();

    my $kwicLanguagesParameter = ($kwicLanguages eq '') ? '' : "select-language=\"$kwicLanguages\"";
    my $kwicKeywordParameter = ($kwicWords eq '') ? '' : "keyword=\"$kwicWords\"";
    my $kwicMixupParameter = ($kwicMixup eq '') ? '' : "mixup=\"$kwicMixup\"";
    my $kwicCaseSensitiveParameter = ($kwicCaseSensitive eq 'yes' or $kwicCaseSensitive eq 'true') ? 'case-sensitive=true' : '';
    my $kwicVariantsParameter = ($kwicVariants > 1) ? "min-variant-count=\"$kwicVariants\"" : '';

    print "Generate a KWIC index (this may take some time)...\n";
    system ("$saxon $xmlFilename $xsldir/xml2kwic.xsl $saxonParameters $kwicLanguagesParameter $kwicKeywordParameter $kwicMixupParameter $kwicCaseSensitiveParameter $kwicVariantsParameter > $kwicFilename");
}


sub determineKwicFilename($) {
    my $basename = shift;

    my $namePartLanguage = $kwicLanguages;
    $namePartLanguage =~ tr/ /-/;
    if ($namePartLanguage ne '') {
        $namePartLanguage = '-' . $namePartLanguage;
    }

    my $namePartWord = $kwicWords;
    $namePartWord =~ tr/ /-/;
    if ($namePartWord ne '') {
        $namePartWord = '-' . $namePartWord;
    }

    my $namePartMixup = $kwicMixup;
    $namePartMixup =~ tr/ /-/;
    if ($namePartMixup ne '') {
        $namePartMixup = '-mixup-' . $namePartMixup;
    }

    my $namePartVariants = '';
    if ($kwicVariants > 1) {
        $namePartVariants = '-variants-' . $kwicVariants;
    }

    return $basename . '-kwic' . $namePartLanguage . $namePartWord . $namePartMixup . $namePartVariants . '.html';
}


sub makeQrCode($) {
    my $pgNumber = shift;

    if ($pgNumber > 0) {
        my $imageDir = '.';
        if (-d 'images') {
            $imageDir = 'images';
        } elsif (-d 'Processed/images') {
            $imageDir = 'Processed/images';
        }

        if (not -e "$imageDir/qrcode.png") {
            # Generate a QR code with a transparent background.
            system("qrcode -l '#0000' -o $imageDir/qrcode.png https://www.gutenberg.org/ebooks/$pgNumber");
        }
    }
}


sub makeHtml($$) {
    my $basename = shift;
    my $xmlFile = shift;
    my $htmlFile = $basename . '.html';

    if ($force == 0 && isNewer($htmlFile, $xmlFile)) {
        print "Skipping conversion to HTML ($htmlFile newer than $xmlFile).\n";
        return;
    }

    my $tmpFile = temporaryFile('html', '.html');
    my $saxonParameters = determineSaxonParameters();
    print "Create HTML version...\n";
    system ("$saxon $xmlFile $xsldir/tei2html.xsl $saxonParameters basename=\"$basename\" > $tmpFile");
    system ("perl $toolsdir/wipeids.pl $tmpFile > $htmlFile");
    if ($useTidy != 0) {
        system ("tidy -m -wrap $pageWidth -f $basename-tidy.err $htmlFile");
    } else {
        my $tmpFile2 = temporaryFile('html', '.html');
        system ("perl $toolsdir/cleanHtml.pl $htmlFile > $tmpFile2");
        unlink($htmlFile);
        system ("mv $tmpFile2 $htmlFile");
    }
    $debug || unlink($tmpFile);
}


sub makePdf($$) {
    my $basename = shift;
    my $xmlFile = shift;
    my $pdfFile =  $basename . '.pdf';

    if ($force == 0 && isNewer($pdfFile, $xmlFile)) {
        print "Skipping conversion to PDF ($pdfFile newer than $xmlFile).\n";
        return;
    }

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


sub makeEpub($$) {
    my $basename = shift;
    my $xmlFile = shift;
    my $epubFile = $basename . '.epub';

    if ($force == 0 && isNewer($epubFile, $xmlFile)) {
        print "Skipping conversion to ePub ($epubFile newer than $xmlFile).\n";
        return;
    }

    my $tmpFile = temporaryFile('epub', '.html');
    my $saxonParameters = determineSaxonParameters();
    print "Create ePub version...\n";
    system ('mkdir epub');
    copyImages('epub/images');
    # copyFormulas('epub/formulas'); # Not including formulas in ePub, as they are embedded as MathML (TODO: this is default, handle non-default situations)
    copyAudio('epub/audio');
    copyFonts('epub/fonts');

    system ("$saxon $xmlFile $xsldir/tei2epub.xsl $saxonParameters basename=\"$basename\" epubversion=\"$epubVersion\" > $tmpFile");

    system ("del $epubFile");
    chdir 'epub';
    system ("zip -Xr9Dq ../$epubFile mimetype");
    system ("zip -Xr9Dq ../$epubFile * -x mimetype");
    chdir '..';

    system ("$epubcheck $epubFile 2> $basename-epubcheck.err");
    $debug || unlink($tmpFile);
    $debug || remove_tree('epub')
}


sub makeText($$) {
    my $basename = shift;
    my $filename = shift;
    my $textFile = $basename . '.txt';

    if ($force == 0 && isNewer($textFile, $filename)) {
        print "Skipping conversion to text file ($textFile newer than $filename).\n";
        return;
    }

    my $tmpFile1 = temporaryFile('txt', '.txt');
    my $tmpFile2 = temporaryFile('txt', '.txt');

    print "Create text version...\n";
    system ("perl $toolsdir/extractNotes.pl $filename");
    system ("cat $filename.out $filename.notes > $tmpFile1");
    system ("perl $toolsdir/tei2txt.pl " . ($useUnicode == 1 ? '-u ' : '') . " -w $pageWidth $tmpFile1 > $tmpFile2");

    if ($useUnicode == 1) {
        # Use our own script to wrap lines, as fmt cannot deal with unicode text.
        system ("perl -S wraplines.pl $tmpFile2 > $textFile");
    } else {
        # system ("perl -S wraplines.pl $tmpFile2 > $basename.txt");
        system ("fmt -sw$pageWidth $tmpFile2 > $textFile");
    }
    system ("$gutcheck $textFile > $basename.gutcheck");
    system ("$jeebies $textFile > $basename.jeebies");

    # Check the version in the Processed directory as well.
    if (-f "Processed/$textFile") {
        system ("$gutcheck Processed/$textFile > $basename-final.gutcheck");
    }

    $debug || unlink("$filename.out");
    $debug || unlink("$filename.notes");
    $debug || unlink($tmpFile1);
    $debug || unlink($tmpFile2);

    # check for required manual interventions
    my $containsError = system ("grep -q \"\\[ERROR:\" $textFile");
    if ($containsError == 0) {
        print "NOTE: Please check $textFile for [ERROR: ...] messages.\n";
    }
    my $containsTable = system ("grep -q \"TABLE\" $textFile");
    if ($containsTable == 0) {
        print "NOTE: Please check $textFile for TABLEs.\n";
    }
    my $containsFigure = system ("grep -q \"FIGURE\" $textFile");
    if ($containsFigure == 0) {
        print "NOTE: Please check $textFile for FIGUREs.\n";
    }
}


sub makeWordlist($$) {
    my $basename = shift;
    my $xmlFile = shift;
    my $wordlistFile = $basename . '-words.html';

    if ($force == 0 && isNewer($wordlistFile, $xmlFile)) {
        print "Skipping creation of word list ($wordlistFile newer than $xmlFile).\n";
        return;
    }

    my $tmpFile = temporaryFile('report', '.html');
    my $options = $debug ? ' -v ' : '';
    $options .= $makeHeatMap ? ' -m ' : '';

    print "Report on word usage...\n";
    system ("perl $toolsdir/ucwords.pl $options $xmlFile > $tmpFile");
    system ("perl $toolsdir/ent2ucs.pl $tmpFile > $wordlistFile");
    $debug || unlink($tmpFile);

    # Create a text heat map.
    if (-f 'heatmap.xml') {
        print "Create text heat map...\n";
        system ("$saxon heatmap.xml $xsldir/tei2html.xsl customCssFile=\"file:$xsldir/style/heatmap.css\" > heatmap.html");
    }
}


sub determineSaxonParameters() {
    my $pwd = `pwd`;
    chop($pwd);
    $pwd =~ s/\\/\//g;

    # Since the XSLT processor cannot find files easily, we have to provide the imageinfo file with a full path as a parameter.
    my $fileImageParam = '';
    if (-f 'imageinfo.xml') {
        $fileImageParam = "imageInfoFile=\"file:/$pwd/imageinfo.xml\"";
    }

    # Since the XSLT processor cannot find files easily, we have to provide the custom CSS file with a full path in a parameter.
    my $cssFileParam = '';
    if (-f $customStylesheet || -f $customStylesheet . '.xml') {
        print "Adding custom stylesheet: $customStylesheet ...\n";
        $cssFileParam = "customCssFile=\"file:/$pwd/$customStylesheet\"";
    }

    my $configurationFileParam = '';
    if (-f $configurationFile) {
        print "Adding custom configuration: $configurationFile ...\n";
        $configurationFileParam = "configurationFile=\"file:/$pwd/$configurationFile\"";
    }

    my $opfManifestFileParam = '';
    if (-f 'opf-manifest.xml') {
        print "Adding additional elements for the OPF manifest...\n";
        $opfManifestFileParam = "opfManifestFile=\"file:/$pwd/opf-manifest.xml\"";
    }

    my $opfMetadataFileParam = '';
    if (-f 'opf-metadata.xml') {
        print "Adding additional items to the OPF metadata...\n";
        $opfMetadataFileParam = "opfMetadataFile=\"file:/$pwd/opf-metadata.xml\"";
    }

    my $traceArguments = '';
    if ($trace == 1) {
        $traceArguments = ' -T -traceout:trace.txt ';
    }

    my $profileArguments = '';
    if ($profile == 1) {
        $profileArguments = ' -TP:profile.html ';
    }

    return "$traceArguments $profileArguments $customOption $fileImageParam $cssFileParam $configurationFileParam $opfManifestFileParam $opfMetadataFileParam ";
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
        return;
    }

    # Copy text version to final location

    my $textFilename = 'Processed/' . $basename . '.txt';

    if (-f $textFilename) {
        copy($textFilename, $pgNumber . '/' . $pgNumber . '.txt');

        # TODO: append PG header and footer.
    }

    # Copy HTML version to final location
    if (-f $basename . '.html') {
        my $htmlDirectory = $pgNumber . '/' . $pgNumber . '-h';
        if (!-f $htmlDirectory) {
            mkdir $htmlDirectory;
        }
        copy($basename . '.html', $htmlDirectory . '/' . $pgNumber . '.html');

        # TODO: append PG header and footer.

        copyImages("$htmlDirectory/images");
    }

    # Zip the whole structure.
    system ("zip -Xr9Dq $pgNumber.zip $pgNumber");
}


#
# extractMetadata -- try to extract some metadata from the TEI file.
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

    if (length($mainTitle) <= 26 && $shortTitle ne '') {
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

    $filename =~ /^(.*)\.(xml|tei)$/;
    my $basename = $1;
    my $format = $2;
    my $checkFilename = $basename . '-checks.html';
    
    if ($force == 0 && isNewer($checkFilename, $filename)) {
        print "Skipping run checks because '$checkFilename' is newer than '$filename'.\n";
        return;
    }
    print "Run checks on $filename.\n";

    my $transcribedFile = transcribe($filename);

    my $positionInfoFilename = $basename . '-pos.' . $format;

    system ("perl -S addPositionInfo.pl \"$transcribedFile\" > \"$positionInfoFilename\"");

    if ($format eq 'tei') {
        my $tmpFile = temporaryFile('checks', '.tei');

        # Hide a number of entities for the checks, so matching pairs of punctuation can be
        # verified. The trick used is that unmatched parentheses and brackets can be represented
        # by their SGML entities, and those entities will be mapped to alternative characters
        # for the test only. Similary, the &apos; entity is mapped to &mlapos;, instead of &rsquo;.
        system ("perl -S precheck.pl \"$positionInfoFilename\" > \"$tmpFile\"");
        $debug || unlink ($positionInfoFilename);

        tei2xml($tmpFile, $basename . '-pos.xml');
        $positionInfoFilename = $basename . '-pos.xml';
        $debug || unlink($tmpFile);
        $debug || unlink($tmpFile . '.err');
    }

    my $xmlfilename = temporaryFile('checks', '.xml');
    system ("$saxon \"$positionInfoFilename\" $xsldir/normalize-table.xsl > $xmlfilename");

    system ("$saxon \"$xmlfilename\" $xsldir/checks.xsl " . determineSaxonParameters() . " > \"$checkFilename\"");
    if ($filename ne $transcribedFile) {
        $debug || unlink ($transcribedFile);
    }
    $debug || unlink ($positionInfoFilename);
    $debug || unlink ($xmlfilename);
}


#
# isNewer -- determine whether the derived file exists, is not empty, and is newer than the source file
#
sub isNewer($$) {
    my $derivedFile = shift;
    my $sourceFile = shift;

    return (-e $derivedFile && -s $derivedFile != 0 && -e $sourceFile && stat($derivedFile)->mtime > stat($sourceFile)->mtime);
}


#
# temporaryFile -- create a temporary file
#
sub temporaryFile($$) {
    my $phase = shift;
    my $extension = shift;
    $tmpCount++;
    return $tmpBase . '-' . $tmpCount . '-' . $phase . $extension;
}


#
# collectImageInfo -- collect some information about images in the imageinfo.xml file.
#
# add -c to called script arguments to also collect contour information with this script.
#
sub collectImageInfo() {
    if (-d 'images') {
        print "Collect image dimensions...\n";
        system ("perl $toolsdir/imageinfo.pl images > imageinfo.xml");
    } elsif (-d 'Processed/images') {
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

    if (-d 'images') {
        system ('cp -r -u images ' . $destination);
    } elsif (-d 'Processed/images') {
        system ('cp -r -u Processed/images ' . $destination);
    }

    # Remove redundant icon images (not used in the ePub)
    if (-f 'epub/images/book.png') {
        system ('rm epub/images/book.png');
    }
    if (-f 'epub/images/card.png') {
        system ('rm epub/images/card.png');
    }
    if (-f 'epub/images/external.png') {
        system ('rm epub/images/external.png');
    }
}


#
# copyFormulas -- copy formula svg-files for use in ePub.
#
sub copyFormulas($) {
    my $destination = shift;

    if (-d 'formulas') {
        system ('cp -r -u formulas ' . $destination);
    } elsif (-d 'Processed/formulas') {
        system ('cp -r -u Processed/formulas ' . $destination);
    }
}

#
# copyAudio -- copy audio files for use in ePub.
#
sub copyAudio($) {
    my $destination = shift;

    if (-d 'audio') {
        system ('cp -r -u audio ' . $destination);
    } elsif (-d 'Processed/audio') {
        system ('cp -r -u Processed/audio ' . $destination);
    }
}


#
# copyFonts -- copy fonts files for use in ePub.
#
sub copyFonts($) {
    my $destination = shift;

    if (-d 'fonts') {
        system ('cp -r -u fonts ' . $destination);
    } elsif (-d 'Processed/fonts') {
        system ('cp -r -u Processed/fonts ' . $destination);
    }
}


#
# tei2xml -- convert a file from SGML TEI to XML, also converting various notations if needed.
#
sub tei2xml($$) {
    my $sgmlFile = shift;
    my $xmlFile = shift;

    if ($force == 0 && isNewer($xmlFile, $sgmlFile)) {
        print "Skipping conversion to XML ('$xmlFile' newer than '$sgmlFile').\n";
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
    my $nsgmlresult = system ("$nsgmls -c \"$catalog\" -wall -E100000 -g -f $sgmlFile.err $tmpFile0 > $sgmlFile.nsgml");
    if ($nsgmlresult != 0) {
        print "WARNING: NSGML found validation errors in $sgmlFile.\n";
    }
    $debug || unlink("$sgmlFile.nsgml");

    my $tmpFile1 = temporaryFile('hide-entities', '.tei');
    my $tmpFile2 = temporaryFile('sx', '.xml');
    my $tmpFile3 = temporaryFile('restore-entities', '.xml');
    my $tmpFile4 = temporaryFile('ucs', '.xml');

    print "Convert SGML to XML...\n";

    # hide entities for parser
    system ("sed \"s/\\&/|xxxx|/g\" < $tmpFile0 > $tmpFile1");
    system ("$sx -c \"$catalog\" -E100000 -xlower -xcomment -xempty -xndata  $tmpFile1 > $tmpFile2");

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

        $currentFile = transcribeNotation($currentFile, '<AR>',  'Arabic',                "$patcdir/arabic/ar2sgml.pat");
        $currentFile = transcribeNotation($currentFile, '<UR>',  'Urdu',                  "$patcdir/arabic/ur2sgml.pat");
        $currentFile = transcribeNotation($currentFile, '<FA>',  'Farsi',                 "$patcdir/arabic/ur2sgml.pat");
        $currentFile = transcribeNotation($currentFile, '<AS>',  'Assamese',              "$patcdir/indic/as2ucs.pat");
        $currentFile = transcribeNotation($currentFile, '<BN>',  'Bengali',               "$patcdir/indic/bn2ucs.pat");
        $currentFile = transcribeNotation($currentFile, '<HE>',  'Hebrew',                "$patcdir/hebrew/he2sgml.pat");
        $currentFile = transcribeNotation($currentFile, '<SA>',  'Sanskrit (Devanagari)', "$patcdir/indic/dn2ucs.pat");
        $currentFile = transcribeNotation($currentFile, '<HI>',  'Hindi (Devanagari)',    "$patcdir/indic/dn2ucs.pat");
        $currentFile = transcribeNotation($currentFile, '<TL>',  'Tagalog (Baybayin)',    "$patcdir/tagalog/tagalog.pat");
        $currentFile = transcribeNotation($currentFile, '<TA>',  'Tamil',                 "$patcdir/indic/ta2ucs.pat");
        $currentFile = transcribeNotation($currentFile, '<SY>',  'Syriac',                "$patcdir/syriac/sy2sgml.pat");
        $currentFile = transcribeNotation($currentFile, '<CO>',  'Coptic',                "$patcdir/coptic/co2sgml.pat");
    }
    return $currentFile;
}


#
# addTranscriptions -- add a transcription of Greek or Cyrillic script in choice elements.
#
sub addTranscriptions($) {
    my $currentFile = shift;

    # Check for presence of Greek or Cyrillic
    my $containsGreek = system ("grep -q -e \"<EL>\\|<GR>\\|<CY>\\|<RU>\\|<RUX>\\|<SR>\" $currentFile");
    if ($containsGreek == 0) {
        my $tmpFile1 = temporaryFile('greek', '.xml');
        my $tmpFile2 = temporaryFile('greek', '.xml');
        my $tmpFile3 = temporaryFile('greek', '.xml');
        my $tmpFile4 = temporaryFile('greek', '.xml');
        my $tmpFile5 = temporaryFile('greek', '.xml');
        my $tmpFile6 = temporaryFile('greek', '.xml');
        my $tmpFile7 = temporaryFile('greek', '.xml');

        print "Add a transcription of Greek or Cyrillic script in choice elements...\n";
        system ("perl $toolsdir/addTrans.pl -x $currentFile > $tmpFile1");
        system ("patc -p $patcdir/greek/grt2sgml.pat $tmpFile1 $tmpFile2");
        system ("patc -p $patcdir/greek/gr2sgml.pat $tmpFile2 $tmpFile3");
        system ("patc -p $patcdir/cyrillic/cyt2sgml.pat $tmpFile3 $tmpFile4");
        system ("patc -p $patcdir/cyrillic/cy2sgml.pat $tmpFile4 $tmpFile5");
        system ("patc -p $patcdir/cyrillic/srt2sgml.pat $tmpFile5 $tmpFile6");
        system ("patc -p $patcdir/cyrillic/sr2sgml.pat $tmpFile6 $tmpFile7");

        $debug || unlink($tmpFile1);
        $debug || unlink($tmpFile2);
        $debug || unlink($tmpFile3);
        $debug || unlink($tmpFile4);
        $debug || unlink($tmpFile5);
        $debug || unlink($tmpFile6);
        $debug || unlink($currentFile);
        $currentFile = $tmpFile7;
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
