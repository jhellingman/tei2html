# Compiler settings for Windows with GCC
CC = gcc
CFLAGS = -Wall -O2
LDFLAGS = 

# Platform detection and adjustments
ifeq ($(OS),Windows_NT)
    RM = del /Q
    TARGET = patc.exe
    OBJ_EXT = .o
else
    RM = rm -f
    TARGET = patc
    OBJ_EXT = .o
endif

objects = patc$(OBJ_EXT) pstree$(OBJ_EXT) searchfile$(OBJ_EXT)

all: $(TARGET)

$(TARGET): $(objects)
	$(CC) $(CFLAGS) -o $(TARGET) $(objects) $(LDFLAGS)

# file dependencies:
patc$(OBJ_EXT)       : patc.c pstree.h searchfile.h
	$(CC) $(CFLAGS) -c patc.c

pstree$(OBJ_EXT)     : pstree.c pstree.h
	$(CC) $(CFLAGS) -c pstree.c

searchfile$(OBJ_EXT) : searchfile.h searchfile.c
	$(CC) $(CFLAGS) -c searchfile.c

clean :
	-$(RM) $(objects) $(TARGET)

.PHONY: all clean
