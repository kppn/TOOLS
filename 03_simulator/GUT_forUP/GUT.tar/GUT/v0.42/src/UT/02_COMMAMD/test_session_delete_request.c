#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <sys/socket.h>

#include <fcntl.h>

#include <net/if.h>
#include <net/if_arp.h>
#include <arpa/inet.h>

#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/udp.h>

#include "common.h"
#include "command.h"
#include "init.h"



int main(int argc, char ** argv)
{
	Environ env;
	int i;
	int c;
	int sfd;
	int readsize;
	int filesize = 0;
	FILE * fp;
	char filebuf[1024];
	struct sockaddr_in command;

	if (argc != 3) {
		printf("few arg\n");
		exit(1);
	}


	if ((fp = fopen(argv[1], "r")) == NULL) {
		printf("file open failure\n");
		exit(1);
	}
	for (i = 0; (c=fgetc(fp)) != EOF; i++ ) {
		filebuf[i] = c;
		filesize++;
	}
	fclose(fp);

	init_environ(&env, "gut.conf");

	command.sin_addr.s_addr = inet_addr("127.0.0.1");
	command.sin_port = htons(50001); 
	command.sin_family = AF_INET;
	sfd = socket(AF_INET, SOCK_DGRAM, 0) ;
	bind(sfd, (struct sockaddr *)&command, sizeof(command));

	for (i = 0; i < 12; i++) {
		session_add_request(filebuf, filesize, &env, &command);
	
		readsize = recv(sfd, filebuf, 1024, 0);
		filebuf[readsize] = '\0';
		printf("%s\n\n", filebuf);
	}

	printf("\n\n\n");
	printf("=============================================================\n");

	disp_environ(&env);

	printf("=============================================================\n");
	printf("\n\n\n");

	for (i = 0; i < 11; i++) {
		env.session[i].ebi = i;
	}

	printf("=============================================================\n");

	if ((fp = fopen(argv[2], "r")) == NULL) {
		printf("file open failure\n");
		exit(1);
	}
	for (i = 0; (c=fgetc(fp)) != EOF; i++ ) {
		filebuf[i] = c;
		filesize++;
	}
	fclose(fp);

	session_delete_request(filebuf, filesize, &env, &command);
	readsize = recv(sfd, filebuf, 1024, 0);
	filebuf[readsize] = '\0';
	printf("%s\n\n", filebuf);

	disp_environ(&env);

	printf("=============================================================\n");

	getchar();
	return 0;
}



