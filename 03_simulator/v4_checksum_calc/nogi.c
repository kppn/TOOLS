#include <stdio.h>
#include <stdlib.h>


unsigned short checksum( unsigned short *buf, int size )
{
	unsigned long sum = 0;
	while (size>1){
		sum += *buf++;
		size -= 2;
	}
	if(size)
		sum += *(unsigned char *)buf;
	sum = (sum & 0xffff) + (sum >> 16);
	sum = (sum & 0xffff) + (sum >> 16);

	return ~sum;
}

int main(){
	FILE *fp;
	int size;
	unsigned short sum;
	unsigned char buf[2048];

	fp = fopen("file.bin","rd");
	size = fread(buf, 1, 2048, fp);
	if (size == 0) {
		printf("file read NG\n");
		exit(1);
	}
	printf("packet size = %d\n", size);
	buf[10] = 0x00;
	buf[11] = 0x00;
	sum = checksum((unsigned short *)buf, size);
	printf("%04x\n",sum);

	return 0;
}
