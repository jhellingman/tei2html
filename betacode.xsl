<!DOCTYPE xsl:stylesheet>
<xsl:stylesheet version="3.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="urn:stylesheet-functions"
    xmlns:xd="http://www.pnp-software.com/XSLTdoc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="f xd xs">

    <xd:doc type="stylesheet">
        <xd:short>Stylesheet to convert beta-code to unicode.</xd:short>
        <xd:detail>This stylesheet converts beta-code to unicode; to be applied to strings
            encoded that way.</xd:detail>
        <xd:author>Jeroen Hellingman</xd:author>
        <xd:copyright>2020, Jeroen Hellingman</xd:copyright>
    </xd:doc>

    <xsl:function name="f:beta-to-unicode" as="xs:string">
        <xsl:param name="string" as="xs:string"/>

        <!-- break-up into a sequence of words and non-words -->
        <xsl:variable name="fragments" as="xs:string*">
            <xsl:analyze-string select="lower-case($string)" regex="([,.:; ]+)">
                <xsl:matching-substring><xsl:value-of select="."/></xsl:matching-substring>
                <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>

        <xsl:variable name="result">
            <xsl:for-each select="$fragments">
                <xsl:value-of select="f:beta-fragment-to-unicode(.)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="string-join($result, '')"/>
    </xsl:function>

    <xsl:function name="f:beta-fragment-to-unicode" as="xs:string">
        <xsl:param name="string" as="xs:string"/>

        <!-- deal with final sigma -->
        <xsl:variable name="string" 
            select="if (substring($string, string-length($string)) = 's') then $string || '2' else $string"/>

        <!-- 
            regular expression for a single beta-code character:

            upper case vowel:       ([*][()]?[/=\]?[+]?[aehiouw][|]?)
            lower case vowel:       ([aehiouw][()]?[/=\&]?[+]?[|]?)
            upper case rho:         (r[()]?)
            lower case rho:         ([*][(]?r)
            upper case consonant:   ([*][bgdzhqklmncpstfxv])
            lower case consonant:   ([bgdzhqklmncpstfxv])
            special letter:         (s[1-3])
            special punctuation:    ([:')])

            combined: (s[1-3])|([*][()]?[/=\]?[+]?[aehiouw][|]?)|([aehiouw][()]?[/=\&]?[+]?[|]?)|(r[()]?)|([*][(]?r)|([*][bgdzhqklmncpstfxv])|([bgdzhqklmncpstfxv])|([:')])
            escaped:  (s[1-3])|([*][()]?[/=\\]?[+]?[aehiouw][|]?)|([aehiouw][()]?[/=\\&amp;]?[+]?[|]?)|(r[()]?)|([*][(]?r)|([*][bgdzhqklmncpstfxv])|([bgdzhqklmncpstfxv])|([:')])
        -->

        <xsl:variable name="result" as="xs:string*">
            <xsl:analyze-string select="$string"
                    regex="(s[1-3])|([*][()]?[/=\\]?[+]?[aehiouw][|]?)|([aehiouw][()]?[/=\\&amp;]?[+]?[|]?)|(r[()]?)|([*][(]?r)|([*][bgdzhqklmncpstfxv])|([bgdzhqklmncpstfxv])|([:')])">
                <xsl:matching-substring>
                    <xsl:value-of select="f:lookup-beta(.)"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:variable>

        <xsl:sequence select="string-join($result, '')"/>
    </xsl:function>

    <xsl:function name="f:lookup-beta" as="xs:string">
        <xsl:param name="betacode" as="xs:string"/>

        <xsl:sequence select="if ($map($betacode)) then $map($betacode) else '###' || $betacode || '###' "/>
    </xsl:function>

    <xsl:variable name="map" select="
        map { 
            'a' :     '&#x03b1;',
            'b' :     '&#x03b2;',
            'g' :     '&#x03b3;',
            'd' :     '&#x03b4;',
            'e' :     '&#x03b5;',
            'z' :     '&#x03b6;',
            'h' :     '&#x03b7;',
            'q' :     '&#x03b8;',
            'i' :     '&#x03b9;',
            'k' :     '&#x03ba;',
            'l' :     '&#x03bb;',
            'm' :     '&#x03bc;',
            'n' :     '&#x03bd;',
            'c' :     '&#x03be;',
            'o' :     '&#x03bf;',
            'p' :     '&#x03c0;',
            'r' :     '&#x03c1;',
            's' :     '&#x03c3;',
            's1' :    '&#x03c3;',
            's2' :    '&#x03c2;',
            's3' :    '&#x03f2;',
            't' :     '&#x03c4;',
            'u' :     '&#x03c5;',
            'f' :     '&#x03c6;',
            'x' :     '&#x03c7;',
            'y' :     '&#x03c8;',
            'w' :     '&#x03c9;',

            '*a' :    '&#x0391;',
            '*b' :    '&#x0392;',
            '*g' :    '&#x0393;',
            '*d' :    '&#x0394;',
            '*e' :    '&#x0395;',
            '*z' :    '&#x0396;',
            '*h' :    '&#x0397;',
            '*q' :    '&#x0398;',
            '*i' :    '&#x0399;',
            '*k' :    '&#x039a;',
            '*l' :    '&#x039b;',
            '*m' :    '&#x039c;',
            '*n' :    '&#x039d;',
            '*c' :    '&#x039e;',
            '*o' :    '&#x039f;',
            '*p' :    '&#x03a0;',
            '*r' :    '&#x03a1;',
            '*s' :    '&#x03a3;',
            '*s3' :   '&#x03f9;',
            '*t' :    '&#x03a4;',
            '*u' :    '&#x03a5;',
            '*f' :    '&#x03a6;',
            '*x' :    '&#x03a7;',
            '*y' :    '&#x03a8;',
            '*w' :    '&#x03a9;',

            'a)' :    '&#x1f00;',
            'e)' :    '&#x1f10;',
            'h)' :    '&#x1f20;',
            'i)' :    '&#x1f30;',
            'o)' :    '&#x1f40;',
            'u)' :    '&#x1f50;',
            'w)' :    '&#x1f60;',
            'r)' :    '&#x1fe4;',
            '*)a' :   '&#x1f08;',
            '*)e' :   '&#x1f18;',
            '*)h' :   '&#x1f28;',
            '*)i' :   '&#x1f38;',
            '*)o' :   '&#x1f48;',
            '*)w' :   '&#x1f68;',

            'a(' :    '&#x1f01;',
            'e(' :    '&#x1f11;',
            'h(' :    '&#x1f21;',
            'i(' :    '&#x1f31;',
            'o(' :    '&#x1f41;',
            'u(' :    '&#x1f51;',
            'w(' :    '&#x1f61;',
            'r(' :    '&#x1fe5;',
            '*(a' :   '&#x1f09;',
            '*(e' :   '&#x1f19;',
            '*(h' :   '&#x1f29;',
            '*(i' :   '&#x1f39;',
            '*(o' :   '&#x1f49;',
            '*(u' :   '&#x1f59;',
            '*(w' :   '&#x1f69;',
            '*(r' :   '&#x1fec;',

            'a\' :    '&#x1f70;',
            'a/' :    '&#x1f71;',
            'e\' :    '&#x1f72;',
            'e/' :    '&#x1f73;',
            'h\' :    '&#x1f74;',
            'h/' :    '&#x1f75;',
            'i\' :    '&#x1f76;',
            'i/' :    '&#x1f77;',
            'o\' :    '&#x1f78;',
            'o/' :    '&#x1f79;',
            'u\' :    '&#x1f7a;',
            'u/' :    '&#x1f7b;',
            'w\' :    '&#x1f7c;',
            'w/' :    '&#x1f7d;',
            '*\a' :   '&#x1fba;',
            '*/a' :   '&#x1fbb;',
            '*\e' :   '&#x1fce;',
            '*/e' :   '&#x1fc9;',
            '*\h' :   '&#x1fca;',
            '*/h' :   '&#x1fcb;',
            '*\i' :   '&#x1fda;',
            '*/i' :   '&#x1fdb;',
            '*\o' :   '&#x1ff8;',
            '*/o' :   '&#x1ff9;',
            '*\u' :   '&#x1fea;',
            '*/u' :   '&#x1feb;',
            '*\w' :   '&#x1ffa;',
            '*/w' :   '&#x1ffb;',

            'a)/' :   '&#x1f04;',
            'e)/' :   '&#x1f14;',
            'h)/' :   '&#x1f24;',
            'i)/' :   '&#x1f34;',
            'o)/' :   '&#x1f44;',
            'u)/' :   '&#x1f54;',
            'w)/' :   '&#x1f64;',
            '*)/a' :  '&#x1f0c;',
            '*)/e' :  '&#x1f1c;',
            '*)/h' :  '&#x1f2c;',
            '*)/i' :  '&#x1f3c;',
            '*)/o' :  '&#x1f4c;',
            '*)/u' :  '&#x1f5c;',
            '*)/w' :  '&#x1f6c;',

            'a)\' :   '&#x1f02;',
            'e)\' :   '&#x1f12;',
            'h)\' :   '&#x1f22;',
            'i)\' :   '&#x1f32;',
            'o)\' :   '&#x1f42;',
            'u)\' :   '&#x1f52;',
            'w)\' :   '&#x1f62;',
            '*)\a' :  '&#x1f0a;',
            '*)\e' :  '&#x1f1a;',
            '*)\h' :  '&#x1f2a;',
            '*)\i' :  '&#x1f3a;',
            '*)\o' :  '&#x1f4a;',
            '*)\u' :  '&#x1f5a;',
            '*)\w' :  '&#x1f6a;',

            'a(/' :   '&#x1f05;',
            'e(/' :   '&#x1f15;',
            'h(/' :   '&#x1f25;',
            'i(/' :   '&#x1f35;',
            'o(/' :   '&#x1f45;',
            'u(/' :   '&#x1f55;',
            'w(/' :   '&#x1f65;',
            '*(/a' :  '&#x1f0d;',
            '*(/e' :  '&#x1f1d;',
            '*(/h' :  '&#x1f2d;',
            '*(/i' :  '&#x1f3d;',
            '*(/o' :  '&#x1f4d;',
            '*(/u' :  '&#x1f5d;',
            '*(/w' :  '&#x1f6d;',

            'a(\' :   '&#x1f03;',
            'e(\' :   '&#x1f13;',
            'h(\' :   '&#x1f23;',
            'i(\' :   '&#x1f33;',
            'o(\' :   '&#x1f43;',
            'u(\' :   '&#x1f53;',
            'w(\' :   '&#x1f63;',
            '*(\a' :  '&#x1f0b;',
            '*(\e' :  '&#x1f1b;',
            '*(\h' :  '&#x1f2b;',
            '*(\i' :  '&#x1f3b;',
            '*(\o' :  '&#x1f4b;',
            '*(\u' :  '&#x1f5b;',
            '*(\w' :  '&#x1f6b;',

            'a=' :    '&#x1fb6;',
            'h=' :    '&#x1fc6;',
            'i=' :    '&#x1fd6;',
            'u=' :    '&#x1fe6;',
            'w=' :    '&#x1ff6;',

            'a)=' :   '&#x1f06;',
            'h)=' :   '&#x1f26;',
            'i)=' :   '&#x1f36;',
            'u)=' :   '&#x1f56;',
            'w)=' :   '&#x1f66;',
            '*)=a' :  '&#x1f0e;',
            '*)=h' :  '&#x1f2e;',
            '*)=i' :  '&#x1f3e;',
            '*)=w' :  '&#x1f6e;',

            'a(=' :   '&#x1f07;',
            'h(=' :   '&#x1f27;',
            'i(=' :   '&#x1f37;',
            'u(=' :   '&#x1f57;',
            'w(=' :   '&#x1f67;',
            '*(=a' :  '&#x1f0f;',
            '*(=h' :  '&#x1f2f;',
            '*(=i' :  '&#x1f3f;',
            '*(=u' :  '&#x1f5f;',
            '*(=w' :  '&#x1f6f;',

            'a=|' :   '&#x1fb7;',
            'h=|' :   '&#x1fc7;',
            'w=|' :   '&#x1ff7;',

            'a|' :    '&#x1fb3;',
            'h|' :    '&#x1fc3;',
            'w|' :    '&#x1ff3;',
            '*a|' :   '&#x1fbc;',
            '*h|' :   '&#x1fcc;',
            '*w|' :   '&#x1ffc;',

            'a/|' :   '&#x1fb4;',
            'h/|' :   '&#x1fc4;',
            'w/|' :   '&#x1ff4;',

            'a)|' :   '&#x1f80;',
            'h)|' :   '&#x1f90;',
            'w)|' :   '&#x1fa0;',
            '*)a|' :  '&#x1f88;',
            '*)h|' :  '&#x1f98;',
            '*)w|' :  '&#x1fa8;',

            'a(|' :   '&#x1f81;',
            'h(|' :   '&#x1f91;',
            'w(|' :   '&#x1fa1;',
            '*(a|' :  '&#x1f89;',
            '*(h|' :  '&#x1f99;',
            '*(w|' :  '&#x1fa9;',

            'a)\|' :  '&#x1f82;',
            'h)\|' :  '&#x1f92;',
            'w)\|' :  '&#x1fa2;',
            '*)\a|' : '&#x1f8a;',
            '*)\h|' : '&#x1f9a;',
            '*)\w|' : '&#x1faa;',

            'a(\|' :  '&#x1f83;',
            'h(\|' :  '&#x1f93;',
            'w(\|' :  '&#x1fa3;',
            '*(\a|' : '&#x1f8b;',
            '*(\h|' : '&#x1f9b;',
            '*(\w|' : '&#x1fab;',

            'a)/|' :  '&#x1f84;',
            'h)/|' :  '&#x1f94;',
            'w)/|' :  '&#x1fa4;',
            '*)/a|' : '&#x1f8c;',
            '*)/h|' : '&#x1f9c;',
            '*)/w|' : '&#x1fac;',

            'a(/|' :  '&#x1f85;',
            'h(/|' :  '&#x1f95;',
            'w(/|' :  '&#x1fa5;',
            '*(/a|' : '&#x1f8d;',
            '*(/h|' : '&#x1f9d;',
            '*(/w|' : '&#x1fad;',

            'a)=|' :  '&#x1f86;',
            'h)=|' :  '&#x1f96;',
            'w)=|' :  '&#x1fa6;',
            '*)=a|' : '&#x1f8e;',
            '*)=h|' : '&#x1f9e;',
            '*)=w|' : '&#x1fae;',

            'a(=|' :  '&#x1f87;',
            'h(=|' :  '&#x1f97;',
            'w(=|' :  '&#x1fa7;',
            '*(=a|' : '&#x1f8f;',
            '*(=h|' : '&#x1f9f;',
            '*(=w|' : '&#x1faf;',

            'i+' :    '&#x03ca;',
            '*+i' :   '&#x03aa;',
            'i\+' :   '&#x1fd2;',
            'i/+' :   '&#x1fd3;',
            'i+/' :   '&#x1fd3;',
            'i=+' :   '&#x1fd7;',
            'u+' :    '&#x03cb;',
            '*+u' :   '&#x03ab;',
            'u\+' :   '&#x1fe2;',
            'u/+' :   '&#x1fe3;',
            'u=+' :   '&#x1fe7;',

            'a&amp;' : '&#x1fb0;',
            'i&amp;' : '&#x1fd0;',
            'u&amp;' : '&#x1fe0;',

            'a''' :    '&#x1fb1;',
            'i''' :    '&#x1fd1;',
            'u''' :    '&#x1fe1;',

            ':' :      '&#x00b7;',
            '''' :     '&#x2019;',
            '-' :      '&#x2010;',
            '_' :      '&#x2014;',
            ')' :      '&#x2019;'

        }">      
    </xsl:variable>




</xsl:stylesheet>