#!/usr/bin/perl -w

#
# Optimize various types of images.
#

use strict;

use File::Basename;
use File::Copy;
use File::stat;
use Time::localtime;
use Getopt::Long;

my $pngout = "pngout.exe";              # see http://advsys.net/ken/util/pngout.htm 
my $optipng = "optipng.exe";            # also https://pngquant.org/ and http://optipng.sourceforge.net/
my $jpegoptim = "jpegoptim.exe";        # see http://freshmeat.net/projects/jpegoptim/; http://pornel.net/jpegoptim
my $jpegtran = "jpegtran.exe";          # http://www.kokkonen.net/tjko/projects.html https://github.com/mozilla/mozjpeg
my $zopflipng = "zopflipng.exe";        # https://github.com/imagemin/zopflipng-bin/tree/master/vendor
my $gifsicle = "gifsicle.exe";          # see http://www.lcdf.org/gifsicle/   (WARNING: might corrupt some images!)

# For benchmarks see: https://css-ig.net/png-tools-overview#overview
# https://github.com/fhanau/Efficient-Compression-Tool

my $temp = "C:\\Temp";

my $errorCount = 0;
my $totalOriginalSize = 0;
my $totalResultSize = 0;
my $imagesConverted = 0;

my $verbose = 0;
my $help = 0;
my $maxAgeHours = 24;

GetOptions(
    'v' => \$verbose,
    'h' => \$help,
    'a=i' => \$maxAgeHours);

if ($help == 1) {
    print "optimg.pl [options] directory\n\n";
    print "    -v     : be verbose\n";
    print "    -h     : print help\n";
    print "    -a=#   : max age in hours of files to compress (0 = always compress)\n";
    exit;
}

sub list_recursively($);


sub list_recursively($) {
    my ($directory) = @_;
    my @files = (  );

    unless (opendir(DIRECTORY, $directory)) {
        print "Cannot open directory $directory!\n";
        exit;
    }

    # Read the directory, ignoring special entries "." and ".."
    @files = grep (!/^\.\.?$/, readdir(DIRECTORY));

    closedir(DIRECTORY);

    foreach my $file (@files) {
        if (-f "$directory\\$file") {
            handle_file("$directory\\$file");
        } elsif (-d "$directory\\$file") {
            list_recursively("$directory\\$file");
        }
    }
}


sub handle_file($) {
    my ($file) = @_;

    if ($maxAgeHours != 0) {
        my $fileTime = stat($file)->mtime;
        my $prettyFileTime = ctime($fileTime);
        my $fileAgeSeconds = time() - $fileTime;
        if ($fileAgeSeconds > ($maxAgeHours * 3600)) {
            $verbose or print "----- Skipping file: $file, older than $maxAgeHours hours ($prettyFileTime).\n";
            return;
        }
    }

    if ($file =~ m/^(.*)\.(png|jpg|jpeg)$/) {
        my $path = $1;
        my $extension = $2;
        my $base = basename($file, '.' . $extension);
        my $dirname = dirname($file);

        my $newfile = $dirname . '\\' . $base . '-optimized.' . $extension;

        $verbose or print "----- Optimizing image: $file\n";
        my $originalSize = -s $file;

        if ($extension eq 'png') {
            # my $returnCode = system ("$pngout /y \"$file\" \"$file\""); (OLDEST)
            # my $returnCode = system ("$optipng -o5 -strip all \"$file\" 2>>\&1"); (SOMEWHAT BETTER)

            my $returnCode = system ("$zopflipng -m \"$file\" \"$newfile\"");

            if (-s $file > -s $newfile) {
                move($newfile, $file);
            } else {
                unlink $newfile;
            }
        } elsif ($extension eq 'jpg' or $extension eq 'jpeg') {
            # my $returnCode = system ("$jpegoptim --strip-all \"$file\"");
            my $returnCode = system ("$jpegtran -copy none \"$file\" 1>>\"$newfile\"");

            if (-s $file > -s $newfile) {
                move($newfile, $file);
            } else {
                unlink $newfile;
            }
        # } elsif ($extension eq 'gif') {
        #     my $returnCode = system ("$gifsicle -O2 --batch \"$file\"");
        }

        my $resultSize = -s $file;

        $imagesConverted++;
        $totalOriginalSize += $originalSize;
        $totalResultSize += $resultSize;
    }
}


sub main() {
    ## initial call ... $ARGV[0] is the first command line argument
    list_recursively($ARGV[0]);

    if (!$verbose) {
        return;
    }

    print "Number of images:          $imagesConverted\n";
    if ($errorCount > 0) {
        print "Number of errors:          $errorCount\n";
    }
    if ($imagesConverted > 0) {
        print "Original size of images:   $totalOriginalSize bytes\n";
        print "New size of images:        $totalResultSize bytes\n";
        print "Space saved:               " . ($totalOriginalSize - $totalResultSize) . " bytes\n";
    }
}


main();
