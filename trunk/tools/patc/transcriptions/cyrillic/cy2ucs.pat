% Cyrillic in my transcription to ISO SGML entities.

% See also: http://en.wikipedia.org/wiki/Romanization_of_Russian and http://en.wikipedia.org/wiki/ALA-LC_romanization_for_Russian
% Following ALA-LC Romanization tables for Slavic alphabets for generated transcription
% Based on GOST 1971 for ASCII style

@patterns 0

"<CY>"      1 "<foreign>"
"<RU>"      1 "<foreign lang=ru>"
"<RUA>"     1 ""

@patterns 1

"&"         2 "&"           % jump over SGML entities in source;

"</CY>"     0 "</foreign>"
"</RU>"     0 "</foreign>"
"</RUA>"    0 ""

"{}"        f               % use for disambiguation

"A"         p "&#x0410;"    % CYRILLIC CAPITAL LETTER A 
"B"         p "&#x0411;"    % CYRILLIC CAPITAL LETTER BE 
"V"         p "&#x0412;"    % CYRILLIC CAPITAL LETTER VE 
"G"         p "&#x0413;"    % CYRILLIC CAPITAL LETTER GHE 
"D"         p "&#x0414;"    % CYRILLIC CAPITAL LETTER DE 
"IE"        p "&#x0415;"    % CYRILLIC CAPITAL LETTER IE 
"Ie"        p "&#x0415;"    % CYRILLIC CAPITAL LETTER IE 
"ZH"        p "&#x0416;"    % CYRILLIC CAPITAL LETTER ZHE 
"Zh"        p "&#x0416;"    % CYRILLIC CAPITAL LETTER ZHE 
"Z"         p "&#x0417;"    % CYRILLIC CAPITAL LETTER ZE 
"I"         p "&#x0418;"    % CYRILLIC CAPITAL LETTER I 
"J"         p "&#x0419;"    % CYRILLIC CAPITAL LETTER SHORT I 
"K"         p "&#x041A;"    % CYRILLIC CAPITAL LETTER KA 
"L"         p "&#x041B;"    % CYRILLIC CAPITAL LETTER EL 
"M"         p "&#x041C;"    % CYRILLIC CAPITAL LETTER EM 
"N"         p "&#x041D;"    % CYRILLIC CAPITAL LETTER EN 
"O"         p "&#x041E;"    % CYRILLIC CAPITAL LETTER O 
"P"         p "&#x041F;"    % CYRILLIC CAPITAL LETTER PE 
"R"         p "&#x0420;"    % CYRILLIC CAPITAL LETTER ER 
"S"         p "&#x0421;"    % CYRILLIC CAPITAL LETTER ES 
"T"         p "&#x0422;"    % CYRILLIC CAPITAL LETTER TE 
"U"         p "&#x0423;"    % CYRILLIC CAPITAL LETTER U 
"F"         p "&#x0424;"    % CYRILLIC CAPITAL LETTER EF 
"KH"        p "&#x0425;"    % CYRILLIC CAPITAL LETTER HA 
"Kh"        p "&#x0425;"    % CYRILLIC CAPITAL LETTER HA 
"TS"        p "&#x0426;"    % CYRILLIC CAPITAL LETTER TSE 
"Ts"        p "&#x0426;"    % CYRILLIC CAPITAL LETTER TSE 
"CH"        p "&#x0427;"    % CYRILLIC CAPITAL LETTER CHE 
"Ch"        p "&#x0427;"    % CYRILLIC CAPITAL LETTER CHE 
"SH"        p "&#x0428;"    % CYRILLIC CAPITAL LETTER SHA 
"Sh"        p "&#x0428;"    % CYRILLIC CAPITAL LETTER SHA 
"SHCH"      p "&#x0429;"    % CYRILLIC CAPITAL LETTER SHCHA 
"Shch"      p "&#x0429;"    % CYRILLIC CAPITAL LETTER SHCHA 
"^''"       p "&#x042A;"    % CYRILLIC CAPITAL LETTER HARD SIGN 
"Y"         p "&#x042B;"    % CYRILLIC CAPITAL LETTER YERU 
"^'"        p "&#x042C;"    % CYRILLIC CAPITAL LETTER SOFT SIGN 
"E"         p "&#x042D;"    % CYRILLIC CAPITAL LETTER E 
"YU"        p "&#x042E;"    % CYRILLIC CAPITAL LETTER YU 
"Yu"        p "&#x042E;"    % CYRILLIC CAPITAL LETTER YU 
"YA"        p "&#x042F;"    % CYRILLIC CAPITAL LETTER YA 
"Ya"        p "&#x042F;"    % CYRILLIC CAPITAL LETTER YA 
"IO"        p "&#x0401;"    % CYRILLIC CAPITAL LETTER IO 
"Io"        p "&#x0401;"    % CYRILLIC CAPITAL LETTER IO 

