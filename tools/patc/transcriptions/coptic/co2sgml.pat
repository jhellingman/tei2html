% Coptic in my transcription to ISO SGML entities.
% This notation is derived from the PGDP notation for Greek.

@patterns 0

"<CO>"      1 "<foreign lang=cop>"
"<COA>"     1 ""


@patterns 1

"&"     2 "&"       % jump over SGML entities in source;

"</CO>"     0 "</foreign>"
"</COA>"    0 ""

"A"         p "&#x2C80;"    % COPTIC CAPITAL LETTER ALFA
"a"         p "&#x2C81;"    % COPTIC SMALL LETTER ALFA
"B"         p "&#x2C82;"    % COPTIC CAPITAL LETTER VIDA
"b"         p "&#x2C83;"    % COPTIC SMALL LETTER VIDA
"G"         p "&#x2C84;"    % COPTIC CAPITAL LETTER GAMMA
"g"         p "&#x2C85;"    % COPTIC SMALL LETTER GAMMA
"D"         p "&#x2C86;"    % COPTIC CAPITAL LETTER DALDA
"d"         p "&#x2C87;"    % COPTIC SMALL LETTER DALDA
"E"         p "&#x2C88;"    % COPTIC CAPITAL LETTER EIE
"e"         p "&#x2C89;"    % COPTIC SMALL LETTER EIE
"^6"        p "&#x2C8A;"    % COPTIC CAPITAL LETTER SOU
"_6"        p "&#x2C8B;"    % COPTIC SMALL LETTER SOU
"Z"         p "&#x2C8C;"    % COPTIC CAPITAL LETTER ZATA
"z"         p "&#x2C8D;"    % COPTIC SMALL LETTER ZATA
"Ê"         p "&#x2C8E;"    % COPTIC CAPITAL LETTER HATE
"ê"         p "&#x2C8F;"    % COPTIC SMALL LETTER HATE
"&Ecirc;"   p "&#x2C8E;"    % COPTIC CAPITAL LETTER HATE
"&ecirc;"   p "&#x2C8F;"    % COPTIC SMALL LETTER HATE
"TH"        p "&#x2C90;"    % COPTIC CAPITAL LETTER THETHE
"Th"        p "&#x2C90;"    % COPTIC CAPITAL LETTER THETHE
"th"        p "&#x2C91;"    % COPTIC SMALL LETTER THETHE
"I"         p "&#x2C92;"    % COPTIC CAPITAL LETTER IAUDA
"i"         p "&#x2C93;"    % COPTIC SMALL LETTER IAUDA
"K"         p "&#x2C94;"    % COPTIC CAPITAL LETTER KAPA
"k"         p "&#x2C95;"    % COPTIC SMALL LETTER KAPA
"L"         p "&#x2C96;"    % COPTIC CAPITAL LETTER LAULA
"l"         p "&#x2C97;"    % COPTIC SMALL LETTER LAULA
"M"         p "&#x2C98;"    % COPTIC CAPITAL LETTER MI
"m"         p "&#x2C99;"    % COPTIC SMALL LETTER M
"N"         p "&#x2C9A;"    % COPTIC CAPITAL LETTER NI
"n"         p "&#x2C9B;"    % COPTIC SMALL LETTER NI
"X"         p "&#x2C9C;"    % COPTIC CAPITAL LETTER KS
"x"         p "&#x2C9D;"    % COPTIC SMALL LETTER KSI
"O"         p "&#x2C9E;"    % COPTIC CAPITAL LETTER O
"o"         p "&#x2C9F;"    % COPTIC SMALL LETTER O

"P"         p "&#x2CA0;"    % COPTIC CAPITAL LETTER P
"p"         p "&#x2CA1;"    % COPTIC SMALL LETTER PI

"R"         p "&#x2CA2;"    % COPTIC CAPITAL LETTER RO
"r"         p "&#x2CA3;"    % COPTIC SMALL LETTER RO

"S"         p "&#x2CA4;"    % COPTIC CAPITAL LETTER SIMA
"s"         p "&#x2CA5;"    % COPTIC SMALL LETTER SIMA

"T"         p "&#x2CA6;"    % COPTIC CAPITAL LETTER TAU
"t"         p "&#x2CA7;"    % COPTIC SMALL LETTER TAU

"U"         p "&#x2CA8;"    % COPTIC CAPITAL LETTER UA
"Y"         p "&#x2CA8;"    % COPTIC CAPITAL LETTER UA
"u"         p "&#x2CA9;"    % COPTIC SMALL LETTER UA
"y"         p "&#x2CA9;"    % COPTIC SMALL LETTER UA

