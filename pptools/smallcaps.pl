# smallcaps.pl -- tag words in all uppercase with <sc>...</sc>

use v5.36;

# Handle Arguments

my $infile = $ARGV[0];
open my $fh, '<', $infile or die "Could not open $infile: $!$";

# Set variables

my $accLetter = "(\\&[A-Za-z](acute|grave|circ|uml|cedil|tilde|slash|ring|dotb|macr|breve);)";
my $ligLetter = "(\\&[A-Za-z]{2}lig;)";
my $specLetter = "(\\&apos;|\\&eth;|\\&ETH;|\\&thorn;|\\&THORN;|\\&alif;|\\&ayn;|\\&prime;)";
my $letter = "(\\w|$accLetter|$ligLetter|$specLetter)";
my $wordPattern = "($letter)+(([-']|&rsquo;|&apos;)($letter)+)*";
my $nonLetter = "\\&(amp|ldquo|rdquo|lsquo|mdash|hellips|gt|lt|frac[0-9][0-9]);";

my $UCaccLetter = "(\\&[A-Z](acute|grave|circ|uml|cedil|tilde|slash|ring|dotb|macr|breve);)";
my $UCligLetter = "(\\&[A-Z]{2}lig;)";
my $UCspecLetter = "(\\&apos;|\\&ETH;|\\&THORN;|\\&alif;|\\&ayn;|\\&prime;)";
my $UCletter = "([A-Z]|$UCaccLetter|$UCligLetter|$UCspecLetter)";
my $UCwordPattern = "\\b($UCletter)+(([-']|&rsquo;|&apos;)($UCletter)+)*\\b";


while (<$fh>) {
    my $remainder = $_;
    while ($remainder =~ /($UCwordPattern)/) {
        print $`;
        $remainder = $';
        my $word = $&;
        if (length($word) > 1) {
            if ($word =~ /^[IVXLCDM]+$/) {
                print $word;
            } else {
                print "<sc>" . ucfirst(lc($word)) . "</sc>";
            }
        } else {
            print $word;
        }
    }
    print $remainder;
}

close $fh;
