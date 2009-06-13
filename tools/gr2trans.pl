# gr2trans.pl -- Add Greek transcription to Greek text
#
# Assumption: Greek sections are marked <GR>...</GR>; other tool will actually convert to transcription.
#
# Output: <choice><orig><GR>...</GR></orig><reg><GRT>...</GRT></reg></choice>
# Alternative output to build HTML: <span class=trans title="<GRTA>...</GRTA>"><GR>...</GR></span>
#


$useHtml = 1;


main();


sub main
{
	my $file = $ARGV[0];

	if ($file eq "-x") 
	{
		$useHtml = 0;
		$file = $ARGV[1];
	}

	open(INPUTFILE, $file) || die("Could not open input file $file");

	my $paragraph = "";

	while (<INPUTFILE>)
	{
		my $line = $_;

		# Deal with PGDP page separators.
		if ($_ =~ /-*File: ([0-9]+)\.png-*\\([^\\]*)(\\([^\\]+))?(\\([^\\]+))?(\\([^\\]+))?\\.*$/) 
		{
			print "\n\n" . handleParagraph($paragraph);
			print "\n$line";
			$paragraph = "";
		}
		elsif ($line ne "\n") 
		{
			chomp($line);
			$paragraph .= " " . $line;
		}
		else
		{
			print "\n\n" . handleParagraph($paragraph);
			$paragraph = "";
		}
	}

	if ($paragraph ne "")
	{
		print "\n\n" . handleParagraph($paragraph);
	}

	close INPUTFILE;
}



sub handleParagraph
{
	my $paragraph = shift;

	if ($useHtml == 1) 
	{
		$paragraph =~ s/<GR>(.*?)<\/GR>/<span class=trans title=\"<GRTA>\1<\/GRTA>\"><GR>\1<\/GR><\/span>/g;
	}
	else
	{
		$paragraph =~ s/<GR>(.*?)<\/GR>/<choice><orig><GR>\1<\/GR><\/orig><reg type=\"trans\"><GRT>\1<\/GRT><\/reg><\/choice>/g;
	}

	return $paragraph;
}
