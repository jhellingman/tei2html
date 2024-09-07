% dn2utf8.pat -- convert Indic script text in Extended Velthuis transliteration
%               to Unicode in UTF8 (Hindi/Marathi/Nepali/Sanskrit)
% Copyright 2003 Jeroen Hellingman
%
% This file is to be used with the pattern-converter utility patc.
%
% patc -p dn2ucs.pat file.dn file.usc
%
% modes/pattern sets
%  0 - roman text
%  1 - Extended Velthuis transcription, primary position
%  2 - Extended Velthuis transcription, secondary position

@patterns 0 roman text
% "$"         1 "<foreign lang=hi>"       switch to indic script

% EVH language tags (use TEI <foreign> tags)

"<HI>"      1 "<foreign lang=hi>"
"<MA>"      1 "<foreign lang=ma>"
"<NP>"      1 "<foreign lang=np>"
"<SA>"      1 "<foreign lang=sa>"

% all others go thru unaltered

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

@patterns 1 Velthuis transcription, primary position
% "$"         0 "</foreign>"  switch back to Roman script
"\\"        t               copy TeX commands
"{}"        f               used for disambiguating transcription
"^"         f               used to indicate capital letters in Roman transcription

"&#"        3 "&#"          copy numeric SGML entity.

"%"         c
"<"         0 "<"           RESYNC
">"         0 ">"           RESYNC

"</HI>"     0 "</foreign>"
"</MA>"     0 "</foreign>"
"</NP>"     0 "</foreign>"
"</SA>"     0 "</foreign>"

% vowels, use full vowel, stay in primary mode
"*"         1 "अ"            EVH silent a -- should not appear initially
"a"         1 "अ"
"!a"        1 "अ"            EVH Kashmiri a -- becomes a
"\"a"       1 "अ"            EVH Singhala ae -- becomes a
"aa"        1 "आ"
"A"         1 "आ"
"!aa"       1 "आ"            EVH Kashmiri aa -- becomes aa
"!A"        1 "आ"            EVH Kashmiri aa -- becomes aa
"\"aa"      1 "आ"            EVH Singhala aeae -- becomes aa
"\"A"       1 "आ"            EVH Singhala aeae -- becomes aa
"i"         1 "इ"
"ii"        1 "ई"
"I"         1 "ई"
"u"         1 "उ"
"~u"        1 "उ्"    EVH Malayalam half u -- becomes u halant (should not appear initially!)
"\"u"       1 "उ"            EVH Kashmiri u -> u
"uu"        1 "ऊ"
"U"         1 "ऊ"
"\"uu"      1 "ऊ"            EVH Kashmiri uu -> uu
"\"U"       1 "ऊ"            EVH Kashmiri uu -> uu
".r"        1 "ऋ"
".R"        1 "ॠ"
".l"        1 "ऌ"
".L"        1 "ॡ"
"\"e"       1 "ऎ"            EVH short e
"e"         1 "ए"
"ai"        1 "ऐ"
"E"         1 "ऐ"
"~a"        1 "अॅ"    English a in Marathi (initially on a)
"~e"        1 "ऍ"            EVH English a (initially on e) (distinction gets lost)
"\"o"       1 "ऒ"            EVH short e
"o"         1 "ओ"
"au"        1 "औ"
"O"         1 "औ"
"~o"        1 "ऑ"            English o in Devanagari

% EVH Urdu ain (appears as a nukta under $a$ or another vowel)

"_a"        1 "अ़"            EVH
"_aa"       1 "आ़"            EVH
"_A"        1 "आ़"            EVH
"_i"        1 "इ़"            EVH
"_a{}i"     1 "अ़ि"    EVH $a$ with nukta and i matra
"_ii"       1 "ई़"            EVH
"_I"        1 "ई़"            EVH
"_a{}ii"    1 "अ़ी"    EVH $a$ with nukta and ii matra
"_a{}I"     1 "अ़ी"    EVH
"_u"        1 "उ़"            EVH
"_uu"       1 "ऊ़"            EVH
"_U"        1 "ऊ़"            EVH

% consonants, go to secondary mode
"k"         2 "क"
"q"         2 "क़"
"kh"        2 "ख"
"K"         2 "ख"
".kh"       2 "ख़"
".K"        2 "ख़"
"g"         2 "ग"
".g"        2 "ग़"
"_g"        2 "ग॒"        EVH Sindhi g with bar below
"gh"        2 "घ"
"G"         2 "घ"
"\"n"       2 "ङ"

"c"         2 "च"
".c"        2 "च़"        EVH Kashmiri c nukta
"ch"        2 "छ"
"C"         2 "छ"
".ch"       2 "छ़"        EVH Kashmiri ch nukta
".C"        2 "छ़"        EVH Kashmiri ch nukta
"j"         2 "ज"
"z"         2 "ज़"
"_j"        2 "ज॒"        EVH Sindhi j with bar below
"jh"        2 "झ"
"J"         2 "झ"
"~n"        2 "ञ"

