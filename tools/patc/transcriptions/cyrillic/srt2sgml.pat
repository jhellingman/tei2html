% Cyrillic (Serbian) in my transcription to ISO SGML entities.

@patterns 0

"<SRT>"      1 "<foreign lang='sr-Latn'>"

@patterns 1

"&"         2 "&"       % jump over SGML entities in source;
"<"         3 "<"       % jump over SGML tags.

"</SRT>"     0 "</foreign>"

"{}"        f           % use for disambiguation

% Capital letters.

"A"         p "A"           % 0x0410    CYRILLIC CAPITAL LETTER A
"B"         p "B"           % 0x0411    CYRILLIC CAPITAL LETTER BE
"V"         p "V"           % 0x0412    CYRILLIC CAPITAL LETTER VE
"G"         p "G"           % 0x0413    CYRILLIC CAPITAL LETTER GHE
"D"         p "D"           % 0x0414    CYRILLIC CAPITAL LETTER DE
"DJ"        p "&#x0110;"    % 0x0402    CYRILLIC CAPITAL LETTER DJE
"Dj"        p "&#x0110;"    % 0x0402    CYRILLIC CAPITAL LETTER DJE
"E"         p "E"           % 0x0415    CYRILLIC CAPITAL LETTER IE
"ZH"        p "&#x017D;"    % 0x0416    CYRILLIC CAPITAL LETTER ZHE
"Zh"        p "&#x017D;"    % 0x0416    CYRILLIC CAPITAL LETTER ZHE
"Z"         p "Z"           % 0x0417    CYRILLIC CAPITAL LETTER ZE
"I"         p "I"           % 0x0418    CYRILLIC CAPITAL LETTER I
"J"         p "J"           % 0x0408    CYRILLIC CAPITAL LETTER JE
"K"         p "K"           % 0x041A    CYRILLIC CAPITAL LETTER KA
"L"         p "L"           % 0x041B    CYRILLIC CAPITAL LETTER EL
"LJ"        p "LJ"          % 0x0409    CYRILLIC CAPITAL LETTER LJE
"Lj"        p "Lj"          % 0x0409    CYRILLIC CAPITAL LETTER LJE
"M"         p "M"           % 0x041C    CYRILLIC CAPITAL LETTER EM
"N"         p "N"           % 0x041D    CYRILLIC CAPITAL LETTER EN
"NJ"        p "NJ"          % 0x040A    CYRILLIC CAPITAL LETTER NJE
"Nj"        p "Nj"          % 0x040A    CYRILLIC CAPITAL LETTER NJE
"O"         p "O"           % 0x041E    CYRILLIC CAPITAL LETTER O
"P"         p "P"           % 0x041F    CYRILLIC CAPITAL LETTER PE
"R"         p "R"           % 0x0420    CYRILLIC CAPITAL LETTER ER
"S"         p "S"           % 0x0421    CYRILLIC CAPITAL LETTER ES
"T"         p "T"           % 0x0422    CYRILLIC CAPITAL LETTER TE
"TSH"       p "&#x0106;"    % 0x040B    CYRILLIC CAPITAL LETTER TSHE
"Tsh"       p "&#x0106;"    % 0x040B    CYRILLIC CAPITAL LETTER TSHE
"U"         p "U"           % 0x0423    CYRILLIC CAPITAL LETTER U
"F"         p "F"           % 0x0424    CYRILLIC CAPITAL LETTER EF
"KH"        p "H"           % 0x0425    CYRILLIC CAPITAL LETTER HA
"Kh"        p "H"           % 0x0425    CYRILLIC CAPITAL LETTER HA
"TS"        p "C"           % 0x0426    CYRILLIC CAPITAL LETTER TSE
"Ts"        p "C"           % 0x0426    CYRILLIC CAPITAL LETTER TSE
"CH"        p "&#x010C;"    % 0x0427    CYRILLIC CAPITAL LETTER CHE
"Ch"        p "&#x010C;"    % 0x0427    CYRILLIC CAPITAL LETTER CHE
"DZ"        p "&#x01C4;"    % 0x040F    CYRILLIC CAPITAL LETTER DZHE
"Dz"        p "&#x01C5;"    % 0x040F    CYRILLIC CAPITAL LETTER DZHE
"SH"        p "&#x0160;"    % 0x0428    CYRILLIC CAPITAL LETTER SHA
"Sh"        p "&#x0160;"    % 0x0428    CYRILLIC CAPITAL LETTER SHA


% Lower-case letters.

"a"         p "a"           % 0x0430    CYRILLIC SMALL LETTER A
"b"         p "b"           % 0x0431    CYRILLIC SMALL LETTER BE
"v"         p "v"           % 0x0432    CYRILLIC SMALL LETTER VE
"g"         p "g"           % 0x0433    CYRILLIC SMALL LETTER GHE
"d"         p "d"           % 0x0434    CYRILLIC SMALL LETTER DE
"dj"        p "&#x0111;"    % 0x0452    CYRILLIC SMALL LETTER DJE
"e"         p "e"           % 0x0435    CYRILLIC SMALL LETTER IE
"zh"        p "&#x017E;"    % 0x0436    CYRILLIC SMALL LETTER ZHE
"z"         p "z"           % 0x0437    CYRILLIC SMALL LETTER ZE
"i"         p "i"           % 0x0438    CYRILLIC SMALL LETTER I
"j"         p "j"           % 0x0458    CYRILLIC SMALL LETTER JE
"k"         p "k"           % 0x043A    CYRILLIC SMALL LETTER KA
"l"         p "l"           % 0x043B    CYRILLIC SMALL LETTER EL
"lj"        p "lj"          % 0x0459    CYRILLIC SMALL LETTER LJE
"m"         p "m"           % 0x043C    CYRILLIC SMALL LETTER EM
"n"         p "n"           % 0x043D    CYRILLIC SMALL LETTER EN
"nj"        p "nj"          % 0x045A    CYRILLIC SMALL LETTER NJE
"o"         p "o"           % 0x043E    CYRILLIC SMALL LETTER O
"p"         p "p"           % 0x043F    CYRILLIC SMALL LETTER PE
"r"         p "r"           % 0x0440    CYRILLIC SMALL LETTER ER
"s"         p "s"           % 0x0441    CYRILLIC SMALL LETTER ES
"t"         p "t"           % 0x0442    CYRILLIC SMALL LETTER TE
"tsh"       p "&#x0107;"    % 0x045B    CYRILLIC SMALL LETTER TSHE
"u"         p "u"           % 0x0443    CYRILLIC SMALL LETTER U
"f"         p "f"           % 0x0444    CYRILLIC SMALL LETTER EF
"kh"        p "h"           % 0x0445    CYRILLIC SMALL LETTER HA
"ts"        p "c"           % 0x0446    CYRILLIC SMALL LETTER TSE
"ch"        p "&#x010D;"    % 0x0447    CYRILLIC SMALL LETTER CHE
"dz"        p "&#x01C6;"    % 0x045F    CYRILLIC SMALL LETTER DZHE
"sh"        p "&#x0161;"    % 0x0448    CYRILLIC SMALL LETTER SHA

@patterns 2  % jumping SGML entities in source

";"         1 ";"               % end of entity: jump back
"</SRT>"    0 ";</foreign>"     % closing Cyrillic early. Forgive.
" "         1 " "               % something unexpected, also jump back.

@patterns 3 % SGML-tags in Cyrillic environment

">"         1 ">"

@end
