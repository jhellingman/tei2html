% untamil.pat -- Tamil transcription to Latin transcription.
%
% History:
%   06-SEP-2012 Created from ta2ucs.pat (JH)

@patterns 0

"<TA>"      1 "<foreign lang=ta-Latn>"   % handle Tamil parts
"<TAA>"     1 ""        % handle Tamil parts (without tagging them)
"</TA>"     e "tag </TA> found in Roman mode"
"</TAA>"    e "tag </TAA> found in Roman mode"

@patterns 2             % copy SGML tags in Tamil mode

">"     1 ">"
"\n"    e "new line in tag in Tamil mode"

"<TA2>" 1 ""            % handle Tamil parts (hack for nested occurences in attributes)

@patterns 3             % copy SGML entities in Tamil mode

";"     1 ";"
" "     e "space in entity in Tamil mode"

@rpatterns 1            % Tamil transcription to Unicode

"</TA>"     0 "</foreign>"
"</TAA>"    0 ""
"<TA>"      e "tag <TA> found in Tamil mode"
"<TAA>"     e "tag <TAA> found in Tamil mode"

"</TA2>"    2 ""        % handle Tamil parts (hack for nested occurences in attributes)

"<"     2 "<"           % SGML tag in Tamil mode
"&"     3 "&"           % SGML entity in Tamil mode

" "     p " "
"\n"    p "\n"
"."     p "."
","     p ","
":"     p ":"
";"     p ";"
"?"     p "?"
"!"     p "!"
"("     p "("
")"     p ")"

"a"     p "a"
"aa"    p "&amacr;"
"i"     p "i"
"ii"    p "&imacr;"
"u"     p "u"
"uu"    p "&umacr;"
"e"     p "e"
"ee"    p "&emacr;"
"ai"    p "ai"
"o"     p "o"
"oo"    p "&omacr;"
"au"    p "au"

".k"    p "&kbarb;"

"k"     p "k"
"\"n"   p "&ndota;"
"c"     p "c"
"~n"    p "&ntilde;"
".t"    p "&tdotb;"
".n"    p "&ndotb;"
"t"     p "t"
"n"     p "n"
"p"     p "p"
"m"     p "m"
"y"     p "y"
"r"     p "r"
"l"     p "l"
"v"     p "v"
"zh"    p "&lbarb;"
".l"    p "&ldotb;"
".r"    p "&rbarb;"
"_n"    p "&nbarb;"
"j"     p "j"
".s"    p "&sdotb;"
"s"     p "s"
"h"     p "h"

"^a"     p "A"
"^aa"    p "&Amacr;"
"^i"     p "I"
"^ii"    p "&Imacr;"
"^u"     p "U"
"^uu"    p "&Umacr;"
"^e"     p "E"
"^ee"    p "&Emacr;"
"^ai"    p "Ai"
"^o"     p "O"
"^oo"    p "&Omacr;"
"^au"    p "Au"

"^.k"    p "&Kdotb;"

"^k"     p "K"
"^\"n"   p "&Ndota;"
"^c"     p "C"
"^~n"    p "&Ntilde;"
"^.t"    p "&Tdotb;"
"^.n"    p "&Ndotb;"
"^t"     p "T"
"^n"     p "N"
"^p"     p "P"
"^m"     p "M"
"^y"     p "Y"
"^r"     p "R"
"^l"     p "L"
"^v"     p "V"
"^zh"    p "&Lbarb;"
"^.l"    p "&Ldotb;"
"^.r"    p "&Rbarb;"
"^_n"    p "&Nbarb;"
"^j"     p "J"
"^.s"    p "&Sdotb;"
"^s"     p "S"
"^h"     p "H"

@end
