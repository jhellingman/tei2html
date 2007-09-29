# ucwords.pl -- Unicode based perl script for words

use utf8;
binmode(STDOUT, ":utf8");
use open ':utf8';

require Encode;
use Unicode::Normalize;

use Roman;		# Roman.pm version 1.1 by OZAWA Sakuro <ozawa@aisoft.co.jp>

use SgmlSupport qw/getAttrVal sgml2utf/;
use LanguageNames qw/getLanguage/;



###############################################################################

sub StripDiacritics
{
	my $str = shift;

	for ($str)
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
	return $str;
}

sub Normalize
{
	my $string = shift;
	$string =~ s/-//g;
	$string = lc(StripDiacritics($string));
	return $string;
}

#==============================================================================

$infile = $ARGV[0];
open(INPUTFILE, $infile) || die("ERROR: Could not open input file $infile");

%wordHash = ();
%nonWordHash = ();
%charHash = ();
%langHash = ();
%tagHash = ();
%rendHash = ();
@pageList = ();
$pageCount = 0;



$wordCount = 0;
$nonWordCount = 0;
$charCount = 0;
$uniqCount = 0;
$nonCount = 0;
$varCount = 0;
$langCount = 0;
$langStackSize = 0;

$tagPattern = "<(.*?)>";


# Phase 1: Collect words.

