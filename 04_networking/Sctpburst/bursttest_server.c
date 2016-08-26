#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <ctype.h>
#include <sys/time.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netinet/sctp.h>


#define	BUFFSIZE	4096



void usage(void)
{
	/* use string join */
	printf(
"sctpburst proto ip:port" "\n"
"\n"
"    proto : udp sctp " "\n"
"\n"
);
	printf("\n");
}



void usage_exit(void)
{
	usage();
	exit(1);
}



double difftime_tv(struct timeval after, struct timeval before)
{
	unsigned long long diff_usec;
	double diff_sec;

	diff_usec = ((after.tv_sec  - before.tv_sec) * 1000000) + (after.tv_usec - before.tv_usec);
	diff_sec = (double)diff_usec / 1000000;

	return diff_sec;
}


int isalldigits(const char * s)
{
	while (*s) {
		if (!isdigit(*s))
			return 0;
		s++;
	}
	return 1;
}



int anyproto_recv(int sock, int proto, unsigned char * buffer)
{
	int recvsize = 0;

	if (proto == IPPROTO_UDP) {
		recvsize = recv(sock, (void *)buffer, BUFFSIZE, 0);
		if (recvsize < 0) {
			printf("udp recv error\n");
			exit(1);
		}
	} 
	else if (proto == IPPROTO_SCTP) {
//
//	 	libsctp bug ? 
// 		sctp_recvmsg() error just after connected. 
//	
//		struct sockaddr_in addr;
//		socklen_t fromlen = sizeof(addr);
//		struct sctp_sndrcvinfo sndrcvinfo;
//		int flags;
//
//                recvsize = sctp_recvmsg( 
//			sock, 				/* int sd,				*/
//			(void *)buffer, 		/* void * msg				*/
//			BUFFSIZE,			/* size_t len				*/
//			(struct sockaddr *)&addr,	/* struct sockaddr * from		*/
//			&fromlen,			/* socklen_t * fromlen			*/
//			&sndrcvinfo,			/*  struct sctp_sndrcvinfo * sinfo	*/
//			&flags				/* int * msg_flags			*/
//			);
		recvsize = recv(sock, (void *)buffer, BUFFSIZE, 0);
		if (recvsize < 0) {
			printf("sctp_recvmsg error\n");
			exit(1);
		}
	}

	if (*(uint32_t *)buffer == -1) 
		return -1;

	return recvsize;
}



#define MAX_BUFFER	4096

int main(int argc, char ** argv)
{
	int listenSock;
	int connSock;
	int proto;

	struct sockaddr_in servaddr;


	/* 
	 * retrieve proto and bind ip/port from arguments
	 */
	if (argc < 3)
		usage_exit();

	if (strcmp(argv[1], "udp") == 0) {
		proto = IPPROTO_UDP;
	}
	else if (strcmp(argv[1], "sctp") == 0) {
		proto = IPPROTO_SCTP;
	}
	else {
		usage_exit();
	}

	char addr_str[128];
	char port_str[128];
	char * semicolon;

	semicolon = strchr(argv[2], ':');
	if (semicolon == NULL)
		usage_exit();
	
	strncpy(addr_str, argv[2], semicolon - argv[2]);
	addr_str[semicolon - argv[2]] = '\0';
	strcpy(port_str, semicolon + 1);
	if (strlen(port_str) == 0 || !isalldigits(port_str) )
		usage_exit();
	
	
	
	/* Create SCTP TCP-Style Socket */
	if (proto == IPPROTO_UDP) {
		listenSock = socket( AF_INET, SOCK_DGRAM, 0);
	}
	else if (proto == IPPROTO_SCTP) {
		listenSock = socket( AF_INET, SOCK_STREAM, IPPROTO_SCTP );
	}
	if (listenSock < 0) {
		printf("listen socket open error\n");
		exit(1);
	}
	
	/* Accept connections from specific interface */
	memset( (void *)&servaddr, 0, sizeof(servaddr) );
	
	in_addr_t addr = inet_addr(addr_str);
	unsigned short port;
	if (addr == -1)
		usage_exit();

	port = strtoul(port_str, NULL, 10);
	printf("bind address : %08x:%05x\n", addr, port);



	/* Bind to the specific address and port */
	servaddr.sin_family = AF_INET;
	servaddr.sin_addr.s_addr = addr;
	servaddr.sin_port = htons(port);
	
	int bind_ret;
	bind_ret = bind( listenSock, (struct sockaddr *)&servaddr, sizeof(servaddr) );
	if (bind_ret < 0) {
		printf("bind error\n");
		exit(1);
	}
	
	
	/* Place the server socket into the listening state */
	if (proto == IPPROTO_UDP ) {
		connSock = listenSock;
	}
	if (proto == IPPROTO_SCTP) {
		int listen_ret;
		listen_ret = listen( listenSock, 5 );
		if (listen_ret < 0) {
			printf("listen error\n");
			exit(1);
		}
		
		/* Await a new client connection */
		connSock = accept( listenSock, NULL, NULL );
		if (connSock < 0) {
			printf("accept error\n");
			exit(1);
		}
	}
	
	
	/* Server loop... */
	struct timeval tm_before;
	struct timeval tm_after;
	int started = 0;
	int recvsize = 0;
	int n_recv = 0;

	uint32_t old_num = -1;
	uint32_t new_num = 0;
	uint32_t missing = 0;

	unsigned char buffer[BUFFSIZE];

	memset(buffer, 0, BUFFSIZE);

	while( 1 ) {
		recvsize = anyproto_recv(connSock, proto, buffer);

		if (!started) {
			started = 1;
			gettimeofday(&tm_before, NULL);
		}

		if (recvsize < 0)
			break;

		n_recv++;

		if (proto == IPPROTO_UDP) {
			new_num = *(uint32_t *)buffer;
			missing += (new_num - old_num) - 1;
			old_num = new_num;
		}
	}

	gettimeofday(&tm_after, NULL);
	printf("%d message received in %lf", n_recv, difftime_tv(tm_after, tm_before));
	if (proto == IPPROTO_UDP)
		printf(" loss %d", missing);
	printf("\n");

	close( connSock );
	
	return 0;
}
 

