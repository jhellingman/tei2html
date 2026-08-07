# catpars.pl -- remove line-breaks in paragraphs.

use v5.36;

my $infile = $ARGV[0];
open my $fh, '<', $infile or die("Could not open input file $infile");

my $mode = "normal";    # normal | concat
my $lineCount = 0;

while (<$fh>) {
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

sub warnForSuspects($line) {
    if ($line =~ /<(table|list|figure)/) {
        my $suspectElement = $1;
        print STDERR "WARNING: paragraph contains $suspectElement element near line $lineCount.\n";
    }
}

sub stripNewline($str) {
    $str =~ s/\n/ /g;
    return $str;
}
