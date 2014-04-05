# tei2txt.pl -- TEI to plain vanilla ASCII text

use strict;

use Getopt::Long;
use POSIX qw/floor/;

use SgmlSupport qw/getAttrVal sgml2utf/;

my $useUnicode = 0;
my $useItalics = 0;
my $pageWidth = 72;
my $centerTables = 1;

GetOptions(
    'u' => \$useUnicode,
    'w=i' => \$pageWidth);

if ($useUnicode == 1)
{
    binmode(STDOUT, ":utf8");
    use open ':utf8';
}

my $tagPattern = "<(.*?)>";
my $italicStart = "_";
my $italicEnd = "_";


if ($useItalics == 1)
{
    $italicStart = "_";
    $italicEnd = "_";
}
else
{
    $italicStart = "";
    $italicEnd = "";
}


#    0.                   1.              2.              3.            4.              5.
#
#    No borders, just     +===+===+       =========       /=======\     =========       =========
#    three spaces         |   |   |       |   |   |       |   |   |                         |
#    between columns      +---+---+       |---+---|       |---+---|                     ----+----
#                         |   |   |       |   |   |       |   |   |     =========           |
#                         +===+===+       =========       \=======/                     =========
#

my $borderStyle = 0;

my @borderTopLeft       = ("",      "+=",   "==",   "/=",   "",     "");
my @borderTopLine       = ("",      "=",    "=",    "=",    "=",    "=");
my @borderTopCross      = ("",      "=+=",  "===",  "===",  "===",  "===");
my @borderTopRight      = ("",      "=+",   "==",   "=\\",  "",     "");

my @borderLeft          = ("",      "| ",   "| ",   "| ",   "",     "");
my @borderLeftCross     = ("",      "+-",   "|-",   "|-",   "",     "");
my @borderRight         = ("",      " |",   " |",   " |",   "",     "");
my @borderRightCross    = ("",      "-+",   "-|",   "-|",   "",     "");

my @innerVertical       = ("   ",   " | ",  " | ",  " | ",  "   ",  " | ");
my @innerCross          = ("   ",   "-+-",  "-+-",  "-+-",  "   ",  "-+-");
my @innerHorizontal     = ("",      "-",    "-",    "-",    "",     "-");

my @borderBottomLeft    = ("",      "+=",   "==",   "\\=",  "",     "");
my @borderBottomLine    = ("",      "=",    "=",    "=",    "=",    "=");
my @borderBottomCross   = ("",      "=+=",  "===",  "===",  "===",  "===");
my @borderBottomRight   = ("",      "=+",   "==",   "=/",   "",     "");


#
# Main program loop
#

while (<>)
{
    my $a = $_;

    # remove TeiHeader
    if ($a =~ /<[Tt]ei[Hh]eader/)
    {
        $a = $';
        while($a !~ /<\/[Tt]ei[Hh]eader>/)
        {
            $a = <>;
        }
        $a =~ /<\/[Tt]ei[Hh]eader>/;
        $a = $';
    }

    # drop comments from text (replace with single space).
    $a =~ s/<!--.*?-->/ /g;
    # warn for remaining comments
    $a =~ s/<!--/[**ERROR: unhandled comment start]/g;

    # warn for notes (which should have been handled in a separate process)
    $a =~ s/<note\b.*?>/[**ERROR: unhandled note start tag]/g;
    $a =~ s/<\/note\b.*?>/[**ERROR: unhandled note end tag]/g;

    # generate part headings
    if ($a =~ /<(div0.*?)>/)
    {
        my $tag = $1;
        my $partNumber = getAttrVal("n", $tag);
        if ($partNumber ne "")
        {
            print "\nPART $partNumber\n";
        }
    }

    # generate chapter headings
    if ($a =~ /<(div1.*?)>/)
    {
        my $tag = $1;
        my $chapterNumber = getAttrVal("n", $tag);
        if ($chapterNumber ne "")
        {
            print "\nCHAPTER $chapterNumber\n";
        }
    }

    # generate section headings
    if ($a =~ /<(div2.*?)>/)
    {
        my $tag = $1;
        my $sectionNumber = getAttrVal("n", $tag);
        if ($sectionNumber ne "")
        {
            print "\nSECTION $sectionNumber\n";
        }
    }

    # generate figure headings
    if ($a =~ /<(figure.*?)>/)
    {
        my $tag = $1;
        my $figureNumber = getAttrVal("n", $tag);
        print "\n------\nFIGURE $figureNumber\n";
    }
    if ($a =~ /<\/figure>/)
    {
        print "------\n";
    }

    # indicate tables for manual processing.
    if ($a =~ /<table.*?>/)
    {
        print "\n[**TODO: Verify table]\n";
        parseTable($a);
    }
    if ($a =~ /<\/table>/)
    {
        print "------\n";
    }

    $a = handleLine($a);


    print $a;
}


