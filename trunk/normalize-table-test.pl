# Perl script to test the the normalize-table.xsl stylesheet with Saxon.

use strict;

use FindBin qw($Bin);

my $toolsdir    = $Bin;
my $xsldir      = $toolsdir;
my $saxon       = "java -jar " . $toolsdir . "/tools/lib/saxon9he.jar ";
my $epubcheck   = "java -jar " . $toolsdir . "/tools/lib/epubcheck-3.0.1.jar ";

my $filename = $ARGV[0];

system ("$saxon $filename $xsldir/normalize-table.xsl");

