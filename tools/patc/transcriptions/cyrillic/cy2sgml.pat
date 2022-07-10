% Cyrillic in my transcription to ISO SGML entities.

% See also: http://en.wikipedia.org/wiki/Romanization_of_Russian and http://en.wikipedia.org/wiki/ALA-LC_romanization_for_Russian
% Following ALA-LC Romanization tables for Slavic alphabets for generated transcription
% Based on GOST 1971 for ASCII style

@patterns 0

"<CY>"      1 "<foreign>"
"<RU>"      1 "<foreign lang='ru'>"
"<UK>"		1 "<foreign lang='uk'>"
"<RUX>"     1 "<foreign lang='ru-1900'>"
"<RUA>"     1 ""

@patterns 1

"&"         2 "&"       % jump over SGML entities in source;
"<"         3 "<"       % jump over SGML tags.

"</CY>"     0 "</foreign>"
"</RU>"     0 "</foreign>"
"</UK>"     0 "</foreign>"
"</RUX>"    0 "</foreign>"
"</RUA>"    0 ""

"{}"        f           % use for disambuigation

% Capital letters.

"A"         p "&Acy;"     % 0x0410    CYRILLIC CAPITAL LETTER A
"B"         p "&Bcy;"     % 0x0411    CYRILLIC CAPITAL LETTER BE
"V"         p "&Vcy;"     % 0x0412    CYRILLIC CAPITAL LETTER VE
"G"         p "&Gcy;"     % 0x0413    CYRILLIC CAPITAL LETTER GHE
"D"         p "&Dcy;"     % 0x0414    CYRILLIC CAPITAL LETTER DE
"IE"        p "&IEcy;"    % 0x0415    CYRILLIC CAPITAL LETTER IE
"Ie"        p "&IEcy;"    % 0x0415    CYRILLIC CAPITAL LETTER IE
"ZH"        p "&ZHcy;"    % 0x0416    CYRILLIC CAPITAL LETTER ZHE
"Zh"        p "&ZHcy;"    % 0x0416    CYRILLIC CAPITAL LETTER ZHE
"Z"         p "&Zcy;"     % 0x0417    CYRILLIC CAPITAL LETTER ZE
"I"         p "&Icy;"     % 0x0418    CYRILLIC CAPITAL LETTER I
"J"         p "&Jcy;"     % 0x0419    CYRILLIC CAPITAL LETTER SHORT I
"K"         p "&Kcy;"     % 0x041A    CYRILLIC CAPITAL LETTER KA
"L"         p "&Lcy;"     % 0x041B    CYRILLIC CAPITAL LETTER EL
"M"         p "&Mcy;"     % 0x041C    CYRILLIC CAPITAL LETTER EM
"N"         p "&Ncy;"     % 0x041D    CYRILLIC CAPITAL LETTER EN
"O"         p "&Ocy;"     % 0x041E    CYRILLIC CAPITAL LETTER O
"P"         p "&Pcy;"     % 0x041F    CYRILLIC CAPITAL LETTER PE
"R"         p "&Rcy;"     % 0x0420    CYRILLIC CAPITAL LETTER ER
"S"         p "&Scy;"     % 0x0421    CYRILLIC CAPITAL LETTER ES
"T"         p "&Tcy;"     % 0x0422    CYRILLIC CAPITAL LETTER TE
"U"         p "&Ucy;"     % 0x0423    CYRILLIC CAPITAL LETTER U
"F"         p "&Fcy;"     % 0x0424    CYRILLIC CAPITAL LETTER EF
"KH"        p "&KHcy;"    % 0x0425    CYRILLIC CAPITAL LETTER HA
"Kh"        p "&KHcy;"    % 0x0425    CYRILLIC CAPITAL LETTER HA
"TS"        p "&TScy;"    % 0x0426    CYRILLIC CAPITAL LETTER TSE
"Ts"        p "&TScy;"    % 0x0426    CYRILLIC CAPITAL LETTER TSE
"CH"        p "&CHcy;"    % 0x0427    CYRILLIC CAPITAL LETTER CHE
"Ch"        p "&CHcy;"    % 0x0427    CYRILLIC CAPITAL LETTER CHE
"SH"        p "&SHcy;"    % 0x0428    CYRILLIC CAPITAL LETTER SHA
"Sh"        p "&SHcy;"    % 0x0428    CYRILLIC CAPITAL LETTER SHA
"SHCH"      p "&SHCHcy;"  % 0x0429    CYRILLIC CAPITAL LETTER SHCHA
"Shch"      p "&SHCHcy;"  % 0x0429    CYRILLIC CAPITAL LETTER SHCHA
"^''"       p "&HARDcy;"  % 0x042A    CYRILLIC CAPITAL LETTER HARD SIGN
"Y"         p "&Ycy;"     % 0x042B    CYRILLIC CAPITAL LETTER YERU
"^'"        p "&SOFTcy;"  % 0x042C    CYRILLIC CAPITAL LETTER SOFT SIGN
"E"         p "&Ecy;"     % 0x042D    CYRILLIC CAPITAL LETTER E
"YU"        p "&YUcy;"    % 0x042E    CYRILLIC CAPITAL LETTER YU
"Yu"        p "&YUcy;"    % 0x042E    CYRILLIC CAPITAL LETTER YU
"YA"        p "&YAcy;"    % 0x042F    CYRILLIC CAPITAL LETTER YA
"Ya"        p "&YAcy;"    % 0x042F    CYRILLIC CAPITAL LETTER YA
"IO"        p "&IOcy;"    % 0x0401    CYRILLIC CAPITAL LETTER IO
"Io"        p "&IOcy;"    % 0x0401    CYRILLIC CAPITAL LETTER IO