sub handleLine($)
{
    my $a = shift;

    # convert entities
    if ($useUnicode == 1)
    {
        $a = sgml2utf($a);
    }
    else
    {
        $a = entities2iso88591($a);
    }

    $a = handleHighlighted($a);

    # handle cell boundaries (non should remain if tables are parsed correctly)
    $a =~ s/<cell(.*?)>/|/g;

    # drop page-breaks (<pb>) as they interfere with the following processing.
    $a =~ s/<pb\b(.*?)>//g;

    # handle numbered lines of verse
    if ($a =~ /( +)<l\b(.*?)>/)
    {
        my $prefix = $`;
        my $remainder = $';
        my $spaces = $1;
        my $attrs = $2;
        my $n = getAttrVal("n", $attrs);
        if ($n)
        {
            my $need = length($spaces) - length($n);
            my $need = $need < 1 ? 1 : $need;
            $a = $prefix . $n . spaces($need) . $remainder;
        }
    }

    # remove any remaining tags
    $a =~ s/<.*?>//g;

    # Some problematic entities from Wolff.
    $a =~ s/\&larr;/<-/g;   # Left Arrow
    $a =~ s/\&rarr;/->/g;   # Right Arrow

    # warn for entities that slipped through.
    if ($a =~ /\&([a-zA-Z0-9._-]+);/)
    {
        my $ent = $1;
        if (!($ent eq "gt" || $ent eq "lt" || $ent eq "amp"))
        {
            print "\n[**ERROR: Contains unhandled entity &$ent;]\n";
        }
    }

    # remove the last remaining entities
    $a =~ s/\&gt;/>/g;
    $a =~ s/\&lt;/</g;
    $a =~ s/\&amp;/&/g;

    # warn for anything that slipped through.
    # BUG: if for example &c; should appear in the output, a bug will be reported
    # $a =~ s/\&\w+;/[ERROR: unhandled $&]/g;

    return $a;
}


sub spaces($)
{
    my $n = shift;
    my $result = "";
    for (my $i = 0; $i < $n; $i++)
    {
        $result .= " ";
    }
    return $result;
}

sub handleHighlighted($)
{
    my $remainder = shift;

    my $a = "";
    while ($remainder =~ /<hi(.*?)>(.*?)<\/hi>/)
    {
        my $attrs = $1;
        my $rend = getAttrVal("rend", $attrs);
        if ($rend eq "sup")
        {
            $a .= $` . $2;
        }
        elsif ($rend eq "sc" || $rend eq "expanded")
        {
            $a .= $` . $2;
        }
        else
        {
            $a .= $` . $italicStart . $2 . $italicEnd;
        }
        $remainder = $';
    }
    return $a . $remainder;
}

sub parseTable($)
{
    my $table = shift;
    while (<>)
    {
        my $line = $_;
        $table .= $line;
        if ($line =~ /<\/table>/)
        {
            my @result = handleTable($table);
            my @wrappedTable = sizeTableColumns($pageWidth - 1, @result);
            printTable(@wrappedTable);
            return;
        }
    }
}

# Place a table in a three-dimensional array: rows, cells, lines (within each cell)
#
sub handleTable($)
{
    my $table = shift;
    # $table =~ s/\n/ /gms; # Remove new-lines for easier handling with default regex.
    $table =~ /<table(.*?)>(.*?)<\/table>/ms;
    my $tableContent = $2;

    my @rows = split(/<row.*?>/ms, $tableContent);

    # First element in result is empty, so drop it
    shift @rows;
    my @result = ();
    foreach my $row (@rows)
    {
        $row = trim($row);
        push @result, [ handleRow($row) ];
    }
    return @result;
}

