# Perl run the extract-segs.xsl stylesheet on a directory with Saxon.

use strict;
use warnings;
use FindBin qw($Bin);
use File::Basename;

my $saxon           = "java -jar " . $Bin . "/lib/saxon9he.jar ";
my $xsldir          = $Bin . "/..";                    # location of xsl stylesheets

my $filename = $ARGV[0];


sub list_recursively($);

sub list_recursively($)
{
    my ($directory) = @_;
    my @files = (  );

    print STDERR "Extracting directory $directory\n";

    unless (opendir(DIRECTORY, $directory)) {
        print "Cannot open directory $directory!\n";
        exit;
    }

    # Read the directory, ignoring special entries "." and ".."
    @files = grep (!/^\.\.?$/, readdir(DIRECTORY));

    closedir(DIRECTORY);

    foreach my $file (@files) {
        if (-f "$directory\\$file") {
            handle_file("$directory\\$file");
        } elsif (-d "$directory\\$file") {
            list_recursively("$directory\\$file");
        }
    }
}


sub handle_file($) {
    my ($file) = @_;

    if ($file =~ m/^(.*)\.(xhtml)$/) {
        print STDERR "Extracting file $file\n";

        my $path = $1;
        my $extension = $2;
        my $base = basename($file, '.' . $extension);
        my $dirname = dirname($file);

        my $tempFile = "tmp-segments.xml";
        my $newFile = $dirname . '\\' . $base . '-segments.txt';

        system ("perl -S stripDocType.pl $file > $tempFile");
        system ("$saxon \"$tempFile\" $xsldir/extract-segs.xsl > $newFile");
    }
}


sub main() {
    list_recursively($filename);
}


main();
