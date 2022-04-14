#include "gpu_bitmap.h"
#include "gpu_bitmap.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define WIDTH 800
#define HEIGHT 600
#define DIM 16

#define K 3
#define G 28
#define M 200


__global__ void color(float *t, uchar4 *buf) {
	int x = blockIdx.x * blockDim.x + threadIdx.x;
	int y = blockIdx.y * blockDim.y + threadIdx.y;
	if (x < WIDTH && y < HEIGHT) {
		int offset = y * WIDTH + x;
		float t3 = 3 * t[offset];
		float rouge, vert, blue;
		if (t3 == 1) {
			rouge = t3 * 255;vert= 2;blue = 0;
		} else {
			rouge = 255;vert = (t3 - 1) * 255;blue = 0;
		}
		buf[offset].x = rouge;
		buf[offset].y = vert;
		buf[offset].z = blue;
		buf[offset].w = 255;
	}
}

__global__ void diffuse(float *t_current, float *t_next) {
	int x = blockIdx.x * blockDim.x + threadIdx.x;
	int y = blockIdx.y * blockDim.y + threadIdx.y;
	int z = blockIdx.z * blockDim.z + threadIdx.z;
	if (x < WIDTH && y < HEIGHT) {
		int offset = y * WIDTH + x;
		int haut = y == HEIGHT - 1 ? offset : offset + WIDTH;
		int haut_gauche;
		
		if (y == HEIGHT - 1 || x == 0 )haut_gauche = offset;
		else haut_gauche = offset + WIDTH;

	  	int gauche = x == 0 ? offset : offset - 1;
    		int bas_gauche = (x == 0 || y == 0) ? offset : offset - WIDTH - 1;
		int bas = y == 0 ? offset : offset - WIDTH;
		int bas_droite = (y == 0 || x == WIDTH -1) ? offset : offset - WIDTH + 1;
		int droite = x == WIDTH - 1 ? offset : offset + 1;
		int haut_droite  = (y == 0 || x == WIDTH -1 ) ? offset : offset - WIDTH + 1;


		int vie = (t_current[haut] == 0 ? 0:1) +(t_current[bas] == 0 ? 0:1)+
		(t_current[gauche] == 0 ? 0:1)+(t_current[droite] == 0 ? 0:1) +
		(t_current[haut_gauche] == 0 ? 0:1) +
		(t_current[haut_droite] == 0 ? 0:1) + (t_current[bas_gauche] == 0 ? 0:1)+(t_current[bas_droite] == 0 ? 0:1) ;
				if(t_current[offset] == 0){
					    if(vie == 3)t_next[offset] = 1;
						else t_next[offset] = 0;			
				}
		    	if(t_current[offset] == 1){
						if(vie == 2 || vie == 3)t_next[offset] = 1;
						else t_next[offset] = 0;		
				}
		t_next[offset] = (1 - 4 * K) * t_current[offset] + K * (t_current[haut] + t_current[bas] + t_current[gauche] + t_current[droite]);
	}
}

struct Donnee {
	float *t1,*t2;
	dim3 blocks,threads;
};
void clean_callback(Donnee *donnee) {
	HANDLE_CUDA_ERR(cudaFree(donnee->t1));
	HANDLE_CUDA_ERR(cudaFree(donnee->t2));
}

void render_callback(uchar4 *buf, Donnee *donnee, int ticks) {
	diffuse<<<donnee->blocks, donnee->threads>>>(donnee->t1, donnee->t2);
	diffuse<<<donnee->blocks, donnee->threads>>>(donnee->t2, donnee->t1);
	color<<<donnee->blocks, donnee->threads>>>(donnee->t1, buf);

}

int main() {
	Donnee donnee;
	GPUBitmap bitmap(WIDTH, HEIGHT, &donnee, "Automate cellulaire");

	size_t taille = WIDTH * HEIGHT * sizeof(float);
	float *t_initial = (float *)calloc(WIDTH * HEIGHT, sizeof(float));
	srand(time(NULL));

	for (int x = 0; x < WIDTH; x++) {
		for (int y = 0; y < HEIGHT; y++) {
				int r = rand();
				if(r%2 == 0)t_initial[y * WIDTH + x] = 1;
				else t_initial[y * WIDTH + x] = 0;
		}

	}
	donnee.blocks = dim3((WIDTH + DIM - 1) / DIM, (HEIGHT + DIM - 1) / DIM);
	donnee.threads = dim3(DIM, DIM);
	HANDLE_CUDA_ERR(cudaMalloc(&donnee.t1, taille));
	HANDLE_CUDA_ERR(cudaMalloc(&donnee.t2, taille));
	HANDLE_CUDA_ERR(cudaMemcpy(donnee.t1, t_initial, taille, cudaMemcpyHostToDevice));
	bitmap.animate((void (*)(uchar4*, void*, int))render_callback, (void (*)(void*))clean_callback);
	return 0;
}
