# Perl script to run the tei2imageinfo.xsl stylesheet with Saxon.

use strict;
use warnings;

use Cwd qw(abs_path);

my $home = $ENV{'TEI2HTML_HOME'};
my $saxonHome = $ENV{'SAXON_HOME'};

my $javaOptions = '-Xms2048m -Xmx4096m -Xss1024k ';
my $java      = "java $javaOptions";

my $xsldir    = abs_path($home); 
my $saxon     = "$java -jar " . $saxonHome . "/saxon9he.jar ";  

my $filename = $ARGV[0];
my $keyword = $ARGV[1];


my $pwd = `pwd`;
chop($pwd);
$pwd =~ s/\\/\//g;

my $imageFileParam = "imageInfoFile=\"file:/$pwd/imageinfo.xml\"";

system ("$saxon \"$filename\" $xsldir/tei2imageinfo.xsl $imageFileParam");
