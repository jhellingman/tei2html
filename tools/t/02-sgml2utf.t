use v5.36;
use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';
use Test::More tests => 8;

use lib 'tools';
use SgmlSupport qw/sgml2utf/;

# 1. named entity (eacute -> U+00E9)
is( sgml2utf('&eacute;'), "\x{00E9}", 'named entity &eacute; -> U+00E9 (é)' );

# 2. HTML entity (lt -> '<')
is( sgml2utf('&lt;'), '<', '&lt; -> <' );

# 3. numeric decimal entity
is( sgml2utf('&#233;'), "\x{00E9}", 'decimal numeric entity &#233; -> U+00E9 (é)' );

# 4. numeric hex entity
is( sgml2utf('&#xE9;'), "\x{00E9}", 'hex numeric entity &#xE9; -> U+00E9 (é)' );

# 5. numeric hex entity (lowercase)
is( sgml2utf('&#xe9;'), "\x{00E9}", 'hex numeric entity &#xE9; -> U+00E9 (é)' );

# 6. unknown entity should be left unchanged (and the module currently warns)
is( sgml2utf('&unknown_entity;'), '&unknown_entity;', 'unknown entity left unchanged' );

# 7. named vulgar fraction (frac12 -> U+00BD)
is( sgml2utf('&frac12;'), "\x{00BD}", '&frac12; -> U+00BD (½)' );

# 8. musical time entity handled by the module (time top/bottom -> XML fragment)
is( sgml2utf('&time34;'),
    '<ab type="musictime"><ab type="top">3</ab><ab type="bottom">4</ab></ab>',
    'time34 -> musictime XML fragment'
);

done_testing();