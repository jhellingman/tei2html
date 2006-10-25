# words.pl -- create list of words occuring in a text
#
# This script will look at the lang attribute to determine the language of the text, and prepares
# list separated by language.
#
# The implementation is somewhat hacked and could be much better. This is fragile code!
#
# Assumptions:
#    Input is well-formed XML (that is: any open tag is matched with a close tag).
#    Input uses SGML style entities.
#    Dictionary for language xx_XX can be found in C:\bin\dict\xx_XX.dict
#	 Custom dictionary for language xx_XX can be found in C:\bin\dict\custom_xx_XX.dict
#
# Copyright 2003, 2005 Jeroen Hellingman

$argvFile = 0;
$outputHtml = 0;

if ($ARGV[0] eq "-h") 
{
	$outputHtml = 1;
	$argvFile = 1;
}

$infile = $ARGV[$argvFile];
open(INPUTFILE, $infile) || die("Could not open input file $infile");
open(CANDIDATES, "> custom-dictionary-candidates.dic");


# Set global variables

$letter88591 = "[¡·¿‡¬‚ƒ‰√„«Á…È»Ë ÍÀÎÕÌÃÏŒÓœÔ—Ò”Û“Ú‘Ù÷ˆ’ı⁄˙Ÿ˘€˚‹¸›˝ˇ≈Âÿ¯∆Ê–ﬁ˛ﬂ]";

$letterEntity = "(\\&#x00([CE][0-9A-F]|[DF][0-68-9A-F]);)";

$accLetter = "(\\&[A-Za-z](acute|grave|circ|uml|umlb|cedil|tilde|slash|ring|dotb|dot|macr|breve|breveb|caron|comma|barb|dotb|ringb|small);)";
$ligLetter = "(\\&[A-Za-z]{2}(lig|barb|tilde);)";
$specLetter = "(\\&(apos|eth|ETH|thorn|THORN|alif|ayn|prime|longs);)";

$letter = "(\\w|$letter88591|$letterEntity|$accLetter|$ligLetter|$specLetter)";

$wordPattern = "($letter)+(([-']|\\&rsquo;|\\&apos;)($letter)+)*";
$nonLetter = "\\&(amp|ldquo|rdquo|lsquo|ndash|mdash|hellips|gt|lt|frac[0-9][0-9]);";
$tagPattern = "<(.*?)>";


%wordHash = ();
%langHash = ();

%langNameHash = ();
$langNameHash{"ar"}			= "Arabic";
$langNameHash{"ar-latn"}	= "Arabic (Latin transcription)";
$langNameHash{"ceb"}		= "Cebuano";
$langNameHash{"de"}			= "German";
$langNameHash{"en"}			= "English";
$langNameHash{"en-1600"}	= "English (seventeenth century)";
$langNameHash{"en-uk"}		= "English (United Kingdom)";
$langNameHash{"en-us"}		= "English (United States)";
$langNameHash{"es"}			= "Spanish";
$langNameHash{"fi"}			= "Finnish";
$langNameHash{"fr"}			= "French";
$langNameHash{"it"}			= "Italian";
$langNameHash{"pt"}			= "Portuguese";
$langNameHash{"jp-latn"}	= "Japanese (Latin transcription)";
$langNameHash{"la"}			= "Latin";
$langNameHash{"nl"}			= "Dutch";
$langNameHash{"nl-1900"}	= "Dutch (old spelling)";
$langNameHash{"tl"}			= "Tagalog";
$langNameHash{"zh-latn"}	= "Chinese (Latin transcription)";
$langNameHash{"he-latn"}	= "Hebrew (Latin transcription)";

$langNameHash{"xx"}			= "unknown language";
$langNameHash{"und"}		= "undetermined language";





$wordCount = 0;
$uniqCount = 0;
$nonCount = 0;
$varCount = 0;
$langCount = 0;
$langStackSize = 0;

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

# Prepend words with sortkey with dashes, diacritics, and spaces removed.
foreach $word (@wordList)
{
	$sortKey = stripDiacritics($word);
	$sortKey =~ s/(-|\s*)//g;
	$word = "$sortKey#$word";
}

# sort, keep case close together, but make stable by appending cased version.
@wordList = sort {lc($a).$a cmp lc($b).$b} @wordList;


