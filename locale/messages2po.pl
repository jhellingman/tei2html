use strict;
use warnings;

my $xsldir = ".";
my $saxon2 = "java.exe -jar tools\\lib\\saxon9he.jar ";

system ("$saxon2 messages.xml $xsldir/messages2po.xsl > messages.po");
system ("$saxon2 messages.xml $xsldir/messages2csv.xsl > messages.csv");
system ("$saxon2 messages.xml $xsldir/messages2messages.xsl > messages-with-missing.xml");