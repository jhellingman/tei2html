# poetry.pl

use strict;
use warnings;

my $poetryMode = 0;

while (<>) {
    my $line = $_;
    if ($line =~ /\/\*/) {
        $poetryMode = 1;
        print "<lg>\n";
    } elsif ($line =~ /\*\//) {
        $poetryMode = 0;
        print "</lg>\n";
    } elsif ($poetryMode == 0) {
        print $line;
    } else {
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
