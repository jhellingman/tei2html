use strict;

use File::Temp qw(mktemp);


my $xsldir  = "C:\\Users\\Jeroen\\Documents\\eLibrary\\Tools\\tei2html";  # location of xsl stylesheets
my $saxon	= "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\saxonhe9\\saxon9he.jar "; # (see http://saxon.sourceforge.net/)

my $filename = $ARGV[0];

my $tmpFile1 = mktemp('tmp-XXXXX');
my $tmpFile2 = mktemp('tmp-XXXXX');

system ("tidy -asxhtml -clean --doctype omit \"$filename\" > $tmpFile1");
system ("sed \"s/\\&/|xxxx|/g\" < $tmpFile1 > $tmpFile2");
system ("$saxon $tmpFile2 \"$xsldir\\html2tei.xsl\" > $tmpFile1");
system ("sed \"s/|xxxx|/\\&/g\" < $tmpFile1 > out.tei");

unlink($tmpFile2);
unlink($tmpFile1);
