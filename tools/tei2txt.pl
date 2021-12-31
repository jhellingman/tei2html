# tei2txt.pl -- TEI to plain vanilla ASCII text

use strict;

use Getopt::Long;
use POSIX qw/floor ceil/;

use SgmlSupport qw/getAttrVal sgml2utf/;

my $useUnicode = 0;
my $useItalics = 0;
my $pageWidth = 72;
my $centerTables = 1;

GetOptions(
    'u' => \$useUnicode,
    'w=i' => \$pageWidth);

if ($useUnicode == 1) {
    binmode(STDOUT, ":encoding(UTF-8)");
    # use open ':utf8';
    use open ':encoding(UTF-8)'
}

my $italicStart = '_';
my $italicEnd = '_';

if ($useItalics == 1) {
    $italicStart = '_';
    $italicEnd = '_';
} else {
    $italicStart = '';
    $italicEnd = '';
}

#    0.                   1.              2.              3.            4.              5.
#
#    No borders, just     +===+===+       =========       /=======\     =========       =========
#    three spaces         |   |   |       |   |   |       |   |   |                         |
#    between columns      +---+---+       |---+---|       |---+---|                     ----+----
#    (6: one space)       |   |   |       |   |   |       |   |   |     =========           |
#                         +===+===+       =========       \=======/                     =========
#

my $borderStyle = 0;

my @borderTopLeft       = ('',      '+=',   '==',   '/=',   '',     '',     '');
my @borderTopLine       = ('',      '=',    '=',    '=',    '=',    '=',    '');
my @borderTopCross      = ('',      '=+=',  '===',  '===',  '===',  '===',  '');
my @borderTopRight      = ('',      '=+',   '==',   '=\\',  '',     '',     '');

my @borderLeft          = ('',      '| ',   '| ',   '| ',   '',     '',     '');
my @borderLeftCross     = ('',      '+-',   '|-',   '|-',   '',     '',     '');
my @borderRight         = ('',      ' |',   ' |',   ' |',   '',     '',     '');
my @borderRightCross    = ('',      '-+',   '-|',   '-|',   '',     '',     '');

my @innerVertical       = ('   ',   ' | ',  ' | ',  ' | ',  '   ',  ' | ',  ' ');
my @innerCross          = ('   ',   '-+-',  '-+-',  '-+-',  '   ',  '-+-',  ' ');
my @innerHorizontal     = ('',      '-',    '-',    '-',    '',     '-',    '');

my @borderBottomLeft    = ('',      '+=',   '==',   '\\=',  '',     '',     '');
my @borderBottomLine    = ('',      '=',    '=',    '=',    '=',    '=',    '');
my @borderBottomCross   = ('',      '=+=',  '===',  '===',  '===',  '===',  '');
my @borderBottomRight   = ('',      '=+',   '==',   '=/',   '',     '',     '');

my @predefinedColumnWidths = ();

#
# Main program loop
#

while (<>) {
    my $line = $_;

    # remove TeiHeader
    if ($line =~ /<[Tt]ei[Hh]eader/) {
        $line = $';
        while ($line !~ /<\/[Tt]ei[Hh]eader>/) {
            $line = <>;
        }
        $line =~ /<\/[Tt]ei[Hh]eader>/;
        $line = $';
    }

    # remove forme works (<fw>...</fw>). (multiple can occur in a single line.)
    while ($line =~ /<fw\b(.*?)>/) {
        my $before = $`;
        $line = $';
        while ($line !~ /<\/fw>/) {
            $line = <>;
        }
        $line =~ /<\/fw>/;
        $line = $before . $';
    }

    # drop comments from text (replace with single space).
    $line =~ s/\s*<!--.*?-->\s*/ /g;

    # Handle predefined column widths (given in a processing instruction)
    if ($line =~ /<\?tei2txt columnWidths=\"(.*?)\"\?>/) {
        @predefinedColumnWidths = split('\s+', $1);
        print STDERR "tei2txt: Using predefined column widths: $1\n";
    }
    if ($line =~ /<\?tei2txt borderStyle=\"(.*?)\"\?>/) {
        $borderStyle = $1;
        print STDERR "tei2txt: Changed border style to: $borderStyle\n";
    }

    # drop processing instructions from text (replace with nothing).
    $line =~ s/\s*<\?.*?\?>\s*//;

    # warn for remaining comments
    $line =~ s/<!--/[**ERROR: unhandled comment start]/g;

    # warn for notes (which should have been handled in a separate process)
    $line =~ s/<note\b.*?>/[**ERROR: unhandled note start tag]/g;
    $line =~ s/<\/note\b.*?>/[**ERROR: unhandled note end tag]/g;

    # generate part headings
    if ($line =~ /<(div0.*?)>/) {
        my $tag = $1;
        my $partNumber = getAttrVal('n', $tag);
        if ($partNumber ne '') {
            print "\nPART $partNumber\n";
        }
    }

    # generate chapter headings
    if ($line =~ /<(div1.*?)>/) {
        my $tag = $1;
        my $chapterNumber = getAttrVal('n', $tag);
        if ($chapterNumber ne '') {
            print "\nCHAPTER $chapterNumber\n";
        }
    }

    # generate section headings
    if ($line =~ /<(div2.*?)>/) {
        my $tag = $1;
        my $sectionNumber = getAttrVal('n', $tag);
        if ($sectionNumber ne '') {
            print "\nSECTION $sectionNumber\n";
        }
    }

    # generate figure headings
    if ($line =~ /<(figure.*?)>/) {
        my $tag = $1;
        my $figureNumber = getAttrVal('n', $tag);
        print "\n------\nFIGURE $figureNumber\n";
    }
    if ($line =~ /<\/figure>/) {
        print "------\n";
    }

    # mark tables for manual verification.
    if ($line =~ /<(table.*?)>/) {
        my $tag = $1;
        print "\n[**TODO: Verify table]\n";
        my $tableId =  getAttrVal('id', $tag);
        parseTable($line, $tableId);
    }
    if ($line =~ /<\/table>/) {
        print "------\n";
    }

    # handle intra-linear text
    if ($line =~ m/<INTRA(.*?)>/) {
        handleIntra();
    }

    $line = handleLine($line);

    print $line;
}


sub handleLine($) {
    my $line = shift;

    # convert entities
    if ($useUnicode == 1) {
        $line = sgml2utf($line);
    } else {
        $line = entities2iso88591($line);
    }

    $line = handleSegments($line);

    $line = handleHighlighted($line);

    # handle cell boundaries (non should remain if tables are parsed correctly)
    $line =~ s/<cell(.*?)>/|/g;

    # drop page-breaks (<pb>) as they interfere with the following processing.
    $line =~ s/<pb\b(.*?)>//g;

    # handle <choice><sic>...</sic><corr>...</corr></choice> and <choice><corr>...</corr><sic>...</sic></choice>
    $line =~ s/<choice\b(.*?)><corr>(.*?)<\/corr><sic>(.*?)<\/sic><\/choice>/$2/g;
    $line =~ s/<choice\b(.*?)><sic>(.*?)<\/sic><corr>(.*?)<\/corr><\/choice>/$3/g;

    # similar for abbr / expan.
    $line =~ s/<choice\b(.*?)><abbr>(.*?)<\/abbr><expan>(.*?)<\/expan><\/choice>/$2/g;
    $line =~ s/<choice\b(.*?)><expan>(.*?)<\/expan><abbr>(.*?)<\/abbr><\/choice>/$3/g;

    # handle numbered lines of verse
    if ($line =~ /( +)<l\b(.*?)>/) {
        my $prefix = $`;
        my $remainder = $';
        my $spaces = $1;
        my $attrs = $2;
        my $number = getAttrVal('n', $attrs);
        if (defined $number) {
            my $need = length($spaces) - length($number);
            $need = $need < 1 ? 1 : $need;
            $line = $prefix . $number . spaces($need) . $remainder;
        }
    }

    # handle references to end-notes like footnotes
    $line = handleEndNotes($line);

    # remove any remaining tags
    $line =~ s/<.*?>//g;

    # Some problematic entities from Wolff.
    $line =~ s/\&larr;/<-/g;   # Left Arrow
    $line =~ s/\&rarr;/->/g;   # Right Arrow

    # warn for entities that slipped through.
    if ($line =~ /\&([a-zA-Z0-9._-]+);/) {
        my $ent = $1;
        if (!($ent eq 'gt' || $ent eq 'lt' || $ent eq 'amp')) {
            print "\n[**ERROR: Contains unhandled entity &$ent;]\n";
        }
    }

    # remove the last remaining entities
    $line =~ s/\&gt;/>/g;
    $line =~ s/\&lt;/</g;
    $line =~ s/\&amp;/&/g;

    # warn for anything that slipped through.
    # BUG: if for example &c; should appear in the output, a bug will be reported
    # $a =~ s/\&\w+;/[ERROR: unhandled $&]/g;

    return $line;
}


