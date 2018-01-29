use strict;

my $xsldir = ".";
my $saxon2 = "java.exe -jar tools\\lib\\saxon9he.jar ";

system ("$saxon2 messages.xml $xsldir/messages2po.xsl > messages.po");
system ("$saxon2 messages.xml $xsldir/messages2csv.xsl > messages.csv");
