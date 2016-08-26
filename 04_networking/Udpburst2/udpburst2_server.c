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
	printf("udpburst_server ipaddr:port ipaddr:port\n");
	printf("   own       : ipaddr:port\n");
	printf("   return to : ipaddr:port\n");
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



int make_sockaddr(char * s, struct sockaddr_in * sockaddr)
{
	char * semicolon;
	char addrstr[128];
	char portstr[128];
	size_t len;
	size_t addrlen;
	size_t portlen;
	
	semicolon = strchr(s, ':');
	if (semicolon == NULL)
		return -1;
	if ((semicolon - s) < 1)
		return -1;
	if (*(semicolon+1) == '\0')
		return -1;

	addrlen = semicolon - s;
	strncpy(addrstr, s, addrlen);
	addrstr[addrlen] = '\0';
	
	len = strlen(s);
	portlen = (s + len) - semicolon - 1;
	strncpy(portstr, semicolon + 1, portlen);
	portstr[portlen] = '\0';
	
	uint16_t port;
	if (!isalldigits(portstr)) 
		return -1;
	port = strtoul(portstr, NULL, 10);
	
	sockaddr->sin_family = AF_INET;
	sockaddr->sin_port = htons(port);
	sockaddr->sin_addr.s_addr = inet_addr(addrstr);

	return 0;
}




int main(int argc, char ** argv)
{
	int sock;

	if (argc != 3) {
		usage();
		return 0;
	}
	
	
	/* create socket */
	sock = socket(AF_INET, SOCK_DGRAM, 0);
	if (sock < 0) {
		printf("socket error\n");
		exit(1);
	}
	
	/* create address, and bind */
	struct sockaddr_in ownaddr;
	make_sockaddr(argv[1], &ownaddr);
	if (bind(sock, (struct sockaddr *)&ownaddr, sizeof(ownaddr)) < 0) {
		printf("bind error\n");
		exit(1);
	}
	
	/* create return address */
	struct sockaddr_in returnaddr;
	make_sockaddr(argv[2], &returnaddr);
	
	
	uint32_t old = -1;
	uint32_t new;
	unsigned char buf[2048];
	while (1) {
		size_t rsize;
		rsize = recv(sock, buf, 2048, 0);
		new = htonl(*(uint32_t *)buf);
		
		if (new != (old + 1))
			printf("some packet missing. before:%u, current%u\n", old, new);
		old = new;
		
		sendto(sock, buf, rsize, 0, (struct sockaddr *)&returnaddr, sizeof(returnaddr));
	}
	
	close(sock);
	
	return 0;
}

