# ucwords.pl -- Unicode based perl script for collecting words from an XML file.

use strict;
use warnings;

use utf8;
binmode(STDOUT, ":utf8");
use open ':utf8';

require Encode;
use Unicode::Normalize;
use Getopt::Long;
use Roman;      # Roman.pm version 1.1 by OZAWA Sakuro <ozawa@aisoft.co.jp>

use SgmlSupport qw/getAttrVal sgml2utf/;
use LanguageNames qw/getLanguage/;

#####################################################################
#
# Main
#


# Global settings
my $verbose = 0;        # Set to 1 to verbosely report what is happening.
my $makeHeatMap = 0;    # Set to 1 to generate a heat-map document.
my $retrograd = 0;      # Set to 1 to generate a retrograd word list.
my $ignoreLanguage = 0; # Set to 1 to ignore language attributes.
my $xmlReport = 0;      # Set to 1 to generate a report in xml.
my $csvReport = 0;      # Set to 1 to generate a report in plain text (CSV).
my $idBook = 0;
my $docTitle = "Title";
my $docAuthor = "Author";

GetOptions(
    'v' => \$verbose,
    'x' => \$xmlReport,
    'r' => \$retrograd,
    'i' => \$ignoreLanguage,
    'c' => \$csvReport,
    'm' => \$makeHeatMap);

if (!defined $ARGV[0]) {
    die "usage: ucwords.pl -imrvx <filename>";
}

my $inputFile = $ARGV[0];

# Constants
my $tagPattern = "<(.*?)>";

# Hashes to collect information
my %wordHash = ();
my %pairHash = ();
my %numberHash = ();
my %nonWordHash = ();
my %badWordsHash = ();
my %goodWordsHash = ();
my %scannoHash = ();
my %charHash = ();
my %compositeCharHash = ();
my %langHash = ();
my %tagHash = ();
my %rendHash = ();
my %dictHash = ();
my %countCountHash = ();

my @lines = ();
my @pageList = ();
my @wordList = ();

my @stackTag = ();
my @stackLang = ();

# Counters
my $headerWordCount = 0;
my $headerNumberCount = 0;
my $headerCharCount = 0;
my $headerNonWordCount = 0;

my $pageCount = 0;
my $wordCount = 0;
my $numberCount = 0;
my $nonWordCount = 0;
my $charCount = 0;
my $langCount = 0;
my $langStackSize = 0;

my $grandTotalWords = 0;
my $grandTotalUniqWords = 0;
my $grandTotalNonWords = 0;
my $grandTotalCharacters = 0;
my $grandTotalCompositeCharacters = 0;
my $grandTotalTags = 0;

my $uniqWords = 0;
my $totalWords = 0;
my $unknownTotalWords = 0;
my $unknownUniqWords = 0;


main();


sub main {
    # loadScannoFile("en");
    if (-d $inputFile) {
        listRecursively($inputFile);
    } else {
        collectWords($inputFile);
    }
    loadGoodBadWords();

    report();
    if ($xmlReport == 1) {
        reportXML();
    }
    if ($csvReport == 1) {
        reportCSV();
    }
    if ($makeHeatMap == 1) {
        makeHeatMap();
    }
}


sub listRecursively {
    my ($directory) = @_;
    my @files = (  );

    if (-f $directory) {
        handleFile($directory);
        return;
    }

    unless (opendir(DIRECTORY, $directory)) {
        logError("Cannot open directory $directory!");
        exit;
    }
    @files = grep (!/^\.\.?$/, readdir(DIRECTORY));
    closedir(DIRECTORY);

    foreach my $file (@files) {
        my $path = $directory . '/' . $file;
        if (-f $path) {
            handleFile($path);
        } elsif (-d $path) {
            listRecursively($path);
        }
    }
}


sub handleFile {
    my ($file) = @_;
    if ($file =~ m/^(.*)\.(xml)$/) {
        print STDERR "Reading words from file: $file\n";
        collectWords($file);
    }
}


####################################################
#
# Collect words from the text.
#


