
use strict;
use warnings;

use Getopt::Long;
use utf8;
binmode(STDOUT, ":utf8");
use open ':utf8';

require Encode;
use Unicode::Normalize;

my $columns = 72;

GetOptions('w=i' => \$columns);

wrapUnicode();

sub test {

	$columns = 42;

	my $latin = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
	
	my $greek = "Δεν υπάρχει κανείς που να αγαπάει τον ίδιο τον πόνο, να τον αναζητά και να θέλει να τον νιώθει, επειδή απλά είναι πόνος. Δεν υπάρχει κανείς που να αγαπάει τον ίδιο τον πόνο, να τον αναζητά και να θέλει να τον νιώθει, επειδή απλά είναι πόνος.";

    wrapLine('', $latin);
	print "\n\n";
	wrapLine('  ', $greek);
}


sub wrapUnicode {
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
		print wrapLine($initialSpace, $line);
        print $finalNewlines;
    }
}


sub wrapLine {
    my $prefix = shift;
    my $line = shift;

    my $prefixLength = logicalCharacterLength($prefix);
    my $currentPosition = 0;

    if ($line !~ /^\s+$/) {
        print $prefix;
        $currentPosition = $prefixLength;
    }

	# print STDERR "LINE: '$line'\n";

    my @pieces = split(/(\s*\S+)/, $line);
    foreach my $piece (@pieces) {

		if ($piece eq '') {
			next;
		}
        # print STDERR "PIECE: '$piece'\n";

        my $pieceLength = logicalCharacterLength($piece);
        if ($currentPosition + $pieceLength < $columns) {
            print $piece;
            $currentPosition += $pieceLength;
            next;
        } else {
            $piece =~ /^(\s*)(\S+)$/;
            my $space = $1;
            my $word = $2;
            print "\n$prefix$word";
            $currentPosition = $prefixLength + logicalCharacterLength($word);
        }
    }
}

sub logicalCharacterLength {
    my $string = shift;

    for ($string) {
        $_ = NFD($_);       ## decompose (Unicode Normalization Form D)
        s/\pM//g;           ## strip combining characters
    }
    return length($string);
}

