#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <ifaddrs.h>


void dump(unsigned char * buf, size_t n)
{
	int i;
	for (i = 0; i < n; i++) {
		printf("%02x", buf[i]);
	}
}




struct addrinfo * to_addrinfo(char * ip, char * port, int flags)
{
	struct addrinfo hints;
	struct addrinfo* ai;
	int err;

	memset(&hints, 0, sizeof(hints));
	hints.ai_family = AF_INET6;
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_flags = flags;

	err = getaddrinfo(ip, port, &hints, &ai);
	if (err != 0) {
		printf("getaddrinfo(): %s\n", gai_strerror(err));
		return NULL;
	}
	if (ai == NULL) {
		printf("no address\n");
		return NULL;
	}

	return ai;
}



struct sockaddr_in6 * find_if(struct addrinfo * if_for)
{
	struct ifaddrs * ifap;
	struct ifaddrs * if_cur;
	
	if (getifaddrs(&ifap) < 0) {
		perror("getifaddrs error");
		exit(1);
	}

	for (if_cur = ifap; if_cur != NULL; if_cur = if_cur->ifa_next) {
		struct sockaddr_in6 * sa_cur;
		struct sockaddr_in6 * sa_for;

		sa_cur = (struct sockaddr_in6 *)if_cur->ifa_addr;
		sa_for = (struct sockaddr_in6 *)if_for->ai_addr;

		printf("%10s ", if_cur->ifa_name);
		dump(sa_cur->sin6_addr.s6_addr, 16);
		printf("   ");
		printf("scope_id : %d", sa_cur->sin6_scope_id);
		printf("\n");

		if (memcmp(sa_cur->sin6_addr.s6_addr, sa_for->sin6_addr.s6_addr, 16) == 0)  {
			printf("!!! interface found\n");
			return (struct sockaddr_in6 *)sa_cur;
		}
	}

	return NULL;
}


int open_sockets(
	int sockets[2],
	struct sockaddr_in6 sas[3],
	char * target_ip, char* target_port,
	char * bind_ip,   char * bind_port,
	char * proxy_ip,  char * proxy_port
)
{
	struct addrinfo * aip;
	int sfd_target;
	int sfd_proxy;
	
	
	struct addrinfo target_ai;
	aip = to_addrinfo(target_ip, target_port, AI_NUMERICHOST | AI_NUMERICSERV);
	if (aip == NULL) {
		printf("target addrinfo fail. %s : %s\n", target_ip, target_port);
		return -1;
	}
	memcpy(&target_ai, aip, sizeof(*aip));

	struct addrinfo bind_ai;
	aip = to_addrinfo(bind_ip, bind_port, AI_PASSIVE | AI_NUMERICHOST | AI_NUMERICSERV);
	if (aip == NULL) {
		printf("bind addrinfo fail. %s : %s\n", bind_ip, bind_port);
		return -1;
	}
	memcpy(&bind_ai, aip, sizeof(*aip));
	
	struct sockaddr_in6 * bind_sa;
	bind_sa = find_if(&bind_ai);
	if (bind_sa == NULL) {
		perror("bind IF not found");
		exit(1);
	}

	
	struct addrinfo proxy_ai;
	aip = to_addrinfo(proxy_ip, proxy_port, AI_NUMERICHOST | AI_NUMERICSERV);
	if (aip == NULL) {
		printf("proxy addrinfo fail. %s : %s\n", proxy_ip, proxy_port);
		return -1;
	}
	memcpy(&proxy_ai, aip, sizeof(*aip));



	/* target socket. open and bind own if */
	sfd_target = socket(target_ai.ai_family, target_ai.ai_socktype, target_ai.ai_protocol);
	if (sfd_target < 0) {
	    perror("target socket open error\n");
	    return -1;
	}
	if (bind(sfd_target, (struct sockaddr *)bind_sa, sizeof(*bind_sa)) < 0) {
	    close(sfd_target);
	    perror("target socket bind error\n");
	    return -1;
	}

	/* proxy socket. open */
	sfd_proxy = socket(proxy_ai.ai_family, proxy_ai.ai_socktype, proxy_ai.ai_protocol);
	if (sfd_proxy < 0) {
	    perror("proxy socket open error\n");
	    return -1;
	}
	if (bind(sfd_proxy, proxy_ai.ai_addr, sizeof(struct sockaddr_in6)) < 0) {
	    perror("proxy socket bind error");
	    return -1;
	}


	sockets[0] = sfd_target;
	sockets[1] = sfd_proxy;
	memcpy(&sas[0], target_ai.ai_addr, sizeof(struct sockaddr_in6));
	memcpy(&sas[1], bind_ai.ai_addr,   sizeof(struct sockaddr_in6));
	memcpy(&sas[2], proxy_ai.ai_addr,  sizeof(struct sockaddr_in6));

	return 0;
}




