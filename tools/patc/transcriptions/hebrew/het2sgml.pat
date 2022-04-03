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

"A"     p "[**unknown Hebrew transcription A]"
"B"     p "[**unknown Hebrew transcription B]"
"C"     p "[**unknown Hebrew transcription C]"
"c"     p "[**unknown Hebrew transcription c]"
"D"     p "[**unknown Hebrew transcription D]"
"F"     p "[**unknown Hebrew transcription F]"
"f"     p "[**unknown Hebrew transcription f]"
"G"     p "[**unknown Hebrew transcription G]"
"I"     p "[**unknown Hebrew transcription I]"
"J"     p "[**unknown Hebrew transcription J]"
"j"     p "[**unknown Hebrew transcription j]"
"K"     p "[**unknown Hebrew transcription K]"
"L"     p "[**unknown Hebrew transcription L]"
"M"     p "[**unknown Hebrew transcription M]"
"N"     p "[**unknown Hebrew transcription N]"
"P"     p "[**unknown Hebrew transcription P]"
"Q"     p "[**unknown Hebrew transcription Q]"
"R"     p "[**unknown Hebrew transcription R]"
"U"     p "[**unknown Hebrew transcription U]"
"V"     p "[**unknown Hebrew transcription V]"
"W"     p "[**unknown Hebrew transcription W]"
"w"     p "[**unknown Hebrew transcription w]"
"X"     p "[**unknown Hebrew transcription X]"
"Y"     p "[**unknown Hebrew transcription Y]"
"Z"     p "[**unknown Hebrew transcription Z]"

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