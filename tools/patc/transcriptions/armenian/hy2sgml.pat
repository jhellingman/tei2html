% Armenian (Eastern variant) in transcription to SGML entities.
% This notation is adopted from https://translit.cc/am/

@patterns 0

"<HY>"      1 "<foreign lang='hy'>"
"<HYA>"     1 ""


@patterns 1

"&"         2 "&"       % jump over SGML entities in source;

"</HY>"     0 "</foreign>"
"</HYA>"    0 ""

% some TEI tags:
"<g>"               p "<g>"
"<b>"               p "<b>"
"<sc>"              p "<sc>"
"<hi>"              p "<hi>"
"<hi rend=ex>"      p "<hi rend='ex'>"
"<hi rend=sc>"      p "<hi rend='sc'>"
"<hi rend=bold>"    p "<hi rend='bold'>"
"</g>"              p "</g>"
"</b>"              p "</b>"
"</sc>"             p "</sc>"
"</hi>"             p "</hi>"

"<choice>"          p "<choice>"
"</choice>"         p "</choice>"
"<sic>"             p "<sic>"
"</sic>"            p "</sic>"
"<corr>"            p "<corr>"
"</corr>"           p "</corr>"
"<abbr>"            p "<abbr>"
"</abbr>"           p "</abbr>"
"<expan>"           p "<expan>"
"</expan>"          p "</expan>"

"<lg>"              p "<lg>"
"</lg>"             p "</lg>"
"<l>"               p "<l>"
"</l>"              p "</l>"


"A"  p   "&#x531;"    % Ա   Armenian Capital Letter Ayb
"B"  p   "&#x532;"    % Բ   Armenian Capital Letter Ben
"G"  p   "&#x533;"    % Գ   Armenian Capital Letter Gim
"D"  p   "&#x534;"    % Դ   Armenian Capital Letter Da
"E"  p   "&#x535;"    % Ե   Armenian Capital Letter Ech
"Z"  p   "&#x536;"    % Զ   Armenian Capital Letter Za
"E'" p   "&#x537;"    % Է   Armenian Capital Letter Eh
"Y'" p   "&#x538;"    % Ը   Armenian Capital Letter Et
"T'" p   "&#x539;"    % Թ   Armenian Capital Letter To
"JH" p   "&#x53a;"    % Ժ   Armenian Capital Letter Zhe
"I"  p   "&#x53b;"    % Ի   Armenian Capital Letter Ini
"L"  p   "&#x53c;"    % Լ   Armenian Capital Letter Liwn
"X"  p   "&#x53d;"    % Խ   Armenian Capital Letter Xeh
"C'" p   "&#x53e;"    % Ծ   Armenian Capital Letter Ca
"K"  p   "&#x53f;"    % Կ   Armenian Capital Letter Ken
"H"  p   "&#x540;"    % Հ   Armenian Capital Letter Ho
"D'" p   "&#x541;"    % Ձ   Armenian Capital Letter Ja
"GH" p   "&#x542;"    % Ղ   Armenian Capital Letter Ghad
"TW" p   "&#x543;"    % Ճ   Armenian Capital Letter Cheh
"M"  p   "&#x544;"    % Մ   Armenian Capital Letter Men
"Y"  p   "&#x545;"    % Յ   Armenian Capital Letter Yi
"N"  p   "&#x546;"    % Ն   Armenian Capital Letter Now
"SH" p   "&#x547;"    % Շ   Armenian Capital Letter Sha
"O"  p   "&#x548;"    % Ո   Armenian Capital Letter Vo
"CH" p   "&#x549;"    % Չ   Armenian Capital Letter Cha
"P"  p   "&#x54a;"    % Պ   Armenian Capital Letter Peh
"J"  p   "&#x54b;"    % Ջ   Armenian Capital Letter Jheh
"R'" p   "&#x54c;"    % Ռ   Armenian Capital Letter Ra
"S"  p   "&#x54d;"    % Ս   Armenian Capital Letter Seh
"V"  p   "&#x54e;"    % Վ   Armenian Capital Letter Vew
"T"  p   "&#x54f;"    % Տ   Armenian Capital Letter Tiwn
"R"  p   "&#x550;"    % Ր   Armenian Capital Letter Reh
"C"  p   "&#x551;"    % Ց   Armenian Capital Letter Co
"W"  p   "&#x552;"    % Ւ   Armenian Capital Letter Yiwn
"P'" p   "&#x553;"    % Փ   Armenian Capital Letter Piwr
"Q"  p   "&#x554;"    % Ք   Armenian Capital Letter Keh
"O'" p   "&#x555;"    % Օ   Armenian Capital Letter Oh
"F"  p   "&#x556;"    % Ֆ   Armenian Capital Letter Feh

