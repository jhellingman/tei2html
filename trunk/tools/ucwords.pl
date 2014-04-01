# ucwords.pl -- Unicode based perl script for collecting words from an XML file.

use strict;

use utf8;
binmode(STDOUT, ":utf8");
use open ':utf8';

require Encode;
use Unicode::Normalize;
use DBI;

use Roman;      # Roman.pm version 1.1 by OZAWA Sakuro <ozawa@aisoft.co.jp>

use SgmlSupport qw/getAttrVal sgml2utf/;
use LanguageNames qw/getLanguage/;

#####################################################################
#
# Main
#


# Global settings
my $verbose = 0;        # Set to 1 to verbosely report what is happening.
my $useDatabase = 0;    # Set to 1 to store the word statistics in a database.
my $idbook = 1;
my $docTitle = "Title";
my $docAuthor = "Author";


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
my $uniqCount = 0;
my $nonCount = 0;
my $varCount = 0;
my $langCount = 0;
my $langStackSize = 0;

my $totalWords = 0;

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


# Constants
my $tagPattern = "<(.*?)>";

my $infile = $ARGV[0];


# Information about currently processed document
my $defaultLang = "en";
if ($infile eq "-l")
{
    $defaultLang = $ARGV[1];
    pushLang("NULL", $defaultLang);
    $infile = $ARGV[2];
}

# Database Handle
my $dbh = 0;

# Prepared SQL queries
my $sthAddWord = 0;
my $sthGetWordCount = 0;



# loadScannoFile("en");

collectWords();

loadGoodBadWords();

if ($useDatabase)
{
    initDatabase();
    addBook($idbook, $docTitle, $docAuthor, $infile);
}

report();

# reportSQL();
# reportXML();
# heatMapDocument();




#################################################
#
# Heatmap related functions
#


