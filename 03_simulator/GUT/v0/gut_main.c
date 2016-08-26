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
#include "gtp.h"

#define BUFSIZE	65572	/* Packet Buffer */





/* User Packet Reciever socket(TUN Device) open */
int tun_sock_open(char *dev)
{
	struct ifreq ifr;
	int fd;
	int err;

	if( (fd = open("/dev/net/tun0", O_RDWR)) < 0 )
		return -1;



	memset(&ifr, 0, sizeof(ifr));

	ifr.ifr_flags = IFF_TUN;
	strncpy(ifr.ifr_name, dev, IFNAMSIZ);

	if( (err = ioctl(fd, TUNSETIFF, (void *) &ifr)) < 0 ){
		close(fd);
		return err;
	}
	strcpy(dev, ifr.ifr_name);

	return fd;
}




/* GTP Tunnel Sender/Reciever socket(DGRAM) open */
int udp_sock_open(struct environ env, struct sockaddr_in * sin)
{
	int sfd; 
	
	/* set UDP Socket Address to sockaddr	*/
	sin->sin_port = htons(env.gtpu_port);
	sin->sin_family = AF_INET;
	sin->sin_addr.s_addr = inet_addr(env.own_gtpu_addr);

	if( (sfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
		printf("UDP Socket open error\n");
		exit(1);
	}

	if (bind(sfd, (struct sockaddr *)sin, sizeof(*sin)) < 0) {
		printf("UDP Socket bind Error, %s:%d\n", env.own_gtpu_addr, env.gtpu_port);
		exit(1);
	}

	return sfd;
}





/* User Packet Sender socket(RAW) open */
int raw_sock_open(int domain)
{
	int sfd;
	int hincl;

	if( (sfd = socket(domain, SOCK_RAW, IPPROTO_RAW)) < 0) {
		printf("RAW Socket open error\n");
		exit(1);
	}


	if (domain == PF_INET) {
		if (setsockopt(sfd, IPPROTO_IP, IP_HDRINCL, &hincl, sizeof(hincl)) < 0) {
			printf("setsockopt error PF_INET: IP_HDRINCL\n");
			exit(1);
		}
	}
	if (domain == PF_INET6) {
		char * dev = "tun0";

		if (setsockopt(sfd, IPPROTO_IPV6, IP_HDRINCL, &hincl, sizeof(hincl)) < 0) {
			printf("setsockopt error PF_INET6: IP_HDRINCL\n");
			exit(1);
		}
		if (setsockopt(sfd, IPPROTO_IPV6, SO_BINDTODEVICE, dev, strlen(dev)+1) < 0) {
			printf("setsockopt error PF_INET6: SO_BINDTODEVICE\n");
			exit(1);
		}
	}

	return sfd;
}





int setipv4(char * dev, char * ip, char * pointopoint) 
{
	char buf[1024];

	sprintf(buf, "/sbin/ifconfig %s %s", dev, ip);
	printf("set if    : %s\n", buf);
	return system(buf);
}




int setroute4(char * dev, char * route) 
{
	char buf[1024];
	char * route_target;

	if (strstr(route, "/32"))
		route_target = "-host";
	else
		route_target = "-net";


	sprintf(buf, "/sbin/route add %s %s dev %s", route_target, route, dev);
	printf("set route : %s\n", buf);
	return system(buf);
}




int setipv6(char * dev, char * ip)
{
	char buf[1024];
	int ret;

	sprintf(buf, "/sbin/ifconfig %s up", dev);
	printf("up if     : %s\n", buf);
	ret = system(buf);
	if (ret != 0)
		return ret;

	sprintf(buf, "/sbin/ifconfig %s inet6 add %s", dev, ip);
	printf("set if    : %s\n", buf);
	ret = system(buf);

	return ret;
}




int setroute6(char * dev, char * route) 
{
	char buf[1024];

	sprintf(buf, "/sbin/route -A inet6 add %s dev %s", route, dev);
	printf("set route : %s\n", buf);
	return system(buf);
}




int setif(struct environ env) 
{
	int ret = 0;

	if (env.user_addr4[0] != '\0')
		ret += setipv4(env.tun_dev, env.user_addr4, env.dst_gtpu_addr);
	if (env.dst_route4[0] != '\0')
		ret += setroute4(env.tun_dev, env.dst_route4);
	if (env.user_addr6[0] != '\0')
		ret += setipv6(env.tun_dev, env.user_addr6);
	if (env.dst_route6[0] != '\0')
		ret += setroute6(env.tun_dev, env.dst_route6);

	return ret;
}




int read_environ(struct environ * env, char * filename)
{
	char buf[256];
	char * p;
	int euip_error = 0;

	/* read environment from config file */
	p = "TUNNEL_DEVIDE";
	if(get_initenv(filename, buf, p) < 0) {
		printf("Error: Eviron elem read error : %s\n", p);
		exit(1);
	}
	strcpy(env->tun_dev, buf);

	p = "GTP-U_UDP_Port";
	if(get_initenv(filename, buf, p) < 0) {
		printf("Error: Eviron elem read error : %s\n", p);
		exit(1);
	}
	env->gtpu_port = atoi(buf);

	p = "GTP-U_OWN_IP";
	if(get_initenv(filename, buf, p) < 0) {
		printf("Error: Eviron elem read error : %s\n", p);
		exit(1);
	}
	strcpy(env->own_gtpu_addr, buf);

	p = "GTP-U_DST_IP";
	if(get_initenv(filename, buf, p) < 0) {
		printf("Error: Eviron elem read error : %s\n", p);
		exit(1);
	}
	strcpy(env->dst_gtpu_addr, buf);

	p = "GWP-U_TEID";
	if(get_initenv(filename, buf, p) < 0) {
		printf("Error: Eviron elem read error : %s\n", p);
		exit(1);
	}
	env->dst_gtpu_teid = strtoul(buf, &p, 16);


	p = "EUIPv4";
	if(get_initenv(filename, buf, p) == 0) {
		strcpy(env->user_addr4, buf);
		p = "SERVER_NW_v4";
		if(get_initenv(filename, buf, p) ==  0) {
			strcpy(env->dst_route4, buf);
		}
		else {
			env->dst_route4[0] = '\0';
			printf("Warning: Option eviron elem read failed : %s\n", p);
		}
	}
	else {
		env->user_addr4[0] = '\0';
		env->dst_route4[0] = '\0';
	}
	if (env->user_addr4[0] == '\0')
		euip_error++;

	
	p = "EUIPv6";
	if (get_initenv(filename, buf, p) == 0) {
		strcpy(env->user_addr6, buf);
		p = "SERVER_NW_v6";
		if(get_initenv(filename, buf, p) ==  0) {
			strcpy(env->dst_route6, buf);
		}
		else {
			env->dst_route6[0] = '\0';
			printf("Warning: Option eviron elem read failed : %s\n", p);
		}
	}
	else {
		env->user_addr6[0] = '\0';
		env->dst_route6[0] = '\0';
	}
	if (env->user_addr6[0] == '\0')
		euip_error++;

	/* Both IPv4/IPv6 EUIP Read Failed */
	if (euip_error == 2) {
		printf("Error: Both EUIPv4/EUIPv6 read error. Please check your config file\n");
		exit(1);
	}

	return 0;
}




void disp_environ(struct environ env) 
{
	printf("\n");
	printf("========= Environment ============ \n");
	printf("tun_dev : '%s'\n", env.tun_dev);
	printf("char own_gtpu_addr : '%s'\n", env.own_gtpu_addr);
	printf("char dst_gtpu_addr : '%s'\n", env.dst_gtpu_addr);
	printf("gtpu_port : %d\n", env.gtpu_port);
	printf("dst_gtpu_teid : %08x\n", env.dst_gtpu_teid);
	printf("user_addr4 : '%s'\n", env.user_addr4 == NULL ? "" : env.user_addr4);
	printf("dst_route4 : '%s'\n", env.dst_route4 == NULL ? "" : env.dst_route4);
	printf("user_addr6 : '%s'\n", env.user_addr6 == NULL ? "" : env.user_addr6);
	printf("dst_route6 : '%s'\n", env.dst_route6 == NULL ? "" : env.dst_route6 );
	printf("\n");
}



int max(int a, int b)
{
	return (a > b) ? a : b;
}



int read_tun(int tunfd, uchar * buf, int bufsize)
{
	int packsize;

	/* read from tun device */
	packsize = read(tunfd, buf, bufsize);
	if (packsize < 0) {
		printf("Error: tun device read error\n");
		return -1;
	}
	printf("read from tun device. size: %d\n", packsize);
	dump(buf, packsize);
	printf("\n\n");

	return packsize;
}

int send_gtp_pdu(int udpfd, uchar * user_p, int packsize, struct sockaddr_in * udp_dst,
		 struct environ * env)
{
	int gtp_header_len;
	uchar * gtp_p;

	/* encapsulate GTP Header */
	gtp_header_len = encap_gtp_header(user_p, packsize, GTP_MSGTYPE_N_PDU, env->dst_gtpu_teid, 0);
	gtp_p = user_p - gtp_header_len;

	/* send GTP-U UDP packet */
	if( sendto(udpfd, gtp_p, packsize+gtp_header_len, 0, 
	    (struct sockaddr *)udp_dst, sizeof(*udp_dst)) < 0) {
		printf("udp socket send error\n");
		return -1;
	}
	printf("send to udp socket. size: %d\n", packsize+gtp_header_len);
	dump(gtp_p, packsize + gtp_header_len);
	printf("\n\n");

	return 0;
}



int send_gtp_echo_resp(int udpfd, uchar * user_p, int packsize, struct sockaddr_in * udp_dst,
		 struct environ * env)
{
	int gtp_header_len;
	uchar * gtp_p;

	/* encapsulate GTP Header */
	gtp_header_len = encap_gtp_header(user_p, packsize, GTP_MSGTYPE_ECHO_RES, env->dst_gtpu_teid, 0);
	gtp_p = user_p - gtp_header_len;

	/* send GTP-U Echo Response UDP packet */
	if( sendto(udpfd, gtp_p, gtp_header_len, 0, 
	    (struct sockaddr *)udp_dst, sizeof(*udp_dst)) < 0) {
		printf("udp socket send error\n");
		return -1;
	}
	printf("send to udp socket. size: %d\n", packsize+gtp_header_len);
	dump(gtp_p, gtp_header_len);
	printf("\n\n");

	return 0;
}



int read_gtp_pdu(int udpfd, uchar * buf, int bufsize)
{
	int packsize;

	/* read from tun device */
	packsize = read(udpfd, buf, bufsize);
	if (packsize < 0) {
		printf("Error: gtp eread error\n");
		return -1;
	}
	printf("read from udp socket. size: %d\n", packsize);
	dump(buf, packsize);
	printf("\n\n");

	return packsize;
}

int send_raw(int rawfd, uchar * buf, int packsize, sa_family_t family)
{
	struct iphdr * iph;
	struct sockaddr_in ip_dst;

	printf("send to raw socket. size: %d\n", packsize);
	dump(buf, packsize);
	printf("\n\n");

	if (family == AF_INET) {
		struct iphdr * iph = (struct iphdr *)buf;
		struct sockaddr_in ip_dst;

		memset(&ip_dst, 0, sizeof(ip_dst));
		ip_dst.sin_addr.s_addr = iph->daddr;
		ip_dst.sin_family = family;
		if( sendto(rawfd, buf, packsize, 0, (struct sockaddr *)&ip_dst, sizeof(ip_dst)) < 0) {
			printf("raw socket send error %s\n", strerror(errno));
			return -1;
		}
	}
	if (family == AF_INET6) {
		struct sockaddr_in6 ip_dst;

		/* hoge */
		ip_dst.sin6_family = family;

		memset(&ip_dst, 0, sizeof(ip_dst));
		ip_dst.sin6_addr.s6_addr[0] = 0xfe;
		ip_dst.sin6_addr.s6_addr[1] = 0x80;
		ip_dst.sin6_addr.s6_addr[2] = 0x00;
		ip_dst.sin6_addr.s6_addr[4] = 0x00;
		ip_dst.sin6_addr.s6_addr[3] = 0x00;
		ip_dst.sin6_addr.s6_addr[5] = 0x00;
		ip_dst.sin6_addr.s6_addr[6] = 0x00;
		ip_dst.sin6_addr.s6_addr[7] = 0x00;
		ip_dst.sin6_addr.s6_addr[8] = 0x00;
		ip_dst.sin6_addr.s6_addr[9] = 0x00;
		ip_dst.sin6_addr.s6_addr[10] = 0x00;
		ip_dst.sin6_addr.s6_addr[11] = 0x00;
		ip_dst.sin6_addr.s6_addr[12] = 0x00;
		ip_dst.sin6_addr.s6_addr[13] = 0x00;
		ip_dst.sin6_addr.s6_addr[14] = 0x00;
		ip_dst.sin6_addr.s6_addr[15] = 0x01;

		/*
		memcpy(ip_dst.sin6_addr.s6_addr, &buf[24], 16);
		*/

		printf("hogeeeeeeeeeeeeeeeeeeeeeee\n");
		dump(ip_dst.sin6_addr.s6_addr, 16);
		printf("\n\n");

		if( sendto(rawfd, buf, packsize, 0, (struct sockaddr *)&ip_dst, sizeof(ip_dst)) < 0) {
			printf("raw socket send error %s\n", strerror(errno));
			return -1;
		}
	}

	return 0;
}



#define GTP_H_SPACE	32

/* tun device adding frame header. delete this header		*/
/* 	i.e.  2oct flag						*/
/* 	      2oct protocol (RFC1340. e.g. IP:0800, IPv6:08DD)	*/
#define TUN_FRAME_H_LEN	4

/*======================================================================================*/
/* Transfer Packet through GTP Tunnel							*/
/* 	* TUN device     =====> <GTP Encap> GTP/UDP socket				*/
/*	* GTP/UDP socket =====> <GTP Decap> RAW socket					*/
/*======================================================================================*/
int packet_transfer(int tunfd, int udpfd, struct sockaddr_in * udp_dst, int rawfd, int raw6fd,
		    struct environ *env)
{
	uchar buf[BUFSIZE];
	int packsize;
	uchar * user_p;		/* point to user packet in buffer 	*/
	int gtp_header_len;
	int sel;
	int ip_ver;

	fd_set fds;
	int maxfd;


	while(1) {
		printf("in transfer loop\n");

		FD_ZERO(&fds);
		FD_SET(tunfd, &fds);
		FD_SET(udpfd, &fds);

		maxfd = max(tunfd, udpfd);

		sel =  select(maxfd + 1, &fds, NULL, NULL, NULL);
		printf("select return %d\n", sel);
		if( sel < 0) {
			printf("Error: select error\n");
			exit(1);
		}
		if (FD_ISSET(tunfd, &fds)) {
			user_p = buf + GTP_H_SPACE;	/* space of GTP Header	*/	

			packsize = read_tun(tunfd, user_p, BUFSIZE-GTP_H_SPACE);
			if (packsize < 0)
				return -1;

			/* tun device adding frame header. delete this header */
			user_p   += TUN_FRAME_H_LEN;
			packsize -= TUN_FRAME_H_LEN;

			send_gtp_pdu(udpfd, user_p, packsize, udp_dst, env);
		}
		if (FD_ISSET(udpfd, &fds)) {
			packsize = read_gtp_pdu(udpfd, buf, BUFSIZE);
			if (packsize < 0)
				return -1;

			if (get_gtp_msgtype(buf) == GTP_MSGTYPE_ECHO_REQ) {
				send_gtp_echo_resp(udpfd, user_p, 0, udp_dst, env);
				continue;
			}

			gtp_header_len = decap_gtp_header(buf);
			user_p = buf + gtp_header_len;
			packsize = packsize - gtp_header_len;
			
			ip_ver = (user_p[0] >> 4) & 0x0f;
			printf("IP Version %d\n", ip_ver);
			switch (ip_ver) {
			case 4:
				send_raw(rawfd, user_p, packsize, AF_INET);
				break;
			case 6:
				send_raw(raw6fd, user_p, packsize, AF_INET6);
				break;
			default:
				printf("IP Version unspecified %d\n", ip_ver);
			}
		}

	}

	return 0;
}





/*======================================================================================*/
/* main											*/
/*======================================================================================*/
int main(int argc, char ** argv)
{
	char device[128] = "tun0";

	int tunfd;
	int rawfd;
	int raw6fd;
	int udpfd;

	struct environ env;
	struct sockaddr_in udp_dst;
	struct sockaddr_in udp_own;

	read_environ(&env, "./gut.conf");
	disp_environ(env);

	/* hogeeeeeee */
	/*
	iph = (struct iphdr *)buf;
	raw_dst.sin_addr.s_addr = iph->daddr;
	raw_dst.sin_family = AF_INET;
	*/

	/**** open tun device						****/
	/**** read from config file and set IP/Router to tun device 	****/
	tunfd = tun_sock_open(device);
	if (tunfd < 0) {
		printf("open failure: %s\n", device);
		exit(1);
	}
	printf("========= Set Interface ============ \n");
	printf("gen device: %s\n", device);
	if(setif(env) < 0) {
		printf("I/F Setting Error\n");
		exit(1);
	}
	printf("\n");
	printf("==================================== \n\n");


	/**** open raw socket	 ****/
	rawfd = raw_sock_open(AF_INET);
	raw6fd = raw_sock_open(AF_INET6);

	/**** open udp socket	****/
	udpfd = udp_sock_open(env, &udp_own);
	/* set udp destination */
	udp_dst.sin_addr.s_addr = inet_addr(env.dst_gtpu_addr);
	udp_dst.sin_family = AF_INET;
	udp_dst.sin_port = htons(env.gtpu_port);

	/* Packet Transfer */
	if (packet_transfer(tunfd, udpfd, &udp_dst, rawfd, raw6fd, &env) < 0) {
		printf("Error: packet transferring function\n");
		exit(1);
	}


	return 0;
}



