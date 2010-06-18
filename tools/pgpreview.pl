# pgpreview.pl -- Create simple HTML preview of proofed pages.

use strict;

use SgmlSupport qw/sgml2utf utf2sgml pgdp2sgml/;


main();


sub main()
{
    my $file = $ARGV[0];
    my $useExtensions = 0;

    if ($file eq "-x") 
    {
        $useExtensions = 1;
        $file = $ARGV[1];
        print STDERR "USING EXTENSIONS FOR FRANCK!\n";
    }

    open(INPUTFILE, $file) || die("Could not open input file $file");

    printHtmlHead();

    my $paragraph = "";

    while (<INPUTFILE>)
    {
        my $line = $_;

        if ($_ =~ /-*File: ([0-9]+)\.png-*\\([^\\]*)(\\([^\\]+))?(\\([^\\]+))?(\\([^\\]+))?\\.*$/) 
        {
            print "\n\n<p>" . handleParagraph($paragraph, $useExtensions);
            print "<hr>\n<b>File: $1.png</b>\n<hr>\n";
            $paragraph = "";
        }
        elsif ($line ne "\n") 
        {
            chomp($line);
            $paragraph .= " " . $line;
        }
        else
        {
            if ($paragraph ne "") 
            {
                print "\n\n<p>" . handleParagraph($paragraph, $useExtensions);
            }
            $paragraph = "";
        }
    }

    if ($paragraph ne "") 
    {
        print "\n\n<p>" . handleParagraph($paragraph, $useExtensions);
    }

    printHtmlTail();

    close INPUTFILE;
}


sub handleParagraph($$)
{
    my $paragraph = shift;
    my $useExtensions = shift;

    $paragraph = pgdp2sgml($paragraph, $useExtensions);

    # Replace dashes in number ranges by en-dashes
    $paragraph =~ s/([0-9])-([0-9])/\1\&ndash;\2/g;

    # Replace two dashes by em-dashes
    $paragraph =~ s/ *---? */\&mdash;/g;

    $paragraph = sgml2utf($paragraph);

    # Tag proofer remarks:
    $paragraph =~ s/(\[\*.*?\])/<span class=remark>\1<\/span>/g;

    # Tag Greek sections (original)
    $paragraph =~ s/(\[GR:.*?\])/<span class=greek>\1<\/span>/g;

    # Tag Greek sections (WRONG!!!)
    $paragraph =~ s/(\[Greek:?.*?\])/<span class=error>\1<\/span>/g;

    # Tag Greek sections (WRONG!!!)
    $paragraph =~ s/(\[G[Rr].*?\])/<span class=error>\1<\/span>/g;

    # Tag Greek sections (after processing)
    $paragraph =~ s/<foreign lang=el>(.*?)<\/foreign>/<span class=greek>\1<\/span>/g;

    # Replace illustration markup:
    $paragraph =~ s/\[Ill?ustration:? (.*)\]/<span class=figure>\n[Illustration: \1\n<\/span>/g;

    # Replace footnote indicators:
    $paragraph =~ s/\[([0-9]+)\]/<sup>\1<\/sup>/g;

    # Replace superscripts
    $paragraph =~ s/\^\{(.*?)\}/<sup>\1<\/sup>/g;
    $paragraph =~ s/\^([a-zA-Z0-9\*])/<sup>\1<\/sup>/g;

    # Replace subscripts
    $paragraph =~ s/_\{(.*?)\}/<sub>\1<\/sub>/g;
    $paragraph =~ s/_([a-zA-Z0-9\*])/<sub>\1<\/sub>/g;

    # Replace other formatting
    $paragraph =~ s/<sc>(.*?)<\/sc>/<span class=sc>\1<\/span>/g;
    $paragraph =~ s/<g>(.*?)<\/g>/<span class=ex>\1<\/span>/g;

    $paragraph =~ s/<tb>/<hr>/g;

    # Anything else between braces is probably wrong:
    $paragraph =~ s/(\^?\{.*?\})/<span class=error>\1<\/span>/g;

    # Remaining non-numeric entities are wrong
    $paragraph =~ s/(\&[^0-9]*?;)/<span class=error>\1<\/span>/g;

    # Remaining short things between brackets are probably wrong
    $paragraph =~ s/(\[[^\]]{0,4}\])/<span class=error>\1<\/span>/g;


    $paragraph = utf2sgml($paragraph);

    # Trim superflous spaces
    $paragraph =~ s/[\t ]+/ /g;
    $paragraph =~ s/^ +//;
    $paragraph =~ s/ +$//;

    # Remove TEI <corr> tags that might drop through.
    $paragraph =~ s/<\/?corr(.*?)>/ /g;

    return $paragraph;
}



sub printHtmlHead()
{
    print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">";
    print "<html>\n";
    print "<title>DP Preview</title>\n";
    print "<style type='text/css'>\n";
    print ".figure { background-color: #FFFF5C; }\n";
    print ".remark { background-color: #FFB442; }\n";
    print ".greek { background-color: #C7FFC7; font-family: Asteria, Palatino Linotype, sans serif; font-size: 16pt;}\n";
    print ".sc { font-variant:small-caps; }\n";
    print ".ex { letter-spacing:0.2em; background-color: #FFFF80; }\n";
    print ".error { background-color: #FF8566; font-weight: bold; }\n";
    print ".xref { background-color: #FFFF8C; }\n";
    print "</style>\n";
    print "</head>\n";
    print "<body>\n";
}


sub printHtmlTail()
{
    print "</body></html>";
}

