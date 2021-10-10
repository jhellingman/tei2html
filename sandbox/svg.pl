# Perl script to run the svg.xsl stylesheet with Saxon.

use strict;
use warnings;

my $javaOptions = '-Xms2048m -Xmx4096m -Xss1024k ';
my $java      = "java $javaOptions";
my $saxonHome = $ENV{'SAXON_HOME'};
my $saxon     = "$java -jar " . $saxonHome . "/saxon9he.jar ";  

system ("$saxon svg.xsl svg.xsl ");
