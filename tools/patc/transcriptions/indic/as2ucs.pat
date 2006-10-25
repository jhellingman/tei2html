% as2usc.pat -- convert Indic script text in Extended Velthuis transliteration
%               to Unicode in XML entities (Assamese
% Copyright 2003 Jeroen Hellingman
%
% This file is to be used with the pattern-converter utility patc.
%
% patc -p as2ucs.pat file.dn file.usc
%
% modes/pattern sets
%  0 - roman text
%  1 - Extended Velthuis transcription, primary position
%  2 - Extended Velthuis transcription, secondary position

@patterns 0 roman text
% "$"		1 "<foreign lang=as>"		switch to indic script

% EVH language tags (use TEI <foreign> tags)

"<AS>"		1 "<foreign lang=as>"

% all others go thru unaltered

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

@patterns 1 Velthuis transcription, primary position
% "$"		0 "</foreign>"			switch back to Roman script
"\\"		t				copy TeX commands
"{}"		f				used for disambiguating transcription
"^"		f				used to indicate capital letters in Roman transcription

"%"		c
"<"		0 "<"				RESYNC
">"		0 ">"				RESYNC

"</AS>"		0 "</foreign>"

% vowels, use full vowel, stay in primary mode
"*"		1 "&#x0985;"			EVH silent a -- should not appear initially
"a"		1 "&#x0985;"
"aa"		1 "&#x0986;"
"A"		1 "&#x0986;"
"i"		1 "&#x0987;"
"ii"		1 "&#x0988;"
"I"		1 "&#x0988;"
"u"		1 "&#x0989;"
"uu"		1 "&#x098A;"
"U"		1 "&#x098A;"
".r"		1 "&#x098B;"
".R"		1 "&#x09E0;"			
".l"		1 "&#x098C;"      
".L"		1 "&#x09E1;"      
"e"		1 "&#x098F;"
"ai"		1 "&#x0990;"
"E"		1 "&#x0990;"
"~a"		1 "&#x0985;&#x09CD;&#x09AF;&#x09BE;"	English a in Bengali (use ya-phala)
"~e"		1 "&#x098F;&#x09CD;&#x09AF;&#x09BE;"	EVH English a (initially on e) (use ya-phala)
"o"		1 "&#x0993;"
"au"		1 "&#x0994;"
"O"		1 "&#x0994;"

% consonants, go to secondary mode
"k"		2 "&#x0995;"
"kh"		2 "&#x0996;"
"K"		2 "&#x0996;"
"g"		2 "&#x0997;"
"gh"		2 "&#x0998;"
"G"		2 "&#x0998;"
"\"n"		2 "&#x0999;"

"c"		2 "&#x099A;"
"ch"		2 "&#x099B;"
"C"		2 "&#x099B;"
"j"		2 "&#x099C;"
"jh"		2 "&#x099D;"
"J"		2 "&#x099D;"
"~n"		2 "&#x099E;"

".t"		2 "&#x099F;"
".th"		2 "&#x09A0;"
".T"		2 "&#x09A0;"
".d"		2 "&#x09A1;"
"R"		2 "&#x09DC;"      
".dh"		2 "&#x09A2;"
".D"		2 "&#x09A2;"
"Rh"		2 "&#x09DD;"      
".n"		2 "&#x09A3;"

"t"		2 "&#x09A4;"
"th"		2 "&#x09A5;"
"T"		2 "&#x09A5;"
"d"		2 "&#x09A6;"
"dh"		2 "&#x09A7;"
"D"		2 "&#x09A7;"
"n"		2 "&#x09A8;"

"p"		2 "&#x09AA;"
"ph"		2 "&#x09AB;"
"P"		2 "&#x09AB;"
"b"		2 "&#x09AC;"
"bh"		2 "&#x09AD;"
"B"		2 "&#x09AD;"
"m"		2 "&#x09AE;"

"y"		2 "&#x09AF;"			(TODO - CHECK)
".y"		2 "&#x09DF;"			EVH Bengali y with nukta (TODO - CHECK)
"r"			2 "&#x09F0;"		% Assamese
"l"		2 "&#x09B2;"
"v"		2 "&#x09F1;"			% Assamese
"\"s"		2 "&#x09B6;"
".s"		2 "&#x09B7;"
"s"		2 "&#x09B8;"
"h"		2 "&#x09B9;"

% numerals: use Bengali numerals

"0"		1 "&#x09E6;"
"1"		1 "&#x09E7;"
"2"		1 "&#x09E8;"
"3"		1 "&#x09E9;"
"4"		1 "&#x09EA;"
"5"		1 "&#x09EB;"
"6"		1 "&#x09EC;"
"7"		1 "&#x09ED;"
"8"		1 "&#x09EE;"
"9"		1 "&#x09EF;"

% specials: stay in primary mode

".o"		1 "&#x0950;"			OM sign (from Devanagari block)
".a"		1 "&#x09BD;"			ahagraha
"@"		1 "&#x0970;"			Abbr. circle (from Devangari block)

"/"		1 "&#x0981;"
".m"		1 "&#x0982;"
"M"		1 "&#x0982;"
".h"		1 "&#x0983;"
"H"		1 "&#x0983;"

"|"		1 "&#x0964;"			(from Devanagari block)
"||"		1 "&#x0965;"			(from Devanagari block)
"&"		1 "&#x09CD;&#x200C;"		explicit halant (EVH small change in semantics)
"+"		1 "&#x09CD;&#x200D;"		EVH soft halant (force half-letter)

".."		1 "."
"#"		1 "&#x00B7;"			centered dot

% all other characters go thru unaltered

" "		1 " "
","		1 ","
";"		1 ";"
":"		1 ":"
"?"		1 "?"
"!"		1 "!"
"("		1 "("
")"		1 ")"
"["		1 "["
"]"		1 "]"
"{"		1 "{"
"}"		1 "}"
% "*"		1 "*"				EVH no more
"\n"		1 "\n"
"\t"		1 "\t"
"-"		1 "-"
"_"		1 "_"
% "+"		1 "+"				EVH no more
"="		1 "="
"`"		1 "`"
"\""		1 "\""
"'"		1 "'"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

@patterns 2 Velthuis transcription, secondary position
"$"		0 "</foreign>"			switch back to Roman script
"\\"		t				copy TeX commands
"{}"		1 ""				used for disambiguating the transcription only
"^"		f				used to indicate capital letters in Roman transcription

"%"		c
"<"		0 "<"				RESYNC
">"		0 ">"				RESYNC

"</AS>"		0 "</foreign>"

% vowels, use matra, go to primary mode

"*"		1 ""				EVH no silent a-matra
"a"		1 ""				no a-matra
"aa"		1 "&#x09BE;"
"A"		1 "&#x09BE;"
"i"		1 "&#x09BF;"
"ii"		1 "&#x09C0;"
"I"		1 "&#x09C0;"
"u"		1 "&#x09C1;"
"uu"		1 "&#x09C2;"
"U"		1 "&#x09C2;"
".r"		1 "&#x09C3;"
".R"		1 "&#x09C4;"      
".l"		1 "&#x09E2;"      
".L"		1 "&#x09E3;"    
"e"		1 "&#x09C7;"
"ai"		1 "&#x09C8;"
"E"		1 "&#x09C8;"
"~a"		1 "&#x09CD;&#x09AF;&#x09BE;"	English a in Bengali (use ya-phala)
"~e"		1 "&#x09CD;&#x09AF;&#x09BE;"	EVH English a in Bengali
"o"		1 "&#x09CB;"
"au"		1 "&#x09CC;"
"O"		1 "&#x09CC;"

% consonants, use halant, stay in secondary mode
"k"		2 "&#x09CD;&#x0995;"
"kh"		2 "&#x09CD;&#x0996;"
"K"		2 "&#x09CD;&#x0996;"
"g"		2 "&#x09CD;&#x0997;"
"gh"		2 "&#x09CD;&#x0998;"
"G"		2 "&#x09CD;&#x0998;"
"\"n"		2 "&#x09CD;&#x0999;"

"c"		2 "&#x09CD;&#x099A;"
"ch"		2 "&#x09CD;&#x099B;"
"C"		2 "&#x09CD;&#x099B;"
"j"		2 "&#x09CD;&#x099C;"
"jh"		2 "&#x09CD;&#x099D;"
"J"		2 "&#x09CD;&#x099D;"
"~n"		2 "&#x09CD;&#x099E;"

".t"		2 "&#x09CD;&#x099F;"
".th"		2 "&#x09CD;&#x09A0;"
".T"		2 "&#x09CD;&#x09A0;"
".d"		2 "&#x09CD;&#x09A1;"
"R"		2 "&#x09CD;&#x09DC;"  
".dh"		2 "&#x09CD;&#x09A2;"
".D"		2 "&#x09CD;&#x09A2;"
"Rh"		2 "&#x09CD;&#x09DD;"  
".n"		2 "&#x09CD;&#x09A3;"

"t"		2 "&#x09CD;&#x09A4;"
"th"		2 "&#x09CD;&#x09A5;"
"T"		2 "&#x09CD;&#x09A5;"
"d"		2 "&#x09CD;&#x09A6;"
"dh"		2 "&#x09CD;&#x09A7;"
"D"		2 "&#x09CD;&#x09A7;"
"n"		2 "&#x09CD;&#x09A8;"

"p"		2 "&#x09CD;&#x09AA;"
"ph"		2 "&#x09CD;&#x09AB;"
"P"		2 "&#x09CD;&#x09AB;"
"b"		2 "&#x09CD;&#x09AC;"
"bh"		2 "&#x09CD;&#x09AD;"
"B"		2 "&#x09CD;&#x09AD;"
"m"		2 "&#x09CD;&#x09AE;"

"y"		2 "&#x09CD;&#x09AF;"		(TODO - CHECK)
".y"		2 "&#x09CD;&#x09DF;"		EVH Bengali y with nukta (TODO - CHECK)
"r"			2 "&#x09CD;&#x09F0;"		% Assamese
"l"		2 "&#x09CD;&#x09B2;"
"v"		2 "&#x09CD;&#x09F1;"			% Assamese
"\"s"		2 "&#x09CD;&#x09B6;"
".s"		2 "&#x09CD;&#x09B7;"
"s"		2 "&#x09CD;&#x09B8;"
"h"		2 "&#x09CD;&#x09B9;"

% numerals: use Bengali numerals

"0"		1 "&#x09E6;"
"1"		1 "&#x09E7;"
"2"		1 "&#x09E8;"
"3"		1 "&#x09E9;"
"4"		1 "&#x09EA;"
"5"		1 "&#x09EB;"
"6"		1 "&#x09EC;"
"7"		1 "&#x09ED;"
"8"		1 "&#x09EE;"
"9"		1 "&#x09EF;"

% specials: switch back to primary mode

".o"		1 "&#x0950;"			OM sign (from Devanagari block)
".a"		1 "&#x09BD;"			ahagraha
"@"		1 "&#x0970;"			Abbr. circle (from Devangari block)

"/"		1 "&#x0981;"
".m"		1 "&#x0982;"
"M"		1 "&#x0982;"
".h"		1 "&#x0983;"
"H"		1 "&#x0983;"

"|"		1 "&#x0964;"			(from Devanagari block)
"||"		1 "&#x0965;"			(from Devanagari block)
"&"		1 "&#x09CD;&#x200C;"		explicit halant (EVH small change in semantics)
"+"		1 "&#x09CD;&#x200D;"		EVH soft halant (force half-letter)

".."		1 "."
"#"		1 "&#x00B7;"			centered dot

% others switch back to primary mode

" "		1 " "
","		1 ","
";"		1 ";"
":"		1 ":"
"?"		1 "?"
"!"		1 "!"
"("		1 "("
")"		1 ")"
"["		1 "["
"]"		1 "]"
"{"		1 "{"
"}"		1 "}"
% "*"		1 "*"				EVH no more
"\n"		1 "\n"
"\t"		1 "\t"
"-"		1 "-"
"_"		1 "_"
% "+"		1 "+"				EVH no more
"="		1 "="
"`"		1 "`"
"\""		1 "\""
"'"		1 "'"

@end

% end of bg2usc.pat
