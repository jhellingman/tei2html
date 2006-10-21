/* patc.c -- pattern processor
 * Copyright 1996, 1998 Jeroen Hellingman
 *
 * History:
 *   04-MAY-1998 recompiled on Mac (JH)
 *   26-JUL-1996 completely rewritten search for files (JH)
 *   06-JAN-1996 Removed free() in try_open() for debugging purposes (JH)
 *   31-DEC-1995 Added exit on allocation error (JH)
 *   30-DEC-1995 Added heapcheck (JH)
 *   23-DEC-1995 Further digging into stack-problems, made parser more
 *               robust, and added feedback dots. (JH)
 *   16-DEC-1995 Increased stack-size for Borland C, made most functions
 *               static, and made some big arrays static as to avoid
 *               using too much stack. (JH)
 *
 * Known problems:
 *   06-JAN-1995 Occasionally gets stuck because of a corrupted heap (JH)
 *   23-DEC-1995 Quickly runs out of stack on MS-DOS (4DOS) (JH)
 */

char *progname  = "patc";
char *version   = "v1.2.9 04-MAY-1998";
char *copyright = "Copyright 1996, 1998 Jeroen Hellingman";

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <assert.h>

#ifdef MSDOS
  #include <malloc.h>     /* MS-DOS, debug only */
#else
  #define MAXPATH 128
#endif

#ifdef MAC
  #include <console.h>
#endif

#include "args.h"
#include "pstree.h"
#include "searchfile.h"

#ifndef TRUE
  #define TRUE    (1==1)
  #define FALSE   (1==0)
#endif

#define NUMPATS   10 /* number of pattern trees */
#define PATLEN    50 /* maximum length of pattern */
#define BUFSIZE  512 /* pushback buffer size (BUFSIZE >= PATLEN) */
#define PACIFY   500 /* print '.' to stderr after this number of patterns
                        recognised */

#define DIRSEPARATOR_CHAR     '\\'
#define DIRSEPARATOR_STRING   "\\"

/* data types */

typedef struct patterntree
{ PSTree *t;      /* pattern tree for this node */
  int     r;      /* restrictive or not? */
} patterntree;

/* globals */

FILE *infile  = stdin;
FILE *outfile = stdout;
patterntree pat[NUMPATS];

char *argv0;
int  verbose = FALSE;           /* be verbose */
int  veryverbose = FALSE;       /* be very verbose */
int  debug = FALSE;             /* debugging mode */
int  wait = FALSE;              /* wait for return at end */
long linenumber = 1;            /* current line in infile */
long sourceline = 0;            /* current line in patcfile */

int _stklen = 0x7FFF;           /* for Borland C on MS-DOS only */

/* prototypes */

#ifdef OLDCODE
static FILE *try_fopen(char*, char*, char*, char*);
static char *add_suffix(char*, char*);
static char *force_suffix(char*, char*);
static char *add_path(char*, char*);
#endif

static void parsetables(FILE *patfile, char *patfilename);
static void patc(void);
static void usage(void);
static void copytexcommand(void);
static void skiptexcommand(void);
static void skiptillmatchingbrace(void);
static void skiptillchar(char c1);
static void copycomment(void);
static void skipcomment(void);
static int  readchar(void);
static void unreadchar(int);
static int  what_escape(const char *s, char *result);
static void PUSHBACK(char*);
static void feedback(void);

/* main */

