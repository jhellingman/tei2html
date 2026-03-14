#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use File::Temp qw(tempfile);
use File::Copy;
use File::Spec;
use File::Path qw(make_path);
use IPC::System::Simple qw(system);

my $max_edge   = 720;
my $resolution = 144;
my $quality    = 82;
my $format     = 'jpg';
my $levels     = 16;
my $colorize   = 0;
my $tint       = '#613700'; # #c26519 orange-brown // #613700 = dark brown (nice) -> #240d00  // #1f2952 blueish-gray (nice) -> #001330 // #944300 brown (nice)  //
my $target     = 'out';

GetOptions(
    'max-edge=i'   => \$max_edge,
    'resolution=i' => \$resolution,
    'quality=i'    => \$quality,
    'format=s'     => \$format,
    'levels=i'     => \$levels,
    'tint=s'       => \$tint,
    'colorize!'    => \$colorize,
    'target=s'     => \$target,
);


# My defaults for Project Gutenberg submissions

if ($target eq 'images@1') {
    $max_edge   = 720;
    $resolution = 144;
} elsif ($target eq 'images@2') {
    $max_edge   = 1440;
    $resolution = 288;
}

# Idea: profiles
#
#               photo             artwork           line-art 
#
# filter        Lanczos/Mitchell  Lanczos           Lanczos
# blur          0.8               0.7               None
# unsharp       1.2x0.8+0.8+0.05  1.5x1.0+1.0+0.1   1.5x1.0+1.0+0
# chroma        4:2:0             4:4:4             N/A
# format        jpg               jpg               png


my $input = shift or die "Usage: $0 [options] <image-or-directory>\n";

# We want to reduce the resolution to the given value, but limit the size to the max_edge length given,
# and only resample once, hence this complex formula:
my $resize_formula = "%[fx:100*min($resolution/max(resolution.x,1),$max_edge/max(w,h))]%";

# Photoshop unsharp mask: amount 33%, radius 1.0, threshold 0
# ImageMagick syntax: -unsharp radius x sigma + amount + threshold
my $radius     = 1.0;
my $sigma      = 1.0;     # good match for PS radius 1.0
my $amount     = 0.33;
my $threshold  = 0;
my $unsharp_formula = "${radius}x${sigma}+${amount}+${threshold}";


if (-d $input) {
    process_directory($input);
} else {
    my ($name, $path) = fileparse($input, qr/\.[^.]+/);
    my $outdir = File::Spec->catdir($path, $target);
    make_path($outdir) unless -d $outdir;
    process_file($input, $outdir);
}

sub process_directory {
    my $dir = shift;

    my $outdir = File::Spec->catdir($dir, $target);
    make_path($outdir) unless -d $outdir;

    opendir(my $dh, $dir) or die "Cannot open directory '$dir': $!";

    while (my $file = readdir($dh)) {
        next if $file =~ /^\./;

        my $path = File::Spec->catfile($dir, $file);
        process_file($path, $outdir);
    }
    closedir($dh);
}

sub process_file {
    my ($input, $outdir) = @_;

    return unless -f $input;
    return unless $input =~ /\.(jpe?g|png|tiff?)$/i;

    my ($name, $path) = fileparse($input, qr/\.[^.]+/);
    my $output = File::Spec->catfile($outdir, "$name.$format");

    if ($colorize) {
        if ($format eq 'png') {
            colorized_png($input, $output);
        } elsif ($format eq 'jpg') {
            colorized_jpg($input, $output);
        } else {
            colorized_other($input, $output);
        }
    } else {
        if ($format eq 'png') {
            standard_png($input, $output);
        } elsif ($format eq 'jpg') {
            standard_jpg($input, $output);
        } else {
            standard_other($input, $output);
        }
    }
}

sub standard_other {
    my ($input, $output) = @_;

    system(
        'magick', $input,
        '-units', 'PixelsPerInch',
        '-filter', 'Mitchell',
        '-define', 'filter:blur=0.9',
        '-resize', $resize_formula,
        '-density', $resolution,
        '-unsharp', $unsharp_formula,
        '-strip',
        $output
    ) == 0 or die "magick failed: $?";
}

