/*+

NAME: PSTree.c --- Pattern Search Tree

AUTHOR: Jeroen Hellingman

    PSTree is een verzameling routines om snel patronen in een
    multi-branch tree op te slaan en terug te vinden, zoals gebruikt
    worden voor bijvoorbeeld spellingscheckers. Bij elk patroon
    kunnen we een string opslaan.

    De worden worden letter voor letter opgeslagen in de nodes
    van de boom, waarbij de eerste node alle eerste letters,
    bevat, en de tweede node voor elk van die letters, de tweede
    letters van woorden die met die letter beginnen. Elke node
    opzich is ook weer opgebouwd als een boom.

    Per letter gebruikt deze structuur vier pointers en een
    character geheugen ruimte (op een 68000 17 bytes), maar
    als het woord 'automatisch' al is opgeslagen, hoeven we
    maar een extra letter te bewaren om 'automatische' op te
    slaan.

    Op deze structuur hebben we de volgende operaties:

    int PSTinsert(PSTree **tree, char *pattern, char *action);
        voeg pattern met action toe aan tree, *tree kan NULL zijn,
        en zal dan veranderen, resultaat: TRUE als succes, FALSE
        anders

    int PSTretract(PSTree **tree, char *pattern);
        Nog niet geimplementeerd

    char *PSTmatch(PSTree *tree, const char *pattern, int *length);
        vind de langste match beginnend bij de pattern[0] van pattern
        met een patroon in tree, resultaat: de actie bij dat patroon,
        NULL als geen actie gevonden, length bevat na afloop de lengte
        van het gematchte patroon, of 0 als geen patroon is gevonden.

HISTORY:
  04-MAY-1998 recompilation on Mac (JH)
  31-DEC-1995 Added exit on allocation failure (JH)
  09-MAY-1994 Changed filenames to all lower-case. (JH)
  05-FEB-1992 Creation (Jeroen Hellingman)

-*/

#define TEST (0)

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>

#include "pstree.h"

#ifndef TRUE
  #define TRUE (1)
  #define FALSE (0)
#endif

/* private operations */

static PSTree *PSTfindelement(PSTree *t, char c);
static PSTree *PSTfindinsertelement(PSTree **t, char c);
static void PSTpmatch(PSTree *tree, const char *pattern, char **action, int *length, int depth);

/* insert: insert p into the pattern tree:
   TRUE: success
   FALSE: failure (already available pattern, failure to allocate cell);
*/

int PSTinsert(PSTree **t, char *p, char *a)
{ PSTree *first = NULL;

  if(t == NULL || p == NULL || p[0] == '\0') /* sanity check */
    return FALSE;

  first = PSTfindinsertelement(t, p[0]);
  if(first == NULL) /* element could not be added/inserted in PSTree? */
    return FALSE;

  if(p[1] == '\0') /* p[0] last element of pattern? */
  { if(first->a == NULL) /* no action assigned yet */
    { first->a = a;
      return TRUE;
    }
    else /* i.e. pattern already in tree */
    { return FALSE;
    }
  }
  else /* not last element in pattern: insert rest of pattern */
    return PSTinsert(&(first->n), &p[1], a);
}

/* PSTfindinsertelement: search for element c, return its node
   if it can be found, create a new node with element c and all
   pointers at NULL otherwise, and return it.
   return NULL at failure.
*/

static PSTree *PSTfindinsertelement(PSTree **t, char c)
{ if(t == NULL) /* sanity check */
    return NULL;

  if(*t == NULL) /* empty tree: create new node */
  { *t = malloc(sizeof(PSTree));
    if(*t == NULL) /* malloc failed */
    { fprintf(stderr, "can't allocate in PST package\n");
      exit(1);
    }
    (*t)->e = c;
    (*t)->l = NULL;
    (*t)->r = NULL;
    (*t)->n = NULL;
    (*t)->a = NULL;
    return *t;
  }
  else
  { if((*t)->e == c) /* we found it */
      return *t;
    else if((*t)->e < c) /* then go left */
      return PSTfindinsertelement(&((*t)->l), c);
    else /* go right */
      return PSTfindinsertelement(&((*t)->r), c);
  }
}

/* PSTfindelement: search for element c, return its node
   if it can be found return NULL at otherwise.
*/

static PSTree *PSTfindelement(PSTree *t, char c)
{ if(t == NULL) /* empty tree */
    return NULL;
  else
  { if(t->e == c) /* we found it */
      return t;
    else if(t->e < c) /* then go left */
      return PSTfindelement(t->l, c);
    else /* go right */
      return PSTfindelement(t->r, c);
  }
}

char *PSTmatch(PSTree *t, const char *p, int *length)
{ char *action = NULL;
  *length = 0;
  PSTpmatch(t, p, &action, length, 1);
  return action;
}

/* remember recursion depth to determine length of match */

static void PSTpmatch(PSTree *t, const char *p, char **action, int *length, int depth)
{ PSTree *first = NULL;

  if(t == NULL || p == NULL || p[0] == '\0') /* sanity check */
    return;

  first = PSTfindelement(t, p[0]);
  if(first == NULL) /* element not found in PSTree? */
    return;

  if(first->a != NULL) /* action for pattern so-far? */
  { *length = depth;
    *action = first->a;
  }

  PSTpmatch(first->n, &p[1], action, length, depth + 1);
}



#if TEST

static void PSTshow(PSTree *t)
{ if(t == NULL)
    printf("(null)\n");
  else
  { putchar(t->e);
    if(t->a != NULL)
    { putchar('[');
      printf("%s", t->a);
      putchar(']');
    }
    PSTshow(t->n);
    putchar('L'); PSTshow(t->l);
    putchar('R'); PSTshow(t->r);
  }
}


int main()
{ char *actie = NULL;
  int len = 0;

  PSTree *t = NULL;
  PSTinsert(&t, "aap", "1");
  PSTinsert(&t, "appel", "2");
  PSTinsert(&t, "aapjes", "3");
  PSTinsert(&t, "koe", "4");
  PSTinsert(&t, "kokosnoot", "5");
  PSTinsert(&t, "akker", "6");
  PSTshow(t); puts("------------"); getchar();

  actie = PSTmatch(t, "aapjesverhaal", &len);
  if(actie != NULL) { printf("actie: (%s) lengte: %d\n", actie, len); }

  actie = PSTmatch(t, "aapjelief", &len);
  if(actie != NULL) { printf("actie: (%s) lengte: %d\n", actie, len); }

  actie = PSTmatch(t, "appelboom", &len);
  if(actie != NULL) { printf("actie: (%s) lengte: %d\n", actie, len); }

  actie = PSTmatch(t, "aster", &len);
  if(actie != NULL) { printf("actie: (%s) lengte: %d\n", actie, len); }
  else { printf("actie: NULL lengte: %d\n", actie, len); }

  return 0;
}

#endif /* TEST */

/* end of PSTree.c */