% Lower-case letters.

"a"         p "&acy;"     % 0x0430    CYRILLIC SMALL LETTER A
"b"         p "&bcy;"     % 0x0431    CYRILLIC SMALL LETTER BE
"v"         p "&vcy;"     % 0x0432    CYRILLIC SMALL LETTER VE
"g"         p "&gcy;"     % 0x0433    CYRILLIC SMALL LETTER GHE
"d"         p "&dcy;"     % 0x0434    CYRILLIC SMALL LETTER DE
"ie"        p "&iecy;"    % 0x0435    CYRILLIC SMALL LETTER IE
"zh"        p "&zhcy;"    % 0x0436    CYRILLIC SMALL LETTER ZHE
"z"         p "&zcy;"     % 0x0437    CYRILLIC SMALL LETTER ZE
"i"         p "&icy;"     % 0x0438    CYRILLIC SMALL LETTER I
"j"         p "&jcy;"     % 0x0439    CYRILLIC SMALL LETTER SHORT I
"k"         p "&kcy;"     % 0x043A    CYRILLIC SMALL LETTER KA
"l"         p "&lcy;"     % 0x043B    CYRILLIC SMALL LETTER EL
"m"         p "&mcy;"     % 0x043C    CYRILLIC SMALL LETTER EM
"n"         p "&ncy;"     % 0x043D    CYRILLIC SMALL LETTER EN
"o"         p "&ocy;"     % 0x043E    CYRILLIC SMALL LETTER O
"p"         p "&pcy;"     % 0x043F    CYRILLIC SMALL LETTER PE
"r"         p "&rcy;"     % 0x0440    CYRILLIC SMALL LETTER ER
"s"         p "&scy;"     % 0x0441    CYRILLIC SMALL LETTER ES
"t"         p "&tcy;"     % 0x0442    CYRILLIC SMALL LETTER TE
"u"         p "&ucy;"     % 0x0443    CYRILLIC SMALL LETTER U
"f"         p "&fcy;"     % 0x0444    CYRILLIC SMALL LETTER EF
"kh"        p "&khcy;"    % 0x0445    CYRILLIC SMALL LETTER HA
"ts"        p "&tscy;"    % 0x0446    CYRILLIC SMALL LETTER TSE
"ch"        p "&chcy;"    % 0x0447    CYRILLIC SMALL LETTER CHE
"sh"        p "&shcy;"    % 0x0448    CYRILLIC SMALL LETTER SHA
"shch"      p "&shchcy;"  % 0x0449    CYRILLIC SMALL LETTER SHCHA
"''"        p "&hardcy;"  % 0x044A    CYRILLIC SMALL LETTER HARD SIGN
"y"         p "&ycy;"     % 0x044B    CYRILLIC SMALL LETTER YERU
"'"         p "&softcy;"  % 0x044C    CYRILLIC SMALL LETTER SOFT SIGN
"e"         p "&ecy;"     % 0x044D    CYRILLIC SMALL LETTER E
"yu"        p "&yucy;"    % 0x044E    CYRILLIC SMALL LETTER YU
"ya"        p "&yacy;"    % 0x044F    CYRILLIC SMALL LETTER YA
"io"        p "&iocy;"    % 0x0451    CYRILLIC SMALL LETTER IO

% Obsolete letters

