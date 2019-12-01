# pgprepare.pl -- prepare a directory of text files for PGDP.

use strict;
use warnings;

use Getopt::Long;
use File::Copy;

my $directory = '.';
if (defined $ARGV[0]) {
    $directory = $ARGV[0];
}

listRecursively($directory);

#
# listRecursively -- list a directory tree to find all text files in it.
#
sub listRecursively {
    my $directory = shift;
    my @files = (  );

    # print STDERR "Scanning: $directory\n";
    opendir(DIR, $directory) or die "Cannot open directory $directory!\n";
    @files = grep (!/^\.\.?$/, readdir(DIR));
    closedir(DIR);

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
sub cleanText($) {
    my $textFile = shift;

    open(INPUTFILE, $textFile) || die("Could not open file $textFile for reading.");
    open(OUTPUTFILE, "> $textFile.tmp") || die("Could not open $textFile.tmp for writing.");

    while (<INPUTFILE>) {
        my $line = $_;

        # Normalize spaces (including non-breaking spaces):
        $line =~ s/(\s|\xA0)+/ /g;

        # Deal with spaced ellipses:
        $line =~ s/ \. \. \. \. / .... /g;
        $line =~ s/ \. \. \. / ... /g;
        $line =~ s/ \. \. / .. /g;

        # Eliminate trailing spaces:
        $line =~ s/\s+$//;

        # Handle Dutch low-opening quotes
        $line =~ s/^[„]/"/g;
        $line =~ s/^,,([a-zA-Z])/"$1/g;
        $line =~ s/ [„]/ "/g;
        $line =~ s/ ,,([a-zA-Z])/ "$1/g;

        # Handle spacing around punctuation marks
        $line =~ s/ ([.,;!?])(\s)/$1$2/g;
        $line =~ s/ ([.,;!?]")(\s)/$1$2/g;
        $line =~ s/ ([.,;!?])$/$1/g;
        $line =~ s/ ([.,;!?]")$/$1/g;
        $line =~ s/ ?-- ?/--/g;

        print OUTPUTFILE $line . "\n";
    }
    close(INPUTFILE);
    close(OUTPUTFILE);
    move($textFile, "$textFile.bak") || die "Copy failed: $!";
    move("$textFile.tmp", $textFile) || die "Copy failed: $!";
}
