/*======================================================*/
/*							*/
/* Change history					*/
/*							*/
/* 	2011/4/18	T.Kondoh			*/
/*		* v0.40 first release			*/
/*							*/
/*======================================================*/


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
#include "interface.h"
#include "command.h"
#include "init.h"

#define GLOBAL_IMPL
#include "global.h"
#undef GLOBAL_IMPL


#define PACKETBUFSIZE	65572	/* Packet Buffer */
#define GTP_H_SPACE	32





Session * find_session(Environ * env, uint32_t teid)
{
	int i;

	for (i = 0; i < env->max_tunnel_device; i++)
		if (env->session[i].own_gtpu_teid == teid)
			return &env->session[i];
	return NULL;
}


/*======================================================================================*/
/* Transfer Packet through GTP Tunnel							*/
/* 	* TUN device     =====> <GTP Encap> GTP/UDP socket				*/
/*	* GTP/UDP socket =====> <GTP Decap> TUN device					*/
/*======================================================================================*/
int packet_transfer(Environ *env)
{
	uchar buf_tmp[PACKETBUFSIZE];
	uchar * buf;
	uchar * user_p;		/* point to user packet in buffer 	*/

	int packsize;
	int sel;

	int i;
	socklen_t socklen;

	fd_set fds;
	int maxfd_num;

	uint8_t msg_type;
	uint32_t teid;
	uint16_t seq;
	Session * sp;

	struct sockaddr_in udp_from;
	const uint8_t dummy_recovery[2] = {0x0e, 0x00};

	buf = buf_tmp + GTP_H_SPACE;
	memset(&udp_from, 0, sizeof(udp_from));
	socklen = sizeof(struct sockaddr_in);

	while(1) {
		FD_ZERO(&fds);
		for (i = 0; i < env->max_tunnel_device; i++)
			if (env->session[i].tunfd != TUNFD_UNUSE)
				FD_SET(env->session[i].tunfd, &fds);
		FD_SET(env->udpfd, &fds);
		FD_SET(env->command_sfd, &fds);
		maxfd_num = maxfd(env);
		DEBUGPRINT(2, ("maxfd : %d\n", maxfd_num));
		sel =  select(maxfd_num + 1, &fds, NULL, NULL, NULL);
		if( sel < 0) {
			DEBUGPRINT(1, ("Error: select error\n"));
			exit(1);
		}


		/* received command */
		if (FD_ISSET(env->command_sfd, &fds)) {
			packsize = recvfrom(env->command_sfd, buf, 4096, 0, (struct sockaddr *)&udp_from, &socklen);
			exec_command(buf, packsize, env, &udp_from);
			
			socklen = sizeof(struct sockaddr_in);
			continue;
		}
		
		/* received TUNFD */
		for (i = 0; i < env->max_tunnel_device; i++) {
			sp = &(env->session[i]);
			if (sp->tunfd == TUNFD_UNUSE)
				continue;
			if (FD_ISSET(sp->tunfd, &fds)) {
				packsize = read_tun(sp->tunfd, buf, PACKETBUFSIZE, &user_p);
				if (packsize < 0)
					break;
				sp->trans_bytes += packsize;
				send_gtp_pdu(env->udpfd, user_p, packsize, (struct sockaddr_in *)&sp->udp_dst, 
				             GTP_MSGTYPE_N_PDU, sp->dst_gtpu_teid, sp->seq++);
				break;
			}
		}
		
		/* received GTP-U */
		if (FD_ISSET(env->udpfd, &fds)) {
			packsize = recv_gtp_pdu(env->udpfd, buf, PACKETBUFSIZE, &udp_from,
				                &msg_type, &teid, &seq, &user_p);
			DEBUGPRINT(1, ("pack from gtp %d\n", packsize));
			if (packsize < 0)
				continue;

			if (msg_type == GTP_MSGTYPE_ECHO_REQ) {
				DEBUGPRINT(1, ("recieve GTP Echo request. \n"));
				memcpy(user_p, dummy_recovery, 2);
				packsize = 2;
				send_gtp_pdu(env->udpfd, user_p, packsize, (struct sockaddr_in *)&udp_from,
				             GTP_MSGTYPE_ECHO_RES, 0, seq);
				DEBUGPRINT(1, ("send GTP Echo Response. \n"));
				continue;
			}
			if (msg_type == GTP_MSGTYPE_END_MARKER) {
				printf("receive End Marker \n");
				continue;
			}
			if (msg_type == GTP_MSGTYPE_ERR_IND) {
				printf("receive Error Indication\n");
				continue;
			}

			/* find session. and write to TUN */

			sp = find_session(env, teid);
			if (sp == NULL) {
				printf("Session not found: recieved TEID: %08x\n", teid);
				continue;
			}
			
			sp->receive_bytes += packsize;
			write_tun(sp->tunfd, user_p, packsize);
		}

	}

	return 0;
}



/*======================================================================================*/
/* main											*/
/*======================================================================================*/
int main(int argc, char ** argv)
{
	Environ env;

	char confname[128] = "/etc/gut.conf";

	if (argc > 1) 
		strcpy(confname, argv[1]);
	DEBUGPRINT(1, ("config file : %s\n", confname));

	init_environ(&env, confname);

	/* Packet Transfer */
	if (packet_transfer(&env) < 0) {
		printf("Error: packet transferring function\n");
		exit(1);
	}

	return 0;
}



