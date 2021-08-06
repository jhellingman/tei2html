% Roughly based on ISO 259 as described on https://en.wikipedia.org/wiki/Romanization_of_Hebrew

@patterns 0

"<HET>"  1 "<foreign lang='he-Latn'>"
"<HET2>" 1 ""

@rpatterns 1

"</HET>"  0 "</foreign>"
"</HET2>" 0 ""
"<"      2 "<"

" "      p " "                  % space.

"'"      p "&apos;"             % א
"b"      p "b"                  % ב
"b."     p "&bbarb;"            % ב
"g"      p "&gmacr;"            % ג
"g."     p "g"                  % ג
"#g"     p "&gcaron;"           % ג
"d"      p "&dbarb;"            % ד
"d."     p "d"                  % ד
"#d."    p "&dbarb;"            % ד
"h"      p "h"                  % ה
"h."     p "h"                  % ה
"v"      p "w"                  % ו
"v."     p "ww"                 % ו
"z"      p "z"                  % ז
"z."     p "zz"                 % ז
"#z"     p "&zcaron;"           % ז
"H"      p "&hdotb;"            % ח
"T"      p "&tdotb;"            % ט
"T."     p "&tdotb;&tdotb;"     % ט
"y"      p "y"                  % י
"y."     p "yy"                 % י
"k/"     p "&kbarb;"            % ך
"k/."    p "k"                  % ך
"k"      p "&kbarb;"            % כ
"k."     p "k"                  % כ
"l"      p "l"                  % ל
"l."     p "ll"                 % ל
"m/"     p "m"                  % ם
"m"      p "m"                  % מ
"m."     p "mm"                 % מ
"n/"     p "n"                  % ן
"n"      p "n"                  % נ
"n."     p "nn"                 % נ
"s"      p "s"                  % ס
"s."     p "ss"                 % ס
"`"      p "&ayin;"             % ע
"p/"     p "&pmacr;"            % ף
"p"      p "&pmacr;"            % פ
"p/."    p "p"                  % ף
"p."     p "p"                  % פ
"x/"     p "&sdotb;"            % ץ
"x"      p "&sdotb;"            % צ
"x."     p "&sdotb;&sdotb;"     % צ
"#x/"    p "&ccaron;"           % ץ
"#x"     p "&ccaron;"           % צ
"q"      p "q"                  % ק
"q."     p "qq"                 % ק
"r"      p "r"                  % ר
"r."     p "rr"                 % ר
"S"      p "&scaron;"           % ש
"S."     p "&scaron;&scaron;"   % ש
"t"      p "&tbarb;"            % ת
"t."     p "t"                  % ת
"#t"     p "&tbar;"             % ת

"^e"     p "&schwa;"            % ְ
"e:"     p "&ebrev;"            % ֱ
"a:"     p "&abrev;"            % ֲ
"o:"     p "&obrev;"            % ֳ
"i"      p "i"                  % ִ
"E"      p "&emacr;"            % ֵ
"e"      p "e"                  % ֶ
"a"      p "a"                  % ַ
"o"      p "o"                  % ָ
"O"      p "&omacr;"            % ֹ
"u"      p "u"                  % ֻ
"."      p ""                   % ּ

"_"      p "-"                  % ־

"S/"     p "&scaron;"           % שׁ
"S/."    p "&scaron;&scaron;"   % שׁ
"S\\"    p "&sacute;"           % שׂ
"S\\."   p "&sacute;&sacute;"   % שׂ

"#"      p "&#x05F3;"           % ׳
"\""     p "&#x05F4;"           % ״

"{.}"    p "."
"{-}"    p "-"
"{,}"    p ","
"{:}"    p ":"
"{'}"    p "'"
"{\"}"   p "\""
"{/}"    p "/"
"{[}"    p "["
"{]}"    p "]"
"--"     p "&mdash;"

"\n"    p "\n"

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

"0"     p "0"
"1"     p "1"
"2"     p "2"
"3"     p "3"
"4"     p "4"
"5"     p "5"
"6"     p "6"
"7"     p "7"
"8"     p "8"
"9"     p "9"

"&"     3 "&"

@patterns 2

">"     1 ">"

@patterns 3

";"     1 ";"

@end