int main(int argc, char** argv)
{
  FILE *patfile     = NULL;
  char *patfilename = NULL;
  char *patcdir     = ".;..;\\etc\\patc";
  char *patcsuffix  = "pat";
  char *infilename  = "stdin";
  char *outfilename = "stdout";
  char *tmp;
  char path[MAXPATH];

#ifdef MAC
	argc = ccommand(&argv);
#endif

#ifdef MSDOS
  /* test our memory structure */
  if(heapcheck() != _HEAPOK)
  { fprintf(stderr, "Heapcheck (1) fails\n");
    exit(1);
  }
#endif

  ARGBEGIN
  { case 'p' : patfilename = ARGF(); break;
    case 'D' : debug = TRUE; verbose = TRUE; break;
    case 'V' : veryverbose = TRUE;
	 case 'v' : verbose = TRUE; break;
	 case 'w' : wait = TRUE; break;
    default  : break;
  }
  ARGEND;

  if(verbose) fprintf(stderr, "%s %s %s\n", progname, version, copyright);
  if(debug) fputs("debugging mode...\n", stderr);
#ifdef MSDOS
  if(debug) fprintf(stderr, "%u stack, %ld memory\n", (unsigned)stackavail(), coreleft());
#endif

  tmp = getenv("PATCDIR");
  if(tmp != NULL) patcdir = tmp;
  if(debug) fprintf(stderr, "PATCDIR=%s\n", patcdir);

  if(argc < 1) usage(); /* we need to read from a file */

  if(patfilename == NULL) usage();

  if(searchfile(path, patfilename, patcsuffix, patcdir) != NULL)
  { if(debug) fprintf(stderr, "trying to open pattern file %s\n", path); 
    patfile = fopen(path, "r");
  }
  if(patfile == NULL)
  { fprintf(stderr, "%s: can't open pattern file %s\n", progname, patfilename);
    exit(2);
  }
  parsetables(patfile, patfilename);
  if(debug) fprintf(stderr, "pattern file read\n");
  fclose(patfile);

  if(argc >= 1)
  { infilename = argv[0];
    infile = fopen(infilename, "r");
    if(infile == NULL)
    { fprintf(stderr, "%s: can't open %s\n", progname, infilename);
      exit(2);
    }
  }
  if(verbose) fprintf(stderr, "reading from %s\n", infilename);

  if(argc >= 2)
  { outfilename = argv[1];
    outfile = fopen(outfilename, "w");
    if(outfile == NULL)
    { fprintf(stderr, "%s: can't create %s\n", progname, outfilename);
      exit(2);
    }
  }
  if(verbose) fprintf(stderr, "writing to %s\n", outfilename);

#ifdef MSDOS
  if(heapcheck() != _HEAPOK)
  { fprintf(stderr, "Heapcheck (2) fails\n");
    exit(1);
  }
#endif

  patc();

  if(argc >= 1) fclose(infile);
  if(argc >= 2) fclose(outfile);

  if(wait)
  { fprintf(stderr, "please press ENTER to return to the shell\n");
	 getchar();
  }
  return 0;
}

static void usage()
{ fprintf(stderr, "usage: %s [-v] [-p patfile] infile outfile\n", progname);
  exit(1);
}

/* parsing functions */

static int readline(char *l, FILE* infile)
{ int i = 0;
  int c = fgetc(infile);
  sourceline++;
  while(isspace(c) && c != '\n' && c != EOF)
    c = fgetc(infile); /* skip whitespace */
  if(c == '%')
    while(c != '\n' && c != EOF)
      c = fgetc(infile); /* skip comments */
  while(c != '\n' && c != EOF && i < BUFSIZE)
  { l[i] = (c == EOF) ? '\0' : (int) c;
    i++;
    c = getc(infile);
  }
  l[i] = '\0';    /* NULL-terminate */
  return (c != EOF);
}

static int getword(char *s, char *d)
{ int i = 0, j = 0;
  while(isspace(s[i]) && s[i] != '\0')
    i++;
  while(isalnum(s[i]))
  { d[j] = s[i];
    j++; i++;
  }
  d[j] = '\0';
  return i;
}

static int getquotedstring(const char *s, char *d)
{ int i = 0;  /* no of chars read in source */
  int j = 0;  /* no of chars inserted in destination */
  while(isspace(s[i]) && s[i] != '\0')
    i++;
  if(s[i] == '"')
  { i++;
    while(s[i] != '"')
    { if(s[i] == '\\') /* escape char */
        i += what_escape(&s[i], &d[j]);
      else
      { d[j] = s[i];
      }
      j++; i++;
      if(s[i] == '\0')
      { fprintf(stderr, "unmatched quote in line %ld\n", sourceline);
        break;
      }
    }
  }
  d[j] = '\0';    /* NULL-terminate */
  i++;            /* skip final " */
  return i;
}

/* Find out what escape sequence is used. If non can be found, we just
   forget about the backslash. Interprete numbers up to 255/177/FF
*/

#define UNSIGNED(t) (char)(((t) < 0) ? (t) + 256 : (t))

