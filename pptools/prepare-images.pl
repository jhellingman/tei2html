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
use Pod::Usage;


# Parameters that can be set via command-line options:

my $profile    = 'photo';

my $colorize   = 0;
my $tint       = '#613700';     # #c26519 orange-brown // #613700 = dark brown (nice) -> #240d00  // #1f2952 blueish-gray (nice) -> #001330 // #944300 brown (nice)
                                # Use pure gray to make line-art lighter, e.g. #252525 =~ 90% gray.

my $max_edge   = 720;
my $resolution = 144;
my $target     = 'out';

my $quality;
my $format;
my $posterize;
my $colorspace;
my $blur;

my $help = 0;
my $man  = 0;

GetOptions(
    'max-edge=i'   => \$max_edge,
    'resolution=i' => \$resolution,
    'quality=i'    => \$quality,
    'format=s'     => \$format,
    'posterize=i'  => \$posterize,
    'tint=s'       => \$tint,
    'colorize!'    => \$colorize,
    'blur=s'       => \$blur,
    'colorspace=s' => \$colorspace,
    'target=s'     => \$target,
    'profile=s'    => \$profile,
    'help!'        => \$help,
    'man!'         => \$man,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage(-verbose => 2) if $man;

# My defaults for Project Gutenberg submissions

if ($target eq 'images@1') {
    $max_edge   = 720;
    $resolution = 144;
} elsif ($target eq 'images@2') {
    $max_edge   = 1440;
    $resolution = 288;
}


my $input = shift or die "Usage: $0 [options] <image-or-directory>\n";

# Parameters only set via profiles
my $filter     = 'Mitchell';    # Mitchell // Lanczos
my $chroma     = '4:2:0';

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

my %profiles = (
    'photo' => {
        'filter'     => 'Lanczos',
        'blur'       => 0.8,       
        'radius'     => 1.2,
        'sigma'      => 0.8,
        'amount'     => 0.8,
        'threshold'  => 0.05,
        'colorspace' => 'sRGB',
        'chroma'     => '4:2:0',
        'quality'    => 82,
        'format'     => 'jpg',
        'posterize'  => undef,          # N/A for JPG
    },
    'artwork' => {
        'filter'     => 'Lanczos',
        'blur'       => 0.7,
        'radius'     => 1.5,
        'sigma'      => 1.0,
        'amount'     => 1.0,
        'threshold'  => 0.1,
        'colorspace' => 'sRGB',
        'chroma'     => '4:4:4',
        'quality'    => 82,
        'format'     => 'jpg',
        'posterize'  => undef,          # N/A for JPG
    },
    'line-art' => {
        'filter'     => 'Lanczos',
        'blur'       => 0,
        'radius'     => 1.0, # 1.5,
        'sigma'      => 1.0,
        'amount'     => 0.33, # 1.0,
        'threshold'  => 0,
        'colorspace' => 'gray',
        'chroma'     => '4:2:0',    # N/A for PNG, but set for overrides
        'quality'    => 82,         # idem
        'format'     => 'png',
        'posterize'  => 16,
    },
    'color-line-art' => {
        'filter'     => 'Lanczos',
        'blur'       => 0,
        'radius'     => 1.5,
        'sigma'      => 1.0,
        'amount'     => 1.0,
        'threshold'  => 0,
        'colorspace' => 'sRGB',
        'chroma'     => '4:2:0',    # N/A for PNG, but set for overrides
        'quality'    => 82,         # idem
        'format'     => 'png',
        'posterize'  => 32,
    },
);

apply_profile($profile) if $profile;


sub apply_profile {
    my ($profile_name) = @_;
    
    if (!exists $profiles{$profile_name}) {
        die "Unknown profile: $profile_name. Valid profiles: " . join(', ', keys %profiles) . "\n";
    }
    
    my $profile = $profiles{$profile_name};

    $filter             = $profile->{'filter'};

    $radius             = $profile->{'radius'};
    $sigma              = $profile->{'sigma'};
    $amount             = $profile->{'amount'};
    $threshold          = $profile->{'threshold'};   
    $unsharp_formula    = "${radius}x${sigma}+${amount}+${threshold}";

    $chroma             = $profile->{'chroma'};

    defined $blur       or $blur        = $profile->{'blur'};
    defined $quality    or $quality     = $profile->{'quality'};
    defined $colorspace or $colorspace  = $profile->{'colorspace'};
    defined $format     or $format      = $profile->{'format'};
    defined $posterize  or $posterize   = $profile->{'posterize'};
}

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
        '-filter', $filter,
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
        '-filter', $filter,
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
    unlink $tmp;
}