sub handleRow($)
{
    my $row = shift;
    my @items = split(/<cell\b(.*?)>/ms, $row);
    my @cells = ();
    my @colspans = ();
    my @rowspans = ();

    # every second item contains tag; first cell is empty.
    for (my $i = 0; $i <= $#items; $i++)
    {
        my $item = $items[$i];
        if ($i % 2 == 0)
        {
            push @cells, $item;
        }
        else
        {
            my $cols = getAttrVal("cols", $item);
            my $rows = getAttrVal("rows", $item);

            $cols = $cols eq "" ? 1 : $cols;
            $rows = $rows eq "" ? 1 : $rows;

            push @colspans, $cols;
            push @rowspans, $rows;
        }
    }

    # First element in result is empty, so drop it
    shift @cells;

    my @result = ();
    foreach my $cell (@cells)
    {
        $cell = handleLine(trim($cell));
        push @result, [ handleCell($cell) ];
    }
    return @result;
}

sub handleCell($)
{
    my $cell = shift;
    my @lines = split("\n", $cell);

    my @result = ();
    foreach my $line (@lines)
    {
        $line = trim($line);
        $line =~ s/\s+/ /g;
        push @result, $line;
    }
    return @result;
}


sub sizeTableColumns($@)
{
    # See also: https://developer.mozilla.org/en-US/docs/Table_Layout_Strategy
    # See http://nothings.org/computer/badtable/
    # in particular: http://www.csse.monash.edu.au/~marriott/HurMarMou05.pdf
    # http://www.csse.monash.edu.au/~marriott/HurMarAlb06.pdf

    my $finalWidth = shift;
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

    for my $i (0 .. $#rows)
    {
        my $cellCount = $#{$rows[$i]};
        for my $j (0 .. $cellCount)
        {
            my $cellHeight = $#{$rows[$i][$j]};
            for my $k (0 .. $cellHeight)
            {
                my $line = $rows[$i][$j][$k];
                my $lineLength = length($line);
                $columnArea[$j] += $lineLength;
                $totalArea += $lineLength;
                if ($lineLength > $desiredColumnWidths[$j])
                {
                    $desiredColumnWidths[$j] = $lineLength;
                }

                my @words = split(/\s+/, $line);
                foreach my $word (@words)
                {
                    my $wordLength = length($word);
                    if ($wordLength > $minimalColumnWidths[$j])
                    {
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
    for my $j (0 .. $#minimalColumnWidths)
    {
        $columns++;
        ##print STDERR "\nCOLUMN: $j WIDTH: $minimalColumnWidths[$j] WORD: $widestWord[$j]";
        $finalColumnWidths[$j] = $minimalColumnWidths[$j];
        $minimalWidth += $minimalColumnWidths[$j];
    }

    # Adjust final width for borders (left 2; between 3; right 2)
    my $borderAdjustment = (($columns - 1) * length($innerCross[$borderStyle])) +
        length($borderLeft[$borderStyle]) +
        length($borderRight[$borderStyle]);

    ##print STDERR "\nTOTAL WIDTH: $finalWidth - $borderAdjustment for $columns columns";

    $finalWidth -= $borderAdjustment;

    if ($minimalWidth > $finalWidth)
    {
        print STDERR "WARNING: Table cannot be fitted into " . ($finalWidth + $borderAdjustment) . " columns! Need " . ($minimalWidth + $borderAdjustment) . " columns.\n";
    }

    # Now we need to distribute the remaining width, by adding it to the most needy column

    # Calculate entitlements (how much every column is supposed to have, based on its area)
    ##print STDERR "\n\nEstablishing column widths (rows: $#rows; columns: $columns; width: $finalWidth; area: $totalArea)";
    my @entitlement = ();
    my @fillFactor = ();
    for my $j (0 .. $columns - 1)
    {
        my $fraction = sqrt($columnArea[$j]) / sqrt($totalArea);
        $entitlement[$j] = $finalWidth * $fraction;
        ##print STDERR "\nColumn $j: ";
        my $pfraction = floor($fraction * 100.0)/100.0;
        my $pentitlement = floor($entitlement[$j]);
        ##print STDERR "\n    width: $finalColumnWidths[$j];\n    area: $desiredColumnWidths[$j]\n    fraction: $pfraction; \n    entitlement: $pentitlement";
        if ($finalColumnWidths[$j] >= $desiredColumnWidths[$j])
        {
            $fillFactor[$j] = 1.0;
        }
        else
        {
            $fillFactor[$j] = $finalColumnWidths[$j] / $entitlement[$j];
        }
        ##print STDERR "\n    fill factor: $fillFactor[$j]";
    }

    # Add spaces to columns with the lowest fill factor, recalculating it as we go;
    my $remainingWidth = $finalWidth - $minimalWidth;
    while ($remainingWidth > 0)
    {
        my $mostNeedy = -1;
        my $worstFillFactor = 1;
        # Find column with lowest fill factor;
        for my $j (0 .. $columns - 1)
        {
            if ($fillFactor[$j] < 1.0 && $fillFactor[$j] < $worstFillFactor)
            {
                $mostNeedy = $j;
                $worstFillFactor = $fillFactor[$j];
            }
        }

        if ($mostNeedy == -1)
        {
            # All columns are satisfied
            last;
        }
        else
        {
            # Give that column an extra space and recalculate fill factor
            $remainingWidth--;
            $finalColumnWidths[$mostNeedy]++;

            if ($finalColumnWidths[$mostNeedy] >= $desiredColumnWidths[$mostNeedy])
            {
                $fillFactor[$mostNeedy] = 1.0;
            }
            else
            {
                $fillFactor[$mostNeedy] = $finalColumnWidths[$mostNeedy] / $entitlement[$mostNeedy];
            }
        }
    }

    # TODO: optimize the table.

    # Break lines in cells.
    for my $i (0 .. $#rows)
    {
        for my $j (0 .. $#{$rows[$i]})
        {
            my @newCell = ();
            my $cellHeight = $#{$rows[$i][$j]};

            ## print STDERR "\nCOLUMN $j: wrapping to $finalColumnWidths[$j]";

            for my $k (0 .. $cellHeight)
            {
                my $line = $rows[$i][$j][$k];
                if ($line eq "")
                {
                    # Handle empty lines directly.
                    push (@newCell, "");
                }
                else
                {
                    my $wrappedLine = wrapLine($line, $finalColumnWidths[$j]);
                    push (@newCell, split("\n", $wrappedLine));
                }
            }
            $rows[$i][$j] = [ @newCell ];
        }
    }
    return @rows;
}


sub minimumCellHeightGivenWidth($$)
{
    my $width = shift;
    my $cell = shift;

    # Just break lines greedily.
    my $line = shift;
    my $maxLength = shift;
    my @lines = split("\n", $line);

    my $height = 0;
    foreach my $line (@lines)
    {
        $height += minimumLineHeightGivenWidth($line, $width);
    }
    return $height;
}


sub minimumLineHeightGivenWidth($$)
{
    my $line = shift;
    my $width = shift;

    my @words = split(/\s+/, $line);

    my $height = 1;
    my $currentWidth = 0;
    foreach my $word (@words)
    {
        my $wordWidth = length ($word);
        $currentWidth += $wordWidth;
        if ($currentWidth > $width)
        {
            $height++;
            $currentWidth = $wordWidth;
        }
        else
        {
            if ($currentWidth != 0)
            {
                $currentWidth++;
            }
        }
    }
    return $height;
}


sub nextShorterLineWidth($$$)
{
    my $line = shift;
    my $width = shift;
    my $height = shift;

    my @words = split(/\s+/, $line);

    # Find word widths (should be stored)
    my @widths = ();
    my $n = 0;
    foreach my $word (@words)
    {
        $widths[$n] = length ($word);
        $n++;
    }

    # find line starting words;
    my $i = 0;
    my $lastLine = 0;
    my @lineStart = ();
    $lineStart[0] = 0;
    my $currentWidth = 0;
    foreach my $word (@words)
    {
        $currentWidth += $widths[$i];
        if ($currentWidth > $width)
        {
            $lastLine++;
            $lineStart[$lastLine] = $i;
            $currentWidth = $widths[$i];
        }
        else
        {
            if ($currentWidth != 0)
            {
                $currentWidth++;
            }
        }
    }

    # We have split the line with the original width. Now
    # merge last line into previous line.

    my @minWidth = ();
    my $lineLength = $widths[$n - 1];
    for (my $w = $n - 1; $w > $lineStart[$lastLine - 2]; $w--)
    {
        $minWidth[$w] = max($width, $lineLength);
        $lineLength = $lineLength + 1 + $widths[$w - 1];
    }

    for (my $L = $lastLine - 3; $L >= 0; $L--)
    {
        my $nlw = $lineStart[$L + 1];
        $lineLength = $widths[$lineStart[$L]];
        for (my $w = $lineStart[$L] + 1; $w < $lineStart[$L + 1] -1 ;$w++)
        {
            $lineLength = $widths[$w] + 1 + $lineLength;
        }
        for (my $w = $lineStart[$L] + 1; $w < $lineStart[$L + 1] -1 ;$w++)
        {
            while ($minWidth[$nlw] > $lineLength && $nlw < $lineStart[$L + 2])
            {
                $lineLength = $lineLength + 1 + $widths[$nlw];
                $nlw++;
            }
            $minWidth[$w] = min($minWidth[$nlw - 1], $lineLength);
            $lineLength = $lineLength - (1 + $widths[$w]);
        }
    }
    return $minWidth[0];
}


sub totalTableWidth(@)
{
    my @columnWidths = @_;

    my $totalTableWidth = length($borderLeft[$borderStyle]);
    for my $i (0 .. $#columnWidths)
    {
        $totalTableWidth += $columnWidths[$i];
        $totalTableWidth += $i < $#columnWidths ? length($innerCross[$borderStyle]) : length($borderRight[$borderStyle]);
    }
    ##print STDERR "totalTableWidth: $totalTableWidth\n";
    return $totalTableWidth;
}


sub printTable(@)
{
    my @rows = @_;

    # Establish the width of each column and height of each row
    my @columnWidths = ();
    my @rowHeights = ();

    for my $i (0 .. $#rows)
    {
        for my $j (0 .. $#{$rows[$i]})
        {
            my $cellHeight = $#{$rows[$i][$j]};
            for my $k (0 .. $cellHeight)
            {
                my $line = $rows[$i][$j][$k];
                my $lineLength = length($line);
                if ($lineLength > $columnWidths[$j])
                {
                    $columnWidths[$j] = $lineLength;
                }
            }
            if ($cellHeight > $rowHeights[$i])
            {
                $rowHeights[$i] = $cellHeight;
            }
        }
    }

    my $totalTableWidth = totalTableWidth(@columnWidths);

    if (length ($borderTopLine[$borderStyle]) > 0)
    {
        printCenterSpacing($totalTableWidth);
        printTopBorder(@columnWidths);
    }

    for my $i (0 .. $#rows)
    {
        # Print a entire row line-by-line for each cell.
        for my $k (0 .. $rowHeights[$i])
        {
            printCenterSpacing($totalTableWidth);
            print $borderLeft[$borderStyle];
            for my $j (0 .. $#{$rows[$i]})
            {
                printWithPadding($rows[$i][$j][$k], $columnWidths[$j]);
                if ($j < $#{$rows[$i]})
                {
                    print $innerVertical[$borderStyle];
                }
            }
            print $borderRight[$borderStyle];
            print "\n";
        }
        if ($i < $#rows)
        {
            if (length ($innerHorizontal[$borderStyle]) > 0)
            {
                printCenterSpacing($totalTableWidth);
                printInnerBorder(@columnWidths);
            }
        }
    }
    if (length ($borderBottomLine[$borderStyle]) > 0)
    {
        printCenterSpacing($totalTableWidth);
        printBottomBorder(@columnWidths);
    }
}


sub printCenterSpacing($)
{
    my $lineWidth = shift;

    if ($centerTables != 0)
    {
        my $centerSpacing = floor(($pageWidth - $lineWidth) / 2);
        if ($centerSpacing > 1)
        {
            print repeat(' ', $centerSpacing);
        }
    }
}


sub wrapLines($$)
{
    my $line = shift;
    my $maxLength = shift;
    my @lines = split("\n", $line);

    my @result = ();
    foreach my $line (@lines)
    {
        push @result, wrapLine($line, $maxLength);
    }
    return join ("\n", @result);
}

sub wrapLine($$)
{
    my $line = shift;
    my $maxLength = shift;
    my $actualMaxLength = 0;

    my @words = split(/\s+/, $line);

    my $result = "";
    my $currentLength = 0;
    foreach my $word (@words)
    {
        my $wordLength = length ($word);

        my $newLength = $currentLength == 0 ? $wordLength : $currentLength + $wordLength + 1;

        # Need to start a new line?
        if ($newLength > $maxLength)
        {
            if ($currentLength != 0)
            {
                $result .= "\n";
            }
            else
            {
                print STDERR "WARNING: single word '$word' longer than $maxLength\n";
            }
            $currentLength = $wordLength;
        }
        else
        {
            if ($currentLength != 0)
            {
                $currentLength++;
                $result .= " ";
            }
            $currentLength += $wordLength;
        }
        $result .= $word;

        if ($actualMaxLength < $currentLength)
        {
            $actualMaxLength = $currentLength;
        }
    }

    if ($actualMaxLength > $maxLength)
    {
        print STDERR "WARNING: could not wrap line to $maxLength; needed $actualMaxLength\n";
    }

    return $result;
}


sub repeat($$)
{
    my $char = shift;
    my $count = shift;
    my $result = "";
    for (my $j = 0; $j < $count; $j++)
    {
        $result .= $char;
    }
    return $result;
}

sub printTopBorder(@)
{
    my @columnWidths = @_;
    if (length ($borderTopLine[$borderStyle]) > 0)
    {
        print $borderTopLeft[$borderStyle];
        for my $i (0 .. $#columnWidths)
        {
            print repeat($borderTopLine[$borderStyle], $columnWidths[$i]);
            print $i < $#columnWidths ? $borderTopCross[$borderStyle] : $borderTopRight[$borderStyle];
        }
        print "\n";
    }
}

sub printInnerBorder(@)
{
    my @columnWidths = @_;
    if (length ($innerHorizontal[$borderStyle]) > 0)
    {
        print $borderLeftCross[$borderStyle];
        for my $i (0 .. $#columnWidths)
        {
            print repeat($innerHorizontal[$borderStyle], $columnWidths[$i]);
            print $i < $#columnWidths ? $innerCross[$borderStyle] : $borderRightCross[$borderStyle];
        }
        print "\n";
    }
}

sub printBottomBorder(@)
{
    my @columnWidths = @_;
    if (length ($borderBottomLine[$borderStyle]) > 0)
    {
        print $borderBottomLeft[$borderStyle];
        for my $i (0 .. $#columnWidths)
        {
            print repeat($borderBottomLine[$borderStyle], $columnWidths[$i]);
            print $i < $#columnWidths ? $borderBottomCross[$borderStyle] : $borderBottomRight[$borderStyle];
        }
        print "\n";
    }
}


sub printWithPadding($$)
{
    my $string = shift;
    my $width = shift;

    # Align right if number or amount
    if ($string =~ /^\$? ?[0-9]+([.,][0-9]+)*$/)
    {
        print spaces($width  - length($string));
        print $string;
    }
    else
    {
        print $string;
        print spaces($width  - length($string));
    }
}


sub trim($)
{
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

#
# entities2iso88591: Convert SGML style entities to ISO 8859-1 values (if available)
#
sub entities2iso88591($)
{
    my $a = shift;

    # change supported accented letters:
    $a =~ s/\&aacute;/á/g;
    $a =~ s/\&Aacute;/Á/g;
    $a =~ s/\&agrave;/à/g;
    $a =~ s/\&Agrave;/À/g;
    $a =~ s/\&acirc;/â/g;
    $a =~ s/\&Acirc;/Â/g;
    $a =~ s/\&atilde;/ã/g;
    $a =~ s/\&Atilde;/Ã/g;
    $a =~ s/\&auml;/ä/g;
    $a =~ s/\&Auml;/Ä/g;
    $a =~ s/\&aring;/å/g;
    $a =~ s/\&Aring;/Å/g;
    $a =~ s/\&aelig;/æ/g;
    $a =~ s/\&AElig;/Æ/g;

    $a =~ s/\&ccedil;/ç/g;
    $a =~ s/\&Ccedil;/Ç/g;

    $a =~ s/\&eacute;/é/g;
    $a =~ s/\&Eacute;/É/g;
    $a =~ s/\&egrave;/è/g;
    $a =~ s/\&Egrave;/È/g;
    $a =~ s/\&ecirc;/ê/g;
    $a =~ s/\&Ecirc;/Ê/g;
    $a =~ s/\&euml;/ë/g;
    $a =~ s/\&Euml;/Ë/g;

    $a =~ s/\&iacute;/í/g;
    $a =~ s/\&Iacute;/Í/g;
    $a =~ s/\&igrave;/ì/g;
    $a =~ s/\&Igrave;/Ì/g;
    $a =~ s/\&icirc;/î/g;
    $a =~ s/\&Icirc;/Î/g;
    $a =~ s/\&iuml;/ï/g;
    $a =~ s/\&Iuml;/Ï/g;

    $a =~ s/\&ntilde;/ñ/g;
    $a =~ s/\&Ntilde;/Ñ/g;

    $a =~ s/\&oacute;/ó/g;
    $a =~ s/\&Oacute;/Ó/g;
    $a =~ s/\&ograve;/ò/g;
    $a =~ s/\&Ograve;/Ò/g;
    $a =~ s/\&ocirc;/ô/g;
    $a =~ s/\&Ocirc;/Ô/g;
    $a =~ s/\&otilde;/õ/g;
    $a =~ s/\&Otilde;/Õ/g;
    $a =~ s/\&ouml;/ö/g;
    $a =~ s/\&Ouml;/Ö/g;
    $a =~ s/\&oslash;/ø/g;
    $a =~ s/\&Oslash;/Ø/g;

    $a =~ s/\&uacute;/ú/g;
    $a =~ s/\&Uacute;/Ú/g;
    $a =~ s/\&ugrave;/ù/g;
    $a =~ s/\&Ugrave;/Ù/g;
    $a =~ s/\&ucirc;/û/g;
    $a =~ s/\&Ucirc;/Û/g;
    $a =~ s/\&uuml;/ü/g;
    $a =~ s/\&Uuml;/Ü/g;

    $a =~ s/\&yacute;/ý/g;
    $a =~ s/\&Yacute;/Ý/g;
    $a =~ s/\&yuml;/ÿ/g;

    $a =~ s/\&fnof;/ƒ/g;
    $a =~ s/\&pound;/£/g;
    $a =~ s/\&deg;/°/g;
    $a =~ s/\&ordf;/ª/g;
    $a =~ s/\&ordm;/º/g;
    $a =~ s/\&dagger;/†/g;
    $a =~ s/\&para;/¶/g;
    $a =~ s/\&sect;/§/g;
    $a =~ s/\&iquest;/¿/g;

    $a =~ s/\&laquo;/«/g;
    $a =~ s/\&raquo;/»/g;

    # remove accented and special letters
    $a =~ s/\&eth;/dh/g;
    $a =~ s/\&ETH;/Dh/g;
    $a =~ s/\&thorn;/th/g;
    $a =~ s/\&THORN;/Th/g;
    $a =~ s/\&mdash;/--/g;
    $a =~ s/\&ndash;/-/g;
    $a =~ s/\&longdash;/----/g;
    $a =~ s/\&supndash;/-/g;
    $a =~ s/\&ldquo;/"/g;
    $a =~ s/\&bdquo;/"/g;
    $a =~ s/\&rdquo;/"/g;
    $a =~ s/\&lsquo;/'/g;
    $a =~ s/\&rsquo;/'/g;
    $a =~ s/\&sbquo;/'/g;
    $a =~ s/\&hellip;/.../g;
    $a =~ s/\&thinsp;/ /g;
    $a =~ s/\&nbsp;/ /g;
    $a =~ s/\&pound;/£/g;
    $a =~ s/\&dollar;/\$/g;
    $a =~ s/\&deg;/°/g;
    $a =~ s/\&dagger;/†/g;
    $a =~ s/\&para;/¶/g;
    $a =~ s/\&sect;/§/g;
    $a =~ s/\&commat;/@/g;
    $a =~ s/\&rbrace;/}/g;
    $a =~ s/\&lbrace;/{/g;


    # my additions
    $a =~ s/\&eringb;/e/g;
    $a =~ s/\&oubb;/ö/g;
    $a =~ s/\&oudb;/ö/g;

    $a =~ s/\&osupe;/ö/g;
    $a =~ s/\&usupe;/ü/g;

    $a =~ s/\&flat;/-flat/g;
    $a =~ s/\&sharp;/-sharp/g;
    $a =~ s/\&natur;/-natural/g;
    $a =~ s/\&Sun;/[Sun]/g;

    $a =~ s/\&ghbarb;/gh/g;
    $a =~ s/\&Ghbarb;/Gh/g;
    $a =~ s/\&GHbarb;/GH/g;

    $a =~ s/\&khbarb;/kh/g;
    $a =~ s/\&Khbarb;/Kh/g;
    $a =~ s/\&KHbarb;/KH/g;

    $a =~ s/\&shbarb;/sh/g;
    $a =~ s/\&Shbarb;/Sh/g;
    $a =~ s/\&SHbarb;/SH/g;

    $a =~ s/\&zhbarb;/zh/g;
    $a =~ s/\&Zhbarb;/Zh/g;
    $a =~ s/\&ZHbarb;/ZH/g;

    $a =~ s/\&ayin;/`/g;
    $a =~ s/\&hamza;/'/g;

    $a =~ s/\&amacrdotb;/a/g;

    $a =~ s/\&oumlcirc;/ö/g;

    $a =~ s/\&imacacu;/í/g;
    $a =~ s/\&omacacu;/ó/g;

    $a =~ s/\&longs;/s/g;
    $a =~ s/\&prime;/'/g;
    $a =~ s/\&Prime;/''/g;
    $a =~ s/\&times;/×/g;
    $a =~ s/\&plusm;/±/g;
    $a =~ s/\&divide;/÷/g;
    $a =~ s/\&plusmn;/±/g;
    $a =~ s/\&peso;/P/g;
    $a =~ s/\&Peso;/P/g;
    $a =~ s/\&ngtilde;/ng/g;
    $a =~ s/\&apos;/'/g;
    $a =~ s/\&mlapos;/'/g;
    $a =~ s/\&okina;/`/g;
    $a =~ s/\&sup([0-9a-zA-Z]);/$1/g;
    $a =~ s/\&supth;/th/g;
    $a =~ s/\&iexcl;/¡/g;
    $a =~ s/\&iquest;/¿/g;
    $a =~ s/\&lb;/lb/g;
    $a =~ s/\&dotfil;/.../g;
    $a =~ s/\&dotfiller;/........./g;
    $a =~ s/\&middot;/·/g;
    $a =~ s/\&aeacute;/æ/g;
    $a =~ s/\&AEacute;/Æ/g;
    $a =~ s/\&oeacute;/oe/g;
    $a =~ s/\&cslash;/¢/g;
    $a =~ s/\&grchi;/x/g;
    $a =~ s/\&omactil;/o/g;
    $a =~ s/\&ebreacu;/e/g;
    $a =~ s/\&amacacu;/a/g;
    $a =~ s/\&ymacr;/y/g;
    $a =~ s/\&eng;/ng/g;
    $a =~ s/\&Rs;/Rs/g;     # Rupee sign.
    $a =~ s/\&tb;/\n\n/g;   # Thematic Break;

    $a =~ s/\&diamond;/*/g;
    $a =~ s/\&triangle;/[triangle]/g;
    $a =~ s/\&bullet;/·/g;

    $a =~ s/CI\&Crev;/M/g;  # roman numeral CI reverse C -> M
    $a =~ s/I\&Crev;/D/g;   # roman numeral I reverse C -> D

    $a =~ s/\&ptildeb;/p/g;
    $a =~ s/\&special;/[symbol]/g;

    $a =~ s/\&florin;/f/g;  # florin sign
    $a =~ s/\&apos;/'/g;    # apostrophe
    $a =~ s/\&emsp;/  /g;   # em-space
    $a =~ s/\&male;/[male]/g;   # male
    $a =~ s/\&female;/[female]/g;   # female
    $a =~ s/\&Lambda;/[Lambda]/g;   # Greek capital letter lambda
    $a =~ s/\&Esmall;/e/g;  # small capital letter E (used as small letter)
    $a =~ s/\&ast;/*/g; # asterix

    $a =~ s/\&there4;/./g;  # Therefor (three dots in triangular arrangement) used as abbreviation dot.
    $a =~ s/\&maltese;/[+]/g;   # Maltese Cross

    # strip accents from remaining entities
    $a =~ s/\&([a-zA-Z])(breve|macr|acute|grave|uml|umlb|tilde|circ|cedil|dotb|dot|breveb|caron|comma|barb|circb|bowb|dota);/$1/g;
    $a =~ s/\&([a-zA-Z]{2})lig;/$1/g;
    $a =~ s/([0-9])\&frac([0-9])([0-9]*);/$1 $2\/$3/g;  # fraction preceded by number
    $a =~ s/\&frac([0-9])([0-9]*);/$1\/$2/g; # other fractions
    $a =~ s/\&frac([0-9])-([0-9]*);/$1\/$2/g; # other fractions
    $a =~ s/\&frac([0-9]+)-([0-9]*);/$1\/$2/g; # other fractions

    return $a;
}
