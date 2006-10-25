# compiler
CC = c:/emx/bin/gcc
# include directory
INCLUDE =-Ic:/emx/include

objects = patc.o pstree.o searchfile.o

patc.exe: $(objects)
    $(CC) -o patc.exe $(objects)

# file dependencies:

patc.o            :   patc.h pstree.h searchfile.h
pstree.o          :   pstree.h
searchfile.o	  :   searchfile.h

# end