while (<INPUTFILE>)
{
	$remainder = $_;
	while ($remainder =~ /$tagPattern/)
	{
		$fragment = $`;
		$tag = $1;
		$remainder = $';
		handleFragment($fragment);
		handleTag($tag);
	}
	handleFragment($remainder);
}


# Phase 2: Sort list
@wordList = keys %wordHash;

foreach $word (@wordList)
{
	($lang, $word) = split(/!/, $word, 2);
	$key = Normalize($word);
	$word = "$lang!$key!$word";
}

@wordList = sort @wordList;


# Phase 3: Report

print "<HTML>";
print "<head><title>Word Usage Report for $infile</title>";
print "<style>\n";
print "body { margin-left: 30px; }\n";
print "p { margin: 0px; }\n";
print ".cnt { color: gray; font-size: smaller; }\n";
print ".err { color: red; font-weight: bold; }\n";
print ".comp { color: green; font-weight: bold; }\n";
print ".comp3 { color: green; }\n";
print ".unk { color: blue; font-weight: bold; }\n";
print ".unk10 { color: blue; }\n";
print ".freq { color: gray; }\n";
print "</style>\n";
print "<head><body>";

#### Report page sequence

print "<h1>Page Number Sequence</h1>";
print "<p>This document contains $pageCount pages.";
print "<p>Sequence: ";

printSequence();


#### Report on word usage

print "<h1>Word Usage Report for $infile</h1>";


open (OUTPUTFILE, ">suggestions-for-dictionary.txt") || die("Could not create output file 'suggestion-for-dictionary.txt'");


$prevLang = "";
$prevWord = "";
$prevKey  = "";
$prevLetter = "";

$uniqWords = 0;
$totalWords = 0;
$unknownTotalWords = 0;
$unknownUniqWords = 0;

foreach $item (@wordList)
{
	($lang, $key, $word) = split(/!/, $item, 3);
	$letter = lc(substr($key, 0, 1));
	$count = $wordHash{$lang . "!" . $word};

	if ($lang ne $prevLang)
	{
		if ($totalWords != 0) 
		{
			print "<h3>Statistics</h3>";
			$percentage =  sprintf("%.2f", 100 * ($unknownTotalWords / $totalWords));
			print "<p>Total words: $totalWords, of which unknown: $unknownTotalWords [$percentage%]";
			$percentage =  sprintf("%.2f", 100 * ($unknownUniqWords / $uniqWords));
			print "<p>Unique words: $uniqWords, of which unknown: $unknownUniqWords [$percentage%]";
		}

		$uniqWords = 0;
		$totalWords = 0;
		$unknownTotalWords = 0;
		$unknownUniqWords = 0;

		# print STDERR "DEBUG: Change of language: $item\n";
		print "<h2>Word frequencies in " . getLanguage(lc($lang)) . "</h2>\n";
		print OUTPUTFILE "\n\n" . getLanguage(lc($lang)) . "\n\n";
		$prevLang = $lang;
		loadDict($lang);	
	}

	$uniqWords++;
	$totalWords += $count;

	if ($key ne $prevKey)
	{
		print "\n<p>";
		$prevKey = $key;
	}

	if ($letter ne $prevLetter)
	{
		print "<h3>" . uc($letter) . "</h3>\n";
		$prevLetter = $letter;
	}

	$known = isKnownWord($word);
	if ($known == 0) 
	{
		$compoundWord = compoundWord($word);
		$unknownUniqWords++;
		$unknownTotalWords += $count;
	}

	if ($known == 0)
	{
		if ($count > 2) 
		{
			print OUTPUTFILE "$word\n";
		}

		if ($compoundWord ne "") 
		{
			if ($count < 3) 
			{
				print "<span class=comp>$compoundWord</span> <span class=cnt>$count</span> ";
			}
			else
			{
				print "<span class=comp3>$compoundWord</span> <span class=cnt>$count</span> ";
			}
		}
		elsif ($count < 3)
		{
			print "<span class=err>$word</span> <span class=cnt>$count</span> ";
		}
		elsif ($count < 6)
		{
			print "<span class=unk>$word</span> <span class=cnt>$count</span> ";
		}
		else
		{
			print "<span class=unk10>$word</span> <span class=cnt>$count</span> ";
		}
	}
	else
	{
		if ($count < 3)
		{
			print "$word <span class=cnt>$count</span> ";
		}
		else
		{
			print "<span class=freq>$word</span> <span class=cnt>$count</span> ";
		}
	}
}

if ($totalWords != 0) 
{
	print "<h3>Statistics</h3>";
	$percentage =  sprintf("%.2f", 100 * ($unknownTotalWords / $totalWords));
	print "<p>Total words: $totalWords, of which unknown: $unknownTotalWords [$percentage%]";
	$percentage =  sprintf("%.2f", 100 * ($unknownUniqWords / $uniqWords));
	print "<p>Unique words: $uniqWords, of which unknown: $unknownUniqWords [$percentage%]";
}



sub compoundWord()
{
	my $word = shift;
	my $start = 4;
	my $end = length($word) - 3;

	# print STDERR "\n$word $end";
	for (my $i = $start; $i < $end; $i++) 
	{
		$before = substr($word, 0, $i);
		$after = substr($word, $i);
		if (isKnownWord($before) == 1 && isKnownWord(ucfirst($after)) == 1)
		{
			# print STDERR "[$before|$after] ";
			return "$before|$after";
		}
	}
	return "";
}


sub isKnownWord()
{
	my $word = shift;
	
	if ($dictHash{lc($word)} != 1)
	{
		if ($dictHash{$word} != 1)
		{
			return 0;
		}
	}
	return 1;
}


#### Report on non-words

@nonWordList = keys %nonWordHash;
print "<h2>Frequencies of Non-Words</h2>\n";
@nonWordList = sort @nonWordList;

print "<table>\n";
print "<tr><th>Sequence<th>Length<th>Count\n";
foreach $item (@nonWordList)
{
	$item =~ s/\0/[NULL]/g;

	if ($item ne "")
	{
		$count = $nonWordHash{$item};
		$length = length($item);
		$item =~ s/ /\&nbsp;/g;
		print "<tr><td>|$item| <td align=right><small>$length</small>&nbsp;&nbsp;&nbsp;<td align=right>$count";
	}
}
print "</table>\n";



#### Report Character usage

@charList = keys %charHash;
print "<h2>Character Frequencies</h2>\n";
@charList = sort @charList;

print "<table>\n";
print "<tr><th>Character<th>Code<th>Count\n";
foreach $char (@charList)
{
	$char =~ s/\0/[NULL]/g;

	$count = $charHash{$char};
	$ord = ord($char);
	print "<tr><td>$char<td align=right><small>$ord</small>&nbsp;&nbsp;&nbsp;<td align=right><b>$count</b>\n";
}
print "</table>\n";



#### Report tags usage

@tagList = keys %tagHash;
print "<h2>XML-Tag Frequencies</h2>\n";
@tagList = sort { lc($a) cmp lc($b) } @tagList;

print "<table>\n";
print "<tr><th>Tag<th>Count\n";
foreach $tag (@tagList)
{
	$count = $tagHash{$tag};
	print "<tr><td><code>$tag</code><td align=right><b>$count</b>\n";
}
print "</table>\n";


#### Report rend usage

@rendList = keys %rendHash;
print "<h2>Rendering Attribute Frequencies</h2>\n";
@rendList = sort { lc($a) cmp lc($b) } @rendList;

print "<table>\n";
print "<tr><th>Rendering<th>Count\n";
foreach $rend (@rendList)
{
	$count = $rendHash{$rend};
	print "<tr><td><code>$rend</code><td align=right><b>$count</b>\n";
}
print "</table>\n";

print "</body></html>";




#
# handleTag: push/pop an XML tag on the tag-stack.
#
sub handleTag
{
	my $tag = shift;

	# end tag or start tag?
	if ($tag =~ /^!/)
	{
		# Comment, don't care.
	}
	elsif ($tag =~ /^\/([a-zA-Z0-9_.-]+)/)
	{
		my $element = $1;
		popLang($element);
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
sub handleFragment
{
	my $fragment = shift;
	$fragment = sgml2utf($fragment);

	my $lang = getLang();

	# NOTE: we don't use \w and \W here, since it gives some unexpected results
	my @words = split(/[^\pL\pN\pM-]+/, $fragment);
	my @nonWords = split(/[\pL\pN\pM-]+/, $fragment);
	my @chars = split(//, $fragment);

	foreach $word (@words)
	{
		if ($word !~ /^[0-9]+$/ && $word ne "")
		{
			$wordHash{$lang . "!" . $word}++;
			$wordCount++;
		}
	}

	foreach $nonWord (@nonWords)
	{
		$nonWordHash{$nonWord}++;
		$nonWordCount++;
	}

	foreach $char (@chars)
	{
		$charHash{$char}++;
		$charCount++;
	}
}

#==============================================================================
#
# popLang: pop from the tag-stack when a tag is closed.
#
sub popLang
{
	my $tag = shift;

	if ($langStackSize > 0 && $tag eq $stackTag[$langStackSize])
	{
		$langStackSize--;
	}
	else
	{
		die("ERROR: XML not well-formed");
	}
}

#
# pushLang: push on the tag-stack when a tag is opened
#
sub pushLang
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
sub getLang
{
	return $stackLang[$langStackSize];
}


#==============================================================================
#
# loadDict: load a dictionary for a language;
#
sub loadDict
{
	my $lang = shift;

	if (!openDictionary("$lang.dic"))
	{
		$lang =~ /-/;
		$shortlang = $`;
		if ($shortlang eq "" || !openDictionary("$shortlang.dic"))
		{
			print STDERR "WARNING: Could not open dictionary for " . getLanguage($lang) . "\n";
			%dictHash = ();
			return;
		}
	}

	%dictHash = ();
	my $count = 0;
	while (<DICTFILE>)
	{
		my $dictword =  $_;
		$dictword =~ s/\n//g;
		$dictHash{$dictword} = 1;
		$count++;
	}
	print STDERR "NOTICE:  Loaded dictionary for " . getLanguage($lang) . " with $count words\n";
	close(DICTFILE);

	loadCustomDictionary($lang);
}


sub loadCustomDictionary
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
			$dictHash{$dictword} = 1;
			$count++;
		}
		print STDERR "NOTICE:  Loaded custom dictionary for " . getLanguage($lang) . " with $count words\n";

		close(DICTFILE);
	}
	else
	{
		print STDERR "WARNING: Could not open custom dictionary $file\n";
	}
}


sub openDictionary
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



#==============================================================================

sub printSequence
{
	my $pStart = "SENTINEL";
	my $pPrevious = "SENTINEL";
	my $comma = "";
	foreach $pCurrent (@pageList)
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


sub isInSequence
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
