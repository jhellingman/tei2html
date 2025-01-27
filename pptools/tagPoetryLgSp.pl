# poetry.pl -- add <l> tags on new-lines in poetry / drama, based on the presence of <lg> or <sp> tags.

use strict;
use warnings;

my $initialSpaceCount = 0;
my $initialSpaces = ' ' x $initialSpaceCount;

my $lgSeen = 0;
my $spSeen = 0;
my $spLooksLikeProse = 0;
my $lineNumber = 0;


while (<>) {
    my $line = $_;
    $lineNumber++;

    if ($line =~ /^<lg>$/) {
        if ($spSeen > 0) {
            print STDERR "WARNING: entering <lg> inside <sp> on line $lineNumber!\n";
        }
        if ($lgSeen > 0) {
            print STDERR "WARNING: entering nested <lg> ($lgSeen) on line $lineNumber!\n";
        }
        $lgSeen++;
        print "<lg>\n";

    } elsif ($line =~ /^<\/lg>$/) {
        if ($lgSeen == 0) {
            print STDERR "ERROR: unmatched </lg> on line $lineNumber!\n";
        } else {
            $lgSeen--;
        }
        print "</lg>\n";

    } elsif ($line =~ /^(<sp\b.*?>)/) {
        my $tag = $1;
        if ($lgSeen > 0) {
            print STDERR "WARNING: entering $tag inside <lg> on line $lineNumber!\n";
        }
        if ($spSeen > 0) {
            print STDERR "WARNING: entering $tag inside <sp> on line $lineNumber!\n";
        } else {
            $spLooksLikeProse = 0;
        }
        $spSeen++;
        print $line;

    } elsif ($line =~ /^<\/sp>$/) {
        if ($spSeen == 0) {
            print STDERR "ERROR: unmatched </sp> mode on line $lineNumber!\n";
        } else {
            $spSeen--;
        }
        print "</sp>\n";


    } elsif ($lgSeen == 0 && $spSeen == 0 || ($spSeen > 0 && $spLooksLikeProse == 1)) {
        print $line;

    } elsif ($line =~ /^<speaker/) {
        print $line;

    } else {
        if ($spSeen > 0 && $line =~ /^[a-z]/) {
            print STDERR "WARNING: <sp> looks like prose on line $lineNumber!\n";
            $spLooksLikeProse = 1;
            print $line;
        } elsif ($line =~ /^\s*$/) {
            # blank line in poetry mode:

            print "</lg>\n\n<lg>\n";
        } elsif ($line =~ /^\s*<l>/) {  # Already tagged
            print $line;
        } else {            
            # count white space before
            $line =~ /^(\s*)(.*)$/;
            my $spaces = $1;
            $line = $2;
            my $n = length($spaces);
            if ($n == 0) {
                print "$initialSpaces<l>$line\n";
            } else {
                print "$initialSpaces$spaces<l rend=\"indent($n)\">$line\n";
            }
        }
    }
}

if ($spSeen != 0) {
    print STDERR "ERROR: open <sp> tags ($spSeen) at end of file!\n"
}

if ($lgSeen != 0) {
    print STDERR "ERROR: open <lg> tags ($lgSeen) at end of file!\n"
}

