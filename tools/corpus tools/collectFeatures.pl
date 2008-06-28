# collectFeatures.pl -- Collect Features that help to identify common mistakes in texts.
#
# This tool collects features that help discriminate easily confused or mixed up words (words in a confusion set),
# The confusion may have a number of causes. The direct inspiration for this tool is to detect
# words mis-recognized by OCR software. Eexamples are {he, be} or {cat, eat}, where very similar letters
# are mis-recognized, leading to another valid word. Such confusions are not detected by a standard spell
# check.
#
# The same mechanism can be used to detect common typing errors, such as {form, from}, confused spellings
# such as {peace, piece}, and even confused semantics, such as {which, that}.
#
# This tool should be run over a large corpus of text in the relevant language. This corpus is assumed
# to be in HTML format (such as harvested from the internet).
#
# This tool assumes that confusion sets are already defined. Other tools will be required to construct
# potential confusion sets, using for example the fact that certain letters or letter groups are easily confused
# by OCR software: {c, e}, {h, b}, {rn, m}, {ni, m}, {in, m}, etc.


# use strict;
# use warnings;

use utf8;
binmode(STDOUT, ":utf8");
use open ':utf8';

require Encode;
use Unicode::Normalize;

use Lingua::Identify qw/langof/;

use SgmlSupport qw/getAttrVal sgml2utf/;
use LanguageNames qw/getLanguage/;

# Configurable parameters

$maximumProximityDistance = 10; # [10]  Size of context within which words are considered to be close to each other.
$minimumCount = 10;             # [10]  Minimum number of times a feature needs to be present to be considered significant.
$minimumSignificance = 0.1;     # [0.1] Minimum value for | P(word) - P(word | feature) | for feature to be considered relevant.
$languagePattern = "(nl)|(af)";


$version = "0.1 alpha";
$confusableFile = "confusables.txt";

# End of configurable parameters

# test();
main();



sub main
{
    %dictHash = ();             # dictionary of valid words
    %partsOfSpeechHash = ();    # part-of-speech information

    %confusableHash = ();       # set of confusable words

    %wordHash = ();
    %patternHoH = ();           # pattern hash of hashes
    %pairHoH = ();              # proximity pair hash of hashes

    my $argumentCount = 0;
    if ($ARGV[$argumentCount] eq "-c")
    {
        $confusableFile = $ARGV[$argumentCount + 1];
        $argumentCount += 2;
    }

    $inputDir = $ARGV[$argumentCount];
    $totalFeatureCount = 0;

    print STDERR "Loading dictionaries\n";

    loadDictionary();
    loadConfusables();
    loadPartsOfSpeech();

    print STDERR "Collecting words from directory $inputDir\n";

    listRecursively($inputDir);

    printf ("VER \t%s\n", $version);
    printf ("CONF\t%s\tMaximum Proximity Distance\n", $maximumProximityDistance);
    printf ("CONF\t%s\tMinimum Count\n", $minimumCount);
    printf ("CONF\t%s\tMinimum Significance\n", $minimumSignificance);
    printf ("CONF\t%s\tLanguage Pattern\n", $languagePattern);

    report();

    print STDERR "$totalFeatureCount features in total\n";

    printf ("STAT\t%s\tFeatures Counted\n", $totalFeatureCount);
}


# listRecursively
#
#   list the contents of a directory,
#   recursively listing the contents of any subdirectories
#
sub listRecursively
{
    my ($directory) = @_;
    my @files = (  );

    unless (opendir(DIRECTORY, $directory))
    {
        print "Cannot open directory $directory!\n";
        exit;
    }

    @files = grep (!/^\.\.?$/, readdir(DIRECTORY));

    closedir(DIRECTORY);

    foreach my $file (@files)
    {
        if (-f "$directory/$file")
        {
            if ($file =~ /\.html?$/)
            {
                handleFile("$directory/$file");
            }

        }
        elsif (-d "$directory/$file")
        {
            listRecursively("$directory/$file");
        }
    }
}


