
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
    "Dr."       => "Dokter",
    "Ing."      => "Ingenieur",
    "Prof."     => "Professor",
    "Ds."       => "Dominee",

# bacc
# bc
# bgen
# c.i
# dhr
# dr
# dr.h.c
# drs
# drs
# ds
# eint
# fa
# Fa
# fam
# gen
# genm
# ing
# ir
# jhr
# jkvr
# jr
# kand
# kol
# lgen
# lkol
# Lt
# maj
# Mej
# mevr
# Mme
# mr
# mr
# Mw
# o.b.s
# plv
# prof
# ritm
# tint
# Vz
# Z.D
# Z.D.H
# Z.E
# Z.Em
# Z.H
# Z.K.H
# Z.K.M
# Z.M
# z.v
#
# a.g.v
    "bijv."         => "bijvoorbeeld",
# bijz
# bv
    "bv."           => "bijvoorbeeld",
# d.w.z
    "d.w.z."        => "dat wil zeggen",
# e.c
# e.g
# e.k
# ev
# i.p.v
    "i.p.v."        => "in plaats van",
# i.s.m
# i.t.t
    "i.t.t."        => "in tegenstelling tot",
# i.v.m
    "i.v.m."        => "in verband met",
# m.a.w
    "m.a.w."        => "met andere woorden",
# m.b.t
    "m.b.t."        => "met betrekking tot",
# m.b.v
# m.h.o
# m.i
# m.i.v
    "m.i.v."        => "met ingang van",
# v.w.t



);


sub test()
{
    # testLiftInlineTags();
    # testTagSegments();
    testFixNesting();
    exit;
}

sub assertEquals($$)
{
    my $expected = shift;
    my $actual = shift;

    if ($expected ne $actual)
    {
        print "  ERROR: Strings not equal!\n";
        print "         Expected: $expected\n";
        print "         Actual:   $actual\n";
    }
}


sub testFixNesting()
{
    print "TEST: fixNesting()\n";

    my $input       = "<seg>Dit is <hi>gewoon eenvoudig.</hi></seg>";
    my $expected    = "<seg>Dit is <hi>gewoon eenvoudig.</hi></seg>";
    my $output = fixNesting($input);
    assertEquals($expected, $output);

    $input      = "<seg>Dit is <hi>fout genest.</seg> <seg>Dat</hi> snap je wel.</seg>";
    $expected   = "<seg>Dit is <hi>fout genest.</hi></seg> <seg><hi>Dat</hi> snap je wel.</seg>";
    $output = fixNesting($input);
    assertEquals($expected, $output);

    $input      = "<seg>Dit is <hi rend='sc'><hi>fout genest.</seg> <seg>Dat</hi> snap</hi> je wel.</seg>";
    $expected   = "<seg>Dit is <hi rend='sc'><hi>fout genest.</hi></hi></seg> <seg><hi rend='sc'><hi>Dat</hi> snap</hi> je wel.</seg>";
    $output = fixNesting($input);
    assertEquals($expected, $output);

}


sub testLiftInlineTags()
{
    print "TEST: liftInlineTags()\n";

    my $input    = "Dit is een korte test<pb n=23>. Hiermee tonen<lb> we <corr sic='an'>aan</corr> dat we zinnen in stukken kunnen breken! Zie je dit? Het werkt.";
    my $expected = "Dit is een korte test___1___. Hiermee tonen___2___ we ___3___aan___4___ dat we zinnen in stukken kunnen breken! Zie je dit? Het werkt.";
    my $output = liftInlineTags($input);
    assertEquals($expected, $output);
    $output = restoreInlineTags($output);
    assertEquals($input, $output);
}


sub testTagSegments()
{
    print "TEST: tagSegments()\n\n";

    my $input    = "Dit is een korte test. Hiermee tonen we aan dat we zinnen in stukken kunnen breken! Zie je dit? Het werkt.";
    my $expected = "<seg>Dit is een korte test.</seg> <seg>Hiermee tonen we aan dat we zinnen in stukken kunnen breken!</seg> <seg>Zie je dit?</seg> <seg>Het werkt.</seg>";

    my $output = tagSegments($input);
    assertEquals($expected, $output);

    $input    = "Dit is een korte test. &Eacute;&Eacute;n, twee, drie!";
    $expected = "<seg>Dit is een korte test.</seg> <seg>&Eacute;&Eacute;n,</seg> <seg>twee,</seg> <seg>drie!</seg>";
    $output = tagSegments($input);
    assertEquals($expected, $output);

    $input    = "Laat mij eens denken.... Ja!";
    $expected = "<seg>Laat mij eens denken....</seg> <seg>Ja!</seg>";
    $output = tagSegments($input);
    assertEquals($expected, $output);

    $input    = "\"Laat mij eens denken....\" Ja!";
    $expected = "<seg>\"Laat mij eens denken....\"</seg> <seg>Ja!</seg>";
    $output = tagSegments($input);
    assertEquals($expected, $output);

    $input    = "\"Laat mij eens denken....\", zei Prof. Dr. Ing. A. M. Janssen.";
    $expected = "<seg>\"Laat mij eens denken....\",</seg> <seg>zei Prof. Dr. Ing. A. M. Janssen.</seg>";
    $output = tagSegments($input);
    assertEquals($expected, $output);

    $input    = "En nu vertelt Louis zijn wedervaren. Ook Truida wordt daarbij genoemd&mdash;hoe kan het anders?";
    $expected = "<seg>En nu vertelt Louis zijn wedervaren.</seg> <seg>Ook Truida wordt daarbij genoemd&mdash;hoe kan het anders?</seg>";
    $output = tagSegments($input);
    assertEquals($expected, $output);
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

        # Skip trailing material. (That is, the checklist I tend to add there.)
		# Follow convention that final </text> is on its own line.
        if ($remainder =~ /^<\/text>/)
        {
            print $remainder;
            last;
        }

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

		# Remove pointless segments only containing a <pb> tag.
		$result =~ s/(<seg[^>]*?>)(<(pb|lb)([^>]*?)>)<\/seg>/\2/g;

		$result = fixNesting($result);
        print $result;
    }

    # Skip whatever is remaining.
    while (<INPUTFILE>)
    {
        my $line = $_;
        print $line;
    }

    close INPUTFILE;
}


