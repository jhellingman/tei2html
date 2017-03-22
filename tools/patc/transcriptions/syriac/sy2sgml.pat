% sy2sgml.pat   -- patterns to translate of Syriac to Unicode (XML Entity notation)
%
% see also: 
%   http://www.unicode.org/charts/PDF/U0700.pdf
%   http://www.omniglot.com/writing/syriac.htm
%   https://en.wikipedia.org/wiki/Syriac_alphabet
%   http://ctan.sharelatex.com/tex-archive/language/aramaic/serto/sertodoc.pdf
%   http://geonames.nga.mil/gns/html/Romanization/Modern_Syriac_Romanization_System_2011.pdf


@patterns 0

"<SY>"      1 "<foreign lang=syc>"
"</SY>"     e "</SY> in Roman mode!"

"<SYA>"     1 ""
"</SYA>"    e "</SYA> in Roman mode!"

@rpatterns 1

"&"         2 "&"           % copy entity.

"</SY>"     0 "&lrm;</foreign>"
"<SY>"      e "<SY> om Syriac mode!!!"

"</SYA>"    0 "&lrm;"
"<SYA>"     e "<SYA> om Syriac mode!!!"

"-"         f               % hyphen disambiguates encoding, should disappear
"--"        p "&mdash;"

"\n"        p "\n"
" "         p " "
"."         p "."

% punctuation marks:

"::"        p "&#x0700;"    % SYRIAC END OF PARAGRAPH
"."         p "&#x0701;"    % SYRIAC SUPRALINEAR FULL STOP
"_."        p "&#x0702;"    % SYRIAC SUBLINEAR FULL STOP
":"         p "&#x0703;"    % SYRIAC SUPRALINEAR COLON
"_:"        p "&#x0704;"    % SYRIAC SUBLINEAR COLON
".."        p "&#x0705;"    % SYRIAC HORIZONTAL COLON
":\\"       p "&#x0706;"    % SYRIAC COLON SKEWED LEFT
"_:/"       p "&#x0707;"    % SYRIAC COLON SKEWED RIGHT
":\"        p "&#x0708;"    % SYRIAC SUPRALINEAR COLON SKEWED LEFT
"_:\\"      p "&#x0709;"    % SYRIAC SUBLINEAR COLON SKEWED RIGHT
"-:"        p "&#x070A;"    % SYRIAC CONTRACTION
"-."        p "&#x070B;"    % SYRIAC HARKLEAN OBELUS
".\"        p "&#x070C;"    % SYRIAC HARKLEAN METOBELUS
".+."       p "&#x070C;"    % SYRIAC HARKLEAN ASTERISCUS

"("         p "("   
")"         p ")"   

% letters

"'"         p "&#x0710;"    % SYRIAC LETTER ALAPH
"^'"        p "&#x0711;"    % SYRIAC LETTER SUPERSCRIPT ALAPH
"b"         p "&#x0712;"    % SYRIAC LETTER BETH
"g"         p "&#x0713;"    % SYRIAC LETTER GAMAL
"G*"        p "&#x0714;"    % SYRIAC LETTER GAMAL GARSHUNI
"d"         p "&#x0715;"    % SYRIAC LETTER DALATH
"R"         p "&#x0716;"    % SYRIAC LETTER DOTLESS DALATH RISH
"h"         p "&#x0717;"    % SYRIAC LETTER HE
"w"         p "&#x0718;"    % SYRIAC LETTER WAW
"z"         p "&#x0719;"    % SYRIAC LETTER ZAIN
"H"         p "&#x071A;"    % SYRIAC LETTER HETH
"T"         p "&#x071B;"    % SYRIAC LETTER TETH
"T*"        p "&#x071C;"    % SYRIAC LETTER TETH GARSHUNI
"y"         p "&#x071D;"    % SYRIAC LETTER YUDH
"Y"         p "&#x071E;"    % SYRIAC LETTER YUDH HE
"k"         p "&#x071F;"    % SYRIAC LETTER KAPH
"l"         p "&#x0720;"    % SYRIAC LETTER LAMADH
"m"         p "&#x0721;"    % SYRIAC LETTER MIM
"n"         p "&#x0722;"    % SYRIAC LETTER NUN
"s"         p "&#x0723;"    % SYRIAC LETTER SEMKATH
"s\"        p "&#x0724;"    % SYRIAC LETTER FINAL SEMKATH
"`"         p "&#x0725;"    % SYRIAC LETTER E
"p"         p "&#x0726;"    % SYRIAC LETTER PE
"P"         p "&#x0727;"    % SYRIAC LETTER REVERSED PE
"S"         p "&#x0728;"    % SYRIAC LETTER SADHE
"q"         p "&#x0729;"    % SYRIAC LETTER QAPH
"r"         p "&#x072A;"    % SYRIAC LETTER RISH
"sh"        p "&#x072B;"    % SYRIAC LETTER SHIN
"t"         p "&#x072C;"    % SYRIAC LETTER TAW