#
# handleFile
#
sub handleFile
{
    my $infile = shift;
    open (INPUTFILE, $infile) || die("Could not open input file $infile");
    binmode(INPUTFILE, ":encoding(latin-1)");

    $pairCount = 0;

    my $language = "nl";
    my $prevWord = "";
    while (<INPUTFILE>)
    {
        my $line = $_;
        # $line =~ s/<(p|br|td|li|h[0-7]|div)\b(.*?)>/~~~~~~/g; # Identify segment borders
        $line =~ s/<(.*?)>/ /g; # Drop remaining SGML/HTML tags
        $line =~ s/\s+/ /g;     # normalize space
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;

        $line = sgml2utf($line);

        # Establish language.
        if (length($line) > 100)
        {
            my ($l, $p) = langof($line);
            if ($l && $p > 0.15)
            {
                $language = $l;
            }
        }

        # We are interested in languages that match our pattern
        if ($language =~ /$languagePattern/)
        {
            # NOTE: we don't use \w and \W here, since it gives some unexpected results
            my @words = split(/[^\pL\pN\pM-]+/, $line);

            # count words in the neighbourhood
            my $size = @words;
            for (my $i = 0; $i < $size; $i++)
            {
                my $word = $words[$i];

                # if word in confusion set
                if (isConfusable($word))
                {
                    countWord($word);

                    for (my $j = -$maximumProximityDistance; $j < $maximumProximityDistance; $j++)
                    {
                        my $position = $i + $j;
                        if ($position > 0 && $position < $size && $position != $i)
                        {
                            countProximityPair($word, $words[$position]);
                        }
                    }
                }
            }

            # Split again, but now keep word separators.
            @words = split(/([^\pL\pN\pM-]+)/, $line);

            # Prune word list to eliminate spaces (we retain punctuation)
            my @filteredWords;
            foreach my $word (@words)
            {
                if ($word !~ /^[\pZ]+$/)
                {
                    $word =~ s/\s+//g;
                    push (@filteredWords, $word);
                }
            }

            my $size = @filteredWords;
            for (my $i = 0; $i < $size; $i++)  # cannot use foreach, as we look ahead.
            {
                my $word = $filteredWords[$i];

                # if word in confusion set
                if (isConfusable($word))
                {
                    $i - 1 > 0                      && countPattern2($word, $filteredWords[$i - 1], "_");
                    $i + 1 < $size                  && countPattern2($word, "_", $filteredWords[$i + 1]);

                    $i - 2 > 0                      && countPattern3($word, $filteredWords[$i - 2], $filteredWords[$i - 1], "_");
                    $i - 1 > 0 && $i + 1 < $size    && countPattern3($word, $filteredWords[$i - 1], "_", $filteredWords[$i + 1]);
                    $i + 2 < $size                  && countPattern3($word, "_", $filteredWords[$i + 1], $filteredWords[$i + 2]);
                }
            }
        }
    }
    close INPUTFILE;

    print STDERR "$pairCount\t$infile\n";
}


#
# isConfusable
#
sub isConfusable
{
    my $word = shift;
    return $confusableHash{$word} == 1;
}


#
# countWord
#
# Count the occurance of a word in the training corpus.
#
sub countWord
{
    my $word = shift;

    $wordHash{"$word"}++;
}

#
# countPattern2
#
# Count the occurance of a two-word pattern in the training corpus.
#
sub countPattern2
{
    my $word = shift;
    my $w1 = shift;
    my $w2 = shift;

    my $pattern = "$word $w1 $w2";
    $patternHoH{$word}{"$w1 $w2"}++;
    $totalFeatureCount++;

    my $p1 = mapPartOfSpeech($w1);
    my $p2 = mapPartOfSpeech($w2);

    my $ppattern = "$word $p1 $p2";

    if ($pattern ne $ppattern)
    {
        $patternHoH{$word}{"$p1 $p2"}++;
    }
}


#
# countPattern3
#
# Count the occurance of a three-word pattern in the training corpus.
#
sub countPattern3
{
    my $word = shift;
    my $w1 = shift;
    my $w2 = shift;
    my $w3 = shift;

    my $pattern = "$word $w1 $w2 $w3";
    $patternHash{$pattern}++;
    $patternHoH{$word}{"$w1 $w2 $w3"}++;
    $totalFeatureCount++;

    my $p1 = mapPartOfSpeech($w1);
    my $p2 = mapPartOfSpeech($w2);
    my $p3 = mapPartOfSpeech($w3);

    my $ppattern = "$word $p1 $p2 $p3";

    if ($pattern ne $ppattern)
    {
        $patternHash{$ppattern}++;
        $patternHoH{$word}{"$p1 $p2 $p3"}++;
    }
}