static int what_escape(const char *s, char *result)
{ int i = 1;      /* length of escape sequence read */
  int ok = TRUE;
  int t = 0;      /* temporary result */

  switch(s[1])
  { case '"':   *result = '"';  break;
    case '\\':  *result = '\\'; break;
    case 't':   *result = '\t'; break;
    case 'n':   *result = '\n'; break;
    case 'b':   *result = '\b'; break;
    case 'h':   /* hexadecimal */
      while(i < 3 && ok)
      { i++;
        if(s[i]>='0' && s[i]<='9') t = t * 16 + (s[i] - '0');
        else if(s[i]>='A' && s[i]<='F') t = t * 16 + (s[i] - 'A') + 10;
        else if(s[i]>='a' && s[i]<='f') t = t * 16 + (s[i] - 'a') + 10;
        else
        { if(i==2) /* no number after \h */
            *result = 'h';
          else /* short number after \h */
            *result = UNSIGNED(t);
          i--;
          ok = FALSE;
        }
      }
      if(ok) *result = UNSIGNED(t);
      break;
    case 'd':   /* decimal */
      while(i < 4 && ok)
      { i++;
        if(s[i]>='0' && s[i]<='9') t = t * 10 + (s[i] - '0');
        else
        { if(i==2) /* no number after \d */
            *result = 'd';
          else /* short number after \d */
            *result = UNSIGNED(t);
          i--;
          ok = FALSE;
        }
      }
      if(ok) *result = UNSIGNED(t);
      break;
    case '0':    /* try octal interpretation */
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
      i--;
      while(i < 3 && ok)
      { i++;
        if(s[i]>='0' && s[i]<='7') t = t * 8 + (s[i] - '0');
        else
        { if(i==1) /* no number after \ */
            *result = s[i];
          else /* short number after \ */
          { *result = UNSIGNED(t);
            i--;
          }
          ok = FALSE;
        }
      }
      if(ok) *result = UNSIGNED(t);
      break;
    default:
      fprintf(stderr, "unknown escape \\%c in line %ld\n", s[1], sourceline);
  }
  return i;
}

static void parsetables(FILE *patfile, char *patfilename)
{ static char line[BUFSIZE];
  static char command[BUFSIZE];
  static char pattern[BUFSIZE];
  static char action[BUFSIZE];
  char *tmp;
  int pos = 1;
  char notEOF = TRUE;
  int currentpat = 0; /* current patterntree under construction */

  while(notEOF)
  { notEOF = readline(line, patfile);
    pos = 0;
    switch(line[0])
    { case '\0':  /* empty line */
       break;
      case '@':   /* command */
        pos++;
        pos += tolower(getword(&line[1], command));
        if(strcmp(command, "patterns") == 0)
        { pos += getword(&line[pos], command);
          currentpat = atoi(command);
          pat[currentpat].r = FALSE;
        }
        else if(strcmp(command, "rpatterns") == 0)
        { pos += getword(&line[pos], command);
          currentpat = atoi(command);
          pat[currentpat].r = TRUE;
        }
        else if(strcmp(command, "end") == 0) return;
        else
        { fprintf(stderr, "Error: unknown command %s in line %ls\n", command, sourceline);
          exit(1);
        }
        break;
      case '"':   /* action */
        pos += getquotedstring(line, pattern);
        pos += getword(&line[pos], command);
        pos += getquotedstring(&line[pos], &action[1]);
        action[0] = command[0];
        tmp = malloc(strlen(action) + 3); /* made one longer than necessary */
        if(tmp == NULL)
        { fprintf(stderr, "Error: cannot allocate\n");
          exit(3);
        }
        strcpy(tmp, action);
        PSTinsert(&pat[currentpat].t, pattern, tmp);
        break;
      default:
        fprintf(stderr, "Error: illegal line (%ld) '%s' in %s\n",
                                        sourceline, line, patfilename);
        fprintf(stderr, "I will forget it\n");
    }
  }
}

/* main pattern matching loop */

