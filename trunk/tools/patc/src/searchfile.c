/* searchfile.cpp -- search for a file to be opened
 *
 * History:
 *   26-JUL-1996 created (Jeroen Hellingman)
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef TRUE
  #define TRUE   1
  #define FALSE  0
#endif

#include "searchfile.h"

static int tryopen(char *file)
{ FILE *tmp = fopen(file, "r");
  /* fprintf(stderr, "trying: %s\n", file); */
  if (tmp == NULL)
    return FALSE;
  else
  { fclose(tmp);
    return TRUE;
  }
}

char *searchfile(char *file, const char *name, const char *ext, const char *path)
{ int p = 0;         /* position in path */
  int len, i, j;

  if (file == NULL) return NULL;
  if (name == NULL) return NULL;

  strcpy(file, name);
  do
  { /* 1. attempt to open the file as given */
    if(tryopen(file)) return file;
    if(ext != NULL)
    { /* 2. strip the extention if present */
      len = strlen(file);
      for(i = len; i > 0; i--)
      { if (file[i] == '\\' || file[i] == '/') break;
        if (file[i] == '.') { file[i] = 0; break; }
      }
      /* 3. add the default extention */
      if(ext[0] != '.') strcat(file, ".");
      strcat(file, ext);
      /* 4. try again */
      if(tryopen(file)) return file;
    }
    if(path != NULL && path[p] != 0)
    { /* 5. prepend the first path */
      for(j = 0; path[p] != ';' && path[p] != 0; p++, j++)
      { file[j] = path[p];
      }
      if(path[p] == ';') p++;
      if(file[j-1] != '\\' && file[j-1] != '/') file[j++] = '\\';
      file[j] = 0;
      strcat(file, name);
    }
    else
      break;
  }
  while(TRUE);
  return NULL;
}

#ifdef TESTING

#include <dir.h>

int main()
{ char file[MAXPATH];
  if(searchfile(file, "autoexec", "bat", "D:\\test;D:\\tmp;.;..;C:\\"))
  { fprintf(stderr, "file found: %s\n", file);
  }
  getchar();
  char *path = getenv("PATH");
  if(searchfile(file, "autoexec", "bat", path))
  { fprintf(stderr, "file found: %s\n", file);
  }

  getchar();
  return 0;
}

#endif /* TESTING */

/* end of searchfile.c */
