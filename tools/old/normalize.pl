# tei2xml.pl -- process a TEI file.

$toolsdir	= "L:\\eLibrary\\tools\\tei2html\\tools";	# location of tools
$patcdir    = "L:\\eLibrary\\tools\\tei2html\\tools\\patc\\transcriptions";	# location of patc transcription files.
$xsldir		= "L:\\eLibrary\\tools\\tei2html";	# location of xsl stylesheets
$tmpdir		= "C:\\Temp";						# place to drop temporary files
$catalog	= "C:\\Bin\\pubtext\\CATALOG";		# location of SGML catalog (required for nsgmls and sx)

#==============================================================================

$filename = $ARGV[0];

if ($filename eq "")
{
    my ($directory) = ".";
    my @files = ( );
    opendir(DIRECTORY, $directory) or die "Cannot open directory $directory!\n";
    @files = readdir(DIRECTORY);
    closedir(DIRECTORY);

    foreach my $file (@files) 
	{
		if ($file =~ /^([A-Za-z0-9-]*?)(-([0-9]+\.[0-9]+))?\.tei$/)
		{
			processFile($file);
			exit;
		}
	}
}
else
{
	processFile($filename);
}


sub processFile
{
	my $filename = shift;

	if ($filename eq "" || $filename !~ /\.html?$/) 
	{
		die "File: '$filename' is not a .HTML file\n";
	}

	print "Create text version...\n";
	system ("perl $toolsdir/normalizeText.pl $filename > tmp.1");
	system ("perl $toolsdir/catpars.pl tmp.1 > tmp.2");
	system ("perl $toolsdir/tei2txt.pl tmp.2 > tmp.3");
	system ("fmt -sw72 tmp.3 > out.txt");

	print "Clean up...";
	system ("rm tmp.?");
	print "Done!\n";
}
