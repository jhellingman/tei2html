# collectWords.pl -- a tool to collect words from a large corpus of texts.

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
%dictHash = ();


$inputDir		= $ARGV[0];
$minWordCount   = $ARGV[1];
$minFileCount   = $ARGV[2];

$totalWordCount = 0;

print STDERR "Loading dictionary\n";

load_dictionary();

print STDERR "Collecting words from directory $inputDir\n";

list_recursively($inputDir);

report_words();

print STDERR ">>> Total: $totalWordCount words.\n";

exit;



# list_recursively
#
#   list the contents of a directory,
#   recursively listing the contents of any subdirectories

sub list_recursively 
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
				handle_file("$directory/$file");
			}
        
        }
		elsif (-d "$directory/$file") 
		{
            list_recursively("$directory/$file");
        }
    }
}






sub handle_file
{
	my $infile = shift;
	open (INPUTFILE, $infile) || die("Could not open input file $infile");
    binmode(INPUTFILE, ":encoding(latin-1)");

	print STDERR "Now processing $infile\n";

	%wordFileHash = ();
	my $wordCount = 0;
	my $newWordCount = 0;
	my $uniqueWordCount = 0;

	my $language = "nl";

	while (<INPUTFILE>)
	{
		$remainder = $_;
		$remainder =~ s/<(.*?)>/ /g;	# Drop SGML/HTML tags
		$remainder =~ s/\s+/ /g;		# normalize space
		$remainder =~ s/^\s+//;
		$remainder =~ s/\s+$//;

		$remainder = sgml2utf($remainder);
		if (length($remainder) > 100)
		{
			my ($l, $p) = langof($remainder);
			if ($l && $p > 0.15) 
			{
				$language = $l;
			}
		}

		# We are interested in what is likely Dutch.
		if ($language eq "nl" || $language eq "af") 
		{
			# NOTE: we don't use \w and \W here, since it gives some unexpected results
			my @words = split(/[^\pL\pN\pM-]+/, $remainder);

			foreach $word (@words)
			{
				$wordCount++;
				$totalWordCount++;

				# print "$language, $word\n";

				$lcword = lc($word);
				$tcword = dutch_titlecase($word);

				if ($word !~ /^[0-9-]*$/)
				{
					if (exists $wordHash{$lcword} || $lcword eq $word)
					{
						$word = $lcword;
						# already counted in title-case?
						if (exists $wordHash{$tcword})
						{
							$wordHash{$word} += $wordHash{$tcword};
							delete $wordHash{$tcword};
						}
						if (exists $wordFileHash{$tcword})
						{
							$wordFiles{$word} += $wordFiles{$tcword};
							delete $wordFiles{$tcword};
							delete $wordFileHash{$tcword};
						}
					}
					else
					{
						$word = $tcword;
					}
					
					if (!exists $wordHash{$word}) 
					{
						$newWordCount++;
					}

					$wordHash{$word}++;

					if (!exists $wordFileHash{$word})
					{
						$wordFileHash{$word} = 1;
						$wordFiles{$word}++;
						$uniqueWordCount++;
					}
				}
			}
		}
	}
	close INPUTFILE;

	print STDERR ">>> $wordCount words; $uniqueWordCount unique; $newWordCount new.\n";
}



sub report_words
{
	my @wordList = keys %wordHash;
	my %newHash = ();

	# Prepend sortkey with dashes, diacritics, and spaces removed.
	foreach $word (@wordList)
	{
		my $sortKey = normalize_dutch_word($word);
		$sortKey =~ s/(-|\s*)//g;
		$word = "$sortKey#$word";
	}

	# print "$minWordCount $minFileCount";

	@wordList = sort {lc($a) cmp lc($b)} @wordList;
	foreach $word (@wordList)
	{
		$word =~ /\#/;
		$word = $';

		$modernWord = lookup_modern($word);
		if ($modernWord || (($wordHash{$word} >= $minWordCount) && ($wordFiles{$word} >= $minFileCount)))
		{
			if ($modernWord ne $word) 
			{
				print "$word\t$wordHash{$word}\t$wordFiles{$word}\t$modernWord\n";
			}
		}
	}
}


sub dutch_titlecase
{
	my $word = shift;
	$word = ucfirst(lc($word));
	$word =~ s/^Ij/IJ/;
	return $word;
}


