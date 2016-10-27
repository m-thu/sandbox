#include <stdio.h>
#include <stdlib.h>

/* check for CUDA error */
#define CHECK_ERROR check_cuda_error(__LINE__-1, __FILE__)

/* #bodies */
static int N;

/* #threads/block (leapfrog) */
static int TPB = 128;

/* #tiles (acceleration kernel) */
static int P;

/* #timesteps */
static int TIMESTEPS = 1000;
/* softening factor (square), G, \Delta t */
static const float EPS = 0.1f, G = 2.f, DELTA_T = 0.01f;

/* acceleration */
__device__ float4 *a;
/* x,y,z: position; w: mass */
static float4 *r_host;
__device__ float4 *r;
/* velocity */
static float4 *v_host;
__device__ float4 *v;

/* random number in [0,1] */
static inline float rnd()
{
	return (float)rand() / RAND_MAX;
}

/* check for CUDA error */
static void check_cuda_error(const int line, const char *file)
{
	cudaError_t e;

	e = cudaGetLastError();
	if (e != cudaSuccess) {
		printf("CUDA error: %s, line %i, file '%s'\n",
		       cudaGetErrorString(e), line, file);
		exit(1);
	}
}

/* leap frog integration kernel (1 particle/thread) */
__global__ void leap_frog_1p_2(float4 *a, float4 *v, float4 *r, float delta_t)
{
	int i = threadIdx.x + __mul24(blockIdx.x, blockDim.x);
	float3 v_tmp;

	v_tmp.x = v[i].x;
	v_tmp.y = v[i].y;
	v_tmp.z = v[i].z;

	v_tmp.x += a[i].x * delta_t;
	v_tmp.y += a[i].y * delta_t;
	v_tmp.z += a[i].z * delta_t;

	r[i].x += v_tmp.x * delta_t;
	r[i].y += v_tmp.y * delta_t;
	r[i].z += v_tmp.z * delta_t;

	v[i] = make_float4(v_tmp.x, v_tmp.y, v_tmp.z, 0.f);
}

/* body-body interaction, returns a_i */
__device__ float3 interaction(float3 ri, float4 rj, float eps)
{
	float3 rij, ai;
	float dst_sqr, cube, inv_sqrt;

	/* distance vector */
	rij.x = rj.x - ri.x;
	rij.y = rj.y - ri.y;
	rij.z = rj.z - ri.z;

	/* compute acceleration */
	dst_sqr = rij.x*rij.x + rij.y*rij.y + rij.z*rij.z + eps;
	cube = dst_sqr * dst_sqr * dst_sqr;
	inv_sqrt = rsqrtf(cube) * rj.w;

	/* acceleration a_i */
	ai.x = rij.x * inv_sqrt;
	ai.y = rij.y * inv_sqrt;
	ai.z = rij.z * inv_sqrt;

	return ai;
}

/* calculate accelerations */
__global__ void acc(float4 *r, float4 *a, float eps, float g)
{
	/* dynamically allocated shared memory */
	extern __shared__ float4 shared[];
	/* acceleration a_i */
	float3 ai = make_float3(0.f, 0.f, 0.f), tmp;
	/* position particle i */
	float3 ri;
	/* particle i */
	int i = threadIdx.x + __mul24(blockIdx.x, blockDim.x);
	int k, l;

	/* get position of particle i */
	ri.x = r[i].x;
	ri.y = r[i].y;
	ri.z = r[i].z;	

	/* loop over tiles */
	for (k = 0; k < gridDim.x; ++k) {
		/* load position and mass into shared memory */
		shared[threadIdx.x] = r[__mul24(k, blockDim.x) + threadIdx.x];
		__syncthreads();

		/* loop over particles in a tile */
		#pragma unroll 32
		for (l = 0; l < blockDim.x; ++l) {
			tmp = interaction(ri, shared[l], eps);
			ai.x += tmp.x;
			ai.y += tmp.y;
			ai.z += tmp.z;
		}

		/* wait for other threads to finish calculation */
		__syncthreads();
	}

	/* save acceleration a_i in global memory */
	a[i] = make_float4(ai.x*g, ai.y*g, ai.z*g, 0.f);
}

