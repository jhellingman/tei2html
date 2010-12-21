% fixgreek.pat --- fix my usage to Yannis usage.

@patterns 0

"<GR>"  1 "<GR>"
"</GR>" e "</GR> in Roman mode"

@patterns 1

"</GR>" 0 "</GR>"
"<GR>"  e "<GR> in Greek mode"

"&apos;" p "&apos;"
"&cdot;" p "&middot;"

"="     p "\\="         % escape = in source (used for macron)
"~"     p "="
"~>"    p ">="
"~<"    p "<="

"\""    e "dieresis in Greek source!!!!"
"v"     e "v in Greek source"
"V"     e "V in Greek source"
"C"     e "C in Greek source"

"|a"    p "a|"
"|h"    p "h|"
"|w"    p "w|"

"|A"    p "A|"
"|H"    p "H|"
"|W"    p "W|"

@end