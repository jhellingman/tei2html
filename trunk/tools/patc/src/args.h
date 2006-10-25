/*
 *  plan 9 argument parsing
 */
extern char *argv0;

#define ARGBEGIN    for((argv0? 0: (argv0=*argv)),argv++,argc--;\
                    argv[0] && argv[0][0]=='-' && argv[0][1];\
                    argc--, argv++) {\
                    char *_args, *_argt, _argc;\
                    _args = &argv[0][1];\
                    if(_args[0]=='-' && _args[1]==0){\
                        argc--; argv++; break;\
                    }\
                    _argc=0;while(*_args) switch(_argc=*_args++)
#define ARGEND      if(_argc);}
#define ARGF()      (_argt=_args, _args="",\
                    (*_argt? _argt: argv[1]? (argc--, *++argv): 0))
#define ARGC()      _argc



