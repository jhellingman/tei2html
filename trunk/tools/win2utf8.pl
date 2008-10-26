# win2utf8.pl -- convert a windows cp1252 encoded file to Unicode.

use utf8;

binmode(STDOUT, ":utf8");

$infile = $ARGV[0];
open (INPUTFILE, $infile) || die("Could not open input file $infile");
binmode(INPUTFILE, ":encoding(cp1252)");

while (<INPUTFILE>)
{
	print;
}

close INPUTFILE;
