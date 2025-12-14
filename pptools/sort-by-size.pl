#!/usr/bin/env perl
use strict;
use warnings;
use File::Copy qw(move);
use File::Basename;
use File::Path qw(make_path);
use Image::Size;

# ---------- Settings ----------
my $LIMIT = 3000; # 3000px @ 600dpi = 1440px @ 288dpi

my %EXT = map { $_ => 1 } qw(
    jpg jpeg png gif tiff tif bmp webp
);

my $wide_dir = "wide";
my $tall_dir = "tall";

# ---------- Dry-run ----------
my $dryrun = 0;
for (@ARGV) {
    $dryrun = 1 if $_ eq '--dryrun';
}

# ---------- Ensure directories ----------
for my $d ($wide_dir, $tall_dir) {
    make_path($d) unless -d $d;
}

# ---------- Scan directory ----------
opendir(my $dh, ".") or die "Cannot open directory: $!";
while (my $file = readdir($dh)) {

    next if $file =~ /^\./;
    next if -d $file;

    # Check extension first
    my ($name, $path, $ext) = fileparse($file, qr/\.[^.]*/);
    $ext =~ s/^\.//;
    next unless $EXT{ lc $ext };

    # Extract image dimensions
    my ($width, $height) = Image::Size::imgsize($path . "/" . $file);
    unless ($width && $height) {
        warn "Could not read size of '$file'\n";
        next;
    }

    next unless $width && $height;

    # Check size threshold
    next unless $width > $LIMIT || $height > $LIMIT;

    # Determine destination
    my $dest_dir = $width > $height ? $wide_dir : $tall_dir;

    # Build destination path with collision avoidance
    my $dest = "$dest_dir/$file";
    my $counter = 1;

    while (-e $dest) {
        $dest = sprintf("%s/%s_%d.%s", $dest_dir, $name, $counter, $ext);
        $counter++;
    }

    if ($dryrun) {
        print "[DRYRUN] Would move '$file' -> '$dest'\n";
    } else {
        move($file, $dest)
            or warn "Failed to move $file -> $dest: $!";
        print "Moved '$file' -> '$dest'\n";
    }
}

closedir $dh;

print $dryrun ? "Dry-run complete.\n" : "Done.\n";
