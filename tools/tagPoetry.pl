# poetry.pl

$poetrymode = 0;

while (<>)
{
    $line = $_;
    if ($line =~ /\/\*/)
    {
        $poetrymode = 1;
        print "<lg>\n";

    }
    elsif ($line =~ /\*\//)
    {
        $poetrymode = 0;
        print "</lg>\n";
    }
    elsif ($poetrymode == 0)
    {
        print $line;
    }
    else
    {
        # blank line in poetry mode:
        if ($line =~ /^\s*$/)
        {
            print "</lg>\n\n<lg>\n";
        }
        else
        {
            # count white space before
            $line =~ /^(\s*)(.*)$/;
            $spaces = $1;
            $line = $2;
            $n = length($spaces);
            if ($n == 0)
            {
                print "    <l>$line\n";
            }
            else
            {
                print "    $spaces<l rend=\"indent($n)\">$line\n";
            }
        }
    }
}
