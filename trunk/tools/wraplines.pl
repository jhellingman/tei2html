
use strict;

use Getopt::Long;
use Text::Wrap;

my $useUnicode = 0;

GetOptions('u' => \$useUnicode);

$Text::Wrap::columns = 72;

if ($useUnicode == 1) 
{
    binmode(STDOUT, ":utf8");
    use open ':utf8';
}

while (<>)
{
    my $line = $_;
    $line =~ /^( *)(.*)(\n*)$/;
    my $initialSpace = $1;
    $line = $2;
    my $finalNewlines = $3;

    print wrap($initialSpace, $initialSpace, $line);
    print $finalNewlines;
}
