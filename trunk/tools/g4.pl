# g4.pl

$directory = $ARGV[0];

opendir(DIR,$directory);
@files = readdir(DIR);
close(DIR);

foreach $file (@files)
{
	if($file =~ /\.tif$/i) 
	{
		$infile = $file;
		system ("copy \"$file\" \"$file.bak\"");
		system ("copy \"$file\" tmp.tif");
		system ("tiffcp -c g4 tmp.tif \"$file\"");
	}
}