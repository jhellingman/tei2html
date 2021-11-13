# linkIndex.pl

use strict;
use warnings;


while (<>) {
    my $line = $_;

    if ($line =~ /<p>(<hi.*?>)?((?:[a-z -]|\&apos;|&OElig;)+(?:[a-z]))(<\/hi>)?/i) {

        my $prefix = $`;
        my $openTag = defined($1) ? $1 : "";
        my $entry = $2;
        my $closeTag = defined($3) ? $3 : "";
        my $remainder = $';

        $line = "$prefix<p id=ix." . makeId($entry) . ">$openTag$entry$closeTag$remainder";
    }

    if ($line =~ /(<hi>See(?: also)?<\/hi>) (<hi.*?>)?((?:[a-z -]|\&apos;|&OElig;)+(?:[a-z]))(<\/hi>)?/i) {

        my $prefix = $`;
        my $see = $1;
        my $openTag = defined($2) ? $2 : "";
        my $entry = $3;
        my $closeTag = defined($4) ? $4 : "";
        my $remainder = $';

        $line = "$prefix$see $openTag<ref target=ix." . makeId($entry) . ">$entry</ref>$closeTag$remainder";
    }

    $line =~ s/ ([0-9][0-9]?[0-9]?)/ <ref target=pb$1 type=pageref>$1<\/ref>/g;
    $line =~ s/ ([ivx]+)([.,])/ <ref target=pb.$1 type=pageref>$1<\/ref>$2/g;
   
    print $line;   
}


sub makeId {
    my $phrase = lc(shift);
    $phrase =~ s/\&apos;//g;
    $phrase =~ s/\&oelig;/oe/g;
    $phrase =~ s/[^a-z-]+/./g;
    return $phrase;
}