% Cyrillic in my transcription to ALA-LC Latin transcription using ISO SGML entities.

% See also: http://en.wikipedia.org/wiki/Romanization_of_Russian and http://en.wikipedia.org/wiki/ALA-LC_romanization_for_Russian
% Following ALA-LC Romanization tables for Slavic alphabets for generated transcription
% Based on GOST 1971 for ASCII style

@patterns 0

"<CY>"      1 "<CYT>"
"<RU>"      1 "<RUT>"
"<RUA>"     1 "<RUAT>"

@patterns 1

"&"         2 "&"           % jump over SGML entities in source;

"</CY>"     0 "</CYT>"
"</RU>"     0 "</RUT>"
"</RUA>"    0 "</RUAT>"

"{}"        f               % use for disambiguation

"A"         p "A"           % CYRILLIC CAPITAL LETTER A 
"B"         p "B"           % CYRILLIC CAPITAL LETTER BE 
"V"         p "V"           % CYRILLIC CAPITAL LETTER VE 
"G"         p "G"           % CYRILLIC CAPITAL LETTER GHE 
"D"         p "D"           % CYRILLIC CAPITAL LETTER DE 
"IE"        p "E"           % CYRILLIC CAPITAL LETTER IE 
"Ie"        p "E"           % CYRILLIC CAPITAL LETTER IE 
"ZH"        p "ZH"          % CYRILLIC CAPITAL LETTER ZHE 
"Zh"        p "Zh"          % CYRILLIC CAPITAL LETTER ZHE 
"Z"         p "Z"           % CYRILLIC CAPITAL LETTER ZE 
"I"         p "I"           % CYRILLIC CAPITAL LETTER I 
"J"         p "&Ibreve;"    % CYRILLIC CAPITAL LETTER SHORT I 
"K"         p "K"           % CYRILLIC CAPITAL LETTER KA 
"L"         p "L"           % CYRILLIC CAPITAL LETTER EL 
"M"         p "M"           % CYRILLIC CAPITAL LETTER EM 
"N"         p "N"           % CYRILLIC CAPITAL LETTER EN 
"O"         p "O"           % CYRILLIC CAPITAL LETTER O 
"P"         p "P"           % CYRILLIC CAPITAL LETTER PE 
"R"         p "R"           % CYRILLIC CAPITAL LETTER ER 
"S"         p "S"           % CYRILLIC CAPITAL LETTER ES 
"T"         p "T"           % CYRILLIC CAPITAL LETTER TE 
"U"         p "U"           % CYRILLIC CAPITAL LETTER U 
"F"         p "F"           % CYRILLIC CAPITAL LETTER EF 
"KH"        p "KH"          % CYRILLIC CAPITAL LETTER HA 
"Kh"        p "Kh"          % CYRILLIC CAPITAL LETTER HA 
"TS"        p "T&#x0361;S"  % CYRILLIC CAPITAL LETTER TSE 
"Ts"        p "T&#x0361;s"  % CYRILLIC CAPITAL LETTER TSE 
"CH"        p "CH"          % CYRILLIC CAPITAL LETTER CHE 
"Ch"        p "Ch"          % CYRILLIC CAPITAL LETTER CHE 
"SH"        p "SH"          % CYRILLIC CAPITAL LETTER SHA 
"Sh"        p "Sh"          % CYRILLIC CAPITAL LETTER SHA 
"SHCH"      p "SHCH"        % CYRILLIC CAPITAL LETTER SHCHA 
"Shch"      p "Shch"        % CYRILLIC CAPITAL LETTER SHCHA 
"^''"       p "&Prime;"     % CYRILLIC CAPITAL LETTER HARD SIGN 
"Y"         p "y"           % CYRILLIC CAPITAL LETTER YERU 
"^'"        p "&prime;"     % CYRILLIC CAPITAL LETTER SOFT SIGN 
"E"         p "&Edota;"     % CYRILLIC CAPITAL LETTER E 
"YU"        p "I&#x0361;U"  % CYRILLIC CAPITAL LETTER YU 
"Yu"        p "I&#x0361;u"  % CYRILLIC CAPITAL LETTER YU 
"YA"        p "I&#x0361;A"  % CYRILLIC CAPITAL LETTER YA 
"Ya"        p "I&#x0361;a"  % CYRILLIC CAPITAL LETTER YA 
"IO"        p "&Euml;"      % CYRILLIC CAPITAL LETTER IO 
"Io"        p "&Euml;"      % CYRILLIC CAPITAL LETTER IO 

