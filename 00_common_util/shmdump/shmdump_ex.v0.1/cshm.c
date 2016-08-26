/************************************************************************/
/* cshm -- simple shared memory tool. create/remove/attach_and_fill/dump 
/* 
/* This program is free software, under GPLv2.
/* Copyleft (C)  T.Kondoh, 2013
/************************************************************************/

/* 
 * Warning! Size of shared memory is fixed value. see "#define SHMSIZE"
 * 
 * command examples (use this with ipcs)
 *   create  :  cshm c 0x00001234 
 *   attach  :  cshm a 0x00001234 
 *   dump    :  cshm x 0x00001234 16
 *   remove  :  cshm r 0x00001234 
 */

#include <stdio.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <string.h>
#include <stdlib.h>
#include <arpa/inet.h>

#define SHMSIZE 4096


unsigned int rotate(unsigned int x, int n)
{
	return (x << n) | (x >> (sizeof(x) - n));
}


unsigned int shuffle(unsigned int x)
{
	x = ((x & 0x0000FF00) << 8) | ((x >> 8) & 0x0000FF00) | (x & 0xFF0000FF);
	x = ((x & 0x00F000F0) << 4) | ((x >> 4) & 0x00F000F0) | (x & 0xF00FF00F);
	x = ((x & 0x0C0C0C0C) << 2) | ((x >> 2) & 0x0C0C0C0C) | (x & 0xC3C3C3C3);
	x = ((x & 0x22222222) << 1) | ((x >> 1) & 0x22222222) | (x & 0x99999999);
	
	return x;
}




void fill_shm(unsigned char * p, size_t n)
{
	int i;
	unsigned int num;

	/*
	for (i = 0; i < n / 4; i++) {
		num = shuffle(i + 0x01020408);
		num = rotate(num, 24);
		num = shuffle(num);
		*(unsigned int *)p = num;
		p += sizeof(unsigned int);
	}
	for (i = 0; i < n % 4; i++) {
		*p++ = i;
	} 
	*/

	for (i = 0; i < n; i++)
		p[i] = i;

	return;
}




void dump(unsigned char * p, size_t n)
{
	int i;
	for (i = 0; i < n; i++) {
		if (i % 16 == 0)
			printf("%016x: ", i);
		printf("%02x", p[i]);
		if (i % 4 == 3)
			printf(" ");
		if (i % 16 == 15)
			printf("\n");
	}
	printf("\n");

	return;
}




int main(int argc, char ** argv)
{
	key_t shmkey;
	int shmid;
	unsigned char * p;

	if (argc < 3) {
		fprintf(stderr, "few args\n\n");
		exit(-1);
	}

	switch (argv[1][0]) {
	case 'c':
		shmkey = strtoul(argv[2], NULL, 16);
		if ((shmid = shmget(shmkey, SHMSIZE, IPC_CREAT|0666)) == -1) {
			fprintf(stderr, "shmget fail\n\n");
			exit(-1);
		}
		break;
	case 'a':
		if (strncmp(argv[2], "0x", 2) == 0) {
			shmkey = strtoul(argv[2], NULL, 16);
			shmid = shmget(shmkey, 0, 0);
			if (shmid == -1) {
				fprintf(stderr, "shmget fail\n\n");
				exit(-1);
			}
		}
		else {
			shmid = strtoul(argv[2], NULL, 10);
		}
		if ((p = shmat(shmid, (void *)0, 0)) == NULL) {
			fprintf(stderr, "shmat fail\n\n");
			exit(-1);
		}
		fill_shm(p, SHMSIZE);
		break;
	case 'x':
		if (argc < 4) {
			fprintf(stderr, "few args\n\n");
			exit(-1);
		}
		size_t dumpsize = strtol(argv[3], NULL, 10);

		if (strncmp(argv[2], "0x", 2) == 0) {
			shmkey = strtoul(argv[2], NULL, 16);
			shmid = shmget(shmkey, 0, 0);
			if (shmid == -1) {
				fprintf(stderr, "shmget fail\n\n");
				exit(-1);
			}
		}
		else {
			shmid = strtoul(argv[2], NULL, 10);
		}

		if ((p = shmat(shmid, (void *)0, 0)) == NULL) {
			fprintf(stderr, "shmat fail\n\n");
			exit(-1);
		}
		
		dump(p, dumpsize);

		break;
	case 'r':
		if (strncmp(argv[2], "0x", 2) == 0) {
			shmkey = strtoul(argv[2], NULL, 16);
			shmid = shmget(shmkey, 0, 0);
			if (shmid == -1) {
				fprintf(stderr, "shmget fail\n\n");
				exit(-1);
			}
		}
		else {
			shmid = strtoul(argv[2], NULL, 10);
		}
		if (shmctl(shmid, IPC_RMID,0) == -1){
			fprintf(stderr, "shmctl(rm) fail\n\n");
			exit(-1);
		}
		break;
	default:
		fprintf(stderr, "unknown option specified\n\n");
		exit(-1);
		break;
	}

	return 0;
}

