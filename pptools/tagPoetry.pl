# poetry.pl

use strict;
use warnings;

my $poetryMode = 0;

my $lineNumber = 0;

while (<>) {
    my $line = $_;
    $lineNumber++;

    if ($line =~ /\/\*/) {
        if ($poetryMode == 1) {
            print STDERR "WARNING: entering poetry mode again on line $lineNumber!\n"
        }
        $poetryMode = 1;
        print "<lg>\n";
    } elsif ($line =~ /\*\//) {
        if ($poetryMode == 0) {
            print STDERR "WARNING: leaving poetry mode again on line $lineNumber!\n"
        }
        $poetryMode = 0;
        print "</lg>\n";
    } elsif ($poetryMode == 0) {
        if ($line =~ /\*\//) {
            print STDERR "WARNING: */ outside poetry mode at line $lineNumber!\n"
        }
        print $line;
    } else {
        if ($line =~ /<p>/) {
            print STDERR "WARNING: <p> in poetry mode at line $lineNumber!\n"
        }
        if ($line =~ /\*\//) {
            print STDERR "WARNING: /* in poetry mode at line $lineNumber!\n"
        }
        # blank line in poetry mode:
        if ($line =~ /^\s*$/) {
            print "</lg>\n\n<lg>\n";
        } else {
            # count white space before
            $line =~ /^(\s*)(.*)$/;
            my $spaces = $1;
            $line = $2;
            my $n = length($spaces);
            if ($n == 0) {
                print "    <l>$line\n";
            } else {
                print "    $spaces<l rend=\"indent($n)\">$line\n";
            }
        }
    }
}
