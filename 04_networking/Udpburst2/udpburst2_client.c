#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>
#include <pthread.h>


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


int end_flag = 0;
int sendsock;
int receivesock;
struct sockaddr_in ownaddr;
struct sockaddr_in targetaddr;
struct sockaddr_in receiveraddr;
unsigned long n_send;
useconds_t sleeptime;


uint32_t difftimes(struct timeval cur, struct timeval old)
{
	uint32_t diff_msec = 0;

	diff_msec = (cur.tv_sec * 1000 + cur.tv_usec / 1000) -
		    (old.tv_sec * 1000 + old.tv_usec / 1000);

	return diff_msec;
}


void * sender(void * param)
{
	unsigned int i;

	usleep(100000);
	
	/* send message as uint32_t(0..UINT_MAX) incremental */
	unsigned char buf[2048];
	uint32_t * cp = (uint32_t *)buf;
	struct timeval * tp = (struct timeval *)(buf + sizeof(uint32_t));
	for (i = 0; i < n_send; i++) {
		*cp = htonl(i);
		gettimeofday(tp, NULL);

		sendto(sendsock, &buf, 128, 0, (struct sockaddr *)&targetaddr, sizeof(targetaddr));
		usleep(sleeptime);
	}

	end_flag = 1;

	pthread_t self = pthread_self();
	pthread_detach(self);

	return NULL;
}



void * receiver(void * param)
{
	unsigned char buf[2048];
	uint32_t * cp = (uint32_t *)buf;
	struct timeval * tp = (struct timeval *)(buf + sizeof(uint32_t));
	struct timeval cur;
	
	uint32_t old = -1;
	uint32_t new;
	uint32_t diff;
	while (1) {
		if (end_flag)
			break;
		size_t rsize;
		rsize = recv(receivesock, buf, 128, 0);
		cp = (uint32_t *)buf;
		gettimeofday(&cur, NULL);
		diff = difftimes(cur, *tp);

		new = ntohl(*cp);
		if (new != (old + 1)) {
			printf("some packet missing. before:%u, current%u\n", old, new);
			fflush(stdout);
		}
		old = new;

		if (diff > 1000) {
			printf("packet round trip time : %u ms\n", diff);
			fflush(stdout);
		}
	}

	pthread_t self = pthread_self();
	pthread_detach(self);

	return NULL;
}



int main(int argc, char ** argv)
{
	if (argc < 6) {
		usage();
		return 0;
	}

	make_sockaddr(argv[1], &ownaddr);
	make_sockaddr(argv[2], &targetaddr);
	make_sockaddr(argv[3], &receiveraddr);
	
	n_send    = strtoul(argv[4], NULL, 10);
	sleeptime = strtoul(argv[5], NULL, 10);

	/* create socket */
	sendsock    = socket(AF_INET, SOCK_DGRAM, 0);
	receivesock = socket(AF_INET, SOCK_DGRAM, 0);
	if (sendsock < 0 || receivesock < 0) {
		printf("socket error\n");
		exit(1);
	}

	if (bind(sendsock, (struct sockaddr *)&ownaddr, sizeof(ownaddr)) < 0) {
		printf("sender bind error\n");
		exit(1);
	}

	if (bind(receivesock, (struct sockaddr *)&receiveraddr, sizeof(receiveraddr)) < 0) {
		printf("receiver bind error\n");
		exit(1);
	}

	pthread_t th_sender;
	pthread_t th_receiver;

	if (pthread_create(&th_receiver, NULL, receiver, NULL) != 0) {
		perror("pthread error\n");
		exit(1);
	}
	if (pthread_create(&th_sender, NULL, sender, NULL) != 0) {
		perror("pthread error\n");
		exit(1);
	}
	
	pthread_join(th_sender, NULL);
	pthread_join(th_receiver, NULL);
	
	return 0;
}

