while (<>)
{
    $a = $_;

    # $a =~ s/\&euro;/€/g;
    # $a =~ s/\&ndash;/–/g;
    # $a =~ s/\&mdash;/—/g;
    # $a =~ s/\&lsquo;/‘/g;
    # $a =~ s/\&rsquo;/’/g;
    # $a =~ s/\&ldquo;/“/g;
    # $a =~ s/\&rdquo;/”/g;
    # $a =~ s/\&prime;/'/g;

    $a =~ s/\&pm;/±/g;
    $a =~ s/\&mult;/×/g;
    $a =~ s/\&div;/÷/g;
    $a =~ s/\&cent;/¢/g;
    $a =~ s/\&pound;/£/g;
    $a =~ s/\&yen;/¥/g;
    $a =~ s/\&sect;/§/g;
    $a =~ s/\&copy;/©/g;
    $a =~ s/\&deg;/°/g;
    $a =~ s/\&middot;/·/g;

    # $a =~ s/\&dagger;/†/g;
    # $a =~ s/\&Dagger;/‡/g;

    $a =~ s/\&hellips;/…/g;
    $a =~ s/\&frac14;/¼/g;
    $a =~ s/\&frac12;/½/g;
    $a =~ s/\&frac34;/¾/g;
    $a =~ s/\&sup1;/¹/g;
    $a =~ s/\&sup2;/²/g;
    $a =~ s/\&sup3;/³/g;

    $a =~ s/\&ordfem;/ª/g;
    $a =~ s/\&ordmas;/º/g;

    $a =~ s/\&Aacute;/Á/g;
    $a =~ s/\&aacute;/á/g;
    $a =~ s/\&Agrave;/À/g;
    $a =~ s/\&agrave;/à/g;
    $a =~ s/\&Acirc;/Â/g;
    $a =~ s/\&acirc;/â/g;
    $a =~ s/\&Auml;/Ä/g;
    $a =~ s/\&auml;/ä/g;
    $a =~ s/\&Atilde;/Ã/g;
    $a =~ s/\&atilde;/ã/g;
    $a =~ s/\&Aring;/Å/g;
    $a =~ s/\&aring;/å/g;
    $a =~ s/\&AElig;/Æ/g;
    $a =~ s/\&aelig;/æ/g;

    $a =~ s/\&Ccedil;/Ç/g;
    $a =~ s/\&ccedil;/ç/g;

    $a =~ s/\&ETH;/Ð/g;
    $a =~ s/\&eth;/ð/g;

    $a =~ s/\&Eacute;/É/g;
    $a =~ s/\&eacute;/é/g;
    $a =~ s/\&Egrave;/È/g;
    $a =~ s/\&egrave;/è/g;
    $a =~ s/\&Ecirc;/Ê/g;
    $a =~ s/\&ecirc;/ê/g;
    $a =~ s/\&Euml;/Ë/g;
    $a =~ s/\&euml;/ë/g;

    $a =~ s/\&Iacute;/Í/g;
    $a =~ s/\&iacute;/í/g;
    $a =~ s/\&Igrave;/Ì/g;
    $a =~ s/\&igrave;/ì/g;
    $a =~ s/\&Icirc;/Î/g;
    $a =~ s/\&icirc;/î/g;
    $a =~ s/\&Iuml;/Ï/g;
    $a =~ s/\&iuml;/ï/g;

    $a =~ s/\&Ntilde;/Ñ/g;
    $a =~ s/\&ntilde;/ñ/g;

    $a =~ s/\&Oacute;/Ó/g;
    $a =~ s/\&oacute;/ó/g;
    $a =~ s/\&Ograve;/Ò/g;
    $a =~ s/\&ograve;/ò/g;
    $a =~ s/\&Ocirc;/Ô/g;
    $a =~ s/\&ocirc;/ô/g;
    $a =~ s/\&Ouml;/Ö/g;
    $a =~ s/\&ouml;/ö/g;
    $a =~ s/\&Otilde;/Õ/g;
    $a =~ s/\&otilde;/õ/g;
    $a =~ s/\&Oslash;/Ø/g;
    $a =~ s/\&oslash;/ø/g;

    $a =~ s/\&szlig;/ß/g;

    $a =~ s/\&THORN;/Þ/g;
    $a =~ s/\&thorn;/þ/g;

    $a =~ s/\&Uacute;/Ú/g;
    $a =~ s/\&uacute;/ú/g;
    $a =~ s/\&Ugrave;/Ù/g;
    $a =~ s/\&ugrave;/ù/g;
    $a =~ s/\&Ucirc;/Û/g;
    $a =~ s/\&ucirc;/û/g;
    $a =~ s/\&Uuml;/Ü/g;
    $a =~ s/\&uuml;/ü/g;

    $a =~ s/\&Yacute;/Ý/g;
    $a =~ s/\&yacute;/ý/g;
    $a =~ s/\&yuml;/ÿ/g;

    print $a;
}
