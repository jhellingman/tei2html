use strict;

my $xsldir = "C:\\Users\\Jeroen\\Documents\\eLibrary\\Tools\\tei2html";  # location of xsl stylesheets
my $saxon2 = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\saxonhe9\\saxon9he.jar ";

system ("$saxon2 messages.xml $xsldir/messages2po.xsl > messages.po");