"Jh" p   "&#x53a;"    % Ժ   Armenian Capital Letter Zhe
"Gh" p   "&#x542;"    % Ղ   Armenian Capital Letter Ghad
"Tw" p   "&#x543;"    % Ճ   Armenian Capital Letter Cheh
"Sh" p   "&#x547;"    % Շ   Armenian Capital Letter Sha
"Ch" p   "&#x549;"    % Չ   Armenian Capital Letter Cha

"`"  p   "&#x559;"    % ՙ   Armenian Modifier Letter Left Half Ring
"/"  p   "&#x55a;"    % ՚   Armenian Apostrophe
"#"  p   "&#x55b;"    % ՛   Armenian Emphasis Mark
"!"  p   "&#x55c;"    % ՜   Armenian Exclamation Mark
","  p   "&#x55d;"    % ՝   Armenian Comma
"?"  p   "&#x55e;"    % ՞   Armenian Question Mark
"~"  p   "&#x55f;"    % ՟   Armenian Abbreviation Mark

"a"  p   "&#x561;"    % ա   Armenian Small Letter Ayb
"b"  p   "&#x562;"    % բ   Armenian Small Letter Ben
"g"  p   "&#x563;"    % գ   Armenian Small Letter Gim
"d"  p   "&#x564;"    % դ   Armenian Small Letter Da
"e"  p   "&#x565;"    % ե   Armenian Small Letter Ech
"z"  p   "&#x566;"    % զ   Armenian Small Letter Za
"e'" p   "&#x567;"    % է   Armenian Small Letter Eh
"y'" p   "&#x568;"    % ը   Armenian Small Letter Et
"t'" p   "&#x569;"    % թ   Armenian Small Letter To
"jh" p   "&#x56a;"    % ժ   Armenian Small Letter Zhe
"i"  p   "&#x56b;"    % ի   Armenian Small Letter Ini
"l"  p   "&#x56c;"    % լ   Armenian Small Letter Liwn
"x"  p   "&#x56d;"    % խ   Armenian Small Letter Xeh
"c'" p   "&#x56e;"    % ծ   Armenian Small Letter Ca
"k"  p   "&#x56f;"    % կ   Armenian Small Letter Ken
"h"  p   "&#x570;"    % հ   Armenian Small Letter Ho
"d'" p   "&#x571;"    % ձ   Armenian Small Letter Ja
"gh" p   "&#x572;"    % ղ   Armenian Small Letter Ghad
"tw" p   "&#x573;"    % ճ   Armenian Small Letter Cheh
"m"  p   "&#x574;"    % մ   Armenian Small Letter Men
"y"  p   "&#x575;"    % յ   Armenian Small Letter Yi
"n"  p   "&#x576;"    % ն   Armenian Small Letter Now
"sh" p   "&#x577;"    % շ   Armenian Small Letter Sha
"o"  p   "&#x578;"    % ո   Armenian Small Letter Vo
"ch" p   "&#x579;"    % չ   Armenian Small Letter Cha
"p"  p   "&#x57a;"    % պ   Armenian Small Letter Peh
"j"  p   "&#x57b;"    % ջ   Armenian Small Letter Jheh
"r'" p   "&#x57c;"    % ռ   Armenian Small Letter Ra
"s"  p   "&#x57d;"    % ս   Armenian Small Letter Seh
"v"  p   "&#x57e;"    % վ   Armenian Small Letter Vew
"t"  p   "&#x57f;"    % տ   Armenian Small Letter Tiwn
"r"  p   "&#x580;"    % ր   Armenian Small Letter Reh
"c"  p   "&#x581;"    % ց   Armenian Small Letter Co
"w"  p   "&#x582;"    % ւ   Armenian Small Letter Yiwn
"p'" p   "&#x583;"    % փ   Armenian Small Letter Piwr
"q"  p   "&#x584;"    % ք   Armenian Small Letter Keh
"o'" p   "&#x585;"    % օ   Armenian Small Letter Oh
"f"  p   "&#x586;"    % ֆ   Armenian Small Letter Feh

"&&" p   "&#x587;"    % և   Armenian Small Ligature Ech Yiwn

"."  p   "&#x589;"    % ։   Armenian Full Stop
"-"  p   "&#x58a;"    % ֊   Armenian Hyphen

@patterns 2  % jumping SGML entities in source

";"         1 ";"               % end of entity: jump back
"</HY>"     0 ";</foreign>"     % closing Armenian early. Forgive.
"</HYA>"    0 ";"               % closing Armenian early. Forgive.
" "         1 " "               % something unexpected, also jump back.


@end
