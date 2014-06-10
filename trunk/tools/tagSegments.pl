
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
my $tagPattern = "<(.*?)>";
my $segmentCounter = 1;

my %abbreviations =
(
"Prof." => 1,
"Dr." => 2,
"Ing." => 3,
);



test();


sub test
{
    print "TESTING...\n\n";
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

    exit;
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
            print tagSegments($fragment);
        }
        print tagSegments($remainder);
    }

    close INPUTFILE;
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

    $text =~ s/([?!])( +)($sentenceStarter)/$1$mark$2$3/g;
    $text =~ s/(\.[\.]+)( +)($sentenceStarter)/$1$mark$2$3/g;
    $text =~ s/([?!\.](?:$punctuationClose+))( +)($sentenceStarter)/$1$mark$2$3/g;

    my @words = split(/( +)/, $text);
    my $i;
    my $result = "";
    for ($i = 0; $i < (scalar(@words) - 1); $i++) 
    {
        my $word = $words[$i];
        if ($word =~ /(($alphaNum|\&apos;|[\.\-])+)($punctuationClose*)(\.+)$/) 
        {
            if (isAbbreviation($word))
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

    my @sentences = split("<sb>( +)", $text);

    my $result = "";
    foreach my $sentence (@sentences) 
    {
        if ($sentence !~ /^ +$/) 
        {
            $result .= startSegment() . $sentence . endSegment();
        }
        else
        {
            $result .= $sentence;
        }
    }
    return $result;
}


sub startSegment()
{
    my $counter =  sprintf("%06d", $segmentCounter);
    $segmentCounter++;
    return "<seg id=\"seg$counter\">";
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

