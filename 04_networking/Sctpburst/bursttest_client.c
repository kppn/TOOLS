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





void usage(void)
{
	/* use string join */
	printf(
"sctpburst proto ip:port tps count" "\n"
"\n"
"    proto : udp sctp " "\n"
"\n"
);
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



int anyproto_send(int sock, int proto, const void * message, size_t len, struct sockaddr * addr)
{
	int sendsize = 0;

	if (proto == IPPROTO_UDP) {
		sendto(sock, message, len, 0, addr, sizeof(*addr));
		if (sendsize < 0) {
			printf("udp send error\n");
			exit(1);
		}
	} 
	else if (proto == IPPROTO_SCTP) {
		sendsize = sctp_sendmsg( 
			sock,			/* int sd			*/
			message,	 	/* const void * msg		*/
			len,			/* size_t len			*/
			NULL, 			/* struct sockaddr *to		*/
			0, 			/* socklen_t tolen		*/
			0, 			/* uint32_t ppid		*/
			0, 			/* uint32_t flags		*/
			0, 			/* uint16_t stream_no		*/
			0, 			/* uint32_t timetolive (ms)	*/
			0 			/* uint32_t context		*/
			);
		if (sendsize < 0) {
			printf("sctp send error\n");
			exit(1);
		}
	}

	return sendsize;
}





#define MAX_BUFFER	4096

int main(int argc, char ** argv)
{
	int connSock;
	struct sockaddr_in servaddr;
	int proto;


	/* 
	 * retrieve bind ip/port tps from arguments
	 */
	if (argc < 5) {
		usage();
		exit(1);
	}

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
	unsigned long tps;
	unsigned long count;

	semicolon = strchr(argv[2], ':');
	if (semicolon == NULL)
		usage_exit();
	
	strncpy(addr_str, argv[2], semicolon - argv[2]);
	addr_str[semicolon - argv[2]] = '\0';
	strcpy(port_str, semicolon + 1);
	if (strlen(port_str) == 0 || !isalldigits(port_str) )
		usage_exit();

	if (strlen(argv[3]) == 0 || !isalldigits(argv[3]) )
		usage_exit();
	tps = strtoul(argv[3], NULL, 10);

	if (strlen(argv[4]) == 0 || !isalldigits(argv[4]) )
		usage_exit();
	count = strtoul(argv[4], NULL, 10);
	
	
	/* Create SCTP TCP-Style Socket */
	if (proto == IPPROTO_UDP) {
		connSock = socket( AF_INET, SOCK_DGRAM, 0);
	}
	else if (proto == IPPROTO_SCTP) {
		connSock = socket( AF_INET, SOCK_STREAM, IPPROTO_SCTP );
	}
	if (connSock < 0) {
		printf("socket open error\n");
		exit(1);
	}
	
	memset( (void *)&servaddr, 0, sizeof(servaddr) );
	
	in_addr_t addr = inet_addr(addr_str);
	unsigned short port;
	if (addr == -1)
		usage_exit();
	port = strtoul(port_str, NULL, 10);
	printf("target address : %08x:%05x\n", addr, port);

	if (proto == IPPROTO_SCTP) {
		/* set the association options */
		struct sctp_initmsg initmsg = {0};
		initmsg.sinit_num_ostreams = 1;
		unsigned long nodelay = 1; 
		
		if (setsockopt( connSock, IPPROTO_SCTP, SCTP_INITMSG, &initmsg, sizeof(initmsg)) < 0 ) {
			printf("setsockopt errno\n");
			exit(1);
		}
		if (setsockopt( connSock, IPPROTO_SCTP, SCTP_NODELAY, &nodelay, sizeof(nodelay)) < 0 ) {
			printf("setsockopt errno\n");
			exit(1);
		}
	}

	servaddr.sin_family = AF_INET;
	servaddr.sin_addr.s_addr = addr;
	servaddr.sin_port = htons(port);
	
	if (proto == IPPROTO_SCTP) {
		/* connect to server */
		if (connect(connSock, (struct sockaddr *)&servaddr, sizeof(servaddr) ) < 0) {
			printf("connect error\n");
			exit(1);
		}
		printf("connected\n");
	
		socklen_t opt_len;
		struct sctp_status status = {0};
		opt_len = (socklen_t) sizeof(struct sctp_status);
		if (getsockopt(connSock, IPPROTO_SCTP, SCTP_STATUS, &status, &opt_len) < 0) {
			printf("getsockopt error\n");
		}
		else {
			printf("Association ID\t\t= %d\n", status.sstat_assoc_id );
			printf("Receiver window size\t= %d\n", status.sstat_rwnd );
		}
	}

	/* client loop. use spinlock for wait */
	struct timeval tm_before;
	struct timeval tm_after;
	struct timeval tm_new;
	struct timeval tm_old;
	int i;
	int sendsize = 0;
	int n_send = 0;
	uint32_t message = 0;

	gettimeofday(&tm_before, NULL);
	gettimeofday(&tm_old, NULL);

	while( 1 ) {
		sendsize = anyproto_send(connSock, proto, &message, 4, (struct sockaddr *)&servaddr);
		if (sendsize < 0) {
			printf("send error\n");
			exit(1);
		}
		n_send++;
		message++;

		/* bussy wait */
		while (1) {
			for (i = 0; i < 10000; i++)
				;
			gettimeofday(&tm_new, NULL);
			if ((tm_new.tv_usec - tm_old.tv_usec) > (1000000 / tps)) 
				break;
		}

		tm_old.tv_sec  = tm_new.tv_sec;
		tm_old.tv_usec = tm_new.tv_usec;

		if (message >= count) 
			break;
	}

	message = -1;
	sendsize = anyproto_send(connSock, proto, &message, 4, (struct sockaddr *)&servaddr);

	gettimeofday(&tm_after, NULL);
	printf("%d message sent in %lf\n", n_send, difftime_tv(tm_after, tm_before));

	close( connSock );
	
	return 0;
}
 

