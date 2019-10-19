use strict;
use warnings;
while (<>) {

    my $line = $_;

    $line =~ s/\&iexcl;/¡/g;
    $line =~ s/\&iquest;/¿/g;
    $line =~ s/\&raquo;/»/g;
    $line =~ s/\&laquo;/«/g;

    $line =~ s/\&pm;/±/g;
    $line =~ s/\&mult;/×/g;
    $line =~ s/\&div;/÷/g;

    $line =~ s/\&cent;/¢/g;
    $line =~ s/\&pound;/£/g;
    $line =~ s/\&yen;/¥/g;

    $line =~ s/\&sect;/§/g;

    $line =~ s/\&Aacute;/Á/g;
    $line =~ s/\&aacute;/á/g;
    $line =~ s/\&Agrave;/À/g;
    $line =~ s/\&agrave;/à/g;
    $line =~ s/\&Acirc;/Â/g;
    $line =~ s/\&acirc;/â/g;
    $line =~ s/\&Auml;/Ä/g;
    $line =~ s/\&auml;/ä/g;
    $line =~ s/\&Atilde;/Ã/g;
    $line =~ s/\&atilde;/ã/g;
    $line =~ s/\&Aring;/Å/g;
    $line =~ s/\&aring;/å/g;
    $line =~ s/\&AElig;/Æ/g;
    $line =~ s/\&aelig;/æ/g;

    $line =~ s/\&Ccedil;/Ç/g;
    $line =~ s/\&ccedil;/ç/g;

    $line =~ s/\&ETH;/Ð/g;
    $line =~ s/\&eth;/ð/g;

    $line =~ s/\&Eacute;/É/g;
    $line =~ s/\&eacute;/é/g;
    $line =~ s/\&Egrave;/È/g;
    $line =~ s/\&egrave;/è/g;
    $line =~ s/\&Ecirc;/Ê/g;
    $line =~ s/\&ecirc;/ê/g;
    $line =~ s/\&Euml;/Ë/g;
    $line =~ s/\&euml;/ë/g;

    $line =~ s/\&Iacute;/Í/g;
    $line =~ s/\&iacute;/í/g;
    $line =~ s/\&Igrave;/Ì/g;
    $line =~ s/\&igrave;/ì/g;
    $line =~ s/\&Icirc;/Î/g;
    $line =~ s/\&icirc;/î/g;
    $line =~ s/\&Iuml;/Ï/g;
    $line =~ s/\&iuml;/ï/g;

    $line =~ s/\&Ntilde;/Ñ/g;
    $line =~ s/\&ntilde;/ñ/g;

    $line =~ s/\&Oacute;/Ó/g;
    $line =~ s/\&oacute;/ó/g;
    $line =~ s/\&Ograve;/Ò/g;
    $line =~ s/\&ograve;/ò/g;
    $line =~ s/\&Ocirc;/Ô/g;
    $line =~ s/\&ocirc;/ô/g;
    $line =~ s/\&Ouml;/Ö/g;
    $line =~ s/\&ouml;/ö/g;
    $line =~ s/\&Otilde;/Õ/g;
    $line =~ s/\&otilde;/õ/g;
    $line =~ s/\&Oslash;/Ø/g;
    $line =~ s/\&oslash;/ø/g;

    $line =~ s/\&szlig;/ß/g;

    $line =~ s/\&THORN;/Þ/g;
    $line =~ s/\&thorn;/þ/g;

    $line =~ s/\&Uacute;/Ú/g;
    $line =~ s/\&uacute;/ú/g;
    $line =~ s/\&Ugrave;/Ù/g;
    $line =~ s/\&ugrave;/ù/g;
    $line =~ s/\&Ucirc;/Û/g;
    $line =~ s/\&ucirc;/û/g;
    $line =~ s/\&Uuml;/Ü/g;
    $line =~ s/\&uuml;/ü/g;

    $line =~ s/\&Yacute;/Ý/g;
    $line =~ s/\&yacute;/ý/g;
    $line =~ s/\&yuml;/ÿ/g;

    print $line;
}
