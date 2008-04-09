# ucwords.pl -- Unicode based perl script for collecting words from an XML file.


use utf8;
binmode(STDOUT, ":utf8");
use open ':utf8';

require Encode;
use Unicode::Normalize;

use Roman;		# Roman.pm version 1.1 by OZAWA Sakuro <ozawa@aisoft.co.jp>

use SgmlSupport qw/getAttrVal sgml2utf/;
use LanguageNames qw/getLanguage/;


main();


sub main
{
	%wordHash = ();
	%pairHash = ();
	%numberHash = ();
	%nonWordHash = ();
	%scannoHash = ();
	%charHash = ();
	%langHash = ();
	%tagHash = ();
	%rendHash = ();
	%dictHash = ();
	@pageList = ();
	$pageCount = 0;

	$headerWordCount = 0;
	$headerNumberCount = 0;
	$headerCharCount = 0;
	$headerNonWordCount = 0;

	$wordCount = 0;
	$numberCount = 0;
	$nonWordCount = 0;
	$charCount = 0;
	$uniqCount = 0;
	$nonCount = 0;
	$varCount = 0;
	$langCount = 0;
	$langStackSize = 0;

	$tagPattern = "<(.*?)>";

	open (OUTPUTFILE, ">suggestions-for-dictionary.txt") || die("Could not create output file 'suggestion-for-dictionary.txt'");
	open (OUTPUTDATA, ">word-statistics.txt") || die("Could not create output file 'word-statistics.txt'");

	loadScannoFile("en");

	collectWords();

	loadGoodBadWords();

	printReportHeader();
	sortWords();
	reportNumbers();
	reportNonWords();
	reportChars();
	reportTags();
	reportRend();
	reportPages();

	reportStatistics();

	print "\n</body></html>";


	heatMapDocument();

}


