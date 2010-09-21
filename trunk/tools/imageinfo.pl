# imageinfo.pl -- Collect information about images into an XML file for processing by XSLT.

use strict;

use Image::Magick;
use File::Basename;
use Getopt::Long;


my $whiteLevel = 10;
my $stepSize = 10;
my $needContour = 0;
my $stripPath = 0;
my $dropPath = 0;

GetOptions (
    'c' => \$needContour,
    's' => \$stripPath,
    'd=i' => \$dropPath);

my $directory = $ARGV[0];

if (!$directory)
{
    $directory = ".";
}


my %seenImageHash = ();

print "<images xmlns=\"http://www.gutenberg.ph/2006/schemas/imageinfo\">";

listRecursively($directory);

print "\n</images>";


#
# listRecursively -- list a directory tree to find all images in it.
#
sub listRecursively($)
{
    my $directory = shift;
    my @files = (  );

    # print STDERR "Scanning: $directory\n";
    opendir(DIR, $directory) or die "Cannot open directory $directory!\n";
    @files = grep (!/^\.\.?$/, readdir(DIR));
    closedir(DIR);

    foreach my $file (@files)
    {
        if (-f "$directory/$file")
        {
            if ($file =~ /\.jpe?g$|\.png|\.gif/i)
            {
                handleImage("$directory/$file");
            }
        }
        elsif (-d "$directory/$file")
        {
            listRecursively("$directory/$file");
        }
    }
}


#
# handleImage -- find the dimensions and optionally outer contours of an image.
#
sub handleImage($)
{
    my $imageFile = shift;
    my $fileFormat;
    my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $fileSize, $atime, $mtime, $ctime, $blksize, $blocks) = stat($imageFile);
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = gmtime($mtime);
    my $fileDate = sprintf "%4d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min , $sec;


    my $imagePath = $imageFile;
    if ($stripPath == 1)
    {
        my ($name, $path, $suffix) = fileparse($imageFile, "");
        $imagePath = "images/$name";
    }
    else
    {
        $imagePath = dropPath($imagePath, $dropPath);
    }

    if ($seenImageHash{$imagePath}) 
    {
        print STDERR "Ignoring second instance of $imagePath\n";
        return
    }
    $seenImageHash{$imagePath} = 1;

    my $image = Image::Magick->new;
    my ($width, $height, $fileSize, $fileFormat) = $image->Ping($imageFile);

    print "\n<image path=\"$imagePath\" filesize=\"$fileSize\" filedate=\"$fileDate\" width=\"${width}px\" height=\"${height}px\">";

    if ($needContour != 0)
    {
        $image->Read($imageFile);

        # collect contour information

        my @leftBoundary;
        my @rightBoundary;

        for (my $y = 0; $y < $height; $y++)
        {
            $leftBoundary[$y] = 0;
            for (my $x = 0; $x < $width; $x++)
            {
                my ($r, $g, $b, $a) = split(",", $image->Get("pixel[$x,$y]"));

                if (isWhite($r, $g, $b))
                {
                    $leftBoundary[$y]++;
                }
                else
                {
                    last;
                }
            }
        }

        for (my $y = 0; $y < $height; $y++)
        {
            $rightBoundary[$y] = 0;
            for (my $x = 0; $x < $width; $x++)
            {
                my $str = "pixel[" . ($width - $x - 1) . ",$y]";
                my ($r, $g, $b, $a) = split(",", $image->Get($str));
                if (isWhite($r, $g, $b))
                {
                    $rightBoundary[$y]++;
                }
                else
                {
                    last;
                }
            }
        }

        print "\n<leftBoundary level=\"$whiteLevel\" step=\"${stepSize}px\">";
        for (my $y = 0; $y < $height; $y += $stepSize)
        {
            my $max = $leftBoundary[$y];
            for (my $y2 = $y; $y2 < $y + $stepSize && $y2 < $height; $y2++)
            {
                $max = $max < $leftBoundary[$y2] ? $max : $leftBoundary[$y2];
            }
            print ($y == 0 ? "$max" : ", $max");
        }
        print "</leftBoundary>";

        print "\n<rightBoundary level=\"$whiteLevel\" step=\"${stepSize}px\">";
        for (my $y = 0; $y < $height; $y += $stepSize)
        {
            my $max = $rightBoundary[$y];
            for (my $y2 = $y; $y2 < $y + $stepSize && $y2 < $height; $y2++)
            {
                $max = $max < $rightBoundary[$y2] ? $max : $rightBoundary[$y2];
            }
            print ($y == 0 ? "$max" : ", $max");
        }
        print "</rightBoundary>";
    }

    print "\n</image>";
}


#
# isWhite -- determine whether a pixel is white enough.
#
sub isWhite($$$)
{
    my ($r, $g, $b) = @_;

    my $gray =  0.299 * $r + 0.587 * $g + 0.114 * $b;
    $gray = $gray / 256;

    return $gray > 255 - $whiteLevel;
}


#
# dropPath -- drop the first $n levels from a directory path.
#
sub dropPath($$)
{
    my $path = shift;
    my $n = shift;

    my @components = split(/\//, $path);

    my $i = 0;
    $path = "";
    foreach my $component (@components)
    {
        if ($i == $n) 
        {
            $path = $component;
        }
        elsif ($i > $n || $i == @components)
        {
            $path .= "/" . $component;
        }
        $i++;
    }

    return $path;
}