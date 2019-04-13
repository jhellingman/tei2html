% Roughly based on ISO 259 as described on https://en.wikipedia.org/wiki/Romanization_of_Hebrew

@patterns 0

"<HET>"  1 "<foreign lang='he-Latn'>"
"<HET2>" 1 ""

@rpatterns 1

"</HET>"  0 "</foreign>"
"</HET2>" 0 ""
"<"		 2 "<"

" "      p " "                  % space.

"'"      p "&apos;"           	% א
"b"      p "b"            		% ב
"b."     p "&bbarb;"            % ב
"g"      p "&gmacr;"          	% ג
"g."     p "g"          		% ג
"#g"     p "&gcaron;"           % ג
"d"      p "&dbarb;"          	% ד
"d."     p "d"          		% ד
"#d."    p "&dbarb;"          	% ד
"h"      p "h"             		% ה
"h."     p "h"             		% ה
"v"      p "w"            		% ו
"v."     p "ww"            		% ו
"z"      p "z"          		% ז
"z."     p "zz"          		% ז
"#z"     p "&zcaron;"          	% ז
"H"      p "&hdotb;"            % ח
"T"      p "&tdotb;"            % ט
"T."     p "&tdotb;&tdotb;"   	% ט
"y"      p "y"            		% י
"y."     p "yy"            		% י
"k/"     p "&kbarb;"       		% ך
"k/."    p "k"       			% ך
"k"      p "&kbarb;"            % כ
"k."     p "k"            		% כ
"l"      p "l"          		% ל
"l."     p "ll"          		% ל
"m/"     p "m"       			% ם
"m"      p "m"            		% מ
"m."     p "mm"            		% מ
"n/"     p "n"       			% ן
"n"      p "n"            		% נ
"n."     p "nn"            		% נ
"s"      p "s"         			% ס
"s."     p "ss"         		% ס
"`"      p "&ayin;"           	% ע
"p/"     p "&pmacr;"        	% ף
"p"      p "&pmacr;"            % פ
"p/."    p "p"        			% ף
"p."     p "p"             		% פ
"x/"     p "&sdotb;"     		% ץ
"x"      p "&sdotb;"          	% צ
"x."     p "&sdotb;&sdotb;"     % צ
"#x/"    p "&ccaron;"     		% ץ
"#x"     p "&ccaron;"          	% צ
"q"      p "q"            		% ק
"q."     p "qq"            		% ק
"r"      p "r"           		% ר
"r."     p "rr"           		% ר
"S"      p "&scaron;"           % ש
"S."     p "&scaron;&scaron;"   % ש
"t"      p "&tbarb;"            % ת
"t."     p "t"            		% ת
"#t"     p "&tbar;"             % ת

"^e"     p "&schwa;"          	% ְ
"e:"     p "&ebrev;"     		% ֱ
"a:"     p "&abrev;"     		% ֲ
"o:"     p "&obrev;"    		% ֳ
"i"      p "i"          		% ִ
"E"      p "&emacr;"          	% ֵ
"e"      p "e"          		% ֶ
"a"      p "a"          		% ַ
"o"      p "o"         			% ָ
"O"      p "&omacr;"          	% ֹ
"u"      p "u"         			% ֻ
"."      p ""         			% ּ

"_"      p "-"          		% ־

"S/"     p "&scaron;"    		% שׁ
"S/."    p "&scaron;&scaron;"   % שׁ
"S\\"    p "&sacute;"     		% שׂ
"S\\."   p "&sacute;&sacute;"   % שׂ

"#"      p "&#x05F3;"    		% ׳
"\""     p "&#x05F4;"     		% ״

"{.}"    p "."		% 
"{,}"    p ","		% 
"{:}"    p ":"		% 
"{'}"    p "'"     	% 
"{\"}"   p "\""   	% 
"{/}"    p "/"   	% 
"--"     p "&mdash;"

"\n"	p "\n"

% unused characters should give error message

"A"     e "unknown Hebrew transcription A"
"B"     e "unknown Hebrew transcription B"
"C"     e "unknown Hebrew transcription C"
"c"     e "unknown Hebrew transcription c"
"D"     e "unknown Hebrew transcription D"
"F"     e "unknown Hebrew transcription F"
"f"     e "unknown Hebrew transcription f"
"G"     e "unknown Hebrew transcription G"
"I"     e "unknown Hebrew transcription I"
"J"     e "unknown Hebrew transcription J"
"j"     e "unknown Hebrew transcription j"
"K"     e "unknown Hebrew transcription K"
"L"     e "unknown Hebrew transcription L"
"M"     e "unknown Hebrew transcription M"
"N"     e "unknown Hebrew transcription N"
"P"     e "unknown Hebrew transcription P"
"Q"     e "unknown Hebrew transcription Q"
"R"     e "unknown Hebrew transcription R"
"U"     e "unknown Hebrew transcription U"
"V"     e "unknown Hebrew transcription V"
"W"     e "unknown Hebrew transcription W"
"w"     e "unknown Hebrew transcription w"
"X"     e "unknown Hebrew transcription X"
"Y"     e "unknown Hebrew transcription Y"
"Z"     e "unknown Hebrew transcription Z"

"0"     e "digit 0 in Hebrew transcription"
"1"     e "digit 1 in Hebrew transcription"
"2"     e "digit 2 in Hebrew transcription"
"3"     e "digit 3 in Hebrew transcription"
"4"     e "digit 4 in Hebrew transcription"
"5"     e "digit 5 in Hebrew transcription"
"6"     e "digit 6 in Hebrew transcription"
"7"     e "digit 7 in Hebrew transcription"
"8"     e "digit 8 in Hebrew transcription"
"9"     e "digit 9 in Hebrew transcription"

@patterns 2

">"		1 ">"

@end