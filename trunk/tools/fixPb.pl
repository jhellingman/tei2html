# fixPb.pl -- fix (renumber) page breaks in TEI tagged files
#
# 1. sequence of numbers
# 2. average size of pages with large deviations


use Roman;			# Roman.pm version 1.1 by OZAWA Sakuro <ozawa@aisoft.co.jp>


$inputFile   = $ARGV[0];
$firstChange = $ARGV[1];
$offset      = $ARGV[2];
$useRoman	 = $ARGV[3];

$previousPage = 0;
$currentPage = 0;
$currentPageSize = 0;
$totalPageSize = 0;
$numberOfPages = 1;

$seenFirst = 0;

open(INPUTFILE, $inputFile) || die("Could not open $inputFile");

print STDERR "Verifying $inputFile\n";

while (<INPUTFILE>)
{
    my $line = $_;
    my $remainder = $line;
    while ($remainder =~ m/<pb(.*?)>/)
    {
		$before = $`;
		$pbAttrs = $1;
        $remainder = $';
        $currentPageSize += length $before;
        # print "NOTE: Page $currentPage contains $currentPageSize bytes.\n";
        $totalPageSize += $currentPageSize;
        $numberOfPages++;
        $currentPageSize = 0;
        $previousPage = $currentPage;
        $currentPage = getAttrVal("n", $pbAttrs);
		#$currentRend = getAttrVal("rend", $pbAttrs);
		# print "TEST: $currentPage";

		$cp = isroman($currentPage) ? arabic($currentPage) : $currentPage;
		$pp = isroman($previousPage) ? arabic($previousPage) : $previousPage;

		if (isnum($currentPage) && $cp == $firstChange) 
		{
			$seenFirst = 1;
		}

		if ($seenFirst && isnum($currentPage)) 
		{
			my $newCurrentPage = $currentPage + $offset;
			if ($useRoman eq "R") 
			{
				$newCurrentPage = uc(roman($newCurrentPage));
			}
			print "$before<pb n=$newCurrentPage id=pb$newCurrentPage>";
		}
		else
		{
			print "$before<pb$pbAttrs>";
		}
    }
    $currentPageSize += length $remainder;
	print $remainder;
}


sub isnum()
{
	$str = shift;
	return $str =~ /^[0-9]+$/;
}


# print STDERR "NOTE: Page $currentPage contains $currentPageSize bytes.\n";
# print STDERR "\n";
print STDERR "NOTE: Total number of pages: $numberOfPages\n";
print STDERR "NOTE: Total size of pages:   $totalPageSize\n";
$averagePageSize = $totalPageSize/$numberOfPages;
print STDERR "NOTE: Average size of page:  $averagePageSize\n";



#
# getAttrVal: Get an attribute value from a tag (if the attribute is present)
#
sub getAttrVal
{
	my $attrName = shift;
	my $attrs = shift;
	my $attrVal = "";

	if ($attrs =~ /$attrName\s*=\s*(\w+)/i)
	{
		$attrVal = $1;
	}
	elsif ($attrs =~ /$attrName\s*=\s*\"(.*?)\"/i)
	{
		$attrVal = $1;
	}
	return $attrVal;
}
