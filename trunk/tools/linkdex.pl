# linkdex.pl -- Link index entries to their corresponding words in a TEI file.
#
# Usage: lindex.pl [-v] document.tei
#
#    -v: print verbose output.
#
# 1. Search for index (between <!-- INDEX START --> and <!-- INDEX END -->
# 2. Read index, each entry having format "<p>Word, Location, Location"
# 3. Read text
# 4. For each entry, look it up on the page where it should occur.
# 5. Add tagging to word if found.
# 6. Dump text with added tags.


main();


sub main()
{
    %indexHash = ();
    $verbose = 0;

    my $infile = $ARGV[0];
    if ($infile eq "-v")
    {
        $verbose = 1;
        $infile = $ARGV[1];
    }

    readDocument($infile);
    readIndex($infile);
    verifyIndex();

    $infile =~ /^([A-Za-z0-9-]*?)(-([0-9]+\.[0-9]+))?\.tei$/;
    saveDocument($1 . "-ix.tei");
}


#
# saveDocument: save the modified document to a file.
#
sub saveDocument($)
{
    my $outfile = shift;

    open(OUTPUTFILE, ">$outfile") || die("Could not open output file $outfile");
    print OUTPUTFILE $document;
    close OUTPUTFILE;
}


#
# readIndex: locate the index in the document
#
sub readIndex($)
{
    my $infile = shift;

    open(INPUTFILE, $infile) || die("Could not open input file $infile");

    while (<INPUTFILE>)
    {
        if ($_ =~ /<!-- INDEX START -->/)
        {
            readIndexLines()
        }
    }

    close(INPUTFILE);
}


#
# readIndexLines: read lines from the index, and add them to the global %indexHash hash-table.
#
sub readIndexLines()
{
    while (<INPUTFILE>)
    {
        if ($_ =~ /<!-- INDEX END -->/)
        {
            return;
        }

        if ($_ =~ /^(?:<p>|<item>)(.*?), /)
        {
            my $word = $1;
            my $locations = $';
            $indexHash{$word} = $locations;
        }
    }
}


#
# verifyIndex: verify the entries of the index can be located on the correct page in the document
#
sub verifyIndex()
{
    my @indexWords = keys %indexHash;
    foreach my $word (@indexWords)
    {
        my $locations = $indexHash{$word};

        $verbose and print "Checking entry $word\n";

        chomp $locations;
        my @locationList = split(/, */, $locations);

        foreach my $location (@locationList)
        {
            locateWord($word, $location);
        }
    }
}


#
# locateWord: locate (and tag) matching words on the indicated location in the document.
#
sub locateWord($$)
{
    my $word = shift;
    my $location = shift;

    if ($location =~ /(.*)\.$/)
    {
        $location = $1;
    }
    if ($location =~ /(.*) (noot|note)\.?$/)
    {
        $location = $1;
    }

    if ($location !~ /^([IVXLCDM]+|[0-9]+$)/i)
    {
        $verbose and print "  ";
        print "Location \"$location\" ignored (entry \"$word\")\n";
        return;
    }

    if ($document =~ /(<pb\b[^>]+?\bn=\"?${location}\b\"?[^>]*?>)(.*?)<pb/s)
    {
        my $pbtag = $1;
        my $text = $2;
        # print "TEXT: $text\n";
        $verbose and print "  Checking page $location\n";

        if ($text =~ /\b${word}\b/si)
        {
            $verbose and print "    \"$word\" found\n";
            tagWords($word, $text);
        }
        else
        {
            $verbose and print "    ";
            print "Page $location: \"$word\" not found\n";
        }
    }
    else
    {
        $verbose and print "  ";
        print "Page $location: page not found";
        (!$verbose) and print " (entry \"$word\")";
        print "\n";
    }
}


#
# tagWords: tag words in text, and replace the text in the document.
#
sub tagWords($$)
{
    my $word = shift;
    my $text = shift;

    my $oldtext = $text;
    $text =~ s/\b(${word})\b/<ix>\1<\/ix>/gsi;
    $document = str_replace("$pbtag$oldtext", "$pbtag$text", $document);
}


#
# readDocument: read the document to be updated into a global.
#
sub readDocument($)
{
    my $infile = shift;

    open(INPUTFILE, $infile) || die("Could not open input file $infile");

    $document = "";
    while (<INPUTFILE>)
    {
        $document .= $_;
    }
    close(INPUTFILE);
}


#
# str_replace: replace a string without using regular expressions
#
sub str_replace($$$)
{
    my $a = shift;
    my $b  = shift;
    my $string = shift;

    my $i = index ($string, $a);
    if ($i != -1)
    {
        $string = substr($string, 0, $i) . $b . substr($string, $i + length($a));
    }
    return $string;
}

