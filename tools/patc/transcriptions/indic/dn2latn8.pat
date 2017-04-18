% dn2latn8.pat -- convert Indic script text in Extended Velthuis transliteration
%                to Unicode Latin transcription in XML entities (Hindi/Marathi/Nepali/Sanskrit)
% Copyright 2003 Jeroen Hellingman
%
% This file is to be used with the pattern-converter utility patc.
%
% patc -p dn2latn8.pat file.dn file.usc
%
% modes/pattern sets
%  0 - roman text
%  1 - Extended Velthuis transcription, primary position
%  2 - Extended Velthuis transcription, secondary position

@patterns 0 roman text

% EVH language tags (use TEI <foreign> tags)

"<HI>"      1 "<foreign lang=hi-Latn>"
"<MA>"      1 "<foreign lang=ma-Latn>"
"<NP>"      1 "<foreign lang=np-Latn>"
"<SA>"      1 "<foreign lang=sa-Latn>"

% all others go thru unaltered

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

@patterns 1 Velthuis transcription, primary position
"\\"        t               copy TeX commands
"{}"        f               used for disambiguating transcription
"^"         f               used to indicate capital letters in Roman transcription

"&#"        2 "&#"          copy numeric SGML entity.

"%"         c
"<"         0 "<"           RESYNC
">"         0 ">"           RESYNC

"</HI>"     0 "</foreign>"
"</MA>"     0 "</foreign>"
"</NP>"     0 "</foreign>"
"</SA>"     0 "</foreign>"

% vowels, use full vowel, stay in primary mode
"*"         p ""                    EVH silent a -- should not appear initially
"a"         p "a"
"!a"        p "a"                   EVH Kashmiri a -- becomes a
"\"a"       p "&aelig;"             EVH Singhala ae -- becomes a
"aa"        p "á"
"A"         p "á"
"!aa"       p "á"             EVH Kashmiri aa -- becomes aa
"!A"        p "á"             EVH Kashmiri aa -- becomes aa
"\"aa"      p "&aeligmacr;"         EVH Singhala aeae -- becomes aa
"\"A"       p "&aeligmacr;"         EVH Singhala aeae -- becomes aa
"i"         p "i"
"ii"        p "í"
"I"         p "í"
"u"         p "u"
"~u"        p "&ubreve;"            EVH Malayalam half u -- becomes u halant (should not appear initially!)
"\"u"       p "u"                   EVH Kashmiri u -> u
"uu"        p "ú"
"U"         p "ú"
"\"uu"      p "ú"             EVH Kashmiri uu -> uu
"\"U"       p "í"             EVH Kashmiri uu -> uu
".r"        p "&rdotb;i"
".R"        p "&rdotb;í"
".l"        p "&ldotb;i"
".L"        p "&ldtobmacr;í"
"\"e"       p "&ebreve;"            EVH short e
"e"         p "e"
"ai"        p "ai"
"E"         p "ai"
"~a"        p "&abreve;"            English a in Marathi (initially on a)
"~e"        p "&ebreve;"            EVH English a (initially on e) (distinction gets lost)
"\"o"       p "&obreve;"            EVH short o
"o"         p "o"
"au"        p "au"
"O"         p "au"
"~o"        p "&obreve;"            English o in Devanagari

% EVH Urdu ain (appears as a nukta under $a$ or another vowel)

"_a"        p "&adotb;"             EVH
"_aa"       p "&adotbmacr;"         EVH
"_A"        p "&adotbmacr;"         EVH
"_i"        p "&idotb;"             EVH
"_ii"       p "&idotbmacr;"         EVH
"_I"        p "&idotbmacr;"         EVH
"_u"        p "&udotb;"             EVH
"_uu"       p "&udotbmacr;"         EVH
"_U"        p "&udotbmacr;"         EVH