#
# heatMapDocument
#
sub heatMapDocument
{
	$infile = $ARGV[0];
	open (INPUTFILE, $infile) || die("ERROR: Could not open input file $infile");
	open (HEATMAPFILE, ">heatmap.xml") || die("Could not create output file 'heatmap.xml'");

	while (<INPUTFILE>)
	{
		$remainder = $_;
		while ($remainder =~ /$tagPattern/)
		{
			$fragment = $`;
			$tag = $1;
			$remainder = $';
			heatMapFragment($fragment);
			heatMapTag($tag);
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
sub heatMapFragment
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
sub heatMapTag
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
sub heatMapNonWord
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
sub heatMapNumber
{
	my $word = shift;

	print HEATMAPFILE $word;
}


#
# heatMapWord
#
sub heatMapWord
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
		if ($count < 2) 
		{
			print HEATMAPFILE "<ab type=\"q5\">$word</ab>";
		}
		elsif ($count < 3) 
		{
			print HEATMAPFILE "<ab type=\"q4\">$word</ab>";
		}
		elsif ($count < 5) 
		{
			print HEATMAPFILE "<ab type=\"q3\">$word</ab>";
		}
		elsif ($count < 8) 
		{
			print HEATMAPFILE "<ab type=\"q2\">$word</ab>";
		}		
		elsif ($count < 100) 
		{
			print HEATMAPFILE "<ab type=\"q1\">$word</ab>";
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
# heatMapScanno
#
sub heatMapScanno
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


sub heatMapPair
{
	# my $word = shift;

	# print HEATMAPFILE $word;
}






#
# collectWords
#
sub collectWords
{
	$infile = $ARGV[0];
	open (INPUTFILE, $infile) || die("ERROR: Could not open input file $infile");

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
		if ($remainder =~ /<\/teiHeader>/) 
		{
			$headerWordCount = $wordCount;
			$headerNumberCount = $numberCount;
			$headerCharCount = $charCount;
			$headerNonWordCount = $nonWordCount;
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

	close (INPUTFILE);
}



#
# sortWords
#
sub sortWords
{
	$grandTotalWords = 0;
	$grandTotalUniqWords = 0;
	$langCount = 0;

	my @languageList = keys %wordHash;
	foreach my $language (@languageList) 
	{
		$langCount++;
		sortLanguageWords($language);
	}
}


#
# sortLanguageWords
#
sub sortLanguageWords
{
	my $language = shift;	
	@wordList = keys %{$wordHash{$language}};

	foreach my $word (@wordList) 
	{
		$key = Normalize($word);
		$word = "$key!$word";
	}
	@wordList = sort @wordList;
	reportWords($language);
	reportLanguagePairs($language);
}


#
# reportPairs
#
sub reportPairs
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
sub reportLanguagePairs
{
	my $language = shift;	
	my @pairList = keys %{$pairHash{$language}};
	@pairList = sort @pairList;

	print "\n\n\n<h3>Most Common Word Pairs in " . getLanguage(lc($language)) . "</h3>\n";

	$max = 0;
	foreach $pair (sort {$pairHash{$language}{$b} <=> $pairHash{$language}{$a} } @pairList)
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
# loadGoodBadWords
#
sub loadGoodBadWords
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
			print STDERR "NOTICE:  Loaded good_words.txt with $count words\n";
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
			print STDERR "NOTICE:  Loaded bad_words.txt with $count words\n";
			close(BADWORDSFILE);
		}
	}
}


#
# printReportHeader
#
sub printReportHeader
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
	print "</style>\n";
	print "\n<head><body>";

	print "\n<h1>Word Usage Report for $docTitle ($infile)</h1>";
}


#
# reportPages
#
sub reportPages
{
	print "\n<h2>Page Number Sequence</h2>";
	print "\n<p>This document contains $pageCount pages.";
	print "\n<p>Sequence: ";

	printSequence();
}


#
# reportWordStatistics
#
sub reportWordStatistics
{
	if ($totalWords != 0) 
	{
		print "\n\n<h3>Statistics</h3>";
		$percentage =  sprintf("%.2f", 100 * ($unknownTotalWords / $totalWords));
		print "\n<p>Total words: $totalWords, of which unknown: $unknownTotalWords [$percentage%]";
		$percentage =  sprintf("%.2f", 100 * ($unknownUniqWords / $uniqWords));
		print "\n<p>Unique words: $uniqWords, of which unknown: $unknownUniqWords [$percentage%]";
	}
}


#
# reportWords
#
sub reportWords
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

	foreach $item (@wordList)
	{
		($key, $word) = split(/!/, $item, 2);

		if ($key ne $prevKey)
		{
			print "\n<p>";
			$prevKey = $key;
		}

		$letter = lc(substr($key, 0, 1));
		if ($letter ne $prevLetter)
		{
			print "\n\n<h3>" . uc($letter) . "</h3>\n";
			$prevLetter = $letter;
		}

		reportWord($word, $language);
	}

	reportWordStatistics();
}


#
# reportWord
#
sub reportWord()
{
	my $word = shift;
	my $language = shift;
	my $count = $wordHash{$language}{$word};

	$uniqWords++;
	$totalWords += $count;
	$grandTotalUniqWords++;
	$grandTotalWords += $count;

	print OUTPUTDATA "$lang\t$word\t$count\n";

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
		if ($count > 2) 
		{
			print OUTPUTFILE "$word\n";
		}

		if ($compoundWord ne "") 
		{
			if ($count < 3) 
			{
				print "<span class='comp $goodOrBad'>$compoundWord</span> ";
			}
			else
			{
				print "<span class='comp3 $goodOrBad'>$compoundWord</span> ";
			}
		}
		elsif ($count < 3)
		{
			print "<span class='err $goodOrBad'>$word</span> ";
		}
		elsif ($count < 6)
		{
			print "<span class='unk $goodOrBad'>$word</span> ";
		}
		else
		{
			print "<span class='unk10 $goodOrBad'>$word</span> ";
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
sub compoundWord()
{
	my $word = shift;
	my $language = shift;
	my $start = 4;
	my $end = length($word) - 3;

	# print STDERR "\n$word $end";
	for (my $i = $start; $i < $end; $i++) 
	{
		$before = substr($word, 0, $i);
		$after = substr($word, $i);
		if (isKnownWord($before, $language) == 1 && isKnownWord(ucfirst($after), $language) == 1)
		{
			# print STDERR "[$before|$after] ";
			return "$before|$after";
		}
	}
	return "";
}


#
# isKnownWord
#
sub isKnownWord()
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
sub reportNonWords
{
	@nonWordList = keys %nonWordHash;
	print "\n\n<h2>Frequencies of Non-Words</h2>\n";
	@nonWordList = sort @nonWordList;

	$grandTotalNonWords = 0;
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
			$grandTotalNonWords += $count;
			print "<tr><td>|$item| <td align=right><small>$length</small>&nbsp;&nbsp;&nbsp;<td align=right>$count";
		}
	}
	print "</table>\n";
}


#
# reportChars
#
sub reportChars
{
	@charList = keys %charHash;
	print "\n\n<h2>Character Frequencies</h2>\n";
	@charList = sort @charList;

	$grandTotalCharacters = 0;
	print "<table>\n";
	print "<tr><th>Character<th>Code<th>Count\n";
	foreach $char (@charList)
	{
		$char =~ s/\0/[NULL]/g;

		$count = $charHash{$char};
		$ord = ord($char);
		$grandTotalCharacters += $count;
		print "<tr><td>$char<td align=right><small>$ord</small>&nbsp;&nbsp;&nbsp;<td align=right><b>$count</b>\n";
	}
	print "</table>\n";
}


#
# reportNumbers
#
sub reportNumbers
{
	@numberList = keys %numberHash;
	print "<h2>Number Frequencies</h2>\n";
	@numberList = sort { $a <=> $b } @numberList;

	print "<p>";
	foreach $number (@numberList)
	{
		$count = $numberHash{$number};
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
sub reportTags
{
	@tagList = keys %tagHash;
	print "\n\n<h2>XML-Tag Frequencies</h2>\n";
	@tagList = sort { lc($a) cmp lc($b) } @tagList;

	$grandTotalTags = 0;
	print "<table>\n";
	print "<tr><th>Tag<th>Count\n";
	foreach $tag (@tagList)
	{
		$count = $tagHash{$tag};
		$grandTotalTags += $count;
		print "<tr><td><code>$tag</code><td align=right><b>$count</b>\n";
	}
	print "</table>\n";
}


#
# reportRend: report on the occurances of the rend tag.
#
sub reportRend
{
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
}


#
# reportStatistics: report the overall word-counts.
#
sub reportStatistics
{
	$textWordCount		= $wordCount	- $headerWordCount;
	$textNonWordCount	= $nonWordCount - $headerNonWordCount;
	$textNumberCount	= $numberCount	- $headerNumberCount;
	$textCharCount		= $charCount	- $headerCharCount;

	$extend = $textWordCount + $textNumberCount;

	print "\n<h2>Overall Statistics</h2>";
	print "\n<table>";
	print "\n<tr><th>Items					<th>Overall				<th>TEI Header			<th>Text				<th>Notes";
	print "\n<tr><td>Number of words:			<td>$wordCount			<td>$headerWordCount	<td>$textWordCount		<td>$langCount languages";
	print "\n<tr><td>Number of non-words:		<td>$nonWordCount		<td>$headerNonWordCount	<td>$textNonWordCount	<td>";	
	print "\n<tr><td>Number of numbers:		<td>$numberCount		<td>$headerNumberCount	<td>$textNumberCount	<td>";
	print "\n<tr><td>Number of characters:	<td>$charCount			<td>$headerCharCount	<td>$textCharCount		<td>excluding characters in tags, SGML headers, or SGML comments, includes header information";
	print "\n<tr><td>Number of tags:			<td>$grandTotalTags		<td>					<td>					<td>excluding closing tags";
	print "\n<tr><td>Extend:					<td>					<td>					<td>$extend				<td>Words and numbers in text";
	print "\n</table>";

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

	my $prevWord = "";
	# NOTE: we don't use \w and \W here, since it gives some unexpected results
	my @words = split(/([^\pL\pN\pM-]+)/, $fragment);
	foreach my $word (@words)
	{
		if ($word ne "") 
		{
			if ($word =~ /^[^\pL\pN\pM-]+$/)
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
}


sub countPair
{
	my $firstWord = shift;
	my $secondWord = shift;
	my $language = shift;

	$pairHash{$language}{"$firstWord!$secondWord"}++;
	# print STDERR "PAIR: $firstWord $secondWord\n";
}


sub countWord
{
	my $word = shift;
	my $lang = shift;

	$wordHash{$lang}{$word}++;
	$wordCount++;
}

sub countNumber
{
	my $number = shift;
	$numberHash{$number}++;
	$numberCount++;
}

sub countNonWord
{
	my $nonWord = shift;
	$nonWordHash{$nonWord}++;
	$nonWordCount++;
}

sub countChar
{
	my $char = shift;
	$charHash{$char}++;
	$charCount++;
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
# loadScannoFile
#
sub loadScannoFile
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
		print STDERR "NOTICE:  Loaded scanno list for " . getLanguage($lang) . " with $count entries\n";

		close(SCANNOFILE);
	}
	else
	{
		print STDERR "WARNING: Unable to open: \"dictionaries\\$lang.scannos\"\n";
	}
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
		my $shortlang = $`;
		if ($shortlang eq "" || !openDictionary("$shortlang.dic"))
		{
			print STDERR "WARNING: Could not open dictionary for " . getLanguage($lang) . "\n";
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
	print STDERR "NOTICE:  Loaded dictionary for " . getLanguage($lang) . " with $count words\n";
	close(DICTFILE);

	loadCustomDictionary($lang);
}


#
# loadCustomDictionary
#
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
			$dictHash{$lang}{$dictword} = 1;
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


#
# openDictionary
#
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
#
# printSequence
#
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


#
# isInSequence
#
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


#
# StripDiacritics
#
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


#
# Normalize
#
sub Normalize
{
	my $string = shift;
	$string =~ s/-//g;
	$string = lc(StripDiacritics($string));
	return $string;
}