sub handleEndNotes() {
    my $remainder = shift;
    my $result = '';

    while ($remainder =~ /([ .,:;!?]*)<ref\b(.*?)>(.*?)<\/ref>/) {
        my $prefix = $`;
        $remainder = $';
        my $spaceOrPunctuationBefore = $1;
        my $attrs = $2;
        my $content = $3;
        my $number = getAttrVal('n', $attrs);
        my $type = getAttrVal('type', $attrs);
        if (defined $type && lc($type) eq 'endnoteref') {
            if ($spaceOrPunctuationBefore eq '') { $spaceOrPunctuationBefore = ' '; }
            if ($content eq '' && defined $number) { $content = $number; }
            $result .= $prefix . $spaceOrPunctuationBefore . '[' . $content . ']';
        }
        else {
            $result .= $prefix . $spaceOrPunctuationBefore . '<ref' . $attrs . '>' . $content . '</ref>';
        }
    }
    return $result . $remainder;
}


sub spaces($) {
    my $n = shift;
    my $result = '';
    for (my $i = 0; $i < $n; $i++) {
        $result .= ' ';
    }
    return $result;
}


sub noBreakSpaces($) {
    my $n = shift;
    my $result = '';
    for (my $i = 0; $i < $n; $i++) {
        $result .= '�';
    }
    return $result;
}


sub handleHighlighted($) {
    my $remainder = shift;

    my $result = '';
    while ($remainder =~ /<hi(.*?)>(.*?)<\/hi>/) {
        my $attrs = $1;
        my $rend = getAttrVal('rend', $attrs);
        if ($rend eq 'sup') {
            $result .= $` . $2;
        } elsif ($rend eq 'sc' || $rend eq 'expanded') {
            $result .= $` . $2;
        } else {
            $result .= $` . $italicStart . $2 . $italicEnd;
        }
        $remainder = $';
    }
    return $result . $remainder;
}


my %mapIdToContent;

