
use strict;
use warnings;

use Getopt::Long;
use utf8;
binmode(STDOUT, ":utf8");
use open ':utf8';
use feature 'unicode_strings';

require Encode;
use Unicode::Normalize;

my $columns = 72;

GetOptions('w=i' => \$columns);

wrapUnicode();

sub test {

    $columns = 42;

    my $latin = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

    my $greek = "Δεν υπάρχει κανείς που να αγαπάει τον ίδιο τον πόνο, να τον αναζητά και να θέλει να τον νιώθει, επειδή απλά είναι πόνος. Δεν υπάρχει κανείς που να αγαπάει τον ίδιο τον πόνο, να τον αναζητά και να θέλει να τον νιώθει, επειδή απλά είναι πόνος.";

    my $tibetan = "༄༅ ༎ཡུལ་ཞིག་ན་བྲམ་ཟེ་དབྱུག་པ་ཅན་ཞེས་བྱ་བ་ཞིག༌འདུག་སྟེ། རབ་ཏུ་དབུལ་འཕོངས་པ་བཟའ་བ་དང༌། བགོ་བ་མེད་པ་ཞིག་གོ། དེས་ཁྱིམ་བདག་ཅིག་ལས་བ་གླང་ཞིག་བརྙས་ཏེ། ཉིན་པར་སྤྱད་ནས་བ་གླང་དེ་ཁྲིད་དེ་ཁྱིམ་བདག་དེའི་ཁྱིམ་དུ་སོང་བ་དང༌། དེ་ན་ཁྱིམ་བདག་ནི་ཟན་ཟ་སྟེ། དབྱུག་པ་ཅན་གྱིས་བ་གླང་དེ་ཁྱིམ་གྱི་ནང་དུ་བཏང་བ་དང༌། བ་གླང་སྒོ་གཞན་དུ་སོང་ནས་སྟོར་རོ༎ ཁྱིམ་བདག་དེ་ཟན་དེ་ཟོས་ནས་ལངས་པ་དང༌། དེ་ན་བ་གླང་མ་མཐོང་ནས་དེས་དབྱུག་པ་ཅན་ལ་གླང་ག་རེ་ཞེས་བྱས་པ་དང༌། ཏེས་སྨྲས་པ། ཁྱོད་ཀྱི་ཁྱིམ་དུ་བཏང་ངོ༌། །ཁྱོད་ཀྱིས་ངའི་གླང་བོར་གྱིས་སློར་བྱིན་ཅིག་ཅེས་སྨྲས་པ་དང༌། དེས་སྨྲས་པ།";

    wrapLine('', $latin);
    print "\n\n";
    wrapLine('  ', $greek);
    print "\n\n";
    wrapLine('', $tibetan);
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

    # Trim trailing spaces.
    $line =~ s/\s+$//;

    # print STDERR "LINE 1: '$line'\n";
    # Insert a zero-width space after tsheg followed by a Tibetan letter.
    # $line =~ s/\x{F0B}([\x{F40}-\x{F6C}])/\x{F0B}\x{200B}$1/g;

    my $prefixLength = spacingCharacterLength($prefix);
    my $currentPosition = 0;

    if ($line !~ /^\s+$/) {
        print $prefix;
        $currentPosition = $prefixLength;
    }

    # print STDERR "LINE 2: '$line'\n";

    my @pieces = split(/(\s*\S+)/, $line);
    foreach my $piece (@pieces) {

        if ($piece eq '') {
            next;
        }
        # print STDERR "PIECE: '$piece'\n";

        my $pieceLength = spacingCharacterLength($piece);
        if ($currentPosition + $pieceLength < $columns) {
            print $piece;
            $currentPosition += $pieceLength;
            next;
        } else {
            $piece =~ /^(\s*)(\S+)$/;
            my $space = $1;
            my $word = $2;
            print "\n$prefix$word";
            $currentPosition = $prefixLength + spacingCharacterLength($word);
        }
    }
}

sub spacingCharacterLength {
    my $string = shift;

    for ($string) {
        $_ = NFD($_);       ## decompose (Unicode Normalization Form D)
        s/\pM//g;           ## strip combining characters
        s/\x{200B}//g;      ## strip zero-width spaces
    }
    return length($string);
}

