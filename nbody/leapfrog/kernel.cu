#include <stdio.h>
#include <stdlib.h>

/* check for CUDA error */
#define CHECK_ERROR check_cuda_error(__LINE__-1, __FILE__)

/* #bodies */
static int N;

/* #threads/block */
static int TPB = 128;

/* #timesteps */
static int TIMESTEPS = 1000;
/* softening factor (square), G, \Delta t */
static const float /*EPS = 0.1f, G = 2.f,*/ DELTA_T = 0.01f;

/* acceleration */
static float4 *a_host;
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

/* leap frog integration kernel (2 particles/thread) */
__global__ void leap_frog_2p_1(float4 *a, float4 *v, float4 *r, float delta_t)
{
	int i = (threadIdx.x + __mul24(blockIdx.x, blockDim.x)) << 1;

	v[i].x += a[i].x * delta_t;
	v[i].y += a[i].y * delta_t;
	v[i].z += a[i].z * delta_t;

	r[i].x += v[i].x * delta_t;
	r[i].y += v[i].y * delta_t;
	r[i].z += v[i].z * delta_t;

	v[i+1].x += a[i+1].x * delta_t;
	v[i+1].y += a[i+1].y * delta_t;
	v[i+1].z += a[i+1].z * delta_t;

	r[i+1].x += v[i+1].x * delta_t;
	r[i+1].y += v[i+1].y * delta_t;
	r[i+1].z += v[i+1].z * delta_t;
}

/* leap frog integration kernel (2 particles/thread) */
__global__ void leap_frog_2p_2(float4 *a, float4 *v, float4 *r, float delta_t)
{
	int i = (threadIdx.x + __mul24(blockIdx.x, blockDim.x)) << 1;
	float3 v1, v2;

	v1.x = v[i].x;
	v1.y = v[i].y;
	v1.z = v[i].z;

	v2.x = v[i+1].x;
	v2.y = v[i+1].y;
	v2.z = v[i+1].z;

	v1.x += a[i].x * delta_t;
	v1.y += a[i].y * delta_t;
	v1.z += a[i].z * delta_t;

	r[i].x += v1.x * delta_t;
	r[i].y += v1.y * delta_t;
	r[i].z += v1.z * delta_t;

	v2.x += a[i+1].x * delta_t;
	v2.y += a[i+1].y * delta_t;
	v2.z += a[i+1].z * delta_t;

	r[i+1].x += v2.x * delta_t;
	r[i+1].y += v2.y * delta_t;
	r[i+1].z += v2.z * delta_t;

	v[i] = make_float4(v1.x, v1.y, v1.z, 0.f);
	v[i+1] = make_float4(v2.x, v2.y, v2.z, 0.f);
}

/* leap frog integration kernel (1 particle/thread) */
__global__ void leap_frog_1p_1(float4 *a, float4 *v, float4 *r, float delta_t)
{
	int i = threadIdx.x + __mul24(blockIdx.x, blockDim.x);

	v[i].x += a[i].x * delta_t;
	v[i].y += a[i].y * delta_t;
	v[i].z += a[i].z * delta_t;

	r[i].x += v[i].x * delta_t;
	r[i].y += v[i].y * delta_t;
	r[i].z += v[i].z * delta_t;
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

/* leap frog integration kernel (1 particle/thread) */
__global__ void leap_frog_1p_3(float4 *a, float4 *v, float4 *r, float delta_t)
{
	int i = threadIdx.x + __mul24(blockIdx.x, blockDim.x);
	extern __shared__ float3 v_tmp[];

	v_tmp[threadIdx.x].x = v[i].x;
	v_tmp[threadIdx.x].y = v[i].y;
	v_tmp[threadIdx.x].z = v[i].z;

	v_tmp[threadIdx.x].x += a[i].x * delta_t;
	v_tmp[threadIdx.x].y += a[i].y * delta_t;
	v_tmp[threadIdx.x].z += a[i].z * delta_t;

	r[i].x += v_tmp[threadIdx.x].x * delta_t;
	r[i].y += v_tmp[threadIdx.x].y * delta_t;
	r[i].z += v_tmp[threadIdx.x].z * delta_t;

	v[i] = make_float4(v_tmp[threadIdx.x].x, v_tmp[threadIdx.x].y,
	                   v_tmp[threadIdx.x].z, 0.f);
}

void init();

int main(int argc, char *argv[])
{
	cudaEvent_t start, stop;
	float time;
	int i, timestep;

	if (argc < 2) {
		printf("usage: leapfrog -N#bodies [-T#threads/block] [-S#timesteps]\n");
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
			default:
				break;
			}
		}
	}

	/*printf("N: %i, TPB: %i, TIMESTEPS: %i\n", N, TPB, TIMESTEPS);*/

	if (N % TPB) {
		printf("#bodies must be a multiple of #threads/block!\n");
		exit(1);
	}

	/* alloc host memory */
	a_host = (float4 *)malloc(N*sizeof(float4));
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
	cudaMemcpy(a, a_host, N*sizeof(float4), cudaMemcpyHostToDevice);
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

		/* leap frog */
		/*leap_frog_1p_1<<<N/TPB, TPB>>>(a, v, r, DELTA_T);*/
		leap_frog_1p_2<<<N/TPB, TPB>>>(a, v, r, DELTA_T);
		/*leap_frog_2p_1<<<N/TPB/2, TPB>>>(a, v, r, DELTA_T);*/
		/*leap_frog_2p_2<<<N/TPB/2, TPB>>>(a, v, r, DELTA_T);*/
		/*cudaMemcpy(r_host, r, N * sizeof(float4), cudaMemcpyDeviceToHost);
		printf("#1: x: %f, y: %f, z: %f\n", r_host[0].x, r_host[0].y, r_host[0].z);
		printf("#2: x: %f, y: %f, z: %f\n", r_host[1].x, r_host[1].y, r_host[1].z);*/
	}

	/* stop counter */
	cudaEventRecord(stop, 0);
	cudaEventSynchronize(stop);
	/* unit: milliseconds */
	cudaEventElapsedTime(&time, start, stop);
	CHECK_ERROR;
	/*printf("elapsed time: %f ms\n", time);*/
	printf("%f\n", time);

	/* free host memory */
	free(a_host);
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
