CC = gcc
CFLAGS = -Wall -O2
LDFLAGS = 
RM = rm -f

ifeq ($(OS),Windows_NT)
    TARGET = patc.exe
else
    TARGET = patc
endif

objects = patc.o pstree.o searchfile.o

all: $(TARGET)

$(TARGET): $(objects)
	$(CC) $(CFLAGS) -o $(TARGET) $(objects) $(LDFLAGS)

# file dependencies:
patc.o       : patc.c pstree.h searchfile.h
	$(CC) $(CFLAGS) -c patc.c

pstree.o     : pstree.c pstree.h
	$(CC) $(CFLAGS) -c pstree.c

searchfile.o : searchfile.h searchfile.c
	$(CC) $(CFLAGS) -c searchfile.c

clean :
	-$(RM) $(objects) $(TARGET)

.PHONY: all clean
