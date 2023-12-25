
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
"{...}"  p "&hellip;"
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