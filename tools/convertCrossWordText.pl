# convertCrossWordText.pl -- convert cross-word to text format.

use strict;
use warnings;
use SgmlSupport qw/getAttrVal/;

if (!defined $ARGV[0]) {
    die "Usage: convertCrossWord.pl <filename>"
}
my $inputFile = $ARGV[0];

main();

sub main {
    open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

    my $mode = 0;
    my $previousLine = "";
    while (<INPUTFILE>) {
        my $line = $_;

        if ($line =~ m/\[crossword\]/) {
            $line = "\n";
            $mode = 1;
            next;
        }

        if ($line =~ m/\[\/crossword]/) {
            print formatLineOne($previousLine);
            $line = "\n";
            $mode = 0;
        }

        #   |~      non-bordered cell       <cell rend=blank>
        #   |       bordered cell           <cell>
        #   |#      black cell              <cell rend=black>
        #   |%      shaded cell             <cell rend=shaded>

        if ($mode == 1) {

            # remove initial | and final |\n
            $line =~ s/\|(.*)\|\n/$1/;
            my $output = "";
            $output = formatLineOne($line);
            $output .= formatLineTwo($line);
            $output .= formatLineThree($line);
            $previousLine = $line;

            print $output;
        } else {
            print $line;
        }
    }
}

sub formatLineOne {
    my $line = shift;
    my $result = "";

    my @cells = split(/\|/, $line, -1);
    foreach my $cell (@cells) {
        $result .= '+-----';
    }
    $result .= "+\n";
    return $result;
}

sub formatLineTwo {
    my $line = shift;
    my $result = "";

    my @cells = split(/\|/, $line, -1);
    foreach my $cell (@cells) {
        $cell = trim($cell);
        if ($cell =~ /[~]+/) {
            $result .= '|\\\\\\\\\\';
        } elsif ($cell =~ /[\#]+/) {
            $result .= '|#####';
        } elsif ($cell =~ /[%]+/) {
            $result .= '|/////';
        } elsif ($cell =~ /([0-9]+)/) {
            my $n = $1;
            $result .= sprintf "| %-4s", $1;
        } else {
            $result .= '|     ';
        }
    }
    $result .= "|\n";
    return $result;
}


sub formatLineThree {
    my $line = shift;
    my $result = "";

    my @cells = split(/\|/, $line, -1);
    foreach my $cell (@cells) {
        $cell = trim($cell);
        if ($cell =~ /[~]+/) {
            $result .= '|\\\\\\\\\\';
        } elsif ($cell =~ /[\#]+/) {
            $result .= '|#####';
        } elsif ($cell =~ /[%]+/) {
            $result .= '|/////';
        } else {
            $result .= '|     ';
        }
    }
    $result .= "|\n";
    return $result;
}


sub trim() {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