"a"         p "a"           % CYRILLIC SMALL LETTER A 
"b"         p "b"           % CYRILLIC SMALL LETTER BE 
"v"         p "v"           % CYRILLIC SMALL LETTER VE 
"g"         p "g"           % CYRILLIC SMALL LETTER GHE 
"d"         p "d"           % CYRILLIC SMALL LETTER DE 
"ie"        p "e"           % CYRILLIC SMALL LETTER IE 
"zh"        p "zh"          % CYRILLIC SMALL LETTER ZHE 
"z"         p "z"           % CYRILLIC SMALL LETTER ZE 
"i"         p "i"           % CYRILLIC SMALL LETTER I 
"j"         p "&ibreve;"    % CYRILLIC SMALL LETTER SHORT I 
"k"         p "k"           % CYRILLIC SMALL LETTER KA 
"l"         p "l"           % CYRILLIC SMALL LETTER EL 
"m"         p "m"           % CYRILLIC SMALL LETTER EM 
"n"         p "n"           % CYRILLIC SMALL LETTER EN 
"o"         p "o"           % CYRILLIC SMALL LETTER O 
"p"         p "p"           % CYRILLIC SMALL LETTER PE 
"r"         p "r"           % CYRILLIC SMALL LETTER ER 
"s"         p "s"           % CYRILLIC SMALL LETTER ES 
"t"         p "t"           % CYRILLIC SMALL LETTER TE 
"u"         p "u"           % CYRILLIC SMALL LETTER U 
"f"         p "f"           % CYRILLIC SMALL LETTER EF 
"kh"        p "kh"          % CYRILLIC SMALL LETTER HA 
"ts"        p "t&#x0361;s"  % CYRILLIC SMALL LETTER TSE 
"ch"        p "ch"          % CYRILLIC SMALL LETTER CHE 
"sh"        p "sh"          % CYRILLIC SMALL LETTER SHA 
"shch"      p "shch"        % CYRILLIC SMALL LETTER SHCHA 
"''"        p "&Prime;"     % CYRILLIC SMALL LETTER HARD SIGN 
"y"         p "y"           % CYRILLIC SMALL LETTER YERU 
"'"         p "&prime;"     % CYRILLIC SMALL LETTER SOFT SIGN 
"e"         p "&edota;"     % CYRILLIC SMALL LETTER E 
"yu"        p "i&#x0361;u"  % CYRILLIC SMALL LETTER YU 
"ya"        p "i&#x0361;a"  % CYRILLIC SMALL LETTER YA 
"yo"        p "&euml;"      % CYRILLIC SMALL LETTER IO 

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

"<"         e "cyt2ucs.pat: stand alone <"
"'"         e "cyt2ucs.pat: stand alone '"
">"         e "cyt2ucs.pat: stand alone >"
"\""        e "cyt2ucs.pat: stand alone \""
"`"         e "cyt2ucs.pat: stand alone `"
"["         e "cyt2ucs.pat: illegal character ["
"]"         e "cyt2ucs.pat: illegal character ]"


@patterns 2  % jumping SGML entities in source

";"         1 ";"           % end of entity: jump back
"</CY>"     0 ";</CUT>"     % closing Cyrillic early. Forgive.
"</RU>"     0 ";</RUT>"     % closing Cyrillic early. Forgive.
"</RUA>"    0 ";</RUAT>"    % closing Cyrillic early. Forgive.
" "         1 " "           % something unexpected, also jump back.

@end
