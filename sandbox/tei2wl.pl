# Perl script to test the the tei2wl.xsl stylesheet with Saxon.

use strict;
use warnings;

my $xsldir = "C:\\Users\\Jeroen\\Documents\\eLibrary\\Tools\\tei2html";  # location of xsl stylesheets
my $saxon = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\saxonhe9\\saxon9he.jar ";

my $filename = $ARGV[0];

system ("$saxon $filename $xsldir/tei2wl.xsl");

