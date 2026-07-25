#!/usr/bin/env perl
use strict;
use warnings;
use File::Spec;
use File::Path qw(make_path);

# --- NOTE ---
# The CLI tool does not embed the gmic-community filters by default.
# fx_pahlsson_descreen is a command defined in the community filters.
# run
#
#   gmic update 
#
# to get this command in the CLI tool.

# --- CONFIGURATION ---
my $input_dir  = './scanned_photos';        # Folder containing 8-bit, 16-bit, or mixed scans
my $output_dir = './descreened_photos';     # Target folder for uniform 8-bit outputs

# --- TUNING PARAMETERS ---
my $smoothness      = 10;   # 0 to 100: Higher = stronger pattern removal
my $recover_details = 4;    # 0 to 100: Re-introduces edge sharpness/contrast
my $lock_aspect     = 0;    # 0 = No, 1 = Yes
my $background      = 0;    # 0 = Neutral gray background fill

# Ensure output directory exists
make_path($output_dir) unless -d $output_dir;

# Read input directory
opendir(my $dh, $input_dir) or die "Cannot open directory $input_dir: $!";
my @images = grep { /\.(png|tiff|tif|bmp)$/i } readdir($dh);
closedir($dh);

print "Found " . scalar(@images) . " images to process.\n";

my $count = 0;
foreach my $file (@images) {
    $count++;
    my $input_path  = File::Spec->catfile($input_dir, $file);
    my $output_path = File::Spec->catfile($output_dir, $file);

    print "[$count/" . scalar(@images) . "] Automatically detecting & processing: $file... \n";

    # --- STEP 1: IMAGEMAGICK DATA EXTRACTION ---
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

    print "  -> Detected Bit Depth: $bit_depth-bit\n";
    print "  -> Detected Resolution: $resolution DPI\n";

    # --- STEP 2: BUILD THE G'MIC COMMAND TO DESCREEN ---
    # We construct our processing array cleanly. No shell conditional parsing required!
    my @gmic_cmd = (
        'gmic',
        '-verbose', '+',   
        '-input', $input_path
    );

    # If the file is 16-bit, inject a division flag into the instruction stack
    if ($bit_depth > 8) {
        print "  -> Scaling 16-bit depth down to 8-bit...\n";
        push(@gmic_cmd, '-div', '257');
    }

    # Finalize the stack array with the descreen macro and output limits
    push(@gmic_cmd, 
        'fx_pahlsson_descreen', "$smoothness,$recover_details,$lock_aspect,$background,0,50,50",
        '-output', "$output_path,uint8,lzw"
    );

    # Execute the G'MIC process
    system(@gmic_cmd);

    # STEP 3: RESTORE RESOLUTION WITH EXIFTOOL

    my @cmd_exiftool = ('exiftool', '-overwrite_original', "-XResolution=$resolution", "-YResolution=$resolution", '-ResolutionUnit=in',  $output_path);
    system(@cmd_exiftool);

    if ($? == 0) {
        print "-> Done.\n";
    } else {
        print "-> ERROR processing $file (Exit code: $?)\n";
    }
}

print "\nBatch processing complete! All processed files archived as uniform 8-bit in: $output_dir\n";
