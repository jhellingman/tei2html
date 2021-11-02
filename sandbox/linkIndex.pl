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

    if ($line =~ /(<hi>See(?: also)?<\/hi>) ((?:[a-z -]|\&apos;|&OElig;)+(?:[a-z]))/i) {

        my $prefix = $`;
        my $see = $1;
        my $entry = $2;
        my $remainder = $';

        $line = "$prefix$see <ref target=ix." . makeId($entry) . ">$entry</ref>$remainder";
    }
    
    print $line;   
}


sub makeId {
    my $phrase = lc(shift);
    $phrase =~ s/\&apos;//g;
    $phrase =~ s/\&oelig;/oe/g;
    $phrase =~ s/[^a-z-]+/./g;
    return $phrase;
}