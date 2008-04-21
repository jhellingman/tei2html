
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


$accLetter = "(\\&[A-Za-z](acute|grave|circ|uml|cedil|tilde|slash|ring|dotb|macr|breve);)";
$ligLetter = "(\\&[A-Za-z]{2}lig;)";
$specLetter = "(\\&apos;|\\&eth;|\\&ETH;|\\&thorn;|\\&THORN;|\\&alif;|\\&ayn;|\\&prime;)";
$letter = "(\\w|$accLetter|$ligLetter|$specLetter)";
$wordPattern = "($letter)+(([-']|&rsquo;|&apos;)($letter)+)*";
$nonLetter = "\\&(amp|ldquo|rdquo|lsquo|mdash|hellips|gt|lt|frac[0-9][0-9]);";


%wordHash = ();
%wordFiles = ();
%dictHash = ();			# dictionary of valid words
%confusableHash = ();	# set of confusable words
%pairHash = ();			# proximity pairs
%patternHash = ();		# patterns


$inputDir       = $ARGV[0];

$totalPairCount = 0;

print STDERR "Loading dictionary\n";

loadDictionary();

print STDERR "Collecting words from directory $inputDir\n";

listRecursively($inputDir);

reportPairs();

print STDERR "$totalPairCount pairs in total\n";
print STDERR "$scannoPairCount scanno pairs\n";

exit;



# listRecursively
#
#   list the contents of a directory,
#   recursively listing the contents of any subdirectories

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
		# $line =~ s/<(p|br|td|li|h[0-7]|div)\b(.*?)>/~~~~~~/g;	# Identify segment borders
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
				if ($word eq 'hij' || $word eq 'bij') 
				{
					countWord($word);

					for (my $j = -10; $j < 10; $j++) 
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
				if ($word eq 'hij' || $word eq 'bij') 
				{
					$i - 1 > 0						&& countPattern2($word, $filteredWords[$i - 1], "_");	
					$i + 1 < $size					&& countPattern2($word, "_", $filteredWords[$i + 1]);	

					$i - 2 > 0						&& countPattern3($word, $filteredWords[$i - 2], $filteredWords[$i - 1], "_");	
					$i - 1 > 0 && $i + 1 < $size	&& countPattern3($word, $filteredWords[$i - 1], "_", $filteredWords[$i + 1]);	
					$i + 2 < $size					&& countPattern3($word, "_", $filteredWords[$i + 1], $filteredWords[$i + 2]);
				}
            }
        }
    }
    close INPUTFILE;

    print STDERR "$pairCount\t$infile\n";
}


#
# countWord
#
sub countWord
{
	my $word = shift;
}

sub countPattern2
{
	my $word = shift;
	my $w1 = shift;
	my $w2 = shift;

	my $pattern = "$word $w1 $w2";
	# print STDERR "PATTERN: $pattern\n";
	$patternHash{"$pattern"}++;
}


sub countPattern3
{
	my $word = shift;
	my $w1 = shift;
	my $w2 = shift;
	my $w3 = shift;

	my $pattern = "$word $w1 $w2 $w3";
	# print STDERR "PATTERN: $pattern\n";
	$patternHash{"$pattern"}++;

	my $p1 = mapPartOfSpeech($w1);
	my $p2 = mapPartOfSpeech($w2);
	my $p3 = mapPartOfSpeech($w3);

	my $ppattern = "$word $p1 $p2 $p3";

}


sub mapPartOfSpeech
{
	my $word = shift;

	if (exists $partOfSpeech{$word}) 
	{
		return $partOfSpeech{$word};
	}
	return $word;
}



#
# countProximityPair
#
sub countProximityPair
{
    my $firstWord = shift;
    my $secondWord = shift;


    $pairCount++;
    $totalPairCount++;

    if (exists $dictHash{$firstWord} && exists $dictHash{$secondWord})
    {
        $scannoPairCount++;
		
		# print STDERR "PAIR:    $firstWord ~ $secondWord\n";

        $pairHash{"$firstWord $secondWord"}++;
    }
}


#
# reportPairs
#
sub reportPairs
{
    my @pairList = keys %pairHash;
    @pairList = sort @pairList;
    foreach my $pair (@pairList)
    {
        my $count = $pairHash{$pair};
		if ($count >= 10) 
		{
			print "$pair\t$count\n";
		}
    }

    my @patternList = keys %patternHash;
    @patternList = sort @patternList;
    foreach my $pattern (@patternList)
    {
        my $count = $patternHash{$pattern};
		if ($count >= 10) 
		{
			print "$pattern\t$count\n";
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
sub loadConfusables
{
    my $confusableFile = "confusables.txt";
    if (!open(CONFUSABLEFILE, "<:encoding(latin1)", $confusableFile))
    {
            print STDERR "Could not open $confusableFile";
            exit;
    }

    %confusableHash = ();
    while (<CONFUSABLEFILE>)
    {
        my $word =  $_;
        $word =~ s/\n//g;
        $confusableHash{$word} = "$word";
    }

    close(CONFUSABLEFILE);
}

