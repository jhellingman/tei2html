# quotes.pl -- Do smart quotes stuff.

use strict;
use warnings;

my $accLetter = "(?:\\&[A-Za-z](?:acute|grave|circ|uml|cedil|tilde|slash|ring|dotb|macr|breve);)";
my $ligLetter = "(?:\\&[A-Za-z]{2}lig;)";
my $specLetter = "(?:\\&eth;|\\&ETH;|\\&thorn;|\\&THORN;|\\&alif;|\\&ayn;|\\&prime;)";
my $letter = "(?:\\w|[��������������������������������������������������������������]|$accLetter|$ligLetter|$specLetter)";

my $wordPattern = "($letter)+(([-']|&apos;)($letter)+)*";

my $tagPattern = "<[^<]*?>";
my $transPattern = "<(AR|BO|CY|FA|GR|SA|UR|HE|HI|SY|DV)>.*?<\\/(AR|BO|CY|GR|FA|SA|UR|HE|HI|SY|DV)>";
my $formulaPattern = "<formula.*?>.*?<\\/formula>";
my $skipPattern = "(($transPattern)|($formulaPattern)|($tagPattern))";

curlyQuoteText();

sub curlyQuoteText {
    while (<>) {
        my $remainder = $_;

        $remainder = disambiguateSingleQuotesWithTags($remainder);

        while ($remainder =~ /$skipPattern/) {
            my $fragment = $`;
            my $skip = $1;
            $remainder = $';
            print curlyQuoteFragment($fragment);
            print $skip;
        }
        print curlyQuoteFragment($remainder);
    }
}

sub curlyQuoteFragment {
    my $fragment = shift;

    # open quotes
    $fragment =~ s/\"($wordPattern)/\&ldquo;$1/g;

    # close quotes
    $fragment =~ s/\"/&rdquo;/g;

    return disambiguateSingleQuotes($fragment);
}

sub disambiguateSingleQuotes {
    my $fragment = shift;

    # Around em-dash:
    $fragment =~ s/(&mdash;)'/$1\&lsquo;/gi;
    $fragment =~ s/'(&mdash;)/\&rsquo;$1/gi;

    # After punctuation is most likely a close-quote:
    $fragment =~ s/([.,:;?!])'/$1\&rsquo;/gi;

    # [Dutch Articles] before stand-alone t, s, k, or n is most likely apostrophe:
    $fragment =~ s/(\s+)'([tskn] )/$1\&apos;$2/gi;
    $fragment =~ s/^'([tskn] )/\&apos;$1/gi;

    # [Abbreviated Years] Before exactly two digits is most likely an apostrophe:
    $fragment =~ s/'([0-9][0-9][^0-9])/\&apos;$1/gi;

    # [Feet or Minutes] after digits is most likely a prime:
    $fragment =~ s/([0-9])''(\s+)/$1\&Prime;$2/gi;
    $fragment =~ s/([0-9])'(\s+)/$1\&prime;$2/gi;

    # But if there is a space it is most likely an open-quote:
    $fragment =~ s/([.,:;?!]\s+)'($letter)/$1\&lsquo;$2/gi;

    # After open brace is most likely open-quote:
    $fragment =~ s/([({])'/$1\&lsquo;/gi;

    # Before close brace is most likely close-quote:
    $fragment =~ s/'([})])/\&rsquo;$1/gi;

    # Between letters is most likely apostrophe:
    $fragment =~ s/($letter)'($letter)/$1\&apos;$2/gi;

    # After space or at beginning of fragment is most likely open-quote:
    $fragment =~ s/(\s+)'($letter)/$1\&lsquo;$2/gi;
    $fragment =~ s/^'($letter)/\&lsquo;$1/gi;

    # After a letter, except s, it is most likely a close-quote:
    $fragment =~ s/([a-rt-z��������������������������������������������������������������])'/$1\&rsquo;/gi;

    return $fragment;
}


sub disambiguateSingleQuotesWithTags {
    my $fragment = shift;

    # Around <hi>...</hi> markup:
    $fragment =~ s/( <hi\b[^<>]*?>)'($letter)/$1\&lsquo;$2/gi;
    $fragment =~ s/( )'(<hi\b[^<>]*?>$letter)/$1\&lsquo;$2/gi;

    $fragment =~ s/($letter<\/hi>)'( )/$1\&rsquo;$2/gi;
    $fragment =~ s/($letter)'(<\/hi> )/$1\&rsquo;$2/gi;

    return $fragment;
}
