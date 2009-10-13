while (<>)
{
    $a = $_;

    # $a =~ s/\&euro;/�/g;
    # $a =~ s/\&ndash;/�/g;
    # $a =~ s/\&mdash;/�/g;
    # $a =~ s/\&lsquo;/�/g;
    # $a =~ s/\&rsquo;/�/g;
    # $a =~ s/\&ldquo;/�/g;
    # $a =~ s/\&rdquo;/�/g;
    # $a =~ s/\&prime;/'/g;

    $a =~ s/\&pm;/�/g;
    $a =~ s/\&mult;/�/g;
    $a =~ s/\&div;/�/g;
    $a =~ s/\&cent;/�/g;
    $a =~ s/\&pound;/�/g;
    $a =~ s/\&yen;/�/g;
    $a =~ s/\&sect;/�/g;
    $a =~ s/\&copy;/�/g;
    $a =~ s/\&deg;/�/g;
    $a =~ s/\&middot;/�/g;

    # $a =~ s/\&dagger;/�/g;
    # $a =~ s/\&Dagger;/�/g;

    $a =~ s/\&hellips;/�/g;
    $a =~ s/\&frac14;/�/g;
    $a =~ s/\&frac12;/�/g;
    $a =~ s/\&frac34;/�/g;
    $a =~ s/\&sup1;/�/g;
    $a =~ s/\&sup2;/�/g;
    $a =~ s/\&sup3;/�/g;

    $a =~ s/\&ordfem;/�/g;
    $a =~ s/\&ordmas;/�/g;

    $a =~ s/\&Aacute;/�/g;
    $a =~ s/\&aacute;/�/g;
    $a =~ s/\&Agrave;/�/g;
    $a =~ s/\&agrave;/�/g;
    $a =~ s/\&Acirc;/�/g;
    $a =~ s/\&acirc;/�/g;
    $a =~ s/\&Auml;/�/g;
    $a =~ s/\&auml;/�/g;
    $a =~ s/\&Atilde;/�/g;
    $a =~ s/\&atilde;/�/g;
    $a =~ s/\&Aring;/�/g;
    $a =~ s/\&aring;/�/g;
    $a =~ s/\&AElig;/�/g;
    $a =~ s/\&aelig;/�/g;

    $a =~ s/\&Ccedil;/�/g;
    $a =~ s/\&ccedil;/�/g;

    $a =~ s/\&ETH;/�/g;
    $a =~ s/\&eth;/�/g;

    $a =~ s/\&Eacute;/�/g;
    $a =~ s/\&eacute;/�/g;
    $a =~ s/\&Egrave;/�/g;
    $a =~ s/\&egrave;/�/g;
    $a =~ s/\&Ecirc;/�/g;
    $a =~ s/\&ecirc;/�/g;
    $a =~ s/\&Euml;/�/g;
    $a =~ s/\&euml;/�/g;

    $a =~ s/\&Iacute;/�/g;
    $a =~ s/\&iacute;/�/g;
    $a =~ s/\&Igrave;/�/g;
    $a =~ s/\&igrave;/�/g;
    $a =~ s/\&Icirc;/�/g;
    $a =~ s/\&icirc;/�/g;
    $a =~ s/\&Iuml;/�/g;
    $a =~ s/\&iuml;/�/g;

    $a =~ s/\&Ntilde;/�/g;
    $a =~ s/\&ntilde;/�/g;

    $a =~ s/\&Oacute;/�/g;
    $a =~ s/\&oacute;/�/g;
    $a =~ s/\&Ograve;/�/g;
    $a =~ s/\&ograve;/�/g;
    $a =~ s/\&Ocirc;/�/g;
    $a =~ s/\&ocirc;/�/g;
    $a =~ s/\&Ouml;/�/g;
    $a =~ s/\&ouml;/�/g;
    $a =~ s/\&Otilde;/�/g;
    $a =~ s/\&otilde;/�/g;
    $a =~ s/\&Oslash;/�/g;
    $a =~ s/\&oslash;/�/g;

    $a =~ s/\&szlig;/�/g;

    $a =~ s/\&THORN;/�/g;
    $a =~ s/\&thorn;/�/g;

    $a =~ s/\&Uacute;/�/g;
    $a =~ s/\&uacute;/�/g;
    $a =~ s/\&Ugrave;/�/g;
    $a =~ s/\&ugrave;/�/g;
    $a =~ s/\&Ucirc;/�/g;
    $a =~ s/\&ucirc;/�/g;
    $a =~ s/\&Uuml;/�/g;
    $a =~ s/\&uuml;/�/g;

    $a =~ s/\&Yacute;/�/g;
    $a =~ s/\&yacute;/�/g;
    $a =~ s/\&yuml;/�/g;

    print $a;
}
