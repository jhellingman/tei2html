
use open ':utf8';

use utf8;
use SgmlSupport qw/sgml2utf_html utf2sgml/;

while (<>)
{
    my $string = $_;
    print utf2sgml(sgml2utf_html($string));
}
