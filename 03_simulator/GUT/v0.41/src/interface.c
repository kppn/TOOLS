#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>

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

#include <linux/if_tun.h>
#include <linux/if_packet.h>
#include <linux/if_ether.h>

#include <errno.h>


#include "common.h"
#include "interface.h"
#include "gtp.h"

#include "global.h"


/* User Packet Reciever socket(TUN Device) open */
int tun_sock_open(char *dev)
{
	struct ifreq ifr;
	int fd;
	int err;
	char devpath[256];

	sprintf(devpath, "%s%s", "/dev/net/", dev);
	if( (fd = open(devpath, O_RDWR)) < 0 )
		return -1;



	memset(&ifr, 0, sizeof(ifr));

	ifr.ifr_flags = IFF_TUN;
	strncpy(ifr.ifr_name, dev, IFNAMSIZ);

	if( (err = ioctl(fd, TUNSETIFF, (void *) &ifr)) < 0 ){
		close(fd);
		return err;
	}
	strcpy(dev, ifr.ifr_name);

	/* set device ethernet for address autoconfiguration */
	if( (err = ioctl(fd, TUNSETLINK, ARPHRD_ETHER)) < 0 ){
	        close(fd);
	        return err;
	}

	return fd;
}



int tun_sock_close(int fd) 
{
	close(fd);

	return 0;
}