#
# collectWords
#
sub collectWords {
    my $inputFile = shift;
    loadDocument($inputFile);

    foreach my $line (@lines) {
        my $remainder = $line;

        if ($remainder =~ /<title\b.*?>(.*?)<\/title>/) {
            $docTitle = sgml2utf($1);
        }
        if ($remainder =~ /<author\b.*?>(.*?)<\/author>/) {
            $docAuthor = sgml2utf($1);
        }
        if ($remainder =~ /<idno type=\"PGnum\">([0-9]+)<\/idno>/) {
            $idBook = $1;
        }
        if ($remainder =~ /<\/teiHeader>/) {
            $headerWordCount = $wordCount;
            $headerNumberCount = $numberCount;
            $headerCharCount = $charCount;
            $headerNonWordCount = $nonWordCount;
        }

        while ($remainder =~ /$tagPattern/) {
            my $fragment = $`;
            my $tag = $1;
            $remainder = $';
            handleFragment($fragment);
            handleTag($tag, $remainder);
        }
        handleFragment($remainder);
    }
}


#
# loadDocument: load a document into memory.
#
sub loadDocument {
    my $inputFile = shift;
    open (INPUTFILE, $inputFile) || die("ERROR: Could not open input file $inputFile");
    while (<INPUTFILE>) {
        push (@lines, $_);
    }
    close (INPUTFILE);
}


#
# handleTag: push/pop an XML tag on the tag-stack.
#
sub handleTag($$) {
    my $tag = shift;
    my $remainder = shift;

    # end tag or start tag?
    if ($tag =~ /^[!?]/) {
        # Comment or processing instruction, don't care.
    } elsif ($tag =~ /^\/([a-zA-Z0-9_.:-]+)/) {
        my $element = $1;
        popLang($element, $remainder);
        $tagHash{$element}++;
    } elsif ($tag =~ /\/$/) {
        # Empty element
        $tag =~ /^([a-zA-Z0-9_.:-]+)/;
        my $element = $1;
        $tagHash{$element}++;
        if ($element eq 'pb') {
            my $n = getAttrVal('n', $tag);
            push @pageList, $n;
            $pageCount++;
        }
        my $rend = getAttrVal('rend', $tag);
        if ($rend ne '') {
            $rendHash{$rend}++;
        }
    } else {
        $tag =~ /^([a-zA-Z0-9_.:-]+)/;
        my $element = $1;
        my $lang = getAttrVal('lang', $tag);
        if ($lang ne '') {
            pushLang($element, $lang);
        } else {
            pushLang($element, getLang());
        }
        my $rend = getAttrVal('rend', $tag);
        if ($rend ne '') {
            $rendHash{$rend}++;
        }
    }
}


#
# handleFragment: split a text fragment into words and insert them
# in the wordlist.
#
sub handleFragment($) {
    my $fragment = shift;
    $fragment = NFC(sgml2utf($fragment));

    my $lang = getLang();

    my $prevWord = '';

    # NOTE: we don't use \w and \W here, since it gives some unexpected results.
    # Character codes: 2032 = prime; 00AD = soft hyphen.
    my @words = split(/([^\x{2032}\x{00AD}`\pL\pN\pM*-]+)/, $fragment);
    foreach my $word (@words) {
        if ($word ne '') {
            if ($word =~ /^[^\x{2032}\x{00AD}`\pL\pN\pM*-]+$/) {
                countNonWord($word);
                # reset previous word if not separated by more than just some space.
                if ($word !~ /^[\pZ]+$/) {
                    $prevWord = '';
                }
            } elsif ($word =~ /^[0-9]+$/) {
                countNumber($word);
                $prevWord = '';
            } else {
                countWord($word, $lang);
                if ($prevWord ne '') {
                    countPair($prevWord, $word, $lang);
                }
                $prevWord = $word;
            }
        }
    }

    my @chars = split(//, $fragment);
    foreach my $char (@chars) {
        countChar($char);
    }

    my @compositeChars = split(/(\pL\pM*)/, $fragment);
    foreach my $compositeChar (@compositeChars) {
        if ($compositeChar =~ /^\pL\pM*$/) {
            countCompositeChar($compositeChar)
        }
    }
}


#
# countPair()
#
sub countPair($$$) {
    my $firstWord = shift;
    my $secondWord = shift;
    my $language = shift;

    $pairHash{$language}{"$firstWord!$secondWord"}++;
    # print STDERR "PAIR: $firstWord $secondWord\n";
}


#
# countWord()
#
sub countWord($$) {
    my $word = shift;
    my $lang = shift;

    $wordHash{$lang}{$word}++;
    $wordCount++;
}

sub countNumber($) {
    my $number = shift;
    $numberHash{$number}++;
    $numberCount++;
}

sub countNonWord($) {
    my $nonWord = shift;
    $nonWordHash{$nonWord}++;
    $nonWordCount++;
}

sub countChar($) {
    my $char = shift;
    $charHash{$char}++;
    $charCount++;
}

sub countCompositeChar($) {
    my $compositeChar = shift;
    if (length($compositeChar) > 1) {
        $compositeCharHash{$compositeChar}++;
        $compositeChar++;
    }
}


####################################################
#
# Report the collected statistics.
#

sub report() {
    printReportHeader();
    sortWords();
    reportNumbers();
    reportNonWords();
    reportChars();
    reportCompositeChars();
    reportTags();
    reportRend();
    reportPages();

    reportStatistics();

    print "\n</body></html>";
}


sub reportXML {
    open (USAGEFILE, ">usage.xml") || die("Could not create output file 'usage.xml'");

    print USAGEFILE "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
    # print USAGEFILE "<?xml-stylesheet type=\"text/xsl\" href=\"http://www.gutenberg.ph/xslt/usage.xsl\"?>";
    print USAGEFILE "<usage" . ($idBook != 0 ? " idBook='$idBook'" : "") .  ">\n";

    reportWordsXML();
    reportNonWordsXML();
    reportCharsXML();
    reportTagsXML();
    reportRendXML();

    print USAGEFILE "</usage>\n";
}

sub reportCSV {
    open (CSVFILE, ">words.csv") || die("Could not create output file 'words.csv'");
    reportWordsCSV();
    close (CSVFILE);
}


#
# sortWords
#
sub sortWords() {
    my @languageList = sort keys %wordHash;
    foreach my $language (@languageList) {
        $langCount++;
        sortLanguageWords($language);
    }
}


#
# reportWordsXML
#
sub reportWordsXML() {
    my @languageList = keys %wordHash;
    foreach my $language (@languageList) {
        reportLanguageWordsXML($language);
    }
}

#
# reportWordsCSV
#
sub reportWordsCSV() {
    my @languageList = keys %wordHash;
    foreach my $language (@languageList) {
        reportLanguageWordsCSV($language);
    }
}


#
# sortLanguageWords
#
sub sortLanguageWords($) {
    my $language = shift;
    @wordList = keys %{$wordHash{$language}};

    foreach my $word (@wordList) {
        my $key = NormalizeForLanguage($word, $language);
        if ($retrograd == 1) {
            $key = reverse($key);
        }
        $word = "$key!$word";
    }
    @wordList = sort @wordList;
    reportWords($language);
    reportLanguagePairs($language);
}


#
# reportLanguageWordsXML
#
sub reportLanguageWordsXML($) {
    my $language = shift;
    my @wordList = keys %{$wordHash{$language}};

    foreach my $word (@wordList) {
        my $key = NormalizeForLanguage($word, $language);
        $word = "$key!$word";
    }
    @wordList = sort @wordList;

    print USAGEFILE "\n<words xml:lang=\"$language\">\n";

    loadDictionary($language);

    my $previousKey = '';
    foreach my $item (@wordList) {
        my ($key, $word) = split(/!/, $item, 2);

        if ($key ne $previousKey) {
            if ($previousKey ne '') {
                print USAGEFILE "</wordGroup>\n";
            }
            print USAGEFILE "<wordGroup>";
        }

        my $count = $wordHash{$language}{$word};
        my $known = isKnownWord($word, $language);

        print USAGEFILE "<word count=\"$count\" known=\"$known\">$word</word>";

        $previousKey = $key;
    }

    if ($previousKey ne '') {
        print USAGEFILE "</wordGroup>\n";
    }

    print USAGEFILE "</words>\n";
}


#
# reportLanguageWordsCSV
#
sub reportLanguageWordsCSV($) {
    my $language = shift;
    my @wordList = keys %{$wordHash{$language}};

    foreach my $word (@wordList) {
        my $key = NormalizeForLanguage($word, $language);
        $word = "$key!$word";
    }
    @wordList = sort @wordList;

    foreach my $item (@wordList) {
        my ($key, $word) = split(/!/, $item, 2);
        my $count = $wordHash{$language}{$word};
        print CSVFILE "$key\t$word\t$language\t$count\n";
    }
}


#
# reportPairs
#
sub reportPairs() {
    my @languageList = keys %pairHash;
    foreach my $language (@languageList) {
        reportLanguagePairs($language);
    }
}


#
# reportLanguagePairs
#
sub reportLanguagePairs($) {
    my $language = shift;
    my @pairList = keys %{$pairHash{$language}};
    @pairList = sort @pairList;

    print "\n\n\n<h3>Most Common Word Pairs in " . getLanguage(lc($language)) . "</h3>\n";

    my $max = 0;
    foreach my $pair (sort {$pairHash{$language}{$b} <=> $pairHash{$language}{$a} } @pairList) {
        my $count = $pairHash{$language}{$pair};
        if ($count < 10) {
            last;
        }

        my ($first, $second) = split(/!/, $pair, 2);

        # print STDERR "PAIR: $count $pair\n";
        print "\n<p>$first $second <span class=cnt>$count</span>";
        $max++;
        if ($max > 100) {
            last;
        }
    }
}


#
# printReportHeader
#
sub printReportHeader() {
    print "<html lang=\"en\">";
    print "\n<head>";
    print "\n<title>Word Usage Report for $docTitle ($inputFile)</title>";
    print "\n<style>\n";
    print "body { margin-left: 30px; }\n";
    if ($retrograd == 1) {
        print "body { text-align: right; }\n";
    }
    print "p { margin: 0px; }\n";
    print ".cnt { color: gray; font-size: smaller; }\n";
    print ".err { color: red; font-weight: bold; }\n";
    print ".comp { color: green; font-weight: bold; }\n";
    print ".comp3 { color: green; }\n";
    print ".unk { color: blue; font-weight: bold; }\n";
    print ".unk10 { color: blue; }\n";
    print ".freq { color: gray; }\n";
    print ".gw { background: yellow; }\n";
    print ".bw { background: red; font-size: 24px;}\n";

    print ".q1 { background-color: #FFFFCC; }\n";
    print ".q2 { background-color: #FFFF5C; }\n";
    print ".q3 { background-color: #FFDB4D; }\n";
    print ".q4 { background-color: #FFB442; font-weight: bold;}\n";
    print ".q5 { background-color: #FF8566; font-weight: bold;}\n";
    print ".q6 { background-color: red; font-weight: bold;}\n";

    print "</style>\n";
    print "\n</head><body>";

    print "\n<h1>Word Usage Report for $docTitle ($inputFile)</h1>";
}


#
# reportPages
#
sub reportPages() {
    print "\n<h2>Page Number Sequence</h2>";
    print "\n<p>This document contains $pageCount pages.";
    print "\n<p>Sequence: ";

    printSequence();
}


#
# reportWordStatistics
#
sub reportWordStatistics() {
    if ($totalWords != 0) {
        print "\n\n<h3>Statistics</h3>";
        my $percentage =  sprintf("%.2f", 100 * ($unknownTotalWords / $totalWords));
        print "\n<p>Total words: $totalWords, of which unknown: $unknownTotalWords [$percentage%]";
        $percentage =  sprintf("%.2f", 100 * ($unknownUniqWords / $uniqWords));
        print "\n<p>Unique words: $uniqWords, of which unknown: $unknownUniqWords [$percentage%]";
    }
}


#
# reportWords
#
sub reportWords($) {
    my $language = shift;

    my $prevKey  = '';
    my $prevLetter = '';

    $uniqWords = 0;
    $totalWords = 0;
    $unknownTotalWords = 0;
    $unknownUniqWords = 0;

    print "\n\n\n<h2>Word frequencies in " . getLanguage(lc($language)) . "</h2>\n";
    loadDictionary($language);

    foreach my $item (@wordList) {
        my ($key, $word) = split(/!/, $item, 2);

        if ($key ne $prevKey) {
            print "\n<p>";
            $prevKey = $key;
        }

        my $letter = lc(substr($key, 0, 1));
        if ($letter ne $prevLetter) {
            print "\n\n<h3>" . uc($letter) . "</h3>\n";
            $prevLetter = $letter;
        }

        reportWord($word, $language);
    }

    reportWordStatistics();
}


sub reportSQL() {
    open (SQLFILE, ">usage.sql") || die("Could not create output file 'usage.sql'");

    print SQLFILE "DELETE FROM WORDS WHERE idbook = $idBook\n";
    print SQLFILE "DELETE FROM BOOKS WHERE idbook = $idBook\n";
    print SQLFILE "INSERT INTO BOOKS ($idBook, \"$docTitle\", \"$docAuthor\")\n";
    print SQLFILE "\n\n\n";

    reportWordsSQL();
    close SQLFILE;
}

#
# reportWordsSQL
#
sub reportWordsSQL() {
    my @languageList = keys %wordHash;
    foreach my $language (@languageList) {
        reportLanguageWordsSQL($language);
    }
}

#
# reportLanguageWordsSQL
#
sub reportLanguageWordsSQL($) {
    my $language = shift;

    my @wordList = keys %{$wordHash{$language}};
    foreach my $word (@wordList) {
        reportWordSQL($word, $language);
    }
}

#
# reportWordSql
#
sub reportWordSQL($$) {
    my $word = shift;
    my $language = shift;

    my $count = $wordHash{$language}{$word};
    print SQLFILE "INSERT INTO WORDS ($idBook, \"$word\", \"$language\", $count)\n";
}


#
# reportWord
#
sub reportWord($$) {
    my $word = shift;
    my $language = shift;
    my $count = $wordHash{$language}{$word};

    $uniqWords++;
    $totalWords += $count;
    $grandTotalUniqWords++;
    $grandTotalWords += $count;

    # Count how many times a word with this frequency occurs:
    $countCountHash{$count}++;

    my $isCompoundWord = 0;
    my $isKnownWord = isKnownWord($word, $language);
    if ($isKnownWord == 0) {
        $isCompoundWord = isCompoundWord($word, $language);
        $unknownUniqWords++;
        $unknownTotalWords += $count;
    }

    my $goodOrBad = defined $badWordsHash{$word} ? 'bw' : defined $goodWordsHash{$word} ? 'gw' : '';

    # Make SHY character visible
    my $unShyWord = $word;
    $unShyWord =~ s/\xad/|/g;

    if ($count > 1 && $retrograd == 1) {
        print "<span class=cnt>$count</span> ";
    }

    my $class = '';
    if ($isKnownWord == 0) {
        my $heatMapClass = lookupHeatMapClass($count);

        if ($isCompoundWord == 1) {
            $class = "$heatMapClass comp $goodOrBad";
        } else {
            $class = "$heatMapClass $goodOrBad";
        }
    } else {
        if ($count < 3) {
            $class = $goodOrBad;
        } else {
            $class = "freq $goodOrBad";
        }
    }
    print "<span" . composeClassAttribute($class) . ">$unShyWord</span> ";

    if ($count > 1 && $retrograd == 0) {
        print "<span class=cnt>$count</span> ";
    }
}

sub composeClassAttribute($) {
    my $class = shift;

    $class =~ s/^\s+|\s+$//g;
    if ($class eq '') {
        return '';
    }
    if ($class =~ /^[a-zA-Z]+$/) {
        return " class=$class";
    }
    return " class='$class'"
}


#
# isCompoundWord
#
sub isCompoundWord($$) {
    my $word = shift;
    my $language = shift;
    my $start = 4;
    my $end = length($word) - 3;

    # print STDERR "\n$word $end";
    for (my $i = $start; $i < $end; $i++) {
        my $before = substr($word, 0, $i);
        my $after = substr($word, $i);
        if (isKnownWord($before, $language) && isKnownWord(ucfirst($after), $language)) {
            # print STDERR "[$before|$after] ";
            return 1;
        }
    }

    my @parts = split(/-/, $word);
    if (@parts > 1) {
        foreach my $part (@parts) {
            if (!isKnownWord($part, $language)) {
                return 0;
            }
        }
        return 1;
    }
    return 0;
}


#
# isKnownWord
#
sub isKnownWord($$) {
    my $word = shift;
    my $language = shift;

    if (defined $dictHash{$language}) {
        if (defined $dictHash{$language}{lc($word)} || defined $dictHash{$language}{$word}) {
            return 1;
        }
    }
    return 0;
}


#
# reportNonWords
#
sub reportNonWords() {
    my @nonWordList = keys %nonWordHash;
    print "\n\n<h2>Frequencies of Non-Words</h2>\n";
    @nonWordList = sort @nonWordList;

    $grandTotalNonWords = 0;
    print "<table>\n";
    print "<tr><th>Sequence<th>Length<th>Count\n";
    foreach my $item (@nonWordList) {
        $item =~ s/\0/[NULL]/g;

        if ($item ne '') {
            my $count = $nonWordHash{$item};
            my $length = length($item);
            $item =~ s/ /\&nbsp;/g;
            $grandTotalNonWords += $count;
            print "<tr><td>|$item| <td align=right><small>$length</small>&nbsp;&nbsp;&nbsp;<td align=right>$count";
        }
    }
    print "</table>\n";
}


#
# reportNonWordsXML
#
sub reportNonWordsXML() {
    my @nonWordList = keys %nonWordHash;
    @nonWordList = sort @nonWordList;

    print USAGEFILE "<nonwords>\n";
    foreach my $item (@nonWordList) {
        $item =~ s/\0/[NULL]/g;

        if ($item ne '') {
            my $count = $nonWordHash{$item};
            $item =~ s/\&/\&amp;/g;
            $item =~ s/</\&lt;/g;
            $item =~ s/>/\&gt;/g;
            print USAGEFILE "<nonword count=\"$count\" xml:space=\"preserve\">$item</nonword>\n";
        }
    }
    print USAGEFILE "</nonwords>\n";
}


#
# reportChars
#
sub reportChars() {
    my @charList = keys %charHash;
    @charList = sort @charList;
    print "\n\n<h2>Character Frequencies</h2>\n";

    $grandTotalCharacters = 0;
    print "<table>\n";
    print "<tr><th>Character<th>Code<th>Count\n";
    foreach my $char (@charList) {
        $char =~ s/\0/[NULL]/g;

        my $count = $charHash{$char};
        my $ord = ord($char);
        $grandTotalCharacters += $count;
        print "<tr><td>$char<td align=right><small>$ord</small>&nbsp;&nbsp;&nbsp;<td align=right><b>$count</b>\n";
    }
    print "</table>\n";
}


#
# reportCharsXML
#
sub reportCharsXML() {
    my @charList = keys %charHash;
    @charList = sort @charList;

    print USAGEFILE "<characters>\n";
    foreach my $char (@charList) {
        my $count = $charHash{$char};
        my $ord = ord($char);
        print USAGEFILE "<character code=\"$ord\" count=\"$count\">&#$ord;</character>\n";
    }
    print USAGEFILE "</characters>\n";
}


#
# reportCompositeChars
#
sub reportCompositeChars() {
    my @compositeCharList = keys %compositeCharHash;
    @compositeCharList = sort @compositeCharList;
    print "\n\n<h2>Unicode Composite Character Frequencies</h2>\n";

    $grandTotalCompositeCharacters = 0;
    print "<table>\n";
    print "<tr><th>Character<th>Codes<th>Count\n";
    foreach my $compositeChar (@compositeCharList) {
        $compositeChar =~ s/\0/[NULL]/g;

        my $count = $compositeCharHash{$compositeChar};

        my $ordinals = '';
        my @chars = split(//, $compositeChar);
        foreach my $char (@chars) {
            $ordinals .= ' ' . ord($char);
        }

        $grandTotalCompositeCharacters += $count;
        print "<tr><td>$compositeChar<td align=right><small>$ordinals</small>&nbsp;&nbsp;&nbsp;<td align=right><b>$count</b>\n";
    }
    print "</table>\n";
}


#
# reportCompositeCharsXML
#
sub reportCompositeCharsXML() {
    my @compositeCharList = keys %compositeCharHash;

    if (@compositeCharList) {
        @compositeCharList = sort @compositeCharList;
        print USAGEFILE "<composite-characters>\n";
        foreach my $compositeChar (@compositeCharList) {
            my $count = $compositeCharHash{$compositeChar};

            my $ords = '';
            my @chars = split(//, $compositeChar);
            foreach my $char (@chars) {
                $ords .= ' ' . ord($char);
            }
            $compositeChar =~ s/\0/[NULL]/g;
            print USAGEFILE "<composite-character codes=\"$ords\" count=\"$count\">$compositeChar</composite-character>\n";
        }
        print USAGEFILE "</composite-characters>\n";
    }
}


#
# reportNumbers
#
sub reportNumbers() {
    my @numberList = keys %numberHash;
    print "<h2>Number Frequencies</h2>\n";
    @numberList = sort { $a <=> $b } @numberList;

    print '<p>';
    foreach my $number (@numberList) {
        my $count = $numberHash{$number};
        if ($count > 1) {
            print "<b>$number</b> <span class=cnt>$count</span>;\n";
        } else {
            print "$number;\n";
        }
    }
}


#
# reportTags: report on the occurances of tags.
#
sub reportTags() {
    my @tagList = keys %tagHash;
    print "\n\n<h2>XML-Tag Frequencies</h2>\n";
    @tagList = sort { lc($a) cmp lc($b) } @tagList;

    $grandTotalTags = 0;
    print "<table>\n";
    print "<tr><th>Tag<th>Count\n";
    foreach my $tag (@tagList) {
        my $count = $tagHash{$tag};
        $grandTotalTags += $count;
        print "<tr><td><code>$tag</code><td align=right><b>$count</b>\n";
    }
    print "</table>\n";
}


#
# reportTagsxml: report on the occurances of tags.
#
sub reportTagsXML() {
    my @tagList = keys %tagHash;
    @tagList = sort { lc($a) cmp lc($b) } @tagList;

    print USAGEFILE "<tags>\n";
    foreach my $tag (@tagList) {
        my $count = $tagHash{$tag};
        print USAGEFILE "<tag count=\"$count\">$tag</tag>\n";
    }
    print USAGEFILE "</tags>\n";
}


#
# reportRend: report on the occurances of the rend tag.
#
sub reportRend() {
    my @rendList = keys %rendHash;
    print "<h2>Rendering Attribute Frequencies</h2>\n";
    @rendList = sort { lc($a) cmp lc($b) } @rendList;

    print "<table>\n";
    print "<tr><th>Rendering<th>Count\n";
    foreach my $rend (@rendList) {
        my $count = $rendHash{$rend};
        print "<tr><td><code>$rend</code><td align=right><b>$count</b>\n";
    }
    print "</table>\n";
}


#
# reportRendXML: report on the occurances of the rend tag.
#
sub reportRendXML() {
    my @rendList = keys %rendHash;
    @rendList = sort { lc($a) cmp lc($b) } @rendList;

    print USAGEFILE "<rends>\n";
    foreach my $rend (@rendList) {
        my $count = $rendHash{$rend};
        print USAGEFILE "<rend count=\"$count\">$rend</rend>\n";
    }
    print USAGEFILE "</rends>\n";
}


#
# reportStatistics: report the overall word-counts.
#
sub reportStatistics {
    my $textWordCount      = $wordCount    - $headerWordCount;
    my $textNonWordCount   = $nonWordCount - $headerNonWordCount;
    my $textNumberCount    = $numberCount  - $headerNumberCount;
    my $textCharCount      = $charCount    - $headerCharCount;

    my $extend = $textWordCount + $textNumberCount;

    print "\n<h2>Overall Statistics</h2>";
    print "\n<table>";
    print "\n<tr><th>Items                  <th>Overall             <th>TEI Header          <th>Text                <th>Notes";
    print "\n<tr><td>Number of words:           <td>$wordCount          <td>$headerWordCount    <td id=textWordCount>$textWordCount      <td id=langCount>$langCount languages";
    print "\n<tr><td>Number of non-words:       <td>$nonWordCount       <td>$headerNonWordCount <td>$textNonWordCount   <td>";
    print "\n<tr><td>Number of numbers:     <td>$numberCount        <td>$headerNumberCount  <td>$textNumberCount    <td>";
    print "\n<tr><td>Number of characters:  <td>$charCount          <td>$headerCharCount    <td>$textCharCount      <td>excluding characters in tags, SGML headers, or SGML comments, includes header information";
    print "\n<tr><td>Number of tags:            <td>$grandTotalTags     <td>                    <td>                    <td>excluding closing tags";
    print "\n<tr><td>Extend:                    <td>                    <td>                    <td>$extend             <td>Words and numbers in text";
    print "\n</table>";
}


#
# reportCountCounts()
#
sub reportCountCounts() {
    print "\n<h3>Count of Counts</h3>";

    print "\n<table>";
    print "\n<tr><th>Count <th>Number of words with this count <th>Total <th>Cummulative";

    my $cummulativeCount = 0;
    foreach my $count (sort { $b <=> $a } (keys %countCountHash)) {
        my $total = $count * $countCountHash{$count};
        $cummulativeCount += $total;
        print "\n<tr><td>$count <td>$countCountHash{$count} <td>$total <td>$cummulativeCount";
    }
    print "\n</table>";
}


#==============================================================================
#
# popLang: pop from the tag-stack when a tag is closed.
#
sub popLang($$) {
    my $tag = shift;
    my $remainder = shift;

    if ($langStackSize > 0 && $tag eq $stackTag[$langStackSize]) {
        $langStackSize--;
    } else {
        die("ERROR: XML not well-formed (found closing tag '$tag' that was not opened; remainder: '$remainder;')");
    }
}

#
# pushLang: push on the tag-stack when a tag is opened
#
sub pushLang($$) {
    my $tag = shift;
    my $lang = shift;

    if ($ignoreLanguage == 1) {
        $lang = 'EN';
    }

    $langHash{$lang}++;
    $langStackSize++;
    $stackLang[$langStackSize] = $lang;
    $stackTag[$langStackSize] = $tag;
}

#
# getLang: get the current language
#
sub getLang() {
    my $lang = $stackLang[$langStackSize];
    return (defined $lang) ? $lang : 'UNK';
}


#==============================================================================
#
# loadScannoFile
#
sub loadScannoFile($) {
    my $lang = shift;

    if (open(SCANNOFILE, "\\eLibrary\\Tools\\tei2html\\tools\\dictionaries\\$lang.scannos")) {
        my $count = 0;
        while (<SCANNOFILE>) {
            my $scanno =  $_;
            $scanno =~ /^(.*?)\|(.*?)\|(.*?)\t([0-9]+)$/;
            my $prev = $1;
            my $word = $2;
            my $next = $3;
            my $frequency = $4;
            # print STDERR "DEBUG: $scanno ->  [$prev] $word [$next] ($frequency)\n";
            $scannoHash{"$prev:$word:$next"} = $frequency;
            $count++;
        }
        $verbose && print STDERR "NOTICE:  Loaded scanno list for " . getLanguage($lang) . " with $count entries\n";

        close(SCANNOFILE);
    } else {
        $verbose && print STDERR "WARNING: Unable to open: \"dictionaries\\$lang.scannos\"\n";
    }
}



#==============================================================================
#
# loadDict: load a dictionary for a language;
#
sub loadDictionary($) {
    my $language = shift;
    if ($language eq 'xx') {
        return;
    }
    if (!openDictionary("$language.dic")) {
        $language =~ /-/;
        my $baseLanguage = $`;
        if (!defined $baseLanguage || $baseLanguage eq '' || !openDictionary("$baseLanguage.dic")) {
            $verbose && print STDERR "WARNING: Could not open dictionary for " . getLanguage($language) . "\n";
            return;
        }
    }

    my $count = 0;
    while (<DICTFILE>) {
        my $dictionaryWord =  $_;
        $dictionaryWord =~ s/\n//g;
        $dictHash{$language}{$dictionaryWord} = 1;
        $count++;
    }
    $verbose && print STDERR "NOTICE:  Loaded dictionary for " . getLanguage($language) . " with $count words\n";
    close(DICTFILE);

    loadCustomDictionary($language);
}


#
# loadCustomDictionary
#
sub loadCustomDictionary($) {
    my $language = shift;
    my $file = "custom-$language.dic";
    if (openDictionary($file)) {
        my $count = 0;
        while (<DICTFILE>) {
            my $dictionaryWord =  $_;
            $dictionaryWord =~ s/\n//g;
            $dictHash{$language}{$dictionaryWord} = 1;
            $count++;
        }
        $verbose && print STDERR "NOTICE:  Loaded custom dictionary for " . getLanguage($language) . " with $count words\n";
        close(DICTFILE);
    }
}


#
# openDictionary
#
sub openDictionary($) {
    my $file = shift;
    if (!open(DICTFILE, "$file")) {
        if (!open(DICTFILE, "..\\$file")) {
            if (!open(DICTFILE, "C:\\bin\\dic\\$file")) {
                return 0;
            }
        }
    }
    return 1;
}


#
# loadGoodBadWords
#
sub loadGoodBadWords() {
    %goodWordsHash = ();
    %badWordsHash = ();

    if (-e 'good_words.txt') {
        if (open(GOODWORDSFILE, "<:encoding(iso-8859-1)", "good_words.txt")) {
            my $count = 0;
            while (<GOODWORDSFILE>) {
                my $dictword =  $_;
                $dictword =~ s/\n//g;
                $goodWordsHash{$dictword} = 1;
                $count++;
            }
            $verbose && print STDERR "NOTICE:  Loaded good_words.txt with $count words\n";
            close(GOODWORDSFILE);
        }
    }

    if (-e 'bad_words.txt') {
        if (open(BADWORDSFILE, "<:encoding(iso-8859-1)", "bad_words.txt")) {
            my $count = 0;
            while (<BADWORDSFILE>) {
                my $dictword =  $_;
                $dictword =~ s/\n//g;
                $badWordsHash{$dictword} = 1;
                $count++;
            }
            $verbose && print STDERR "NOTICE:  Loaded bad_words.txt with $count words\n";
            close(BADWORDSFILE);
        }
    }
}


#################################################
#
# Heatmap related functions
#


#
# heatMapDocument
#
sub makeHeatMap() {
    open (INPUTFILE, $inputFile) || die("ERROR: Could not open input file $inputFile");
    open (HEATMAPFILE, ">heatmap.xml") || die("Could not create output file 'heatmap.xml'");

    while (<INPUTFILE>) {
        my $remainder = $_;
        while ($remainder =~ /$tagPattern/) {
            my $fragment = $`;
            my $tag = $1;
            $remainder = $';
            heatMapFragment($fragment);
            heatMapTag($tag, $remainder);
            print HEATMAPFILE "<" . sgml2utf($tag) . ">";
        }
        heatMapFragment($remainder);
    }

    close (HEATMAPFILE);
    close (INPUTFILE);
}


#
# heatMapFragment: split a text fragment into words and create a heat map
# from it.
#
sub heatMapFragment($) {
    my $fragment = shift;
    $fragment = sgml2utf($fragment);

    my $lang = getLang();

    my $prevWord = "";

    # NOTE: we don't use \w and \W here, since it gives some unexpected results.
    my @words = split(/([^\pL\pN\pM-]+)/, $fragment);

    my $size = @words;
    for (my $i = 0; $i < $size; $i++) {
        # cannot use foreach, as we look ahead.
        my $word = $words[$i];

        if ($word ne "") {
            if ($word =~ /^[^\pL\pN\pM-]+$/) {
                heatMapNonWord($word);
                # reset previous word if separated from this word by more than just a space.
                if ($word !~ /^[\pZ]+$/) {
                    $prevWord = "";
                }
            } elsif ($word =~ /^[0-9]+$/) {
                heatMapNumber($word);
                $prevWord = "";
            } else {
                # we have a word.
                my $nextWord = "";

                if (exists($words[$i + 2]) && $words[$i + 1] =~ /^[\pZ]+$/ && $words[$i + 2] =~ /^[\pL\pN\pM-]+$/) {
                    $nextWord = $words[$i + 2];
                }
                heatMapWord($word, $lang, $prevWord, $nextWord);
                $prevWord = $word;
            }
        }
    }
}


#
# heatMapTag: push/pop an XML tag on the tag-stack. (non-counting variant of handleTag)
#
sub heatMapTag($$) {
    my $tag = shift;
    my $remainder = shift;

    # end tag or start tag?
    if ($tag =~ /^!/) {
        # Comment, don't care.
    }
    elsif ($tag =~ /^\/([a-zA-Z0-9_.:-]+)/) {
        my $element = $1;
        popLang($element, $remainder);
    } elsif ($tag =~ /\/$/) {
        # Empty element
        $tag =~ /^([a-zA-Z0-9_.:-]+)/;
    } else {
        $tag =~ /^([a-zA-Z0-9_.:-]+)/;
        my $element = $1;
        my $lang = getAttrVal('lang', $tag);
        if ($lang ne '') {
            pushLang($element, $lang);
        } else {
            pushLang($element, getLang());
        }
    }
}


#
# heatMapNonWord
#
sub heatMapNonWord($) {
    my $word = shift;
    my $xmlWord = $word;

    $xmlWord =~ s/</\&lt;/g;
    $xmlWord =~ s/>/\&gt;/g;
    $xmlWord =~ s/\&/\&amp;/g;

    my $count = defined $nonWordHash{$word} ? $nonWordHash{$word} : 0;
    if ($count < 5) {
        print HEATMAPFILE "<ab type=\"p3\">$xmlWord</ab>";
    } elsif ($count < 25) {
        print HEATMAPFILE "<ab type=\"p2\">$xmlWord</ab>";
    } elsif ($count < 100) {
        print HEATMAPFILE "<ab type=\"p1\">$xmlWord</ab>";
    } else {
        print HEATMAPFILE $xmlWord;
    }
}


#
# heatMapNumber
#
sub heatMapNumber($) {
    my $word = shift;
    print HEATMAPFILE $word;
}


#
# heatMapWord
#
sub heatMapWord($$$$) {
    my $word = shift;
    my $dummy = shift;
    my $prevWord = shift;
    my $nextWord = shift;
    my $lang = getLang();

    # print STDERR "HEATMAP: [$prevWord] $word [$nextWord]\n";

    if (!isKnownWord($word, $lang)) {
        my $count = $wordHash{$lang}{$word};
        if ($count < 100) {
            my $type = lookupHeatMapClass($count);
            print HEATMAPFILE "<ab type=\"$type\">$word</ab>";
        } else {
            print HEATMAPFILE $word;
        }
    } else {
        heatMapScanno($word, $prevWord, $nextWord);
    }
}


#
# lookupHeatMapClass
#
sub lookupHeatMapClass($) {
    my $count = shift;
    if ($count < 2) {
        return 'q5';
    } elsif ($count < 3) {
        return 'q4';
    } elsif ($count < 5) {
        return 'q3';
    } elsif ($count < 8) {
        return 'q2';
    } elsif ($count < 100) {
        return 'q1';
    } else {
        return '';
    }
}


#
# heatMapScanno
#
sub heatMapScanno($$$) {
    my $word = shift;
    my $prevWord = shift;
    my $nextWord = shift;
    my $lang = getLang();

    if (exists($scannoHash{":$word:"})) {
        print HEATMAPFILE "<ab type=\"h3\">$word</ab>";
    } else {
        print HEATMAPFILE $word;
    }
}


#
# heatMapPair()
#
sub heatMapPair() {
    # my $word = shift;

    # print HEATMAPFILE $word;
}



#==============================================================================
#
# printSequence
#
sub printSequence() {
    my $pStart = 'SENTINEL';
    my $pPrevious = 'SENTINEL';
    my $comma = '';
    foreach my $pCurrent (@pageList) {
        if ($pCurrent eq '') {
            $pCurrent = 'N/A';
        }
        if ($pCurrent =~ /n$/) {
            # ignore page-break in footnote.
        } else {
            if (!isInSequence($pPrevious, $pCurrent)) {
                if ($pStart eq 'SENTINEL') {
                    # No range yet
                } elsif ($pStart eq $pPrevious) {
                    print "$comma$pStart";
                    $comma = ', ';
                } else {
                    print "$comma$pStart-$pPrevious";
                    $comma = ', ';
                }
                $pStart = $pCurrent;
            }
            $pPrevious = $pCurrent;
        }
    }

    # last sequence:
    if ($pStart eq 'SENTINEL') {
        # No range at all
        print 'Empty Sequence.'
    } elsif ($pStart eq $pPrevious) {
        print "$comma$pStart.";
    } else {
        print "$comma$pStart-$pPrevious.";
    }
}


#
# isInSequence
#
sub isInSequence($$) {
    my $first = shift;
    my $second = shift;

    if ($first eq 'SENTINEL') {
        return 0;
    }

    if (isroman($first) and isroman($second)) {
        return (arabic($first) == arabic($second) - 1);
    } elsif (isNumber($first) and isNumber($second)) {
        return $first == $second - 1;
    }
    return 0;
}


sub isNumber {
    my $s = shift;
    return $s =~ /^[0-9]+$/
}


#
# StripDiacritics
#
sub StripDiacritics($) {
    my $string = shift;

    for ($string) {
        $_ = NFD($_);       ## decompose (Unicode Normalization Form D)
        s/\pM//g;           ## strip combining characters

        # additional normalizations: (see https://en.wikipedia.org/wiki/Typographic_ligature)
        s/\x{00df}/ss/g;    ## German eszet “ß” -> “ss”
        s/\x{1E9E}/SS/g;    ## German capital eszet “ß” -> “SS”
        s/\x{00c6}/AE/g;    ## Æ
        s/\x{00e6}/ae/g;    ## æ
        s/\x{0132}/IJ/g;    ## Dutch IJ
        s/\x{0133}/ij/g;    ## Dutch ij
        s/\x{0152}/OE/g;    ## Œ
        s/\x{0153}/oe/g;    ## œ

        s/\x{A734}/AO/g;    ## Ligature AO
        s/\x{A735}/ao/g;    ## ligature ao

        s/\x{1EFA}/LL/g;    ## ligature Ll (older Welsh)
        s/\x{1EFB}/ll/g;    ## Ligature ll (older Welsh)

        s/\x{00AD}//g;      ## soft-hyphen
        s/\x{2032}//g;      ## prime
        s/`//g;             ## back-tick
        s/\x{02b9}//g;      ## Modifier letter prime
        s/\x{02bb}//g;      ## 'Okina (Hawaiian glottal stop)
        s/\x{02bc}//g;      ## Modifier letter apostrophe
        s/\x{02bf}//g;      ## Modifier letter left half ring (Ayin)
        s/\x{02be}//g;      ## Modifier letter right half ring (Hamza)

        s/\x{0640}//g;      ## Arabic tatweel

        tr/\x{00d0}\x{0110}\x{00f0}\x{0111}\x{0126}\x{0127}/DDddHh/; # ÐÐðdHh
        tr/\x{0131}\x{0138}\x{013f}\x{0141}\x{0140}\x{0142}/ikLLll/; # i??L?l
        tr/\x{014a}\x{0149}\x{014b}\x{00d8}\x{00f8}\x{017f}/NnnOos/; # ???Øø?
        tr/\x{00de}\x{0166}\x{00fe}\x{0167}/TTtt/;                   # ÞTþt
    }
    return $string;
}


#
# StripPoints -- map Arabic letters to their "undotted" versions.
#
sub StripPoints($) {
    my $string = shift;

    for ($string) {
        # U+0628 BEH; U+062A TEH; U+062B THEH; U+067E PEH; U+0679 TTEH  ->  U+066E DOTLESS BEH
        s/\x{0628}/\x{066E}/g;
        s/\x{062A}/\x{066E}/g;
        s/\x{062B}/\x{066E}/g;
        s/\x{067E}/\x{066E}/g;
        s/\x{0679}/\x{066E}/g;

        # U+062C JEEM; U+062E KHAH; U+0686 TCHEH  ->  U+062D HAH
        s/\x{062C}/\x{062D}/g;
        s/\x{062E}/\x{062D}/g;
        s/\x{0686}/\x{062D}/g;
    
        # U+0630 THAL; U+0688 DDAL  ->  U+062F DAL
        s/\x{0630}/\x{062F}/g;
        s/\x{0688}/\x{062F}/g;

        # U+0632 ZAIN; U+0698 JEH; U+0691 RREH  ->  U+0631 REH
        s/\x{0632}/\x{0631}/g;
        s/\x{0698}/\x{0631}/g;
        s/\x{0691}/\x{0631}/g;

        # U+0634 SHEEN; U+069C SEEN WITH THREE DOTS BELOW AND THREE DOTS ABOVE ->  U+0633 SEEN
        s/\x{0634}/\x{0633}/g;
        s/\x{069C}/\x{0633}/g;

        # U+069E SAD WITH THREE DOTS ABOVE; U+0636 DAD  ->  U+0635 SAD
        s/\x{069E}/\x{0635}/g;
        s/\x{0636}/\x{0635}/g;

        # U+0638 ZAH  ->  U+0637 TAH
        s/\x{0638}/\x{0637}/g;

        # U+063A GHAIN  ->  U+0639 AIN
        s/\x{063A}/\x{0639}/g;

        # U+0641 FEH; U+06A2 FEH WITH DOT MOVED BELOW  ->  U+06A1 DOTLESS FEH
        s/\x{0641}/\x{06A1}/g;
        s/\x{06A2}/\x{06A1}/g;

        # U+0642 QAF; U+06A7 QAF WITH DOT ABOVE; U+06A8 QAF WITH THREE DOTS ABOVE  ->  U+066F DOTLESS QAF
        s/\x{0642}/\x{066F}/g;
        s/\x{06A7}/\x{066F}/g;
        s/\x{06A8}/\x{066F}/g;

        # U+06AE KAF WITH THREE DOTS BELOW  ->  U+0643 KAF
        s/\x{06AE}/\x{0643}/g;

        # U+0646 NOON  ->  U+06BA NOON GHUNNA    
        s/\x{0646}/\x{06BA}/g;
    }
    return $string;
}


#
# Normalize
#
sub Normalize($) {
    my $string = shift;
    $string =~ s/-//g;
    $string =~ s/\*//g;
    $string = lc(StripDiacritics($string));
    return $string;
}


#
# NormalizeForLanguage
#
sub NormalizeForLanguage($$) {
    my $string = shift;
    my $lang = shift;
    if ($lang eq 'ceb') {
        return CebuanoNormalize($string);
    }
    if ($lang eq 'ar' or $lang eq 'ur' or $lang eq 'fa') {
        $string = StripPoints($string);
    }
    return Normalize($string);
}


#
# CebuanoNormalize
#
sub CebuanoNormalize($) {
    my $string = shift;
    $string = Normalize($string);

    # Handle old Spanish-derived spelling variants
    $string =~ s/gui/gi/g;
    $string =~ s/qui/ki/g;
    $string =~ s/o/u/g;
    $string =~ s/e/i/g;
    $string =~ s/ci/si/g;
    $string =~ s/c/k/g;
    $string =~ s/ao/aw/g;

    return $string;
}


#
# SimilarityNormalize
#
# Sort in such a way that letters that are easily confused sort close together.
# Typical confused pairs are mapped to one of the pair.
#
sub SimilarityNormalize($) {
    my $string = shift;
    $string = StripDiacritics($string);

    # English spelling variations
    $string =~ s/ou/o/g;
    $string =~ s/ll/l/g;
    $string =~ s/ise/ize/g;

    $string =~ s/ri/m/g;
    $string =~ s/rn/m/g;
    $string =~ s/[lI]/l/g;
    $string =~ s/[bh]/b/g;
    $string =~ s/[ce]/e/g;
    $string =~ s/[mw]/m/g;
    $string =~ s/[HN]/H/g;
    $string =~ s/[VY]/V/g;
    $string =~ s/[CG]/C/g;

    # ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz
    # ABEFCGJILMWKHNXDOQPRSZTUVYaecouvwbhkdfjygqpltirnmszx
    $string =~ tr/ABEFCGJILMWKHNXDOQPRSZTUVYaecouvwbhkdfjygqpltirnmszx/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz/;

    return lc($string);
}

