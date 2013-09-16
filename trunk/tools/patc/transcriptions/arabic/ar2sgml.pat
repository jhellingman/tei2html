% ar2sgml.pat   -- patterns to translate Yannis Haralambous' transcription of
%                  Arabic, Persian, Urdu, etc. to Unicode (XML Entity notation)

@patterns 0

"<AR>"      1 "<foreign lang=ar>"
"</AR>"     e "</AR> in Roman mode!"

"<UR>"      1 "<foreign lang=ur>"
"</UR>"     e "</UR> in Roman mode!"


@rpatterns 1

"&"         2 "&"       % copy entity.

"</AR>"     0 "</foreign>"
"<AR>"      e "<AR> om Arabic mode!!!"

"</UR>"     0 "</foreign>"
"<UR>"      e "<UR> om Arabic mode!!!"

"\n"        p "\n"
" "         p " "
"."         p "."
","         p "&#x060C;"
";"         p "&#x061B;"
"?"         p "&#x061F;"

"0"         p "&#x06F0;"
"1"         p "&#x06F1;"
"2"         p "&#x06F2;"
"3"         p "&#x06F3;"
"4"         p "&#x06F4;"
"5"         p "&#x06F5;"
"6"         p "&#x06F6;"
"7"         p "&#x06F7;"
"8"         p "&#x06F8;"
"9"         p "&#x06F9;"

"-"         f               % hyphen disambiguates encoding, should disappear

"A"         p "&#x0627;"
"'a"        p "&#x0623;"
"'i"        p "&#x0625;"
"'A"        p "&#x0622;"
"\"A"       p "&#x0671;"
"b"         p "&#x0628;"
"=b"        p "&#x0628;"
"0b"        p "&#x0628;"    % undotted b
"t"         p "&#x062A;"
"0t"        p "&#x062A;"    % undotted t
"th"        p "&#x062B;"
"0th"       p "&#x062B;"    % undotted th
"p"         p "&#x067E;"
"0p"        p "&#x067E;"    % undotted p
"j"         p "&#x062C;"
"0j"        p "&#x062C;"
"H"         p "&#x062D;"
"kh"        p "&#x062E;"
"0kh"       p "&#x062E;"    % undotted kh
"ch"        p "&#x0686;"
"0ch"       p "&#x0686;"    % undotted ch
"d"         p "&#x062F;"
"dh"        p "&#x0630;"
"0dh"       p "&#x0630;"    % undotted dh
"r"         p "&#x0631;"
"z"         p "&#x0632;"
"0z"        p "&#x0632;"    % undotted z
"zh"        p "&#x0698;"
"0zh"       p "&#x0698;"    % undotted zh
"s"         p "&#x0633;"
"sh"        p "&#x0634;"
"0sh"       p "&#x0634;"
"*sh"       p "&#x069C;"
"S"         p "&#x0635;"
"*S"        P "&#x069E;"
"D"         p "&#x0636;"
"0D"        p "&#x0636;"
"T"         p "&#x0637;"
"Z"         p "&#x0638;"
"0Z"        p "&#x0638;"
"`"         p "&#x0639;"
"gh"        p "&#x063A;"
"0gh"       p "&#x063A;"
"f"         p "&#x0641;"
"=f"        p "&#x0641;"
"0f"        p "&#x0641;"
"*f"        p "&#x06A2;"
"q"         p "&#x0642;"
"=q"        p "&#x0642;"
"0q"        p "&#x0642;"
"*q"        p "&#x06A7;"
"*Q"        p "&#x06A8;"
"v"         p "&#x06A4;"
"k"         p "&#x0643;"
"*k"        p "&#x06AE;"
"g"         p "&#x06AF;"
"l"         p "&#x0644;"
"m"         p "&#x0645;"
"n"         p "&#x0646;"
"=n"        p "&#x0646;"
"0n"        p "&#x0646;"
"'n"        p "&#x06BA;"        % Urdu: noon ghunna. (nuun without dot)
"h"         p "&#x0647;"        % normally typed as -h except when initial
"x"         p "&#x06C1;"        % Urdu: normal heh, instead of do-chasmi heh.

"\"h"       p "&#x0629;"
"0\"h"      p "&#x0629;"
"\"t"       p "&#x0629;"
"0\"t"      p "&#x0629;"

"'t"        p "&#x0679;"        % Urdu: tteh
"'d"        p "&#x0688;"        % Urdu: ddal
"'r"        p "&#x0691;"        % Urdu: rreh

"e"         p "&#x06C0;"
"U"         p "&#x0648;"
"'u"        p "&#x0624;"
"I"         p "&#x0649;"
"y"         p "&#x064A;"
"0y"        p "&#x064A;"
"'y"        p "&#x0626;"
"||"        p "&#x0621;"

"E"         p "&#x06D2;"        % Urdu: Yeh barree


"LLah"      p "&#xFDF2;"
"SLh"       p "&#xFDFA;"

"a"         p "&#x064E;"
"i"         p "&#x0650;"
"u"         p "&#x064F;"
"<>"        p "&#x0652;"
"a|"        p "&#x0670;"
"aN"        p "&#x064B;"
"iN"        p "&#x064D;"
"uN"        p "&#x064C;"

% doubled letters get shadda (Todo for letters without dots and Moroccan letters)

"bb"        p "&#x0628;&#x0651;"
"tt"        p "&#x062A;&#x0651;"
"thth"      p "&#x062B;&#x0651;"
"pp"        p "&#x067E;&#x0651;"
"jj"        p "&#x062C;&#x0651;"
"HH"        p "&#x062D;&#x0651;"
"khkh"      p "&#x062E;&#x0651;"
"chch"      p "&#x0686;&#x0651;"
"dd"        p "&#x062F;&#x0651;"
"dhdh"      p "&#x0630;&#x0651;"
"rr"        p "&#x0631;&#x0651;"
"zz"        p "&#x0632;&#x0651;"
"zhzh"      p "&#x0698;&#x0651;"
"ss"        p "&#x0633;&#x0651;"
"shsh"      p "&#x0634;&#x0651;"
"SS"        p "&#x0635;&#x0651;"
"DD"        p "&#x0636;&#x0651;"
"TT"        p "&#x0637;&#x0651;"
"ZZ"        p "&#x0638;&#x0651;"
"``"        p "&#x0639;&#x0651;"
"ghgh"      p "&#x063A;&#x0651;"
"ff"        p "&#x0641;&#x0651;"
"qq"        p "&#x0642;&#x0651;"
"vv"        p "&#x06A4;&#x0651;"
"kk"        p "&#x0643;&#x0651;"
"gg"        p "&#x06AF;&#x0651;"
"ll"        p "&#x0644;&#x0651;"
"mm"        p "&#x0645;&#x0651;"
"nn"        p "&#x0646;&#x0651;"
"'n'n"      p "&#x06BA;&#x0651;"
"hh"        p "&#x0647;&#x0651;"
"UU"        p "&#x0648;&#x0651;"
"II"        p "&#x0649;&#x0651;"
"yy"        p "&#x064A;&#x0651;"

@patterns 2 % copy entity in Arabic mode

";"         1 ";"

" "         e "space in entity!"

@end

