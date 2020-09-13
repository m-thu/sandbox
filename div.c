#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>

// n + 10 | n^3 + 100

int main()
{
	uint64_t n;

	for (n = 0; n < 10000; ++n)
		if (((n*n*n + 100) % (n + 10)) == 0)
			printf("n = %" PRIu64 "\n", n);

	return 0;
}

/*
gcc -Wall -std=c99 -pedantic -Wextra -O3 div.c
./a.out

n = 0
n = 2
n = 5
n = 8
n = 10
n = 15
n = 20
n = 26
n = 35
n = 40
n = 50
n = 65
n = 80
n = 90
n = 140
n = 170
n = 215
n = 290
n = 440
n = 890
*/