print "<style>\n";
print "p	{ margin: 0px; }\n";
print ".cnt { color: gray; font-size: smaller; }\n";
print ".err { color: red; font-weight: bold; }\n";
print ".unk { color: blue; font-weight: bold; }\n";
print ".unk10 { color: blue; }\n";
print ".freq { color: gray; }\n";
print "</style>\n";


$lang = "";
$prevWord = "";
$prevLetter = "";
foreach $wordx (@wordList)
{
	$word = $wordx;
	$word =~ /\#/;
	$word = $';
	$wordnc = lc($`);
	$langWord = $word;
	$word =~ /::/;
	$word = $';
	$newlang = $`;

	$wordnc =~ /::/;
	$wordnc = $';

	if ($lang ne $newlang)
	{
		print "<h2>Word frequencies in " . $langNameHash{lc($newlang)} . "</h2>\n";
		$lang = $newlang;
		loadDict($lang);
	}
	
	if ($wordnc ne $prevWord) 
	{
		print "\n<p>";
		$prevWord = $wordnc;
	}

	$letter = lc(substr($wordnc, 0, 1));
	if ($letter ne $prevLetter) 
	{
		print "<h3>" . uc($letter) . "</h3>\n";
		$prevLetter = $letter;
	}

	$unknown = 0;
	if ($dictHash{lc($word)} != 1) 
	{
		if ($dictHash{$word} != 1) 
		{
			$unknown = 1;
		}
	}
	if ($unknown == 1) 
	{
		if ($wordHash{$langWord} < 3) 
		{
			print "<span class=err>$word</span> <span class=cnt>$wordHash{$langWord}</span> ";
		}
		elsif ($wordHash{$langWord} < 6) 
		{
			print "<span class=unk>$word</span> <span class=cnt>$wordHash{$langWord}</span> ";
		}
		else
		{
			print "<span class=unk10>$word</span> <span class=cnt>$wordHash{$langWord}</span> ";

			if (length($word) > 2) 
			{
				print CANDIDATES "$word\n";
			}
		}
	}
	else
	{
		if ($wordHash{$langWord} < 3) 
		{
			print "$word <span class=cnt>$wordHash{$langWord}</span> ";
		}
		else
		{
			print "<span class=freq>$word</span> <span class=cnt>$wordHash{$langWord}</span> ";
		}
	}
}


#
# stripDiacritics: create a unaccented version of word for sorting.
#
sub stripDiacritics8859_1
{
	my $in = shift;
	my $result = $in;

	$result =~ s/[¡¿¬ƒ√≈]/A/g;
	$result =~ s/[·‡‚‰„Â]/a/g;
	$result =~ s/[«]/C/g;
	$result =~ s/[Á]/c/g;
	$result =~ s/[…» À]/E/g;
	$result =~ s/[ÈËÍÎ]/e/g;
	$result =~ s/[ÕÃŒœ]/I/g;
	$result =~ s/[ÌÏÓÔ]/i/g;
	$result =~ s/[—]/N/g;
	$result =~ s/[Ò]/n/g;
	$result =~ s/[”“‘÷’ÿ]/O/g;
	$result =~ s/[ÛÚÙˆı¯]/o/g;
	$result =~ s/[⁄Ÿ€‹]/U/g;
	$result =~ s/[˙˘˚¸]/u/g;
	$result =~ s/[›]/Y/g;
	$result =~ s/[˝ˇ]/y/g;
	$result =~ s/[∆]/AE/g;
	$result =~ s/[Ê]/ae/g;
	$result =~ s/[–]/DH/g;
	$result =~ s/[]/dh/g;
	$result =~ s/[ﬁ]/TH/g;
	$result =~ s/[˛]/th/g;
	$result =~ s/[ﬂ]/ss/g;

	return $result;
}

sub stripDiacriticsNumericEntities
{
	my $in = shift;
	my $result = $in;

	$result =~ s/\&#x00C[0-5];/A/g;
	$result =~ s/\&#x00E[0-5];/a/g;
	$result =~ s/\&#x00C7;/C/g;
	$result =~ s/\&#x00E7;/c/g;
	$result =~ s/\&#x00C[89AB];/E/g;
	$result =~ s/\&#x00E[89AB];/e/g;
	$result =~ s/\&#x00C[C-F];/I/g;
	$result =~ s/\&#x00E[C-F];/i/g;
	$result =~ s/\&#x00D1;/N/g;
	$result =~ s/\&#x00F1;/n/g;
	$result =~ s/\&#x00D[2-68];/O/g;
	$result =~ s/\&#x00F[2-68];/o/g;
	$result =~ s/\&#x00D[9ABC];/U/g;
	$result =~ s/\&#x00F[9ABC];/u/g;
	$result =~ s/\&#x00DD;/Y/g;
	$result =~ s/\&#x00F[DF];/y/g;
	$result =~ s/\&#x00C6;/AE/g;
	$result =~ s/\&#x00E6;/ae/g;
	$result =~ s/\&#x00D0;/DH/g;
	$result =~ s/\&#x00F0;/dh/g;
	$result =~ s/\&#x00DE;/TH/g;
	$result =~ s/\&#x00FE;/th/g;
	$result =~ s/\&#x00DF;/ss/g;

	return $result;
}

sub stripDiacritics
{
	my $in = shift;
	my $result = $in;
	$result = stripDiacritics8859_1($result);
	$result = stripDiacriticsNumericEntities($result);

	$result =~ s/\&([A-Za-z])(acute|grave|circ|uml|umlb|cedil|tilde|slash|ring|dotb|dot|macr|breveb|breve|caron|comma|barb|dotb|ringb|small);/$1/g;
	$result =~ s/\&szlig;/ss/g;
	$result =~ s/\&([A-Za-z]{2})(lig|barb|tilde);/$1/g;
	$result =~ s/\&eth;/th/g;
	$result =~ s/\&ETH;/TH/g;
	$result =~ s/\&thorn;/dh/g;
	$result =~ s/\&THORN;/DH/g;
	$result =~ s/\&longs;/s/g;
	$result =~ s/\&(.*?);//g;

	return $result;
}



#
# getAttrVal: Get an attribute value from a tag (if the attribute is present)
#
sub getAttrVal
{
	my $attrName = shift;
	my $attrs = shift;
	my $attrVal = "";

	if ($attrs =~ /$attrName\s*=\s*(\w+)/i)
	{
		$attrVal = $1;
	}
	elsif ($attrs =~ /$attrName\s*=\s*\"(.*?)\"/i)
	{
		$attrVal = $1;
	}
	return $attrVal;
}

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
	elsif ($tag =~ /^\/(.+?\b)/)
	{
		my $element = $1;
		popLang($element);
	}
	elsif ($tag =~ /\/$/)
	{
		# empty element, don't care.
	}
	else
	{
		$tag =~ /^(.+?\b)/;
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
# handleFragment: split a text fragment into words and insert them 
# in the wordlist.
#
sub handleFragment
{
	my $remainder = shift;
	
	while ($remainder =~ /($wordPattern)/)
	{
		my $word = $1;
		$remainder = $';
		if ($word !~ /^[0-9]*$/)
		{
			my $lang = getLang();
			$wordHash{$lang . "::" . $word}++;
			$wordCount++;
		}
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
		die("XML not well-formed");
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

	close(CANDIDATES);
	open(CANDIDATES, "> custom-dictionary-" . $lang . "-candidates.dic");

	# Load dictionary
	if (!open(DICTFILE, "C:\\bin\\dic\\$lang.dic"))
	{
		$lang =~ /-/;
		$shortlang = $`;
		# print "Could not open C:\\bin\\dic\\$lang.dic, trying C:\\bin\\dict\\$shortlang.dic\n\n";
		if (!open(DICTFILE, "C:\\bin\\dic\\$shortlang.dic"))
		{
			if (!open(DICTFILE, "$shortlang.dic")) 
			{
				print "<p>Could not open C:\\bin\\dic\\$shortlang.dic, using empty dictionary\n\n";
				%dictHash = ();
				return;
			}
		}
	}

	%dictHash = ();
	while (<DICTFILE>)
	{
		my $dictword =  $_;
		$dictword =~ s/\n//g;
		$dictHash{$dictword} = 1;		
	}
	close(DICTFILE);

	loadCustomDictionary($lang);
}


sub loadCustomDictionary
{
	my $lang = shift;
	my $file = "custom-$lang.dic";
	if (openDictionary($file)) 
	{
		while (<DICTFILE>)
		{
			my $dictword =  $_;
			$dictword =~ s/\n//g;
			$dictHash{$dictword} = 1;		
		}
		close(DICTFILE);
	}
	else
	{
		print "<p>Could not open custom dictionary $file\n";
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

