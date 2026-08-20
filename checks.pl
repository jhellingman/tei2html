#!/usr/bin/perl -w

# Perl script to test the checks.xsl stylesheet with Saxon.

use v5.36;

my $home = $ENV{'TEI2HTML_HOME'};
my $saxonHome = $ENV{'SAXON_HOME'};

my $isWindows = ($^O eq 'MSWin32');
my $isLinux = ($^O eq 'linux');

my $xsldir      = abs_path($home);
my $javaOptions = '-Xms2048m -Xmx4096m -Xss1024k ';
my $java        = "java $javaOptions";
my $saxon       = $isWindows || $isLinux
                  ? "$java -jar " . $saxonHome . '/saxon9he.jar '
                  : 'saxon ';

my $fileName = $ARGV[0];

$fileName =~ /^(.*)\.xml$/;
my $baseName = $1;
my $newName = $baseName . "-pos.xml";

system ("perl -S addPositionInfo.pl \"$fileName\" > \"$newName\"");
system ("$saxon \"$newName\" $xsldir/checks.xsl");
