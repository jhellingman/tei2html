# tei2html.pl -- process a TEI file.

use strict;
use warnings;

use DateTime;
use File::Copy;
use File::stat;
use File::Temp qw(mktemp);
use File::Path qw(make_path remove_tree);
use FindBin qw($Bin);
use Getopt::Long;
use Cwd qw(abs_path);
use Math::Round;
use XML::XPath;

use SgmlSupport qw/utf2numericEntities translateEntity/;

#==============================================================================
# Configuration

my $home = $ENV{'TEI2HTML_HOME'};
my $saxonHome = $ENV{'SAXON_HOME'};
my $princeHome = $ENV{'PRINCE_HOME'};
my $mariadbHome = $ENV{'MARIADB_HOME'};

my $javaOptions = '-Xms2048m -Xmx4096m -Xss1024k ';

my $xsldir    = abs_path($home);                                            # location of xsl stylesheets
my $toolsdir  = $home . "/tools";                                           # location of tools
my $patcdir   = $toolsdir . "/patc/transcriptions";                         # location of patc transcription files.
my $catalog   = $home . "/dtd/CATALOG";                                     # location of SGML catalog (required for nsgmls and sx)

my $java      = "java $javaOptions";
my $prince    = $princeHome . "/Engine/bin/prince.exe";                     # see https://www.princexml.com/
my $saxon     = "$java -jar " . $saxonHome . "/saxon9he.jar ";              # see http://saxon.sourceforge.net/
my $epubcheck = "$java -jar " . $toolsdir . "/lib/epubcheck-4.0.2.jar ";    # see https://github.com/IDPF/epubcheck
my $schxslt   = "$java -jar " . $toolsdir . "/lib/schxslt-cli.jar";         # Schematron processor, see https://github.com/schxslt/schxslt

my $schematronFile = $home . "/schematron/tei-validation.sch";              # Schematron rules
my $schematronXslt = $home . "/schematron/validation-report.xsl";           # XSLT to convert the schematron report to HTML
my $namespaceXslt = $home . "/schematron/tei-namespace.xsl";                # XSLT to add TEI namespace to document

my $jeebies   = "C:\\Bin\\jeebies";                                         # see http://gutcheck.sourceforge.net/
my $gutcheck  = "gutcheck";
my $nsgmls    = "nsgmls";                                                   # see http://www.jclark.com/sp/ or http://openjade.sourceforge.net/doc/index.htm
my $sx        = "sx";                                                       # in the latter case, use onsgmls and osx instead of nsgmls and sx.
my $mariadb   = "\"C:\\Program Files\\MariaDB 10.10\\bin\\mariadb.exe\"";

my $LOG_LEVEL_ERROR = 1;
my $LOG_LEVEL_WARNING = 2;
my $LOG_LEVEL_INFO = 3;
my $LOG_LEVEL_TRACE = 4;

#==============================================================================
# Arguments and default values

my $atSize              = 1;
my $clean               = 0;
my $configurationFile   = "tei2html.config";
my $customOption        = "";
my $customStylesheet    = "custom.css"; # Deprecated: use CSS in a tagsDecl instead.
my $debug               = 0;
my $epubVersion         = "3.0.1";
my $explicitMakeText    = 0;
my $force               = 0;
my $kwicCaseSensitive   = "no";
my $kwicLanguages       = "";
my $kwicMixup           = "";
my $kwicSort            = "";
my $kwicVariants        = 1;
my $kwicWords           = "";

my $makeEpub            = 0;
my $makeHeatMap         = 0;
my $makeHtml            = 0;
my $makeHtml5           = 0;
my $makeKwic            = 0;
my $makeP5              = 0;
my $makePdf             = 0;
my $makePGTEI           = 0;
my $makeSQL             = 0;
my $makeText            = 0;
my $makeWordlist        = 0;
my $makeXML             = 0;
my $makeZip             = 0;

my $noTranscription     = 0;
my $noTranscriptionPopups = 0;
my $pageWidth           = 72;
my $profile             = 0;
my $runChecks           = 0;
my $showHelp            = 0;
my $trace               = 0;
my $useTidy             = 0;
my $useUnicode          = 0;
my $logLevel            = 3;    # 1: Error; 2: Warning; 3: Info; 4: Trace.

GetOptions(
    '5' => \$makeP5,
    'e' => \$makeEpub,
    'f' => \$force,
    'h' => \$makeHtml,
    'k' => \$makeKwic,
    'p' => \$makePdf,
    'q' => \$showHelp,
    'r' => \$makeWordlist,
    't' => \$explicitMakeText,
    'u' => \$useUnicode,
    'v' => \$runChecks,
    'x' => \$makeXML,
    'z' => \$makeZip,

    'C=s' => \$configurationFile,
    'c=s' => \$customStylesheet,
    'i=i' => \$atSize,
    's=s' => \$customOption,
    'w=i' => \$pageWidth,
    'l=i' => \$logLevel,

    'clean' => \$clean,
    'debug' => \$debug,
    'epubversion=s' => \$epubVersion,
    'heatmap' => \$makeHeatMap,
    'help' => \$showHelp,
    'html5' => \$makeHtml5,
    'kwiclang=s' => \$kwicLanguages,
    'kwicword=s' => \$kwicWords,
    'kwicwords=s' => \$kwicWords,
    'kwicsort=s' => \$kwicSort,
    'kwiccasesensitive=s' => \$kwicCaseSensitive,
    'kwicmixup=s' => \$kwicMixup,
    'kwicvariants=i' => \$kwicVariants,
    'notranscription' => \$noTranscription,
    'notranscriptions' => \$noTranscription,
    'notranscriptionpopups' => \$noTranscriptionPopups,
    'pagewidth=i' => \$pageWidth,
    'profile' => \$profile,
    'sql' => \$makeSQL,
    'tidy'=> \$useTidy,
    'trace' => \$trace
    );