sub colorized_other {
    my ($input, $output) = @_;

    system(
        'magick', $input,
        '-units', 'PixelsPerInch',
        '-filter', 'Mitchell',
        '-define', 'filter:blur=0.9',
        '-resize', $resize_formula,
        '-density', $resolution,

        '-colorspace', 'gray',
        '(',
            '-size', '1x256',
            "gradient:$tint-white",
        ')',
        '-clut',

        '-unsharp', $unsharp_formula,
        '-strip',
        $output
    ) == 0 or die "magick failed: $?";
}

sub standard_jpg {
    my ($input, $output) = @_;

    my ($fh, $tmp) = tempfile(SUFFIX => '.ppm');
    close $fh;

    standard_other($input, $tmp);
    compress_jpg($tmp, $output);
}

sub colorized_jpg {
    my ($input, $output) = @_;

    my ($fh, $tmp) = tempfile(SUFFIX => '.ppm');
    close $fh;

    colorized_other($input, $tmp);
    compress_jpg($tmp, $output);
}

sub compress_jpg {
    my ($input, $output) = @_;
    system(
        'cjpegli',
        '-q', $quality,
        '--chroma_subsampling=420',
        '--progressive_level=2',
        $input,
        $output
    ) == 0 or die "cjpegli failed: $?";
}

sub compress_png {
    my ($input, $output) = @_;

    system('zopflipng', '-m', $input, $output) == 0 or die "zopflipng failed: $?";;

    if (-s $input < -s $output) {
        copy($input, $output);
    }
}

sub standard_jpg_direct {
    my ($input, $output) = @_;

    system(
        'magick', $input,
        '-units', 'PixelsPerInch',
        '-filter', 'Lanczos',
        '-define', 'filter:blur=0.9',
        '-resize', $resize_formula,
        '-density', $resolution,
        '-unsharp', $unsharp_formula,
        '-strip',
        '-colorspace', 'sRGB',
        '-define', 'jpeg:optimize-coding=true',
        '-sampling-factor', '4:2:0',
        '-interlace', 'Plane',
        '-quality', $quality,
        $output
    ) == 0 or die "magick failed: $?";
}

sub colorized_jpg_direct {
    my ($input, $output) = @_;

    system(
        'magick', $input,
        '-units', 'PixelsPerInch',
        '-filter', 'Lanczos',
        '-define', 'filter:blur=0.9',
        '-resize', $resize_formula,
        '-density', $resolution,

        '-colorspace', 'gray',
        '(',
            '-size', '1x256',
            "gradient:$tint-white",
        ')',
        '-clut',

        '-unsharp', $unsharp_formula,
        '-strip',
        '-colorspace', 'sRGB',
        '-define', 'jpeg:optimize-coding=true',
        '-sampling-factor', '4:2:0',
        '-interlace', 'Plane',
        '-quality', $quality,
        $output
    ) == 0 or die "magick failed: $?";
}

sub standard_png {
    my ($input, $output) = @_;

    my ($fh, $tmp) = tempfile(SUFFIX => '.png');
    close $fh;

    system(
        'magick', $input,
        '-units', 'PixelsPerInch',
        '-filter', 'Mitchell',
        '-resize', $resize_formula,
        '-density', $resolution,

        '-unsharp', $unsharp_formula,

        '-colorspace', 'Gray',
        '-posterize', $levels,
        '-dither', 'None',
        '-type', 'Grayscale',

        '-define', "png:compression-level=7",
        $tmp
    ) == 0 or die "magick failed: $?";

    compress_png($tmp, $output);
}

sub colorized_png {
    my ($input, $output) = @_;

    my ($fh, $tmp) = tempfile(SUFFIX => '.png');
    close $fh;

    system(
        'magick', $input,
        '-units', 'PixelsPerInch',
        '-filter', 'Mitchell',
        '-resize', $resize_formula,
        '-density', $resolution,

        '-colorspace', 'gray',
        '(',
            '-size', '1x256',
            "gradient:$tint-white",
        ')',
        '-clut',

        '-unsharp', $unsharp_formula,

        '-posterize', $levels,
        '-dither', 'None',

        '-define', "png:compression-level=7",
        $tmp
    ) == 0 or die "magick failed: $?";

    compress_png($tmp, $output);
}
