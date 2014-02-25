# tagMeasures.pl -- Tag measures appearing in documents.

$tagPattern = "<(.*?)>";

$unitPatternEN = "(?:inch(?:es)?|foot|feet|yard(?:s)?|fathom(?:s)?|furlong(?:s)?|(?:nautical )?mile(?:s)?|ounce(?:s)?|pound(?:s)?)";
$unitPatternNL = "(?:duim(?:en)?|voet(?:en)?|vadem(?:s)?|(?:zee)?mijl(?:en)?|ons|pond(?:en)?)";
$numberPattern = "(?:(?:[0-9]+[. ])*[0-9]+(?:,[0-9]+)?)";
$measurePattern = "($numberPattern) ($unitPatternEN|$unitPatternNL)";

$connectPatternNL = "(?:bij|en|of)";
$anotherPattern = "($numberPattern) ($connectPatternNL) \$";

%units = (

# Imperial units
"inch",             "2.54 centimeter",
"inches",           "2.54 centimeter",
"foot",             "0.3048 meter",
"feet",             "0.3048 meter",
"yard",             "0.9144 meter",
"yards",            "0.9144 meter",
"fathom",           "1.8288 meter",
"fathoms",          "1.8288 meter",
"furlong",          "201.16800 meter",
"furlongs",         "201.16800 meter",
"mile",             "1.609344 kilometer",
"miles",            "1.609344 kilometer",
"nautical mile",    "1.85200 kilometer",
"nautical miles",   "1.85200 kilometer",

"ounce",            "28.3495231 gram",
"ounces",           "28.3495231 gram",
"pound",            "0.45359237 kilogram",
"pounds",           "0.45359237 kilogram",

# Dutch names, but using Imperial values.
"duim",             "2.54 centimeter",
"duimen",           "2.54 centimeter",
"voet",             "0.3048 meter",
"voeten",           "0.3048 meter",
"vadem",            "1.8288 meter",
"vadems",           "1.8288 meter",
"mijl",             "1.609344 kilometer",
"mijlen",           "1.609344 kilometer",

"zeemijl",          "1.85200 kilometer",
"zeemijlen",        "1.85200 kilometer",

"ons",              "28.3495231 gram",
"pond",             "0.45359237 kilogram",
"ponden",           "0.45359237 kilogram"

);


test();


sub test
{
    print "TESTING...\n\n";
    print tagMeasures("De lengte is 400 voet.\n");
    print tagMeasures("De rivier is 1724 mijlen lang en bij de monding 1600 voet breed.\n");
    print tagMeasures("De plank is 3 duim dik en 5 voet lang.\n");
    print tagMeasures("De kamer is 20 bij 12 voet groot.\n");
    print tagMeasures("De zak weegt 50 pond.\n");
    print tagMeasures("De zee is hier 34.6 vadem diep.\n");
    print tagMeasures("Een lengte van 0.00654 inch.\n");
    print tagMeasures("Een graad is 60 zeemijl op de evenaar.\n");
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

    if (defined $units{$unit} )
    {
        ($metricValue, $metricUnit) = split(/ /, $units{$unit});

        my $reg = round($number * $metricValue);

        if ($showUnit == 0)
        {
            return "<measure reg=\"$reg\">$number</measure>";
        }
        return "<measure reg=\"$reg $metricUnit\">$number $unit</measure>";
    }
    return "$number $unit";
}


sub round
{
    my $number = shift;
    my $accuracy = 3;

    my $order = log10($number);
    if ($order <= $accuracy)
    {
        my $power = 10 ** int(-$order + $accuracy);
        return int(($number * $power)  + .5)/$power;
    }
    return int($number + .5);
}


sub log10
{
    my $n = shift;
    return log($n)/log(10);
}
