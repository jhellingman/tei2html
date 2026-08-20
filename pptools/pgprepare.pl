#!/usr/bin/perl -w

# pgprepare.pl -- prepare a set of text files for upload to PGDP.

use v5.36;

use Getopt::Long;
use File::Copy;

my $readUnicode = 0;
my $showHelp = 0;
my $verbose = 0;

GetOptions(
    'u' => \$readUnicode,
    'v' => \$verbose,
    'q' => \$showHelp,
    'help' => \$showHelp);

if ($showHelp == 1) {
    print "pgprepare.pl -- PGDP pre-processor: prepare a set of text files for upload to PGDP.\n\n";
    print "Usage: pgprepare.pl [-uq] <file>\n\n";
    print "Options:\n";
    print "    u         Read input files as unicode.\n";
    print "    v         Verbose output to STDERR.\n";
    print "    q         Print this help and exit.\n";

    exit(0);
}

my $directory = '.';
if (defined $ARGV[0]) {
    $directory = $ARGV[0];
}

listRecursively($directory);

#
# listRecursively -- list a directory tree to find all text files in it.
#
sub listRecursively($directory) {
    my @files = (  );

    opendir(my $dh, $directory) or die "Cannot open directory $directory: $!";
    @files = grep (!/^\.\.?$/, readdir($dh));
    closedir($dh);

    foreach my $file (@files) {
        if (-f "$directory/$file") {
            if ($file =~ /[0-9]+\.txt/i) {
                cleanText("$directory/$file");
            }
        }
        elsif (-d "$directory/$file") {
            listRecursively("$directory/$file");
        }
    }
}


#
# cleanText -- cleanup a text file for PGDP.
#
sub cleanText($textFile) {

    # open(INPUTFILE, $textFile) || die("Could not open file $textFile for reading.");
    my $input;
    if ($readUnicode == 1) {
        open $input, '<:encoding(UTF-8)', $textFile or die "Could not open UTF-8 file $textFile for reading: $!";
        $verbose and print STDERR "Reading UTF-8 text file: $textFile\n";
    } else {
        open $input, '<:encoding(cp1252)', $textFile or die "Could not open file $textFile for reading: $!";
        $verbose and print STDERR "Reading text file: $textFile\n";
    }
    open my $output, '>', "$textFile.tmp" or die "Could not open $textFile.tmp for writing: $!";
    binmode($output, ":encoding(utf8)");

    while (<$input>) {
        my $line = $_;

        # Normalize spaces (including non-breaking spaces):
        $line =~ s/(\s|\xA0)+/ /g;

        # Deal with spaced ellipses:
        $line =~ s/ \. \. \. \. / .... /g;
        $line =~ s/ \. \. \. / ... /g;
        $line =~ s/ \. \. / .. /g;

        # Eliminate trailing spaces:
        $line =~ s/\s+$//;

        # Handle Dutch or German low-opening quotes
        $line =~ s/^[\x{201E}]/"/g;
        $line =~ s/^,,([a-zA-Z])/"$1/g;
        $line =~ s/ [\x{201E}]/ "/g;
        $line =~ s/ ,,([a-zA-Z])/ "$1/g;

        # Handle spacing around punctuation marks
        $line =~ s/ ([.,;!?])(\s)/$1$2/g;
        $line =~ s/ ([.,;!?]")(\s)/$1$2/g;
        $line =~ s/ ([.,;!?])$/$1/g;
        $line =~ s/ ([.,;!?]")$/$1/g;
        $line =~ s/ ?-- ?/--/g;

        # Handle unwanted characters:
        $line =~ s/[�]/./g;
        $line =~ s/[\x{201C}\x{201D}\x{201E}\x{201F}]/"/g;  # double quotation marks
        $line =~ s/[\x{2018}\x{2019}\x{201A}\x{201B}]/'/g;  # single quotation marks
        $line =~ s/[\x{20AC}]/E/g;                          # euro-sign
        $line =~ s/[�]/"/g;

        $line =~ s/[\x{2E17}\x{2E40}]/-/g;                  # German double hyphen
        $line =~ s/[\x{2014}]/--/g;                         # em-dash

        print $output $line . "\n";
    }
    close $input;
    close $output;
    move($textFile, "$textFile.bak") or die "Copy failed: $!";
    move("$textFile.tmp", $textFile) or die "Copy failed: $!";
}
