% ar2sgml.pat   -- patterns to translate Yannis Haralambous' transcription of
%                  Arabic, etc. to Unicode (XML Entity notation)
%
% see also: http://utf8-chartable.de/unicode-utf8-table.pl?start=1536&utf8=string-literal

@patterns 0

"<AR>"      1 "<foreign lang=ar>"
"</AR>"     e "</AR> in Roman mode!"

"<ARA>"     1 ""
"</ARA>"    e "</ARA> in Roman mode!"


@rpatterns 1

"&"         2 "&"           % copy entity.
"<"         3 "<"           % copy tag.

"</AR>"     0 "&lrm;</foreign>"
"<AR>"      e "<AR> om Arabic mode!!!"

"</ARA>"    0 "&lrm;"
"<ARA>"     e "<ARA> om Arabic mode!!!"

"-"         f               % hyphen disambiguates encoding, should disappear
"--"        p "&mdash;"

"\n"        p "\n"
" "         p " "
"."         p "."
","         p "&#x060C;"    % ARABIC COMMA
";"         p "&#x061B;"    % ARABIC SEMICOLON
"?"         p "&#x061F;"    % ARABIC QUESTION MARK

"("         p "("   
")"         p ")"   

"_"         p "&#x0640;"    % ARABIC TATWEEL

% The following numbers are appropriate for Arabic:

"0"         p "&#x0660;"    % ARABIC-INDIC DIGIT ZERO
"1"         p "&#x0661;"    % ARABIC-INDIC DIGIT ONE
"2"         p "&#x0662;"    % ARABIC-INDIC DIGIT TWO
"3"         p "&#x0663;"    % ARABIC-INDIC DIGIT THREE
"4"         p "&#x0664;"    % ARABIC-INDIC DIGIT FOUR
"5"         p "&#x0665;"    % ARABIC-INDIC DIGIT FIVE
"6"         p "&#x0666;"    % ARABIC-INDIC DIGIT SIX
"7"         p "&#x0667;"    % ARABIC-INDIC DIGIT SEVEN
"8"         p "&#x0668;"    % ARABIC-INDIC DIGIT EIGHT
"9"         p "&#x0669;"    % ARABIC-INDIC DIGIT NINE

"A"         p "&#x0627;"    % ARABIC LETTER ALEF
"'a"        p "&#x0623;"    % ARABIC LETTER ALEF WITH HAMZA ABOVE
"'i"        p "&#x0625;"    % ARABIC LETTER ALEF WITH HAMZA BELOW
"'A"        p "&#x0622;"    % ARABIC LETTER ALEF WITH MADDA ABOVE
"\"A"       p "&#x0671;"    % ARABIC LETTER ALEF WASLA

"b"         p "&#x0628;"    % ARABIC LETTER BEH
"=b"        p "&#x0628;"    %
"0b"        p "&#x066E;"    % dotless b -> U+066E ARABIC LETTER DOTLESS BEH

"t"         p "&#x062A;"    % ARABIC LETTER TEH
"0t"        p "&#x066E;"    % dotless t -> U+066E ARABIC LETTER DOTLESS BEH

"th"        p "&#x062B;"    % ARABIC LETTER THEH
"0th"       p "&#x066E;"    % dotless th -> U+066E ARABIC LETTER DOTLESS BEH

"p"         p "&#x067E;"    % ARABIC LETTER PEH
"0p"        p "&#x066E;"    % dotless p -> U+066E ARABIC LETTER DOTLESS BEH

"j"         p "&#x062C;"    % ARABIC LETTER JEEM
"0j"        p "&#x062D;"    % dotless j -> U+062D ARABIC LETTER HAH

"H"         p "&#x062D;"    % ARABIC LETTER HAH

"kh"        p "&#x062E;"    % ARABIC LETTER KHAH
"0kh"       p "&#x062D;"    % dotless kh -> U+062D ARABIC LETTER HAH

"ch"        p "&#x0686;"    % ARABIC LETTER TCHEH
"0ch"       p "&#x062D;"    % dotless ch -> U+062D ARABIC LETTER HAH

"d"         p "&#x062F;"    % ARABIC LETTER DAL

"dh"        p "&#x0630;"    % ARABIC LETTER THAL
"0dh"       p "&#x062F;"    % dotless dh -> U+062F ARABIC LETTER DAL

"r"         p "&#x0631;"    % ARABIC LETTER REH

"z"         p "&#x0632;"    % ARABIC LETTER ZAIN
"0z"        p "&#x0631;"    % dotless z -> U+0631 ARABIC LETTER REH

"zh"        p "&#x0698;"    % ARABIC LETTER JEH
"0zh"       p "&#x0631;"    % dotless zh -> U+0631 ARABIC LETTER REH

"s"         p "&#x0633;"    % ARABIC LETTER SEEN

"sh"        p "&#x0634;"    % ARABIC LETTER SHEEN
"0sh"       p "&#x0633;"    % dotless sh -> U+0633 ARABIC LETTER SEEN

"*sh"       p "&#x069C;"    % ARABIC LETTER SEEN WITH THREE DOTS BELOW AND THREE DOTS ABOVE

"S"         p "&#x0635;"    % ARABIC LETTER SAD

"*S"        P "&#x069E;"    % ARABIC LETTER SAD WITH THREE DOTS ABOVE