sub liftInlineTags($)
{
    my $line = shift;

    $line = liftRegex("<GR>(.*?)<\\/GR>", $line);
    $line = liftRegex("<abbr(.*?)>(.*?)<\\/abbr>", $line);

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


sub liftRegex($$)
{
    my $regex = shift;
    my $remainder = shift;
    my $result = "";
    while ($remainder =~ m/($regex)/)
    {
        my $before = $`;
        my $lifted = $1;
        $remainder = $';
        $liftedTags{$liftedTagCounter} = $lifted;
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


# Fix the nesting of <seg> tags relative to <hi> tags.
sub fixNesting($)
{
    my $line = shift;

    my $remainder = $line;
    my $result = "";

    my $stackSize = 0;
    my $maxStackSize = 0;
    my %tagStack = ();

    while ($remainder =~ m/<(\/?(?:hi|seg|ref))(.*?)>/)
    {
        my $before = $`;
        my $tag = $1;
        my $attrs = $2;
        $remainder = $';

        my $fullTag = "<$tag$attrs>";
        my $resultTag = $fullTag;

        if ($tag eq "hi" || $tag eq "ref")
        {
            $tagStack{$stackSize} = $fullTag;
            $stackSize++;
            if ($stackSize > $maxStackSize)
            {
                $maxStackSize = $stackSize;
            }
        }
        elsif ($tag eq "/hi" || $tag eq "/ref")
        {
            $stackSize--;
        }
        elsif ($tag eq "seg" || $tag eq "/seg")
        {
            if ($stackSize > 0)
            {
                # close all <hi> tags on the stack, and reopen.
                my $stackPointer = $stackSize;
                $resultTag = "";
                while ($stackPointer > 0)
                {
					my $closeTag = $tagStack{$stackPointer - 1} =~ /^<ref/ ? "</ref>" : "</hi>";

                    $resultTag .= $closeTag;
                    $stackPointer--;
                }
                $resultTag .= $fullTag;

                while ($stackPointer <= $stackSize)
                {
                    $resultTag .= $tagStack{$stackPointer};
                    $stackPointer++;
                }
            }
        }
        $result .= $before . $resultTag;
    }
    $result .= $remainder;

    # Eliminate pointless <hi> </hi> sequences (cannot see italic spaces anyway).
    for (my $i = $maxStackSize; $i > 0; $i--)
    {
        $result =~ s/<hi([^>]*?)>(\s*)<\/hi>/\2/g;
        $result =~ s/<ref([^>]*?)>(\s*)<\/ref>/\2/g;
    }

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
    my $dutchSpecial = "(?:\\&apos;|\\')[tn]";

    my $sentenceStarter = "($punctuationOpen)*($dutchSpecial\\s+)?($upperCaseLetter)";

    $text =~ s/([:,])( +)/$1$mark$2/g;

    $text =~ s/([?!])( +)($sentenceStarter)/$1$mark$2$3/g;
    $text =~ s/(\.[\.]+)( +)($sentenceStarter)/$1$mark$2$3/g;
    $text =~ s/([?!\.](?:$punctuationClose+))( +)($sentenceStarter)/$1$mark$2$3/g;

    my @words = split(/(\s+)/, $text);
    my $i;
    my $result = "";
    for ($i = 0; $i < (scalar(@words) - 1); $i++)
    {
        my $word = $words[$i];
        my $nextWord = defined($words[$i + 2]) ? $words[$i + 2] : '';
        my $thirdWord = defined($words[$i + 4]) ? $words[$i + 4] : '';

        # Does the 'word' end with a ;, but is not an SGML entity?
        if ($word =~ /;$/ && !($word =~ /\&[A-Za-z0-9]+;$/))
        {
            $result .= $word . $mark;
        }
        elsif ($word =~ /(($alphaNum|\&apos;|[\.\-])+)($punctuationClose*)(\.+)$/)
        {
            # Is the word an abbreviation or a (set of) initials?
            if (isAbbreviation($word) || $word =~ /^($upperCaseLetter\.)+$/)
            {
                $result .= $word;
            }
            # Does the following 'word' start with a sentence starter?
            elsif ($nextWord =~ /^$upperCaseLetter/)
            {
                $result .= $word . $mark;
            }
            # Do we have the Dutch special case ('t Was or 'n Huis)?
            elsif ($nextWord =~ /^$dutchSpecial$/ && $thirdWord =~ /^$upperCaseLetter/)
            {
                $result .= $word . $mark;
            }
            else
            {
                $result .= $word;
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

	# Move whitespace out of segments where possible.
    $result =~ s/(\s+)(<\/seg>)/\2\1/g;
    $result =~ s/(<seg[^>]*?>)(\s+)/\2\1/g;

    $result = fixNesting($result);

    return $result;
}


sub startSegment()
{
    my $counter = $segmentCounter;
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



main();