static void patc()
{ static char ps[PATLEN+1]; /* pattern to be search for */
  char *action;             /* action with pattern */
  int len = PATLEN;         /* length of found pattern; part of ps to be read */
  int current = 0;          /* current active patterntree */
  int i, j;                 /* counters */

  while(TRUE)
  { if(veryverbose) feedback();
    /* fill pattern */
    for(i = 0, j = len; j < PATLEN; i++, j++) ps[i] = ps[j];
    for(i = PATLEN - len; i < PATLEN; i++)
    { int c = readchar();
      ps[i] = (c == EOF) ? '\0' : c;
    }
    ps[PATLEN] = '\0'; /* NULL-terminate */
    if(ps[0] == '\0') break;

    /* find action */

    action = PSTmatch(pat[current].t, ps, &len);
    if(len == 0)
    { if(pat[current].r)   /* restrictive? */
      { if(verbose)        /* complain */
          fprintf(stderr, "Warning: illegal character '%c' near line %d\n", ps[0], linenumber);
      }
      else /* copy silently */
      { fputc(ps[0], outfile);
      }
      len = 1;
    }
    else /* do action */
    { switch(action[0])
      { case 'p':
          fputs(&action[1], outfile);
          break;
        case 'c':
          PUSHBACK(ps);
          len = PATLEN;
          copycomment();
          break;
        case 't':
          PUSHBACK(ps);
          len = PATLEN;
          copytexcommand();
          break;
        case 'T':
          PUSHBACK(ps);
          len = PATLEN;
          skiptexcommand();
          break;
        case 's':
          PUSHBACK(ps);
          len = PATLEN;
          skipcomment();
          break;
        case 'f':
          /* do nothing */
          break;
        case 'e':
          fprintf(stderr, "Error: %s near line %ld\n", &action[1], linenumber);
          break;
        case 'S':
          PUSHBACK(ps);
          len = PATLEN;
          skiptillchar(action[1]);
          break;
        case 'B':
          PUSHBACK(ps);
          len = PATLEN;
          skiptillmatchingbrace();
          break;
        case '0': current = 0; fputs(&action[1], outfile); break;
        case '1': current = 1; fputs(&action[1], outfile); break;
        case '2': current = 2; fputs(&action[1], outfile); break;
        case '3': current = 3; fputs(&action[1], outfile); break;
        case '4': current = 4; fputs(&action[1], outfile); break;
        case '5': current = 5; fputs(&action[1], outfile); break;
        case '6': current = 6; fputs(&action[1], outfile); break;
        case '7': current = 7; fputs(&action[1], outfile); break;
        case '8': current = 8; fputs(&action[1], outfile); break;
        case '9': current = 9; fputs(&action[1], outfile); break;
        default:
          fprintf(stderr, "Internal error: unknown action\n");
          exit(10);
      } /* switch */
    } /* else */
  } /* while */
  if(current != 0)
    fprintf(stderr, "Warning: mode = %d at end of file\n", current);
} /* patc() */

/* special command implementing functions */

static void skiptillchar(char c1)
{ int c2;
  do
  { c2 = readchar();
    if(c2 == EOF) return;
  } while(c2 != c1);
}

static void skiptillmatchingbrace()
/* skip a TeX group enclosed in braces.
 * next brace on input opens the group to skip
 */
{ int i = 1;
  int c;
  do
  { c = readchar();
    if(c == EOF) return;
  } while(c != '{');
  while(i > 0)
  { c = readchar();
    if(c == '{') i++;
    if(c == '}') i--;
    if(c == EOF) return;
  }
}

static void copytexcommand()
/* copy TeX commmand, including preceding \
 * this will work in plain TeX and LaTeX
 */
{ int c = readchar();
  if(c == '\\')
  { fputc(c, outfile);
    c = readchar();
    if(isalpha(c))
    { while(isalpha(c))
      { fputc(c, outfile);
        c = readchar();
      }
      unreadchar(c);
    }
    else
      fputc(c, outfile);
  }
  else
    unreadchar(c);
}

static void skiptexcommand()
/* skip TeX commmand, including preceding \
 * this will work in plain TeX and LaTeX
 */
{ int c = readchar();
  if(c == '\\')
  { c = readchar();
    if(isalpha(c))
    { while(isalpha(c))
      { c = readchar();
      }
      unreadchar(c);
    }
  }
  else
    unreadchar(c);
}

static void copycomment()
{ int c = readchar();
  if(c == '%')
  { while(c != '\n' && c != EOF)
    { fputc(c, outfile);
      c = readchar();
    }
    fputc('\n', outfile);
  }
  else
    unreadchar(c);
}

