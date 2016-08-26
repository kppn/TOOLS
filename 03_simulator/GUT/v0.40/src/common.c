#include <string.h>
#include <stdlib.h>
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




int max(int a, int b)
{
	return (a > b) ? a : b;
}



int maxfd(Environ * env)
{
	int i;
	int maxnum = 0;

	for (i = 0; i < env->max_tunnel_device; i++) 
		if (env->session[i].tunfd != TUNFD_UNUSE)
			maxnum = max(env->session[i].tunfd, maxnum);
	maxnum = max(env->command_sfd, maxnum);
	maxnum = max(env->udpfd, maxnum);

	return maxnum;
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
	    strspn(s, delim) == len) 
	    	return -1;

	i = 0;
	head = s + strspn(s, delim);
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
		if (strpbrktok(elemname, 1024, linebuf, "= \t", 0) < 0) {
			continue;
		}
		if (strpbrktok(elemvalue, 1024, linebuf, "= \t", 1) < 0) {
			continue;
		}
		chomp(elemname);
		if (strcmp(envname, elemname) == 0) {
			strcpy(retbuf, elemvalue);
			fclose(fp);
			return 0;
		}
	}
	printf("%s : %d\n", __FILE__, __LINE__);

	fclose(fp);
	return -1;
}



/* Read Config File */

