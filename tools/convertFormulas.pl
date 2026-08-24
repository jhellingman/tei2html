#!/usr/bin/perl -w

use v5.36;

use File::Basename;
use Getopt::Long;
use IPC::Open3;
use Symbol 'gensym';

my $force = 0;         # Force regeneration even when output exists.

my $makeHtml = 0;      # Generate HTML files.
my $makeSvg = 0;       # Generate SVG files.
my $makeMml = 0;       # Generate MML files.
my $makePng = 0;       # Generate PNG files.

my $speech = 1;        # Output accessible speech in generated SVG (to avoid running into a bug printing "index radical" before the SVG code in the output). 

GetOptions(
    'h' => \$makeHtml,
    's' => \$makeSvg,
    'm' => \$makeMml,
    'p' => \$makePng,
    'f' => \$force,
    'speech!' => \$speech
    );

if ($makeHtml == 0 && $makeMml == 0 && $makePng == 0) {
    $makeSvg = 1;
}

sub main() {
    my $file = $ARGV[0];

    if (!defined $file) {
        $file = ".";
    }
    if (-d $file) {
        listRecursively($file);
    } else {
        handleFile($file);
    }
}

sub listRecursively($directory) {
    my @files = (  );

    opendir(my $dirHandle, $directory) or die "Cannot open directory $directory: $!";

    # Read the directory, ignoring special entries "." and ".."
    @files = grep (!/^\.\.?$/, readdir($dirHandle));

    closedir($dirHandle);

    foreach my $file (@files) {
        my $filePath = "$directory/$file";
        if (-f $filePath) {
            handleFile($filePath);
        } elsif (-d $filePath) {
            listRecursively($filePath);
        }
    }
}

sub handleFile($file) {
    if ($file !~ m/^(.*)\.tex$/) {
      return;
    }

    my $base = basename($file, '.tex');
    my $dirname = dirname($file);

    my $svgFile = $dirname . '/' . $base . '.svg';
    my $htmlFile = $dirname . '/' . $base . '.html';
    my $mmlFile = $dirname . '/' . $base . '.mml';
    my $pngFile = $dirname . '/' . $base . '.png';

    # say "Converting TeX formula: $file";

    open my $fileHandle, '<', $file or die "Could not open input file $file: $!";
    my $formula = "";
    while (<$fileHandle>) {
        $formula .= $_;
    }
    close $fileHandle;

    my $inlineMode = startsWith($base, "inline");

    # see https://github.com/mathjax/mathjax-node-cli
    if ($makeSvg  && ($force || !-e $svgFile))  { writeMathFormula('tex2svg',     $inlineMode, $formula, $svgFile); }
    if ($makeHtml && ($force || !-e $htmlFile)) { writeMathFormula('tex2htmlcss', $inlineMode, $formula, $htmlFile); }
    if ($makeMml  && ($force || !-e $mmlFile))  { writeMathFormula('tex2mml',     $inlineMode, $formula, $mmlFile); }

    # see https://github.com/shakiba/svgexport
    if ($makePng  && ($force || !-e $pngFile))  { system ('svgexport', $svgFile, $pngFile, '1.79x', 'svg{background:white;}'); }

}

sub runAndCapture(@cmd) {
    my $errfh = gensym;
    my $pid = open3(undef, my $outfh, $errfh, @cmd);
    binmode $outfh;
    binmode $errfh;
    my $stdout = do { local $/; <$outfh> // '' };
    my $stderr = do { local $/; <$errfh> // '' };
    waitpid($pid, 0);
    my $exit = $? >> 8;
    return ($stdout, $stderr, $exit);
}

sub writeMathFormula($tool, $inlineMode, $formula, $outputFile) {
    say "Calling $tool tool to create $outputFile for formula: '$formula'";

    my @cmd = ($tool);
    push @cmd, '--inline' if $inlineMode;
    push @cmd, '--speech=false' if $speech == 0;
    push @cmd, $formula;
    my ($output, $err, $exit) = runAndCapture(@cmd);
    if ($exit != 0) {
        warn "$tool failed (exit=$exit): $err";
    }

    # Noticed that some generated SVG is invalid, so adding an extra check.
    if ($tool eq 'tex2svg' and rindex($output, '<svg', 0) != 0) {
        warn "Generated output for $outputFile does not start with '<svg': discarding output.";
        warn $err;
        warn "(Try running with --no-speech if TeX-formula appears correct)";
        return;
    }
    open my $fh, '>', $outputFile or die "Could not open $outputFile: $!";
    print $fh $output;
    close $fh;
}

sub startsWith($string, $prefix) {
    return substr($string, 0, length($prefix)) eq $prefix;
}

main();
