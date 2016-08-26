#include <stdio.h>
#include <stdlib.h>
#include <string.h>


unsigned short checksum(unsigned short *buf, int size)
{
	unsigned long sum = 0;

	while (size > 1) {
		printf("for: %04x\t", *buf);
		sum += *buf++;
		size -= 2;
		printf("%08x\n", sum);
	}
	if (size)
		sum += *(unsigned char *)buf;

	printf("fuga: %08x\n", sum);

	sum  = (sum & 0xffff) + (sum >> 16);	/* add overflow counts */
	sum  = (sum & 0xffff) + (sum >> 16);	/* once again */

	printf("fuga: %08x\n", sum);
	
	return ~sum;
}


int stoh(unsigned char * data, char * buf)
{
	char hex[3];
	int i, j;
	int byte = 0;

	if(buf[0] == '#') {
		return 0;
	}

	j = 0;
	for (i = 0; buf[i] != '\0'; i++) {
		if (!isxdigit(buf[i])) {
			continue;
		}
		hex[j++] = buf[i];
		if (j == 2) {
			hex[j] = '\0';
			data[byte] = strtol(hex, NULL, 16);
			j = 0;
			byte++;
		}
	}
	return byte;
}


void dump(unsigned char * buf, int n)
{
        int i;
        int j = 0;

        for(i = 0; i < n; i++) {
                printf("%02x", buf[i]);
                j++;
                if (i % 2)
                        printf(" ");
                if (j == 16) {
                        printf("\n");
                        j = 0;
                }
        }
}



int main(int argc, char ** argv)
{
	unsigned char data[128];
	char buf[256];
	unsigned short sum;
	int c;
	int i;
	FILE * fp;

	if (argc != 2) {
		printf("few args\n");
		exit(1);
	}

	fp = fopen(argv[1], "rb");
	if (fp == NULL) {
		printf("file open error\n");
		exit(1);
	}
	i = 0;
	while(fgets(buf, 255, fp) != NULL) {
		i += stoh(data+i, buf);
	}

	printf("data:\n");
	dump(data, i);

	printf("\n\n");
	sum = checksum(data, i);
	printf("0x%04x\n", sum);
}

