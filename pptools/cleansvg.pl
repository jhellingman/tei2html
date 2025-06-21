#!/usr/bin/perl
use strict;
use warnings;
use File::Copy;

my $saxonHome = $ENV{'SAXON_HOME'};
my $javaOptions = '-Xms2048m -Xmx4096m -Xss1024k ';

my $java      = "java $javaOptions";
my $saxon     = "$java -jar " . $saxonHome . "/saxon9he.jar ";

# XSLT file (adjust if needed)
my $xslt_file = 'cleansvg.xsl';

# Check if the XSLT file exists
die "XSLT file '$xslt_file' not found\n" unless -e $xslt_file;

# Process each .svg file in the current directory
foreach my $svg_file (glob("*.svg")) {
    my $backup_file = "$svg_file.bak";
    my $temp_output = "$svg_file.tmp";

    print "Processing $svg_file -> (backup: $backup_file)\n";

    # Run the transformation
    my $cmd = "$saxon -s:$svg_file -xsl:$xslt_file -o:$temp_output";
    system($cmd) == 0 or do {
        warn "Failed to process $svg_file: $!\n";
        next;
    };

    # Rename original to .bak
    move($svg_file, $backup_file) or do {
        warn "Failed to backup $svg_file to $backup_file: $!\n";
        next;
    };

    # Move cleaned output to original name
    move($temp_output, $svg_file) or do {
        warn "Failed to write cleaned file to $svg_file: $!\n";
        # Restore from backup in case of error
        move($backup_file, $svg_file);
    };
}
