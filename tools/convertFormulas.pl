#!/usr/bin/perl -w

use strict;
use File::Basename;

sub listRecursively($);

sub listRecursively($) {
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
            handleFile("$directory\\$file");
        } elsif (-d "$directory\\$file") {
            listRecursively("$directory\\$file");
        }
    }
}

sub handleFile($) {
    my ($file) = @_;
    if ($file =~ m/^(.*)\.tex$/) {
        my $path = $1;
        my $base = basename($file, '.tex');
        my $dirname = dirname($file);

        my $svgFile = $dirname . '\\' . $base . '.svg';
        my $htmlFile = $dirname . '\\' . $base . '.html';
        my $mmlFile = $dirname . '\\' . $base . '.mml';
        my $pngFile = $dirname . '\\' . $base . '.png';

        print "Converting TeX formula: $file\n";

        open(INPUTFILE, $file) || die("Could not open input file $file");
        my $formula = "";
        while (<INPUTFILE>) {
            $formula .= $_;
        }
        close INPUTFILE;

        my $inlineMode = startsWith($base, "inline") ? "--inline" : "";

        # see https://github.com/mathjax/mathjax-node-cli
        system ("tex2svg $inlineMode \"$formula\" > $svgFile");
        system ("tex2htmlcss $inlineMode \"$formula\" > $htmlFile");
        system ("tex2mml $inlineMode \"$formula\" > $mmlFile");

        # see https://github.com/shakiba/svgexport
        system ("svgexport $svgFile $pngFile 1.79x \"svg{background:white;}\"");
    }
}


sub startsWith($) {
    return substr($_[0], 0, length($_[1])) eq $_[1];
}


sub main() {
    my $file = $ARGV[0];

    if (not $file) {
        $file = ".";
    }
    if (-d $file) {
        listRecursively($file);
    } else {
        handleFile($file);
    }
}

main();