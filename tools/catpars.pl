# catpars.pl -- remove line-breaks in paragraphs.

use strict;
use warnings;

my $infile = $ARGV[0];
open(INPUTFILE, $infile) || die("Could not open input file $infile");

my $mode = "normal";    # normal | concat

while (<INPUTFILE>) {
    my $line = $_;
    if ($mode eq "normal") {
        if ($line =~ /^(<pb\b([^>]*)>)?(<q\b([^>]*)>)?<p\b([^>]*)>/) {
            print stripNewline($line);
            $mode = "concat";
        } else {
            print $line;
        }
    } elsif ($mode eq "concat") {
        if ($line =~ /^(<pb\b([^>]*)>)?<p\b([^>]*)>/) {
            print "\n\n";
            print stripNewline($line);
        } elsif ($line =~ /^\s$/) {
            $mode = "normal";
            print "\n" . $line;
        } else {
            print stripNewline($line);
        }
    }
}


sub stripNewline($) {
    my $str = shift;
    $str =~ s/\n/ /g;
    return $str;
}
