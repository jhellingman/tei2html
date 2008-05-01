

use Image::Magick;
use File::Basename;

# use strict;

$whiteLevel = 10;
$stepSize = 10;
$needContour = 0;
$stripPath = 0;

$directory = $ARGV[0];

if ($directory eq "-c") 
{
	$needContour = 1;
	$directory = $ARGV[1];
}

if ($directory eq "-s") 
{
	$stripPath = 1;
	$directory = $ARGV[1];
}

if (!$directory) 
{
	$directory = ".";
}



print "<images xmlns=\"http://www.gutenberg.ph/2006/schemas/imageinfo\">";

listRecursively($directory);

print "\n</images>";



sub listRecursively 
{
    my $directory = shift;
    my @files = (  );
    
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




sub handleImage
{
	my $imageFile = shift;
	my $fileFormat;
	my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $fileSize, $atime, $mtime, $ctime, $blksize, $blocks) = stat($imageFile);
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime($mtime);
	my $fileDate = sprintf "%4d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min , $sec;

	my $image = Image::Magick->new;

	my ($width, $height, $fileSize, $fileFormat) = $image->Ping($imageFile);

	my $imagePath = $imageFile;
	if ($stripPath == 1) 
	{
		my ($name, $path, $suffix) = fileparse($imageFile, "");
		$imagePath = "images/$name";
	}

	print "\n<image path=\"$imagePath\" filesize=\"$fileSize\" filedate=\"$fileDate\" width=\"${width}px\" height=\"${height}px\">";

	if ($needContour != 0) 
	{
		$image->Read($imageFile);

		# collect contour information

		for ($y = 0; $y < $height; $y++)
		{
			$leftBoundary[$y] = 0;
			for ($x = 0; $x < $width; $x++)
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

		for ($y = 0; $y < $height; $y++)
		{
			$rightBoundary[$y] = 0;
			for ($x = 0; $x < $width; $x++)
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
		for ($y = 0; $y < $height; $y += $stepSize)
		{
			$max = $leftBoundary[$y];
			for ($y2 = $y; $y2 < $y + $stepSize && $y2 < $height; $y2++) 
			{
				$max = $max < $leftBoundary[$y2] ? $max : $leftBoundary[$y2];
			}
			print ($y == 0 ? "$max" : ", $max");
		}
		print "</leftBoundary>";

		print "\n<rightBoundary level=\"$whiteLevel\" step=\"${stepSize}px\">";
		for ($y = 0; $y < $height; $y += $stepSize)
		{
			$max = $rightBoundary[$y];
			for ($y2 = $y; $y2 < $y + $stepSize && $y2 < $height; $y2++) 
			{
				$max = $max < $rightBoundary[$y2] ? $max : $rightBoundary[$y2];
			}
			print ($y == 0 ? "$max" : ", $max");
		}
		print "</rightBoundary>";
	}

	print "\n</image>";

	return TRUE;
}


sub isWhite
{	
	my ($r, $g, $b) = @_;

	$gray =  0.299 * $r + 0.587 * $g + 0.114 * $b;

	$gray = $gray / 256;
	return $gray > 255 - $whiteLevel;
}