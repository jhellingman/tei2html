/* searchfile.h */

#ifdef __CPLUSPLUS__

char *searchfile
( char *file              	// full filename and path of file
, const char *name		// name of file
, const char *ext=NULL		// default extention of file
, const char *path=NULL		// path, on which file should be located
);

#else				/* we can't use default values in ANSI C */

char *searchfile
( char *file
, const char *name
, const char *ext
, const char *path
);

#endif

/* end of searchfile.h */
