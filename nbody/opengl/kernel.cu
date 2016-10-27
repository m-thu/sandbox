/* based on NVIDIAs simpleGL example */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include <GL/glew.h>
#include <GL/freeglut.h>

#include <cutil_inline.h>
#include <cutil_gl_inline.h>
#include <cutil_gl_error.h>
#include <vector_types.h>

#include <gsl/gsl_rng.h>

/* OpenGL */
static const int window_width = 800, window_height = 600;
int mouse_old_x, mouse_old_y;
int mouse_buttons = 0;
float rotate_x = 0., rotate_y = 0.;
float translate_z = -3.;

/* vertex buffer object */
GLuint vbo_pos;
cudaGraphicsResource_t vbo_res;

/* check for CUDA error */
#define CHECK_ERROR check_cuda_error(__LINE__-1, __FILE__)

/* #bodies */
static int N;

/* #threads/block (leapfrog) */
static int TPB = 16;

/* #tiles (acceleration kernel) */
static int P;

/* softening factor (square), G, \Delta t */
static float EPS = 1., G = 10., DELTA_T = 0.01;
static float DAMPENING = .7;

/* acceleration */
__device__ float4 *a;
/* x,y,z: position; w: mass */
static float4 *r_host;
__device__ float4 *r;
/* velocity */
static float4 *v_host;
__device__ float4 *v;

