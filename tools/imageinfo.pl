# imageinfo.pl -- Collect information about images into an XML file for processing by XSLT.

use strict;
use warnings;

use Image::Size;
use File::Basename;
use Getopt::Long;

# Override buggy windows version of stat; see https://metacpan.org/release/Win32-UTCFileTime
use Win32::UTCFileTime qw(:DEFAULT $ErrStr);

my $whiteLevel = 10;
my $stepSize = 10;
my $stripPath = 0;
my $dropPath = 0;

GetOptions (
    's' => \$stripPath,
    'd=i' => \$dropPath);

my $directory = '.';
if (defined $ARGV[0]) {
    $directory = $ARGV[0];
}

my %seenImageHash = ();

main();

sub main {
    print "<images xmlns=\"http://www.gutenberg.ph/2006/schemas/imageinfo\">";
    listRecursively($directory);
    print "\n</images>";
}


#
# listRecursively -- list a directory tree to find all images in it.
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
            if ($file =~ /\.jpe?g$|\.png|\.gif/i) {
                handleImage("$directory/$file");
            }
        }
        elsif (-d "$directory/$file") {
            listRecursively("$directory/$file");
        }
    }
}


#
# handleImage -- find the dimensions of an image.
#
sub handleImage($) {
    my $imageFile = shift;

    my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $statFileSize, $atime, $mtime, $ctime, $blksize, $blocks) = stat($imageFile);
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = gmtime($mtime);
    my $fileDate = sprintf "%4d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min , $sec;

    my $imagePath = $imageFile;
    if ($stripPath == 1) {
        my ($name, $path, $suffix) = fileparse($imageFile, "");
        $imagePath = "images/$name";
    } else {
        $imagePath = dropPath($imagePath, $dropPath);
    }

    if ($seenImageHash{$imagePath}) {
        print STDERR "Ignoring second instance of $imagePath\n";
        return;
    }
    $seenImageHash{$imagePath} = 1;

    my ($width, $height) = imgsize($imageFile);
    my $fileSize = -s $imageFile;

    print "\n<image path=\"$imagePath\" filesize=\"$fileSize\" filedate=\"$fileDate\" width=\"${width}px\" height=\"${height}px\"/>";
}


#
# dropPath -- drop the first $n levels from a directory path.
#
sub dropPath($$) {
    my $path = shift;
    my $n = shift;

    my @components = split(/\//, $path);

    my $i = 0;
    $path = "";
    foreach my $component (@components) {
        if ($i == $n) {
            $path = $component;
        } elsif ($i > $n || $i == @components) {
            $path .= "/" . $component;
        }
        $i++;
    }

    return $path;
}
