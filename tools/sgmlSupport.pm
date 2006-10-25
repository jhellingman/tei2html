
package sgmlSupport;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(getAttrVal);

# patterns for recognizing letters (including letter entities)

BEGIN
{
	$capAccLetter = "\\&[A-Z](acute|grave|circ|uml|cedil|tilde|slash|ring|dotb|macr|breve);";
	$capLigLetter = "\\&[A-Z]{2}lig;";
	$capSpecLetter = "\\&apos;|\\&ETH;|\\&THORN;|\\&alif;|\\&ayn;|\\&prime;";

	$smallAccLetter = "\\&[a-z](acute|grave|circ|uml|cedil|tilde|slash|ring|dotb|macr|breve);";
	$smallLigLetter = "\\&[a-z]{2}lig;";
	$smallSpecLetter = "\\&apos;|\\&eth;|\\&thorn;|\\&alif;|\\&ayn;|\\&prime;";

	$capLetter = "([A-Z]|$capAccLetter|$capLigLetter|$capSpecLetter)";
	$smallLetter = "([a-z]|$smallAccLetter|$smallLigLetter|$smallSpecLetter)";
	$letter = "($capLetter|$smallLetter)";
}

# Get an attribute value (if the attribute is present)
#
# Usage:
#	getAttrVal($attrName, $attrs)
# Parameters:
#   $attrName: the name of which the attribute value is required.
#	$attrs: string with SGML style attributes:  A=abc B="test" C="aap"

sub getAttrVal
{
	my $attrName = shift;
	my $attrs = shift;
	my $attrVal = "";

	if($attrs =~ /$attrName\s*=\s*(\w+)/i)
	{
		$attrVal = $1;
	}
	elsif($attrs =~ /$attrName\s*=\s*\"(.*?)\"/i)
	{
		$attrVal = $1;
	}
	return $attrVal;
}
