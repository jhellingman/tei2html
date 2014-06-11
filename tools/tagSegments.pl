
use strict;

# Segementize a TEI file

# See: http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-s.html
# And: http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-seg.html

# Basically, add <seg id=seg000001>...</seg> to elements containing text.





# Elements to split:

#   <p>, <head>, <l>, <cell>, <item>, <note>


# Elements not to split, but wrap in a single: anything else: (mostly inline elements)
#
#       <hi>; <ref>; <xref>;    -- handle as integral part when itself not breakable; otherwise break.

# To take into account:   This is the <hi>end.</hi>


# Elements to be ignored
#
#       <lb>, <pb>

# Special handling: 
#
#       <note> -- lift from context, handle separately.


# Algorithm

# 1. Lift tags like <note> from text, replace by TOKEN, place in array.
# 2. Segmentize
# 3. Merge tags back into text.



my $mark = "<sb>";

my $tagPattern = "(<.*?>)";

my $segmentCounter = 1;

my $liftedTagMark = "___";
my $liftedTagCounter = 1;
my %liftedTags = ();



my %abbreviations =
(
    "Prof." => 1,
    "Dr." => 2,
    "Ing." => 3,
	"Ds." => 4,
);


sub test()
{
    testLiftInlineTags();
    testTagSegments();
    exit;
}


sub testLiftInlineTags()
{
    print "TESTING liftInlineTags()\n\n";

    testLiftInlineTags1("<tb>");
    testLiftInlineTags1("<lb>");
    testLiftInlineTags1("Dit is een korte test<pb n=23>. Hiermee tonen<lb> we <corr sic='an'>aan</corr> dat we zinnen in stukken kunnen breken! Zie je dit? Het werkt.");
}


sub testLiftInlineTags1($)
{
    my $line = shift;
    my $lifted = liftInlineTags($line);
    my $tagged = tagSegments($lifted);
    my $restored = restoreInlineTags($tagged);

    print $restored;
    print "\n\n";
}


sub testTagSegments()
{
    print "TESTING tagSegments()\n\n";
    print tagSegments("Dit is een korte test. Hiermee tonen we aan dat we zinnen in stukken kunnen breken! Zie je dit? Het werkt.");
    print "\n\n";
    print tagSegments("Dit is een korte test. &Eacute;&Eacute;n, twee, drie!");
    print "\n\n";
    print tagSegments("Laat mij eens denken.... Ja!");
    print "\n\n";
    print tagSegments("\"Laat mij eens denken....\" Ja!");
    print "\n\n";
    print tagSegments("\"Laat mij eens denken....\" zei Prof. Dr. Ing. Janssen.");
    print "\n\n";
    print tagSegments("Laat mij vertellen. 't Was op een koude zaterdag.");
    print "\n\n";
}


