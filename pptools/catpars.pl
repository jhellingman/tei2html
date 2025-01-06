# catpars.pl -- remove line-breaks in paragraphs.

use strict;
use warnings;

my $infile = $ARGV[0];
open(INPUTFILE, $infile) || die("Could not open input file $infile");

my $mode = "normal";    # normal | concat
my $lineCount = 0;

while (<INPUTFILE>) {
    my $line = $_;
    $lineCount++;
    if ($mode eq "normal") {
        if ($line =~ /^(<speaker\b[^>]*>.*<\/speaker> +)?(<pb\b([^>]*)>)?(<q\b([^>]*)>)?<p\b([^>]*)>/) {
            print stripNewline($line);
            warnForSuspects($line);
            $mode = "concat";
        } else {
            print $line;
        }
    } elsif ($mode eq "concat") {

        warnForSuspects($line);

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


sub warnForSuspects {
    my $line = shift;
    if ($line =~ /<(table|list|figure)/) {
        my $suspectElement = $1;
        print STDERR "WARNING: paragraph contains $suspectElement element near line $lineCount.\n";
    }
}


sub stripNewline {
    my $str = shift;
    $str =~ s/\n/ /g;
    return $str;
}
