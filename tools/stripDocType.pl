# stripDocType.pl -- Remove the HTML legacy doctype as saxon will not accept it.

use strict;
use warnings;

sub slurp($);

my $text = slurp($ARGV[0]);

$text =~ s/<!DOCTYPE\s+html\s+SYSTEM\s+\"about:legacy-compat\">//g;

print $text;

sub slurp($) {
    my $filename = shift;
    open my $file, '<', $filename or die "Cannot open $filename\n";
    local $/ = undef;
    my $result = <$file>;
    close $file;
    return $result;
}
