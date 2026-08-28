#!/usr/bin/perl -w
# Perl script to run the tei2imageinfo.xsl stylesheet with Saxon.

use v5.36;

use Cwd qw(abs_path);

my $home = $ENV{'TEI2HTML_HOME'};
my $saxonHome = $ENV{'SAXON_HOME'};

my $javaOptions = '-Xms2048m -Xmx4096m -Xss1024k ';
my $java      = "java $javaOptions";

my $xslDir    = abs_path($home);
my $saxon     = "$java -jar " . $saxonHome . "/saxon9he.jar ";  

my $filename = $ARGV[0];

my $pwd = `pwd`;
chop($pwd);
$pwd =~ s/\\/\//g;

my $imageFileParam = "imageInfoFile=\"file:/$pwd/imageinfo.xml\"";

system ("$saxon \"$filename\" $xslDir/tei2imageinfo.xsl $imageFileParam");