"a"         p "&#x0430;"    % CYRILLIC SMALL LETTER A 
"b"         p "&#x0431;"    % CYRILLIC SMALL LETTER BE 
"v"         p "&#x0432;"    % CYRILLIC SMALL LETTER VE 
"g"         p "&#x0433;"    % CYRILLIC SMALL LETTER GHE 
"d"         p "&#x0434;"    % CYRILLIC SMALL LETTER DE 
"ie"        p "&#x0435;"    % CYRILLIC SMALL LETTER IE 
"zh"        p "&#x0436;"    % CYRILLIC SMALL LETTER ZHE 
"z"         p "&#x0437;"    % CYRILLIC SMALL LETTER ZE 
"i"         p "&#x0438;"    % CYRILLIC SMALL LETTER I 
"j"         p "&#x0439;"    % CYRILLIC SMALL LETTER SHORT I 
"k"         p "&#x043A;"    % CYRILLIC SMALL LETTER KA 
"l"         p "&#x043B;"    % CYRILLIC SMALL LETTER EL 
"m"         p "&#x043C;"    % CYRILLIC SMALL LETTER EM 
"n"         p "&#x043D;"    % CYRILLIC SMALL LETTER EN 
"o"         p "&#x043E;"    % CYRILLIC SMALL LETTER O 
"p"         p "&#x043F;"    % CYRILLIC SMALL LETTER PE 
"r"         p "&#x0440;"    % CYRILLIC SMALL LETTER ER 
"s"         p "&#x0441;"    % CYRILLIC SMALL LETTER ES 
"t"         p "&#x0442;"    % CYRILLIC SMALL LETTER TE 
"u"         p "&#x0443;"    % CYRILLIC SMALL LETTER U 
"f"         p "&#x0444;"    % CYRILLIC SMALL LETTER EF 
"kh"        p "&#x0445;"    % CYRILLIC SMALL LETTER HA 
"ts"        p "&#x0446;"    % CYRILLIC SMALL LETTER TSE 
"ch"        p "&#x0447;"    % CYRILLIC SMALL LETTER CHE 
"sh"        p "&#x0448;"    % CYRILLIC SMALL LETTER SHA 
"shch"      p "&#x0449;"    % CYRILLIC SMALL LETTER SHCHA 
"''"        p "&#x044A;"    % CYRILLIC SMALL LETTER HARD SIGN 
"y"         p "&#x044B;"    % CYRILLIC SMALL LETTER YERU 
"'"         p "&#x044C;"    % CYRILLIC SMALL LETTER SOFT SIGN 
"e"         p "&#x044D;"    % CYRILLIC SMALL LETTER E 
"yu"        p "&#x044E;"    % CYRILLIC SMALL LETTER YU 
"ya"        p "&#x044F;"    % CYRILLIC SMALL LETTER YA 
"yo"        p "&#x0451;"    % CYRILLIC SMALL LETTER IO 

% "DJ"        p "&#x0402;"    % CYRILLIC CAPITAL LETTER DJE (Serbocroatian) 
% "GJ"        p "&#x0403;"    % CYRILLIC CAPITAL LETTER GJE 
% "IE"        p "&#x0404;"    % CYRILLIC CAPITAL LETTER UKRAINIAN IE 
% "DS"        p "&#x0405;"    % CYRILLIC CAPITAL LETTER DZE 
%             p "&#x0406;"    % CYRILLIC CAPITAL LETTER BYELORUSSIAN-UKRAINIAN I 
%             p "&#x0407;"    % CYRILLIC CAPITAL LETTER YI (Ukrainian) 
%             p "&#x0408;"    % CYRILLIC CAPITAL LETTER JE 
%             p "&#x0409;"    % CYRILLIC CAPITAL LETTER LJE 
%             p "&#x040A;"    % CYRILLIC CAPITAL LETTER NJE 
%             p "&#x040B;"    % CYRILLIC CAPITAL LETTER TSHE (Serbocroatian) 
%             p "&#x040C;"    % CYRILLIC CAPITAL LETTER KJE 
%             p "&#x040E;"    % CYRILLIC CAPITAL LETTER SHORT U (Byelorussian) 
%             p "&#x040F;"    % CYRILLIC CAPITAL LETTER DZHE 

%             p "&#x0452;"    % CYRILLIC SMALL LETTER DJE (Serbocroatian) 
%             p "&#x0453;"    % CYRILLIC SMALL LETTER GJE 
%             p "&#x0454;"    % CYRILLIC SMALL LETTER UKRAINIAN IE 
%             p "&#x0455;"    % CYRILLIC SMALL LETTER DZE 
%             p "&#x0456;"    % CYRILLIC SMALL LETTER BYELORUSSIAN-UKRAINIAN I 
%             p "&#x0457;"    % CYRILLIC SMALL LETTER YI (Ukrainian) 
%             p "&#x0458;"    % CYRILLIC SMALL LETTER JE 
%             p "&#x0459;"    % CYRILLIC SMALL LETTER LJE 
%             p "&#x045A;"    % CYRILLIC SMALL LETTER NJE 
%             p "&#x045B;"    % CYRILLIC SMALL LETTER TSHE (Serbocroatian) 
%             p "&#x045C;"    % CYRILLIC SMALL LETTER KJE 
%             p "&#x045E;"    % CYRILLIC SMALL LETTER SHORT U (Byelorussian) 
%             p "&#x045F;"    % CYRILLIC SMALL LETTER DZHE 


% warn for illegal characters

"<"         e "cy2ucs.pat: stand alone <"
"'"         e "cy2ucs.pat: stand alone '"
">"         e "cy2ucs.pat: stand alone >"
"\""        e "cy2ucs.pat: stand alone \""
"`"         e "cy2ucs.pat: stand alone `"
"["         e "cy2ucs.pat: illegal character ["
"]"         e "cy2ucs.pat: illegal character ]"


@patterns 2  % jumping SGML entities in source

";"         1 ";"               % end of entity: jump back
"</CY>"     0 ";</foreign>"     % closing Cyrillic early. Forgive.
"</RU>"     0 ";</foreign>"     % closing Cyrillic early. Forgive.
"</RUA>"    0 ";"               % closing Cyrillic early. Forgive.
" "         1 " "               % something unexpected, also jump back.

@end
