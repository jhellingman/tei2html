#!/usr/bin/perl
#
# win2utf8.pl


# use strict;
# use warnings;

use utf8;

# binmode(STDIN, ":encoding(cp1252)");
binmode(STDOUT, ":utf8");

list_recursively('.');

exit;

# list_recursively
#
#   list the contents of a directory,
#   recursively listing the contents of any subdirectories

sub list_recursively
{
    my ($directory) = @_;
    my @files = (  );

    unless (opendir(DIRECTORY, $directory))
    {
        print "Cannot open directory $directory!\n";
        exit;
    }

    # Read the directory, ignoring special entries "." and ".."
    @files = grep (!/^\.\.?$/, readdir(DIRECTORY));

    closedir(DIRECTORY);

    foreach my $file (@files)
    {
        if (-f "$directory\\$file")
        {
            if ($file =~ /\.txt?$/)
            {
                handle_file("$directory\\$file");
            }
        }
        elsif (-d "$directory\\$file")
        {
            list_recursively("$directory\\$file");
        }
    }
}


# handle_file
#

sub handle_file
{
    my $infile = shift;

    print "processing '$infile'\n";

    open (INPUTFILE, $infile) || die("Could not open input file $infile");
    binmode(INPUTFILE, ":encoding(cp1252)");
    open (OUTPUTFILE, ">$infile.new") || die("Could not open create output file $infile.new");
    binmode(OUTPUTFILE, ":utf8");

    while (<INPUTFILE>)
    {
        $line = $_;

        $line =~ s/\x{201E}/\"/g;
        #$line =~ s/[ ]/ /g;     # no-break space -> normal space.
        $line =~ s/\s+/ /g;     # Multiple whitespace to single whitespace.
        $line =~ s/\s*$//;      # Trim final whitespace.

        print OUTPUTFILE "$line\n";
    }

    close OUTPUTFILE;
    close INPUTFILE;

    system ("copy \"$infile\" \"$infile.bak\"");
    system ("copy \"$infile.new\" \"$infile\"");
    system ("rm \"$infile.new\"");
}
