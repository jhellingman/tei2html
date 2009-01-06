


while (<>) 
{
	chomp $_;
	$_ =~ /([0-9]+) +([0-9]+) +(.*?) +(.*)/;

	$wcount = $1;
	$dcount = $2;
	$oldword = $3;
	$newword = $4;

	if ($oldword ne $newword) 
	{
		print "$wcount\t$dcount\t$oldword\t$newword\n";
	}
}