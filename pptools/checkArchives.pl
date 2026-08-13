#!/usr/bin/perl -w

#
# Check the consistency of archive files.
#

use v5.36;

use File::Basename;
use File::Temp;

my $sevenZip = "\"C:\\Program Files\\7-Zip\\7z\"";

my $logFile = "checkArchives.log";

main();

sub main() {
    ## initial call ... $ARGV[0] is the first command line argument
    list_recursively($ARGV[0]);
}

sub list_recursively($directory) {
    my @files = (  );

    opendir(my $dh, $directory) or die "Cannot open directory $directory: $!";
    @files = grep (!/^\.\.?$/, readdir($dh));
    closedir($dh);

    foreach my $file (@files) {
        if (-f "$directory/$file") {
            handle_file("$directory/$file");
        } elsif (-d "$directory/$file") {
            list_recursively("$directory/$file");
        }
    }
}


sub handle_file($file) {
    if ($file =~ m/^(.*)\.(7z|zip)$/) {
        system ("$sevenZip t -bb0 \"$file\" 1>>$logFile");
    }
}
