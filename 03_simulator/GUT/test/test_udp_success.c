#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <netdb.h>

#include <fcntl.h>

#include <net/if.h>
#include <arpa/inet.h>

#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/udp.h>

#include <linux/if_tun.h>
#include <linux/if_packet.h>
#include <linux/if_ether.h>
/*
#include <linux/in6.h>
#include <linux/ipv6.h>
#include <linux/icmpv6.h>
*/

#include <errno.h>

#include "common.h"


#define BUFSIZE	65572	/* Packet Buffer */




/* User Packet Sender socket(RAW) open */
int raw_sock_open()
{
	int sfd;
	int hincl;

	/*
	if( (sfd = socket(AF_INET6, SOCK_RAW, IPPROTO_ICMPV6)) < 0) {
	*/
	if( (sfd = socket(AF_INET6, SOCK_RAW, IPPROTO_UDP)) < 0) {
		printf("RAW Socket open error\n");
		exit(1);
	}


	char * dev = "eth1";

	if (setsockopt(sfd, IPPROTO_IPV6, IP_HDRINCL, &hincl, sizeof(hincl)) < 0) {
		printf("setsockopt error PF_INET6: IP_HDRINCL\n");
		exit(1);
	}
	if (setsockopt(sfd, IPPROTO_IPV6, SO_BINDTODEVICE, dev, strlen(dev)+1) < 0) {
		printf("setsockopt error PF_INET6: SO_BINDTODEVICE\n");
		exit(1);
	}

	return sfd;
}





int max(int a, int b)
{
	return (a > b) ? a : b;
}




static unsigned char cmsgbuf[8192];
int cmsglen;
int confirm = 0;

/*======================================================================================*/
/* main											*/
/*======================================================================================*/
int main(int argc, char ** argv)
{
	char device[128] = "eth1";
	uchar buf[4096];
	int packsize = 16;
	int i;

	int raw6fd;

	for (i = 0; i < packsize; i++) {
		buf[i] = i;
	}

	raw6fd = raw_sock_open();
	if (raw6fd < 0) {
		printf("raw sock open error\n");
		exit(1);
	}


	/***************************************************/
	{
	struct ifreq ifr;
	struct cmsghdr *cmsg;
	struct in6_pktinfo *ipi;
				
	memset(&ifr, 0, sizeof(ifr));
	strncpy(ifr.ifr_name, device, IFNAMSIZ-1);
	if (ioctl(raw6fd, SIOCGIFINDEX, &ifr) < 0) {
		fprintf(stderr, "ping: unknown iface %s\n", device);
		exit(2);
	}
	cmsg = (struct cmsghdr*)cmsgbuf;
	cmsglen += CMSG_SPACE(sizeof(*ipi));
	cmsg->cmsg_len = CMSG_LEN(sizeof(*ipi));
	cmsg->cmsg_level = SOL_IPV6;
	cmsg->cmsg_type = IPV6_PKTINFO;
			
	ipi = (struct in6_pktinfo*)CMSG_DATA(cmsg);
	memset(ipi, 0, sizeof(*ipi));
	ipi->ipi6_ifindex = ifr.ifr_ifindex;
	}
	/*************************************************/


	/************************************************/
	{
	struct msghdr mhdr;
	struct iovec iov;
	int i;
	int cc = packsize + 8;
	struct addrinfo hints; 
	struct addrinfo *res0;
	int gai;
	char * target = "2004::1";

	struct sockaddr_in6 whereto;	/* who to ping */
	int wheretolen;

	memset(&hints, 0, sizeof(hints));
	hints.ai_family = PF_INET6;
	hints.ai_socktype = SOCK_RAW;
	hints.ai_protocol = IPPROTO_ICMPV6;
	gai = getaddrinfo(target, NULL, &hints, &res0);
	if (gai) {
		fprintf(stderr, "ping: %s\n", gai_strerror(gai));
		exit(2);
	}
	if (!res0->ai_addr || res0->ai_addr->sa_family != AF_INET6) {
		fprintf(stderr, "ping: getaddrinfo() is broken.\n");
		exit(2);
	}
	memset(&whereto, 0, sizeof(struct sockaddr_in6));
	memcpy(&whereto, res0->ai_addr, res0->ai_addrlen);
	wheretolen = res0->ai_addrlen;

	whereto.sin6_family = AF_INET6;
	whereto.sin6_port = htons(IPPROTO_UDP);
	/*
	whereto.sin6_port = htons(IPPROTO_IPV6);
	*/

	printf("### whereto:\n");
	dump(&whereto, wheretolen);
	printf("\n\n");


	iov.iov_len  = cc;
	iov.iov_base = buf;

	mhdr.msg_name = &whereto;
	mhdr.msg_namelen = wheretolen;
	mhdr.msg_iov = &iov;
	mhdr.msg_iovlen = 1;
	mhdr.msg_control = cmsgbuf;
	mhdr.msg_controllen = cmsglen;


	struct sockaddr_in6 ip_dst;
	ip_dst.sin6_family = AF_INET6;

	printf("send to raw socket. size: %d\n", packsize);
	dump(buf, packsize);
	printf("\n\n");


	i = sendmsg(raw6fd, &mhdr, confirm);
	if(i < 0) {
		printf("raw socket send error %s\n", strerror(errno));
		return -1;
	}

	}
	/***********************************************/


	return 0;
}