int connect_sockets (
	int sfd_target,
	int sfd_proxy,
	struct sockaddr_in6 * sa_target
)
{
	int sfd_proxy_accepted;

	if (listen(sfd_proxy, 1) < 0) {
		perror("proxy listen error");
		return -1;
	}

	if ((sfd_proxy_accepted = accept(sfd_proxy, NULL, NULL)) < 0) {
		perror("proxy accept error");
		return -1;
	}
	printf("connection from client\n");

	if (connect(sfd_target, (struct sockaddr *)sa_target, sizeof(*sa_target)) < 0) {
		close(sfd_proxy_accepted);
		close(sfd_proxy);
		perror("target connect error");
		return -1;
	}
	printf("target connected\n\n");

	return sfd_proxy_accepted;
}



void proxying(int sfd1, int sfd2)
{
	unsigned int buf[4096];
	fd_set fds;
	int maxfd;

	while (1) {
		FD_ZERO(&fds);
		FD_SET(sfd1, &fds);
		FD_SET(sfd2, &fds);

		maxfd = (sfd1 > sfd2) ? sfd1 : sfd2;

		int sfd_active;
		sfd_active = select(maxfd + 1, &fds, NULL, NULL, NULL);
		if (sfd_active < 0) {
		        perror("select error\n");
		        exit(1);
		}

		int sfd_from;
		int sfd_to;
		if (FD_ISSET(sfd1, &fds)) {
			sfd_from = sfd1;
			sfd_to = sfd2;
		}
		if (FD_ISSET(sfd2, &fds)) {
			sfd_from = sfd2;
			sfd_to = sfd1;
		}

		size_t recvsize;
		recvsize = recv(sfd_from, buf, 4096, 0);
		if (recvsize < 0) {
			perror("recv error\n");
		}

		size_t sentsize;
		sentsize = send(sfd_to, buf, recvsize, 0);
		if (sentsize < 0) {
			perror("send error\n");
		}
	}
}



void print_usage()
{
	printf(
	"few args"								"\n"
	""									"\n"
	"usage: ipv6tcpproxy  targe_ip port  bind_ip port  proxy_ip port"	"\n"
	""									"\n"
	"  example"								"\n"
	"    ipv6proxy  fe80::11 62010  fe80::20 0  9999::1 10000"		"\n"
	""									"\n"
	"  +-------+ fe80::11.60010    fe80::20.auto +------------+ 9999::1.10000    +--------+"	"\n"
	"  | target| <-------------------------------|ipv6tcpproxy|<---------------->| client |"	"\n"
	"  +-------+                                 +------------+                  +--------+"	"\n"
	""												"\n"
	);
}




int main(int argc, char ** argv)
{
	int sfds[2];
	struct sockaddr_in6 sas[3];
	
	char * target_ip   = argv[1];
	char * target_port = argv[2];
	char * bind_ip     = argv[3];
	char * bind_port   = argv[4];
	char * proxy_ip    = argv[5];
	char * proxy_port  = argv[6];

	if (argc < 7) {
		print_usage();
		exit(1);
	}
	
	int ret;
	ret = open_sockets(
		sfds,
		sas,
		target_ip, target_port,
		bind_ip,   bind_port,
		proxy_ip,  proxy_port
	);
	if (ret < 0) {
		printf("socket open error\n");
		exit(1);
	}
	printf("\n");
	printf("wait connection from client...\n");
	printf("\n");

	int sfd_target = sfds[0];

	int sfd_proxy;
	sfd_proxy = connect_sockets(sfds[0], sfds[1], &sas[0]);
	if (sfd_proxy < 0) {
		printf("connect / bind error\n");
		exit(1);
	}

	proxying(sfd_target, sfd_proxy);

	return 0;
}