% consonants, go to secondary mode
"k"         p "k"
"q"         p "q"
"kh"        p "kh"
"K"         p "kh"
".kh"       p "&khbarb;"
".K"        p "&khbarb;"
"g"         p "g"
".g"        p "&gbarb;"
"_g"        p "&gdotb;"             EVH Sindhi g with bar below
"gh"        p "gh"
"G"         p "gh"
"\"n"       p "&ndota;"

"c"         p "c"
".c"        p "&cdotb;"             EVH Kashmiri c nukta
"ch"        p "ch"
"C"         p "ch"
".ch"       p "&cdotb;h"            EVH Kashmiri ch nukta
".C"        p "&cdotb;h"            EVH Kashmiri ch nukta
"j"         p "j"
"z"         p "z"
"_j"        p "&jbarb;"             EVH Sindhi j with bar below
"jh"        p "jh"
"J"         p "jh"
"~n"        p "&ntilde;"

".t"        p "&tdotb;"
".th"       p "&tdotb;h"
".T"        p "&tdotb;h"
".d"        p "&ddotb;"
"R"         p "&rdotb;" 
"_d"        p "&dbarb;"             EVH Sindhi .d with bar below
".dh"       p "&ddotb;h"
".D"        p "&ddotb;h"
"Rh"        p "&rdotb;h"
".n"        p "&ndotb;"

"t"         p "t"
"th"        p "th"
"T"         p "th"
"d"         p "d"
"dh"        p "dh"
"D"         p "dh"
"n"         p "n"

"_n"        p "&nbarb;"             EVH Malayalam, Tamil n with bar below (or nukta)

"p"         p "p"
"ph"        p "ph"
"P"         p "ph"
"f"         p "f"
"b"         p "b"
"_b"        p "&bbarb;"             EVH Sindhi b with bar below
"bh"        p "bh"
"B"         p "bh"
"m"         p "m"

"y"         p "y"
".y"        p "&ydota;"             EVH Bengali y with bar below (or nukta)
"r"         p "r"
"\"r"       p "r"                   Marathi eyelash ra
"_r"        p "&rbarb;"             EVH Dravidian ra
"_t"        p "&tbarb;"             EVH Dravidian ra (pronounced as .ta)
"l"         p "l"
"L"         p "&ldotb;"
"\"L"       p "zh"                  EVH Tamil, Malayalam zh
"zh"        p "zh"                  EVH Tamil, Malayalam zh
"v"         p "v"
"\"s"       p "sh"
".s"        p "sh"
"s"         p "s"
"h"         p "h"

% numerals: use Devanagari numerals

"0"         p "0"
"1"         p "1"
"2"         p "2"
"3"         p "3"
"4"         p "4"
"5"         p "5"
"6"         p "6"
"7"         p "7"
"8"         p "8"
"9"         p "9"

% specials: stay in primary mode

".o"        p "&omacr;&mdota;"      OM sign
".a"        p ""                    ahagraha
"@"         p "."                   Abbr. circle

"/"         p "&mdota;"
".m"        p "&mdotb;"
"M"         p "&mdotb;"
".h"        p "&hdotb;"
"H"         p "&hdotb;"

"|"         p "."
"||"        p "."
"&"         p ""                    explicit halant (EVH small change in semantics)
"+"         p ""                    EVH soft halant (force half-letter)

".."        p "."
"#"         p "&middot;"            centered dot

% all other characters go thru unaltered

" "         p " "
","         p ","
";"         p ";"
":"         p ":"
"?"         p "?"
"!"         p "!"
"("         p "("
")"         p ")"
"["         p "["
"]"         p "]"
"{"         p "{"
"}"         p "}"
% "*"       p "*"               EVH no more
"\n"        p "\n"
"\t"        p "\t"
"-"         p "-"
"_"         p "_"
% "+"       p "+"               EVH no more
"="         p "="
"`"         p "`"
"\""        p "\""
"'"         p "'"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

@patterns 2 Numeric SGML entities

";"         1 ";"

@end

% end of dn2latn.pat
