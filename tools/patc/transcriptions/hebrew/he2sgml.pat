
@patterns 0

"<HE>"  1 "<foreign lang='he'>&rlm;"
"<HE2>" 1 "&rlm;"

@rpatterns 1

"</HE>"  0 "&lrm;</foreign>"
"</HE2>" 0 "&lrm;"
"<"      2 "<"

" "      p " "                  % space.

"'"      p "&healef;"           % א
"b"      p "&hebet;"            % ב
"g"      p "&hegimel;"          % ג
"d"      p "&hedalet;"          % ד
"h"      p "&hehe;"             % ה
"v"      p "&hevav;"            % ו
"z"      p "&hezayin;"          % ז
"H"      p "&hehet;"            % ח
"T"      p "&hetet;"            % ט
"y"      p "&heyod;"            % י
"k/"     p "&hefinalkaf;"       % ך
"k"      p "&hekaf;"            % כ
"l"      p "&helamed;"          % ל
"m/"     p "&hefinalmem;"       % ם
"m"      p "&hemem;"            % מ
"n/"     p "&hefinalnun;"       % ן
"n"      p "&henun;"            % נ
"s"      p "&hesamekh;"         % ס
"`"      p "&heayin;"           % ע
"p/"     p "&hefinalpe;"        % ף
"p"      p "&hepe;"             % פ
"x/"     p "&hefinaltsadi;"     % ץ
"x"      p "&hetsadi;"          % צ
"q"      p "&heqof;"            % ק
"r"      p "&heresh;"           % ר
"S"      p "&heshin;"           % ש
"t"      p "&hetav;"            % ת

"^e"     p "&hesheva;"          %  ְ
"e:"     p "&hehatafsegol;"     %  ֱ
"a:"     p "&hehatafpatah;"     %  ֲ
"o:"     p "&hehatafqamats;"    %  ֳ
"i"      p "&hehiriq;"          %  ִ
"E"      p "&hetsere;"          %  ֵ
"e"      p "&hesegol;"          %  ֶ
"a"      p "&hepatah;"          %  ַ
"o"      p "&heqamats;"         %  ָ
"O"      p "&heholam;"          %  ֹ
"u"      p "&hequbuts;"         %  ֻ
"."      p "&hedagesh;"         %  ּ

"_"      p "&hemaqaf;"          % ־

"S/"     p "&heshin;&heshindot;"    % שׁ
"S\\"    p "&heshin;&hesindot;"     % שׂ

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
"{(}"    p "("
"{)}"    p ")"
"--"     p "&mdash;"

"'="     p "&#xFB21;"           % wide alef
"d="     p "&#xFB22;"           % wide dalet
"h="     p "&#xFB23;"           % wide he
"k="     p "&#xFB24;"           % wide kaf
"l="     p "&#xFB25;"           % wide lamed
"m/="    p "&#xFB26;"           % wide final mem
"r="     p "&#xFB27;"           % wide resh
"t="     p "&#xFB28;"           % wide tav

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