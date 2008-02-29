# normalizeText.pl -- turn various formats of text to canonical text to prepare a text compare

use utf8;
binmode(STDOUT, ":utf8");
use open ':utf8';


require Encode;

use Unicode::Normalize;
use SgmlSupport qw/getAttrVal sgml2utf_html/;




$fileName = $ARGV[0];
$encoding = $ARGV[1] || "latin-1";


$tagPattern = "<(.*?)>";


handleFile($fileName, $encoding);



sub handleFile
{
	my $fileName = shift;
	my $encoding = shift;

	my $text = readFile($fileName, $encoding);

	if ($fileName =~ /\.html?$/) 
	{
		$text = processHtml($text);
	}
	elsif ($fileName =~ /\.te?xt$/) 
	{
		$text = processText($text);
	}
	elsif ($fileName =~ /\.tei$/) 
	{
		$text = processTei($text);
	}

	print $text;
}








# Process a text file
sub processText
{
	my $text = shift;
	$text = normalizeSpaces($text);
	$text = tagPars($text);
	$text = catPars($text);

	return $text;
}


# Process an HTML file
sub processHtml
{
	my $text = shift;
	
	$text = normalizeSpaces($text);
	$text = cleanHtmlTags($text);
	$text = sgml2utf_html($text);

	return $text;
}

# Process a TEI file
sub processTei
{
	my $text = shift;
	

	return $text;
}






# Read a file in the specified encoding.
sub readFile
{
	my $fileName = shift;
	my $fileEncoding = shift;
	my $fileContents = "";

	open (INPUTFILE, $fileName) || die("Could not open input file $fileName");
    binmode (INPUTFILE, ":encoding($fileEncoding)");

	print STDERR "Opening '$fileName' with encoding '$fileEncoding'\n";

	while (<INPUTFILE>)
	{
		$fileContents .= $_;
	}

	close (INPUTFILE);
	return $fileContents;
}





# Concatenate paragraphs to a single line. Explicit linebreaks (<br> tags) are retained
sub catPars()
{
	my $text = shift;

	$text =~ s/\n/ /g;
	$text =~ s/<p>/\n\n<p>/g;

	return $text;
}


# Tag paragraphs in plain text. Paragraphs are blocks of text preceeded by an empty line.
sub tagPars()
{
	my $text = shift;

	# Mark beginning of paragraphs:
	# $text =~ s/\n\n([A-Z0-9"'([])/\n\n<p>\1/g;
	$text =~ s/\n\n([^\n])/\n\n<p>\1/g;

	return $text;
}



# Drop almost all HTML tags, except for <p> (paragraphs), and <i>, <b>, and <sc> formatting.
sub cleanHtmlTags
{
	my $text = shift;
	my $result = "";

	$text =~ s/\n/ /g;		# Get rid of all new lines.
	$text =~ s/<style\b(.*?)>(.*?)<\/style>//g;  # Get rid of CSS.

	my $remainder = $text;
	while ($remainder =~ /$tagPattern/)
	{
		my $fragment = $`;
		my $tag = $1;
		$remainder = $';
		$result .= handleHtmlFragment($fragment);
		$result .= handleHtmlTag($tag);
	}
	$result .= handleHtmlFragment($remainder);

	$result =~ s/<p> +/<p>/g;	# Get rid of superflous spaces.
	$result =~ s/\n +/\n/g;		# Get rid of superflous spaces.

	return $result;
}

sub handleHtmlFragment
{
	my $fragment = shift;

	# print STDERR "Handling fragment '$fragment'\n";

	return $fragment;
}

sub handleHtmlTag
{
	my $tag = shift;

	# print STDERR "Handling tag <$tag>\n";

	if ($tag =~ /^(li|td|blockquote|title|h1|h2|h3|h4|h5|h6|p)\b/i) 
	{
		return "\n\n<p>"
	}
	elsif ($tag =~ /^(strong|emph|b|i)\b/i) 
	{
		return "<i>"
	}
	elsif ($tag =~ /^\/(strong|emph|b|i)\b/i) 
	{
		return "</i>"
	}
}






# Normalize tagging of text-style tags around punctuation.
sub normalizeTagging
{


}






sub normalizeSpaces
{
	my $text = shift;

	$text =~ s/\t/ /g;			# Tabs go to spaces
	$text =~ s/ +/ /g;			# Series of spaces go to a single space
	$text =~ s/ \n/\n/g;		# Spaces before new-line are removed
	$text =~ s/\n\n+/\n\n/g;	# Multiple empty lines go to a single empty line

	return $text;
}
