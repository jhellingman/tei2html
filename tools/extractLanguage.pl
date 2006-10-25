# extractLanguage.pl -- extract text in a certain language
#
# This script will look at the lang attribute to determine the language of the text.
#
# The implementation is somewhat hacked and could be much better. This is fragile code!
#
# Assumptions:
#    Input is well-formed XML (that is: any open tag is matched with a close tag).
#    All tags appear on a single line (no line-breaks inside tags).
#
# copyleft 2004 Jeroen Hellingman

$infile = $ARGV[0];
$outLang = $ARGV[1];

open(INPUTFILE, $infile) || die("Could not open input file $infile");

%langNames = ();
$langNames{"AA"} =  "Afar";
$langNames{"AB"} =  "Abkhazian";
$langNames{"AF"} =  "Afrikaans";
$langNames{"AM"} =  "Amharic";
$langNames{"AR"} =  "Arabic";
$langNames{"AS"} =  "Assamese";
$langNames{"AY"} =  "Aymara";
$langNames{"AZ"} =  "Azerbaijani";
$langNames{"BA"} =  "Bashkir";
$langNames{"BE"} =  "Byelorussian";
$langNames{"BG"} =  "Bulgarian";
$langNames{"BH"} =  "Bihari";
$langNames{"BI"} =  "Bislama";
$langNames{"BN"} =  "Bengali";
$langNames{"BO"} =  "Tibetan";
$langNames{"BR"} =  "Breton";
$langNames{"CA"} =  "Catalan";
$langNames{"CO"} =  "Corsican";
$langNames{"CS"} =  "Czech";
$langNames{"CY"} =  "Welsh";
$langNames{"DA"} =  "Danish";
$langNames{"DE"} =  "German";
$langNames{"DZ"} =  "Bhutani";
$langNames{"EL"} =  "Greek";
$langNames{"EN"} =  "English";
$langNames{"EO"} =  "Esperanto";
$langNames{"ES"} =  "Spanish";
$langNames{"ET"} =  "Estonian";
$langNames{"EU"} =  "Basque";
$langNames{"FA"} =  "Persian";
$langNames{"FI"} =  "Finnish";
$langNames{"FJ"} =  "Fiji";
$langNames{"FO"} =  "Faeroese";
$langNames{"FR"} =  "French";
$langNames{"FY"} =  "Frisian";
$langNames{"GA"} =  "Irish";
$langNames{"GD"} =  "Gaelic";
$langNames{"GL"} =  "Galician";
$langNames{"GN"} =  "Guarani";
$langNames{"GU"} =  "Gujarati";
$langNames{"HA"} =  "Hausa";
$langNames{"HI"} =  "Hindi";
$langNames{"HR"} =  "Croatian";
$langNames{"HU"} =  "Hungarian";
$langNames{"HY"} =  "Armenian";
$langNames{"IA"} =  "Interlingua";
$langNames{"IE"} =  "Interlingue";
$langNames{"IK"} =  "Inupiak";
$langNames{"IN"} =  "Indonesian";
$langNames{"IS"} =  "Icelandic";
$langNames{"IT"} =  "Italian";
$langNames{"IW"} =  "Hebrew";
$langNames{"JA"} =  "Japanese";
$langNames{"JI"} =  "Yiddish";
$langNames{"JW"} =  "Javanese";
$langNames{"KA"} =  "Georgian";
$langNames{"KK"} =  "Kazakh";
$langNames{"KL"} =  "Greenlandic";
$langNames{"KM"} =  "Cambodian";
$langNames{"KN"} =  "Kannada";
$langNames{"KO"} =  "Korean";
$langNames{"KS"} =  "Kashmiri";
$langNames{"KU"} =  "Kurdish";
$langNames{"KY"} =  "Kirghiz";
$langNames{"LA"} =  "Latin";
$langNames{"LN"} =  "Lingala";
$langNames{"LO"} =  "Laothian";
$langNames{"LT"} =  "Lithuanian";
$langNames{"LV"} =  "Latvian";
$langNames{"MG"} =  "Malagasy";
$langNames{"MI"} =  "Maori";
$langNames{"MK"} =  "Macedonian";
$langNames{"ML"} =  "Malayalam";
$langNames{"MN"} =  "Mongolian";
$langNames{"MO"} =  "Moldavian";
$langNames{"MR"} =  "Marathi";
$langNames{"MS"} =  "Malay";
$langNames{"MT"} =  "Maltese";
$langNames{"MY"} =  "Burmese";
$langNames{"NA"} =  "Nauru";
$langNames{"NE"} =  "Nepali";
$langNames{"NL"} =  "Dutch";
$langNames{"NO"} =  "Norwegian";
$langNames{"OC"} =  "Occitan";
$langNames{"OM"} =  "Oromo";
$langNames{"OR"} =  "Oriya";
$langNames{"PA"} =  "Punjabi";
$langNames{"PL"} =  "Polish";
$langNames{"PS"} =  "Pashto";
$langNames{"PT"} =  "Portuguese";
$langNames{"QU"} =  "Quechua";
$langNames{"RM"} =  "Rhaeto-Romance";
$langNames{"RN"} =  "Kirundi";
$langNames{"RO"} =  "Romanian";
$langNames{"RU"} =  "Russian";
$langNames{"RW"} =  "Kinyarwanda";
$langNames{"SA"} =  "Sanskrit";
$langNames{"SD"} =  "Sindhi";
$langNames{"SG"} =  "Sangro";
$langNames{"SH"} =  "Serbo-Croatian";
$langNames{"SI"} =  "Singhalese";
$langNames{"SK"} =  "Slovak";
$langNames{"SL"} =  "Slovenian";
$langNames{"SM"} =  "Samoan";
$langNames{"SN"} =  "Shona";
$langNames{"SO"} =  "Somali";
$langNames{"SQ"} =  "Albanian";
$langNames{"SR"} =  "Serbian";
$langNames{"SS"} =  "Siswati";
$langNames{"ST"} =  "Sesotho";
$langNames{"SU"} =  "Sudanese";
$langNames{"SV"} =  "Swedish";
$langNames{"SW"} =  "Swahili";
$langNames{"TA"} =  "Tamil";
$langNames{"TE"} =  "Tegulu";
$langNames{"TG"} =  "Tajik";
$langNames{"TH"} =  "Thai";
$langNames{"TI"} =  "Tigrinya";
$langNames{"TK"} =  "Turkmen";
$langNames{"TL"} =  "Tagalog";
$langNames{"TN"} =  "Setswana";
$langNames{"TO"} =  "Tonga";
$langNames{"TR"} =  "Turkish";
$langNames{"TS"} =  "Tsonga";
$langNames{"TT"} =  "Tatar";
$langNames{"TW"} =  "Twi";
$langNames{"UK"} =  "Ukrainian";
$langNames{"UR"} =  "Urdu";
$langNames{"UZ"} =  "Uzbek";
$langNames{"VI"} =  "Vietnamese";
$langNames{"VO"} =  "Volapuk";
$langNames{"WO"} =  "Wolof";
$langNames{"XH"} =  "Xhosa";
$langNames{"YO"} =  "Yoruba";
$langNames{"ZH"} =  "Chinese";
$langNames{"ZU"} =  "Zulu";

