#!/usr/bin/env perl
use strict;
use warnings;
use File::Spec;
use Getopt::Long;

# Parameters
my $dir = ".";
my $increment = 1;
my $offset    = 1;
my $reverse   = 0;
my $dry_run   = 0;

GetOptions(
    "dir=s"       => \$dir,
    "increment=i" => \$increment,
    "offset=i"    => \$offset,
    "reverse!"    => \$reverse,
    "dryrun!"    => \$dry_run,
) or die "Error parsing options\n";

# 1. Load all file names
opendir(my $dh, $dir) or die "Cannot open directory '$dir': $!";
my @files = grep { -f File::Spec->catfile($dir, $_) } readdir($dh);
closedir($dh);

# Filter image-like files
@files = grep { /\.(?:jpg|jpeg|png|tif|tiff|bmp|gif)$/i } @files;

# 2. Sort alphabetically (or reverse if requested)
@files = sort @files;
@files = reverse @files if $reverse;

# 3. Compute new names
my @renames;
my $num = $offset;

for my $old (@files) {
    my ($base, $ext) = $old =~ /^(.*?)(\.[^.]+)?$/;
    $ext ||= '';
    my $new = sprintf("%04d%s", $num, $ext);  # zero-padded
    push @renames, [ $old, $new ];
    $num += $increment;
}

# 4. Verify collisions
{
    my %existing = map { $_ => 1 } @files;
    for my $pair (@renames) {
        my ($old, $new) = @$pair;
        if ($existing{$new} && $new ne $old) {
            die "Name collision detected: '$new' already exists. Aborting.\n";
        }
    }
}

# 5. Perform renames (or simulate them)
for my $pair (@renames) {
    my ($old, $new) = @$pair;

    if ($old eq $new) {
        print "[skip] $old -> $new (unchanged)\n" if $dry_run;
        next;
    }

    if ($dry_run) {
        print "[dry-run] $old -> $new\n";
    } else {
        my $oldpath = File::Spec->catfile($dir, $old);
        my $newpath = File::Spec->catfile($dir, $new);

        rename($oldpath, $newpath)
            or die "Failed to rename '$old' -> '$new': $!";
        print "$old -> $new\n";
    }
}

print $dry_run ? "Dry run complete.\n" : "Renaming complete.\n";