% Persian letters

"B"         p "&#x072D;"    % SYRIAC LETTER PERSIAN BHETH
"G"         p "&#x072E;"    % SYRIAC LETTER PERSIAN GHAMAL
"D"         p "&#x072F;"    % SYRIAC LETTER PERSIAN DHALATH

% Syriac vowel points

% Western Syriac convention:

"=a"        p "&#x0733;"    % SYRIAC ZQAPHA ABOVE
"a"         p "&#x0730;"    % SYRIAC PTHAHA ABOVE
"e"         p "&#x0736;"    % SYRIAC RBASA ABOVE
"i"         p "&#x073A;"    % SYRIAC HBASA ABOVE
"u"         p "&#x073D;"    % SYRIAC ESASA ABOVE
"x"         p "&#x0747;"    % SYRIAC OBLIQUE LINE ABOVE

"=A"        p "&#x0734;"    % SYRIAC ZQAPHA BELOW
"A"         p "&#x0731;"    % SYRIAC PTHAHA BELOW
"E"         p "&#x0737;"    % SYRIAC RBASA BELOW
"I"         p "&#x073B;"    % SYRIAC HBASA BELOW
"U"         p "&#x073E;"    % SYRIAC ESASA BELOW
"X"         p "&#x0748;"    % SYRIAC OBLIQUE LINE BELOW

% Syriac marks

"F"         p "&#x0740;"    % SYRIAC FEMININE DOT
"Q"         p "&#x0741;"    % SYRIAC QUSHSHAYA (plosive; "hard")
"+"         p "&#x0742;"    % SYRIAC RUKKAKHA (aspirated; "soft")

% Syriac hard letters (doubled) begadkepat
% 
% "bb"        p "&#x0712;&#x0741;"    % SYRIAC LETTER BETH + SYRIAC QUSHSHAYA
% "gg"        p "&#x0713;&#x0741;"    % SYRIAC LETTER GAMAL + SYRIAC QUSHSHAYA
% "dd"        p "&#x0715;&#x0741;"    % SYRIAC LETTER DALATH + SYRIAC QUSHSHAYA
% "kk"        p "&#x071F;&#x0741;"    % SYRIAC LETTER KAPH + SYRIAC QUSHSHAYA
% "pp"        p "&#x0726;&#x0741;"    % SYRIAC LETTER PE + SYRIAC QUSHSHAYA
% "tt"        p "&#x072C;&#x0741;"    % SYRIAC LETTER TAW + SYRIAC QUSHSHAYA
% 
% Syriac soft letters (letter + rukkakha)
% 
% "v"         p "&#x0712;&#x0742;"    % SYRIAC LETTER BETH + SYRIAC RUKKAKHA
% "gh"        p "&#x0713;&#x0742;"    % SYRIAC LETTER GAMAL + SYRIAC RUKKAKHA
% "dh"        p "&#x0715;&#x0742;"    % SYRIAC LETTER DALATH + SYRIAC RUKKAKHA
% "kh"        p "&#x071F;&#x0742;"    % SYRIAC LETTER KAPH + SYRIAC RUKKAKHA
% "f"         p "&#x0726;&#x0742;"    % SYRIAC LETTER PE + SYRIAC RUKKAKHA
% "th"        p "&#x072C;&#x0742;"    % SYRIAC LETTER TAW + SYRIAC RUKKAKHA


@patterns 2 % copy entity in Syriac mode

";"         1 ";"

" "         e "space in entity!"

@end