sub colorized_jpg {
    my ($input, $output) = @_;

    my ($fh, $tmp) = tempfile(SUFFIX => '.ppm');
    close $fh;

    colorized_other($input, $tmp);
    compress_jpg($tmp, $output);
    unlink $tmp;
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
        '-filter', $filter,
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
        '-filter', $filter,
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
        '-filter', $filter,
        '-resize', $resize_formula,
        '-density', $resolution,

        '-unsharp', $unsharp_formula,

        '-colorspace', 'gray',
        '-posterize', $posterize,
        '-dither', 'None',
        '-type', 'Grayscale',

        '-define', "png:compression-level=7",
        $tmp
    ) == 0 or die "magick failed: $?";

    compress_png($tmp, $output);
    unlink $tmp;
}

sub colorized_png {
    my ($input, $output) = @_;

    my ($fh, $tmp) = tempfile(SUFFIX => '.png');
    close $fh;

    system(
        'magick', $input,
        '-units', 'PixelsPerInch',
        '-filter', $filter,
        '-resize', $resize_formula,
        '-density', $resolution,

        '-colorspace', 'gray',
        '(',
            '-size', '1x256',
            "gradient:$tint-white",
        ')',
        '-clut',

        '-unsharp', $unsharp_formula,

        '-posterize', $posterize,
        '-dither', 'None',

        '-define', "png:compression-level=7",
        $tmp
    ) == 0 or die "magick failed: $?";

    compress_png($tmp, $output);
    unlink $tmp;
}


__END__

=head1 NAME

prepare-images.pl - Resize and convert images for use in ebooks.

=head1 SYNOPSIS

prepare-images.pl [options] <file | directory>

Options:
    --max-edge <pixels>     Maximum length of the longest edge
    --resolution <dpi>      Target resolution
    --quality <n>           JPEG quality setting
    --format <ext>          Output format (jpg, png)
    --posterize <n>         Number of grayscale/color levels
    --tint <color>          Tint color used for colorization
    --colorize              Enable colorization
    --target <dir>          Output directory
    --help                  Show brief help
    --man                   Show full documentation

=head1 DESCRIPTION

prepare-images.pl processes images using ImageMagick. Images may be
resampled to a target resolution, resized to limit their maximum
dimension, optionally colorized, and converted to another format.

If a directory is given, all supported image files inside that
directory are processed.

=head1 OPTIONS

=head2 --max-edge

Maximum allowed length of the longest image edge in pixels. Images
larger than this value are scaled down while preserving aspect ratio.

Default: 720

=head2 --resolution

Target image resolution in dots per inch (DPI). Images are resampled
so that their relative physical sizes remain consistent, unless they
exceed the maximum size specified.

Default: 144

=head2 --quality

Compression quality for JPEG output.

Default: 82

=head2 --format

Output image format, typically C<jpg> or C<png>.

Default: jpg

=head2 --posterize

Number of grayscale levels or colors; used for PNG output.

Default: 16

=head2 --tint

Base color used when colorizing images. Any color understood by 
ImageMagick can be used.

Example:

--tint "#c26519"

=head2 --colorize / --nocolorize

Enable or disable colorization of images.

=head2 --target

Directory where output images will be written. If omitted, an
C<out/> directory will be created inside the input directory.

=head1 EXAMPLES

Resize all images in a directory:

prepare-images.pl photos/

Convert an image to PNG with 16 grayscale levels:

prepare-images.pl --format png --posterize 16 image.tif

Apply colorization:

prepare-images.pl --colorize --tint "#5a3fa0" image.png

Write output to another directory:

prepare-images.pl --target output scans/

=head1 AUTHOR

Jeroen Hellingman

=head1 LICENSE

GPL
