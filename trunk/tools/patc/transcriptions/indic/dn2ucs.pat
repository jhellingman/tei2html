% dn2usc.pat -- convert Indic script text in Extended Velthuis transliteration
%               to Unicode in XML entities (Hindi/Marathi/Nepali/Sanskrit)
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
"$"     1 "<foreign lang=hi>"       switch to indic script

% EVH language tags (use TEI <foreign> tags)

"<HI>"      1 "<foreign lang=hi>"
"<MA>"      1 "<foreign lang=ma>"
"<NP>"      1 "<foreign lang=np>"
"<SA>"      1 "<foreign lang=sa>"

% all others go thru unaltered

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

@patterns 1 Velthuis transcription, primary position
"$"     0 "</foreign>"          switch back to Roman script
"\\"        t               copy TeX commands
"{}"        f               used for disambiguating transcription
"^"     f               used to indicate capital letters in Roman transcription

"%"     c
"<"     0 "<"               RESYNC
">"     0 ">"               RESYNC

"</HI>"     0 "</foreign>"
"</MA>"     0 "</foreign>"
"</NP>"     0 "</foreign>"
"</SA>"     0 "</foreign>"

% vowels, use full vowel, stay in primary mode
"*"     1 "&#x0905;"            EVH silent a -- should not appear initially
"a"     1 "&#x0905;"
"!a"        1 "&#x0905;"            EVH Kashmiri a -- becomes a
"\"a"       1 "&#x0905;"            EVH Singhala ae -- becomes a
"aa"        1 "&#x0906;"
"A"     1 "&#x0906;"
"!aa"       1 "&#x0906;"            EVH Kashmiri aa -- becomes aa
"!A"        1 "&#x0906;"            EVH Kashmiri aa -- becomes aa
"\"aa"      1 "&#x0906;"            EVH Singhala aeae -- becomes aa
"\"A"       1 "&#x0906;"            EVH Singhala aeae -- becomes aa
"i"     1 "&#x0907;"
"ii"        1 "&#x0908;"
"I"     1 "&#x0908;"
"u"     1 "&#x0909;"
"~u"        1 "&#x0909;&#x094D;"        EVH Malayalam half u -- becomes u halant (should not appear initially!)
"\"u"       1 "&#x0909;"            EVH Kashmiri u -> u
"uu"        1 "&#x090A;"
"U"     1 "&#x090A;"
"\"uu"      1 "&#x090A;"            EVH Kashmiri uu -> uu
"\"U"       1 "&#x090A;"            EVH Kashmiri uu -> uu
".r"        1 "&#x090B;"
".R"        1 "&#x0960;"
".l"        1 "&#x090C;"
".L"        1 "&#x0961;"
"\"e"       1 "&#x090E;"            EVH short e
"e"     1 "&#x090F;"
"ai"        1 "&#x0910;"
"E"     1 "&#x0910;"
"~a"        1 "&#x0905;&#x0945;"        English a in Marathi (initially on a)
"~e"        1 "&#x090D;"            EVH English a (initially on e) (distinction gets lost)
"\"o"       1 "&#x0912;"            EVH short e
"o"     1 "&#x0913;"
"au"        1 "&#x0914;"
"O"     1 "&#x0914;"
"~o"        1 "&#x0911;"            English o in Devanagari

% EVH Urdu ain (appears as a nukta under $a$ or another vowel)

"_a"        1 "&#x0905;&#x093C;"        EVH
"_aa"       1 "&#x0906;&#x093C;"        EVH
"_A"        1 "&#x0906;&#x093C;"        EVH
"_i"        1 "&#x0907;&#x093C;"        EVH
"_a{}i"     1 "&#x0905;&#x093C;&#x093F;"    EVH $a$ with nukta and i matra
"_ii"       1 "&#x0908;&#x093C;"        EVH
"_I"        1 "&#x0908;&#x093C;"        EVH
"_a{}ii"    1 "&#x0905;&#x093C;&#x0940;"    EVH $a$ with nukta and ii matra
"_a{}I"     1 "&#x0905;&#x093C;&#x0940;"    EVH
"_u"        1 "&#x0909;&#x093C;"        EVH
"_uu"       1 "&#x090A;&#x093C;"        EVH
"_U"        1 "&#x090A;&#x093C;"        EVH

% consonants, go to secondary mode
"k"     2 "&#x0915;"
"q"     2 "&#x0958;"
"kh"        2 "&#x0916;"
"K"     2 "&#x0916;"
".kh"       2 "&#x0959;"
".K"        2 "&#x0959;"
"g"     2 "&#x0917;"
".g"        2 "&#x095A;"
"_g"        2 "&#x0917;&#x0952;"        EVH Sindhi g with bar below
"gh"        2 "&#x0918;"
"G"     2 "&#x0918;"
"\"n"       2 "&#x0919;"