void init();

int main(int argc, char *argv[])
{
	cudaEvent_t start, stop;
	float time;
	int i, timestep;

	if (argc < 2) {
		printf("usage: nbody -N#bodies [-T#threads/block] [-S#timesteps] -P#tiles\n");
		exit(1);
	}

	/* get command line parameters */
	for (i = 1; i < argc; ++i) {
		if (argv[i][0] == '-') {
			switch (argv[i][1]) {
			case 'N':
				N = atoi(argv[i]+2);
				break;
			case 'T':
				TPB = atoi(argv[i]+2);
				break;
			case 'S':
				TIMESTEPS = atoi(argv[i]+2);
				break;
			case 'P':
				P = atoi(argv[i]+2);
				break;
			default:
				break;
			}
		}
	}

	/*printf("N: %i, TPB: %i, TIMESTEPS: %i, P: %i\n", N, TPB, TIMESTEPS, P);*/

	if (N % TPB) {
		printf("#bodies must be a multiple of #threads/block!\n");
		exit(1);
	}

	if (N % P) {
		printf("#bodies must be a multiple of #p!\n");
		exit(1);
	}

	/* alloc host memory */
	r_host = (float4 *)malloc(N*sizeof(float4));
	v_host = (float4 *)malloc(N*sizeof(float4));
	/* alloc device memory */
	cudaMalloc((void **)&a, N*sizeof(float4));
	cudaMalloc((void **)&r, N*sizeof(float4));
	cudaMalloc((void **)&v, N*sizeof(float4));
	CHECK_ERROR;

	/* generate initial configuration */
	srand(1);
	init();

	/* copy config to device memory */
	cudaMemcpy(r, r_host, N*sizeof(float4), cudaMemcpyHostToDevice);
	cudaMemcpy(v, v_host, N*sizeof(float4), cudaMemcpyHostToDevice);
	CHECK_ERROR;

	/* start counter */
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start, 0);

	/* integration steps */
	for (timestep = 0; timestep < TIMESTEPS; ++timestep) {
		/* update accelerations */
		acc<<<N/P, P>>>(r, a, EPS, G);

		/* leap frog */
		leap_frog_1p_2<<<N/TPB, TPB>>>(a, v, r, DELTA_T);
		/*cudaMemcpy(r_host, r, N * sizeof(float3), cudaMemcpyDeviceToHost);
		printf("#1: x: %f, y: %f, z: %f\n", r_host[0].x, r_host[0].y, r_host[0].z);
		printf("#2: x: %f, y: %f, z: %f\n", r_host[1].x, r_host[1].y, r_host[1].z);*/
	}

	/* stop counter */
	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	/* unit: milliseconds */
	cudaEventElapsedTime(&time, start, stop);
	CHECK_ERROR;
	/*printf("elapsed time: %f\n", time);
	printf("#interactions/s: %f\n", ((float)TIMESTEPS*N*N) / time * 1000);*/
	printf("%f\n", ((float)TIMESTEPS*N*N) / time * 1000);

	/* free host memory */
	free(r_host);
	free(v_host);
	/* free device memory */
	cudaFree(a);
	cudaFree(r);
	cudaFree(v);
	CHECK_ERROR;

	return 0;
}

/* generate initial configuration */
void init()
{
	int i;

	for (i = 0; i < N; ++i) {
		/* mass */
		r_host[i].w = rnd()>0.5 ? 1.f : 10.f;

		/* velocity */
		v_host[i].x = 3.f;
		v_host[i].y = rnd() * 10.f;
		v_host[i].z = -5.f;

		/* position */
		r_host[i].x = rnd() * 50.f;
		r_host[i].y = rnd() * 50.f;
		r_host[i].z = rnd() * 50.f;
	}
}
