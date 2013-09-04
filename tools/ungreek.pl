# ungreek.pl -- replace Greek with Greek in Latin transcription in a file.

use strict;

use File::stat;
use File::Temp qw(mktemp);

my $toolsdir        = "C:\\Users\\Jeroen\\Documents\\eLibrary\\Tools\\tei2html\\tools";   # location of tools
my $patcdir         = $toolsdir . "\\patc\\transcriptions"; # location of patc transcription files.

my $infile = $ARGV[0];

$infile =~ /^([A-Za-z0-9-]*?)(-([0-9]+\.[0-9]+))?\.(tei|xml)$/;
my $basename = $1;
my $version = $2;
my $extension = $4;

my $outfile = $basename . "-ungreek" . $version . "." . $extension;

system ("patc -p $patcdir/greek/ungreek8.pat $infile $outfile");
