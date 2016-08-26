#include <stdlib.h>
#include <stdio.h>

int calc(char * s)
{
	int n = 0;
	while (*s) {
		if (*s == '#')
			break;
		if (isxdigit(*s))
			n++;
		s++;
	}

	return n;
}


int main()
{
	char buf[1024];
	int total = 0;

	while (fgets(buf, 1023, stdin) ) {
		total += calc(buf);
	}
	total /= 2;

	printf("\n");
	printf("length: %4d : 0x%x\n", total, total);

	return 0;
}

