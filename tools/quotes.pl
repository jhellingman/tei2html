# quotes.pl -- Do smart quotes stuff.

$accLetter = "(\\&[A-Za-z](acute|grave|circ|uml|cedil|tilde|slash|ring|dotb|macr|breve);)";
$ligLetter = "(\\&[A-Za-z]{2}lig;)";
$specLetter = "(\\&apos;|\\&eth;|\\&ETH;|\\&thorn;|\\&THORN;|\\&alif;|\\&ayn;|\\&prime;)";
$letter = "(\\w|$accLetter|$ligLetter|$specLetter;)";
$wordPattern = "($letter)+(([-']|&rsquo;|&apos;)($letter)+)*";
$nonLetter = "\\&(amp|ldquo|rdquo|lsquo|mdash|hellips|gt|lt|frac[0-9][0-9]);";

while(<>)
{
	$line = $_;

	# open quotes
	$line =~ s/\"($wordPattern)/\&ldquo;$1/g;

	# close quotes
	$line =~ s/\"/&rdquo;/g;

	# fix stuff in SGML tags:  ="  ">

	$remainder = $line;
	$line = "";
	while ($remainder =~ /(<.*?>)/) 
	{
		$line .= $`;
		$tag = $1;
		$remainder = $';
		$tag =~ s/\&(r|l)dquo;/\"/g;
		$line .= $tag;
	}
	$line .= $remainder;

	print $line;
}
