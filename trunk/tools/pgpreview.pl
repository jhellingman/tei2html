# pgpreview.pl -- Create simple HTML preview of proofed pages.

use SgmlSupport qw/sgml2utf utf2sgml/;



main();




sub main
{
	my $file = $ARGV[0];

	open(INPUTFILE, $file) || die("Could not open input file $file");

	printHtmlHead();

	my $paragraph = "";

	while (<INPUTFILE>)
	{
		my $line = $_;

		if ($_ =~ /-*File: ([0-9]+)\.png-*\\([^\\]*)(\\([^\\]+))?(\\([^\\]+))?(\\([^\\]+))?\\.*$/) 
		{
			print "\n\n<p>" . handleParagraph($paragraph);
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
			print "\n\n<p>" . handleParagraph($paragraph);
			$paragraph = "";
		}
	}

	printHtmlTail();
}


sub handleParagraph
{
	my $paragraph = shift;

	$paragraph = pgdp2sgml($paragraph);
	$paragraph = utf2sgml(sgml2utf($paragraph));

	# Tag proofer remarks:
	$paragraph =~ s/(\[\*.*?\])/<span class=remark>\1<\/span>/g;

	# Tag Greek sections (original)
	$paragraph =~ s/(\[GR:.*?\])/<span class=greek>\1<\/span>/g;

	# Tag Greek sections (WRONG!!!)
	$paragraph =~ s/(\[Greek:?.*?\])/<span class=error>\1<\/span>/g;

	# Tag Greek sections (WRONG!!!)
	$paragraph =~ s/(\[GR.*?\])/<span class=error>\1<\/span>/g;

	# Tag Greek sections (after processing)
	$paragraph =~ s/<foreign lang=el>(.*?)<\/foreign>/<span class=greek>\1<\/span>/g;

	# Replace illustration markup:
	$paragraph =~ s/\[Ill?ustration:? (.*)\]/<span class=figure>\n[Illustration: \1\n<\/span>/g;

	# Replace dashes in number ranges by en-dashes
	$paragraph =~ s/([0-9])-([0-9])/\1\&ndash;\2/g;

	# Replace two dashes by em-dashes
	$paragraph =~ s/ *---? */\&mdash;/g;

	# Replace footnote indicators:
	$paragraph =~ s/\[([0-9]+)\]/<sup>\1<\/sup>/g;

	# Replace superscripts
	$paragraph =~ s/\^\{([a-zA-Z0-9]+)\}/<hi rend=sup>\1<\/hi>/g;
	$paragraph =~ s/\^([a-zA-Z0-9])/<hi rend=sup>\1<\/hi>/g;

	return $paragraph;
}


#
# Handle special letters in the coding system as used on PGDP.
#
sub pgdp2sgml
{
	my $string = shift;

	$string =~ s/\[~([a-zA-Z])\]/\&\1tilde;/g;			# tilde
	$string =~ s/\[=([a-zA-Z])\]/\&\1macr;/g;			# macron
	$string =~ s/\[\)([a-zA-Z])\]/\&\1breve;/g;			# breve
	$string =~ s/\[\.([a-zA-Z])\]/\&\1dot;/g;			# dot above
	$string =~ s/\[[>v]([a-zA-Z])\]/\&\1caron;/g;		# caron / hajek

	$string =~ s/\[([a-zA-Z])\.\]/\&\1dotb;/g;			# dot below
	$string =~ s/\[([a-zA-Z]),\]/\&\1cedil;/g;			# cedilla

	# various odd letters: (As used in Franck's Etymologisch Woordenboek)
	$string =~ s/\[ng]/\&eng;/g;						# eng
	$string =~ s/\[NG]/\&ENG;/g;						# ENG
	$string =~ s/\[zh]/\&ezh;/g;						# ezh
	$string =~ s/\[ZH]/\&EZH;/g;						# EZH
	$string =~ s/\[sh]/\&esh;/g;						# esh
	$string =~ s/\[SH]/\&ESH;/g;						# ESH

	$string =~ s/\[x]/\&khgr;/g;						# Greek chi in Latin context

	return $string;
}


sub printHtmlHead
{
	print "<html>\n";
	print "<title>DP Preview</title>\n";
	print "<style>\n";
	print ".figure { background-color: #FFFF5C; }\n";
	print ".remark { background-color: #FFB442; }\n";
	print ".greek { background-color: #C7FFC7; font-family: Asteria, Palatino Linotype, sans serif; font-size: 16pt;}\n";
	print ".error { background-color: #FF8566; font-weight: bold; }\n";
	print "</style>\n";
	print "</head>\n";
	print "<body>\n";

}


sub printHtmlTail
{
	print "</body></html>";
}