static void skipcomment()
{ int c = readchar();
  if(c == '%')
  { while(c != '\n' && c != EOF) c = readchar();
  }
  else
    unreadchar(c);
}

/* pacifier (give some feedback to the user during processing) */

static void feedback(void)
{ static int count = 0;
  if(count == PACIFY)
  { putc('.', stderr);
    count = 0;
  }
  else count++;
}

/* file access with buffer */

static void PUSHBACK(char *c)
/* push the characters in string c back into the inputstream, works
 * with the pair of functions readchar() and unreadchar()
 */
{ int i = (int)strlen(c)-1;
  for( ;i >= 0; i--) unreadchar((int)c[i]);
}

static int fbuffer[BUFSIZE];        /* buffer for file operations */
static int last = 0;                /* last + 1 used in fbuffer */

static int readchar()
{ int result;

  if(last==0) /* niets in buffer */
    result = fgetc(infile);
  else /* pak first uit buffer */
  { last--;
    result = fbuffer[last];
  }
  if(result == '\n') linenumber++;
  return result;
}

static void unreadchar(int c)
{ if(last == BUFSIZE)
  { fprintf(stderr, "%s: push-back file buffer overflow\n", progname);
    exit(1);
  }
  else /* insert after last in buffer */
  { fbuffer[last] = c;
    last++;
    if(c == '\n') linenumber--;
  }
}


#ifdef OLDCODE

/* file name functions */

static FILE *try_fopen(char *name, char *suffix, char *path, char *flags)
{ FILE *result;
  char *tmp1, *tmp2;

  tmp1 = tmp2 = NULL;
  result = fopen(name, flags);
  if(debug) fprintf(stderr, "1. trying to open %s\n", name);
  if(result == NULL)
  { tmp1 = add_suffix(name, suffix);
    result = fopen(tmp1, flags);
    if(debug) fprintf(stderr, "2. trying to open %s\n", tmp1);
    if(result == NULL)
    { tmp2 = add_path(name, path);
      result = fopen(tmp2, flags);
      if(debug) fprintf(stderr, "3. trying to open %s\n", tmp2);
      if(result == NULL)
      { /* free(tmp2); TODO DEBUG */
        tmp2 = add_path(tmp1, path);
        result = fopen(tmp2, flags);
        if(debug) fprintf(stderr, "4. trying to open %s\n", tmp2);
      }
    }
  }
  /* if(tmp1 != NULL) free(tmp1); TODO DEBUG */
  /* if(tmp2 != NULL) free(tmp2); TODO DEBUG */
  return result;
}

/* add suffix to name if it has none given */

static char *add_suffix(char* name, char *suffix)
{ int i;
  int len0 = strlen(name);
  int len1 = strlen(suffix);
  char *result;

  /* seek for a dot, if found we already have a suffix, so return name */
  for(i=0; i<len0; i++)
  { if(name[i] == '.') return name;
  }
  result = malloc(len0 + len1 + 2);
  assert(result != NULL);
  strcpy(result, name);
  result[len0] = '.'; result[len0+1] = '\0';
  strcat(result, suffix);
  return result;
}

/* add suffix, remove orginal suffix if given */

static char *force_suffix(char* name, char *suffix)
{ int i;
  int len0 = strlen(name);
  int len1 = strlen(suffix);
  char *result;

  /* seek for dot, if found break */
  for(i=0; i<len0; i++)
  { if(name[i] == '.') break;
  }
  result = malloc(len0 + len1 + 2);
  assert(result != NULL);
  strcpy(result, name);
  result[i] = '.'; result[i+1] = '\0';
  strcat(result, suffix);
  return result;
}

/* place a path in front of a file name */

static char *add_path(char *filename, char *path)
{
  int len1, len2;
  char *result;
  if(path == NULL) return filename;
  len1 = strlen(path);
  len2 = strlen(filename);
  result = malloc(len1 + len2 + 2);         /* one for possible '/', one for '\0' */ 
  assert(result != NULL);
  strcpy(result, path);
  if(path[len1-1] != DIRSEPARATOR_CHAR)     /* add backslash if not already there */
    strcat(result, DIRSEPARATOR_STRING);
  strcat(result, filename);
  return result;
}

#endif /* OLDCODE */

/* end of patc.c */