sub load_dictionary
{
	open(DICTFILE, "C:\\bin\\dic\\nl.dic") || die "Could not open C:\\bin\\dic\\nl.dic";

	%dictHash = ();
	while (<DICTFILE>)
	{
		my $word =  $_;
		$word =~ s/\n//g;
		my $normword = normalize_dutch_word($word);

		if (exists $dictHash{$normword}) 
		{
			$dictHash{$normword} .= "; $word"
		}
		else
		{
			$dictHash{$normword} = "$word";		
		}
	}
	close(DICTFILE);
}


sub normalize_dutch_word_all
{
	my $word = shift;
	$word = strip_diacritics(lc($word));

	# Very old conventions.
	$word =~ s/ck/k/g;									# zulck -> zulk
	$word =~ s/ae/aa/g;									# helaes -> helaas
	$word =~ s/oi/oo/g;									# oirzaeck -> oorzaak
	$word =~ s/gt/cht/g;								# pligt -> plicht
	$word =~ s/gh/ch/g;									# moght -> mocht
	$word =~ s/gch/ch/g;								# ligchaam -> lichaam
	$word =~ s/ey/ei/g;									# Leyden -> Leiden
	$word =~ s/aaije/aaie/g;							# draaijen -> draaien
	$word =~ s/oeije/oeie/g;							# loeijen -> loeien
	$word =~ s/uije/uie/g;								# kruijen -> kruien
	$word =~ s/aa([bcdfghklmnprst])([aeiou])/a\1\2/g;	# klaagen -> klagen
	$word =~ s/aau/au/g;								# praauw -> prauw

	# Modernisms
	$word =~ s/lik$/lijk/g;								# mogelik -> mogelijk
	$word =~ s/ies$/isch/g;								# geologies -> geologisch
	$word =~ s/ij/y/g;									# zijn -> zyn

	# Spelling De Vries-Te Winkel
	$word =~ s/oo([bcdfghklmnprst])([aeiou])/o\1\2/g;	# rooken -> roken
	$word =~ s/ee([bcdfghklmnprst])([aeiou])/e\1\2/g;	# leenen -> lenen
	$word =~ s/\Bsch/s/g;								# mensch -> mens
	$word =~ s/ph/f/g;									# photographie -> fotografie
	$word =~ s/oeie/oei/g;								# moeielijk -> moeilijk
	$word =~ s/qu/kw/g;									# questie -> kwestie

	# Phonetic equivalences.
	$word =~ s/ch/g/;
	$word =~ s/c([iey])/s\1/g;	
	$word =~ s/c/k/g;

	return $word;
}


sub normalize_dutch_word
{
	my $word = shift;
	$word = strip_diacritics(lc($word));

	# Spelling De Vries-Te Winkel
	$word =~ s/oo([bcdfghklmnprst])([aeiou])/o\1\2/g;	# rooken -> roken
	$word =~ s/ee([bcdfghklmnprst])([aeiou])/e\1\2/g;	# leenen -> lenen
	$word =~ s/\Bsch/s/g;								# mensch -> mens
	$word =~ s/ph/f/g;									# photographie -> fotografie
	$word =~ s/oeie/oei/g;								# moeielijk -> moeilijk
	$word =~ s/qu/kw/g;									# questie -> kwestie

	return $word;
}


sub lookup_modern
{
	my $word = shift;
	return $dictHash{normalize_dutch_word($word)}
}


sub strip_diacritics
{
	my $string = shift;

	for ($string) 
	{
		$_ = NFD($_);		##  decompose (Unicode Normalization Form D)
		s/\pM//g;			##  strip combining characters

		# additional normalizations:
		s/\x{00df}/ss/g;	##  German eszet “ß” -> “ss”
		s/\x{00c6}/AE/g;	##  Æ
		s/\x{00e6}/ae/g;	##  æ
		s/\x{0132}/IJ/g;	##  Dutch IJ
		s/\x{0133}/ij/g;	##  Dutch ij
		s/\x{0152}/Oe/g;	##  Œ
		s/\x{0153}/oe/g;	##  œ

		tr/\x{00d0}\x{0110}\x{00f0}\x{0111}\x{0126}\x{0127}/DDddHh/; # ÐÐðdHh
		tr/\x{0131}\x{0138}\x{013f}\x{0141}\x{0140}\x{0142}/ikLLll/; # i??L?l
		tr/\x{014a}\x{0149}\x{014b}\x{00d8}\x{00f8}\x{017f}/NnnOos/; # ???Øø?
		tr/\x{00de}\x{0166}\x{00fe}\x{0167}/TTtt/;                   # ÞTþt
	}
	return $string;
}