"c"     2 "&#x091A;"
".c"        2 "&#x091A;&#x093C;"        EVH Kashmiri c nukta
"ch"        2 "&#x091B;"
"C"     2 "&#x091B;"
".ch"       2 "&#x091B;&#x093C;"        EVH Kashmiri ch nukta
".C"        2 "&#x091B;&#x093C;"        EVH Kashmiri ch nukta
"j"     2 "&#x091C;"
"z"     2 "&#x095B;"
"_j"        2 "&#x091C;&#x0952;"        EVH Sindhi j with bar below
"jh"        2 "&#x091D;"
"J"     2 "&#x091D;"
"~n"        2 "&#x091E;"

".t"        2 "&#x091F;"
".th"       2 "&#x0920;"
".T"        2 "&#x0920;"
".d"        2 "&#x0921;"
"R"     2 "&#x095C;"
"_d"        2 "&#x0921;&#x0952;"        EVH Sindhi .d with bar below
".dh"       2 "&#x0922;"
".D"        2 "&#x0922;"
"Rh"        2 "&#x095D;"
".n"        2 "&#x0923;"

"t"     2 "&#x0924;"
"th"        2 "&#x0925;"
"T"     2 "&#x0925;"
"d"     2 "&#x0926;"
"dh"        2 "&#x0927;"
"D"     2 "&#x0927;"
"n"     2 "&#x0928;"

"_n"        2 "&#x0929;"            EVH Malayalam, Tamil n with bar below (or nukta)

"p"     2 "&#x092A;"
"ph"        2 "&#x092B;"
"P"     2 "&#x092B;"
"f"     2 "&#x095E;"
"b"     2 "&#x092C;"
"_b"        2 "&#x092C;&#x0952;"        EVH Sindhi b with bar below
"bh"        2 "&#x092D;"
"B"     2 "&#x092D;"
"m"     2 "&#x092E;"

"y"     2 "&#x092F;"
".y"        2 "&#x095F;"            EVH Bengali y with bar below (or nukta)
"r"     2 "&#x0930;"
"\"r"       2 "&#x0931;"            Marathi eyelash ra
"_r"        2 "&#x0931;"            EVH Dravidian ra
"_t"        2 "&#x0931;"            EVH Dravidian ra (pronounced as .ta)
"l"     2 "&#x0932;"
"L"     2 "&#x0933;"
"\"L"       2 "&#x0934;"            EVH Tamil, Malayalam zh
"zh"        2 "&#x0934;"            EVH Tamil, Malayalam zh
"v"     2 "&#x0935;"
"\"s"       2 "&#x0936;"
".s"        2 "&#x0937;"
"s"     2 "&#x0938;"
"h"     2 "&#x0939;"

% numerals: use Devanagari numerals

"0"     1 "&#x0966;"
"1"     1 "&#x0967;"
"2"     1 "&#x0968;"
"3"     1 "&#x0969;"
"4"     1 "&#x096A;"
"5"     1 "&#x096B;"
"6"     1 "&#x096C;"
"7"     1 "&#x096D;"
"8"     1 "&#x096E;"
"9"     1 "&#x096F;"

% specials: stay in primary mode

".o"        1 "&#x0950;"            OM sign
".a"        1 "&#x093D;"            ahagraha
"@"     1 "&#x0970;"            Abbr. circle

"/"     1 "&#x0901;"
".m"        1 "&#x0902;"
"M"     1 "&#x0902;"
".h"        1 "&#x0903;"
"H"     1 "&#x0903;"

"|"     1 "&#x0964;"
"||"        1 "&#x0965;"
"&"     1 "&#x094D;&#x200C;"        explicit halant (EVH small change in semantics)
"+"     1 "&#x094D;&#x200D;"        EVH soft halant (force half-letter)

".."        1 "."
"#"     1 "&#x00B7;"            centered dot

% all other characters go thru unaltered

" "     1 " "
","     1 ","
";"     1 ";"
":"     1 ":"
"?"     1 "?"
"!"     1 "!"
"("     1 "("
")"     1 ")"
"["     1 "["
"]"     1 "]"
"{"     1 "{"
"}"     1 "}"
% "*"       1 "*"               EVH no more
"\n"        1 "\n"
"\t"        1 "\t"
"-"     1 "-"
"_"     1 "_"
% "+"       1 "+"               EVH no more
"="     1 "="
"`"     1 "`"
"\""        1 "\""
"'"     1 "'"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

