# tagMeasures.pl -- Tag measures appearing in documents.

use strict;
use Getopt::Long;

my $lang             = "en";

GetOptions('l=s' => \$lang);

my $tagPattern = "(<.*?>)";
my $fracPattern = "(?:\&frac[0-9][0-9];)";

my $numberPatternEN = "(?:(?:[0-9]+[, ])*[0-9]+(?:\.[0-9]+)?)";
my $unitPatternEN = "(?:inch(?:es)?|foot|feet|yard(?:s)?|fathom(?:s)?|furlong(?:s)?|(?:nautical )?mile(?:s)?|ounce(?:s)?|pound(?:s)?|verst(?:s)?)";
my $measurePatternEN = "($numberPatternEN) ($unitPatternEN)";
my $connectPatternEN = "(?:by|and|or|to)";
my $anotherPatternEN = "($numberPatternEN) ($connectPatternEN) \$";

my $fahrenheitPattern = "(-?$numberPatternEN\xB0) (F(?:ahr(?:enheit|\.)|\.))";
my $anotherFahrenheitPattern = "(-?$numberPatternEN\xB0) ($connectPatternEN) \$";

my $numberPattern = $numberPatternEN;
my $unitPattern = $unitPatternEN;
my $measurePattern = $measurePatternEN;
my $connectPattern = $connectPatternEN;
my $anotherPattern = $anotherPatternEN;

# See http://www.rexegg.com/regex-trick-numbers-in-english.html
my $one_to_9 = "(?:f(?:ive|our)|s(?:even|ix)|t(?:hree|wo)|(?:ni|o)ne|eight))";
my $ten_to_19 = "(?:(?:(?:s(?:even|ix)|f(?:our|if)|nine)te|e(?:ighte|lev))en|t(?:(?:hirte)?en|welve)))";
my $two_digit_prefix = "(?:s(?:even|ix)|t(?:hir|wen)|f(?:if|or)|eigh|nine)ty)";
my $one_to_99 = "(?:$two_digit_prefix)(?:[- ](?:$one_to_9))?|(?:$ten_to_19)|(?:$one_to_9)";
my $one_to_999 = "(?:$one_to_9)[ ]hundred(?:[ ](?:and[ ])?(?:$one_to_99))?|(?:$one_to_99))";
my $one_to_999_999 = "(?:$one_to_999)[ ]thousand(?:[ ](?:$one_to_999))?|(?:$one_to_999))";
my $one_to_999_999_999 = "(?:$one_to_999)[ ]million(?:[ ](?:$one_to_999_999))?|(?:$one_to_999_999))";
my $one_to_999_999_999_999 = "(?:$one_to_999)[ ]billion(?:[ ](?:$one_to_999_999_999))?|(?:$one_to_999_999_999))";
my $one_to_999_999_999_999_999 = "(?:$one_to_999)[ ]trillion(?:[ ](?:$one_to_999_999_999_999))?|(?:$one_to_999_999_999_999))";
my $englishNumber = "zero|(?:$one_to_999_999_999_999_999)";

my $numberPatternNL = "(?:(?:[0-9]+[. ])*[0-9]+(?:,[0-9]+)?)";
my $unitPatternNL = "(?:duim(?:en)?|voet(?:en)?|vadem(?:s)?|(?:zee)?mijl(?:en)?|ons|pond(?:en)?)";
my $measurePatternNL = "($numberPatternNL) ($unitPatternNL)";
my $connectPatternNL = "(?:bij|en|of)";
my $anotherPatternNL = "($numberPatternNL) ($connectPatternNL) \$";

if ($lang eq "nl") {
    $numberPattern = $numberPatternNL;
    $unitPattern = $unitPatternNL;
    $measurePattern = $measurePatternNL;
    $connectPattern = $connectPatternNL;
    $anotherPattern = $anotherPatternNL;
}


