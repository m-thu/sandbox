CC = gcc -Wall -Wextra -pedantic -std=c99 -pipe -Os
LIB = -lnfc

all: list-devices list-tags tags

tags: *.c
	ctags *.c

list-devices: list-devices.c
	$(CC) -o list-devices list-devices.c $(LIB)

list-tags: list-tags.c
	$(CC) -o list-tags list-tags.c $(LIB)

clean:
	rm -f tags
	rm -f list-devices
	rm -f list-tags

.PHONY: all clean
