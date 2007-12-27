# kwic.pl -- Unicode based perl script for collecting a keyword in context list

use utf8;
binmode(STDOUT, ":utf8");
use open ':utf8';

require Encode;
use Unicode::Normalize;

use SgmlSupport qw/getAttrVal sgml2utf/;
use LanguageNames qw/getLanguage/;

###############################################################################

sub StripDiacritics
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

sub Normalize
{
	my $string = shift;
	$string =~ s/-//g;
	$string = lc(StripDiacritics($string));
	return $string;
}

#==============================================================================

$infile = $ARGV[0];
$matchOne = $ARGV[1];
$matchTwo = $ARGV[2];
$matchTwo = defined $matchTwo ? $matchTwo : "[SENTINEL]";
open(INPUTFILE, $infile) || die("ERROR: Could not open input file $infile");


@wordList = ();
$wordListSize = 0;

@kwicLineList = ();
$kwicLineCount = 0;

$tagPattern = "<(.*?)>";

# Phase 1: Read file into list of words (and non-words)

while (<INPUTFILE>)
{
	$remainder = $_;

	if ($remainder =~ /<title>(.*?)<\/title>/) 
	{
		$docTitle = $1;
	}
	if ($remainder =~ /<author>(.*?)<\/author>/) 
	{
		$docAuthor = $1;
	}

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

# report out:


print "<HTML>";
print "<head><title>KWIC Report for $docTitle ($infile)</title>";
print "<style>\n";
print "body { margin-left: 30px; }\n";
print ".m1 { color: red; font-weight: bold; }\n";
print ".m2 { color: blue; font-weight: bold; }\n";
print ".p { text-align: right; }\n";
print "</style>\n";
print "<head><body>";


print "<table>\n";


for ($i = 0; $i < $wordListSize; $i++) 
{
	$word = $wordList[$i];
	if (lc $word eq lc $matchOne or lc $word eq lc $matchTwo) 
	{
		my $prefix = getPrefix($i);
		my $postfix = getPostfix($i);

		my $kwicLine = $prefix . ":XYXYX:" . $word . ":XYXYX:" . $postfix;
		$kwicLineList[$kwicLineCount++] = $kwicLine;
	}
}


@sortedKwicLineList = sort byReversedPrefix @kwicLineList;


foreach $kwicLine (@sortedKwicLineList) 
{
	($prefix, $word, $postfix) = split(/:XYXYX:/, $kwicLine, 3);

	if (lc $word eq lc $matchOne)
	{
		print "<tr><td class=p>$prefix <td class=m1>$word <td>$postfix\n";
	}
	else
	{
		print "<tr><td class=p>$prefix <td class=m2>$word <td>$postfix\n";
	}
}



print "</table>\n";
print "</body>\n";


sub byReversedPrefix 
{
	my ($prefixA, $wordA, $postfixA) = split(/:XYXYX:/, $a, 3);
	my ($prefixB, $wordB, $postfixB) = split(/:XYXYX:/, $b, 3);
	my $reverseA = lc reverse $prefixA;
	my $reverseB = lc reverse $prefixB;
	$reverseA cmp $reverseB;
}

sub byPostFix
{
	my ($prefixA, $wordA, $postfixA) = split(/:XYXYX:/, $a, 3);
	my ($prefixB, $wordB, $postfixB) = split(/:XYXYX:/, $b, 3);
	(lc $postfixA) cmp (lc $postfixB);
}

sub getPrefix()
{
	my $index = shift;
	my $i = $index - 1;
	my $length = 0;
	while ($i >= 0 && $length < 40)
	{
		$length += length($wordList[$i]);
		$i--;
	}
	my $result = "";
	while ($i < $index) 
	{
		$result .= $wordList[$i];
		$i++;
	}
	return $result;
}

sub getPostfix()
{
	my $index = shift;
	my $i = $index + 1;
	my $length = 0;
	while ($i < $wordListSize && $length < 40)
	{
		$length += length($wordList[$i]);
		$i++;
	}
	my $result = "";
	while ($index <= $i) 
	{
		$index++;
		$result .= $wordList[$index];
	}
	return $result;
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
	my @words = split(/([^\pL\pN\pM-]+)/, $fragment);

	foreach $word (@words)
	{
		# print "Adding: $word\n";
		@wordList[$wordListSize++] = $word;
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


