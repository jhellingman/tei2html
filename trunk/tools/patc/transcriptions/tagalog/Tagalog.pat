% Tagalog.pat -- Translate tagalog in old Baybayin script to Unicode.

@patterns 0

"<TL>"      1 "<foreign lang=TL-Bayb>"

@rpatterns 1 % primary position

"</TL>"     0 "</foreign>"

% common punctuation

" "     p " "
"\n"    p "\n"

% tags

"<"     3 "<"

% independent vowels

"A"     p "&#x1700;"
"I"     p "&#x1701;"
"E"     p "&#x1701;"
"U"     p "&#x1702;"
"O"     p "&#x1702;"

"a"     p "&#x1700;"
"i"     p "&#x1701;"
"e"     p "&#x1701;"
"u"     p "&#x1702;"
"o"     p "&#x1702;"

% consonants

"k"     2 "&#x1703;"
"g"     2 "&#x1704;"
"ng"    2 "&#x1705;"
"N"     2 "&#x1705;"
"t"     2 "&#x1706;"
"d"     2 "&#x1707;"
"r"     2 "&#x1707;"
"n"     2 "&#x1708;"
"p"     2 "&#x1709;"
"b"     2 "&#x170A;"
"m"     2 "&#x170B;"
"y"     2 "&#x170C;"
"l"     2 "&#x170E;"
"w"     2 "&#x170F;"
"s"     2 "&#x1710;"
"h"     2 "&#x1711;"

% Common punctuation marks.

"|"     p "&#x1735;"
"||"    p "&#x1736;"
"."     p "&#x1736;"

@rpatterns 2 % secondary position

" "     1 ""
"a"     1 ""
"i"     1 "&#x1712;"
"e"     1 "&#x1712;"
"u"     1 "&#x1713;"
"o"     1 "&#x1713;"
"+"     1 "&#x1714;"

% special case of both vowel signs appearing with a letter (seen in Doctrina Christiana

"iu"    1 "&#x1712;&#x1713;"

@patterns 3 % tags

">"     1 ">"

@end;
