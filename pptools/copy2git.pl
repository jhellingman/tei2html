#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use File::Find;
use File::Copy;
use File::Path qw(make_path);
use File::Spec;
use Cwd 'abs_path';

# Option parsing
my $dry_run = 0;
GetOptions('dry-run' => \$dry_run) or die "Usage: $0 [--dry-run] source_dir [target_dir]\n";

# Positional arguments
die "Usage: $0 [--dry-run] source_dir target_dir\n" unless @ARGV == 2 || @ARGV == 1;

my ($source, $target) = @ARGV;
$source = abs_path($source);
$target = abs_path($target);

# Validate source and target directories
die "Source directory '$source' does not exist!\n" unless -d $source;

# Find the existing git repo if it exists:
my $root = "D:/Users/Jeroen/Documents/eLibrary/Git/GutenbergSource";
my $repo = extract_pgsrc_id($source);

if (defined $repo) {
    $target = $root . "/" . $repo;
}

die "No target directory defined\n" unless defined $target;

die "Target directory '$target' does not exist!\n" unless -d $target or $dry_run;

# List of filename patterns to ignore
my @ignored_patterns = (
    qr/\.bak$/,   # ends with .bak
    qr/\.err$/,
    qr/\.epub$/,  # ends with .epub
    qr/^tmp/,     # starts with tmp
    qr/\.7z$/,
    qr/issues.xml$/,
    qr/.*-checks.html$/,
    qr/.*-included.xml$/,
    qr/.*-preprocessed.xml$/,
    qr/.*-schematron-report.html$/,
    qr/.*-words.html$/,

    qr/^[0-9]+.txt$/,
    qr/^[0-9]+-8.txt$/,
    qr/^[0-9]+-0.txt$/,
    qr/^[0-9]+-h.htm$/,
);

find(\&wanted, $source);

if (defined $repo) {
    print "\n\nNow verify the git directory, remove any redundant files, and say\n";
    print "\ngit add -A\ngit commit -m \"updated ebook\"\ngit push\n";
}

sub wanted {
    my $rel_path = File::Spec->abs2rel($File::Find::name, $source);
    my $target_path = File::Spec->catfile($target, $rel_path);
    my $name = $_;

    # Check ignore patterns
    foreach my $pattern (@ignored_patterns) {
        return if -f $_ && $name =~ $pattern;
    }

    # Ignore 'images' directory inside 'Processed' if 'images@1' exists
    if (-d $_ && $name eq 'images') {
        my $parent = $File::Find::dir;
        my $base = (File::Spec->splitdir($parent))[-1];
        if ($base eq 'Processed') {
            my $sibling = File::Spec->catdir($parent, 'images@1');
            return if -d $sibling;
        }
    }

    # Handle directories
    if (-d $_) {
        unless (-d $target_path) {
            print "[DRY-RUN] " if $dry_run;
            print "Creating directory: $target_path\n";
            make_path($target_path) unless $dry_run;
        }
    }
    # Handle file copying
    elsif (-f $_) {
        my ($volume, $directories, undef) = File::Spec->splitpath($target_path);
        my $dir = File::Spec->catpath($volume, $directories, '');
        unless (-d $dir) {
            print "[DRY-RUN] " if $dry_run;
            print "Creating directory: $dir\n";
            make_path($dir) unless $dry_run;
        }

        print "[DRY-RUN] " if $dry_run;
        print "Copying file: $File::Find::name -> $target_path\n";
        unless ($dry_run) {
            copy($File::Find::name, $target_path)
                or warn "Failed to copy $File::Find::name: $!";
            # Preserve timestamps
            my @stat = stat($File::Find::name);
            utime($stat[8], $stat[9], $target_path);  # atime, mtime
        }
    }
}

sub extract_pgsrc_id {
    my ($dir) = @_;
    opendir my $dh, $dir or do {
        warn "Cannot open directory '$dir': $!";
        return undef;
    };

    my ($tei_file) = grep { /[0-9]\.[0-9]+\.tei$/ && -f "$dir/$_" } readdir($dh);
    closedir $dh;

    return undef unless $tei_file;
    my $full_path = "$dir/$tei_file";

    open my $fh, '<:encoding(iso-latin-1)', $full_path or do {
        warn "Could not open $full_path: $!";
        return undef;
    };

    while (my $line = <$fh>) {
        if ($line =~ m{<idno\s+type=["']?PGSrc["']?\s*>(.*?)</idno>}) {
            close $fh;
            return $1;
        }
    }

    return undef;
}