"Ix"        p "&#x0406;"  % 0x0406    CYRILLIC CAPITAL LETTER BYELORUSSIAN-UKRAINIAN I
"Fx"        p "&#x0472;"  % 0x0472    CYRILLIC CAPITAL LETTER FITA
"Ex"        p "&#x0462;"  % 0x0462    CYRILLIC CAPITAL LETTER YAT
"Ux"        p "&#x0474;"  % 0x0474    CYRILLIC CAPITAL LETTER IZHITSA
"IX"        p "&#x0406;"  % 0x0406    CYRILLIC CAPITAL LETTER BYELORUSSIAN-UKRAINIAN I
"FX"        p "&#x0472;"  % 0x0472    CYRILLIC CAPITAL LETTER FITA
"EX"        p "&#x0462;"  % 0x0462    CYRILLIC CAPITAL LETTER YAT
"UX"        p "&#x0474;"  % 0x0474    CYRILLIC CAPITAL LETTER IZHITSA

"ix"        p "&#x0456;"  % 0x0456    CYRILLIC SMALL LETTER BYELORUSSIAN-UKRAINIAN I
"fx"        p "&#x0473;"  % 0x0473    CYRILLIC SMALL LETTER FITA
"ex"        p "&#x0463;"  % 0x0463    CYRILLIC SMALL LETTER YAT
"ux"        p "&#x0475;"  % 0x0475    CYRILLIC SMALL LETTER IZHITSA

% "DJ"        "&DJcy;"    % 0x0402    CYRILLIC CAPITAL LETTER DJE (Serbocroatian)
% "GJ"        "&GJcy;"    % 0x0403    CYRILLIC CAPITAL LETTER GJE
% "IE"        "&Jukcy;"   % 0x0404    CYRILLIC CAPITAL LETTER UKRAINIAN IE
% "DS"        "&DScy;"    % 0x0405    CYRILLIC CAPITAL LETTER DZE
%             "&Iukcy;"   % 0x0406    CYRILLIC CAPITAL LETTER BYELORUSSIAN-UKRAINIAN I
%             "&YIcy;"    % 0x0407    CYRILLIC CAPITAL LETTER YI (Ukrainian)
%             "&Jsercy;"  % 0x0408    CYRILLIC CAPITAL LETTER JE
%             "&LJcy;"    % 0x0409    CYRILLIC CAPITAL LETTER LJE
%             "&NJcy;"    % 0x040A    CYRILLIC CAPITAL LETTER NJE
%             "&TSHch;"   % 0x040B    CYRILLIC CAPITAL LETTER TSHE (Serbocroatian)
%             "&KJcy;"    % 0x040C    CYRILLIC CAPITAL LETTER KJE
%             "&Ubrcy;"   % 0x040E    CYRILLIC CAPITAL LETTER SHORT U (Byelorussian)
%             "&DZcy;"    % 0x040F    CYRILLIC CAPITAL LETTER DZHE

%             "&djcy;"    % 0x0452    CYRILLIC SMALL LETTER DJE (Serbocroatian)
%             "&gjcy;"    % 0x0453    CYRILLIC SMALL LETTER GJE
%             "&jukcy;"   % 0x0454    CYRILLIC SMALL LETTER UKRAINIAN IE
%             "&dscy;"    % 0x0455    CYRILLIC SMALL LETTER DZE
%             "&iukcy;"   % 0x0456    CYRILLIC SMALL LETTER BYELORUSSIAN-UKRAINIAN I
%             "&yicy;"    % 0x0457    CYRILLIC SMALL LETTER YI (Ukrainian)
%             "&jsercy;"  % 0x0458    CYRILLIC SMALL LETTER JE
%             "&ljcy;"    % 0x0459    CYRILLIC SMALL LETTER LJE
%             "&njcy;"    % 0x045A    CYRILLIC SMALL LETTER NJE
%             "&tshcy;"   % 0x045B    CYRILLIC SMALL LETTER TSHE (Serbocroatian)
%             "&kjcy;"    % 0x045C    CYRILLIC SMALL LETTER KJE
%             "&ubrcy;"   % 0x045E    CYRILLIC SMALL LETTER SHORT U (Byelorussian)
%             "&dzcy;"    % 0x045F    CYRILLIC SMALL LETTER DZHE

@patterns 2  % jumping SGML entities in source

";"         1 ";"               % end of entity: jump back
"</CY>"     0 ";</foreign>"     % closing Cyrillic early. Forgive.
"</RU>"     0 ";</foreign>"     % closing Cyrillic early. Forgive.
"</RUX>"    0 ";</foreign>"     % closing Cyrillic early. Forgive.
"</RUA>"    0 ";"               % closing Cyrillic early. Forgive.
" "         1 " "               % something unexpected, also jump back.

@patterns 3 % SGML-tags in Cyrillic environment

">"         1 ">"

@end
