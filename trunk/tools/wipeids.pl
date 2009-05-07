# wipeIds.pl -- wipe superfluous ids from an HTML document.

$inputFile = $ARGV[0];
open (INPUTFILE, $inputFile) || die("Could not open $inputFile");

%refHash = ();

# Collect IDs being referenced in the file.
while (<INPUTFILE>)
{
    $line = $_;
    $remainder = $line;
    while ($remainder =~ m/<(.*?)>/)
    {
        $tag = $1;
        $remainder = $';
        $href = getAttrVal("href", $tag);

        if ($href =~ m/^#([a-z0-9.-]+)$/i) 
        {
            $ref = $1;
            $refHash{$ref}++;
        }
    }
}

close INPUTFILE;

open (INPUTFILE, $inputFile) || die("Could not open $inputFile");

# Remove all unused IDs.
while (<INPUTFILE>)
{
    $remainder = $_;
    $output = "";
    while ($remainder =~ m/<(.*?)>/)
    {
        $output .= $`;
        $tag = $1;
        $remainder = $';
        $id = getAttrVal("id", $tag);
        # $href = getAttrVal("href", $tag);

        if ($id ne "") 
        {
            if (!$refHash{$id}) 
            {
                $tag =~ s/id=\"$id\"//;
            }
        }
        $tag =~ s/\s+/ /g;
        $tag =~ s/\s+$//;

        $output .= "<$tag>";
    }
    $output .= $remainder;

    # remove useless (in HTML) namespace declarations.
    $output =~ s/xmlns(:\w+)?=\"(.*?)\"//g;

    # Remove empty anchors:
    $output =~ s/<a><\/a>//g;

    # Remove multiple spaces:
    $output =~ s/[\t ]+/ /g;

	# Remove end-of-line spaces:
    $output =~ s/[\t ]*$//g;

	if ($output !~ /^[\t ]*$/) 
	{
		print $output;
	}
}

close INPUTFILE;


#
# getAttrVal: Get an attribute value from a tag (if the attribute is present)
#
sub getAttrVal
{
    my $attrName = shift;
    my $attrs = shift;
    my $attrVal = "";

    if ($attrs =~ /$attrName\s*=\s*(\w+)/i)
    {
        $attrVal = $1;
    }
    elsif ($attrs =~ /$attrName\s*=\s*\"(.*?)\"/i)
    {
        $attrVal = $1;
    }
    return $attrVal;
}
