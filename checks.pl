# Perl script to test the checks.xsl stylesheet with Saxon.

use strict;
use warnings;

my $xsldir = "C:\\Users\\Jeroen\\Documents\\eLibrary\\Tools\\tei2html";  # location of xsl stylesheets
my $saxon = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\saxonhe9\\saxon9he.jar ";

my $filename = $ARGV[0];

$filename =~ /^(.*)\.xml$/;
my $basename = $1;
my $newname = $basename . "-pos.xml";

system ("perl -S addPositionInfo.pl \"$filename\" > \"$newname\"");
system ("$saxon \"$newname\" $xsldir/checks.xsl");