"D"         p "&#x0636;"    % ARABIC LETTER DAD
"0D"        p "&#x0635;"    % dotless D -> U+0635 ARABIC LETTER SAD

"T"         p "&#x0637;"    % ARABIC LETTER TAH

"Z"         p "&#x0638;"    % ARABIC LETTER ZAH
"0Z"        p "&#x0637;"    % dotless Z -> U+0637 ARABIC LETTER TAH

"`"         p "&#x0639;"    % ARABIC LETTER AIN

"gh"        p "&#x063A;"    % ARABIC LETTER GHAIN
"0gh"       p "&#x0639;"    % dotless gh -> U+0639 ARABIC LETTER AIN

"f"         p "&#x0641;"    % ARABIC LETTER FEH
"=f"        p "&#x0641;"    %
"0f"        p "&#x06A1;"    % dotless f -> U+06A1 ARABIC LETTER DOTLESS FEH
"*f"        p "&#x06A2;"    % ARABIC LETTER FEH WITH DOT MOVED BELOW

"q"         p "&#x0642;"    % ARABIC LETTER QAF
"=q"        p "&#x0642;"    %
"0q"        p "&#x066F;"    % dotless q -> U+066F ARABIC LETTER DOTLESS QAF
"*q"        p "&#x06A7;"    % ARABIC LETTER QAF WITH DOT ABOVE
"*Q"        p "&#x06A8;"    % ARABIC LETTER QAF WITH THREE DOTS ABOVE

"v"         p "&#x06A4;"    % ARABIC LETTER VEH

"k"         p "&#x0643;"    % ARABIC LETTER KAF
"*k"        p "&#x06AE;"    % ARABIC LETTER KAF WITH THREE DOTS BELOW

"g"         p "&#x06AF;"    % ARABIC LETTER GAF

"l"         p "&#x0644;"    % ARABIC LETTER LAM

"m"         p "&#x0645;"    % ARABIC LETTER MEEM

"n"         p "&#x0646;"    % ARABIC LETTER NOON
"=n"        p "&#x0646;"    %
"0n"        p "&#x06BA;"    % dotless n -> U+06BA ARABIC LETTER NOON GHUNNA
"'n"        p "&#x06BA;"    % ARABIC LETTER NOON GHUNNA    Urdu: noon ghunna. (nuun without dot)

"h"         p "&#x0647;"    % ARABIC LETTER HEH                 normally typed as -h except when initial
"x"         p "&#x06C1;"    % ARABIC LETTER HEH GOAL            Urdu: normal heh, instead of do-chasmi heh.
"'h"        p "&#x06BE;"    % ARABIC LETTER HEH DOACHASHMEE     Urdu: do-chasmi heh.

"\"h"       p "&#x0629;"    % ARABIC LETTER TEH MARBUTA
"0\"h"      p "&#x06C1;"    % dotless teh marbuta -> ? U+06C1 ARABIC LETTER HEH GOAL
"\"t"       p "&#x0629;"    %
"0\"t"      p "&#x0629;"    %

"'t"        p "&#x0679;"    % ARABIC LETTER TTEH                Urdu: tteh
"'d"        p "&#x0688;"    % ARABIC LETTER DDAL                Urdu: ddal
"'r"        p "&#x0691;"    % ARABIC LETTER RREH                Urdu: rreh
"'k"        p "&#x06A9;"    % ARABIC LETTER KEHEH

"e"         p "&#x06C0;"    % ARABIC LETTER HEH WITH YEH ABOVE
"U"         p "&#x0648;"    % ARABIC LETTER WAW
"'u"        p "&#x0624;"    % ARABIC LETTER WAW WITH HAMZA ABOVE
"I"         p "&#x0649;"    % ARABIC LETTER ALEF MAKSURA
"y"         p "&#x064A;"    % ARABIC LETTER YEH
"0y"        p "&#x0649;"    % dotless y -> U+0649 ARABIC LETTER ALEF MAKSURA
"'y"        p "&#x0626;"    % ARABIC LETTER YEH WITH HAMZA ABOVE
"||"        p "&#x0621;"    % ARABIC LETTER HAMZA

"E"         p "&#x06D2;"    % ARABIC LETTER YEH BARREE        Urdu: Yeh barree


"LLah"      p "&#xFDF2;"    %
"SLh"       p "&#xFDFA;"    %

"a"         p "&#x064E;"    % ARABIC FATHA
"i"         p "&#x0650;"    % ARABIC KASRA
"u"         p "&#x064F;"    % ARABIC DAMMA
"<>"        p "&#x0652;"    % ARABIC SUKUN
"a|"        p "&#x0670;"    % ARABIC LETTER SUPERSCRIPT ALEF
"aN"        p "&#x064B;"    % ARABIC FATHATAN
"iN"        p "&#x064D;"    % ARABIC KASRATAN
"uN"        p "&#x064C;"    % ARABIC DAMMATAN


% Doubled letters get shadda (Todo for letters without dots and Moroccan letters)
% use dash to avoid this: b-b, etc.

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

"</AR>"     e "</AR> in copy-entity mode!"
"</ARA>"    e "</ARA> in copy-entity mode!"

@patterns 3 % copy tag in Arabic mode

">"         1 ">"

"</AR>"     e "</AR> in copy-tag mode!"
"</ARA>"    e "</ARA> in copy-tag mode!"

@end