".t"        2 "ट"
".th"       2 "ठ"
".T"        2 "ठ"
".d"        2 "ड"
"R"         2 "ड़"
"_d"        2 "ड॒"        EVH Sindhi .d with bar below
".dh"       2 "ढ"
".D"        2 "ढ"
"Rh"        2 "ढ़"
".n"        2 "ण"

"t"         2 "त"
"th"        2 "थ"
"T"         2 "थ"
"d"         2 "द"
"dh"        2 "ध"
"D"         2 "ध"
"n"         2 "न"

"_n"        2 "ऩ"                EVH Malayalam, Tamil n with bar below (or nukta)

"p"         2 "प"
"ph"        2 "फ"
"P"         2 "फ"
"f"         2 "फ़"
"b"         2 "ब"
"_b"        2 "ब॒"        EVH Sindhi b with bar below
"bh"        2 "भ"
"B"         2 "भ"
"m"         2 "म"

"y"         2 "य"
".y"        2 "य़"                EVH Bengali y with bar below (or nukta)
"r"         2 "र"
"\"r"       2 "ऱ"                Marathi eyelash ra
"_r"        2 "ऱ"                EVH Dravidian ra
"_t"        2 "ऱ"                EVH Dravidian ra (pronounced as .ta)
"l"         2 "ल"
"L"         2 "ळ"
"\"L"       2 "ऴ"                EVH Tamil, Malayalam zh
"zh"        2 "ऴ"                EVH Tamil, Malayalam zh
"v"         2 "व"
"\"s"       2 "श"
".s"        2 "ष"
"s"         2 "स"
"h"         2 "ह"

% numerals: use Devanagari numerals

"0"         1 "०"
"1"         1 "१"
"2"         1 "२"
"3"         1 "३"
"4"         1 "४"
"5"         1 "५"
"6"         1 "६"
"7"         1 "७"
"8"         1 "८"
"9"         1 "९"

% specials: stay in primary mode

".o"        1 "ॐ"            OM sign
".a"        1 "ऽ"            ahagraha
"@"         1 "॰"            Abbr. circle

"/"         1 "ँ"
".m"        1 "ं"
"M"         1 "ं"
".h"        1 "ः"
"H"         1 "ः"

"|"         1 "।"
"||"        1 "॥"
"&"         1 "्‌"    explicit halant (EVH small change in semantics)
"+"         1 "्‍"    EVH soft halant (force half-letter)

".."        1 "."
"#"         1 "·"            centered dot

% all other characters go thru unaltered

" "         1 " "
","         1 ","
";"         1 ";"
":"         1 ":"
"?"         1 "?"
"!"         1 "!"
"("         1 "("
")"         1 ")"
"["         1 "["
"]"         1 "]"
"{"         1 "{"
"}"         1 "}"
% "*"       1 "*"               EVH no more
"\n"        1 "\n"
"\t"        1 "\t"
"-"         1 "-"
"_"         1 "_"
% "+"       1 "+"               EVH no more
"="         1 "="
"`"         1 "`"
"\""        1 "\""
"'"         1 "'"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

@patterns 2 Velthuis transcription, secondary position
"$"         0 "</foreign>"      switch back to Roman script
"\\"        t                   copy TeX commands
"{}"        1 ""                used for disambiguating the transcription only
"^"         f                   used to indicate capital letters in Roman transcription

"%"         c
"<"         0 "<"               RESYNC
">"         0 ">"               RESYNC

"</HI>"     0 "</foreign>"
"</MA>"     0 "</foreign>"
"</NP>"     0 "</foreign>"
"</SA>"     0 "</foreign>"

"&#"        3 "&#"          copy numeric SGML entity.


% vowels, use matra, go to primary mode

"*"         1 ""                EVH no silent a-matra
"a"         1 ""                no a-matra
"!a"        1 ""                EVH no Kashmiri a matra
"\"a"       1 ""                EVH no Singhala ae matra
"aa"        1 "ा"
"A"         1 "ा"
"!aa"       1 "ा"            EVH Kashmiri aa -> aa
"!A"        1 "ा"            EVH Kashmiri aa -> aa
"\"aa"      1 "ा"            EVH Singhala aeae -> aa
"\"A"       1 "ा"            EVH Singhala aeae -> aa
"i"         1 "ि"
"ii"        1 "ी"
"I"         1 "ी"
"u"         1 "ु"
"~u"        1 "ु्"        EVH Malayalam half u -> u + halant
"\"u"       1 "ु"            EVH Kashmiri u -> u
"uu"        1 "ू"
"U"         1 "ू"
"\"uu"      1 "ू"            EVH Kashmiri uu -> uu
"\"U"       1 "ू"            EVH Kashmiri uu -> uu
".r"        1 "ृ"
".R"        1 "ॄ"
".l"        1 "ॢ"
".L"        1 "ॣ"
"\"e"       1 "ॆ"            EVH short e
"e"         1 "े"
"ai"        1 "ै"
"E"         1 "ै"
"~a"        1 "ॅ"            English a in Marathi
"~e"        1 "ॅ"            EVH English a in Marathi, Gujarati
"\"o"       1 "ॊ"            EVH short o
"o"         1 "ो"
"au"        1 "ौ"
"O"         1 "ौ"
"~o"        1 "ॉ"            English o in Devanagari

