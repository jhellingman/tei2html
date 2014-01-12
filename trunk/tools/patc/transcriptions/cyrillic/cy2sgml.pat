% Cyrillic in my transcription to ISO SGML entities.

% See also: http://en.wikipedia.org/wiki/Romanization_of_Russian and http://en.wikipedia.org/wiki/ALA-LC_romanization_for_Russian
% Following ALA-LC Romanization tables for Slavic alphabets for generated transcription
% Based on GOST 1971 for ASCII style

@patterns 0

"<RU>"      1 "<foreign lang=ru>"
"<RUA>"     1 ""

@patterns 1

"&"         2 "&"       % jump over SGML entities in source;

"</RU>"     0 "</foreign>"
"</RUA>"    0 ""

"{}"        f           % use for disambuigation

"A"         "&Acy;"     % 0x0410    CYRILLIC CAPITAL LETTER A 
"B"         "&Bcy;"     % 0x0411    CYRILLIC CAPITAL LETTER BE 
"V"         "&Vcy;"     % 0x0412    CYRILLIC CAPITAL LETTER VE 
"G"         "&Gcy;"     % 0x0413    CYRILLIC CAPITAL LETTER GHE 
"D"         "&Dcy;"     % 0x0414    CYRILLIC CAPITAL LETTER DE 
"IE"        "&IEcy;"    % 0x0415    CYRILLIC CAPITAL LETTER IE 
"Ie"        "&IEcy;"    % 0x0415    CYRILLIC CAPITAL LETTER IE 
"ZH"        "&ZHcy;"    % 0x0416    CYRILLIC CAPITAL LETTER ZHE 
"Zh"        "&ZHcy;"    % 0x0416    CYRILLIC CAPITAL LETTER ZHE 
"Z"         "&Zcy;"     % 0x0417    CYRILLIC CAPITAL LETTER ZE 
"I"         "&Icy;"     % 0x0418    CYRILLIC CAPITAL LETTER I 
"J"         "&Jcy;"     % 0x0419    CYRILLIC CAPITAL LETTER SHORT I 
"K"         "&Kcy;"     % 0x041A    CYRILLIC CAPITAL LETTER KA 
"L"         "&Lcy;"     % 0x041B    CYRILLIC CAPITAL LETTER EL 
"M"         "&Mcy;"     % 0x041C    CYRILLIC CAPITAL LETTER EM 
"N"         "&Ncy;"     % 0x041D    CYRILLIC CAPITAL LETTER EN 
"O"         "&Ocy;"     % 0x041E    CYRILLIC CAPITAL LETTER O 
"P"         "&Pcy;"     % 0x041F    CYRILLIC CAPITAL LETTER PE 
"R"         "&Rcy;"     % 0x0420    CYRILLIC CAPITAL LETTER ER 
"S"         "&Scy;"     % 0x0421    CYRILLIC CAPITAL LETTER ES 
"T"         "&Tcy;"     % 0x0422    CYRILLIC CAPITAL LETTER TE 
"U"         "&Ucy;"     % 0x0423    CYRILLIC CAPITAL LETTER U 
"F"         "&Fcy;"     % 0x0424    CYRILLIC CAPITAL LETTER EF 
"KH"        "&KHcy;"    % 0x0425    CYRILLIC CAPITAL LETTER HA 
"Kh"        "&KHcy;"    % 0x0425    CYRILLIC CAPITAL LETTER HA 
"TS"        "&TScy;"    % 0x0426    CYRILLIC CAPITAL LETTER TSE 
"Ts"        "&TScy;"    % 0x0426    CYRILLIC CAPITAL LETTER TSE 
"CH"        "&CHcy;"    % 0x0427    CYRILLIC CAPITAL LETTER CHE 
"Ch"        "&CHcy;"    % 0x0427    CYRILLIC CAPITAL LETTER CHE 
"SH"        "&SHcy;"    % 0x0428    CYRILLIC CAPITAL LETTER SHA 
"Sh"        "&SHcy;"    % 0x0428    CYRILLIC CAPITAL LETTER SHA 
"SHCH"      "&SHCHcy;"  % 0x0429    CYRILLIC CAPITAL LETTER SHCHA 
"Shch"      "&SHCHcy;"  % 0x0429    CYRILLIC CAPITAL LETTER SHCHA 
"^''"       "&HARDcy;"  % 0x042A    CYRILLIC CAPITAL LETTER HARD SIGN 
"Y"         "&Ycy;"     % 0x042B    CYRILLIC CAPITAL LETTER YERU 
"^'"        "&SOFTcy;"  % 0x042C    CYRILLIC CAPITAL LETTER SOFT SIGN 
"E"         "&Ecy;"     % 0x042D    CYRILLIC CAPITAL LETTER E 
"YU"        "&YUcy;"    % 0x042E    CYRILLIC CAPITAL LETTER YU 
"Yu"        "&YUcy;"    % 0x042E    CYRILLIC CAPITAL LETTER YU 
"YA"        "&YAcy;"    % 0x042F    CYRILLIC CAPITAL LETTER YA 
"Ya"        "&YAcy;"    % 0x042F    CYRILLIC CAPITAL LETTER YA 
"IO"        "&IOcy;"    % 0x0401    CYRILLIC CAPITAL LETTER IO 
"Io"        "&IOcy;"    % 0x0401    CYRILLIC CAPITAL LETTER IO 

