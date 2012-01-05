# tei2txt.pl -- TEI to plain vanilla ASCII text

use strict;
use SgmlSupport qw/getAttrVal sgml2utf/;


my $tagPattern = "<(.*?)>";
my $italicStart = "_";
my $italicEnd = "_";


if (1 == 1)
{
    $italicStart = "";
    $italicEnd = "";
}


#
# Main program loop
#

while (<>)
{
    my $a = $_;

    # remove TeiHeader
    if ($a =~ /<[Tt]ei[Hh]eader/)
    {
        $a = $';
        while($a !~ /<\/[Tt]ei[Hh]eader>/)
        {
            $a = <>;
        }
        $a =~ /<\/[Tt]ei[Hh]eader>/;
        $a = $';
    }

    # drop comments from text (replace with single space).
    $a =~ s/<!--.*?-->/ /g;
    # warn for remaining comments
    $a =~ s/<!--/[ERROR: unhandled comment start]/g;

    # warn for notes (which should have been handled in a separate process)
    $a =~ s/<note\b.*?>/[ERROR: unhandled note start tag]/g;
    $a =~ s/<\/note\b.*?>/[ERROR: unhandled note end tag]/g;

    # generate part headings
    if ($a =~ /<(div0.*?)>/)
    {
        my $tag = $1;
        my $partNumber = getAttrVal("n", $tag);
        if ($partNumber ne "")
        {
            print "\nPART $partNumber\n";
        }
    }

    # generate chapter headings
    if ($a =~ /<(div1.*?)>/)
    {
        my $tag = $1;
        my $chapterNumber = getAttrVal("n", $tag);
        if ($chapterNumber ne "")
        {
            print "\nCHAPTER $chapterNumber\n";
        }
    }

    # generate section headings
    if ($a =~ /<(div2.*?)>/)
    {
        my $tag = $1;
        my $sectionNumber = getAttrVal("n", $tag);
        if ($sectionNumber ne "")
        {
            print "\nSECTION $sectionNumber\n";
        }
    }

    # generate figure headings
    if ($a =~ /<(figure.*?)>/)
    {
        my $tag = $1;
        my $figureNumber = getAttrVal("n", $tag);
        print "\n------\nFIGURE $figureNumber\n";
    }
    if ($a =~ /<\/figure>/)
    {
        print "------\n";
    }

    # indicate tables for manual processing.
    if ($a =~ /<table.*?>/)
    {
        print "\n------\nTABLE\n";
    }
    if ($a =~ /<\/table>/)
    {
        print "------\n";
    }


    # convert entities
    $a = entities2iso88591($a);


    # handle italics (with underscores)
    my $remainder = $a;
    $a = "";
    while ($remainder =~ /<hi(.*?)>(.*?)<\/hi>/)
    {
        my $attrs = $1;
        my $rend = getAttrVal("rend", $attrs);
        if ($rend eq "sup")
        {
            $a .= $` . $2;
        }
        elsif ($rend eq "sc" || $rend eq "expanded")
        {
            $a .= $` . $2;
        }
        else
        {
            $a .= $` . $italicStart . $2 . $italicEnd;
        }
        $remainder = $';
    }
    $a .= $remainder;

    # handle cell boundaries
    $a =~ s/<cell(.*?)>/|/g;

    # drop page-breaks (<pb>) as they interfere with the following processing.
    $a =~ s/<pb\b(.*?)>//g;

    # handle numbered lines of verse
    if ($a =~ /( +)<l\b(.*?)>/)
    {
        my $prefix = $`;
        my $remainder = $';
        my $spaces = $1;
        my $attrs = $2;
        my $n = getAttrVal("n", $attrs);
        if ($n)
        {
            my $need = length($spaces) - length($n);
            my $need = $need < 1 ? 1 : $need;
            $a = $prefix . $n . spaces($need) . $remainder;
        }
    }

    # remove any remaining tags
    $a =~ s/<.*?>//g;

	# Some problematic ones from Wolff.
    $a =~ s/\&larr;/<-/g;	# Left Arrow
    $a =~ s/\&rarr;/->/g;	# Right Arrow

    # warn for entities that slipped through.
    if ($a =~ /\&([a-zA-Z0-9._-]+);/)
    {
        my $ent = $1;
        if (!($ent eq "gt" || $ent eq "lt" || $ent eq "amp"))
        {
            print "\n[ERROR: Contains unhandled entity &$ent;]\n";
        }
    }

    # remove the last remaining entities
    $a =~ s/\&gt;/>/g;
    $a =~ s/\&lt;/</g;
    $a =~ s/\&amp;/&/g;


    # warn for anything that slipped through.
    # BUG: if for example &c; should appear in the output, a bug will be reported
    # $a =~ s/\&\w+;/[ERROR: unhandled $&]/g;

    print $a;
}


sub spaces($)
{
    my $n = shift;
    my $result = "";
    for (my $i = 0; $i < $n; $i++) 
    {
        $result .= " ";
    }
    return $result;
}



#
# entities2iso88591: Convert SGML style entities to ISO 8859-1 values (if available)
#
sub entities2iso88591($)
{
    my $a = shift;

    # change supported accented letters:
    $a =~ s/\&aacute;/á/g;
    $a =~ s/\&Aacute;/Á/g;
    $a =~ s/\&agrave;/à/g;
    $a =~ s/\&Agrave;/À/g;
    $a =~ s/\&acirc;/â/g;
    $a =~ s/\&Acirc;/Â/g;
    $a =~ s/\&atilde;/ã/g;
    $a =~ s/\&Atilde;/Ã/g;
    $a =~ s/\&auml;/ä/g;
    $a =~ s/\&Auml;/Ä/g;
    $a =~ s/\&aring;/å/g;
    $a =~ s/\&Aring;/Å/g;
    $a =~ s/\&aelig;/æ/g;
    $a =~ s/\&AElig;/Æ/g;

    $a =~ s/\&ccedil;/ç/g;
    $a =~ s/\&Ccedil;/Ç/g;

    $a =~ s/\&eacute;/é/g;
    $a =~ s/\&Eacute;/É/g;
    $a =~ s/\&egrave;/è/g;
    $a =~ s/\&Egrave;/È/g;
    $a =~ s/\&ecirc;/ê/g;
    $a =~ s/\&Ecirc;/Ê/g;
    $a =~ s/\&euml;/ë/g;
    $a =~ s/\&Euml;/Ë/g;

    $a =~ s/\&iacute;/í/g;
    $a =~ s/\&Iacute;/Í/g;
    $a =~ s/\&igrave;/ì/g;
    $a =~ s/\&Igrave;/Ì/g;
    $a =~ s/\&icirc;/î/g;
    $a =~ s/\&Icirc;/Î/g;
    $a =~ s/\&iuml;/ï/g;
    $a =~ s/\&Iuml;/Ï/g;

    $a =~ s/\&ntilde;/ñ/g;
    $a =~ s/\&Ntilde;/Ñ/g;

    $a =~ s/\&oacute;/ó/g;
    $a =~ s/\&Oacute;/Ó/g;
    $a =~ s/\&ograve;/ò/g;
    $a =~ s/\&Ograve;/Ò/g;
    $a =~ s/\&ocirc;/ô/g;
    $a =~ s/\&Ocirc;/Ô/g;
    $a =~ s/\&otilde;/õ/g;
    $a =~ s/\&Otilde;/Õ/g;
    $a =~ s/\&ouml;/ö/g;
    $a =~ s/\&Ouml;/Ö/g;
    $a =~ s/\&oslash;/ø/g;
    $a =~ s/\&Oslash;/Ø/g;

    $a =~ s/\&uacute;/ú/g;
    $a =~ s/\&Uacute;/Ú/g;
    $a =~ s/\&ugrave;/ù/g;
    $a =~ s/\&Ugrave;/Ù/g;
    $a =~ s/\&ucirc;/û/g;
    $a =~ s/\&Ucirc;/Û/g;
    $a =~ s/\&uuml;/ü/g;
    $a =~ s/\&Uuml;/Ü/g;

    $a =~ s/\&yacute;/ý/g;
    $a =~ s/\&Yacute;/Ý/g;
    $a =~ s/\&yuml;/ÿ/g;

    $a =~ s/\&fnof;/ƒ/g;
    $a =~ s/\&pound;/£/g;
    $a =~ s/\&deg;/°/g;
    $a =~ s/\&ordf;/ª/g;
    $a =~ s/\&ordm;/º/g;
    $a =~ s/\&dagger;/†/g;
    $a =~ s/\&para;/¶/g;
    $a =~ s/\&sect;/§/g;
    $a =~ s/\&iquest;/¿/g;

    $a =~ s/\&laquo;/«/g;
    $a =~ s/\&raquo;/»/g;

    # remove accented and special letters
    $a =~ s/\&eth;/dh/g;
    $a =~ s/\&ETH;/Dh/g;
    $a =~ s/\&thorn;/th/g;
    $a =~ s/\&THORN;/Th/g;
    $a =~ s/\&mdash;/--/g;
    $a =~ s/\&ndash;/-/g;
    $a =~ s/\&longdash;/----/g;
    $a =~ s/\&supndash;/-/g;
    $a =~ s/\&ldquo;/"/g;
    $a =~ s/\&bdquo;/"/g;
    $a =~ s/\&rdquo;/"/g;
    $a =~ s/\&lsquo;/'/g;
    $a =~ s/\&rsquo;/'/g;
    $a =~ s/\&sbquo;/'/g;
    $a =~ s/\&hellip;/.../g;
    $a =~ s/\&thinsp;/ /g;
    $a =~ s/\&nbsp;/ /g;
    $a =~ s/\&pound;/£/g;
    $a =~ s/\&dollar;/\$/g;
    $a =~ s/\&deg;/°/g;
    $a =~ s/\&dagger;/†/g;
    $a =~ s/\&para;/¶/g;
    $a =~ s/\&sect;/§/g;
    $a =~ s/\&commat;/@/g;
    $a =~ s/\&rbrace;/}/g;
    $a =~ s/\&lbrace;/{/g;


    # my additions
    $a =~ s/\&eringb;/e/g;
    $a =~ s/\&oubb;/ö/g;
    $a =~ s/\&oudb;/ö/g;

    $a =~ s/\&osupe;/ö/g;
    $a =~ s/\&usupe;/ü/g;

    $a =~ s/\&flat;/-flat/g;
    $a =~ s/\&sharp;/-sharp/g;
    $a =~ s/\&natur;/-natural/g;
    $a =~ s/\&Sun;/[Sun]/g;

    $a =~ s/\&ghbarb;/gh/g;
    $a =~ s/\&Ghbarb;/Gh/g;
    $a =~ s/\&GHbarb;/GH/g;

    $a =~ s/\&khbarb;/kh/g;
    $a =~ s/\&Khbarb;/Kh/g;
    $a =~ s/\&KHbarb;/KH/g;

    $a =~ s/\&shbarb;/sh/g;
    $a =~ s/\&Shbarb;/Sh/g;
    $a =~ s/\&SHbarb;/SH/g;

    $a =~ s/\&zhbarb;/zh/g;
    $a =~ s/\&Zhbarb;/Zh/g;
    $a =~ s/\&ZHbarb;/ZH/g;

    $a =~ s/\&ayin;/`/g;
    $a =~ s/\&hamza;/'/g;

    $a =~ s/\&amacrdotb;/a/g;

    $a =~ s/\&oumlcirc;/ö/g;

    $a =~ s/\&imacacu;/í/g;
    $a =~ s/\&omacacu;/ó/g;

    $a =~ s/\&longs;/s/g;
    $a =~ s/\&prime;/'/g;
    $a =~ s/\&Prime;/''/g;
    $a =~ s/\&times;/×/g;
    $a =~ s/\&plusm;/±/g;
    $a =~ s/\&divide;/÷/g;
    $a =~ s/\&plusmn;/±/g;
    $a =~ s/\&peso;/P/g;
    $a =~ s/\&Peso;/P/g;
    $a =~ s/\&ngtilde;/ng/g;
    $a =~ s/\&apos;/'/g;
    $a =~ s/\&sup([0-9a-zA-Z]);/$1/g;
    $a =~ s/\&supth;/th/g;
    $a =~ s/\&iexcl;/¡/g;
    $a =~ s/\&iquest;/¿/g;
    $a =~ s/\&lb;/lb/g;
    $a =~ s/\&dotfil;/.../g;
    $a =~ s/\&dotfiller;/........./g;
    $a =~ s/\&middot;/·/g;
    $a =~ s/\&aeacute;/æ/g;
    $a =~ s/\&AEacute;/Æ/g;
    $a =~ s/\&oeacute;/oe/g;
    $a =~ s/\&cslash;/¢/g;
    $a =~ s/\&grchi;/x/g;
    $a =~ s/\&omactil;/o/g;
    $a =~ s/\&ebreacu;/e/g;
    $a =~ s/\&amacacu;/a/g;
    $a =~ s/\&ymacr;/y/g;
    $a =~ s/\&eng;/ng/g;
    $a =~ s/\&Rs;/Rs/g;     # Rupee sign.
    $a =~ s/\&tb;/\n\n/g;   # Thematic Break;

    $a =~ s/\&triangle;/[triangle]/g;
    $a =~ s/\&bullet;/·/g;

    $a =~ s/CI\&Crev;/M/g;  # roman numeral CI reverse C -> M
    $a =~ s/I\&Crev;/D/g;   # roman numeral I reverse C -> D

    $a =~ s/\&ptildeb;/p/g;
    $a =~ s/\&special;/[symbol]/g;

    $a =~ s/\&florin;/f/g;  # florin sign
    $a =~ s/\&apos;/'/g;    # apostrophe
    $a =~ s/\&emsp;/  /g;   # em-space
    $a =~ s/\&male;/[male]/g;   # male
    $a =~ s/\&female;/[female]/g;   # female
    $a =~ s/\&Lambda;/[Lambda]/g;   # Greek capital letter lambda
    $a =~ s/\&Esmall;/e/g;  # small capital letter E (used as small letter)
    $a =~ s/\&ast;/*/g; # asterix

    $a =~ s/\&there4;/./g;	# Therefor (three dots in triangular arrangement) used as abbreviation dot.
    $a =~ s/\&maltese;/[+]/g;	# Maltese Cross




    # strip accents from remaining entities
    $a =~ s/\&([a-zA-Z])(breve|macr|acute|grave|uml|umlb|tilde|circ|cedil|dotb|dot|breveb|caron|comma|barb|circb|bowb);/$1/g;
    $a =~ s/\&([a-zA-Z]{2})lig;/$1/g;
    $a =~ s/([0-9])\&frac([0-9])([0-9]*);/$1 $2\/$3/g;  # fraction preceded by number
    $a =~ s/\&frac([0-9])([0-9]*);/$1\/$2/g; # other fractions
    $a =~ s/\&frac([0-9])-([0-9]*);/$1\/$2/g; # other fractions
    $a =~ s/\&frac([0-9]+)-([0-9]*);/$1\/$2/g; # other fractions

    return $a;
}


