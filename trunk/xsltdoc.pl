
use strict;

my $xsldir = "C:\\Users\\Jeroen\\Documents\\eLibrary\\Tools\\tei2html";
my $saxon = "\"C:\\Program Files\\Java\\jre6\\bin\\java.exe\" -jar C:\\bin\\saxonhe9\\saxon9he.jar ";
my $xsltdoc = "..\\XSLTdoc_1.2.2\\xsl\\xsltdoc.xsl";

system ("$saxon xsltdoc.config $xsltdoc");

