
# use strict;
# use warnings;

use utf8;
binmode(STDOUT, ":utf8");
use open ':utf8';

require Encode;
use Unicode::Normalize;

use Lingua::Identify qw/langof/;

use SgmlSupport qw/getAttrVal sgml2utf/;
use LanguageNames qw/getLanguage/;


$accLetter = "(\\&[A-Za-z](acute|grave|circ|uml|cedil|tilde|slash|ring|dotb|macr|breve);)";
$ligLetter = "(\\&[A-Za-z]{2}lig;)";
$specLetter = "(\\&apos;|\\&eth;|\\&ETH;|\\&thorn;|\\&THORN;|\\&alif;|\\&ayn;|\\&prime;)";
$letter = "(\\w|$accLetter|$ligLetter|$specLetter)";
$wordPattern = "($letter)+(([-']|&rsquo;|&apos;)($letter)+)*";
$nonLetter = "\\&(amp|ldquo|rdquo|lsquo|mdash|hellips|gt|lt|frac[0-9][0-9]);";


%wordHash = ();
%wordFiles = ();
%dictHash = ();
%scannoHash = ();
%pairHash = ();

$inputDir		= $ARGV[0];

$totalPairCount = 0;

print STDERR "Loading dictionary\n";

load_dictionary();

print STDERR "Collecting words from directory $inputDir\n";

list_recursively($inputDir);

report_pairs();

print STDERR "$totalPairCount pairs in total\n";
print STDERR "$scannoPairCount scanno pairs\n";

exit;



# list_recursively
#
#   list the contents of a directory,
#   recursively listing the contents of any subdirectories

sub list_recursively 
{
    my ($directory) = @_;
    my @files = (  );
    
    unless (opendir(DIRECTORY, $directory)) 
	{
        print "Cannot open directory $directory!\n";
        exit;
    }
    
    @files = grep (!/^\.\.?$/, readdir(DIRECTORY));
    
    closedir(DIRECTORY);
    
    foreach my $file (@files) 
	{
        if (-f "$directory/$file") 
		{
			if ($file =~ /\.html?$/) 
			{
				handle_file("$directory/$file");
			}
        
        }
		elsif (-d "$directory/$file") 
		{
            list_recursively("$directory/$file");
        }
    }
}


#
# handle_file
#
sub handle_file
{
	my $infile = shift;
	open (INPUTFILE, $infile) || die("Could not open input file $infile");
    binmode(INPUTFILE, ":encoding(latin-1)");

	$pairCount = 0;

	my $language = "nl";
	my $prevWord = "";
	while (<INPUTFILE>)
	{
		my $line = $_;
		$line =~ s/<(.*?)>/ /g;	# Drop SGML/HTML tags
		$line =~ s/\s+/ /g;		# normalize space
		$line =~ s/^\s+//;
		$line =~ s/\s+$//;

		$line = sgml2utf($line);

		# Establish language.
		if (length($line) > 100)
		{
			my ($l, $p) = langof($line);
			if ($l && $p > 0.15) 
			{
				$language = $l;
			}
		}

		# We are interested in what is likely Dutch.
		if ($language eq "nl" || $language eq "af") 
		{
			# NOTE: we don't use \w and \W here, since it gives some unexpected results
			my @words = split(/([^\pL\pN\pM-]+)/, $line);

			foreach $word (@words)
			{
				if ($word =~ /[^\pL\pN\pM-]+/) 
				{
					# reset previous word if not separated by space(s).
					if ($word !~ /^[\pZ]+$/) 
					{
						$prevWord = "";
					}
				}
				else
				{
					countPair($prevWord, $word);
					$prevWord = $word;
				}
			}
		}
	}
	close INPUTFILE;

	print STDERR "$pairCount\t$infile\n";
}


#
# countPair
#
sub countPair
{
	my $firstWord = shift;
	my $secondWord = shift;

	$pairCount++;
	$totalPairCount++;

	if ((exists $dictHash{$firstWord} && exists $scannoHash{$secondWord}) ||
	 	(exists $scannoHash{$firstWord} && exists $dictHash{$secondWord})) 
	# if (exists $dictHash{$firstWord} && exists $dictHash{$secondWord})
	{
		$scannoPairCount++;

		$pairHash{"$firstWord $secondWord"}++;
	}
}


#
# report_pairs
#
sub report_pairs
{
	my @pairList = keys %pairHash;

	@pairList = sort @pairList;
	foreach my $pair (@pairList)
	{
		my $count = $pairHash{$pair};
		print "$pair\t$count\n";
	}
}


#
# load_dictionary: load required dictionaries.
#
sub load_dictionary
{
	my $dictFile = "C:\\bin\\dic\\nl_NL_1900_full.txt";
	if (!open(DICTFILE, "<:encoding(latin1)", $dictFile))
	{
			print STDERR "Could not open $dictFile";
			exit;
	}

	%dictHash = ();
	while (<DICTFILE>)
	{
		my $word =  $_;
		$word =~ s/\n//g;
		$dictHash{$word} = "$word";
	}
	close(DICTFILE);


	my $scannoFile = "scanno-list.txt";
	if (!open(DICTFILE, "<:encoding(latin1)", $scannoFile))
	{
			print STDERR "Could not open $scannoFile";
			exit;
	}

	%scannoHash = ();
	while (<DICTFILE>)
	{
		my $word =  $_;
		$word =~ s/\n//g;
		$scannoHash{$word} = "$word";		
		
	}
	close(DICTFILE);
}

