# pageMap.pl -- Prepare an HTML heatmap of changes during rounds on PGDP.

# Usage: perl pageMap.pl projectId

use strict;
# use Text::Levenshtein qw(distance);
use Text::Levenshtein::XS qw/distance/;
use Statistics::Descriptive;

my $PAGE_SEPARATOR = /\n-*File: 0*([0-9]+)\.(png|jpg)-*\n/;

my $IMAGE_URL_FORMAT = "https://www.pgdp.net/c/tools/page_browser.php?mode=image&project=%s&imagefile=%03u.png";

my $style = <<'EOF';
<style>

.hm { border-collapse: collapse; border: 2pt solid black; }
.hm td { width: 16px; height: 16px; font-size: xx-small; color: gray; text-align: center; vertical-align: middle; }

.hm10 { background-color: #CC0000; }
.hm09 { background-color: #FF0000; }
.hm08 { background-color: #FF3300; }
.hm07 { background-color: #FF6600; }
.hm06 { background-color: #FF9900; }
.hm05 { background-color: #FFCC00; }
.hm04 { background-color: #FFFF00; }
.hm03 { background-color: #FFFF3F; }
.hm02 { background-color: #FFFF7F; }
.hm01 { background-color: #FFFFBF; }
.hm00 { background-color: #FFFFFF; }

.hn10 { background-color: #FF0000; }
.hn09 { background-color: #FF1900; }
.hn08 { background-color: #FF3300; }
.hn07 { background-color: #FF4C00; }
.hn06 { background-color: #FF6600; }
.hn05 { background-color: #FF7F00; }
.hn04 { background-color: #FF9900; }
.hn03 { background-color: #FFB200; }
.hn02 { background-color: #FFCC00; }
.hn01 { background-color: #FFE500; }
.hn00 { background-color: #FFFF00; }

.hq01 { background-color: #FF0000; }
.hq02 { background-color: #FF3300; }
.hq03 { background-color: #FF6600; }
.hq04 { background-color: #FF9900; }
.hq05 { background-color: #FFCC00; }
.hq06 { background-color: #FEFF00; }
.hq07 { background-color: #CBFF00; }
.hq08 { background-color: #98FF00; }
.hq09 { background-color: #65FF00; }
.hq10 { background-color: #32FF00; }
.hq11 { background-color: #00FF00; }

</style>
EOF



my $project = $ARGV[0];

my $outputFile = $project . "-out.html";

my $file_ocr = $project . "_OCR.txt";
my $file_p1 = $project . "_P1_saved.txt";
my $file_p2 = $project . "_P2_saved.txt";
my $file_p3 = $project . "_P3_saved.txt";
my $file_f1 = $project . "_F1_saved.txt";
my $file_f2 = $project . "_F2_saved.txt";

my @pages_ocr;
my @pages_p1;
my @pages_p2;
my @pages_p3;
my @pages_f1;
my @pages_f2;

my @pages_f1_clean;
my @pages_f2_clean;


main();


sub main() {

    @pages_ocr = loadPages($file_ocr);
    @pages_p1 = loadPages($file_p1);
    @pages_p2 = loadPages($file_p2);
    @pages_p3 = loadPages($file_p3);
    @pages_f1 = loadPages($file_f1);
    @pages_f2 = loadPages($file_f2);

    for my $i (0 .. $#pages_f1) {
        $pages_f1_clean[$i] = stripFormatting($pages_f1[$i]);
    }

    for my $i (0 .. $#pages_f1) {
        $pages_f2_clean[$i] = stripFormatting($pages_f2[$i]);
    }

    open(OUTPUTFILE, "> $outputFile") || die("Could not open $outputFile");

    print OUTPUTFILE "<h2>OCR vs P1</h2>\n";
    pageMap(\@pages_ocr, \@pages_p1);

    print OUTPUTFILE "<h2>P1 vs P2</h2>\n";
    pageMap(\@pages_p1, \@pages_p2);

    print OUTPUTFILE "<h2>P2 vs P3</h2>\n";
    pageMap(\@pages_p2, \@pages_p3);

    print OUTPUTFILE "<h2>P3 vs F1 (without formatting)</h2>\n";
    pageMap(\@pages_p3, \@pages_f1_clean);

    print OUTPUTFILE "<h2>F1 vs F2</h2>\n";
    pageMap(\@pages_f1, \@pages_f2);

    print OUTPUTFILE "<h2>P1 vs F2 (without formatting)</h2>\n";
    pageMap(\@pages_p1, \@pages_f1_clean);

    close(OUTPUTFILE);
}


sub pageMap(@@) {
    my ($ref1, $ref2) = @_;
    my @pages1 = @{ $ref1 };
    my @pages2 = @{ $ref2 };

    # Collect information from files.
    my @distances;
    my @percentages;
    for my $i (0 .. $#pages1) {
        my $distance = distance($pages1[$i], $pages2[$i]);
        $distances[$i] = $distance;
        my $length = length($pages1[$i]) + length($pages2[$i]);
        if ($length > 0) {
            $percentages[$i] = ($distance / $length) * 100.0;
        } else {
            $percentages[$i] = 0;
        }
    }

    my $stat = Statistics::Descriptive::Full->new();
    $stat->add_data(@distances);

    # my @percentiles = (10, 20, 30, 40, 50, 60, 70, 80, 90, 100);
    my @percentiles = (25, 33, 50, 67, 80, 90, 93, 95, 97, 99);
    foreach my $percentile (@percentiles) {
        print "PERCENTILE $percentile: " . $stat->percentile($percentile) . "\n";
    }

    my $statPercentages = Statistics::Descriptive::Full->new();
    $statPercentages->add_data(@percentages);
    my %thresholds;
    foreach my $percentile (@percentiles) {
        my $threshold = $statPercentages->percentile($percentile);
        print "PERCENTILE $percentile: $threshold\n";
        $thresholds{$percentile} = $threshold;
    }

    # Determine 'color' for each page.
    my @categories;
    for my $i (0 .. $#pages1) {
        $categories[$i] = 0;
        foreach my $j (0 .. $#percentiles) {
            if ($percentages[$i] > $thresholds{$percentiles[$j]}) {
                $categories[$i] = $j;
                next;
            }
        }
    }

    print OUTPUTFILE $style;
    print OUTPUTFILE "\n<table class=\"hm\">";
    foreach my $i (0 .. $#distances) {
        my $pageDescription = sprintf("PAGE %4s %6s %6s %6s    %.3f   =  %2s\n", $i,  length($pages2[$i]), length($pages2[$i]), $distances[$i], $percentages[$i], $categories[$i]);
        print $pageDescription;

        if ($i % 50 == 0) {
            print OUTPUTFILE "\n<tr>\n";
        }
        my $url = sprintf($IMAGE_URL_FORMAT, $project, $i);
        print OUTPUTFILE "<td class=\"hm0" . $categories[$i] . "\"><a href=\"$url\">" . $distances[$i] . "</a></td>";
        if ($i % 50 == 49) {
            print OUTPUTFILE "\n</tr>\n";
        }
    }
    print OUTPUTFILE "\n</table>";

    print OUTPUTFILE "\n<p><table>\n";
    print OUTPUTFILE "<tr><td>          <td>Absolute                 <td>Percentage\n";
    print OUTPUTFILE "<tr><td>Median    <td>" . sprintf("%.0f", $stat->median()) .   "<td>" . sprintf("%.2f", $statPercentages->median()) . "\n";
    print OUTPUTFILE "<tr><td>Mean      <td>" . sprintf("%.3f", $stat->mean()) .     "<td>" . sprintf("%.2f", $statPercentages->mean()) . "\n";
    print OUTPUTFILE "<tr><td>Variance  <td>" . sprintf("%.3f", $stat->variance()) . "<td>" . sprintf("%.2f", $statPercentages->variance()) . "\n";
    print OUTPUTFILE "\n</table>";
}


sub loadPages($) {
    my $file = shift;

    open(INPUTFILE, $file) || die("Could not open $file");

    my $content = '';
    while (<INPUTFILE>){
        $content .= $_;
    } 

    # my @pages = split($PAGE_SEPARATOR, $content);
    my @p = split(/\n-*File: (0*(?:[0-9]+)\.(?:png|jpg))-*\n/, $content);

    my @pages;
    my @fileNames;
    foreach my $i (0 .. $#p) {
        if ($i % 2) {
            push(@fileNames, $p[$i]);
        } else {
            push(@pages, $p[$i]);
        }
    }

    foreach my $i (0 .. $#pages) {
       $pages[$i] = normalize($pages[$i]);
    }

    close(INPUTFILE);

    return @pages;
}


sub normalize($) {
    my $string = shift;

    $string =~ s/\240/ /g; # non-breaking space
    $string =~ s/\s+/ /g;

    return $string;
}


sub stripFormatting($) {
    my $string = shift;

    # print "BEFORE: $string\n\n";

    $string =~ s/<\/?(i|g|sc)>//g;      # Simple formatting.
    $string =~ s/\[\*\*.*?\]//g;        # Proofer's notes.
    $string =~ s/\/[*#]//g;             # /* /#
    $string =~ s/[*#]\///g;             # */ #/
    $string =~ s/\[Footnote [0-9]+://g; # Footnote notation.

    # print "AFTER:  $string\n\n";

    return $string;
}
