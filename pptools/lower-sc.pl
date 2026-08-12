# lower-sc.pl -- make words between <sc>...</sc> lowercase;

use v5.36;

use Encode qw(encode decode);

my $encoding = 'latin-1';

my $infile = $ARGV[0]; 

open my $fh, '<', $infile or die "Could not open $infile: $!";

while (<$fh>) {
    my $remainder = $_;
    while ($remainder =~ /<sc>(.*?)<\/sc>/) {
        print $`;
        $remainder = $';
        my $smallCaps = decode($encoding, $1);
        print "<sc>" . lc($smallCaps) . "</sc>";
    }
    print $remainder;
}

close $fh;