"PH"        p "&#x2CAA;"    % COPTIC CAPITAL LETTER FI
"Ph"        p "&#x2CAA;"    % COPTIC CAPITAL LETTER FI
"ph"        p "&#x2CAB;"    % COPTIC SMALL LETTER F

"CH"        p "&#x2CAC;"    % COPTIC CAPITAL LETTER KHI
"Ch"        p "&#x2CAC;"    % COPTIC CAPITAL LETTER KHI
"ch"        p "&#x2CAD;"    % COPTIC SMALL LETTER KH

"PS"        p "&#x2CAE;"    % COPTIC CAPITAL LETTER PSI
"Ps"        p "&#x2CAE;"    % COPTIC CAPITAL LETTER PSI
"ps"        p "&#x2CAF;"    % COPTIC SMALL LETTER PSI

"Ô"         p "&#x2CB0;"    % COPTIC CAPITAL LETTER OOU
"ô"         p "&#x2CB1;"    % COPTIC SMALL LETTER OOU
"&Ocirc;"   p "&#x2CB0;"    % COPTIC CAPITAL LETTER OOU
"&ocirc;"   p "&#x2CB1;"    % COPTIC SMALL LETTER OOU

"SH"        p "&#x03E2;"    % COPTIC CAPITAL LETTER SHEI
"Sh"        p "&#x03E2;"    % COPTIC CAPITAL LETTER SHEI
"sh"        p "&#x03E3;"    % COPTIC SMALL LETTER SHEI

"F"         p "&#x03E4;"    % COPTIC CAPITAL LETTER FEI
"f"         p "&#x03E5;"    % COPTIC SMALL LETTER FEI

"KH"        p "&#x03E6;"    % COPTIC CAPITAL LETTER KHEI
"Kh"        p "&#x03E6;"    % COPTIC CAPITAL LETTER KHEI
"kh"        p "&#x03E7;"    % COPTIC SMALL LETTER KHEI

"HH"        p "&#x03E8;"    % COPTIC CAPITAL LETTER HORI
"Hh"        p "&#x03E8;"    % COPTIC CAPITAL LETTER HORI
"hh"        p "&#x03E9;"    % COPTIC SMALL LETTER HORI

"J"         p "&#x03EA;"    % COPTIC CAPITAL LETTER GANGIA
"j"         p "&#x03EB;"    % COPTIC SMALL LETTER GANGIA

"Q"         p "&#x03EC;"    % COPTIC CAPITAL LETTER SHIMA
"q"         p "&#x03ED;"    % COPTIC SMALL LETTER SHIMA

"DH"        p "&#x03EE;"    % COPTIC CAPITAL LETTER DEI
"Dh"        p "&#x03EE;"    % COPTIC CAPITAL LETTER DEI
"dh"        p "&#x03EF;"    % COPTIC SMALL LETTER DEI

"^900"      p "&#x2CC0;"    % COPTIC CAPITAL LETTER SAMPI
"_900"      p "&#x2CC1;"    % COPTIC SMALL LETTER SAMPI

"XH"        p "&#x2CC8;"    % COPTIC CAPITAL LETTER AKHMIMIC KHEI
"Xh"        p "&#x2CC8;"    % COPTIC CAPITAL LETTER AKHMIMIC KHEI
"xh"        p "&#x2CC9;"    % COPTIC SMALL LETTER AKHMIMIC KHEI

"X9"        p "&#x2CCA;"    % COPTIC CAPITAL LETTER DIALECT-P HORI
"x9"        p "&#x2CCB;"    % COPTIC SMALL LETTER DIALECT-P HORI

% warn for illegal characters

"v"         e "co2sgml.pat: illegal character v"
"V"         e "co2sgml.pat: illegal character V"
"C"         e "co2sgml.pat: illegal character C"
"<"         e "co2sgml.pat: stand alone <"
"'"         e "co2sgml.pat: stand alone '"
">"         e "co2sgml.pat: stand alone >"
"\""        e "co2sgml.pat: stand alone \""
"`"         e "co2sgml.pat: stand alone `"
"["         e "co2sgml.pat: illegal character ["
"]"         e "co2sgml.pat: illegal character ]"


@patterns 2  % jumping SGML entities in source

";"         1 ";"               % end of entity: jump back
"</CO>"     0 ";</foreign>"     % closing Coptic early. Forgive.
"</COA>"    0 ";"               % closing Coptic early. Forgive.
" "         1 " "               % something unexpected, also jump back.


@end
