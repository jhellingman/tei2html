# precheck.pl -- Small modifications to TEI file to make checks work better.

# Turn &apos; into &mlapos; (modifier letter apostrophe) to distinguish them from &rsquo;
# Hide intentionally unmatched pairs        &lpar;   &rpar;   &lsqb;   &rsqb;   &lcub;   &rcub;
# by mapping them to the full-width block:  &#xFF08; &#xFF09; &#xFF3B; &#xFF3D; &#xFF5B; &#xFF5B;

# Hide special characters intentionally 'hidden' by entities.
# &num; -> #xFF03;

use strict;
use warnings;

while (<>) {

    my $line = $_;

    $line =~ s/\&apos;/\&mlapos;/g;    # modifier letter apostrophe

    $line =~ s/\&lpar;/\&#xFF08;/g;    # left parenthesis
    $line =~ s/\&rpar;/\&#xFF09;/g;    # right parenthesis

    $line =~ s/\&lsqb;/\&#xFF3B;/g;    # left square bracket
    $line =~ s/\&rsqb;/\&#xFF3D;/g;    # right square bracket

    $line =~ s/\&lcub;/\&#xFF5B;/g;    # left curly bracket
    $line =~ s/\&rcub;/\&#xFF5D;/g;    # right curly bracket

    $line =~ s/\&num;/\&#xFF03;/g;     # number sign

    print $line;
}
