#!/usr/bin/env perl

use v5.36;

use File::Spec;
use File::Path qw(make_path);
use Getopt::Long qw(GetOptions);
use Scalar::Util qw(looks_like_number);

# --- NOTE ---
# The g'mic CLI tool does not embed the gmic-community filters by default.
# fx_pahlsson_descreen is a command defined in the community filters.
# run
#
#   gmic update 
#
# to get this command in the CLI tool.

# --- Default configuration (can be overridden via CLI) ---
my $input_dir  = './scanned_photos';        # Folder containing 8-bit, 16-bit, or mixed scans
my $output_dir = './descreened_photos';     # Target folder for uniform 8-bit outputs

# tuning parameters
my $smoothness      = 10;   # 0 to 100: Higher = stronger pattern removal
my $recover_details = 4;    # 0 to 100: Re-introduces edge sharpness/contrast
my $lock_aspect     = 0;    # 0 = No, 1 = Yes
my $background      = 0;    # 0 = Neutral gray background fill

# runtime/behavior flags
my $dry_run   = 0;    # if true, print commands but don't run
my $verbose   = 0;    # higher = more verbose
my $help      = 0;
my $overwrite = 0;    # if true, overwrite original file

GetOptions(
    'input|i=s'        => \$input_dir,
    'output|o=s'       => \$output_dir,
    'smooth|s=i'       => \$smoothness,
    'recover|r=i'      => \$recover_details,
    'lock!'            => \$lock_aspect,     # --lock or --no-lock
    'background=i'     => \$background,
    'dry-run|n'        => \$dry_run,
    'verbose|v+'       => \$verbose,         # -v, -vv, ...
    'help|h'           => \$help,
    'overwrite!'       => \$overwrite
) or usage(1);

if ($help) {
    usage(0);
}

sub clamp($value, $min, $max) {
    return $min if $value < $min;
    return $max if $value > $max;
    return $value;
}

sub validate_parameters() {
  if (defined $smoothness && looks_like_number($smoothness)) {
      $smoothness = clamp($smoothness, 0, 100);
  } else {
      warn "Invalid --smooth value; using default $smoothness\n";
  }

  if (defined $recover_details && looks_like_number($recover_details)) {
      $recover_details = clamp($recover_details, 0, 100);
  } else {
      warn "Invalid --recover value; using default $recover_details\n";
  }

  $lock_aspect = $lock_aspect ? 1 : 0;
  $background  = $background ? 1 : 0;

  print_configuration() if $verbose;
}

sub main() {
    validate_parameters();

    # Ensure output directory exists
    make_path($output_dir) unless -d $output_dir;

    # Read input directory
    opendir(my $dh, $input_dir) or die "Cannot open directory $input_dir: $!";
    my @images = grep { /\.(png|tiff|tif|bmp)$/i } readdir($dh);
    closedir($dh);

    print "Found " . scalar(@images) . " images to process.\n" if $verbose;

    my $count = 0;
    foreach my $file (@images) {

        $count++;
        my $input_path  = File::Spec->catfile($input_dir, $file);
        my $output_path = File::Spec->catfile($output_dir, $file);

        if (!$overwrite && -e $output_path) {
            print "Skipping $file: target file exists.\n" if $verbose;
            next;
        }

        print "[$count/" . scalar(@images) . "] Automatically detecting & processing: $file... \n" if $verbose;

        my ($bit_depth, $resolution) = determine_bit_depth_and_resolution($input_path);

        if (!auto_descreen($input_path, $output_path, $file, $bit_depth)) {
          next;
        }

        restore_resolution($output_path, $file, $resolution);
    }

    print "\nBatch processing complete! All processed files archived as uniform 8-bit in: $output_dir\n" if $verbose;
}

