#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>

/*

           !
 ( a b )^2 = ( aa bb )
 ( c d )     ( cc dd )

 ( a b ) * ( a b ) = ( a*a + b*c  a*b + b*d )
 ( c d )   ( c d )   ( c*a + d*c  c*b + d*d )

*/

int main()
{
	uint64_t a, b, c, d;
	uint64_t x11, x12, x21, x22;

	for (a = 0; a < 10; ++a)
		for (b = 0; b < 10; ++b)
			for (c = 0; c < 10; ++c)
				for (d = 0; d < 10; ++d) {
					x11 = a*a + b*c;
					x12 = a*b + b*d;
					x21 = c*a + d*c;
					x22 = c*b + d*d;

					if ((a*11 == x11) &&
					    (b*11 == x12) &&
					    (c*11 == x21) &&
					    (d*11 == x22)) {

						printf(" ( %"PRIu64" %"PRIu64" )\n", a, b);
						printf(" ( %"PRIu64" %"PRIu64" )\n\n", c, d);
					}
				}

	return 0;
}

/*
gcc -Wall -std=c99 -pedantic -Wextra -O3 matsq.c
./a.out

 ( 0 0 )
 ( 0 0 )

 ( 2 2 )
 ( 9 9 )

 ( 2 3 )
 ( 6 9 )

 ( 2 6 )
 ( 3 9 )

 ( 2 9 )
 ( 2 9 )

 ( 3 3 )
 ( 8 8 )

 ( 3 4 )
 ( 6 8 )

 ( 3 6 )
 ( 4 8 )

 ( 3 8 )
 ( 3 8 )

 ( 4 4 )
 ( 7 7 )

 ( 4 7 )
 ( 4 7 )

 ( 5 5 )
 ( 6 6 )

 ( 5 6 )
 ( 5 6 )

 ( 6 5 )
 ( 6 5 )

 ( 6 6 )
 ( 5 5 )

 ( 7 4 )
 ( 7 4 )

 ( 7 7 )
 ( 4 4 )

 ( 8 3 )
 ( 8 3 )

 ( 8 4 )
 ( 6 3 )

 ( 8 6 )
 ( 4 3 )

 ( 8 8 )
 ( 3 3 )

 ( 9 2 )
 ( 9 2 )

 ( 9 3 )
 ( 6 2 )

 ( 9 6 )
 ( 3 2 )

 ( 9 9 )
 ( 2 2 )
*/
