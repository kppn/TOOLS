/* =============================================================================
 * chnum
 *
 *  入力値を以下の表現で出力する。32bit。
 *    ・符号付き10進
 *    ・符号無し10進
 *    ・16進
 *    ・IPアドレス形式
 *
 *   2014/3/24   T.kondoh
 *        初版作成
 *
 ============================================================================= */



#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdint.h>


void print_usage(void)
{
	printf("usage: chnum (+dec | -dec | 0xhex | ipstr)\n");
	printf("\n");

	return;
}


int isipstr(const char * s)
{
	int i;
	size_t len;
	int dotp[4];

	len = strlen(s);
	if (len < 7 || len > 15)
		return 0;
	if (!isdigit(s[0]) || !isdigit(s[len-1]))
		return 0;

	int ndots = 0;
	int ndigits = 0;
	for (i = 0; i < len; i++) {
		if (!isdigit(s[i]) && s[i] != '.')
			return 0;
		if (s[i] == '.') {
			if (ndots >= 3)
				return 0;
			if (i != 0 && s[i-1] == '.')
				return 0;
			if (ndigits > 3)
				return 0;
			if (ndigits >= 2 && s[i-ndigits] == '0')
				return 0;
			ndots++;
			dotp[ndots] = i;
			ndigits = 0;

			continue;
		}

		/* digit appear */
		ndigits++;
	}
	if (ndots != 3)
		return 0;

	dotp[0] = -1;
	uint32_t num;
	for (i = 0; i < 4; i++) {
		num = strtoul(&s[dotp[i]+1], NULL, 10);
		if (num < 0 || num > 255)
			return 0;
	}

	return 1;
}




int main(int argc, char ** argv) 
{
	int i;
	uint32_t num = 0;

	if (argc < 2) {
		print_usage();
		exit(1);
	}

	char * s = argv[1];
	char * p = s;

	if (isipstr(s)) {
		p--;
		for(i = 0; i < 4; i++) {
			num <<= 8;
			num += strtoul(p+1, &p, 10);
		}
	}
	else if (s[0] == '+') {
		num = strtoul(&s[1], &p, 10);
		if (*p != '\0') {
			print_usage();
			exit(1);
		}
	}
	else if (s[0] == '-') {
		num = strtoul(&s[1], &p, 10);
		num = -num;
		if (*p != '\0') {
			print_usage();
			exit(1);
		}
	}
	else if (strncmp(s, "0x", 2) == 0) {
		num = strtoul(&s[2], &p, 16);
		if (*p != '\0') {
			print_usage();
			exit(1);
		}
	}
	else {
		printf("hogfe");
	}

	printf("s dec  : %d\n", num);
	printf("us dec : %u\n", num);
	printf("hex    : 0x%08x\n", num);
	printf("ipstr  : %d.%d.%d.%d\n",	
				num >> 24,
				num >> 16 & 0xff,
				num >>  8 & 0xff,
				num       & 0xff
				);

	return 0;
}



