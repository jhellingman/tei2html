% Classical Greek in my transcription to Latin transcription according to the ALA-LC Romanization Tables.
% My notation is identical to Yannis Haralambous' notation.

% Assuming the following diphthongs: ai au ei eu oi ou hu ui, with the accents always on the second letter.

@patterns 0

"<GR>"     1 "<GR>"
"<RU>"     1 "<RU>"
"<RUX>"    1 "<RUX>"

@patterns 2 % Skip over SGML entities in Greek transcriptions

";"         1 ";"

@patterns 1

"</GR>"     0 "</GR>"
"</RU>"     0 "</RU>"
"</RUX>"    0 "</RUX>"

"&"         2 "&"

"'"         p "[**APOS**]"

@end
