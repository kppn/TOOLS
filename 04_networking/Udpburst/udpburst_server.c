#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <ctype.h>



void usage(void)
{
	printf("udpburst_server ipaddr:port [-v]\n");
	printf("\n");

	return;
}



int isalldigits(char * s)
{
	while (*s) {
		if (!isdigit(*s))
			return 0;
		s++;
	}
	return 1;
}




int main(int argc, char ** argv)
{
	int sock;
	struct sockaddr_in addr;
	char own_ip_str[1024];
	char own_port_str[1024];
	char * semicolon;
	int vervose = 0;
	
	if (argc > 3) {
		usage();
		return 0;
	}
	
	/* 
	 * decode argument as 
	 * 	argv[1] : (ipaddress):(port)
	*/
	
	
	strcpy(own_ip_str, argv[1]);
	semicolon = strchr(own_ip_str, ':');
	if (semicolon  == NULL) {
		usage();
		return 0;
	}
	*semicolon = '\0';

	if (argc > 2) {
		if (strcmp(argv[2], "-v") == 0) {
			printf("vervose mode\n");
			vervose = 1;
		}
	}
	
	strcpy(own_port_str, semicolon + 1);
	if ((strlen(own_port_str) == 0) || !isalldigits(own_port_str)) {
		printf("port number out of range\n");
		usage();
		return 0;
	}
	
	
	sock = socket(AF_INET, SOCK_DGRAM, 0);
	if (sock < 0) {
		printf("socket error\n");
		exit(1);
	}
	
	addr.sin_family = AF_INET;
	addr.sin_port = htons(strtol(own_port_str, NULL, 10));
	addr.sin_addr.s_addr = inet_addr(own_ip_str);;

	if (vervose) {
		printf("ip   : %s\n", inet_ntoa(addr.sin_addr));
		printf("port : %05d\n", ntohs(addr.sin_port));
	}
	
	if (bind(sock, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
		printf("bind error\n");
		exit(1);
	}
	
	uint32_t old = -1;
	uint32_t new;
	while (1) {
		recv(sock, &new, sizeof(new), 0);
		new = ntohl(new);

		if (vervose)
			printf("%d\n", new);

		if (new != (old + 1))
			printf("some packet missing. before:%u, current%u\n", old, new);
		old = new;
	}
	
	close(sock);
	
	return 0;
}