sub main
{
    my $file = $ARGV[0];

    if (!defined($file) || $file eq '') 
    {
        test();
    }

    open(INPUTFILE, $file) || die("Could not open input file $file");

    # Skip upto start of actual text.
    while (<INPUTFILE>) 
    {
        my $line = $_;
        if ($line =~ /<text(.*?)>/)
        {
            print $line;
            last;
        }
        print $line;
    }


    while (<INPUTFILE>)
    {
        my $remainder = $_;
		$remainder = liftInlineTags($remainder);
        my $result = "";
        while ($remainder =~ /$tagPattern/)
        {
            my $before = $`;
            my $tag = $1;
            $remainder = $';
            $result .= tagSegments($before) . $tag;
        }
        $result .= tagSegments($remainder);

		$result = restoreInlineTags($result);
        print $result;
    }

    close INPUTFILE;
}


sub liftInlineTags($)
{
    my $line = shift;

	$line = liftGreek($line);

    my $remainder = $line;
    my $result = "";
    while ($remainder =~ m/(<\/?(hi|pb|lb|corr|abbr|ref|xref)(.*?)>)/)
    {
        my $before = $`;
        my $tag = $1;
        $remainder = $';
        $liftedTags{$liftedTagCounter} = $tag;
        $result .= $before . $liftedTagMark . $liftedTagCounter . $liftedTagMark;
        $liftedTagCounter++;
    }
    $result .= $remainder;
    return $result;
}


# Remove <GR>...</GR> tagging from the file.
sub liftGreek($)
{
    my $remainder = shift;
    my $result = "";
    while ($remainder =~ m/(<GR>(.*?)<\/GR>)/)
    {
        my $before = $`;
        my $greek = $1;
        $remainder = $';
        $liftedTags{$liftedTagCounter} = $greek;
        $result .= $before . $liftedTagMark . $liftedTagCounter . $liftedTagMark;
        $liftedTagCounter++;
    }
    $result .= $remainder;
    return $result;
}


sub restoreInlineTags($)
{
    my $line = shift;
    my $remainder = $line;
    my $result = "";
    while ($remainder =~ m/$liftedTagMark([0-9]+)$liftedTagMark/)
    {
        my $before = $`;
        my $tagNumber = $1;
        $remainder = $';
        my $tag = $liftedTags{$tagNumber};
        $result .= $before . $tag;
    }
    $result .= $remainder;

	# Eliminate pointless <seg><tag></seg> sequences.
	$result =~ s/<seg>(<(pb|lb)(.*?)>)<\/seg>/\1/g;

    return $result;
}


sub findSegmentBreaks($)
{
    my $text = shift;

    my $alphaNum = "(?:[\\p{IsAlnum}]|\\&[A-Za-z](?:breve|macr|acute|grave|uml|umlb|tilde|circ|cedil|dotb|dot|breveb|caron|comma|barb|circb|bowb|dota);)";

    my $upperCaseLetter = "(?:[\\p{IsUpper}]|\\&[A-Z](?:breve|macr|acute|grave|uml|umlb|tilde|circ|cedil|dotb|dot|breveb|caron|comma|barb|circb|bowb|dota);)";
    my $punctuationOpen = "(?:\\&lsquo;|\\&ldquo;|\\&bdquo;|\\&iexcl;|\\&iquest;|[\\'\\\"\\(\\[\\¿\\¡\\p{IsPi}])";
    my $punctuationClose = "(?:\\&rsquo;|\\&rdquo;|[\\'\\\"\\)\\]\\p{IsPf}])";

    # Handle the special Dutch case of 't and 'n starting a new sentence.
    my $dutchSpecial = "(?:\\&apos;|\\')[tn]\\s+";

    my $sentenceStarter = "($punctuationOpen)*($dutchSpecial)?($upperCaseLetter)";

    # print "PATTERN: $punctuationClose\n";

    $text =~ s/([:;,])( +)/$1$mark$2/g;

    $text =~ s/([?!])( +)($sentenceStarter)/$1$mark$2$3/g;
    $text =~ s/(\.[\.]+)( +)($sentenceStarter)/$1$mark$2$3/g;
    $text =~ s/([?!\.](?:$punctuationClose+))( +)($sentenceStarter)/$1$mark$2$3/g;

    my @words = split(/(\s+)/, $text);
    my $i;
    my $result = "";
    for ($i = 0; $i < (scalar(@words) - 1); $i++) 
    {
        my $word = $words[$i];
        if ($word =~ /(($alphaNum|\&apos;|[\.\-])+)($punctuationClose*)(\.+)$/) 
        {
			# Is the word an abbreviation or a (set of) initials?
            if (isAbbreviation($word) || $word =~ /^($upperCaseLetter\.)+$/)
            {
                $result .= $word;
            }
            else
            {
                $result .= $word . $mark;
            }
        }
        else
        {
            $result .= $word;
        }
    }
    $result .= $words[$i];
    
    return $result;
}


sub tagSegments($)
{
    my $text = shift;
    $text = findSegmentBreaks($text);

    # print "TEXT: $text\n";

    my @sentences = split(/<sb>(\s+)/, $text);

    my $result = "";
    foreach my $sentence (@sentences) 
    {
        if ($sentence !~ /^\s+$/) 
        {
            $result .= startSegment() . $sentence . endSegment();
        }
        else
        {
            $result .= $sentence;
        }
    }

    $result =~ s/(\s+)(<\/seg>)/\2\1/g;

    return $result;
}


sub startSegment()
{
    my $counter =  sprintf("%06d", $segmentCounter);
    $segmentCounter++;
    # return "<seg id=\"seg$counter\">";
	return "<seg>";
}


sub endSegment()
{
    return "</seg>";
}


sub isAbbreviation($)
{
    my $word = shift;
    return exists($abbreviations{$word});
}


sub isAbbreviationBeforeNumber($)
{
    return 0;
}



main();
