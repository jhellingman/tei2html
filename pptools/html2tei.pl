# Perl script to test the the html2tei.xsl stylesheet with Saxon.

use strict;
use warnings;
use File::Temp qw(mktemp);
use FindBin qw($Bin);

my $toolsdir    = $Bin;
my $xsldir      = $toolsdir;
my $saxon       = "java -jar " . $toolsdir . "/lib/saxon9he.jar ";

my $filename = $ARGV[0];

my $tmpFile1 = mktemp('tmp-XXXXX');
my $tmpFile2 = mktemp('tmp-XXXXX');

system ("tidy -asxhtml -clean --doctype omit \"$filename\" > $tmpFile1");
system ("sed \"s/\\&/|xxxx|/g\" < $tmpFile1 > $tmpFile2");
system ("$saxon $tmpFile2 \"$xsldir/../sandbox/html2tei.xsl\" > $tmpFile1");
system ("sed \"s/|xxxx|/\\&/g\" < $tmpFile1 > out.xml");

unlink($tmpFile2);
unlink($tmpFile1);
