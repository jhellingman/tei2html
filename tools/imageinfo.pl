# imageinfo.pl -- Collect information about images into an XML file for processing by XSLT.

use strict;
use warnings;

use Image::Size;
use File::Basename;
use Getopt::Long;

# Override buggy windows version of stat; see https://metacpan.org/release/Win32-UTCFileTime
# use Win32::UTCFileTime qw(:DEFAULT $ErrStr);
BEGIN {
    if ($^O eq "MSWin32") {
        require Win32::UTCFileTime;
        Win32::UTCFileTime->import(qw(:DEFAULT $ErrStr));
    }
}

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
            if ($file =~ /\.mp3|\.mxl/i) {
                handleMP3("$directory/$file");
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
sub handleImage {
    my $imageFile = shift;

    my $imagePath = handlePath($imageFile, "images");
    if ($seenImageHash{$imagePath}) {
        print STDERR "Ignoring second instance of $imagePath\n";
        return;
    }
    $seenImageHash{$imagePath} = 1;

    my $fileDate = getFileDate($imageFile);
    my ($width, $height) = imgsize($imageFile);
    my $fileSize = -s $imageFile;

    print "\n<image path=\"$imagePath\" filesize=\"$fileSize\" filedate=\"$fileDate\" width=\"${width}px\" height=\"${height}px\"/>";
}


#
# handleMP3 -- find some information of an MP3 file.
#
sub handleMP3 {
    my $mp3File = shift;

    my $mp3Path = handlePath($mp3File, "music");
    if ($seenImageHash{$mp3Path}) {
        print STDERR "Ignoring second instance of $mp3Path\n";
        return;
    }
    $seenImageHash{$mp3Path} = 1;

    my $fileDate = getFileDate($mp3File);
    my $fileSize = -s $mp3File;

    print "\n<music path=\"$mp3Path\" filesize=\"$fileSize\" filedate=\"$fileDate\"/>";
}


sub handlePath {
    my $imageFile = shift;
    my $defaultPath = shift;
    my $imagePath;

    if ($stripPath == 1) {
        my ($name, $path, $suffix) = fileparse($imageFile, "");
        $imagePath = "$defaultPath/$name";
    } else {
        $imagePath = dropPath($imageFile, $dropPath);
    }

    return $imagePath;
}


sub getFileDate {
    my $file = shift;

    my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $statFileSize, $atime, $mtime, $ctime, $blksize, $blocks) = stat($file);
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = gmtime($mtime);
    my $fileDate = sprintf "%4d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min , $sec;

    return $fileDate;
}


#
# dropPath -- drop the first $n levels from a directory path.
#
sub dropPath {
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
