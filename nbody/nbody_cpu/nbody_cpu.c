#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

typedef struct {
	float x, y, z;
} float3;

typedef struct {
	float x, y, z, w;
} float4;

/* #bodies */
long N;

/* #timesteps */
static const long TIMESTEPS = 100;
/* softening factor (square), G, \Delta t */
static const float EPS = 0.1, G = 2., DELTA_T = 0.01;

/* acceleration */
float3 *a;
/* mass */
float *m;
/* position */
float3 *r;
/* velocity */
float3 *v;

/* random number in [0,1] */
static inline float rnd()
{
	return (float)rand() / RAND_MAX;
}

void init();

int main(int argc, char *argv[])
{
	clock_t start, stop;
	double time;
	long i, j, timestep;

	float3 rij, ai;
	float dst_sqr, cube, inv_sqrt;

	if (argc != 2) {
		printf("usage: nbody_cpu #bodies\n");
		exit(1);
	}

	N = atol(argv[1]);

	/* alloc host memory */
	a = (float3 *)malloc(N*sizeof(float3));
	m = (float *)malloc(N*sizeof(float));
	r = (float3 *)malloc(N*sizeof(float3));
	v = (float3 *)malloc(N*sizeof(float3));

	srand(1);
	init();

	/* measure execution time */
	start = clock();

	/* integration steps */
	for (timestep = 0; timestep < TIMESTEPS; ++timestep) {
		/* update accelerations */
		for (i = 0; i < N; ++i) {
			ai.x = 0;
			ai.y = 0;
			ai.z = 0;

			for (j = 0; j < N; ++j) {
				/* distance vector */
				rij.x = r[j].x - r[i].x;
				rij.y = r[j].y - r[i].y;
				rij.z = r[j].z - r[i].z;
				/* compute acceleration */
				dst_sqr = rij.x * rij.x +
				     rij.y * rij.y + rij.z * rij.z + EPS;
				cube = dst_sqr * dst_sqr * dst_sqr;
				inv_sqrt = 1. / sqrtf(cube);
				inv_sqrt *= m[j];
				/* acceleration a_i */
				ai.x += rij.x * inv_sqrt;
				ai.y += rij.y * inv_sqrt;
				ai.z += rij.z * inv_sqrt;
			}

			/* store result */
			a[i].x = G * ai.x;
			a[i].y = G * ai.y;
			a[i].z = G * ai.z;
		}

		/* leap frog */
		for (i = 0; i < N; ++i) {
			/* step with constant coordinates */
			v[i].x = v[i].x + a[i].x * DELTA_T;
			v[i].y = v[i].y + a[i].y * DELTA_T;
			v[i].z = v[i].z + a[i].z * DELTA_T;
			/* step with constant velocities */
			r[i].x = r[i].x + v[i].x * DELTA_T;
			r[i].y = r[i].y + v[i].y * DELTA_T;
			r[i].z = r[i].z + v[i].z * DELTA_T;
		}
		/*printf("#1: x: %f, y: %f, z: %f\n", r[0].x, r[0].y, r[0].z);
		printf("#2: x: %f, y: %f, z: %f\n", r[1].x, r[1].y, r[1].z);*/
	}

	stop = clock();
	time = (double)(stop - start) / CLOCKS_PER_SEC;
	/*printf("elapsed time: %f\n", time);
	printf("interactions/second: %f\n", (TIMESTEPS*(N*N))/time);*/
	printf("%li\t%f\n", N, (TIMESTEPS*(N*N))/time);

	/* free host memory */
	free(a);
	free(m);
	free(r);
	free(v);

	return 0;
}

/* generate initial configuration */
void init()
{
	long i;

	for (i = 0; i < N; ++i) {
		/* mass */
		m[i] = rnd()>0.5 ? 1. : 10.;

		/* velocity */
		v[i].x = 3.;
		v[i].y = rnd() * 10;
		v[i].z = -5.;

		/* position */
		r[i].x = rnd() * 50;
		r[i].y = rnd() * 50;
		r[i].z = rnd() * 50;
	}
}