my $inputFile = defined $ARGV[0] ? $ARGV[0] : '';


if ($showHelp == 1) {
    print "tei2html.pl -- process a TEI file to produce plain text, HTML, and ePub output\n\n";

    print "Usage: tei2html.pl [-options] <inputfile.tei>\n\n";

    print "Options:\n\n";

    print "    5         Convert XML output to P5 format.\n";
    print "    e         Produce ePub output.\n";
    print "    f         Force generation of output file, even if it is newer than input.\n";
    print "    h         Produce HTML output.\n";
    print "    k         Produce KWIC index.\n";
    print "    p         Produce PDF output.\n";
    print "    q         Print this help and exit.\n";
    print "    r         Produce word-usage report.\n";
    print "    t         Produce text output.\n";
    print "    u         Use Unicode output (in the text version).\n";
    print "    v         Run a number of checks, and produce a report.\n";
    print "    x         Produce XML output.\n";
    print "    z         Produce ZIP file for Project Gutenberg submission (IN DEVELOPMENT).\n\n";

    print "    C=<file>  Use the given file as configuration file (default: tei2html.config).\n";
    print "    c=<file>  Set the custom CSS stylesheet (default: custom.css).\n";
    print "    i=<int>   Select the image set in kept in a directory named 'images\@<int>' (default: 0)\n";
    print "              (0 = not applicable; 1 = nominal 144dpi/max 720px; 2 = nominal 288dpi/max 1440px).\n";
    print "    l=<int>   Set the log-level (1 = Error; 2 = Warning; 3 = Info (default); 4 = Trace)\n";
    print "    s=<value> Set the custom option (handed to XSLT processor).\n";
    print "    w=<int>   Set the page width (default: 72 characters).\n\n";

    print "    clean                           Clean intermediate files normally preserved.\n";
    print "    debug                           Debug mode.\n";
    print "    heatmap                         Generate a heatmap version.\n";
    print "    kwiclang=<languages>            Languages to be shown in KWIC, use ISO-639 codes, separated by spaces.\n";
    print "    kwicword=<words>                Words to be shown in KWIC, separate words by spaces.\n";
    print "    kwiccase=<yes/no>               Be case-sensitive in KWIC.\n";
    print "    kwicsort=<preceding/following>  Sort by (reverse) preceding or following context in KWIC.\n";
    print "    kwicmixup=<string>              Letters that can be mixed-up in KWIC, separate letters by spaces.\n";
    print "    kwicvariants=<number>           Report only words with at least this many variant spellings.\n";
    print "    notranscription                 Don't use transcription schemes.\n";
    print "    notranscriptionpopups           Don't use pop-ups to show Latin transcription of Greek and Cyrillic.\n";
    print "    pagewidth=<int>                 Set the page width (default: 72 characters).\n";
    print "    profile                         Profile mode.\n";
    print "    sql                             Generate metadata and wordlists in SQL format and attempt to store them.\n";
    print "    trace                           Use XSLT in trace mode.\n";

    exit(0);
}


# Dependencies between files:
#
# (Processed/)?images/*.(jpg|png) -> imageinfo.xml
# *(-[0-9].[0-9]+).tei + imageinfo.xml + tei2html.config + custom.css -> *.xml -> *-included.xml -> *-preprocessed.xml -> *.html, *.epub, readme.adoc, metadata.xml
# *(-[0-9].[0-9]+).tei -> *(-utf8).txt


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

# Files



# Metadata

my $pgNumber = "00000";
my $mainTitle = "";
my $shortTitle = "";
my $author = "";
my $language = "";
my $releaseDate = "";

processFiles();


