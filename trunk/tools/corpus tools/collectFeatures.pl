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

$maximumProximityDistance = 5;	# [10]  Size of context within which words are considered to be close to each other.
$minimumCount = 10;				# [10]  Minimum number of times a feature needs to be present to be considered significant.
$minimumSignificance = 0.1;		# [0.1] Minimum value for | P(word) - P(word | feature) | for feature to be considered relevant.
$version = "0.1 alpha";

# End of configurable parameters

main();



sub main
{

	$accLetter = "(\\&[A-Za-z](acute|grave|circ|uml|cedil|tilde|slash|ring|dotb|macr|breve);)";
	$ligLetter = "(\\&[A-Za-z]{2}lig;)";
	$specLetter = "(\\&apos;|\\&eth;|\\&ETH;|\\&thorn;|\\&THORN;|\\&alif;|\\&ayn;|\\&prime;)";
	$letter = "(\\w|$accLetter|$ligLetter|$specLetter)";
	$wordPattern = "($letter)+(([-']|&rsquo;|&apos;)($letter)+)*";
	$nonLetter = "\\&(amp|ldquo|rdquo|lsquo|mdash|hellips|gt|lt|frac[0-9][0-9]);";


	%wordHash = ();
	%wordFiles = ();
	%dictHash = ();         # dictionary of valid words
	%confusableHash = ();   # set of confusable words
	%pairHash = ();         # proximity pairs (co-occurance of words)
	%patternHash = ();      # patterns
	%partsOfSpeechHash = (); # part-of-speech information 

	%wordProbabilityHash = ();

	$inputDir = $ARGV[0];
	$totalFeatureCount = 0;

	print STDERR "Loading dictionaries\n";

	loadDictionary();
	loadConfusables();
	loadPartsOfSpeech();

	print STDERR "Collecting words from directory $inputDir\n";

	listRecursively($inputDir);

	printf ("S\t%s\tVersion\n", $version);
	printf ("S\t%s\tMaximum Proximity Distance\n", $maximumProximityDistance);
	printf ("S\t%s\tMinimum Count\n", $minimumCount);
	printf ("S\t%s\tMinimum Significance\n", $minimumSignificance);

	report();

	print STDERR "$totalFeatureCount features in total\n";

	printf ("X\t%s\tFeatures Counted\n", $totalFeatureCount);
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

        # We are interested in what is likely Dutch.
        if ($language eq "nl" || $language eq "af")
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
    $patternHash{$pattern}++;
    $totalFeatureCount++;

    my $p1 = mapPartOfSpeech($w1);
    my $p2 = mapPartOfSpeech($w2);

    my $ppattern = "$word $p1 $p2";

	if ($pattern ne $ppattern) 
	{
	    $patternHash{$ppattern}++;
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
    $totalFeatureCount++;

    my $p1 = mapPartOfSpeech($w1);
    my $p2 = mapPartOfSpeech($w2);
    my $p3 = mapPartOfSpeech($w3);

    my $ppattern = "$word $p1 $p2 $p3";
	
	if ($pattern ne $ppattern) 
	{
	    $patternHash{$ppattern}++;
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
        $pairHash{"$firstWord $secondWord"}++;
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

	reportWords();
	reportPatterns();
	reportPairs();
}


#
# reportWords
#
# Report the number of occurences and relative frequences of words in the confusion sets.
#
sub reportWords
{
    my @wordList = keys %wordHash;
    @wordList = sort @wordList;
    foreach my $word (@wordList)
    {
        my $count = $wordHash{$word};
        if ($count >= $minimumCount) 
        {
			# find total for confusion set this word is in.
			# Once we have a significant number of words of one of the set members, we are interested in all.
			my $total = 0;
			my $set = $confusableSetHash{$word};
			my @words = split(/, */, $set);
			foreach (@words) 
			{
				$total += $wordHash{$_};
			}

			foreach (@words) 
			{
				my $count = $wordHash{$_};
				if (defined $count) 
				{
					my $fraction = $count / $total;
					# print "W:\t$_\t$count\t$total\t$fraction\n";	
					printf ("W\t%s\t%s\t%.3f\t%s\n", $count, $total, $fraction, $_);
					$wordHash{$_} = -$count; # Indicate we have reported this word.
				}
			}
        }
    }

	foreach (@words) 
	{
		if ($wordHash{$_} < 0) 
		{
			$wordHash{$_} = -$wordHash{$_}; # counted everything; need information later.
		}
	}
}


#
# reportPairs
#
# Report the number of occurences and relative frequences of significant proximity pairs.
#
sub reportPairs
{
    my @pairList = keys %pairHash;
    @pairList = sort @pairList;
    foreach my $pair (@pairList)
    {
        my $count = $pairHash{$pair};
        if ($count >= $minimumCount) 
        {
			my ($word, $other) = split(/ /, $pair);
			my $countWord = $wordHash{$word};

			# find totals for confusion set this word is in.
			my $total = 0;
			my $totalWord = 0;
			my $set = $confusableSetHash{$word};
			my @words = split(/, */, $set);
			foreach (@words) 
			{
				$total += $pairHash{$_ . " " . $other};
				$totalWord += $wordHash{$_};
			}

			foreach (@words) 
			{
				my $pair = $_ . " " . $other;
				my $count = $pairHash{$pair};
				if (defined $count)
				{
					my $fraction = $count / $total;

					# calculate significance of this information: | Pr($word) - Pr($word | $pair) |
					# we are not interest in pairs that have no significance (no discriminatory ability)
					my $wordFraction = $wordHash{$_} / ($totalWord);
					my $significance = abs ($wordFraction - $fraction);
					
					if ($significance > $minimumSignificance) 
					{
						# print "C:\t$pair\t$count\t$total\t$fraction\t$significance\n";
						printf ("C\t%s\t%s\t%.3f\t%.3f\t%s\n", $count, $total, $fraction, $significance, $pair);
					}
					$pairHash{$pair} = -$count; # Indicate we have reported this pair.
				}
			}
        }
    }

	# Done with pairHash, cleanup.
	%pairHash = ();
}


#
# reportPatterns
#
# Report the number of occurences and relative frequences of significant patterns.
#
sub reportPatterns
{
    my @patternList = keys %patternHash;
    @patternList = sort @patternList;
    foreach my $pattern (@patternList)
    {
        my $count = $patternHash{$pattern};
        if ($count >= $minimumCount) 
        {
			$pattern =~ /^(.*?) (.*)$/;
			my $word = $1;
			my $tail = $2;

			my $countWord = $wordHash{$word};

			# find totals for confusion set this word is in.
			my $total = 0;
			my $totalWord = 0;
			my $set = $confusableSetHash{$word};
			my @words = split(/, */, $set);
			foreach (@words) 
			{
				$total += $patternHash{$_ . " " . $tail};
				$totalWord += $wordHash{$_};
			}

			foreach (@words) 
			{
				my $pattern = $_ . " " . $tail;
				my $count = $patternHash{$pattern};
				if (defined $count)
				{
					my $fraction = $count / $total;

					# calculate significance of this information: | Pr($word) - Pr($word | $pattern) |
					# we are not interest in pairs that have no significance (no discriminatory ability)
					my $wordFraction = $wordHash{$_} / ($totalWord);
					my $significance = abs ($wordFraction - $fraction);
					
					if ($significance > $minimumSignificance) 
					{ 
						# print "P:\t$pattern\t$count\t$total\t$fraction\t$significance\n";			
						printf ("P\t%s\t%s\t%.3f\t%.3f\t%s\n", $count, $total, $fraction, $significance, $pattern);
					}
					$patternHash{$pair} = -$count; # Indicate we have reported this pair.
				}
			}
        }
    }

	# Done with patternHash, cleanup.
	%patternHash = ();
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
    my $confusableFile = "confusables.txt";
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
#	line	- The line in the source database this information is based on (ignored)	
#	tag		- The POS-tag determined for this word
#	rule	- The rule the tagging software used to determine the POS-tag. (ignored)
#	word	- The word-form thus tagged.
#	word2	- Only used when the original data contained an cross reference (ignored)
#
sub loadPartsOfSpeech
{
    my $partsOfSpeechFile = "partsofspeech.txt";
    if (!open(PARTSOFSPEECHFILE, "<:utf8", $partsOfSpeechFile))
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