GCC_WARNINGS:=-Wall -Wextra -pedantic
GCC_OPTFLAGS:=-O3 -march=native -mtune=native -fomit-frame-pointer
CFLAGS:=$(GCC_WARNINGS) $(GCC_OPTFLAGS) -pipe
CFLAGS+=-lm

CC:=gcc

nbody_cpu: nbody_cpu.c
	$(CC) $(CFLAGS) -o $@ $<

profile: nbody_cpu.c
	$(CC) $(CFLAGS) -fprofile-generate -o nbody_cpu_profile nbody_cpu.c
	./nbody_cpu_profile 10000

optimized: nbody_cpu.c
	$(CC) $(CFLAGS) -fprofile-use -o nbody_cpu_opt nbody_cpu.c

clean:
	rm -f nbody_cpu nbody_cpu_profile nbody_cpu_opt nbody_cpu.gcda

.PHONY: clean