# ISO 639 3-letter codes.

$langNames{"BIK"} = "Bicolano";
$langNames{"CEB"} = "Cebuano";
$langNames{"CRB"} = "Chavacano";
$langNames{"HIL"} = "Hiligaynon";
$langNames{"ILO"} = "Ilocano";
$langNames{"PAG"} = "Pangasinan";
$langNames{"PAM"} = "Kapampangan";
$langNames{"WAR"} = "Waray-Waray";
$langNames{"KHA"} = "Khasi";

# Territory specific additions

$langNames{"EN-UK"} = "U.K. English";
$langNames{"EN-US"} = "U.S. English";

# Private additions.

$langNames{"BIS"} = "Bisayan";
$langNames{"GAD"} = "Gaddang";


$langNames{"NL-1900"} = "Dutch (spelling of De Vries-Te Winkel)";
$langNames{"NL-1800"} = "Dutch (19th century spelling)";
$langNames{"NL-1700"} = "Dutch (18th century spelling)";
$langNames{"NL-1600"} = "Dutch (17th century spelling)";

# Set variables

$tagPattern = "<(.*?)>";

%langHash = ();

$langCount = 0;
$langStackSize = 0;

if ($langNames{uc($outLang)}) 
{
	$langName = $langNames{uc($outLang)};
}
else
{
	$langName = $outLang;
}

print "<!-- Fragments in $langName from $infile -->";
print "<fragments>";

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

print "</fragments>";

#
# getAttrVal: Get an attribute value from a tag (if the attribute is present)
#
sub getAttrVal
{
	my $attrName = shift;
	my $attrs = shift;
	my $attrVal = "";

	if($attrs =~ /$attrName\s*=\s*(\w+)/i)
	{
		$attrVal = $1;
	}
	elsif($attrs =~ /$attrName\s*=\s*\"(.*?)\"/i)
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
		if (getLang() eq $outLang) 
		{
			print "<$tag>\n";
		}

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

		if (getLang() eq $outLang) 
		{
			print "\n<$tag>";
		}
	}
}

#
# handleFragment
#
sub handleFragment
{
	my $remainder = shift;
	
	my $lang = getLang();

	if ($lang eq $outLang) 
	{
		print $remainder;
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

