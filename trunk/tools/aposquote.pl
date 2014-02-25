# aposquote.pl -- script to disambiguate single quotation marks, 

use strict;

my $inputFile = $ARGV[0];

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

print STDERR "Handling $inputFile\n";

while (<INPUTFILE>)
{
    my $line = $_;
    $line = disambiguateQuotes($line);
    print $line;
}


sub disambiguateQuotes($)
{
    my $line = shift;

    # After interpunction is most likely a close-quote:
    $line =~ s/([.,:;?!])'(\s+)/\1\&rsquo;\2/gi;        # following spaces
    $line =~ s/([.,:;?!])'(<)/\1\&rsquo;\2/gi;          # following tag

    # [Dutch Articles] before stand-alone t, s, k, or n is most likely apostrophe:
    $line =~ s/(\s+)'([tskn] )/\1\&apos;\2/gi;

    # [Abbreviated Years] Before exactly two digits is most likely an apostrophe:
    $line =~ s/'([0-9][0-9][^0-9])/\&apos;\1/gi;

    # [Feet or Minutes] after digits is most likely a prime:
    $line =~ s/([0-9])'(\s+)/\1\&prime;\2/gi;

    # But if their is a space it is most likely an open-quote:
    $line =~ s/([.,:;?!]\s+)'([a-z])/\1\&lsquo;\2/gi;

    # After open brace is most likely open-quote:
    $line =~ s/([({])'/\1\&lsquo;/gi;

    # Before close brace is most likely close-quote:
    $line =~ s/'([})])/\&rsquo;\1/gi;

    # Around em-dash:
    $line =~ s/(&mdash;)'/\1\&lsquo;/gi;
    $line =~ s/'(&mdash;)/\&rsquo;\1/gi;

    # Between letters is most likely apostrophe:
    $line =~ s/([a-z])'([a-z])/\1\&apos;\2/gi;

    # After space is most likely open-quote:
    $line =~ s/(\s+)'([a-z])/\1\&lsquo;\2/gi;

    # After <p>- or <l>-tag is most likely open-quote:
    $line =~ s/(<[pl]>)'([a-z])/\1\&lsquo;\2/gi;

    # Arround <hi>...</hi> markup:
    $line =~ s/( <hi>)'([a-z])/\1\&lsquo;\2/gi;
    $line =~ s/( )'(<hi>[a-z])/\1\&lsquo;\2/gi;

    $line =~ s/([a-z]<\/hi>)'( )/\1\&rsquo;\2/gi;
    $line =~ s/([a-z])'(<\/hi> )/\1\&rsquo;\2/gi;

    return $line;
}



