# modernize.pl -- modernize text in old Dutch spelling

use strict;

use utf8;
# binmode(STDOUT, ":utf8");
use open ':utf8';

require Encode;
use Unicode::Normalize;
use DBI;

use Roman;      # Roman.pm version 1.1 by OZAWA Sakuro <ozawa@aisoft.co.jp>

use SgmlSupport qw/getAttrVal sgml2utf/;
use LanguageNames qw/getLanguage/;


my %dictHash = ();
my %wordsHash = ();
my %langHash = ();
my @stackTag = ();
my @stackLang = ();

my $langStackSize = 0;
my $changed = 0;

my $tagPattern = "(<.*?>)";



my $infile = $ARGV[0];

loadDictionary("C:\\Users\\Jeroen\\Documents\\eLibrary\\Tools\\tei2html\\tools\\dictionaries\\nl_NL_1900_changes.txt");
loadDictionary("modernize-list.txt");

modernizeText($infile);

print STDERR "NOTICE:  Changed $changed words\n";



sub loadWords($)
{
	my $file = shift;
	open(WORDSFILE, "<:encoding(iso-8859-1)", "$file") || die ("ERROR: Could not open input file $file");

    my $count = 0;
    while (<WORDSFILE>)
    {
        my $word =  $_;
		chomp $word;
		$wordsHash{$word} = 1;
		$count++;
    }
    print STDERR "NOTICE:  Loaded dictionary: $file with $count words\n";
    close(WORDSFILE);
}



sub loadDictionary($)
{
	my $file = shift;
	open(DICTFILE, "<:encoding(iso-8859-1)", "$file") || die ("ERROR: Could not open input file $file");

    my $count = 0;
    while (<DICTFILE>)
    {
        my $line =  $_;
		chomp $line;
		$line =~ /^(.*?)\t(.*)$/;
		my $oldWord = $1;
		my $newWord = $2;

		if ($newWord ne '' && $newWord ne '~' && $newWord ne $oldWord)
		{
			# print "$oldWord -> $newWord\n";
			$dictHash{$oldWord} = $newWord;
			$count++;
		}
    }
    print STDERR "NOTICE:  Loaded dictionary: $file with $count changed words\n";
    close(DICTFILE);
}


#
# modernizeText
#
sub modernizeText()
{
    open (INPUTFILE, "<:encoding(iso-8859-1)", $infile) || die("ERROR: Could not open input file $infile");

    while (<INPUTFILE>)
    {
        my $remainder = $_;

        while ($remainder =~ /$tagPattern/)
        {
            my $fragment = $`;
            my $tag = $1;
            $remainder = $';
            handleFragment($fragment);
            # handleTag($tag, $remainder);
			print $tag;
        }
        handleFragment($remainder);
    }

    close (INPUTFILE);
}


#
# handleFragment: split a text fragment into words and insert them
# in the wordlist.
#
sub handleFragment($)
{
    my $fragment = shift;
    # $fragment = NFC(sgml2utf($fragment));

    my $lang = getLang();

    # NOTE: we don't use \w and \W here, since it gives some unexpected results
    my @words = split(/([^\pL\pN\pM-]+)/, $fragment);
    foreach my $word (@words)
    {
		if ($dictHash{$word} ne '')
		{
			print $dictHash{$word};
			$changed++;
		}
		else
		{
			print $word;
		}
    }
}


#
# handleTag: push/pop an XML tag on the tag-stack.
#
sub handleTag($$)
{
    my $tag = shift;
    my $remainder = shift;

    # end tag or start tag?
    if ($tag =~ /^[!?]/)
    {
        # Comment or processing instruction, don't care.
    }
    elsif ($tag =~ /^\/([a-zA-Z0-9_.-]+)/)
    {
        my $element = $1;
        popLang($element, $remainder);
    }
    elsif ($tag =~ /\/$/)
    {
        # Empty element
        $tag =~ /^([a-zA-Z0-9_.-]+)/;
    }
    else
    {
        $tag =~ /^([a-zA-Z0-9_.-]+)/;
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
    }
}


#==============================================================================
#
# popLang: pop from the tag-stack when a tag is closed.
#
sub popLang($)
{
    my $tag = shift;
    my $remainder = shift;

    if ($langStackSize > 0 && $tag eq $stackTag[$langStackSize])
    {
        $langStackSize--;
    }
    else
    {
        die("ERROR: XML not well-formed (found closing tag '$tag' that was not opened; remainder: $remainder)");
    }
}

#
# pushLang: push on the tag-stack when a tag is opened
#
sub pushLang($$)
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
sub getLang()
{
    return $stackLang[$langStackSize];
}

