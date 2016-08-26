#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>


void usage(void)
{
	printf("udpburst_client ipaddr:port send_count\n");
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
	unsigned int i;
	int sock;
	struct sockaddr_in addr;
	char * semicolon;
	char dest_ip_str[1024];
	char dest_port_str[1024];
	unsigned short dest_port;
	unsigned long n_send;
	
	
	if (argc < 3) {
		usage();
		return 0;
	}
	
	/* 
	 * decode argument as 
	 * 	argv[1] : (ipaddress):(port)
	 * 	argv[2] : (send packet number)
	*/
	strcpy(dest_ip_str, argv[1]);
	semicolon = strchr(dest_ip_str, ':');
	if (semicolon  == NULL) {
		usage();
		return 0;
	}
	*semicolon = '\0';
	
	strcpy(dest_port_str, semicolon + 1);
	if ((strlen(dest_port_str) == 0) && !isalldigits(dest_port_str)) {
		usage();
		return 0;
	}
	dest_port = strtoul(dest_port_str, NULL, 10);
	if (dest_port < 1 || 65535 < dest_port) {
		printf("port number out of range\n");
		usage();
		return 0;
	}
	if (argc > 2) {
		if (!isalldigits(argv[2])) {
			printf("packet send number out of range\n");
			usage();
			return 0;
		}
	}
	n_send = strtoul(argv[2], NULL, 10);
	
	
	/* create socket */
	sock = socket(AF_INET, SOCK_DGRAM, 0);
	if (sock < 0) {
		printf("socket error\n");
		exit(1);
	}
	
	addr.sin_family = AF_INET;
	addr.sin_port = htons(dest_port);
	addr.sin_addr.s_addr = inet_addr(dest_ip_str);
	
	/* send message as uint32_t(0..UINT_MAX) incremental */
	for (i = 0; i < n_send; i++) {
		uint32_t message = htonl(i);
		sendto(sock, &message, sizeof(message), 0, (struct sockaddr *)&addr, sizeof(addr));
		// usleep(260);
	}
	
	close(sock);
	
	return 0;
}

