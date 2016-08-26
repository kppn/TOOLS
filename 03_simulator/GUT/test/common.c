#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <stdint.h>

#include "common.h"

void dump(uchar * buf, int n)
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



int strpbrktok(char * buf, int buflen, 
		char * s, const char * delim, int n)
{
	int i;
	char * p;
	char * head;
	int len;
	int cpylen;
	
	if (s == NULL || delim == NULL || 
	    (len=strlen(s)) == 0 || 
	    strspn(s, delim) == len) /* ¥Ç¥ê¥ß¥¿¤·¤«Ìµ¤¤¾ì¹ç */
		return -1;

	i = 0;
	head = s + strspn(s, delim);	/* ¹ÔÆ¬¤Î¥Ç¥ê¥ß¥¿¤òÈô¤Ð¤¹ */
	while (1) {
		p = strpbrk(head, delim);
		if (p == NULL) {
			p = s + strlen(s);
			if (i != n)
				return -1;
			break;
		}
		if (i++ == n)
			break;
		head = p + strspn(p, delim);
	}
	
	cpylen = p - head;
	if (buflen - 1 < cpylen)
		cpylen = buflen - 1;
	strncpy(buf, head, cpylen);
	buf[cpylen] = '\0';

	return cpylen;
}





char * chomp(char * s)
{
	while (*s != '\0') {
		if (*s == ' ') {
			*s = '\0';
			break;
		}
		s++;
	}

	return s;
}





int get_initenv(char * filename, char retbuf[], const char * envname)
{
	char linebuf[1024];
	char elemname[256];
	char elemvalue[256];
	char * endl;
	FILE * fp;

	if ( (fp = fopen(filename, "r")) == NULL) {
		return -1;
	}
	
	while (fgets(linebuf, 1023, fp)) {
		if (linebuf[0] == '#')	/* ignore comment line */
			continue;
		if ( (endl=strchr(linebuf, '\n')))
			*endl = '\0';
		if (strpbrktok(elemname, 1024, linebuf, "=", 0) < 0) {
			continue;
		}
		if (strpbrktok(elemvalue, 1024, linebuf, "=", 1) < 0) {
			continue;
		}
		chomp(elemname);
		if (strcmp(envname, elemname) == 0) {
			strcpy(retbuf, elemvalue);
			fclose(fp);
			return 0;
		}
	}

	fclose(fp);
	return -1;
}



/* Read Config File */