int udp_sock_open(const char * ip, uint16_t port)
{
	int sfd;
	struct sockaddr_in sin;
	
	sin.sin_port = htons(port);
	sin.sin_family = AF_INET;
	sin.sin_addr.s_addr = inet_addr(ip);

	if( (sfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
		printf("UDP Socket open error\n");
		exit(1);
	}

	if (bind(sfd, (struct sockaddr *)&sin, sizeof(sin)) < 0) {
		printf("UDP Socket bind Error, %s:%d\n", ip, port);
		exit(1);
	}
	
	return sfd;
}



int udp_sock_close(int fd)
{
	close(fd);

	return 0;
}




static int setip(char * dev, char * ip, sa_family_t family) 
{
	char buf[1024];
	int ret;


	if (family == AF_INET) {
		sprintf(buf, "/sbin/ifconfig %s %s", dev, ip);
		DEBUGPRINT(1, ("set if    : %s\n", buf));
		ret = system(buf);
	}

	if (family == AF_INET6) {
		sprintf(buf, "/sbin/ifconfig %s up", dev);
		DEBUGPRINT(1, ("up if     : %s\n", buf));
		ret = system(buf);
		if (ret != 0)
			return ret;
	
		sprintf(buf, "/sbin/ifconfig %s inet6 add %s", dev, ip);
		DEBUGPRINT(1, ("set if    : %s\n", buf));
		ret = system(buf);
	}

	return ret;
}




static int setroute(char * dev, char * route, sa_family_t family) 
{
	char buf[1024];
	int ret;
	char * route_target;

	if (family == AF_INET) {
		if (strstr(route, "/32"))
			route_target = "-host";
		else
			route_target = "-net";
	
	
		sprintf(buf, "/sbin/route add %s %s dev %s", route_target, route, dev);
		DEBUGPRINT(1, ("set route : %s\n", buf));
		ret = system(buf);
	}
	if (family == AF_INET6) {
		sprintf(buf, "/sbin/route -A inet6 add %s dev %s", route, dev);
		DEBUGPRINT(1, ("set route : %s\n", buf));
		ret = system(buf);
	}

	return ret;
}




int setif(Session * sp) 
{
	int ret = 0;

	if (sp->user_addr4[0] != '\0')
		ret += setip(sp->tun_dev, sp->user_addr4, AF_INET);
	if (sp->user_addr6[0] != '\0')
		ret += setip(sp->tun_dev, sp->user_addr6, AF_INET6);

	if (sp->dst_route4[0] != '\0')
		ret += setroute(sp->tun_dev, sp->dst_route4, AF_INET);
	if (sp->dst_route6[0] != '\0')
		ret += setroute(sp->tun_dev, sp->dst_route6, AF_INET6);

	return ret;
}










/* tun device adding frame header. delete this header		*/
/* 	i.e.  2oct flag						*/
/* 	      2oct protocol (RFC1340. e.g. IP:0800, IPv6:08DD)	*/

#define TUN_FRAME_H_LEN 4

uchar * encap_tunframe(uchar * user_p)
{
	uchar * tun_frame;
	int ip_ver;
	
	tun_frame = user_p - TUN_FRAME_H_LEN;

	ip_ver = (user_p[0] >> 4) & 0x0f;

	/* dummy tun frame */
	tun_frame[0] = 0x00;
	tun_frame[1] = 0x00;

	if (ip_ver == 4) {
		tun_frame[2] = 0x08;
		tun_frame[3] = 0x00;
	} 
	if (ip_ver == 6) {
		tun_frame[2] = 0x86;
		tun_frame[3] = 0xdd;
	} 

	return tun_frame;
}




uchar * decap_tunframe(uchar * buf)
{
	return buf + TUN_FRAME_H_LEN;
}




int read_tun(int tunfd, uchar * buf, int size, uchar ** user_p)
{
	int readsize;

	/* read from tun device */
	readsize = read(tunfd, buf, size);
	if (readsize < 0) {
		printf("Error: tun device read error\n");
		return readsize;
	}

	DEBUGPRINT(2, ("\n"));
	DEBUGPRINT(2, ("read from tun device. size: %d\n", readsize));
	DEBUGDUMP(3, (buf, readsize));
	DEBUGPRINT(3, ("\n\n"));

	*user_p = decap_tunframe(buf);

	return readsize + (buf - *user_p);
}



int write_tun(int tunfd, uchar * buf, int size)
{
	int writesize;
	uchar * tun_frame;
	tun_frame = encap_tunframe(buf);

	writesize = size + (buf - tun_frame);

	if ( (writesize = write(tunfd, tun_frame, writesize)) < 0) {
		printf("Error: tun device send error: %s\n", strerror(errno));
		return writesize;
	}

	DEBUGPRINT(2, ("\n"));
	DEBUGPRINT(2, ("send to tun. size: %d\n", writesize));
	DEBUGDUMP(3, (tun_frame, writesize));
	DEBUGPRINT(3, ("\n"));

	return writesize;
}




int recv_gtp_pdu(int udpfd, uchar * buf, int size, struct sockaddr_in * udp_from,
		     uint8_t * msg_type, uint32_t * teid, uint16_t * seq, uchar ** user_p)
{
	int recvsize;
	socklen_t socklen;

	socklen = sizeof(struct sockaddr_in);

	/* receive from udp socket */
	recvsize = recvfrom(udpfd, buf, size, 0, (struct sockaddr *)udp_from, &socklen);
	if (recvsize < 0) {
		printf("Error: gtp read error\n");
		return recvsize;
	}

	DEBUGPRINT(2, ("\n"));
	DEBUGPRINT(2, ("read from udp socket. size: %d\n", recvsize));
	DEBUGDUMP(3, (buf, recvsize));
	DEBUGPRINT(3, ("\n"));

	*user_p = decap_gtp_header(buf, msg_type, teid, seq);

	return recvsize + (buf - *user_p);
}





int send_gtp_pdu(int udpfd, uchar * buf, int size, struct sockaddr_in * udp_dst, 
                 uint8_t msg_type, uint32_t teid, uint16_t seq)
{
	int sendsize;
	uchar * gtp_p;


	gtp_p = encap_gtp_header(buf, size, msg_type, teid, seq, 0);
	sendsize = size + (buf - gtp_p);

	/* send GTP-U UDP packet */
	sendsize = sendto(udpfd, gtp_p, sendsize, 0, (struct sockaddr *)udp_dst, sizeof(*udp_dst));
	if (sendsize < 0) {
		printf("udp socket send error\n");
		DEBUGPRINT(2, ("ip       : %08x\n", udp_dst->sin_addr.s_addr));
		DEBUGPRINT(2, ("port     : %04x\n", udp_dst->sin_port));
		DEBUGPRINT(2, ("\n"));
		return sendsize;
	}
	DEBUGPRINT(2, ("\n"));
	DEBUGPRINT(2, ("send to udp socket. size: %d\n", sendsize));
	DEBUGDUMP(3, (gtp_p, sendsize));
	DEBUGPRINT(3, ("\n"));

	return sendsize;
}



