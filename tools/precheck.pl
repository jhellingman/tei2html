# precheck.pl -- Small modifications to TEI file to make checks work better.

# Turn &apos; into &mlapos; (modifier letter apostrophe) to distinguish them from &rsquo;
# Hide intentionally unmatched pairs        &lpar;   &rpar;   &lsqb;   &rsqb;   &lcub;   &rcub;
# by mapping them to the full-width block:  &#xFF08; &#xFF09; &#xFF3B; &#xFF3D; &#xFF5B; &#xFF5B;

# Hide special characters intetionally 'hidden' by entities.
# &num; -> #xFF03;

while (<>) {

    $a = $_;

    $a =~ s/\&apos;/\&mlapos;/g;    # modifier letter apostrophe

    $a =~ s/\&lpar;/\&#xFF08;/g;    # left parenthesis
    $a =~ s/\&rpar;/\&#xFF09;/g;    # right parenthesis

    $a =~ s/\&lsqb;/\&#xFF3B;/g;    # left square bracket
    $a =~ s/\&rsqb;/\&#xFF3D;/g;    # right square bracket

    $a =~ s/\&lcub;/\&#xFF5B;/g;    # left curly bracket
    $a =~ s/\&rcub;/\&#xFF5B;/g;    # right curly bracket

    $a =~ s/\&num;/\&#xFF03;/g;     # number sign


    print $a;
}
