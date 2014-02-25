# smallcaps.pl -- tag words in all uppercase with <sc>...</sc>

# Handle Arguments
$infile = $ARGV[0];
open(INPUTFILE, $infile) || die("Could not open input file $infile");

# Set variables

$accLetter = "(\\&[A-Za-z](acute|grave|circ|uml|cedil|tilde|slash|ring|dotb|macr|breve);)";
$ligLetter = "(\\&[A-Za-z]{2}lig;)";
$specLetter = "(\\&apos;|\\&eth;|\\&ETH;|\\&thorn;|\\&THORN;|\\&alif;|\\&ayn;|\\&prime;)";
$letter = "(\\w|$accLetter|$ligLetter|$specLetter)";
$wordPattern = "($letter)+(([-']|&rsquo;|&apos;)($letter)+)*";
$nonLetter = "\\&(amp|ldquo|rdquo|lsquo|mdash|hellips|gt|lt|frac[0-9][0-9]);";

$UCaccLetter = "(\\&[A-Z](acute|grave|circ|uml|cedil|tilde|slash|ring|dotb|macr|breve);)";
$UCligLetter = "(\\&[A-Z]{2}lig;)";
$UCspecLetter = "(\\&apos;|\\&ETH;|\\&THORN;|\\&alif;|\\&ayn;|\\&prime;)";
$UCletter = "([A-Z]|$UCaccLetter|$UCligLetter|$UCspecLetter)";
$UCwordPattern = "\\b($UCletter)+(([-']|&rsquo;|&apos;)($UCletter)+)*\\b";


while (<INPUTFILE>)
{
    $remainder = $_;
    while($remainder =~ /($UCwordPattern)/)
    {
        print $`;
        $remainder = $';
        $word = $&;
        if (length($word) > 1) 
        {
            if ($word =~ /^[IVXLCDM]+$/) 
            {
                print $word;
            }
            else
            {
                print "<sc>" . ucfirst(lc($word)) . "</sc>";
            }
        }
        else
        {
            print $word;
        }
    }
    print $remainder;
}
