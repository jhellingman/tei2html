# extractNotes.pl -- extract notes from TEI tagged files
#
# Extract occurances of footnotes in TEI tagged files to a separate foot-note file, with links back to the
# original note locations. In TEI, the following tags are relevant:
#
#   <pb n="23">             page breaks, more may occur in a single line
#   <note n="2">...</note>      actually notes, may cover more than one line
#
# Which should be translated to
#
#   <a name="n23.2" href="notes.html#n23.2"><sup>2</sup></a>
#
# in the source file and
#
#   <p><a name="n23.2" href="text.html#n23.2>Page 23 note 2:</a>
#     <p>...
#
# in the notes file.
#
# Notes in the TEI header should be ignored. (TODO)
# This code depends on valid TEI.

use strict;

my $inputFile = $ARGV[0];
my $outputFile = $inputFile . ".out";
my $notesFile = $inputFile . ".notes";

# The names of the ultimate converted HTML files are required
# to create the correct HREFs.

my $htmlBase = $ARGV[1];
my $notesHtml = $htmlBase . "-notes.html";
my $outputHtml = $htmlBase . ".html";

my $noteNumber = 0;
my $seqNumber = 0;
my $pageNumber = 0;


open(INPUTFILE, $inputFile) || die("Could not open $inputFile");
open(OUTPUTFILE, "> $outputFile") || die("Could not open $outputFile");
open(NOTESFILE, "> $notesFile") || die("Could not open $notesFile");

print NOTESFILE "\n\nNOTES\n\n";


my $prevPageNumber = "";
while (<INPUTFILE>)
{
    my $line = $_;
    my $remainder = $line;

    # Skip over the TeiHeader;
    if ($remainder =~ m/<(teiHeader\b.*?)>/)
    {
        while ($remainder !~ m/<\/teiHeader>/)
        {
            $remainder = <INPUTFILE>;
        }
    }

    while ($remainder =~ m/<(note\b.*?)>/)
    {
        my $beforeNote = $`;
        my $attributes = $1;
        $remainder = $';
        my $noteText = '';

        $noteNumber = getAttrVal("n", $attributes);
        my $notePlace = getAttrVal("place", $attributes);

        if ($notePlace eq "")
        {
            # print "WARNING: note without place indication\n";
        }

        print OUTPUTFILE $beforeNote;

        # match the last <pb> tag before the note
        if ($beforeNote =~ /.*<(pb\b.*?)>/)
        {
            my $tag = $1;
            $pageNumber = getAttrVal("n", $tag);
            # print "[$pageNumber]\n";
        }

        # Find the end of the note
        my $nestingLevel = 0;
        my $endFound = 0;
        while ($endFound == 0)
        {
            if ($remainder =~ m/<(\/?note)\b(.*?)>/)
            {
                my $beforeTag = $`;
                my $noteTag = $1;
                $remainder = $';

                # print "DEBUG: $noteTag\n";
                if ($noteTag eq "note")
                {
                    $nestingLevel++;
                    $noteText .= $beforeTag . " ((";
                    print "WARNING: Nested notes on page $pageNumber rendered in-line (check for '((')\n";
                }
                elsif ($noteTag eq "\/note")
                {
                    # print "DEBUG: end found: $nestingLevel\n";
                    if ($nestingLevel == 0)
                    {
                        $endFound = 1;
                        $noteText .= $beforeTag;
                    }
                    else
                    {
                        $nestingLevel--;
                        $noteText .= $beforeTag . ")) ";
                    }
                }
            }
            else
            {
                # Get the next line
                $remainder .= <INPUTFILE>;
            }
        }

        if ($noteText =~ /^\W*$/)
        {
            print "WARNING: (almost) empty note '$noteText' on page $pageNumber (n=$noteNumber)\n";
        }

        if ($notePlace ne "margin")
        {
            $seqNumber++;
            print OUTPUTFILE " [$seqNumber]";
            print NOTESFILE "[$seqNumber] $noteText\n\n"
        }
        else
        {
            print OUTPUTFILE "[$noteText] ";
        }
    }

    # match the last <pb> tag after the note (or on the line if there is no note).
    if ($remainder =~ /.*<(pb.*?)>/)
    {
        my $tag = $1;
        $pageNumber = getAttrVal("n", $tag);
        # print "[$pageNumber]\n";
    }

    print OUTPUTFILE $remainder;
}

# print "NOTE: this document contains $seqNumber notes and $pageNumber pages.\n"



# Get an attribute value (if the attribute is present)
sub getAttrVal($$)
{
    my $attrName = shift;
    my $attrs = shift;
    my $attrVal = "";

    if($attrs =~ /$attrName\s*=\s*(\w+)/i)
    {
        $attrVal = $1;
    }
    elsif($attrs =~ /$attrName\s*=\s*\"(.*?)\"/i)
    {
        $attrVal = $1;
    }
    return $attrVal;
}