sub determine_bit_depth_and_resolution($input_path) {

    # We retrieve both the bit-depth and horizontal resolution in one command.
    # %x outputs horizontal resolution (e.g. 600) and %[bit-depth] outputs bit-depth (e.g. 16).
    my $cmd_identify = "magick identify -format \"%[bit-depth],%x\" \"$input_path\"";
    my $meta_data = `$cmd_identify`;

    # Defaults in case metadata extraction fails
    my $bit_depth = 8;
    my $resolution = 600;

    if (defined $meta_data && $meta_data =~ /^(\d+),([\d\.]+)/) {
        $bit_depth  = $1;
        # Round the resolution float to an integer (e.g., 600.00 pixels/inch -> 600)
        $resolution = int($2);
    } else {
        print "  -> Warning: Could not parse metadata cleanly. Defaulting to 8-bit, 600 DPI.\n";
    }

    print "  -> Detected Bit Depth: $bit_depth-bit\n" if $verbose;
    print "  -> Detected Resolution: $resolution DPI\n" if $verbose;

    return ($bit_depth, $resolution);
}

sub auto_descreen($input_path, $output_path, $file, $bit_depth) {

    my @gmic_cmd = (
        'gmic',
        '-input', $input_path
    );

    if ($verbose) {
        push(@gmic_cmd, '-verbose', '+');
    } else {
        push(@gmic_cmd, '-verbose', '-');
    }

    # If the file is 16-bit, add a division flag into the instruction stack
    if ($bit_depth == 16) {
        print "  -> Scaling 16-bit depth down to 8-bit...\n" if $verbose;
        push(@gmic_cmd, '-div', '257');
    }

    # Finalize the stack array with the descreen macro and output limits
    push(@gmic_cmd,
        'fx_pahlsson_descreen', "$smoothness,$recover_details,$lock_aspect,$background,0,50,50",
        '-output', "$output_path,uint8,lzw"
    );

    # Execute the G'MIC process
    system_or_dry_run(@gmic_cmd);

    if ($? != 0) {
        print "-> ERROR g'mic processing $file (Exit code: $?)\n";
        return 0;
    }
    return 1;
}

sub restore_resolution($output_path, $file, $resolution) {

    my @cmd_exiftool = ('exiftool', '-overwrite_original', "-XResolution=$resolution", "-YResolution=$resolution", '-ResolutionUnit=in',  $output_path);
    system_or_dry_run(@cmd_exiftool);

    if ($? == 0) {
        print "-> Done.\n" if $verbose;
    } else {
        print "-> ERROR exiftool processing $file (Exit code: $?)\n";
    }
}

sub system_or_dry_run {
  if ($dry_run) {
    print join(" ", @_);
    print "\n";
  } else {
    system(@_);
  }
}

sub print_configuration() {
    print "Configuration:\n";
    print "  input:           $input_dir\n";
    print "  output:          $output_dir\n";
    print "  smoothness:      $smoothness\n";
    print "  recover_details: $recover_details\n";
    print "  lock_aspect:     $lock_aspect\n";
    print "  background:      $background\n";
    print "  dry-run:         $dry_run\n";
    print "  overwrite:       $overwrite\n";
}

sub usage($exit_code) {
    $exit_code //= 0;
    print <<"USAGE";
Usage: $0 [options]

Options:
  -i, --input DIR               Input directory containing images (default: $input_dir)
  -o, --output DIR              Output directory for processed images (default: $output_dir)

  --smooth N, -s N              Smoothness 0..100 (default: $smoothness)
  --recover N, -r N             Recover details 0..100 (default: $recover_details)
  --lock / --no-lock            Lock aspect ratio flag (default: @{[ $lock_aspect ? 'on' : 'off' ]})
  --background N                Background mode (0 = neutral gray, default: $background)

  --dry-run, -n                 Print the actions but do not execute commands
  --overwrite / --no-overwrite  Overwrite output file if it exists (default: @{[ $overwrite ? 'on' : 'off' ]})
  -v, --verbose                 Increase verbosity (can be repeated)
  -h, --help                    Show this help and exit

Examples:
  $0 --input scans --output out --smooth 12 --recover 5
  $0 -i scans -o out --dry-run -vv

USAGE
    exit $exit_code;
}

main();
