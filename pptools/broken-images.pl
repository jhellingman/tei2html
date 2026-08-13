#!/usr/bin/perl -w

#
# Test JPEG files in directories.
#

use v5.36;

use File::Basename;
use Image::Magick;

sub list_recursively($directory) {
    my @files = (  );

    opendir(my $dh, $directory) or die "Cannot open directory $directory: $!";
    @files = grep (!/^\.\.?$/, readdir($dh));
    closedir($dh);

    foreach my $file (@files) {
        if (-f "$directory\\$file") {
            handle_file("$directory\\$file");
        } elsif (-d "$directory\\$file") {
            list_recursively("$directory\\$file");
        }
    }
}


sub handle_file($file) {
    if ($file =~ m/^(.*)\.(jpg|png|gif)$/) {
        my $image = new Image::Magick;
        my $error = $image->Read($file);
        if ($error) {
            print "BROKEN $file\n";
        } else {
            print "OK     $file\n";
        }
    }
}


sub main() {
    my $file = $ARGV[0];

    if (!defined $file) {
        $file = ".";
    }
    if (-d $file) {
        list_recursively($file);
    } else {
        handle_file($file);
    }
}


main();
