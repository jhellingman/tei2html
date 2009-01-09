


while (<>) 
{
	chomp $_;
	$_ =~ /([0-9]+)\s+([0-9]+)\s+(.*?)\s+(.*)/;

	$wcount = $1;
	$dcount = $2;
	$oldword = $3;
	$newword = $4;

	if ($oldword ne $newword) 
	{
		print "$oldword\t$newword\n";
	}
}