#
# mapPartOfSpeech
#
# Map a word to its part-of-speech, as recorded in our dictionary.
# A word not present in the dictionary will map to itself.
#
sub mapPartOfSpeech
{
    my $word = shift;

    if (exists $partsOfSpeechHash{$word})
    {
        return "[" . $partsOfSpeechHash{$word} . "]";
    }
    return $word;
}


#
# countProximityPair
#
# Count the occurance of a proximity pair in the training corpus.
#
sub countProximityPair
{
    my $firstWord = shift;
    my $secondWord = shift;

    $pairCount++;

    if (exists $dictHash{$firstWord} && exists $dictHash{$secondWord})
    {
        $totalFeatureCount++;
        $pairHoH{$firstWord}{$secondWord}++;
    }
}


#
# report
#
# Print a report of the collected statistics.
#
sub report
{
    # make STDOUT hot to enable line-based buffering.
    select STDOUT;
    $| = 1;

    reportConfusionSets();
}


#
# reportConfusionSets
#
# Report the confusion sets we have handled.
#
sub reportConfusionSets
{
    my %handled = ();
    my @confusableSetList = keys %confusableSetHash;
    @confusableSetList = sort @confusableSetList;
    foreach my $word (@confusableSetList)
    {
        if (!exists($handled{$word}))
        {
            my $set = $confusableSetHash{$word};
            my $total = 0;

            my @words = split(/, */, $set);
            foreach (@words)
            {
                $total += exists $wordHash{$_} ? $wordHash{$_} : 0;
            }

            if ($total > $minimumCount)
            {
                printf ("\nSET \t%s\n", $set);
                foreach (@words)
                {
                    $handled{$_} = 1;
                    reportWord($_, $total, $set);
                }
            }
        }
    }
}


#
# reportWord
#
sub reportWord
{
    my $word = shift;
    my $total = shift;
    my $set = shift;
    if (exists $wordHash{$word})
    {
        my $count = $wordHash{$word};
        my $fraction = $count / $total;
        printf ("WORD\t%s\t%s\t%.3f\t%s\n", $count, $total, $fraction, $word);

        # report on patterns involving this word
        my @words = split(/, */, $set);

        my $patternHash = $patternHoH{$word};
        my @patternList = keys %$patternHash;
        @patternList = sort @patternList;
        foreach my $pattern (@patternList)
        {
            $patternTotal = 0;
            foreach (@words)
            {
                $patternTotal += exists $patternHoH{$_}{$pattern} ? $patternHoH{$_}{$pattern} : 0;
            }

            if ($patternTotal > $minimumCount)
            {
                if (exists $patternHoH{$word}{$pattern})
                {
                    my $patternCount = $patternHoH{$word}{$pattern};
                    my $patternFraction = $patternCount / $patternTotal;
                    my $patternSignificance = $patternFraction - $fraction;
                    if ($patternSignificance > $minimumSignificance)
                    {
                        printf ("PAT \t%s\t%s\t%.3f\t%.3f\t%s\n", $patternCount, $patternTotal, $patternFraction, $patternSignificance, $pattern);
                    }
                }
            }
        }

        # report on pairs involving this word
        my $pairHash = $pairHoH{$word};
        my @pairList = keys %$pairHash;
        @pairList = sort @pairList;
        foreach my $pair (@pairList)
        {
            $pairTotal = 0;
            foreach (@words)
            {
                $pairTotal += exists $pairHoH{$_}{$pair} ? $pairHoH{$_}{$pair} : 0;
            }

            if ($pairTotal > $minimumCount)
            {
                if (exists $pairHoH{$word}{$pair})
                {
                    my $pairCount = $pairHoH{$word}{$pair};
                    my $pairFraction = $pairCount / $pairTotal;
                    my $pairSignificance = $pairFraction - $fraction;
                    if ($pairSignificance > $minimumSignificance)
                    {
                        printf ("PAIR\t%s\t%s\t%.3f\t%.3f\t%s\n", $pairCount, $pairTotal, $pairFraction, $pairSignificance, $pair);
                    }
                }
            }
        }
    }
}