/* GSL rng */
const gsl_rng_type *T;
gsl_rng *rng;

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
__global__ void leap_frog_1p_2(float4 *a, float4 *v, float4 *r, float delta_t,
                               float dampening)
{
	int i = threadIdx.x + __mul24(blockIdx.x, blockDim.x);
	float3 v_tmp;

	v_tmp.x = v[i].x;
	v_tmp.y = v[i].y;
	v_tmp.z = v[i].z;

	v_tmp.x += a[i].x * delta_t;
	v_tmp.y += a[i].y * delta_t;
	v_tmp.z += a[i].z * delta_t;

	v_tmp.x *= dampening;
	v_tmp.y *= dampening;
	v_tmp.z *= dampening;

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

__global__ void copy_to_vbo(float4 *r, float3 *pos)
{
	int i = threadIdx.x + __mul24(blockIdx.x, blockDim.x);

	pos[i].x = r[i].x;
	pos[i].y = r[i].y;
	pos[i].z = r[i].z;
}

void init();
void cleanup();

void keyboard(unsigned char key, int /*x*/, int /*y*/)
{
	switch (key) {
	/* ESC */
	case 27:
		exit(0);
		break;
	/* reset */
	case 'r':
		init();
		cudaMemcpy(r, r_host, N*sizeof(float4), cudaMemcpyHostToDevice);
		cudaMemcpy(v, v_host, N*sizeof(float4), cudaMemcpyHostToDevice);
		CHECK_ERROR;
		break;
	/* increase gravity */
	case '+':
		G += 2.;
		break;
	/* decrease gravity */
	case '-':
		G -= 2.;
		if (G < 0.)
			G = 0.1;
		break;
	/* increase dampening */
	case 'i':
		DAMPENING -= 0.05;
		if (DAMPENING < 0.)
			DAMPENING = 0.05;
		break;
	/* decrease dampening */
	case 'd':
		DAMPENING += 0.1;
		if (DAMPENING > 1.)
			DAMPENING = 1.;
		break;
	/* increase softening */
	case 'S':
		EPS += 0.1;
		break;
	/* decrease softening */
	case 's':
		EPS -= 0.1;
		if (EPS < 0.)
			EPS = 0.1;
		break;
	/* reset to default parameters */
	case 'p':
		G = 10.;
		EPS = 1.;
		DAMPENING = 0.7;
		break;
	default:
		break;
	}
}

void mouse(int button, int state, int x, int y)
{
	if (state == GLUT_DOWN) {
		mouse_buttons |= 1<<button;
	} else if (state == GLUT_UP) {
		mouse_buttons = 0;
	}

	mouse_old_x = x;
	mouse_old_y = y;
}

void motion(int x, int y)
{
	float dx, dy;

	dx = (float)(x - mouse_old_x);
	dy = (float)(y - mouse_old_y);

	if (mouse_buttons & 1) {
		rotate_x += dy * 0.2f;
		rotate_y += dx * 0.2f;
	} else if (mouse_buttons & 4) {
		translate_z += dy * 0.01f;
	}

	mouse_old_x = x;
	mouse_old_y = y;
}

void display()
{
	float3 *pos;
	size_t size = N*sizeof(float3);

	/* run kernel */
	cudaGraphicsMapResources(1, &vbo_res, 0);
	cudaGraphicsResourceGetMappedPointer((void **)&pos, &size, vbo_res);
	acc<<<N/P, P>>>(r, a, EPS, G);
	leap_frog_1p_2<<<N/TPB, TPB>>>(a, v, r, DELTA_T, DAMPENING);
	copy_to_vbo<<<N/P, P>>>(r, pos);
	cudaGraphicsUnmapResources(1, &vbo_res, 0);

	/* rotate view */
	glClear(GL_COLOR_BUFFER_BIT);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glTranslatef(0., 0., translate_z);
	glRotatef(rotate_x, 1., 0., 0.);
	glRotatef(rotate_y, 0., 1., 0.);

	/* draw points */	
	glPointSize(1.);
	glColor4f(1., 1., 1., 1.);
	glBindBuffer(GL_ARRAY_BUFFER, vbo_pos);
	glVertexPointer(3, GL_FLOAT, 0, 0);
	glEnableClientState(GL_VERTEX_ARRAY);
	glDrawArrays(GL_POINTS, 0, N);
	glDisableClientState(GL_VERTEX_ARRAY);

	glutSwapBuffers();
	glutPostRedisplay();
}

int main(int argc, char *argv[])
{
	struct cudaDeviceProp dev_prop;
	int device;
	int i;

	if (argc < 2) {
		printf("usage: nbody -N#bodies [-T#threads/block] -P#tiles\n");
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

	/* init OpenGL */
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE);
	glutInitWindowSize(window_width, window_height);
	glutCreateWindow("N-Body");
	glutDisplayFunc(display);
	/*glutReshapeFunc(reshape);*/
	glutKeyboardFunc(keyboard);
	/*glutSpecialFunc();*/
	glutMouseFunc(mouse);
	glutMotionFunc(motion);
	glewInit();

	/* init GL */
	glClearColor(0., 0., 0., 1.);
	glDisable(GL_DEPTH_TEST);
	glViewport(0, 0, window_width, window_height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(60., (GLfloat)window_width / (GLfloat)window_height,
	               1., 100.);

	/* get CUDA device properties */
	cudaGetDevice(&device);
	cudaGetDeviceProperties(&dev_prop, device);
	cudaGLSetGLDevice(device);
	CHECK_ERROR;

	/* create VBO */
	glGenBuffers(1, &vbo_pos);
	glBindBuffer(GL_ARRAY_BUFFER, vbo_pos);
	glBufferData(GL_ARRAY_BUFFER, N*sizeof(float3), 0, GL_DYNAMIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	cudaGraphicsGLRegisterBuffer(&vbo_res, vbo_pos,
                                     cudaGraphicsMapFlagsWriteDiscard);
	CHECK_ERROR;

	/* alloc host memory */
	r_host = (float4 *)malloc(N*sizeof(float4));
	v_host = (float4 *)malloc(N*sizeof(float4));
	/* alloc device memory */
	cudaMalloc((void **)&a, N*sizeof(float4));
	cudaMalloc((void **)&r, N*sizeof(float4));
	cudaMalloc((void **)&v, N*sizeof(float4));
	CHECK_ERROR;

	/* generate initial configuration */
	T = gsl_rng_default;
	rng = gsl_rng_alloc(T);
	gsl_rng_set(rng, time(0));
	init();

	/* copy config to device memory */
	cudaMemcpy(r, r_host, N*sizeof(float4), cudaMemcpyHostToDevice);
	cudaMemcpy(v, v_host, N*sizeof(float4), cudaMemcpyHostToDevice);
	CHECK_ERROR;

	atexit(cleanup);

	glutMainLoop();
	return 0;
}

/* generate initial configuration */
void init()
{
	int i;

	for (i = 0; i < N; ++i) {
		/* mass */
		r_host[i].w = gsl_rng_uniform(rng)>0.5 ? 1. : 10.;
		/*r_host[i].w = 5.;*/

		/* velocity */
		v_host[i].x = gsl_rng_uniform(rng) * 10.;
		v_host[i].y = gsl_rng_uniform(rng) * 5.;
		v_host[i].z = -3. * gsl_rng_uniform(rng);

		/* position */
		r_host[i].x = gsl_rng_uniform(rng) * 50.;
		r_host[i].y = gsl_rng_uniform(rng) * 50.;
		r_host[i].z = gsl_rng_uniform(rng) * 50.;
	}
}

void cleanup()
{
	/* free host memory */
	free(r_host);
	free(v_host);
	/* free device memory */
	cudaFree(a);
	cudaFree(r);
	cudaFree(v);
	CHECK_ERROR;

	/* delete VBO */
	cudaGraphicsUnregisterResource(vbo_res);
	glBindBuffer(1, vbo_pos);
	glDeleteBuffers(1, &vbo_pos);

	gsl_rng_free(rng);
}