@patterns 2 Velthuis transcription, secondary position
"$"     0 "</foreign>"          switch back to Roman script
"\\"        t               copy TeX commands
"{}"        1 ""                used for disambiguating the transcription only
"^"     f               used to indicate capital letters in Roman transcription

"%"     c
"<"     0 "<"               RESYNC
">"     0 ">"               RESYNC

"</HI>"     0 "</foreign>"
"</MA>"     0 "</foreign>"
"</NP>"     0 "</foreign>"
"</SA>"     0 "</foreign>"


% vowels, use matra, go to primary mode

"*"     1 ""                EVH no silent a-matra
"a"     1 ""                no a-matra
"!a"        1 ""                EVH no Kashmiri a matra
"\"a"       1 ""                EVH no Singhala ae matra
"aa"        1 "&#x093E;"
"A"     1 "&#x093E;"
"!aa"       1 "&#x093E;"            EVH Kashmiri aa -> aa
"!A"        1 "&#x093E;"            EVH Kashmiri aa -> aa
"\"aa"      1 "&#x093E;"            EVH Singhala aeae -> aa
"\"A"       1 "&#x093E;"            EVH Singhala aeae -> aa
"i"     1 "&#x093F;"
"ii"        1 "&#x0940;"
"I"     1 "&#x0940;"
"u"     1 "&#x0941;"
"~u"        1 "&#x0941;&#x094D;"        EVH Malayalam half u -> u + halant
"\"u"       1 "&#x0941;"            EVH Kashmiri u -> u
"uu"        1 "&#x0942;"
"U"     1 "&#x0942;"
"\"uu"      1 "&#x0942;"            EVH Kashmiri uu -> uu
"\"U"       1 "&#x0942;"            EVH Kashmiri uu -> uu
".r"        1 "&#x0943;"
".R"        1 "&#x0944;"
".l"        1 "&#x0962;"
".L"        1 "&#x0963;"
"\"e"       1 "&#x0946;"            EVH short e
"e"     1 "&#x0947;"
"ai"        1 "&#x0948;"
"E"     1 "&#x0948;"
"~a"        1 "&#x0945;"            English a in Marathi
"~e"        1 "&#x0945;"            EVH English a in Marathi, Gujarati
"\"o"       1 "&#x094A;"            EVH short o
"o"     1 "&#x094B;"
"au"        1 "&#x094C;"
"O"     1 "&#x094C;"
"~o"        1 "&#x0949;"            English o in Devanagari

% EVH Urdu ain jumps back to primary mode
% (appears as a nukta under $a$ or another vowel)

"_a"        1 "&#x0905;&#x093C;"        EVH
"_aa"       1 "&#x0906;&#x093C;"        EVH
"_A"        1 "&#x0906;&#x093C;"        EVH
"_i"        1 "&#x0907;&#x093C;"        EVH
"_a{}i"     1 "&#x0905;&#x093C;&#x093F;"    EVH $a$ with nukta and i matra
"_ii"       1 "&#x0908;&#x093C;"        EVH
"_I"        1 "&#x0908;&#x093C;"        EVH
"_a{}ii"    1 "&#x0905;&#x093C;&#x0940;"    EVH $a$ with nukta and ii matra
"_a{}I"     1 "&#x0905;&#x093C;&#x0940;"    EVH
"_u"        1 "&#x0909;&#x093C;"        EVH
"_uu"       1 "&#x090A;&#x093C;"        EVH
"_U"        1 "&#x090A;&#x093C;"        EVH

% consonants, use halant, stay in secondary mode
"k"     2 "&#x094D;&#x0915;"
"q"     2 "&#x094D;&#x0958;"
"kh"        2 "&#x094D;&#x0916;"
"K"     2 "&#x094D;&#x0916;"
".kh"       2 "&#x094D;&#x0959;"
".K"        2 "&#x094D;&#x0959;"
"g"     2 "&#x094D;&#x0917;"
".g"        2 "&#x094D;&#x095A;"
"_g"        2 "&#x094D;&#x0917;&#x0952;"    EVH Sindhi g with bar below
"gh"        2 "&#x094D;&#x0918;"
"G"     2 "&#x094D;&#x0918;"
"\"n"       2 "&#x094D;&#x0919;"

"c"     2 "&#x094D;&#x091A;"
".c"        2 "&#x094D;&#x091A;&#x093C;"    EVH Kashmiri c nukta
"ch"        2 "&#x094D;&#x091B;"
"C"     2 "&#x094D;&#x091B;"
".ch"       2 "&#x094D;&#x091B;&#x093C;"    EVH Kashmiri ch nukta
".C"        2 "&#x094D;&#x091B;&#x093C;"    EVH Kashmiri ch nukta
"j"     2 "&#x094D;&#x091C;"
"z"     2 "&#x094D;&#x095B;"
"_j"        2 "&#x094D;&#x091C;&#x0952;"    EVH Sindhi j with bar below
"jh"        2 "&#x094D;&#x091D;"
"J"     2 "&#x094D;&#x091D;"
"~n"        2 "&#x094D;&#x091E;"