#
# heatMapDocument
#
sub heatMapDocument()
{
    open (INPUTFILE, $infile) || die("ERROR: Could not open input file $infile");
    open (HEATMAPFILE, ">heatmap.xml") || die("Could not create output file 'heatmap.xml'");

    while (<INPUTFILE>)
    {
        my $remainder = $_;
        while ($remainder =~ /$tagPattern/)
        {
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
sub heatMapFragment($)
{
    my $fragment = shift;
    $fragment = sgml2utf($fragment);

    my $lang = getLang();

    my $prevWord = "";
    # NOTE: we don't use \w and \W here, since it gives some unexpected results
    my @words = split(/([^\pL\pN\pM-]+)/, $fragment);

    my $size = @words;
    for (my $i = 0; $i < $size; $i++)  # cannot use foreach, as we look ahead.
    {
        my $word = $words[$i];

        if ($word ne "")
        {
            if ($word =~ /^[^\pL\pN\pM-]+$/)
            {
                heatMapNonWord($word);
                # reset previous word if separated from this word by more than just a space.
                if ($word !~ /^[\pZ]+$/)
                {
                    $prevWord = "";
                }
            }
            elsif ($word =~ /^[0-9]+$/)
            {
                heatMapNumber($word);
                $prevWord = "";
            }
            else # we have a word.
            {
                my $nextWord = "";

                if (exists($words[$i + 2]) && $words[$i + 1] =~ /^[\pZ]+$/ && $words[$i + 2] =~ /^[\pL\pN\pM-]+$/)
                {
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
sub heatMapTag($$)
{
    my $tag = shift;
    my $remainder = shift;

    # end tag or start tag?
    if ($tag =~ /^!/)
    {
        # Comment, don't care.
    }
    elsif ($tag =~ /^\/([a-zA-Z0-9_.-]+)/)
    {
        my $element = $1;
        popLang($element, $remainder);
    }
    elsif ($tag =~ /\/$/)
    {
        # Empty element
        $tag =~ /^([a-zA-Z0-9_.-]+)/;
    }
    else
    {
        $tag =~ /^([a-zA-Z0-9_.-]+)/;
        my $element = $1;
        my $lang = getAttrVal("lang", $tag);
        if ($lang ne "")
        {
            pushLang($element, $lang);
        }
        else
        {
            pushLang($element, getLang());
        }
    }
}


#
# heatMapNonWord
#
sub heatMapNonWord($)
{
    my $word = shift;
    my $xmlWord = $word;

    $xmlWord =~ s/</\&lt;/g;
    $xmlWord =~ s/>/\&gt;/g;
    $xmlWord =~ s/\&/\&amp;/g;

    if ($nonWordHash{$word} < 5)
    {
        print HEATMAPFILE "<ab type=\"p3\">$xmlWord</ab>";
    }
    elsif ($nonWordHash{$word} < 25)
    {
        print HEATMAPFILE "<ab type=\"p2\">$xmlWord</ab>";
    }
    elsif ($nonWordHash{$word} < 100)
    {
        print HEATMAPFILE "<ab type=\"p1\">$xmlWord</ab>";
    }
    else
    {
        print HEATMAPFILE $xmlWord;
    }
}


#
# heatMapNumber
#
sub heatMapNumber($)
{
    my $word = shift;

    print HEATMAPFILE $word;
}


#
# heatMapWord
#
sub heatMapWord($$$$)
{
    my $word = shift;
    my $dummy = shift;
    my $prevWord = shift;
    my $nextWord = shift;
    my $lang = getLang();

    # print STDERR "HEATMAP: [$prevWord] $word [$nextWord]\n";

    if (!isKnownWord($word, $lang))
    {
        my $count = $wordHash{$lang}{$word};
        if ($count < 100)
        {
            my $type = lookupHeatMapClass($count);
            print HEATMAPFILE "<ab type=\"$type\">$word</ab>";
        }
        else
        {
            print HEATMAPFILE $word;
        }
    }
    else
    {
        heatMapScanno($word, $prevWord, $nextWord);
    }
}


#
# lookupHeatMapClass
#
sub lookupHeatMapClass($)
{
    my $count = shift;
    if ($count < 2)
    {
        return "q5";
    }
    elsif ($count < 3)
    {
        return "q4";
    }
    elsif ($count < 5)
    {
        return "q3";
    }
    elsif ($count < 8)
    {
        return "q2";
    }
    elsif ($count < 100)
    {
        return "q1";
    }
    else
    {
        return "";
    }
}


#
# heatMapScanno
#
sub heatMapScanno($$$)
{
    my $word = shift;
    my $prevWord = shift;
    my $nextWord = shift;
    my $lang = getLang();

    if (exists($scannoHash{":$word:"}))
    {
        print HEATMAPFILE "<ab type=\"h3\">$word</ab>";
    }
    else
    {
        print HEATMAPFILE $word;
    }
}


#
# heatMapPair()
#
sub heatMapPair()
{
    # my $word = shift;

    # print HEATMAPFILE $word;
}



####################################################
#
# Collecting the words from the text.
#


sub loadDocument($)
{
    my $infile = shift;
    open (INPUTFILE, $infile) || die("ERROR: Could not open input file $infile");
    while (<INPUTFILE>)
    {
        push (@lines, $_);
    }
    close (INPUTFILE);
}


#
# collectWords
#
sub collectWords()
{
    loadDocument($infile);

    foreach my $line (@lines)
    {
        my $remainder = $line;

        if ($remainder =~ /<title>(.*?)<\/title>/)
        {
            $docTitle = sgml2utf($1);
        }
        if ($remainder =~ /<author>(.*?)<\/author>/)
        {
            $docAuthor = sgml2utf($1);
        }
        if ($remainder =~ /<idno type=\"PGnum\">([0-9]+)<\/idno>/)
        {
            $idbook = $1;
            # $useDatabase = 1;
        }
        if ($remainder =~ /<\/teiHeader>/)
        {
            $headerWordCount = $wordCount;
            $headerNumberCount = $numberCount;
            $headerCharCount = $charCount;
            $headerNonWordCount = $nonWordCount;
        }

        while ($remainder =~ /$tagPattern/)
        {
            my $fragment = $`;
            my $tag = $1;
            $remainder = $';
            handleFragment($fragment);
            handleTag($tag, $remainder);
        }
        handleFragment($remainder);
    }
}


####################################################
#
# Report the collected statistics.
#


sub report()
{
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


sub reportXML()
{
    open (USAGEFILE, ">usage.xml") || die("Could not create output file 'usage.xml'");

    print USAGEFILE "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
    print USAGEFILE "<?xml-stylesheet type=\"text/xsl\" href=\"http://www.gutenberg.ph/xslt/usage.xsl\"?>";
    print USAGEFILE "<usage>\n";

    reportWordsXML();
    reportNonWordsXML();
    reportCharsXML();
    reportTagsXML();
    reportRendXML();

    print USAGEFILE "</usage>\n";
}


#
# sortWords
#
sub sortWords()
{
    my @languageList = keys %wordHash;
    foreach my $language (@languageList)
    {
        $langCount++;
        sortLanguageWords($language);
    }
}


#
# reportWordsXML
#
sub reportWordsXML()
{
    my @languageList = keys %wordHash;
    foreach my $language (@languageList)
    {
        reportLanguageWordsXML($language);
    }
}


#
# sortLanguageWords
#
sub sortLanguageWords($)
{
    my $language = shift;
    @wordList = keys %{$wordHash{$language}};

    foreach my $word (@wordList)
    {
        my $key = NormalizeForLanguage($word, $language);
        $word = "$key!$word";
    }
    @wordList = sort @wordList;
    reportWords($language);
    reportLanguagePairs($language);
}


#
# reportLanguageWordsXML
#
sub reportLanguageWordsXML($)
{
    my $language = shift;
    my @wordList = keys %{$wordHash{$language}};

    foreach my $word (@wordList)
    {
        my $key = NormalizeForLanguage($word, $language);
        $word = "$key!$word";
    }
    @wordList = sort @wordList;

    print USAGEFILE "\n<words xml:lang=\"$language\">\n";

    loadDict($language);

    my $previousKey = "";
    foreach my $item (@wordList)
    {
        my ($key, $word) = split(/!/, $item, 2);

        if ($key ne $previousKey) 
        {
            if ($previousKey ne "")
            {
                print USAGEFILE "</wordGroup>\n";
            }
            print USAGEFILE "<wordGroup>";
        }

        my $count = $wordHash{$language}{$word};
        my $known = isKnownWord($word, $language);

        print USAGEFILE "<word count=\"$count\" known=\"$known\">$word</word>";

        $previousKey = $key;
    }

    if ($previousKey ne "") 
    {
        print USAGEFILE "</wordGroup>\n";
    }

    print USAGEFILE "</words>\n";
}


#
# reportPairs
#
sub reportPairs()
{
    my @languageList = keys %pairHash;
    foreach my $language (@languageList)
    {
        reportLanguagePairs($language);
    }
}


#
# reportLanguagePairs
#
sub reportLanguagePairs($)
{
    my $language = shift;
    my @pairList = keys %{$pairHash{$language}};
    @pairList = sort @pairList;

    print "\n\n\n<h3>Most Common Word Pairs in " . getLanguage(lc($language)) . "</h3>\n";

    my $max = 0;
    foreach my $pair (sort {$pairHash{$language}{$b} <=> $pairHash{$language}{$a} } @pairList)
    {
        my $count = $pairHash{$language}{$pair};
        if ($count < 10)
        {
            last;
        }

        my ($first, $second) = split(/!/, $pair, 2);

        # print STDERR "PAIR: $count $pair\n";
        print "\n<p>$first $second <span class=cnt>$count</span>";
        $max++;
        if ($max > 100)
        {
            last;
        }
    }
}


#
# printReportHeader
#
sub printReportHeader()
{
    print "<html>";
    print "\n<head><title>Word Usage Report for $docTitle ($infile)</title>";
    print "\n<style>\n";
    print "body { margin-left: 30px; }\n";
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
    print "\n<head><body>";

    print "\n<h1>Word Usage Report for $docTitle ($infile)</h1>";
}


#
# reportPages
#
sub reportPages()
{
    print "\n<h2>Page Number Sequence</h2>";
    print "\n<p>This document contains $pageCount pages.";
    print "\n<p>Sequence: ";

    printSequence();
}


#
# reportWordStatistics
#
sub reportWordStatistics()
{
    if ($totalWords != 0)
    {
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
sub reportWords($)
{
    my $language = shift;

    my $prevWord = "";
    my $prevKey  = "";
    my $prevLetter = "";

    $uniqWords = 0;
    $totalWords = 0;
    $unknownTotalWords = 0;
    $unknownUniqWords = 0;

    print "\n\n\n<h2>Word frequencies in " . getLanguage(lc($language)) . "</h2>\n";
    loadDict($language);

    foreach my $item (@wordList)
    {
        my ($key, $word) = split(/!/, $item, 2);

        if ($key ne $prevKey)
        {
            print "\n<p>";
            $prevKey = $key;
        }

        my $letter = lc(substr($key, 0, 1));
        if ($letter ne $prevLetter)
        {
            print "\n\n<h3>" . uc($letter) . "</h3>\n";
            $prevLetter = $letter;
        }

        reportWord($word, $language);
    }

    reportWordStatistics();
}




sub reportSQL()
{
    open (SQLFILE, ">usage.sql") || die("Could not create output file 'usage.sql'");


    print SQLFILE "DELETE FROM WORDS WHERE idbook = $idbook\n";
    print SQLFILE "DELETE FROM BOOKS WHERE idbook = $idbook\n";

    print SQLFILE "INSERT INTO BOOKS ($idbook, \"$docTitle\", \"$docAuthor\")\n";

    print SQLFILE "\n\n\n";

    reportWordsSQL();

    close SQLFILE;
}

#
# reportWordsSQL
#
sub reportWordsSQL()
{
    my @languageList = keys %wordHash;
    foreach my $language (@languageList)
    {
        reportLanguageWordsSQL($language);
    }
}

#
# reportLanguageWordsSQL
#
sub reportLanguageWordsSQL($)
{
    my $language = shift;

    my @wordList = keys %{$wordHash{$language}};
    foreach my $word (@wordList)
    {
        reportWordSQL($word, $language);
    }
}

#
# reportWordSql
#
sub reportWordSQL($$)
{
    my $word = shift;
    my $language = shift;

    my $count = $wordHash{$language}{$word};
    print SQLFILE "INSERT INTO WORDS ($idbook, \"$word\", \"$language\", $count)\n";
}



#
# reportWord
#
sub reportWord($$)
{
    my $word = shift;
    my $language = shift;
    my $count = $wordHash{$language}{$word};

    if ($useDatabase)
    {
        addWord($idbook, $word, $language, $count);
    }

    $uniqWords++;
    $totalWords += $count;
    $grandTotalUniqWords++;
    $grandTotalWords += $count;

    # Count how many times a word with this frequency occurs:
    $countCountHash{$count}++;
    
    my $compoundWord = "";
    my $known = isKnownWord($word, $language);
    if ($known == 0)
    {
        $compoundWord = compoundWord($word, $language);
        $unknownUniqWords++;
        $unknownTotalWords += $count;
    }

    my $goodOrBad = $badWordsHash{$word} == 1 ? "bw" : $goodWordsHash{$word} == 1 ? "gw" : "";

    if ($known == 0)
    {
        my $heatMapClass = lookupHeatMapClass($count);

        if ($compoundWord ne "")
        {
            print "<span class='$heatMapClass comp $goodOrBad'>$compoundWord</span> ";
        }
        else
        {
            print "<span class='$heatMapClass $goodOrBad'>$word</span> ";
        }
    }
    else
    {
        if ($count < 3)
        {
            print "<span class='$goodOrBad'>$word</span> ";
        }
        else
        {
            print "<span class='freq $goodOrBad'>$word</span> ";
        }
    }

    if ($count > 1)
    {
        print "<span class=cnt>$count</span> ";
    }
}


#
# compoundWord
#
sub compoundWord($$)
{
    my $word = shift;
    my $language = shift;
    my $start = 4;
    my $end = length($word) - 3;

    # print STDERR "\n$word $end";
    for (my $i = $start; $i < $end; $i++)
    {
        my $before = substr($word, 0, $i);
        my $after = substr($word, $i);
        if (isKnownWord($before, $language) == 1 && isKnownWord(ucfirst($after), $language) == 1)
        {
            # print STDERR "[$before|$after] ";
            return "$word";
        }
    }

    my @parts = split(/-/, $word);
    foreach my $part (@parts)
    {
        if (!isKnownWord($part, $language))
        {
            return "";
        }
    }

    return $word;
}


#
# isKnownWord
#
sub isKnownWord($$)
{
    my $word = shift;
    my $lang = shift;

    if ($dictHash{$lang}{lc($word)} != 1)
    {
        if ($dictHash{$lang}{$word} != 1)
        {
            return 0;
        }
    }
    return 1;
}


#
# reportNonWords
#
sub reportNonWords()
{
    my @nonWordList = keys %nonWordHash;
    print "\n\n<h2>Frequencies of Non-Words</h2>\n";
    @nonWordList = sort @nonWordList;

    $grandTotalNonWords = 0;
    print "<table>\n";
    print "<tr><th>Sequence<th>Length<th>Count\n";
    foreach my $item (@nonWordList)
    {
        $item =~ s/\0/[NULL]/g;

        if ($item ne "")
        {
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
sub reportNonWordsXML()
{
    my @nonWordList = keys %nonWordHash;
    @nonWordList = sort @nonWordList;

    print USAGEFILE "<nonwords>\n";
    foreach my $item (@nonWordList)
    {
        $item =~ s/\0/[NULL]/g;

        if ($item ne "")
        {
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
sub reportChars()
{
    my @charList = keys %charHash;
    @charList = sort @charList;
    print "\n\n<h2>Character Frequencies</h2>\n";

    $grandTotalCharacters = 0;
    print "<table>\n";
    print "<tr><th>Character<th>Code<th>Count\n";
    foreach my $char (@charList)
    {
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
sub reportCharsXML()
{
    my @charList = keys %charHash;
    @charList = sort @charList;

    print USAGEFILE "<characters>\n";
    foreach my $char (@charList)
    {
        my $count = $charHash{$char};
        my $ord = ord($char);
        print USAGEFILE "<character code=\"$ord\" count=\"$count\">&#$ord;</character>\n";
    }
    print USAGEFILE "</characters>\n";
}


#
# reportCompositeChars
#
sub reportCompositeChars()
{
    my @compositeCharList = keys %compositeCharHash;
    @compositeCharList = sort @compositeCharList;
    print "\n\n<h2>Unicode Composite Character Frequencies</h2>\n";

    $grandTotalCompositeCharacters = 0;
    print "<table>\n";
    print "<tr><th>Character<th>Codes<th>Count\n";
    foreach my $compositeChar (@compositeCharList)
    {
        $compositeChar =~ s/\0/[NULL]/g;

        my $count = $compositeCharHash{$compositeChar};

        my $ords = "";
        my @chars = split(//, $compositeChar);
        foreach my $char (@chars)
        {
            $ords .= " " . ord($char);
        }

        $grandTotalCompositeCharacters += $count;
        print "<tr><td>$compositeChar<td align=right><small>$ords</small>&nbsp;&nbsp;&nbsp;<td align=right><b>$count</b>\n";
    }
    print "</table>\n";
}


#
# reportCompositeCharsXML
#
sub reportCompositeCharsXML()
{
    my @compositeCharList = keys %compositeCharHash;

    if (@compositeCharList)
    {
        @compositeCharList = sort @compositeCharList;
        print USAGEFILE "<composite-characters>\n";
        foreach my $compositeChar (@compositeCharList)
        {
            my $count = $compositeCharHash{$compositeChar};

            my $ords = "";
            my @chars = split(//, $compositeChar);
            foreach my $char (@chars)
            {
                $ords .= " " . ord($char);
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
sub reportNumbers()
{
    my @numberList = keys %numberHash;
    print "<h2>Number Frequencies</h2>\n";
    @numberList = sort { $a <=> $b } @numberList;

    print "<p>";
    foreach my $number (@numberList)
    {
        my $count = $numberHash{$number};
        if ($count > 1)
        {
            print "<b>$number</b> <span class=cnt>$count</span>;\n";
        }
        else
        {
            print "$number;\n";
        }
    }
}


#
# reportTags: report on the occurances of tags.
#
sub reportTags()
{
    my @tagList = keys %tagHash;
    print "\n\n<h2>XML-Tag Frequencies</h2>\n";
    @tagList = sort { lc($a) cmp lc($b) } @tagList;

    $grandTotalTags = 0;
    print "<table>\n";
    print "<tr><th>Tag<th>Count\n";
    foreach my $tag (@tagList)
    {
        my $count = $tagHash{$tag};
        $grandTotalTags += $count;
        print "<tr><td><code>$tag</code><td align=right><b>$count</b>\n";
    }
    print "</table>\n";
}


#
# reportTagsxml: report on the occurances of tags.
#
sub reportTagsXML()
{
    my @tagList = keys %tagHash;
    @tagList = sort { lc($a) cmp lc($b) } @tagList;

    print USAGEFILE "<tags>\n";
    foreach my $tag (@tagList)
    {
        my $count = $tagHash{$tag};
        print USAGEFILE "<tag count=\"$count\">$tag</tag>\n";
    }
    print USAGEFILE "</tags>\n";
}


#
# reportRend: report on the occurances of the rend tag.
#
sub reportRend()
{
    my @rendList = keys %rendHash;
    print "<h2>Rendering Attribute Frequencies</h2>\n";
    @rendList = sort { lc($a) cmp lc($b) } @rendList;

    print "<table>\n";
    print "<tr><th>Rendering<th>Count\n";
    foreach my $rend (@rendList)
    {
        my $count = $rendHash{$rend};
        print "<tr><td><code>$rend</code><td align=right><b>$count</b>\n";
    }
    print "</table>\n";
}


#
# reportRendXML: report on the occurances of the rend tag.
#
sub reportRendXML()
{
    my @rendList = keys %rendHash;
    @rendList = sort { lc($a) cmp lc($b) } @rendList;

    print USAGEFILE "<rends>\n";
    foreach my $rend (@rendList)
    {
        my $count = $rendHash{$rend};
        print USAGEFILE "<rend count=\"$count\">$rend</rend>\n";
    }
    print USAGEFILE "</rends>\n";
}


#
# reportStatistics: report the overall word-counts.
#
sub reportStatistics
{
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
sub reportCountCounts()
{
    print "\n<h3>Count of Counts</h3>";

    print "\n<table>";
    print "\n<tr><th>Count <th>Number of words with this count <th>Total <th>Cummulative";

    my $cummulativeCount = 0;
    foreach my $count (sort { $b <=> $a } (keys %countCountHash))
    {
        my $total = $count * $countCountHash{$count};
        $cummulativeCount += $total;
        print "\n<tr><td>$count <td>$countCountHash{$count} <td>$total <td>$cummulativeCount";
    }
    print "\n</table>";
}


#
# handleTag: push/pop an XML tag on the tag-stack.
#
sub handleTag($$)
{
    my $tag = shift;
    my $remainder = shift;

    # end tag or start tag?
    if ($tag =~ /^[!?]/)
    {
        # Comment or processing instruction, don't care.
    }
    elsif ($tag =~ /^\/([a-zA-Z0-9_.-]+)/)
    {
        my $element = $1;
        popLang($element, $remainder);
        $tagHash{$element}++;
    }
    elsif ($tag =~ /\/$/)
    {
        # Empty element
        $tag =~ /^([a-zA-Z0-9_.-]+)/;
        my $element = $1;
        $tagHash{$element}++;
        if ($element eq "pb")
        {
            my $n = getAttrVal("n", $tag);
            push @pageList, $n;
            $pageCount++;
        }
        my $rend = getAttrVal("rend", $tag);
        if ($rend ne "")
        {
            $rendHash{$rend}++;
        }
    }
    else
    {
        $tag =~ /^([a-zA-Z0-9_.-]+)/;
        my $element = $1;
        my $lang = getAttrVal("lang", $tag);
        if ($lang ne "")
        {
            pushLang($element, $lang);
        }
        else
        {
            pushLang($element, getLang());
        }
        my $rend = getAttrVal("rend", $tag);
        if ($rend ne "")
        {
            $rendHash{$rend}++;
        }
    }
}


#
# handleFragment: split a text fragment into words and insert them
# in the wordlist.
#
sub handleFragment($)
{
    my $fragment = shift;
    $fragment = NFC(sgml2utf($fragment));

    my $lang = getLang();

    my $prevWord = "";
    # NOTE: we don't use \w and \W here, since it gives some unexpected results
    my @words = split(/([^\x{2032}`\pL\pN\pM-]+)/, $fragment);
    foreach my $word (@words)
    {
        if ($word ne "")
        {
            if ($word =~ /^[^\x{2032}`\pL\pN\pM-]+$/)
            {
                countNonWord($word);
                # reset previous word if not separated by more than just a space.
                if ($word !~ /^[\pZ]+$/)
                {
                    $prevWord = "";
                }
            }
            elsif ($word =~ /^[0-9]+$/)
            {
                countNumber($word);
                $prevWord = "";
            }
            else
            {
                countWord($word, $lang);
                if ($prevWord ne "")
                {
                    countPair($prevWord, $word, $lang);
                }
                $prevWord = $word;
            }
        }
    }

    my @chars = split(//, $fragment);
    foreach my $char (@chars)
    {
        countChar($char);
    }

    my @compositeChars = split(/(\pL\pM*)/, $fragment);
    foreach my $compositeChar (@compositeChars)
    {
        if ($compositeChar =~ /^\pL\pM*$/)
        {
            countCompositeChar($compositeChar)
        }
    }
}


#
# countPair()
#
sub countPair($$$)
{
    my $firstWord = shift;
    my $secondWord = shift;
    my $language = shift;

    $pairHash{$language}{"$firstWord!$secondWord"}++;
    # print STDERR "PAIR: $firstWord $secondWord\n";
}


#
# countWord()
#
sub countWord($$)
{
    my $word = shift;
    my $lang = shift;

    $wordHash{$lang}{$word}++;
    $wordCount++;
}

sub countNumber($)
{
    my $number = shift;
    $numberHash{$number}++;
    $numberCount++;
}

sub countNonWord($)
{
    my $nonWord = shift;
    $nonWordHash{$nonWord}++;
    $nonWordCount++;
}

sub countChar($)
{
    my $char = shift;
    $charHash{$char}++;
    $charCount++;
}

sub countCompositeChar($)
{
    my $compositeChar = shift;
    if (length($compositeChar) > 1)
    {
        $compositeCharHash{$compositeChar}++;
        $compositeChar++;
    }
}


#==============================================================================
#
# popLang: pop from the tag-stack when a tag is closed.
#
sub popLang($)
{
    my $tag = shift;
    my $remainder = shift;

    if ($langStackSize > 0 && $tag eq $stackTag[$langStackSize])
    {
        $langStackSize--;
    }
    else
    {
        die("ERROR: XML not well-formed (found closing tag '$tag' that was not opened; remainder: $remainder)");
    }
}

#
# pushLang: push on the tag-stack when a tag is opened
#
sub pushLang($$)
{
    my $tag = shift;
    my $lang = shift;

    $langHash{$lang}++;
    $langStackSize++;
    $stackLang[$langStackSize] = $lang;
    $stackTag[$langStackSize] = $tag;
}

#
# getLang: get the current language
#
sub getLang()
{
    return $stackLang[$langStackSize];
}


#==============================================================================
#
# loadScannoFile
#
sub loadScannoFile($)
{
    my $lang = shift;

    if (open(SCANNOFILE, "\\eLibrary\\Tools\\tei2html\\tools\\dictionaries\\$lang.scannos"))
    {
        my $count = 0;
        while (<SCANNOFILE>)
        {
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
    }
    else
    {
        $verbose && print STDERR "WARNING: Unable to open: \"dictionaries\\$lang.scannos\"\n";
    }
}



#==============================================================================
#
# loadDict: load a dictionary for a language;
#
sub loadDict($)
{
    my $lang = shift;
    if ($lang eq "xx") 
    {
        return;
    }

    if (!openDictionary("$lang.dic"))
    {
        $lang =~ /-/;
        my $shortlang = $`;
        if ($shortlang eq "" || !openDictionary("$shortlang.dic"))
        {
            $verbose && print STDERR "WARNING: Could not open dictionary for " . getLanguage($lang) . "\n";
            return;
        }
    }

    my $count = 0;
    while (<DICTFILE>)
    {
        my $dictword =  $_;
        $dictword =~ s/\n//g;
        $dictHash{$lang}{$dictword} = 1;
        $count++;
    }
    $verbose && print STDERR "NOTICE:  Loaded dictionary for " . getLanguage($lang) . " with $count words\n";
    close(DICTFILE);

    loadCustomDictionary($lang);
}


#
# loadCustomDictionary
#
sub loadCustomDictionary($)
{
    my $lang = shift;
    my $file = "custom-$lang.dic";
    if (openDictionary($file))
    {
        my $count = 0;
        while (<DICTFILE>)
        {
            my $dictword =  $_;
            $dictword =~ s/\n//g;
            $dictHash{$lang}{$dictword} = 1;
            $count++;
        }
        $verbose && print STDERR "NOTICE:  Loaded custom dictionary for " . getLanguage($lang) . " with $count words\n";

        close(DICTFILE);
    }
}


#
# openDictionary
#
sub openDictionary($)
{
    my $file = shift;
    if (!open(DICTFILE, "$file"))
    {
        if (!open(DICTFILE, "..\\$file"))
        {
            if (!open(DICTFILE, "C:\\bin\\dic\\$file"))
            {
                return 0;
            }
        }
    }
    return 1;
}


#
# loadGoodBadWords
#
sub loadGoodBadWords()
{
    %goodWordsHash = ();
    %badWordsHash = ();

    if (-e "good_words.txt")
    {
        if (open(GOODWORDSFILE, "<:encoding(iso-8859-1)", "good_words.txt"))
        {
            my $count = 0;
            while (<GOODWORDSFILE>)
            {
                my $dictword =  $_;
                $dictword =~ s/\n//g;
                $goodWordsHash{$dictword} = 1;
                $count++;
            }
            $verbose && print STDERR "NOTICE:  Loaded good_words.txt with $count words\n";
            close(GOODWORDSFILE);
        }
    }

    if (-e "bad_words.txt")
    {
        if (open(BADWORDSFILE, "<:encoding(iso-8859-1)", "bad_words.txt"))
        {
            my $count = 0;
            while (<BADWORDSFILE>)
            {
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


#==============================================================================
#
# printSequence
#
sub printSequence()
{
    my $pStart = "SENTINEL";
    my $pPrevious = "SENTINEL";
    my $comma = "";
    foreach my $pCurrent (@pageList)
    {
        if ($pCurrent eq "")
        {
            $pCurrent = "N/A";
        }
        if ($pCurrent =~ /n$/)
        {
            # ignore page-break in footnote.
        }
        else
        {
            if (!isInSequence($pPrevious, $pCurrent))
            {
                if ($pStart eq "SENTINEL")
                {
                    # No range yet
                }
                elsif ($pStart eq $pPrevious)
                {
                    print "$comma$pStart";
                    $comma = ", ";
                }
                else
                {
                    print "$comma$pStart-$pPrevious";
                    $comma = ", ";
                }
                $pStart = $pCurrent;
            }
            $pPrevious = $pCurrent;
        }
    }

    # last sequence:
    if ($pStart eq "SENTINEL")
    {
        # No range at all
        print "Empty Sequence."
    }
    elsif ($pStart eq $pPrevious)
    {
        print "$comma$pStart.";
    }
    else
    {
        print "$comma$pStart-$pPrevious.";
    }
}


#
# isInSequence
#
sub isInSequence($$)
{
    my $a = shift;
    my $b = shift;
    if ($a eq "SENTINEL")
    {
        return 0;
    }
    if (isroman($a))
    {
        return (arabic($a) == arabic($b) - 1);
    }
    else
    {
        return $a == $b - 1;
    }
}


#
# StripDiacritics
#
sub StripDiacritics($)
{
    my $string = shift;

    for ($string)
    {
        $_ = NFD($_);       ##  decompose (Unicode Normalization Form D)
        s/\pM//g;           ##  strip combining characters

        # additional normalizations:
        s/\x{00df}/ss/g;    ##  German eszet “ß” -> “ss”
        s/\x{00c6}/AE/g;    ##  Æ
        s/\x{00e6}/ae/g;    ##  æ
        s/\x{0132}/IJ/g;    ##  Dutch IJ
        s/\x{0133}/ij/g;    ##  Dutch ij
        s/\x{0152}/Oe/g;    ##  Œ
        s/\x{0153}/oe/g;    ##  œ

        s/\x{2032}//g;          ## prime
        s/`//g;					## back-tick.
        s/\x{02bb}//g;          ## 'Okina (Hawaiian glottal stop)
        s/\x{02bc}//g;          ## Modifier letter apostrophe
        s/\x{02bf}//g;          ## Modifier letter left half ring (Ayin)
        s/\x{02be}//g;          ## Modifier letter right half ring (Hamza)

        tr/\x{00d0}\x{0110}\x{00f0}\x{0111}\x{0126}\x{0127}/DDddHh/; # ÐÐðdHh
        tr/\x{0131}\x{0138}\x{013f}\x{0141}\x{0140}\x{0142}/ikLLll/; # i??L?l
        tr/\x{014a}\x{0149}\x{014b}\x{00d8}\x{00f8}\x{017f}/NnnOos/; # ???Øø?
        tr/\x{00de}\x{0166}\x{00fe}\x{0167}/TTtt/;                   # ÞTþt
    }
    return $string;
}


#
# Normalize
#
sub Normalize($)
{
    my $string = shift;
    $string =~ s/-//g;
    $string = lc(StripDiacritics($string));
    return $string;
}


#
# NormalizeForLanguage
#
sub NormalizeForLanguage($$)
{
    my $string = shift;
    my $lang = shift;
    if ($lang eq 'ceb') 
    {
        return CebuanoNormalize($string);
    }
    return Normalize($string);
}


#
# CebuanoNormalize
#
sub CebuanoNormalize($)
{
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
sub SimilarityNormalize($)
{
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


#####################################
#
# Database support functions
#
# See http://cpan.uwinnipeg.ca/htdocs/DBI/DBI.html#Outline_Usage for details of DBI usage.
#

#
# InitDatabase
#
sub initDatabase()
{
    # database information
    my $db = "words";
    my $host = "localhost";
    my $userid = "root";
    my $passwd = "my49sql";
    my $connectionInfo = "dbi:mysql:$db;$host";

    # make connection to database
    $dbh = DBI->connect($connectionInfo, $userid, $passwd, { RaiseError => 1, AutoCommit => 1 });

    initQueries();
}


#
# initQueries()
#
sub initQueries()
{
    my $queryAddWord = "INSERT INTO word (idbook, word, language, count) VALUES (?, ?, ?, ?)";
    $sthAddWord = $dbh->prepare($queryAddWord);

    my $queryGetWordCount = "SELECT sum(count) AS wordcount, count(*) AS doccount FROM word WHERE word=? AND language=?";
    $sthGetWordCount = $dbh->prepare($queryGetWordCount);
}


#
# addWord($$$$)
#
sub addWord($$$$)
{
    my $idbook = shift;
    my $word = shift;
    my $language = shift;
    my $count = shift;

    $word = substr($word, 0, 64);
    $language = substr($language, 0, 8);

    # print "$idbook, $word, $language, $count\n";
    $sthAddWord->execute($idbook, $word, $language, $count);
}


#
# getWordCount
#
sub getWordCount($$)
{
    my $word = shift;
    my $language = shift;
    $sthGetWordCount->execute($word, $language);

    my $wordcount;
    my $doccount;

    $sthGetWordCount->bind_columns(\$wordcount, \$doccount);

    if ($sthGetWordCount->fetch())
    {
        return ($wordcount, $doccount);
    }
    else
    {
        return (0, 0);
    }
}


#
# addBook
#
sub addBook($$$)
{
    my $idbook = shift;
    my $title = shift;
    my $author = shift;
    my $filename = shift;

    $title = substr($title, 0, 128);
    $author = substr($author, 0, 128);
    $filename = substr($filename, 0, 128);

    # Do we already have the book?
    my $sth = $dbh->prepare("SELECT idbook FROM book WHERE idbook = ?");
    $sth->execute($idbook);
    $sth->bind_columns(\$idbook);
    if ($sth->fetch())
    {
        # We already have this book, remove it from the database.
        $sth = $dbh->prepare("DELETE FROM word WHERE idbook = ?");
        $sth->execute($idbook);
        $sth = $dbh->prepare("DELETE FROM book WHERE idbook = ?");
        $sth->execute($idbook);
    }

    $sth = $dbh->prepare("INSERT INTO book (idbook, title, author, file) VALUES (?, ?, ?, ?)");
    $sth->execute($idbook, $title, $author, $filename);
}


