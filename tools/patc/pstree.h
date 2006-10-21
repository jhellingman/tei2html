/* pstree.h */

typedef struct PSTree
{   char                e;      /* element in this node */
    struct PSTree       *l;     /* left branch of PSTree */
    struct PSTree       *r;     /* right branch of PSTree */
    struct PSTree       *n;     /* PSTree for next element in pattern */
    char                *a;     /* Action with pattern that ends here */
} PSTree;

/* public operations */

int PSTinsert(PSTree **tree, char *pattern, char *action);
int PSTretract(PSTree **tree, char *pattern);
char *PSTmatch(PSTree *tree, const char *pattern, int *length);
