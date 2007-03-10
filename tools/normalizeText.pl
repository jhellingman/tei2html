# normalize.pl -- turn HTML to canonical text to prepare a text compare


use SgmlSupport qw/getAttrVal sgml2utf/;



$tagPattern = "<(.*?)>";


$infile = $ARGV[0];


if ($infile =~ /\.html?$/) 
{
	normalizeHtml($infile)

}

sub normalizeHtml
{
	my $infile = shift;
	open(INPUTFILE, $infile) || die("ERROR: Could not open input file $infile");
	my $contents = "";
	while (<INPUTFILE>)
	{
		$contents .= $_;
	}
	close INPUTFILE;

	my $remainder = $contents;
	while ($remainder =~ /$tagPattern/)
	{
		my $fragment = $`;
		my $tag = $1;
		$remainder = $';
		handleFragment($fragment);
		handleTag($tag);
	}
	handleFragment($remainder);
}



sub handleFragment
{
	my $fragment = shift;

    $fragment =~ s/[ \t]+/ /g;
    $fragment =~ s/[»”„]/"/g;
    $fragment =~ s/[’]/'/g;
    $fragment =~ s/[…]/.../g;

	print $fragment;
}

sub handleTag
{
	my $tag = shift;

	# print "<$tag>\n";

	if ($tag =~ /^(li|td|blockquote|title|h1|h2|h3|h4|h5|h6|p)\b/i) 
	{
		print "\n<p>"
	}
	elsif ($tag =~ /^(strong|emph|b|i)\b/i) 
	{
		print "<hi>"
	}
	elsif ($tag =~ /^\/(strong|emph|b|i)\b/i) 
	{
		print "</hi>"
	}
}
