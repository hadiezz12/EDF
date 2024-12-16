# Compiler and flags
CC = gcc
CFLAGS = -Wall -Werror -g

# Targets
all: main

# Linking the executable
main: main.o avl_tree.o
	$(CC) $(CFLAGS) -o main main.o avl_tree.o

# Compiling the main file
main.o: main.c avl_tree.h
	$(CC) $(CFLAGS) -c main.c

# Compiling the AVL tree implementation
avl_tree.o: avl_tree.c avl_tree.h
	$(CC) $(CFLAGS) -c avl_tree.c

# Cleaning up generated files
clean:
	rm -f *.o main
