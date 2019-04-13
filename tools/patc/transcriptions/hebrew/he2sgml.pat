
@patterns 0

"<HE>"  1 "<foreign lang='he'>&rlm;"
"<HE2>" 1 "&rlm;"

@rpatterns 1

"</HE>"  0 "&lrm;</foreign>"
"</HE2>" 0 "&lrm;"
"<"		 2 "<"

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

"^e"     p "&hesheva;"          % ְ
"e:"     p "&hehatafsegol;"     % ֱ
"a:"     p "&hehatafpatah;"     % ֲ
"o:"     p "&hehatafqamats;"    % ֳ
"i"      p "&hehiriq;"          % ִ
"E"      p "&hetsere;"          % ֵ
"e"      p "&heseqol;"          % ֶ
"a"      p "&hepatah;"          % ַ
"o"      p "&heqamats;"         % ָ
"O"      p "&heholam;"          % ֹ
"u"      p "&hequbuts;"         % ֻ
"."      p "&hedagesh;"         % ּ

"_"      p "&hemaqaf;"          % ־

"S/"     p "&heshin;&heshindot;"    % שׁ
"S\\"    p "&heshin;&hesindot;"     % שׂ

"#"      p "&#x05F3;"    		% ׳
"\""     p "&#x05F4;"     		% ״

"{.}"    p "."		% 
"{,}"    p ","		% 
"{:}"    p ":"		% 
"{'}"    p "'"     	% 
"{\"}"   p "\""   	% 
"{/}"    p "/"   	% 
"--"     p "&mdash;"

"'="     p "&#xFB21;"      		% wide alef
"d="     p "&#xFB22;"      		% wide dalet
"h="     p "&#xFB23;"      		% wide he
"k="     p "&#xFB24;"      		% wide kaf
"l="     p "&#xFB25;"      		% wide lamed
"m/="    p "&#xFB26;"      		% wide final mem
"r="     p "&#xFB27;"      		% wide resh
"t="     p "&#xFB28;"      		% wide tav

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