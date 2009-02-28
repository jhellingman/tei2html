# tagMeasures.pl -- Tag measures appearing in documents.


$unitPattern = "(?:voeten|voet|mijlen|mijl|inches|inch|duimen|duim)";
$numberPattern = "(?:(?:[0-9]+[. ])*[0-9]+(?:,[0-9]+)?)";
$measurePattern = "($numberPattern) ($unitPattern)";
$tagPattern = "<(.*?)>";


$connectPattern = "(?:bij|en|of)";
$anotherPattern = "($numberPattern) ($connectPattern) \$";


test();




sub test
{
	print "TESTING...\n";
	print tagMeasures("De lengte is 400 voet.\n");
	print tagMeasures("De rivier is 324 mijlen lang en bij de monding 600 voet breed.\n");
	print tagMeasures("De plank is 3 duim dik en 5 voet lang.\n");
	print tagMeasures("De kamer is 20 bij 12 voet groot.\n");
}


sub main
{
	my $file = $ARGV[0];
	open(INPUTFILE, $file) || die("Could not open input file $file");

	while (<INPUTFILE>)
	{
		my $remainder = $_;
		while ($remainder =~ /$tagPattern/)
		{
			my $fragment = $`;
			my $tag = $1;
			$remainder = $';
			print tagMeasures($fragment);
		}
		print tagMeasures($remainder);
	}

	close INPUTFILE;
}


sub tagMeasures
{

	my $remainder = shift;

	my $result = "";
	while ($remainder =~ /$measurePattern/)
	{
		my $before = $`;
		my $number = $1;
		my $unit = $2;
		$remainder = $';

		if ($before =~ /$anotherPattern/) 
		{
			$before = $`;
			my $otherNumber = $1;
			my $connector = $2;
			$before .= tagMeasure($otherNumber, $unit, 0);
			$before .= " $connector ";
		}

		$result .= $before;
		$result .= tagMeasure($number, $unit, 1);
	}
	$result .= $remainder;
	
	return $result;
}


sub tagMeasure
{
	my $number = shift;
	my $unit = shift;
	my $showUnit = shift;

	if ($unit eq "inch" || $unit eq "inches" || $unit eq "duim" || $unit eq "duimen") 
	{
		$reg = round($number * 2.54);
		$reg .= " centimeter";
	}

	if ($unit eq "voet" || $unit eq "voeten") 
	{
		$reg = round($number * 0.3048);
		$reg .= " meter";
	}

	if ($unit eq "mijl" || $unit eq "mijlen") 
	{
		$reg = round($number * 1.609344);
		$reg .= " kilometer";
	}

	if ($showUnit == 0) 
	{
		return "<measure reg=\"$reg\">$number</measure>";
	}
	return "<measure reg=\"$reg\">$number $unit</measure>";
}


sub round
{
	my $number = shift;
	return int($number + .5);
}