my %units = (

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

# Special measures for Armenia - Travels and Studies:
"verst",            "1.0668 kilometer",
"versts",           "1.0668 kilometer",


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


main();


sub test {
    print "TESTING...\n\n";
    print tagMeasures("De lengte is 400 voet.\n");
    print tagMeasures("De rivier is 1724 mijlen lang en bij de monding 1600 voet breed.\n");
    print tagMeasures("De plank is 3 duim dik en 5 voet lang.\n");
    print tagMeasures("De kamer is 20 bij 12 voet groot.\n");
    print tagMeasures("De zak weegt 50 pond.\n");
    print tagMeasures("De zee is hier 34.6 vadem diep.\n");
    print tagMeasures("Een lengte van 0.00654 inch.\n");
    print tagMeasures("Een graad is 60 zeemijl op de evenaar.\n");

    print tagMeasures("Aralykh, 2750 feet; Ararat, 16,916 feet.\n");
}


sub main {
    my $file = $ARGV[0];
    open(INPUTFILE, $file) || die("Could not open input file $file");

    while (<INPUTFILE>)
    {
        my $remainder = $_;
        my $result = "";
        while ($remainder =~ /$tagPattern/)
        {
            my $fragment = $`;
            my $tag = $1;
            $remainder = $';
            $result .= tagMeasures($fragment);
            $result .= $tag;
        }
        $result .= tagMeasures($remainder);

        # Special handling for degrees Fahrenheit.
        $remainder = $result;
        $result = "";
        while ($remainder =~ /$tagPattern/)
        {
            my $fragment = $`;
            my $tag = $1;
            $remainder = $';
            $result .= tagFahrenheits($fragment);
            $result .= $tag;
        }
        $result .= tagFahrenheits($remainder);


        print $result;
    }

    close INPUTFILE;
}


sub tagMeasures($) {
    my $remainder = shift;

    my $result = "";
    while ($remainder =~ /$measurePattern/) {
        my $before = $`;
        my $number = $1;
        my $unit = $2;
        $remainder = $';

        if ($before =~ /$anotherPattern/) {
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


sub tagMeasure($$$) {
    my $number = shift;
    my $unit = shift;
    my $showUnit = shift;

    my $cleanNumber = cleanNumber($number);

    if (defined $units{$unit} ) {
        my ($metricValue, $metricUnit) = split(/ /, $units{$unit});

        my $reg = round($cleanNumber * $metricValue);

        if ($showUnit == 0) {
            return "<measure reg=\"$reg\">$number</measure>";
        }
        return "<measure reg=\"$reg $metricUnit\">$number $unit</measure>";
    }
    return "$number $unit";
}


sub tagFahrenheits($) {
    my $remainder = shift;

    my $result = "";
    while ($remainder =~ /$fahrenheitPattern/) {
        my $before = $`;
        my $number = $1;
        my $unit = $2;
        $remainder = $';

        if ($before =~ /$anotherFahrenheitPattern/) {
            $before = $`;
            my $otherNumber = $1;
            my $connector = $2;
            $before .= tagFahrenheit($otherNumber, $unit, 0);
            $before .= " $connector ";
        }

        $result .= $before;
        $result .= tagFahrenheit($number, $unit, 1);
    }
    $result .= $remainder;

    return $result;
}


sub tagFahrenheit($$$) {
    my $number = shift;
    my $unit = shift;
    my $showUnit = shift;

    my $cleanNumber = cleanNumber($number);

    my $celcius = "Celcius";
    if ($unit eq "F.") {
        $celcius = "C.";
    }

    my $reg = round(($cleanNumber - 32) * 5/9);

    if ($showUnit == 0) {
        return "<measure reg=\"$reg°\">$number</measure>";
    }
    return "<measure reg=\"$reg° $celcius\">$number $unit</measure>";
}


sub cleanNumber($) {
    my $number = shift;

    if ($lang eq "en") {
        $number =~ s/[, °]//g;
    } else {
        $number =~ s/[. °]//g;
    }
    return $number;
}


sub round($) {
    my $number = shift;
    my $accuracy = 3;

    my $order = log10($number);
    if ($order <= $accuracy) {
        my $power = 10 ** int(-$order + $accuracy);
        return int(($number * $power) + .5)/$power;
    }
    return int($number + .5);
}


sub log10($) {
    my $n = shift;
    $n = abs($n);
    return log($n)/log(10);
}
