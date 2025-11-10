# Perl script to run the xml2kwic.xsl stylesheet with Saxon.

use strict;
use warnings;

my $xsldir = "C:\\Users\\Jeroen\\Documents\\eLibrary\\Tools\\tei2html";  # location of xsl stylesheets
my $saxon = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\saxonhe9\\saxon9he.jar ";

my $filename = $ARGV[0];
my $keyword = $ARGV[1];

my $keywordArgument = $keyword eq '' ? '' : "keyword=\"$keyword\"";

system ("$saxon \"$filename\" $xsldir/xml2kwic.xsl $keywordArgument");