".t"        2 "&#x094D;&#x091F;"
".th"       2 "&#x094D;&#x0920;"
".T"        2 "&#x094D;&#x0920;"
".d"        2 "&#x094D;&#x0921;"
"R"     2 "&#x094D;&#x095C;"
"_d"        2 "&#x094D;&#x0921;&#x0952;"    EVH Sindhi .d with bar below
".dh"       2 "&#x094D;&#x0922;"
".D"        2 "&#x094D;&#x0922;"
"Rh"        2 "&#x094D;&#x095D;"
".n"        2 "&#x094D;&#x0923;"

"t"     2       "&#x094D;&#x0924;"
"th"    2       "&#x094D;&#x0925;"
"T"     2       "&#x094D;&#x0925;"
"d"     2       "&#x094D;&#x0926;"
"dh"    2       "&#x094D;&#x0927;"
"D"     2       "&#x094D;&#x0927;"
"n"     2       "&#x094D;&#x0928;"

"_n"    2       "&#x094D;&#x0929;"      EVH Tamil na with bar below (or nukta)

"p"     2       "&#x094D;&#x092A;"
"ph"    2       "&#x094D;&#x092B;"
"P"     2       "&#x094D;&#x092B;"
"f"     2       "&#x094D;&#x095E;"
"b"     2       "&#x094D;&#x092C;"
"_b"    2       "&#x094D;&#x092C;&#x0952;"      EVH Sindhi b with bar below
"bh"    2       "&#x094D;&#x092D;"
"B"     2       "&#x094D;&#x092D;"
"m"     2       "&#x094D;&#x092E;"

"y"     2       "&#x094D;&#x092F;"
".y"    2       "&#x094D;&#x095F;"      EVH Bengali y with nukta
"r"     2       "&#x094D;&#x0930;"
"\"r"   2       "&#x094D;&#x0931;"      Marathi eyelash ra
"_r"    2       "&#x094D;&#x0931;"      EVH Dravidian ra
"_t"    2       "&#x094D;&#x0931;"      EVH Dravidian ra (pronounced ta)
"l"     2       "&#x094D;&#x0932;"
"L"     2       "&#x094D;&#x0933;"
"\"L"   2       "&#x094D;&#x0934;"      EVH Tamil, Malayalam zh
"zh"    2       "&#x094D;&#x0934;"      EVH Tamil, Malayalam zh
"v"     2       "&#x094D;&#x0935;"
"\"s"   2       "&#x094D;&#x0936;"
".s"    2       "&#x094D;&#x0937;"
"s"     2       "&#x094D;&#x0938;"
"h"     2       "&#x094D;&#x0939;"

% numerals: use Devanagari numerals

"0"     1       "&#x0966;"
"1"     1       "&#x0967;"
"2"     1       "&#x0968;"
"3"     1       "&#x0969;"
"4"     1       "&#x096A;"
"5"     1       "&#x096B;"
"6"     1       "&#x096C;"
"7"     1       "&#x096D;"
"8"     1       "&#x096E;"
"9"     1       "&#x096F;"

% specials: go to primary mode

".o"    1       "&#x0950;"      OM sign
".a"    1       "&#x093D;"      ahagraha
"@"     1       "&#x0970;"      Abbr. circle
"/"     1       "&#x0901;"
".m"    1       "&#x0902;"
"M"     1       "&#x0902;"
".h"    1       "&#x0903;"
"H"     1       "&#x0903;"

"|"     1       "&#x0964;"
"||"    1       "&#x0965;"
"&"     1       "&#x094D;&#x200C;"      explicit halant (EVH small change in semantics)
"+"     1       "&#x094D;&#x200D;"  EVH soft halant

".."    1       "."
"#"     1       "&#x00B7;"      centered dot (distinction gets lost)

% others switch back to primary mode

" "     1       " "
","     1       ","
";"     1       ";"
":"     1       ":"
"?"     1       "?"
"!"     1       "!"
"("     1       "("
")"     1       ")"
"["     1       "["
"]"     1       "]"
"{"     1       "{"
"}"     1       "}"
% "*"     1       "*"           EVH no more
"\n"    1       "\n"
"\t"    1       "\t"
"-"     1       "-"
"_"     1       "_"
% "+"     1       "+"           EVH no more
"="     1       "="
"`"     1       "`"
"\""    1       "\""
"'"     1       "'"

@end

% end of dn2usc.pat