sub processFiles {
    if ($inputFile eq '') {
        my ($directory) = '.';
        my @files = ();
        opendir(DIRECTORY, $directory) or fatal("Cannot open directory $directory!");
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

    info("=== Start! =================================================================");

    my ($basename, $version, $format) = analyzeFilename($filename);

    info("Process $filename");

    if ($version >= 1.0) {
        $makeText = 0;

        # Warn about processed files missing or being out-of-date.
        if (isNewer($filename, "Processed/$basename.xml")) {
            warning("Processed/$basename.xml is missing or out-of-date!");
            $makeXML = 1;
        }
        if (isNewer($filename, "Processed/$basename.html")) {
            warning("Processed/$basename.html is missing or out-of-date!");
            $makeHtml = 1;
        }
        if (isNewer($filename, "Processed/$basename.epub")) {
            warning("Processed/$basename.epub is missing or out-of-date!");
            $makeEpub = 1;
        }
    }
    if ($explicitMakeText == 1) {
        $makeText = 1;
    }

    extractMetadata($filename);
    if ($logLevel >= $LOG_LEVEL_INFO) {
        extractEntities($filename);
    }

    $atSize = determineAtSize();
    $atSize > 0 && prepareImages();
    makeQrCode($pgNumber);
    collectImageInfo();

    my $xmlFilename = $format eq 'tei' ? $basename . '.xml' : $filename;
    if ($format eq 'tei') {
        tei2xml($filename, $xmlFilename);
    }

    my $includedXmlFilename = "$basename-included.xml";
    includeXml($xmlFilename, $includedXmlFilename);

    my $preprocessedXmlFilename = "$basename-preprocessed.xml";
    preprocessXml($includedXmlFilename, $preprocessedXmlFilename);

    makeMetadata($preprocessedXmlFilename);
    makeReadme($preprocessedXmlFilename);

    $runChecks    && runChecks($basename,    $filename);
    $makeWordlist && makeWordlist($basename, $preprocessedXmlFilename);
    $makeHtml     && makeHtml($basename,     $preprocessedXmlFilename);
    $makeHtml5    && makeHtml5($basename,    $preprocessedXmlFilename);
    $makeEpub     && makeEpub($basename,     $preprocessedXmlFilename);
    $makePdf      && makePdf($basename,      $preprocessedXmlFilename);
    !$runChecks && $makeKwic && makeKwic($basename, $preprocessedXmlFilename);
    $makeText     && makeText($basename,     $filename);
    $makeP5       && makeP5($basename,       $preprocessedXmlFilename);
    $makeSQL      && makeSql($preprocessedXmlFilename);

    $makePGTEI && system ("$saxon $preprocessedXmlFilename $xsldir/tei2pgtei.xsl > $basename-pgtei.xml");

    $makeZip == 1 && $pgNumber > 0 && makeZip($basename);

    $clean && clean($basename, $version); 

    info("=== Done! ==================================================================");
}


sub analyzeFilename($) {
    my $filename = shift;

    if ($filename eq "" || !($filename =~ /\.tei$/ || $filename =~ /\.xml$/)) {
        fatal("File: '$filename' doesn't look like a TEI file.");
    }

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

    return ($basename, $version, $format);
}


sub clean($$) {
    my $basename = shift;
    my $version = shift;

    trace("Remove generated files");

    removeFile("$basename-included.xml");
    removeFile("$basename-preprocessed.xml");
    removeFile("$basename.gutcheck");
    removeFile("$basename-final.gutcheck");
    removeFile("$basename.jeebies");
    removeFile("$basename-epubcheck.err");

    # removeFile("$basename-words.html");
    removeFile("$basename-checks.html");
    removeFile("$basename-$version.tei.err");
    removeFile("issues.xml");
    removeFile("metadata.sql");
    removeFile("words.sql");
}


sub trace($) {
  my $message = shift;
  if ($logLevel >= $LOG_LEVEL_TRACE) {
      print $message . "\n";
  }
}

sub info($) {
    my $message = shift;
    if ($logLevel >= $LOG_LEVEL_INFO) {
        print $message . "\n";
    }
}

sub warning($) {
  my $message = shift;
  if ($logLevel >= $LOG_LEVEL_WARNING) {
      print "WARNING: $message\n";
  }
}

sub error($) {
  my $message = shift;
  if ($logLevel >= $LOG_LEVEL_ERROR) {
      print STDERR "ERROR: $message\n";
  }
}

sub fatal($) {
  my $message = shift;
  die "FATAL: $message\n";
}


sub removeFile($) {
    my $fileToRemove = shift;

    if (!-e $fileToRemove) {
        print "WARNING: attempt to remove non-existing file: $fileToRemove.\n";
        return;
    }

    my $fileAge = -M $fileToRemove;
    if ($fileAge > 0.0) {
        print "WARNING: attempt to remove file that pre-dates start time of script: $fileToRemove.\n";
        return;
    }

    !$debug || print "DEBUG: Removing file: $fileToRemove.\n";
    $debug || unlink($fileToRemove);
}


sub includeXml($$) {
    my $xmlFilename = shift;
    my $includedXmlFilename = shift;

    if ($force == 0 && isNewer($includedXmlFilename, $xmlFilename) && isNewer($includedXmlFilename, 'tei2html.config')) {
        trace("Skip conversion to included XML ($includedXmlFilename newer than $xmlFilename).");
        return;
    }

    trace("Include inclusions in TEI file...");
    system ("$saxon $xmlFilename $xsldir/include.xsl > $includedXmlFilename");
}


sub preprocessXml($$) {
    my $xmlFilename = shift;
    my $preprocessedXmlFilename = shift;

    if ($force == 0 && isNewer($preprocessedXmlFilename, $xmlFilename)) {
        trace("Skip conversion to preprocessed XML ($preprocessedXmlFilename newer than $xmlFilename).");
        return;
    }

    trace("Preprocess TEI file...");
    system ("$saxon $xmlFilename $xsldir/preprocess.xsl > $preprocessedXmlFilename");
}


sub makeP5($$) {
    my $basename = shift;
    my $xmlFilename = shift;
    my $p5XmlFilename = $basename . '-p5.xml';

    if ($force == 0 && isNewer($p5XmlFilename, $xmlFilename)) {
        trace("Skip conversion to TEI P5 XML ($p5XmlFilename newer than $xmlFilename).");
        return;
    }

    trace("Convert to TEI P5 (experimental)...");
    system ("$saxon $xmlFilename $xsldir/p4top5.xsl > $p5XmlFilename");
}


sub makeMetadata($) {
    my $xmlFilename = shift;

    if ($force == 0 && isNewer('metadata.xml', $xmlFilename)) {
        trace("Skip extract metadata because 'metadata.xml' is newer than '$xmlFilename'.");
        return;
    }

    trace("Extract metadata to metadata.xml...");
    system ("$saxon $xmlFilename $xsldir/tei2dc.xsl > metadata.xml");
}


sub makeSql($) {
    my $xmlFilename = shift;

    if ($force == 0 && isNewer('metadata.sql', $xmlFilename)) {
        trace("Skip create metadata in SQL because 'metadata.sql' is newer than '$xmlFilename'.");
        return;
    }

    trace("Extract metadata to metadata.sql...");
    system ("$saxon $xmlFilename $xsldir/tei2sql.xsl > metadata.sql");

    if ($pgNumber > 0 && -e "metadata.sql") {
        trace("Store metadata in words database");
        system ("$mariadb -D words < metadata.sql");
    }
}


sub makeReadmeMarkDown($) {
    my $xmlFilename = shift;

    if ($force == 0 && isNewer('README.md', $xmlFilename)) {
        trace("Skip create readme because 'README.md' is newer than '$xmlFilename'.");
        return;
    }

    trace("Extract metadata to README.md...");
    system ("$saxon $xmlFilename $xsldir/tei2readme.xsl > README.md");
}


sub makeReadme($) {
    my $xmlFilename = shift;

    if ($force == 0 && isNewer('README.adoc', $xmlFilename)) {
        trace("Skip create readme because 'README.adoc' is newer than '$xmlFilename'.");
        return;
    }

    trace("Extract metadata to README.adoc...");
    system ("$saxon $xmlFilename $xsldir/tei2adoc.xsl > README.adoc");
}


sub makeKwic($$) {
    my $basename = shift;
    my $xmlFilename = shift;
    my $kwicFilename = determineKwicFilename($basename);

    if ($force == 0 && isNewer($kwicFilename, $xmlFilename)) {
        trace("Skip creation of KWIC ($kwicFilename newer than $xmlFilename).");
        return;
    }

    my $saxonParameters = determineSaxonParameters();

    my $kwicLanguagesParameter = ($kwicLanguages eq '') ? '' : "select-language=\"$kwicLanguages\"";
    my $kwicKeywordParameter = ($kwicWords eq '') ? '' : "keyword=\"$kwicWords\"";
    my $kwicSortParameter = ($kwicSort eq '') ? '' : "sort-context=\"$kwicSort\"";
    my $kwicMixupParameter = ($kwicMixup eq '') ? '' : "mixup=\"$kwicMixup\"";
    my $kwicCaseSensitiveParameter = ($kwicCaseSensitive eq 'yes' or $kwicCaseSensitive eq 'true') ? 'case-sensitive=true' : '';
    my $kwicVariantsParameter = ($kwicVariants > 1) ? "min-variant-count=\"$kwicVariants\"" : '';

    trace("Generate a KWIC index (this may take some time)...");
    system ("$saxon $xmlFilename $xsldir/xml2kwic.xsl $saxonParameters $kwicLanguagesParameter $kwicSortParameter $kwicKeywordParameter $kwicMixupParameter $kwicCaseSensitiveParameter $kwicVariantsParameter > $kwicFilename");
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
    my $number = shift;

    if ($number > 0) {
        my $imageDir = '.';
        if (-d 'images') {
            $imageDir = 'images';
        } elsif (-d 'Processed/images') {
            $imageDir = 'Processed/images';
        }

        if ($atSize > 0) {
            makeQrCodeAtSize($number, $imageDir, $atSize * 4);
        }

        if (-d 'Processed/images@1') {
            makeQrCodeAtSize($number, 'Processed/images@1', 4);
        }

        if (-d 'Processed/images@2') {
            makeQrCodeAtSize($number, 'Processed/images@2', 8);
        }
    }
}


sub makeQrCodeAtSize($$) {
    my $number = shift;
    my $imageDir = shift;
    my $scale = shift;

    my $file = $imageDir . '/qr' . $number . '.png';

    if (not -e $file) {
        # Generate a QR code with a transparent background.
        system("qrcode -l '#0000' -s $scale -o $file https://www.gutenberg.org/ebooks/$number");

        # Optimize the generated QR code.
        my $newFile = "$imageDir/qrcode-optimized.png";
        system ("zopflipng.exe -m \"$file\" \"$newFile\"");
        if (-s "$file" > -s "$newFile") {
            move($newFile, $file);
        } else {
            removeFile($newFile);
        }
    }
}


sub makeHtml {
    my $basename = shift;
    my $xmlFile = shift;
    my $htmlFile = $basename . '.html';
    makeHtmlCommon($basename, $xmlFile, $htmlFile, "tei2html.xsl");
}


sub makeHtml5 {
    my $basename = shift;
    my $xmlFile = shift;
    my $htmlFile = $basename . '-h5.html';
    makeHtmlCommon($basename, $xmlFile, $htmlFile, "tei2html5.xsl");

    # Use tidy to convert the generated HTML to HTML5.
    # my $html5File = $basename . '-h5.html';
    # system("tidy --output-xml no --doctype html5 --wrap $pageWidth --quote-nbsp no --quiet yes \"$htmlFile\" > \"$html5File\"");
}


sub makeHtmlCommon {
    my $basename = shift;
    my $xmlFile = shift;
    my $htmlFile = shift;
    my $xsltFile = shift;

    if ($force == 0 && isNewer($htmlFile, $xmlFile)) {
        trace("Skip conversion to HTML ($htmlFile newer than $xmlFile).");
        return;
    }

    my $tmpFile = temporaryFile('html', '.html');
    my $saxonParameters = determineSaxonParameters();
    trace("Create HTML version...");
    system ("$saxon $xmlFile $xsldir/$xsltFile $saxonParameters basename=\"$basename\" > $tmpFile");
    system ("perl $toolsdir/wipeids.pl $tmpFile > $htmlFile");
    if ($useTidy != 0) {
        system ("tidy -m -wrap $pageWidth -f $basename-tidy.err $htmlFile");
    } else {
        my $tmpFile2 = temporaryFile('html', '.html');
        system ("perl $toolsdir/cleanHtml.pl $htmlFile > $tmpFile2");
        removeFile($htmlFile);
        system ("mv $tmpFile2 $htmlFile");
    }
    removeFile($tmpFile);
}


sub makePdf($$) {
    my $basename = shift;
    my $xmlFile = shift;
    my $pdfFile =  $basename . '.pdf';

    if ($force == 0 && isNewer($pdfFile, $xmlFile)) {
        trace("Skip conversion to PDF ($pdfFile newer than $xmlFile).");
        return;
    }

    my $tmpFile1 = temporaryFile('pdf', '.html');
    my $tmpFile2 = temporaryFile('pdf', '.html');
    my $saxonParameters = determineSaxonParameters();

    # Do the HTML transform again, but with an additional parameter to apply Prince specific rules in the XSLT transform.
    trace("Create PDF version...");
    system ("$saxon $xmlFile $xsldir/tei2html.xsl $saxonParameters optionPrinceMarkup=\"Yes\" > $tmpFile1");
    system ("perl $toolsdir/wipeids.pl $tmpFile1 > $tmpFile2");
    system ("sed \"s/^[ \t]*//g\" < $tmpFile2 > $basename-prince.html");
    system ("$prince $basename-prince.html $pdfFile");

    removeFile($tmpFile1);
    removeFile($tmpFile2);
}


sub makeEpub($$) {
    my $basename = shift;
    my $xmlFile = shift;
    my $epubFile = $basename . '.epub';

    if ($force == 0 && isNewer($epubFile, $xmlFile)) {
        trace("Skip conversion to ePub ($epubFile newer than $xmlFile).");
        return;
    }

    my $tmpFile = temporaryFile('epub', '.html');
    my $saxonParameters = determineSaxonParameters();
    trace("Create ePub version from $xmlFile...");
    system ('mkdir epub');
    copyImages('epub/images');
    # copyFormulas('epub/formulas'); # Not including formulas in ePub, as they are embedded as MathML (TODO: this is default, handle non-default situations)
    copyAudio('epub/audio');
    copyMusic('epub/music');
    copyFonts('epub/fonts');

    system ("$saxon $xmlFile $xsldir/tei2epub.xsl $saxonParameters basename=\"$basename\" epubversion=\"$epubVersion\" > $tmpFile");

    removeFile($epubFile);
    chdir 'epub';
    system ("zip -Xr9Dq ../$epubFile mimetype");
    system ("zip -Xr9Dq ../$epubFile * -x mimetype");
    chdir '..';

    system ("$epubcheck $epubFile 2> $basename-epubcheck.err");
    removeFile($tmpFile);
    $debug || remove_tree('epub')
}


sub makeText($$) {
    my $basename = shift;
    my $filename = shift;
    my $textFile = $basename . ($useUnicode == 1 ? '-utf8' : '') . '.txt';

    if ($force == 0 && isNewer($textFile, $filename)) {
        trace("Skip conversion to text file ($textFile newer than $filename).");
        return;
    }

    my $transcribedFile = $filename;
    if ($useUnicode == 1) {
        $transcribedFile = transcribe($filename, 1);
    }

    my $tmpFile1 = temporaryFile('txt', '.txt');
    my $tmpFile2 = temporaryFile('txt', '.txt');

    trace("Create text version from $transcribedFile...");
    system ("perl $toolsdir/extractNotes.pl $transcribedFile");
    system ("cat $transcribedFile.out $transcribedFile.notes > $tmpFile1");
    system ("perl $toolsdir/tei2txt.pl " . ($useUnicode == 1 ? '-u ' : '') . " -w $pageWidth $tmpFile1 > $tmpFile2");

    if ($useUnicode == 1) {
        # Use our own script to wrap lines, as fmt cannot deal with unicode text.
        # system ("perl -S wraplines.pl $tmpFile2 > $textFile");
        system ("perl -S wrapLinesUnicode.pl -w=$pageWidth $tmpFile2 > $textFile");
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

    if ($filename ne $transcribedFile) {
        removeFile($transcribedFile);
    }

    removeFile("$transcribedFile.out");
    removeFile("$transcribedFile.notes");
    removeFile($tmpFile1);
    removeFile($tmpFile2);

    # check for required manual interventions
    my $containsError = system ("grep -q \"\\[ERROR:\" $textFile");
    if ($containsError == 0) {
        warning("Please check $textFile for [ERROR: ...] messages.");
    }
    my $containsTable = system ("grep -q \"TABLE\" $textFile");
    if ($containsTable == 0) {
        warning("Please check $textFile for TABLEs.");
    }
    my $containsFigure = system ("grep -q \"FIGURE\" $textFile");
    if ($containsFigure == 0) {
        warning("Please check $textFile for FIGUREs.");
    }
}


sub makeWordlist($$) {
    my $basename = shift;
    my $xmlFile = shift;
    my $wordlistFile = $basename . '-words.html';

    if ($force == 0 && isNewer($wordlistFile, $xmlFile)) {
        trace("Skip creation of word list ($wordlistFile newer than $xmlFile).");
        return;
    }

    my $tmpFile = temporaryFile('report', '.html');
    my $options = $debug ? ' -v ' : '';
    $options .= $makeHeatMap ? ' -m ' : '';
    $options .= $makeSQL ? ' -s ' : '';

    trace("Report on word usage...");
    system ("perl $toolsdir/ucwords.pl $options $xmlFile > $tmpFile");
    system ("perl $toolsdir/ent2ucs.pl $tmpFile > $wordlistFile");

    removeFile($tmpFile);

    if ($pgNumber > 0 && -e "words.sql") {
        trace("Store word usage in words database");
        system ("$mariadb -D words < words.sql");
    }

    # Create a text heat map.
    if (-f 'heatmap.xml') {
        trace("Create text heat map...");
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
        trace("Add custom stylesheet: $customStylesheet ...");
        $cssFileParam = "customCssFile=\"file:/$pwd/$customStylesheet\"";
    }

    my $configurationFileParam = '';
    if (-f $configurationFile) {
        trace("Add custom configuration: $configurationFile ...");
        $configurationFileParam = "configurationFile=\"file:/$pwd/$configurationFile\"";
    }

    my $opfManifestFileParam = '';
    if (-f 'opf-manifest.xml') {
        trace("Add additional elements for the OPF manifest...");
        $opfManifestFileParam = "opfManifestFile=\"file:/$pwd/opf-manifest.xml\"";
    }

    my $opfMetadataFileParam = '';
    if (-f 'opf-metadata.xml') {
        trace("Add additional items to the OPF metadata...");
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

    trace("Prepare a zip file for (re-)submission to Project Gutenberg");

    if (!-f $pgNumber) {
        mkdir $pgNumber;
    }

    if (!-d $pgNumber) {
        error("Failed to create directory $pgNumber, will not make zip file.");
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
    open(PGFILE, $file) || fatal("Could not open input file $file to extract metadata.");

    # Skip upto start of actual text.
    while (<PGFILE>) {
        my $line = $_;
        if ($line =~ /<TEI.2 lang=\"?([a-z][a-z]).*?\"?>/) {
            $language = $1;
        }
        if ($line =~ /<idno type=\"?PGnum\"?>([0-9]+)<\/idno>/) {
            $pgNumber = $1;
        }
        if ($line =~ /<author\b.*?>(.*?)<\/author>/) {
            if ($author eq "") {
                $author = $1;
            } else {
                $author .= ", " . $1;
            }
        }
        if ($line =~ /<date\b.*?>(.*?)<\/date>/) {
            $releaseDate = $1;
        }
        if ($line =~ /<title(?: nfc=\"?[0-9]+\"?)?>(.*?)<\/title>/) {
            $mainTitle = $1;
        }
        if ($line =~ /<title type=\"?short\"?(?: nfc=\"?[0-9]+\"?)?>(.*?)<\/title>/) {
            $shortTitle = $1;
        }
        if ($line =~ /<title type=\"?pgshort\"?>(.*?)<\/title>/) {
            $shortTitle = $1;
        }

        # All relevant metadata should be in or before the publicationStmt.
        if ($line =~ /<\/publicationStmt>/) {
            last;
        }
    }
    close(PGFILE);

    if (length($mainTitle) > 26 && $shortTitle eq '') {
        warning("Long title longer than 26 characters, but no short title given");
    }

    if (length($mainTitle) <= 26 && $shortTitle eq '') {
        $shortTitle = $mainTitle;
    }

    if (length($shortTitle) > 26 ) {
        warning("Short title too long (should be less than 27 characters)");
    }

    info("----------------------------------------------------------------------------");
    info("Author:       $author");
    info("Title:        $mainTitle");
    info("Short title:  $shortTitle");
    info("Language:     $language");
    info("Ebook #:      $pgNumber");
    info("Release Date: $releaseDate");
    info("----------------------------------------------------------------------------");
}


#
# extractEntities -- Extract a list of entities used.
#
sub extractEntities($) {
    my $file = shift;
    my %entityHash = ();
    my $entityPattern = "\&([a-z0-9._-]+);";

    open(PGFILE, $file) || fatal("Could not open input file $file");

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
        my $maxEntityLength = 1 + length longestString(@entityList);
        my @translationList = map { utf2numericEntities(translateEntity($_)) } @entityList;
        my $maxTranslationLength = 1 + length longestString(@translationList);

        foreach my $entity (@entityList) {
            my $translation = utf2numericEntities(translateEntity($entity));
            my $paddedEntity = sprintf "%s%-*s", $entity, $maxEntityLength - length $entity, ' ';
            my $paddedTranslation = sprintf "\"%s\"%-*s", $translation, $maxTranslationLength - length $translation, ' ';
            my $count = $entityHash{$entity};
            my $paddedCount = sprintf "%-*s %s", 6 - length $count, ' ', $count;
            print "    <!ENTITY $paddedEntity CDATA $paddedTranslation -- $paddedCount -->\n";
        }
        print "\n]>\n\n";
    }
}


sub longestString {
    my $max = -1;
    my $max_ref;
    for (@_) {
        if (length > $max) {
            $max = length;
            $max_ref = \$_;
        }
    }
    $$max_ref;
}


#
# runChecks -- run various checks on the file. To help error reporting, line/column information is
# added to the TEI file first.
#
sub runChecks($) {
    my $basename = shift;
    my $filename = shift;
   
    $filename =~ /^(.*)\.(xml|tei)$/;
    my $format = $2;
    my $checkFilename = $basename . '-checks.html';

    if ($force == 0 && isNewer($checkFilename, $filename)) {
        trace("Skip run checks because '$checkFilename' is newer than '$filename'.");
        return;
    }
    trace("Run checks on $filename.");

    my $intraFile = convertIntraNotation($filename);

    my $transcribedFile = transcribe($intraFile, $noTranscriptionPopups);

    my $positionInfoFilename = $basename . '-pos.' . $format;

    trace("Adding pos attributes to $inputFile");
    system ("perl $toolsdir/addPositionInfo.pl \"$transcribedFile\" > \"$positionInfoFilename\"");

    if ($format eq 'tei') {
        my $tmpFile = temporaryFile('checks', '.tei');

        # Hide a number of entities for the checks, so matching pairs of punctuation can be
        # verified. The trick used is that unmatched parentheses and brackets can be represented
        # by their SGML entities, and those entities will be mapped to alternative characters
        # for the test only. Similarly, the &apos; entity is mapped to &mlapos;, instead of &rsquo;.
        system ("perl $toolsdir/precheck.pl \"$positionInfoFilename\" > \"$tmpFile\"");
        removeFile($positionInfoFilename);

        tei2xml($tmpFile, $basename . '-pos.xml');
        $positionInfoFilename = $basename . '-pos.xml';
        removeFile($tmpFile);
        removeFile($tmpFile . '.err');
    }

    my $xmlFilename = temporaryFile('checks', '.xml');
    system ("$saxon \"$positionInfoFilename\" $xsldir/preprocess.xsl > $xmlFilename");

    system ("$saxon \"$xmlFilename\" $xsldir/checks.xsl " . determineSaxonParameters() . " > \"$checkFilename\"");

    runSchematron($basename, $xmlFilename);

    $makeKwic && makeKwic($basename, $xmlFilename);

    if ($filename ne $intraFile) {
        removeFile($intraFile);
    }
    if ($filename ne $transcribedFile) {
        removeFile($transcribedFile);
    }
    removeFile($positionInfoFilename);
    removeFile($xmlFilename);
}


sub runSchematron($) {
    my $basename = shift;
    my $xmlFilename = shift;

    ## The schematron wants the document to be in the TEI namespace: "http://www.tei-c.org/ns/1.0"
    my $tmpFile = "$basename-ns.xml";
    system("$saxon -s:$xmlFilename -xsl:$namespaceXslt -o:$tmpFile");

    trace("Run schematron checks: $schxslt -s $schematronFile -d $xmlFilename -o $xmlFilename-report.xml");
    my $result = system("$schxslt -s $schematronFile -d $basename-ns.xml -o $xmlFilename-report.xml");

    if ($result != 0) {
        warning("Schematron validation failed!");
    }

    trace("Transform schematron result to HTML: $saxon -s:$xmlFilename-report.xml -xsl:$schematronXslt -o:$basename-report.html");
    my $transform_result = system("$saxon -s:$xmlFilename-report.xml -xsl:$schematronXslt -o:$basename-schematron-report.html");

    removeFile($tmpFile);
    removeFile("$xmlFilename-report.xml");
}


#
# isNewer -- determine whether the derived file exists, is not empty, and is newer than the source file
#
sub isNewer($$) {
    my $derivedFile = shift;
    my $sourceFile = shift;

    # Don't care if source file does not exist (e.g. for a tei2html.config file).
    if (!-e $sourceFile || -s $sourceFile == 0) {
        return 1;
    }

    if (!-e $derivedFile || -s $derivedFile == 0) {
        return 0;
    }

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
sub collectImageInfo() {
    if (-d 'images') {
        trace("Collect image dimensions from 'images'...");
        system ("perl $toolsdir/imageinfo.pl images > imageinfo.xml");
    } elsif (-d 'Processed/images') {
        trace("Collect image dimensions from 'Processed/images'...");
        system ("perl $toolsdir/imageinfo.pl -d=1 Processed/images > imageinfo.xml");
    }

    if (-d 'music') {
        trace("Collect information from 'music'...");
        system ("perl $toolsdir/imageinfo.pl music > musicinfo.xml");
    } elsif (-d 'Processed/music') {
        trace("Collect information from 'Processed/music'...");
        system ("perl $toolsdir/imageinfo.pl -d=1 Processed/music > musicinfo.xml");
    }
}


#
# determineAtSize -- read the scale factor from tei2html.config.
#
sub determineAtSize() {
    if (!-e 'tei2html.config') {
        return 1;
    }

    my $scale = 1;

    # Use eval, so we can recover from fatal parse errors in XML:XPath.
    eval {
        my $xpath = XML::XPath->new(filename => 'tei2html.config');
        my $scaleNode = $xpath->find('/tei2html.config/images.scale');
        $scale = $scaleNode->string_value();
        $xpath->cleanup();
        1;
    } or do {
        error("Problem parsing tei2html.config.");
    };
    if ($scale eq '') {
        $scale = 1;
    }

    return round(1.0/$scale);
}


#
# prepareImages -- copy images in the selected resolution ('@-size') to the main images directory
#
sub prepareImages() {
    my $source = 'Processed/images@' . $atSize;
    my $destination = 'Processed/images';

    if (!-d $source) {
        warning("Source directory $source does not exist");
        return;
    }

    if (-d $destination) {
        # Destination exists, prevent copying into it.
        warning("Destination '$destination' exists; will not copy images again");
        return;
    }

    system ('cp -r -u ' . $source . ' ' . $destination);
}


#
# copyImages -- copy image files for use in ePub.
#
sub copyImages($) {
    my $destination = shift;

    if (-d $destination) {
        # Destination exists, prevent copying into it.
        warning("Destination exists; will not copy images again");
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

sub copyMusic($) {
    my $destination = shift;

    if (-d 'music') {
        system ('cp -r -u music ' . $destination);
    } elsif (-d 'Processed/music') {
        system ('cp -r -u Processed/music ' . $destination);
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
# tei2xml -- convert a file from SGML TEI to XML, also convert various notations if needed.
#
sub tei2xml($$) {
    my $sgmlFile = shift;
    my $xmlFile = shift;

    if ($force == 0 && isNewer($xmlFile, $sgmlFile)) {
        trace("Skip conversion to XML ('$xmlFile' newer than '$sgmlFile').");
        return;
    }

    trace("Convert SGML file '$sgmlFile' to XML file '$xmlFile'.");

    # Convert Latin-1 characters to entities
    my $tmpFile0 = temporaryFile('entities', '.tei');
    trace("Convert Latin-1 characters to entities...");
    system ("patc -p $toolsdir/patc/win2sgml.pat $sgmlFile $tmpFile0");

    my $intraFile = convertIntraNotation($tmpFile0);

    my $transcribedFile = transcribe($intraFile, $noTranscriptionPopups);

    trace("Check SGML...");
    my $nsgmlresult = system ("$nsgmls -c \"$catalog\" -wall -E100000 -g -f $sgmlFile.raw.err $transcribedFile > $sgmlFile.nsgml");
    if ($nsgmlresult != 0) {
        warning("NSGML found validation errors in $sgmlFile.");
    }
    removeFile("$sgmlFile.nsgml");
    system ("perl $toolsdir/filter-nsgmls-errors.pl $sgmlFile.raw.err > $sgmlFile.err");
    system ("cat $sgmlFile.err");
    removeFile("$sgmlFile.raw.err");

    my $tmpFile1 = temporaryFile('hide-entities', '.tei');
    my $tmpFile2 = temporaryFile('sx', '.xml');
    my $tmpFile3 = temporaryFile('restore-entities', '.xml');
    my $tmpFile4 = temporaryFile('ucs', '.xml');

    trace("Convert SGML to XML...");

    # hide entities for parser
    system ("sed \"s/\\&/|xxxx|/g\" < $transcribedFile > $tmpFile1");
    system ("$sx -c \"$catalog\" -E100000 -xlower -xcomment -xempty -xndata -f $tmpFile1.sx.err $tmpFile1 > $tmpFile2");
    removeFile("$tmpFile1.sx.err");

    # apply proper case to tags.
    system ("$saxon -versionmsg:off $tmpFile2 $xsldir/tei2tei.xsl > $tmpFile3");

    # restore entities
    system ("sed \"s/|xxxx|/\\&/g\" < $tmpFile3 > $tmpFile4");
    system ("perl $toolsdir/ent2ucs.pl $tmpFile4 > $xmlFile");

    removeFile($tmpFile4);
    removeFile($tmpFile3);
    removeFile($tmpFile2);
    removeFile($tmpFile1);
    removeFile($tmpFile0);
    removeFile($intraFile);
    removeFile($transcribedFile);
}

#
# convertIntraNotation -- Convert <INTRA> notation.
#
sub convertIntraNotation() {
    my $filename = shift;

    my $containsIntralinear = system ("grep -q \"<INTRA\" $filename");
    if ($containsIntralinear == 0 && $noTranscription == 0) {
        my $tmpFile = temporaryFile('intra', '.tei');
        trace("Convert <INTRA> notation to standard TEI <ab>-elements...");
        system ("perl $toolsdir/intralinear.pl $filename > $tmpFile");
        $filename = $tmpFile;
    }
    return $filename;
}

#
# transcribe -- transcribe foreign scripts in special notations to entities.
#
sub transcribe($$) {
    my $currentFile = shift;
    my $noPopups = shift;

    if ($noTranscription == 0) {
        if ($noPopups == 0) {
            $currentFile = addTranscriptions($currentFile);
        } else {
            $currentFile = transcribeNotation($currentFile, '<EL>',  'Greek',                       "$patcdir/greek/gr2sgml.pat");
            $currentFile = transcribeNotation($currentFile, '<GR>',  'Greek (classical)',           "$patcdir/greek/gr2sgml.pat");
            $currentFile = transcribeNotation($currentFile, '<ALS>', 'Tosk (Southern Albanian)',    "$patcdir/greek/gr2sgml.pat");
            $currentFile = transcribeNotation($currentFile, '<CY>',  'Cyrillic',                    "$patcdir/cyrillic/cy2sgml.pat");
            $currentFile = transcribeNotation($currentFile, '<RU>',  'Russian',                     "$patcdir/cyrillic/cy2sgml.pat");
            $currentFile = transcribeNotation($currentFile, '<UK>',  'Ukrainian',                   "$patcdir/cyrillic/cy2sgml.pat");
            $currentFile = transcribeNotation($currentFile, '<SR>',  'Serbian',                     "$patcdir/cyrillic/sr2sgml.pat");
        }

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
        $currentFile = transcribeNotation($currentFile, '<HG>',  'Hieroglyphs',           "$patcdir/hieroglyphs/hg2sgml.pat");

        my $containsTibetan = system ("grep -q -e \"<BO>\" $currentFile");
        if ($containsTibetan == 0) {
            $currentFile = convertWylie($currentFile);
        }
    }
    return $currentFile;
}


sub convertWylie() {
    my $currentFile = shift;
    my $tmpFile = temporaryFile('wylie', '.xml');

    trace("Convert Tibetan transcription...");
    system ("perl $toolsdir/convertWylie.pl $currentFile > $tmpFile");

    removeFile($currentFile);
    return $tmpFile;
}


#
# addTranscriptions -- add a transcription of Greek or Cyrillic script in choice elements.
#
sub addTranscriptions($) {
    my $currentFile = shift;

    # Check for presence of Greek or Cyrillic
    my $containsGreek = system ("grep -q -e \"<EL>\\|<GR>\\|<ALS>\\|<CY>\\|<RU>\\|<UK>\\|<RUX>\\|<SR>\" $currentFile");
    if ($containsGreek == 0) {
        my $tmpFile1 = temporaryFile('transcribe', '.xml');
        my $tmpFile2 = temporaryFile('transcribe', '.xml');
        my $tmpFile3 = temporaryFile('transcribe', '.xml');
        my $tmpFile4 = temporaryFile('transcribe', '.xml');
        my $tmpFile5 = temporaryFile('transcribe', '.xml');
        my $tmpFile6 = temporaryFile('transcribe', '.xml');
        my $tmpFile7 = temporaryFile('transcribe', '.xml');

        trace("Add a transcription of Greek or Cyrillic script in choice elements...");
        system ("perl $toolsdir/addTrans.pl -x $currentFile > $tmpFile1");
        system ("patc -p $patcdir/greek/grt2sgml.pat $tmpFile1 $tmpFile2");
        system ("patc -p $patcdir/greek/gr2sgml.pat $tmpFile2 $tmpFile3");
        system ("patc -p $patcdir/cyrillic/cyt2sgml.pat $tmpFile3 $tmpFile4");
        system ("patc -p $patcdir/cyrillic/cy2sgml.pat $tmpFile4 $tmpFile5");
        system ("patc -p $patcdir/cyrillic/srt2sgml.pat $tmpFile5 $tmpFile6");
        system ("patc -p $patcdir/cyrillic/sr2sgml.pat $tmpFile6 $tmpFile7");

        removeFile($tmpFile1);
        removeFile($tmpFile2);
        removeFile($tmpFile3);
        removeFile($tmpFile4);
        removeFile($tmpFile5);
        removeFile($tmpFile6);
        removeFile($currentFile);
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

        trace("Convert $name transcription...");
        system ("patc -p $patternFile $currentFile $tmpFile");

        removeFile($currentFile);
        $currentFile = $tmpFile;
    }
    return $currentFile;
}
