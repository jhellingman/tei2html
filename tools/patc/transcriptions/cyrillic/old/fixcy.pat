

@patterns 0

"<RUX>"     1 "<RUX>"

@patterns 1

"&"         2 "&"           % jump over SGML entities in source;
"<"         3 "<"           % jump over SGML tags.

"</RUX>"    0 "</RUX>"

"E"         p "IE"
"e"         p "ie"

"È"         p "E"     
"è"         p "e"     

"Ë"         p "IO"
"ë"         p "io"

"JU"        p "YU"   
"Ju"        p "Yu"    
"ju"        p "yu"    

"JA"        p "YA"    
"Ja"        p "Ya"   
"ja"        p "ya"   

"EX"        p "EX"
"ex"        p "ex"

"io"        p "i{}o"
"IO"        p "I{}O"

@patterns 2  % jumping SGML entities in source

";"         1 ";"               % end of entity: jump back
" "         1 " "               % something unexpected, also jump back.

@patterns 3 % SGML-tags in Cyrillic environment

">"         1 ">"

@end
