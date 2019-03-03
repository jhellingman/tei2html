# fixDitto.pl -- convert non-standard <ditto> notation to <seg> notation, finding a source seg to copy, where possible.

use strict;

my $inputFile = $ARGV[0];

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");
chomp(my @lines = <INPUTFILE>);
close INPUTFILE;

print STDERR "Verifying $inputFile\n";

my $segNumber = 0;
my $lineNumber = 0;
my $dittoMark = ",,";

my %mapDittoToId;
my %mapIdToDitto;
my %mapIdToFound;
my %mapIdToWordCount;

foreach my $line (@lines) {
    my $remainder = $line;
    my $newLine = "";
    while ($remainder =~ m/<ditto(\b.*?)>(.*?)<\/ditto>/) {
        my $before = $`;
        $remainder = $';
        my $attrs = $1;
        my $content = $2;

        if ($attrs ne "") {
            print STDERR "\nWARN:  line $lineNumber: non-empty attributes: <ditto $attrs>";
        }

        my $id = $mapDittoToId{$content};
        if ($id eq "") {
            $segNumber++;
            $id = $segNumber;
            $mapDittoToId{$content} = $id;
            $mapIdToDitto{$id} = $content;

            # seek backwards for content above.
            for (my $i = $lineNumber - 1; $i > $lineNumber - 15 && $i > 0; $i--) {
                my $seekLine = $lines[$i];
                my $start = index($seekLine, $content);
                if ($start != -1) {
                    my $newSourceLine = substr($seekLine, 0, $start) . "<seg id=s$id>$content</seg>" . substr($seekLine, $start + length($content));
                    $lines[$i] = $newSourceLine;
                    $mapIdToFound{$id} = 1;
                    $mapIdToWordCount{$id} = countWords($content);

                    print STDERR "\nINFO:  line $i: s$id = $content ($mapIdToWordCount{$id})";
                    $i = 0;
                }
            }
            if (not $mapIdToFound{$id}) {
                print STDERR "\nERROR: line $lineNumber: content for s$id not found: [$content]";
            }
        }
        # print STDERR "<seg copyOf=s$id>,,</seg>\n";
        $newLine .= "$before<seg copyOf=s$id>" . repeat($dittoMark, $mapIdToWordCount{$id}) . "</seg>";
    }
    $newLine .= $remainder;
    $lines[$lineNumber] = $newLine;
    $lineNumber++;
}

foreach my $line (@lines) {
    print "$line\n";
}

sub countWords($) {
    my $text = shift;
    my $count;
    $count++ while $text =~ /\S+/g;
    return $count;
}

sub repeat($$) {
    my $symbol = shift;
    my $count = shift;
    return trim("$symbol " x $count);
}

sub trim($) { 
    my $string = shift; 
    $string =~ s/^\s+|\s+$//g; 
    return $string 
};
