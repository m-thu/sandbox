CC = gcc -Wall -Wextra -pedantic -std=c99 -pipe -Os
LIB = -lnfc

all: list-devices tags

tags: *.c
	ctags *.c

list-devices: list-devices.c
	$(CC) -o list-devices list-devices.c $(LIB)

clean:
	rm -f tags
	rm -f list-devices

.PHONY: all clean
