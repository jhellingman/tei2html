
objects = patc.o pstree.o searchfile.o

patc: $(objects)
	$(CC) -o patc $(objects)

# file dependencies:

patc.o       : patc.c pstree.h searchfile.h
pstree.o     : pstree.c pstree.h
searchfile.o : searchfile.h searchfile.c

clean :
	-rm $(objects) patc