sub handleSegments($) {
    my $remainder = shift;

    my $result = '';
    while ($remainder =~ /<seg(.*?)>(.*?)<\/seg>/) {
        my $before = $`;
        my $attrs = $1;
        my $content = $2;
        $remainder = $';
        
        $result .= $before;

        my $id = getAttrVal('id', $attrs);
        my $copyOf = getAttrVal('copyOf', $attrs);
        if ($id ne '') {
            $mapIdToContent{$id} = $content;
            $result .= $content;
        } elsif ($copyOf ne '') {
            if (!defined $mapIdToContent{$copyOf}) {
                print STDERR "ERROR: <seg id=$copyOf> not found.\n";
                $result .= $content;
            }
            else {
                $result .= useDittoMarks($mapIdToContent{$copyOf});
            }
        }
        else {
            $result .= $content;
        }
    }
    return $result . $remainder;
}

sub useDittoMarks($) {
    my $string = shift;
    my $result = '';
    $string = handleLine($string);

    my @words = split(/(\s+)/, $string);
    foreach my $word (@words) {
        if ($word =~ /\s+/) {
            $result .= $word;
        } else {
            $result .= useDittoMark($word);
        }
    }
    return $result;
}

sub useDittoMark($) {
    my $string = shift;
    my $spacesBefore = floor((length($string) - 2) / 2.0);
    my $spacesAfter = ceil((length($string) - 2) / 2.0);
    return noBreakSpaces($spacesBefore) . ',,' . noBreakSpaces($spacesAfter);
}


sub centerStringInWidth($$) {
    my $string = shift;
    my $width = shift;
    my $spacesBefore = floor(($width - length($string)) / 2.0);
    my $spacesAfter = ceil(($width - length($string)) / 2.0);
    return spaces($spacesBefore) . $string . spaces($spacesAfter);
}



sub parseTable($) {
    my $table = shift;
    my $tableId = shift;
    my $tableHead = '';

    # print STDERR "DEBUG: Parsing table: $table.\n";

    while (<>) {
        my $line = $_;

        $line = handleSegments($line);

        if ($line =~ /<head>(.*?)<\/head>/) {
            $tableHead = $1;
        }
        $table .= $line;
        if ($line =~ /<\/table>/) {
            my @result = handleTable($table);
            my @wrappedTable = sizeTableColumns($pageWidth - 1, $tableId, @result);
            if ($tableHead ne '') {
                print handleLine($tableHead) . "\n\n";
            }
            printTable(@wrappedTable);
            return;
        }
    }
}

# Place a table in a three-dimensional array: rows, cells, lines (within each cell)
#
sub handleTable($) {
    my $table = shift;
    # $table =~ s/\n/ /gms; # Remove new-lines for easier handling with default regex.
    $table =~ /<table\b(.*?)>(.*?)<\/table>/ms;
    my $tableAttributes = $1;
    my $tableContent = $2;

    # print STDERR "DEBUG: Handling table ID: " . getAttrVal('id', $tableAttributes) . "\n";

    my @rows = split(/<row\b.*?>/ms, $tableContent);

    # First element in result is empty, so drop it
    shift @rows;
    my @result = ();
    foreach my $row (@rows) {
        $row = trim($row);
        push @result, [ handleRow($row) ];
    }
    return @result;
}

sub handleRow($) {
    my $row = shift;
    my @items = split(/<cell\b(.*?)>/ms, $row);
    my @cells = ();
    my @colSpans = ();
    my @rowSpans = ();

    # print STDERR "DEBUG: Handling row\n";

    # Every second item contains tag; first cell is empty.
    for (my $i = 0; $i <= $#items; $i++) {
        my $item = $items[$i];
        if ($i % 2 == 0) {
            push @cells, $item;
        } else {
            my $cols = getAttrVal('cols', $item);
            my $rows = getAttrVal('rows', $item);

            $cols = $cols eq '' ? 1 : $cols;
            $rows = $rows eq '' ? 1 : $rows;

            push @colSpans, $cols;
            push @rowSpans, $rows;
        }
    }

    # First element in result is empty, so drop it
    shift @cells;

    my @result = ();
    foreach my $cell (@cells) {
        $cell = handleLine(trim($cell));
        push @result, [ handleCell($cell) ];
    }

    return @result;
}

sub handleCell($) {
    my $cell = shift;
    my @lines = split("\n", $cell);

    my @result = ();
    foreach my $line (@lines) {
        $line = trim($line);
        $line =~ s/\s+/ /g;
        push @result, $line;
    }
    return @result;
}


sub sizeTableColumns($$@) {
    # See also: https://developer.mozilla.org/en-US/docs/Table_Layout_Strategy
    # See http://nothings.org/computer/badtable/
    # in particular: http://www.csse.monash.edu.au/~marriott/HurMarMou05.pdf
    # http://www.csse.monash.edu.au/~marriott/HurMarAlb06.pdf

    my $finalWidth = shift;
    my $tableId = shift;
    my @rows = @_;

    # Establish minimal column widths (narrowest column width without breaking words)
    # Establish maximal column widths (maximum desired width; no line-breaks needed)
    # Establish column weight (total number of characters in a column)
    # Establish total weight of all columns (total number of characters in table)
    my @minimalColumnWidths = ();
    my @desiredColumnWidths = ();
    my @widestWord = ();
    my @columnArea = ();
    my $totalArea = 0;

    for my $i (0 .. $#rows) {
        my $cellCount = $#{$rows[$i]};
        for my $j (0 .. $cellCount) {
            my $cellHeight = $#{$rows[$i][$j]};
            for my $k (0 .. $cellHeight) {
                my $line = $rows[$i][$j][$k];
                my $lineLength = length($line);
                $columnArea[$j] += $lineLength;
                $totalArea += $lineLength;
                if ($lineLength > $desiredColumnWidths[$j]) {
                    $desiredColumnWidths[$j] = $lineLength;
                }

                my @words = split(/\s+/, $line);
                foreach my $word (@words) {
                    my $wordLength = length($word);
                    if ($wordLength > $minimalColumnWidths[$j]) {
                        $widestWord[$j] = $word;
                        $minimalColumnWidths[$j] = $wordLength;
                    }
                }
            }
        }
    }

    # Find minimal width of table;
    my @finalColumnWidths = ();
    my $minimalWidth = 0;
    my $columns = 0;
    for my $j (0 .. $#minimalColumnWidths) {
        $columns++;
        ##print STDERR "\nCOLUMN: $j WIDTH: $minimalColumnWidths[$j] WORD: $widestWord[$j]";
        $finalColumnWidths[$j] = $minimalColumnWidths[$j];
        $minimalWidth += $minimalColumnWidths[$j];
    }

    # Adjust final width for borders (left 2; between 3; right 2)
    my $borderAdjustment = (($columns - 1) * length($innerCross[$borderStyle])) +
        length($borderLeft[$borderStyle]) +
        length($borderRight[$borderStyle]);

    $finalWidth -= $borderAdjustment;

    if ($minimalWidth > $finalWidth) {
        print STDERR "WARNING: Table $tableId cannot be fitted into " . ($finalWidth + $borderAdjustment) . " columns! Need " . ($minimalWidth + $borderAdjustment) . " columns.\n";
    }

    # Now we need to distribute the remaining width, by adding it to the most needy column.
    # Calculate entitlements (how much every column is supposed to have, based on its area)
    my @entitlement = ();
    my @fillFactor = ();
    for my $j (0 .. $columns - 1) {
        my $fraction = sqrt($columnArea[$j]) / sqrt($totalArea);
        $entitlement[$j] = $finalWidth * $fraction;
        if ($finalColumnWidths[$j] >= $desiredColumnWidths[$j]) {
            $fillFactor[$j] = 1.0;
        } else {
            $fillFactor[$j] = $finalColumnWidths[$j] / $entitlement[$j];
        }
    }

    # Add spaces to columns with the lowest fill factor, recalculating it as we go;
    my $remainingWidth = $finalWidth - $minimalWidth;
    while ($remainingWidth > 0) {
        my $mostNeedy = -1;
        my $worstFillFactor = 1;
        # Find column with lowest fill factor;
        for my $j (0 .. $columns - 1) {
            if ($fillFactor[$j] < 1.0 && $fillFactor[$j] < $worstFillFactor) {
                $mostNeedy = $j;
                $worstFillFactor = $fillFactor[$j];
            }
        }

        if ($mostNeedy == -1) {
            # All columns are satisfied
            last;
        } else {
            # Give that column an extra space and recalculate fill factor
            $remainingWidth--;
            $finalColumnWidths[$mostNeedy]++;

            if ($finalColumnWidths[$mostNeedy] >= $desiredColumnWidths[$mostNeedy]) {
                $fillFactor[$mostNeedy] = 1.0;
            } else {
                $fillFactor[$mostNeedy] = $finalColumnWidths[$mostNeedy] / $entitlement[$mostNeedy];
            }
        }
    }

    # TODO: optimize the table.


    # Allow calculated widths to be overriden by widths specified in a processing instruction
    if ($#predefinedColumnWidths > 0) {
        if ($#predefinedColumnWidths != $#finalColumnWidths) {
            print STDERR "WARNING: Number of predefinedColumnWidths (" 
                . ($#predefinedColumnWidths + 1)
                . ") differs from actual number of columns ("
                . ($#finalColumnWidths + 1)
                . ")!\n";
        }
        @finalColumnWidths = @predefinedColumnWidths;
    }

    # Break lines in cells.
    for my $i (0 .. $#rows) {
        for my $j (0 .. $#{$rows[$i]}) {
            my @newCell = ();
            my $cellHeight = $#{$rows[$i][$j]};

            for my $k (0 .. $cellHeight) {
                my $line = $rows[$i][$j][$k];
                if ($line eq '') {
                    # Handle empty lines directly.
                    push (@newCell, '');
                } else {
                    my $wrappedLine = wrapLine($line, $finalColumnWidths[$j]);
                    push (@newCell, split("\n", $wrappedLine));
                }
            }
            $rows[$i][$j] = [ @newCell ];
        }
    }
    return @rows;
}


sub totalTableWidth(@) {
    my @columnWidths = @_;

    my $totalTableWidth = length($borderLeft[$borderStyle]);
    for my $i (0 .. $#columnWidths) {
        $totalTableWidth += $columnWidths[$i];
        $totalTableWidth += $i < $#columnWidths ? length($innerCross[$borderStyle]) : length($borderRight[$borderStyle]);
    }
    return $totalTableWidth;
}


sub printTable(@) {
    my @rows = @_;

    # Establish the width of each column and height of each row
    my @columnWidths = ();
    my @rowHeights = ();

    for my $i (0 .. $#rows) {
        $rowHeights[$i] = 0;
        for my $j (0 .. $#{$rows[$i]}) {
            my $cellHeight = $#{$rows[$i][$j]};
            for my $k (0 .. $cellHeight) {
                my $line = $rows[$i][$j][$k];
                my $lineLength = length($line);
                if ($lineLength > $columnWidths[$j]) {
                    $columnWidths[$j] = $lineLength;
                }
            }
            if ($cellHeight > $rowHeights[$i]) {
                $rowHeights[$i] = $cellHeight;
            }
        }
    }

    # Allow calculated widths to be overriden by widths specified in a processing instruction
    if ($#predefinedColumnWidths > 0) {
        if ($#predefinedColumnWidths != $#columnWidths) {
            print STDERR "WARNING: Number of predefinedColumnWidths (" 
                . ($#predefinedColumnWidths + 1)
                . ") differs from actual number of columns ("
                . ($#columnWidths + 1)
                . ")!\n";
        }
        @columnWidths = @predefinedColumnWidths;
    }

    my $totalTableWidth = totalTableWidth(@columnWidths);

    if (length ($borderTopLine[$borderStyle]) > 0) {
        printCenterSpacing($totalTableWidth);
        printTopBorder(@columnWidths);
    }

    for my $i (0 .. $#rows) {
        # Print a entire row line-by-line for each cell.
        for my $k (0 .. $rowHeights[$i]) {
            printCenterSpacing($totalTableWidth);
            print $borderLeft[$borderStyle];
            for my $j (0 .. $#{$rows[$i]}) {
                printWithPadding($rows[$i][$j][$k], $columnWidths[$j]);
                if ($j < $#{$rows[$i]}) {
                    print $innerVertical[$borderStyle];
                }
            }
            print $borderRight[$borderStyle];
            print "\n";
        }
        if ($i < $#rows) {
            if (length ($innerHorizontal[$borderStyle]) > 0) {
                printCenterSpacing($totalTableWidth);
                printInnerBorder(@columnWidths);
            }
        }
    }
    if (length ($borderBottomLine[$borderStyle]) > 0) {
        printCenterSpacing($totalTableWidth);
        printBottomBorder(@columnWidths);
    }
}


sub printCenterSpacing($) {
    my $lineWidth = shift;

    if ($centerTables != 0) {
        my $centerSpacing = floor(($pageWidth - $lineWidth) / 2);
        if ($centerSpacing > 1) {
            print repeat(' ', $centerSpacing);
        }
    }
}


sub wrapLines($$) {
    my $paragraph = shift;
    my $maxLength = shift;
    my @lines = split("\n", $paragraph);

    my @result = ();
    foreach my $line (@lines) {
        push @result, wrapLine($line, $maxLength);
    }
    return join ("\n", @result);
}

sub wrapLine($$) {
    my $line = shift;
    my $maxLength = shift;
    my $actualMaxLength = 0;

    my @words = split(/\s+/, $line);

    my $result = '';
    my $currentLength = 0;
    foreach my $word (@words) {
        my $wordLength = length ($word);

        my $newLength = $currentLength == 0 ? $wordLength : $currentLength + $wordLength + 1;

        # Need to start a new line?
        if ($newLength > $maxLength) {
            if ($currentLength != 0) {
                $result .= "\n";
            } else {
                print STDERR "WARNING: single word '$word' longer than $maxLength\n";
            }
            $currentLength = $wordLength;
        } else {
            if ($currentLength != 0) {
                $currentLength++;
                $result .= ' ';
            }
            $currentLength += $wordLength;
        }
        $result .= $word;

        if ($actualMaxLength < $currentLength) {
            $actualMaxLength = $currentLength;
        }
    }

    if ($actualMaxLength > $maxLength) {
        print STDERR "WARNING: could not wrap line to $maxLength; needed $actualMaxLength\n";
    }

    return $result;
}


sub repeat($$) {
    my $char = shift;
    my $count = shift;
    my $result = '';
    for (my $j = 0; $j < $count; $j++) {
        $result .= $char;
    }
    return $result;
}

sub printTopBorder(@) {
    my @columnWidths = @_;
    if (length ($borderTopLine[$borderStyle]) > 0) {
        print $borderTopLeft[$borderStyle];
        for my $i (0 .. $#columnWidths) {
            print repeat($borderTopLine[$borderStyle], $columnWidths[$i]);
            print $i < $#columnWidths ? $borderTopCross[$borderStyle] : $borderTopRight[$borderStyle];
        }
        print "\n";
    }
}

sub printInnerBorder(@) {
    my @columnWidths = @_;
    if (length ($innerHorizontal[$borderStyle]) > 0) {
        print $borderLeftCross[$borderStyle];
        for my $i (0 .. $#columnWidths) {
            print repeat($innerHorizontal[$borderStyle], $columnWidths[$i]);
            print $i < $#columnWidths ? $innerCross[$borderStyle] : $borderRightCross[$borderStyle];
        }
        print "\n";
    }
}

sub printBottomBorder(@) {
    my @columnWidths = @_;
    if (length ($borderBottomLine[$borderStyle]) > 0) {
        print $borderBottomLeft[$borderStyle];
        for my $i (0 .. $#columnWidths) {
            print repeat($borderBottomLine[$borderStyle], $columnWidths[$i]);
            print $i < $#columnWidths ? $borderBottomCross[$borderStyle] : $borderBottomRight[$borderStyle];
        }
        print "\n";
    }
}


sub printWithPadding($$) {
    my $string = shift;
    my $width = shift;

    # Align right if number or amount
    if ($string =~ /^\$? ?[0-9]+([.,][0-9]+)*$/) {
        print spaces($width  - length($string));
        print $string;
    } else {
        print $string;
        print spaces($width  - length($string));
    }
}


sub trim($) {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

#
# handleIntra: handle so-called intra-lineair text, by approaching
# it in plain text.
#
sub handleIntra() {

    print "[** BEGIN INTRA --------------------------]\n";

    while (<>) {
        my $line = $_;
        if ($line =~ m/<\/INTRA>/) {
            print "[** END INTRA --------------------------]\n";
            return;
        }
        chomp($line);

        $line = hideFootnoteMarkers($line);

        # Lines look like this:  "normal text [top text|bottom text] normal text."
        my $normalTexts = $line;
        $normalTexts =~ s/\[\|([^|]+?)\]/<BREAK>/g;
        $normalTexts =~ s/\[([^|]+?)\|\]/<BREAK>/g;
        $normalTexts =~ s/\[([^|]+?)\|([^|]+?)\]/<BREAK>/g;

        my @normals = split(/<BREAK>/, $normalTexts);
        my @tops = $line =~ /\[([^|]*)\|[^|]*\]/g;
        my @bottoms = $line =~ /\[[^|]*\|([^|]*)\]/g;

        my $normalCount = scalar @normals;

        my $start = handleLine($normals[0]);
        my $topLine = $start;
        my $bottomLine = spaces(length($start));

        for (my $i = 0; $i < $normalCount; $i++) {

            my $top = handleLine($tops[$i]);
            my $bottom = handleLine($bottoms[$i]);
            my $n = handleLine($normals[$i + 1]);

            my $nWidth = length($n);
            my $tbWidth = max(length $top, length $bottom);

            # Append the next top + bottom phrase pair.
            my $topPhrase    .= centerStringInWidth($top, $tbWidth);
            my $bottomPhrase .= centerStringInWidth($bottom, $tbWidth);

            if (length($topLine . $topPhrase) > $pageWidth) {
                print restoreFootnoteMarkers($topLine) . "\n";
                print restoreFootnoteMarkers($bottomLine) . "\n\n";
                $topLine = '';
                $bottomLine = '';
            }

            $topLine .= $topPhrase;
            $bottomLine .= $bottomPhrase;

            # Append the next middle piece.
            if (length($topLine . $n) > $pageWidth) {
                print restoreFootnoteMarkers($topLine) . "\n";
                print restoreFootnoteMarkers($bottomLine) . "\n\n";
                $topLine = '';
                $bottomLine = '';
                $n = ltrim($n);
                $nWidth = length($n);
            }
            $topLine .= $n;
            $bottomLine .= spaces($nWidth);

        }
        print restoreFootnoteMarkers($topLine) . "\n";
        print restoreFootnoteMarkers($bottomLine) . "\n\n";
    }
}


sub ltrim($) {
    my $string = shift;
    $string =~ s/^\s+//g;
    return $string;
}


sub hideFootnoteMarkers($) {
    my $string = shift;
    $string =~ s/\[([0-9]+)\]/{$1}/g;
    return $string;
}


sub restoreFootnoteMarkers($) {
    my $string = shift;
    $string =~ s/\{([0-9]+)\}/[$1]/g;
    return $string;
}


sub max($$) {
    my $first = shift;
    my $second = shift;
    return $first > $second ? $first : $second;
}


#
# entities2iso88591: Convert SGML style entities to ISO 8859-1 values (if available)
#
sub entities2iso88591($) {
    my $string = shift;

    # soft-hyphen:
    $string =~ s/\&shy;/\x{00AD}/g;

    # change supported accented letters:
    $string =~ s/\&aacute;/�/g;
    $string =~ s/\&Aacute;/�/g;
    $string =~ s/\&agrave;/�/g;
    $string =~ s/\&Agrave;/�/g;
    $string =~ s/\&acirc;/�/g;
    $string =~ s/\&Acirc;/�/g;
    $string =~ s/\&atilde;/�/g;
    $string =~ s/\&Atilde;/�/g;
    $string =~ s/\&auml;/�/g;
    $string =~ s/\&Auml;/�/g;
    $string =~ s/\&aring;/�/g;
    $string =~ s/\&Aring;/�/g;
    $string =~ s/\&aelig;/�/g;
    $string =~ s/\&AElig;/�/g;

    $string =~ s/\&ccedil;/�/g;
    $string =~ s/\&Ccedil;/�/g;

    $string =~ s/\&eacute;/�/g;
    $string =~ s/\&Eacute;/�/g;
    $string =~ s/\&egrave;/�/g;
    $string =~ s/\&Egrave;/�/g;
    $string =~ s/\&ecirc;/�/g;
    $string =~ s/\&Ecirc;/�/g;
    $string =~ s/\&euml;/�/g;
    $string =~ s/\&Euml;/�/g;

    $string =~ s/\&iacute;/�/g;
    $string =~ s/\&Iacute;/�/g;
    $string =~ s/\&igrave;/�/g;
    $string =~ s/\&Igrave;/�/g;
    $string =~ s/\&icirc;/�/g;
    $string =~ s/\&Icirc;/�/g;
    $string =~ s/\&iuml;/�/g;
    $string =~ s/\&Iuml;/�/g;

    $string =~ s/\&ntilde;/�/g;
    $string =~ s/\&Ntilde;/�/g;

    $string =~ s/\&oacute;/�/g;
    $string =~ s/\&Oacute;/�/g;
    $string =~ s/\&ograve;/�/g;
    $string =~ s/\&Ograve;/�/g;
    $string =~ s/\&ocirc;/�/g;
    $string =~ s/\&Ocirc;/�/g;
    $string =~ s/\&otilde;/�/g;
    $string =~ s/\&Otilde;/�/g;
    $string =~ s/\&ouml;/�/g;
    $string =~ s/\&Ouml;/�/g;
    $string =~ s/\&oslash;/�/g;
    $string =~ s/\&Oslash;/�/g;

    $string =~ s/\&uacute;/�/g;
    $string =~ s/\&Uacute;/�/g;
    $string =~ s/\&ugrave;/�/g;
    $string =~ s/\&Ugrave;/�/g;
    $string =~ s/\&ucirc;/�/g;
    $string =~ s/\&Ucirc;/�/g;
    $string =~ s/\&uuml;/�/g;
    $string =~ s/\&Uuml;/�/g;

    $string =~ s/\&yacute;/�/g;
    $string =~ s/\&Yacute;/�/g;
    $string =~ s/\&yuml;/�/g;

    $string =~ s/\&fnof;/�/g;
    $string =~ s/\&pound;/�/g;
    $string =~ s/\&deg;/�/g;
    $string =~ s/\&ordf;/�/g;
    $string =~ s/\&ordm;/�/g;
    $string =~ s/\&dagger;/�/g;
    $string =~ s/\&para;/�/g;
    $string =~ s/\&sect;/�/g;
    $string =~ s/\&iquest;/�/g;

    $string =~ s/\&laquo;/�/g;
    $string =~ s/\&raquo;/�/g;

    # remove accented and special letters
    $string =~ s/\&eth;/dh/g;
    $string =~ s/\&ETH;/Dh/g;
    $string =~ s/\&thorn;/th/g;
    $string =~ s/\&THORN;/Th/g;
    $string =~ s/\&mdash;/--/g;
    $string =~ s/\&ndash;/-/g;
    $string =~ s/\&longdash;/----/g;
    $string =~ s/\&supndash;/-/g;
    $string =~ s/\&ldquo;/"/g;
    $string =~ s/\&bdquo;/"/g;
    $string =~ s/\&rdquo;/"/g;
    $string =~ s/\&lsquo;/'/g;
    $string =~ s/\&rsquo;/'/g;
    $string =~ s/\&sbquo;/'/g;
    $string =~ s/\&hellip;/.../g;
    $string =~ s/\&thinsp;/ /g;
    $string =~ s/\&nbsp;/�/g;
    $string =~ s/\&zwsp;//g;
    $string =~ s/\&pound;/�/g;
    $string =~ s/\&dollar;/\$/g;
    $string =~ s/\&deg;/�/g;
    $string =~ s/\&dagger;/�/g;
    $string =~ s/\&para;/�/g;
    $string =~ s/\&sect;/�/g;
    $string =~ s/\&commat;/@/g;
    $string =~ s/\&rbrace;/}/g;
    $string =~ s/\&lbrace;/{/g;

    $string =~ s/\&lpar;/(/g;
    $string =~ s/\&rpar;/)/g;
    $string =~ s/\&lsqb;/[/g;
    $string =~ s/\&rsqb;/]/g;
    $string =~ s/\&lcub;/{/g;
    $string =~ s/\&rcub;/}/g;
    $string =~ s/\&num;/#/g;

    # my additions
    $string =~ s/\&eringb;/e/g;
    $string =~ s/\&oubb;/�/g;
    $string =~ s/\&oudb;/�/g;

    $string =~ s/\&eemacr;/ee/g;
    $string =~ s/\&oomacr;/oo/g;
    $string =~ s/\&aemacr;/ae/g;

    $string =~ s/\&osupe;/�/g;
    $string =~ s/\&usupe;/�/g;

    $string =~ s/\&flat;/-flat/g;
    $string =~ s/\&sharp;/-sharp/g;
    $string =~ s/\&natur;/-natural/g;
    $string =~ s/\&Sun;/[Sun]/g;

    $string =~ s/\&chbarb;/ch/g;
    $string =~ s/\&Chbarb;/Ch/g;
    $string =~ s/\&CHbarb;/CH/g;

    $string =~ s/\&ghbarb;/gh/g;
    $string =~ s/\&Ghbarb;/Gh/g;
    $string =~ s/\&GHbarb;/GH/g;

    $string =~ s/\&khbarb;/kh/g;
    $string =~ s/\&Khbarb;/Kh/g;
    $string =~ s/\&KHbarb;/KH/g;

    $string =~ s/\&shbarb;/sh/g;
    $string =~ s/\&Shbarb;/Sh/g;
    $string =~ s/\&SHbarb;/SH/g;

    $string =~ s/\&suptack;/s/g;
    $string =~ s/\&sdntack;/s/g;

    $string =~ s/\&zhbarb;/zh/g;
    $string =~ s/\&Zhbarb;/Zh/g;
    $string =~ s/\&ZHbarb;/ZH/g;

    $string =~ s/\&ayin;/`/g;
    $string =~ s/\&hamza;/'/g;

    $string =~ s/\&amacrdotb;/a/g;

    $string =~ s/\&oumlcirc;/�/g;

    $string =~ s/\&imacacu;/�/g;
    $string =~ s/\&omacacu;/�/g;

    $string =~ s/\&amacracu;/�/g;
    $string =~ s/\&emacracu;/�/g;
    $string =~ s/\&omacracu;/�/g;
    $string =~ s/\&umacracu;/�/g;

    $string =~ s/\&ebrevacu;/�/g;
    $string =~ s/\&imacrtild;/i/g;
    $string =~ s/\&Emacrtild;/E/g;
    $string =~ s/\&emacrtild;/e/g;
    $string =~ s/\&Amacrtild;/�/g;
    $string =~ s/\&amacrtild;/�/g;

    $string =~ s/\&longs;/s/g;
    $string =~ s/\&prime;/'/g;
    $string =~ s/\&Prime;/''/g;
    $string =~ s/\&tprime;/'''/g;
    $string =~ s/\&qprime;/''''/g;
    $string =~ s/\&times;/�/g;
    $string =~ s/\&plusm;/�/g;
    $string =~ s/\&divide;/�/g;
    $string =~ s/\&plusmn;/�/g;
    $string =~ s/\&peso;/P/g;
    $string =~ s/\&Peso;/P/g;
    $string =~ s/\&ngtilde;/ng/g;
    $string =~ s/\&Ngtilde;/Ng/g;
    $string =~ s/\&NGtilde;/NG/g;
    $string =~ s/\&mring;/m/g;
    $string =~ s/\&Mring;/M/g;
    $string =~ s/\&apos;/'/g;
    $string =~ s/\&rhring;/`/g;
    $string =~ s/\&mlapos;/'/g;
    $string =~ s/\&mlprime;/'/g;
    $string =~ s/\&okina;/`/g;
    $string =~ s/\&tcomma;/`/g;
    $string =~ s/\&sup([0-9a-zA-Z]);/$1/g;
    $string =~ s/\&supth;/th/g;
    $string =~ s/\&iexcl;/�/g;
    $string =~ s/\&iquest;/�/g;
    $string =~ s/\&lb;/lb/g;
    $string =~ s/\&dotfil;/.../g;
    $string =~ s/\&dotfiller;/........./g;
    $string =~ s/\&middot;/�/g;
    $string =~ s/\&aeacute;/�/g;
    $string =~ s/\&AEacute;/�/g;
    $string =~ s/\&oeacute;/oe/g;
    $string =~ s/\&dstrok;/d/g;
    $string =~ s/\&Dstrok;/D/g;

    $string =~ s/\&aoacute;/a�/g;

    $string =~ s/\&aewmacr;/ae/g;
    $string =~ s/\&AEmacr;/�/g;
    $string =~ s/\&nbrevdotb;/n/g;
    $string =~ s/\&nchndrb;/n/g;         # n chandrabindu

    $string =~ s/\&iabrevb;/ia/g;        # ia with breve below
    $string =~ s/\&oacbb;/o/g;           # o with acute and bar below
    $string =~ s/\&ocibb;/o/g;           # o with circumflex and bar below
    $string =~ s/\&omacbb;/o/g;          # o with macron and bar below
    $string =~ s/\&icibrb;/i/g;          # i with circumflex and breve below
    $string =~ s/\&idtmac;/i/g;          # i with dot and macron above

    $string =~ s/\&cslash;/�/g;
    $string =~ s/\&grchi;/x/g;
    $string =~ s/\&omactil;/o/g;
    $string =~ s/\&ebreacu;/e/g;
    $string =~ s/\&obrevacu;/o/g;
    $string =~ s/\&umacrtild;/u/g;
    $string =~ s/\&amacacu;/a/g;
    $string =~ s/\&nringb;/n/g;
    $string =~ s/\&ymacr;/y/g;
    $string =~ s/\&eng;/ng/g;
    $string =~ s/\&Rs;/Rs/g;     # Rupee sign.
    $string =~ s/\&tb;/\n\n/g;   # Thematic Break;

    $string =~ s/\&diamond;/*/g;
    $string =~ s/\&triangle;/[triangle]/g;
    $string =~ s/\&bullet;/�/g;

    $string =~ s/CI\&Crev;/M/g;  # roman numeral CI reverse C -> M
    $string =~ s/I\&Crev;/D/g;   # roman numeral I reverse C -> D

    $string =~ s/\&ptildeb;/p/g;
    $string =~ s/\&special;/[symbol]/g;

    $string =~ s/\&florin;/f/g;  # florin sign
    $string =~ s/\&apos;/'/g;    # apostrophe
    $string =~ s/\&emsp;/  /g;   # em-space
    $string =~ s/\&male;/[male]/g;   # male
    $string =~ s/\&female;/[female]/g;   # female
    $string =~ s/\&Esmall;/e/g;  # small capital letter E (used as small letter)
    $string =~ s/\&ast;/*/g; # asterix

    $string =~ s/\&there4;/./g;      # Therefor (three dots in triangular arrangement) used as abbreviation dot.
    $string =~ s/\&maltese;/[+]/g;   # Maltese Cross
    $string =~ s/\&wwelsh;/6/g;      # Old-Welsh w (looks like 6)
    $string =~ s/\&\#x204A;/7/g;     # Tironian et (looks like 7)


    # Small caps letters

    $string =~ s/\&Dsc;/D/g;
    $string =~ s/\&Ysc;/Y/g;


    # Rough Greek transcription

    $string =~ s/\&Alpha;/A/g;       #  GREEK CAPITAL LETTER ALPHA
    $string =~ s/\&Beta;/B/g;        #  GREEK CAPITAL LETTER BETA
    $string =~ s/\&Gamma;/G/g;       #  GREEK CAPITAL LETTER GAMMA
    $string =~ s/\&Delta;/D/g;       #  GREEK CAPITAL LETTER DELTA
    $string =~ s/\&Epsilon;/E/g;     #  GREEK CAPITAL LETTER EPSILON
    $string =~ s/\&Zeta;/Z/g;        #  GREEK CAPITAL LETTER ZETA
    $string =~ s/\&Eta;/�/g;         #  GREEK CAPITAL LETTER ETA
    $string =~ s/\&Theta;/Th/g;      #  GREEK CAPITAL LETTER THETA
    $string =~ s/\&Iota;/I/g;        #  GREEK CAPITAL LETTER IOTA
    $string =~ s/\&Kappa;/K/g;       #  GREEK CAPITAL LETTER KAPPA
    $string =~ s/\&Lambda;/L/g;      #  GREEK CAPITAL LETTER LAMDA
    $string =~ s/\&Mu;/M/g;          #  GREEK CAPITAL LETTER MU
    $string =~ s/\&Nu;/N/g;          #  GREEK CAPITAL LETTER NU
    $string =~ s/\&Xi;/X/g;          #  GREEK CAPITAL LETTER XI
    $string =~ s/\&Omicron;/O/g;     #  GREEK CAPITAL LETTER OMICRON
    $string =~ s/\&Pi;/P/g;          #  GREEK CAPITAL LETTER PI
    $string =~ s/\&Rho;/R/g;         #  GREEK CAPITAL LETTER RHO
    $string =~ s/\&Sigma;/S/g;       #  GREEK CAPITAL LETTER SIGMA
    $string =~ s/\&Tau;/T/g;         #  GREEK CAPITAL LETTER TAU
    $string =~ s/\&Upsilon;/U/g;     #  GREEK CAPITAL LETTER UPSILON
    $string =~ s/\&Upsi;/U/g;        #  GREEK CAPITAL LETTER UPSILON
    $string =~ s/\&Phi;/F/g;         #  GREEK CAPITAL LETTER PHI
    $string =~ s/\&Chi;/Ch/g;        #  GREEK CAPITAL LETTER CHI
    $string =~ s/\&Psi;/Ps/g;        #  GREEK CAPITAL LETTER PSI
    $string =~ s/\&Omega;/�/g;       #  GREEK CAPITAL LETTER OMEGA

    $string =~ s/\&alpha;/a/g;       #  GREEK SMALL LETTER ALPHA
    $string =~ s/\&beta;/b/g;        #  GREEK SMALL LETTER BETA
    $string =~ s/\&gamma;/g/g;       #  GREEK SMALL LETTER GAMMA
    $string =~ s/\&delta;/d/g;       #  GREEK SMALL LETTER DELTA
    $string =~ s/\&epsilon;/e/g;     #  GREEK SMALL LETTER EPSILON
    $string =~ s/\&epsi;/e/g;        #  GREEK SMALL LETTER EPSILON
    $string =~ s/\&zeta;/z/g;        #  GREEK SMALL LETTER ZETA
    $string =~ s/\&eta;/�/g;         #  GREEK SMALL LETTER ETA
    $string =~ s/\&thetas;/th/g;     #  GREEK SMALL LETTER THETA
    $string =~ s/\&theta;/th/g;      #  GREEK SMALL LETTER THETA
    $string =~ s/\&iota;/i/g;        #  GREEK SMALL LETTER IOTA
    $string =~ s/\&kappa;/k/g;       #  GREEK SMALL LETTER KAPPA
    $string =~ s/\&lambda;/l/g;      #  GREEK SMALL LETTER LAMDA
    $string =~ s/\&mu;/m/g;          #  GREEK SMALL LETTER MU
    $string =~ s/\&nu;/n/g;          #  GREEK SMALL LETTER NU
    $string =~ s/\&xi;/x/g;          #  GREEK SMALL LETTER XI
    $string =~ s/\&omicron;/o/g;     #  GREEK SMALL LETTER OMICRON
    $string =~ s/\&pi;/p/g;          #  GREEK SMALL LETTER PI
    $string =~ s/\&rho;/r/g;         #  GREEK SMALL LETTER RHO
    $string =~ s/\&sigma;/s/g;       #  GREEK SMALL LETTER SIGMA
    $string =~ s/\&tau;/t/g;         #  GREEK SMALL LETTER TAU
    $string =~ s/\&upsilon;/u/g;     #  GREEK SMALL LETTER UPSILON
    $string =~ s/\&upsi;/u/g;        #  GREEK SMALL LETTER UPSILON
    $string =~ s/\&phi;/f/g;         #  GREEK SMALL LETTER PHI
    $string =~ s/\&chi;/ch/g;        #  GREEK SMALL LETTER CHI
    $string =~ s/\&psi;/ps/g;        #  GREEK SMALL LETTER PSI
    $string =~ s/\&omega;/�/g;       #  GREEK SMALL LETTER OMEGA

    # Common abbreviations in small-caps -> upper case.
    $string =~ s/\&BC;/B.C./g;       #  Before Christ
    $string =~ s/\&AD;/A.D./g;       #  Anno Domino
    $string =~ s/\&AH;/A.H./g;       #  Anno Heriga
    $string =~ s/\&AM;/A.M./g;       #  Anno Mundi / Ante Meridian
    $string =~ s/\&PM;/P.M./g;       #  Post Meridian

    # Superscript letters and Roman numerals
    $string =~ s/\&supa;/a/g;        #  superscript a (years)
    $string =~ s/\&supd;/d/g;        #  superscript d (days)
    $string =~ s/\&suph;/h/g;        #  superscript h (hours)
    $string =~ s/\&supm;/m/g;        #  superscript m (minutes)
    $string =~ s/\&supc;/c/g;        #  superscript c (circles)
    $string =~ s/\&supI;/I/g;        #  superscript I
    $string =~ s/\&supII;/II/g;      #  superscript II
    $string =~ s/\&supIII;/III/g;    #  superscript III
    $string =~ s/\&supIV;/IV/g;      #  superscript IV
    $string =~ s/\&supV;/V/g;        #  superscript V
    $string =~ s/\&supVI;/VI/g;      #  superscript VI

    # Phantom characters (used for easy alignment in tables) 
    $string =~ s/\&ph\.deg;/ /g;     #  Phantom degree sign
    $string =~ s/\&ph\.pr;/ /g;      #  Phantom prime
    $string =~ s/\&ph\.Pr;/ /g;      #  Phantom double prime
    $string =~ s/\&ph\.tpr;/ /g;     #  Phantom triple prime
    $string =~ s/\&ph\.qpr;/ /g;     #  Phantom quadruple prime
    $string =~ s/\&ph\.supa;/ /g;    #  Phantom superscript a (years)
    $string =~ s/\&ph\.supd;/ /g;    #  Phantom superscript d (days)
    $string =~ s/\&ph\.suph;/ /g;    #  Phantom superscript h (hours)
    $string =~ s/\&ph\.supm;/ /g;    #  Phantom superscript m (minutes)
    $string =~ s/\&ph\.supc;/ /g;    #  Phantom superscript c (circles)
    $string =~ s/\&ph\.supI;/ /g;    #  Phantom superscript I
    $string =~ s/\&ph\.supII;/ /g;   #  Phantom superscript II
    $string =~ s/\&ph\.supIII;/ /g;  #  Phantom superscript III
    $string =~ s/\&ph\.supIV;/ /g;   #  Phantom superscript IV
    $string =~ s/\&ph\.supV;/ /g;    #  Phantom superscript V
    $string =~ s/\&ph\.supVI;/ /g;   #  Phantom superscript VI
    $string =~ s/\&ph\.comma;/ /g;   #  Phantom comma
    $string =~ s/\&ph\.period;/ /g;  #  Phantom period
    $string =~ s/\&ph\.zero;/ /g;    #  Phantom zero

    $string =~ s/\&ph\.czero;/  /g;  #  Phantom comma zero
    $string =~ s/\&ph\.pzero;/  /g;  #  Phantom period zero

    $string =~ s/\&ph\.czz;/   /g;   #  Phantom comma zero zero
    $string =~ s/\&ph\.pzz;/   /g;   #  Phantom period zero zero

    # strip accents from remaining entities
    $string =~ s/\&([a-zA-Z])(breve|macr|acute|grave|uml|umlb|tilde|circ|cedil|dotb|dot|breveb|caron|comma|barb|circb|bowb|dota);/$1/g;
    $string =~ s/\&([a-zA-Z]{2})lig;/$1/g;
    $string =~ s/([0-9])\&frac([0-9])([0-9]*);/$1 $2\/$3/g;  # fraction preceded by number
    $string =~ s/\&frac([0-9])([0-9]*);/$1\/$2/g; # other fractions
    $string =~ s/\&frac([0-9])-([0-9]*);/$1\/$2/g; # other fractions
    $string =~ s/\&frac([0-9]+)-([0-9]*);/$1\/$2/g; # other fractions

    $string =~ s/\&time([0-9])([0-9]*);/$1\/$2/g; # musical time; handle as fraction.

    $string =~ s/\&\#x0361;//g; # non-spacing bow.

    return $string;
}