% EVH Urdu ain jumps back to primary mode
% (appears as a nukta under $a$ or another vowel)

"_a"        1 "अ़"        EVH
"_aa"       1 "आ़"        EVH
"_A"        1 "आ़"        EVH
"_i"        1 "इ़"        EVH
"_a{}i"     1 "अ़ि"    EVH $a$ with nukta and i matra
"_ii"       1 "ई़"        EVH
"_I"        1 "ई़"        EVH
"_a{}ii"    1 "अ़ी"    EVH $a$ with nukta and ii matra
"_a{}I"     1 "अ़ी"    EVH
"_u"        1 "उ़"        EVH
"_uu"       1 "ऊ़"        EVH
"_U"        1 "ऊ़"        EVH

% consonants, use halant, stay in secondary mode
"k"         2 "्क"
"q"         2 "्क़"
"kh"        2 "्ख"
"K"         2 "्ख"
".kh"       2 "्ख़"
".K"        2 "्ख़"
"g"         2 "्ग"
".g"        2 "्ग़"
"_g"        2 "्ग॒"    EVH Sindhi g with bar below
"gh"        2 "्घ"
"G"         2 "्घ"
"\"n"       2 "्ङ"

"c"         2 "्च"
".c"        2 "्च़"    EVH Kashmiri c nukta
"ch"        2 "्छ"
"C"         2 "्छ"
".ch"       2 "्छ़"    EVH Kashmiri ch nukta
".C"        2 "्छ़"    EVH Kashmiri ch nukta
"j"         2 "्ज"
"z"         2 "्ज़"
"_j"        2 "्ज॒"    EVH Sindhi j with bar below
"jh"        2 "्झ"
"J"         2 "्झ"
"~n"        2 "्ञ"

".t"        2 "्ट"
".th"       2 "्ठ"
".T"        2 "्ठ"
".d"        2 "्ड"
"R"         2 "्ड़"
"_d"        2 "्ड॒"    EVH Sindhi .d with bar below
".dh"       2 "्ढ"
".D"        2 "्ढ"
"Rh"        2 "्ढ़"
".n"        2 "्ण"

"t"         2 "्त"
"th"        2 "्थ"
"T"         2 "्थ"
"d"         2 "्द"
"dh"        2 "्ध"
"D"         2 "्ध"
"n"         2 "्न"

"_n"        2 "्ऩ"      EVH Tamil na with bar below (or nukta)
            
"p"         2 "्प"
"ph"        2 "्फ"
"P"         2 "्फ"
"f"         2 "्फ़"
"b"         2 "्ब"
"_b"        2 "्ब॒"      EVH Sindhi b with bar below
"bh"        2 "्भ"
"B"         2 "्भ"
"m"         2 "्म"
            
"y"         2 "्य"
".y"        2 "्य़"      EVH Bengali y with nukta
"r"         2 "्र"
"\"r"       2 "्ऱ"      Marathi eyelash ra
"_r"        2 "्ऱ"      EVH Dravidian ra
"_t"        2 "्ऱ"      EVH Dravidian ra (pronounced ta)
"l"         2 "्ल"
"L"         2 "्ळ"
"\"L"       2 "्ऴ"      EVH Tamil, Malayalam zh
"zh"        2 "्ऴ"      EVH Tamil, Malayalam zh
"v"         2 "्व"
"\"s"       2 "्श"
".s"        2 "्ष"
"s"         2 "्स"
"h"         2 "्ह"

% numerals: use Devanagari numerals

"0"         1 "०"
"1"         1 "१"
"2"         1 "२"
"3"         1 "३"
"4"         1 "४"
"5"         1 "५"
"6"         1 "६"
"7"         1 "७"
"8"         1 "८"
"9"         1 "९"

% specials: go to primary mode

".o"        1 "ॐ"      OM sign
".a"        1 "ऽ"      ahagraha
"@"         1 "॰"      Abbr. circle
"/"         1 "ँ"
".m"        1 "ं"
"M"         1 "ं"
".h"        1 "ः"
"H"         1 "ः"
           
"|"         1 "।"
"||"        1 "॥"
"&"         1 "्‌"    explicit halant (EVH small change in semantics)
"+"         1 "्‍"    EVH soft halant
           
".."        1 "."
"#"         1 "·"            centered dot (distinction gets lost)

% others switch back to primary mode

" "         1 " "
","         1 ","
";"         1 ";"
":"         1 ":"
"?"         1 "?"
"!"         1 "!"
"("         1 "("
")"         1 ")"
"["         1 "["
"]"         1 "]"
"{"         1 "{"
"}"         1 "}"
% "*"       1 "*"           EVH no more
"\n"        1 "\n"
"\t"        1 "\t"
"-"         1 "-"
"_"         1 "_"
% "+"       1 "+"           EVH no more
"="         1 "="
"`"         1 "`"
"\""        1 "\""
"'"         1 "'"


@patterns 3 Numeric SGML entities

";"         1 ";"

@end

% end of dn2usc.pat