"a"         "&acy;"     % 0x0430    CYRILLIC SMALL LETTER A 
"b"         "&bcy;"     % 0x0431    CYRILLIC SMALL LETTER BE 
"v"         "&vcy;"     % 0x0432    CYRILLIC SMALL LETTER VE 
"g"         "&gcy;"     % 0x0433    CYRILLIC SMALL LETTER GHE 
"d"         "&dcy;"     % 0x0434    CYRILLIC SMALL LETTER DE 
"ie"        "&iecy;"    % 0x0435    CYRILLIC SMALL LETTER IE 
"zh"        "&zhcy;"    % 0x0436    CYRILLIC SMALL LETTER ZHE 
"z"         "&zcy;"     % 0x0437    CYRILLIC SMALL LETTER ZE 
"i"         "&icy;"     % 0x0438    CYRILLIC SMALL LETTER I 
"j"         "&jcy;"     % 0x0439    CYRILLIC SMALL LETTER SHORT I 
"k"         "&kcy;"     % 0x043A    CYRILLIC SMALL LETTER KA 
"l"         "&lcy;"     % 0x043B    CYRILLIC SMALL LETTER EL 
"m"         "&mcy;"     % 0x043C    CYRILLIC SMALL LETTER EM 
"n"         "&ncy;"     % 0x043D    CYRILLIC SMALL LETTER EN 
"o"         "&ocy;"     % 0x043E    CYRILLIC SMALL LETTER O 
"p"         "&pcy;"     % 0x043F    CYRILLIC SMALL LETTER PE 
"r"         "&rcy;"     % 0x0440    CYRILLIC SMALL LETTER ER 
"s"         "&scy;"     % 0x0441    CYRILLIC SMALL LETTER ES 
"t"         "&tcy;"     % 0x0442    CYRILLIC SMALL LETTER TE 
"u"         "&ucy;"     % 0x0443    CYRILLIC SMALL LETTER U 
"f"         "&fcy;"     % 0x0444    CYRILLIC SMALL LETTER EF 
"kh"        "&khcy;"    % 0x0445    CYRILLIC SMALL LETTER HA 
"ts"        "&tscy;"    % 0x0446    CYRILLIC SMALL LETTER TSE 
"ch"        "&chcy;"    % 0x0447    CYRILLIC SMALL LETTER CHE 
"sh"        "&shcy;"    % 0x0448    CYRILLIC SMALL LETTER SHA 
"shch"      "&shchcy;"  % 0x0449    CYRILLIC SMALL LETTER SHCHA 
"''"        "&hardcy;"  % 0x044A    CYRILLIC SMALL LETTER HARD SIGN 
"y"         "&ycy;"     % 0x044B    CYRILLIC SMALL LETTER YERU 
"'"         "&softcy;"  % 0x044C    CYRILLIC SMALL LETTER SOFT SIGN 
"e"         "&ecy;"     % 0x044D    CYRILLIC SMALL LETTER E 
"yu"        "&yucy;"    % 0x044E    CYRILLIC SMALL LETTER YU 
"ya"        "&yacy;"    % 0x044F    CYRILLIC SMALL LETTER YA 
"yo"        "&iocy;"    % 0x0451    CYRILLIC SMALL LETTER IO 

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


% warn for illegal characters

"<"         e "cy2sgml.pat: stand alone <"
"'"         e "cy2sgml.pat: stand alone '"
">"         e "cy2sgml.pat: stand alone >"
"\""        e "cy2sgml.pat: stand alone \""
"`"         e "cy2sgml.pat: stand alone `"
"["         e "cy2sgml.pat: illegal character ["
"]"         e "cy2sgml.pat: illegal character ]"


@patterns 2  % jumping SGML entities in source

";"         1 ";"               % end of entity: jump back
"</RU>"     0 ";</foreign>"     % closing Cyrillic early. Forgive.
"</RUA>"    0 ";"               % closing Cyrillic early. Forgive.
" "         1 " "               % something unexpected, also jump back.

@end
