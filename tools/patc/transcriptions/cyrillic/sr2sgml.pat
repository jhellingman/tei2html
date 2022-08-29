% Cyrillic (Serbian) in my transcription to ISO SGML entities.

@patterns 0

"<SR>"      1 "<foreign lang='sr'>"

@patterns 1

"&"         2 "&"       % jump over SGML entities in source;
"<"         3 "<"       % jump over SGML tags.

"</SR>"     0 "</foreign>"

"{}"        f           % use for disambiguation

% Capital letters.

"A"         p "&Acy;"     % 0x0410    CYRILLIC CAPITAL LETTER A
"B"         p "&Bcy;"     % 0x0411    CYRILLIC CAPITAL LETTER BE
"V"         p "&Vcy;"     % 0x0412    CYRILLIC CAPITAL LETTER VE
"G"         p "&Gcy;"     % 0x0413    CYRILLIC CAPITAL LETTER GHE
"D"         p "&Dcy;"     % 0x0414    CYRILLIC CAPITAL LETTER DE
"DJ"        p "&DJcy;"    % 0x0402    CYRILLIC CAPITAL LETTER DJE
"Dj"        p "&DJcy;"    % 0x0402    CYRILLIC CAPITAL LETTER DJE
"E"         p "&IEcy;"    % 0x0415    CYRILLIC CAPITAL LETTER IE
"ZH"        p "&ZHcy;"    % 0x0416    CYRILLIC CAPITAL LETTER ZHE
"Zh"        p "&ZHcy;"    % 0x0416    CYRILLIC CAPITAL LETTER ZHE
"Z"         p "&Zcy;"     % 0x0417    CYRILLIC CAPITAL LETTER ZE
"I"         p "&Icy;"     % 0x0418    CYRILLIC CAPITAL LETTER I
"J"         p "&Jsercy;"  % 0x0408    CYRILLIC CAPITAL LETTER JE
"K"         p "&Kcy;"     % 0x041A    CYRILLIC CAPITAL LETTER KA
"L"         p "&Lcy;"     % 0x041B    CYRILLIC CAPITAL LETTER EL
"LJ"        p "&LJcy;"    % 0x0409    CYRILLIC CAPITAL LETTER LJE
"Lj"        p "&LJcy;"    % 0x0409    CYRILLIC CAPITAL LETTER LJE
"M"         p "&Mcy;"     % 0x041C    CYRILLIC CAPITAL LETTER EM
"N"         p "&Ncy;"     % 0x041D    CYRILLIC CAPITAL LETTER EN
"NJ"        p "&NJcy;"    % 0x040A    CYRILLIC CAPITAL LETTER NJE
"Nj"        p "&NJcy;"    % 0x040A    CYRILLIC CAPITAL LETTER NJE
"O"         p "&Ocy;"     % 0x041E    CYRILLIC CAPITAL LETTER O
"P"         p "&Pcy;"     % 0x041F    CYRILLIC CAPITAL LETTER PE
"R"         p "&Rcy;"     % 0x0420    CYRILLIC CAPITAL LETTER ER
"S"         p "&Scy;"     % 0x0421    CYRILLIC CAPITAL LETTER ES
"T"         p "&Tcy;"     % 0x0422    CYRILLIC CAPITAL LETTER TE
"TSH"       p "&TSHch;"   % 0x040B    CYRILLIC CAPITAL LETTER TSHE
"Tsh"       p "&TSHch;"   % 0x040B    CYRILLIC CAPITAL LETTER TSHE
"U"         p "&Ucy;"     % 0x0423    CYRILLIC CAPITAL LETTER U
"F"         p "&Fcy;"     % 0x0424    CYRILLIC CAPITAL LETTER EF
"KH"        p "&KHcy;"    % 0x0425    CYRILLIC CAPITAL LETTER HA
"Kh"        p "&KHcy;"    % 0x0425    CYRILLIC CAPITAL LETTER HA
"TS"        p "&TScy;"    % 0x0426    CYRILLIC CAPITAL LETTER TSE
"Ts"        p "&TScy;"    % 0x0426    CYRILLIC CAPITAL LETTER TSE
"CH"        p "&CHcy;"    % 0x0427    CYRILLIC CAPITAL LETTER CHE
"Ch"        p "&CHcy;"    % 0x0427    CYRILLIC CAPITAL LETTER CHE
"DZ"        p "&DZcy;"    % 0x040F    CYRILLIC CAPITAL LETTER DZHE
"Dz"        p "&DZcy;"    % 0x040F    CYRILLIC CAPITAL LETTER DZHE
"SH"        p "&SHcy;"    % 0x0428    CYRILLIC CAPITAL LETTER SHA
"Sh"        p "&SHcy;"    % 0x0428    CYRILLIC CAPITAL LETTER SHA


