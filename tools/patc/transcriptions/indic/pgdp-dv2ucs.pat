% dn2usc.pat -- convert Indic script text in Velthuis transliteration as used on PGDP.
%               to Unicode in XML entities (Sanskrit)
% Copyright 2015 Jeroen Hellingman
%
% This file is to be used with the pattern-converter utility patc.
%
% patc -p pgdp-dv2ucs.pat file.dn file.usc
%
% modes/pattern sets
%  0 - roman text
%  1 - Extended Velthuis transcription, primary position
%  2 - Extended Velthuis transcription, secondary position

@patterns 0 roman text
"[DV:"     1 "<foreign lang=sk>"       switch to Devanagari script.

% all others go thru unaltered

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

@rpatterns 1 Velthuis transcription, primary position
"]"     0 "</foreign>"          switch back to Roman script

"{}"        f               used for disambiguating transcription

"<"     0 "<"               RESYNC
">"     0 ">"               RESYNC

"[["    0 "["               
"]]"    0 "]"               


% vowels, use full vowel, stay in primary mode
"a"     1 "&#x0905;"
"aa"        1 "&#x0906;"
"A"     1 "&#x0906;"
"i"     1 "&#x0907;"
"ii"        1 "&#x0908;"
"I"     1 "&#x0908;"
"u"     1 "&#x0909;"
"uu"        1 "&#x090A;"
"U"     1 "&#x090A;"
".r"        1 "&#x090B;"
".R"        1 "&#x0960;"
".l"        1 "&#x090C;"
".L"        1 "&#x0961;"
"e"     1 "&#x090F;"
"ai"        1 "&#x0910;"
"E"     1 "&#x0910;"
"~a"        1 "&#x0905;&#x0945;"        English a in Marathi (initially on a)
"o"     1 "&#x0913;"
"au"        1 "&#x0914;"
"O"     1 "&#x0914;"
"~o"        1 "&#x0911;"            English o in Devanagari


% consonants, go to secondary mode
"k"     2 "&#x0915;"
"q"     2 "&#x0958;"
"kh"        2 "&#x0916;"
"K"     2 "&#x0916;"
".kh"       2 "&#x0959;"
".K"        2 "&#x0959;"
"g"     2 "&#x0917;"
".g"        2 "&#x095A;"
"gh"        2 "&#x0918;"
"G"     2 "&#x0918;"
"\"n"       2 "&#x0919;"

"c"     2 "&#x091A;"
"ch"        2 "&#x091B;"
"C"     2 "&#x091B;"
"j"     2 "&#x091C;"
"z"     2 "&#x095B;"
"jh"        2 "&#x091D;"
"J"     2 "&#x091D;"
"~n"        2 "&#x091E;"
"ñ"        2 "&#x091E;"


".t"        2 "&#x091F;"
".th"       2 "&#x0920;"
".T"        2 "&#x0920;"
".d"        2 "&#x0921;"
"R"     2 "&#x095C;"
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


"p"     2 "&#x092A;"
"ph"        2 "&#x092B;"
"P"     2 "&#x092B;"
"f"     2 "&#x095E;"
"b"     2 "&#x092C;"
"bh"        2 "&#x092D;"
"B"     2 "&#x092D;"
"m"     2 "&#x092E;"

"y"     2 "&#x092F;"
"r"     2 "&#x0930;"
"l"     2 "&#x0932;"
"L"     2 "&#x0933;"
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
"\n"        1 "\n"
"\t"        1 "\t"
"-"     1 "-"
"_"     1 "_"
"="     1 "="
"`"     1 "`"
"\""        1 "\""
"'"     1 "'"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

@rpatterns 2 Velthuis transcription, secondary position
"]"     0 "</foreign>"          switch back to Roman script
"{}"        1 ""                used for disambiguating the transcription only

"%"     c
"<"     0 "<"               RESYNC
">"     0 ">"               RESYNC


% vowels, use matra, go to primary mode

"*"     1 ""                EVH no silent a-matra
"a"     1 ""                no a-matra
"aa"        1 "&#x093E;"
"A"     1 "&#x093E;"
"i"     1 "&#x093F;"
"ii"        1 "&#x0940;"
"I"     1 "&#x0940;"
"u"     1 "&#x0941;"
"uu"        1 "&#x0942;"
"U"     1 "&#x0942;"
".r"        1 "&#x0943;"
".R"        1 "&#x0944;"
".l"        1 "&#x0962;"
".L"        1 "&#x0963;"
"e"     1 "&#x0947;"
"ai"        1 "&#x0948;"
"E"     1 "&#x0948;"
"o"     1 "&#x094B;"
"au"        1 "&#x094C;"
"O"     1 "&#x094C;"
"~o"        1 "&#x0949;"            English o in Devanagari


% consonants, use halant, stay in secondary mode
"k"     2 "&#x094D;&#x0915;"
"q"     2 "&#x094D;&#x0958;"
"kh"        2 "&#x094D;&#x0916;"
"K"     2 "&#x094D;&#x0916;"
".kh"       2 "&#x094D;&#x0959;"
".K"        2 "&#x094D;&#x0959;"
"g"     2 "&#x094D;&#x0917;"
".g"        2 "&#x094D;&#x095A;"
"gh"        2 "&#x094D;&#x0918;"
"G"     2 "&#x094D;&#x0918;"
"\"n"       2 "&#x094D;&#x0919;"

"c"     2 "&#x094D;&#x091A;"
"ch"        2 "&#x094D;&#x091B;"
"C"     2 "&#x094D;&#x091B;"
"j"     2 "&#x094D;&#x091C;"
"z"     2 "&#x094D;&#x095B;"
"jh"        2 "&#x094D;&#x091D;"
"J"     2 "&#x094D;&#x091D;"
"~n"        2 "&#x094D;&#x091E;"
"ñ"        2 "&#x094D;&#x091E;"

".t"        2 "&#x094D;&#x091F;"
".th"       2 "&#x094D;&#x0920;"
".T"        2 "&#x094D;&#x0920;"
".d"        2 "&#x094D;&#x0921;"
"R"     2 "&#x094D;&#x095C;"
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


"p"     2       "&#x094D;&#x092A;"
"ph"    2       "&#x094D;&#x092B;"
"P"     2       "&#x094D;&#x092B;"
"f"     2       "&#x094D;&#x095E;"
"b"     2       "&#x094D;&#x092C;"
"bh"    2       "&#x094D;&#x092D;"
"B"     2       "&#x094D;&#x092D;"
"m"     2       "&#x094D;&#x092E;"

"y"     2       "&#x094D;&#x092F;"
"r"     2       "&#x094D;&#x0930;"
"l"     2       "&#x094D;&#x0932;"
"L"     2       "&#x094D;&#x0933;"
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
"\n"    1       "\n"
"\t"    1       "\t"
"-"     1       "-"
"_"     1       "_"
"="     1       "="
"`"     1       "`"
"\""    1       "\""
"'"     1       "'"

@end

% end of dn2usc.pat
