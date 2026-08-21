use v5.36;
use strict;
use warnings;
use Test::More tests => 7;

use lib 'tools';
use SgmlSupport qw/getAttrVal/;

# 1. double-quoted attribute
my $attrs1 = q{A="abc" B="test"};
is( getAttrVal('A', $attrs1), 'abc', 'double-quoted attribute value' );

# 2. unquoted attribute (alnum, dot, hyphen allowed)
my $attrs2 = q{B=xyz C="aap"};
is( getAttrVal('B', $attrs2), 'xyz', 'unquoted attribute value' );

# 3. single-quoted attribute (desired behavior)
my $attrs3 = q{C='single' D=2};
is( getAttrVal('C', $attrs3), 'single', 'single-quoted attribute value' );

# 4. missing attribute -> empty string
my $attrs4 = q{A="1"};
is( getAttrVal('Z', $attrs4), '', 'missing attribute returns empty string' );

# 5. whitespace around equals and in quoted value
my $attrs5 = q{X = " spaced " Y=val};
is( getAttrVal('X', $attrs5), ' spaced ', 'handles whitespace around = and inside quoted value' );

# 6. case-insensitive attribute name matching
my $attrs6 = q{Name="John"};
is( getAttrVal('name', $attrs6), 'John', 'attribute name matching is case-insensitive' );

# 7. unquoted value with dot and hyphen
my $attrs7 = q{id=ab-c.d other="ok"};
is( getAttrVal('id', $attrs7), 'ab-c.d', 'unquoted value can contain dot and hyphen' );

done_testing();