% Lower-case letters.

"a"         p "&acy;"     % 0x0430    CYRILLIC SMALL LETTER A
"b"         p "&bcy;"     % 0x0431    CYRILLIC SMALL LETTER BE
"v"         p "&vcy;"     % 0x0432    CYRILLIC SMALL LETTER VE
"g"         p "&gcy;"     % 0x0433    CYRILLIC SMALL LETTER GHE
"d"         p "&dcy;"     % 0x0434    CYRILLIC SMALL LETTER DE
"dj"        p "&djcy;"    % 0x0452    CYRILLIC SMALL LETTER DJE
"e"         p "&iecy;"    % 0x0435    CYRILLIC SMALL LETTER IE
"zh"        p "&zhcy;"    % 0x0436    CYRILLIC SMALL LETTER ZHE
"z"         p "&zcy;"     % 0x0437    CYRILLIC SMALL LETTER ZE
"i"         p "&icy;"     % 0x0438    CYRILLIC SMALL LETTER I
"j"         p "&jsercy;"  % 0x0458    CYRILLIC SMALL LETTER JE
"k"         p "&kcy;"     % 0x043A    CYRILLIC SMALL LETTER KA
"l"         p "&lcy;"     % 0x043B    CYRILLIC SMALL LETTER EL
"lj"        p "&ljcy;"    % 0x0459    CYRILLIC SMALL LETTER LJE
"m"         p "&mcy;"     % 0x043C    CYRILLIC SMALL LETTER EM
"n"         p "&ncy;"     % 0x043D    CYRILLIC SMALL LETTER EN
"nj"        p "&njcy;"    % 0x045A    CYRILLIC SMALL LETTER NJE
"o"         p "&ocy;"     % 0x043E    CYRILLIC SMALL LETTER O
"p"         p "&pcy;"     % 0x043F    CYRILLIC SMALL LETTER PE
"r"         p "&rcy;"     % 0x0440    CYRILLIC SMALL LETTER ER
"s"         p "&scy;"     % 0x0441    CYRILLIC SMALL LETTER ES
"t"         p "&tcy;"     % 0x0442    CYRILLIC SMALL LETTER TE
"tsh"       p "&tshcy;"   % 0x045B    CYRILLIC SMALL LETTER TSHE
"u"         p "&ucy;"     % 0x0443    CYRILLIC SMALL LETTER U
"f"         p "&fcy;"     % 0x0444    CYRILLIC SMALL LETTER EF
"kh"        p "&khcy;"    % 0x0445    CYRILLIC SMALL LETTER HA
"ts"        p "&tscy;"    % 0x0446    CYRILLIC SMALL LETTER TSE
"ch"        p "&chcy;"    % 0x0447    CYRILLIC SMALL LETTER CHE
"dz"        p "&dzcy;"    % 0x045F    CYRILLIC SMALL LETTER DZHE
"sh"        p "&shcy;"    % 0x0448    CYRILLIC SMALL LETTER SHA

@patterns 2  % jumping SGML entities in source

";"         1 ";"               % end of entity: jump back
"</SR>"     0 ";</foreign>"     % closing Cyrillic early. Forgive.
" "         1 " "               % something unexpected, also jump back.

@patterns 3 % SGML-tags in Cyrillic environment

">"         1 ">"

@end
