# tagGreek.pl -- tag sequences of Unicode Greek script.

use strict;

my $before = "<foreign lang='grc'>";
my $after = "</foreign>";

# Pattern: Greek (Neutral Greek)+

my $file = $ARGV[0];

open(INPUTFILE, '<:encoding(UTF-8)', $file) || die("Could not open input file $file");
open(OUTPUTFILE, "> tmp-1.txt") || die("Could not open tmp-1.txt for writing.");
binmode(OUTPUTFILE, ":utf8");

my $regex = "[\p{Greek}]+([ ,.;?:]+[\p{Greek}]+)*";

while (<INPUTFILE>) {

    $_ =~ s/([\p{Greek}]+([ ,.]+[\p{Greek}]+)*)/$before$1$after/g;

    print OUTPUTFILE $_;
}

close OUTPUTFILE;
