
use strict;
use warnings;

use Getopt::Long;
use Text::Wrap;

my $useUnicode = 0;

GetOptions('u' => \$useUnicode);

$Text::Wrap::columns = 72;

if ($useUnicode == 1) {
    binmode(STDOUT, ":encoding(UTF-8)");
    use open ':encoding(UTF-8)';
}

while (<>) {
    my $line = $_;

    $line =~ /^(\s*)(.*)([\r\n]*)$/;
    my $initialSpace = $1;
    $line = $2;
    my $finalNewlines = $3;

    if ($line eq '') {
        print "\n";
        next;
    }

    print wrap($initialSpace, $initialSpace, $line);
    print $finalNewlines;
}