#
# loadDictionary: load required dictionaries.
#
sub loadDictionary
{
    my $dictFile = "C:\\bin\\dic\\nl-1900.dic";
    if (!open(DICTFILE, "<:utf8", $dictFile))
    {
        print STDERR "Could not open $dictFile";
        exit;
    }

    %dictHash = ();
    while (<DICTFILE>)
    {
        my $word =  $_;
        $word =~ s/\n//g;
        $dictHash{$word} = "$word";
    }
    close(DICTFILE);
}


#
# loadConfusables: load set of confusable words.
#
# The format for this file is simple: each line contains the confusable words, separated by comma's.
#
# For example:
#       he, be
#       modern, modem
#       peace, piece
#
sub loadConfusables
{
    if (!open(CONFUSABLEFILE, "<:encoding(latin1)", $confusableFile))
    {
        print STDERR "Could not open $confusableFile";
        exit;
    }

    %confusableSetHash = ();
    %confusableHash = ();
    while (<CONFUSABLEFILE>)
    {
        my $set =  $_;
        chomp($set);

        my @words = split(/, */, $set);
        foreach my $word (@words)
        {
            $confusableHash{$word} = 1;
            $confusableSetHash{$word} = $set; # TODO: words can be in more than one set! Handle this by appending sets, separated by ;
        }
    }

    close(CONFUSABLEFILE);
}


#
# loadPartsOfSpeech: load the POS-database.
#
# The format is a tab-separated file, with the following fields
#   line    - The line in the source database this information is based on (ignored)
#   tag     - The POS-tag determined for this word
#   rule    - The rule the tagging software used to determine the POS-tag. (ignored)
#   word    - The word-form thus tagged.
#   word2   - Only used when the original data contained an cross reference (ignored)
#
sub loadPartsOfSpeech
{
    my $partsOfSpeechFile = "partsofspeech.txt";
    if (!open(PARTSOFSPEECHFILE, "<:encoding(latin1)", $partsOfSpeechFile))
    {
        print STDERR "Could not open $partsOfSpeechFile";
        exit;
    }

    %partsOfSpeechHash = ();
    while (<PARTSOFSPEECHFILE>)
    {
        my $line =  $_;
        chomp($line);

        my ($n, $tag, $rule, $word, $word2) = split("\t", $line);

        if ($tag ne "XREF" && $tag ne "UNC")
        {
            chomp($word);
            # just interested in first two letters of tag.
            $tag = substr($tag, 0, 2);
            $partsOfSpeechHash{$word} = $tag;
        }
    }

    close(PARTSOFSPEECHFILE);
}


#
# loadFeatures: load the pre-established features database
#
sub loadFeatures
{
    my $featuresFile = "nldb.stats";
    if (!open(FEATURESFILE, "<:encoding(latin1)", $featuresFile))
    {
        print STDERR "Could not open $featuresFile";
        exit;
    }

    while (<FEATURESFILE>)
    {
        my $line =  $_;
        chomp($line);

        my ($code, $count, $total, $frequency, $significance, $feature) = split("\t", $line);

        # TODO
    }

    close(FEATURESFILE);
}



#
# combineProbabilities
#
# combining probabilities, using:  ab / ( ab + (1-a)(1-b)), which is a very simple
# approximation, assuming that all probabilities are independent.
#
sub combineProbabilities
{
    my $product1 = 1;
    my $product2 = 1;
    foreach my $probability (@_)
    {
        $product1 *= $probability;
        $product2 *= (1 - $probability);
    }
    return $product1 / ($product1 + $product2);
}


sub testCombineProbabilities
{
    print combineProbabilities(0.333) . "\n";
    print combineProbabilities(0.25, 0.25) . "\n";
    print combineProbabilities(0.25, 0.25, 0.25) . "\n";
    print combineProbabilities(0.333, 0.333) . "\n";
    print combineProbabilities(0.5, 0.5) . "\n";
    print combineProbabilities(0.5, 0.5, 0.5, 0.5) . "\n";
    print combineProbabilities(0.75, 0.75) . "\n";
    print combineProbabilities(0.9, 0.9, 0.9) . "\n";
}