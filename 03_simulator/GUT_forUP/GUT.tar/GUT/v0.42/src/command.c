#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>

#include <net/if.h>
#include <net/if_arp.h>
#include <arpa/inet.h>

#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/udp.h>

#include "init.h"
#include "command.h"
#include "interface.h"
#include "global.h"


static char bs_buffer[2048];
static char * bs_current = NULL;
static int bs_length = 0;

char * sgets_init(char * bs, int l)
{
	bs_current = bs_buffer;
	bs_length = l;

	memcpy(bs_buffer, bs, l);

	return bs_buffer;

}

int sgets(char * buf, int size)
{
	int i;
	char * p = bs_current;
	
	for (i = 0; i < size - 1; i++) {
		if (bs_length <= 0)
			return 0;

		*buf = *bs_current;
		if (*bs_current == '\n')
			break;

		buf++;
		bs_current++;
		bs_length--;

	}
	*buf = '\0';
	bs_current++;
	
	return bs_current - p;
}



typedef struct _message {
	char * param_name;
	char * scan_syntax;	/* scanf input syntax. e.g. %d */
	size_t offset;		/* offset of Session structure member */
	char presense;		/* 'M':Mandatory, 'O':Optional */
	char * set_marker;	/* if parameter is included in message, set_marker = param_name */
	char type;		/* type of member of Session. 'I':32bit Signed Integer, 'U':32bit Unsigned Integer, 'S':char*, */
} Message;

Message def_add_request[] = 
{
	/* parameter name	syntax	offset of 'Session' structure		Presence	Marker */
	{"EBI",			"%d",	offsetof(Session, ebi),			'M', 		NULL},
	{"GTP-U_OWN_TEID",	"%08x",	offsetof(Session, own_gtpu_teid),	'M', 		NULL},
	{"GTP-U_DST_IP",	"%s",	offsetof(Session, dst_gtpu_addr),	'M', 		NULL},
	{"GTP-U_DST_TEID",	"%08x",	offsetof(Session, dst_gtpu_teid),	'M', 		NULL},
	{"EUIPV4",		"%s",	offsetof(Session, user_addr4),		'O', 		NULL},
	{"EUIPV6",		"%s",	offsetof(Session, user_addr6),		'O', 		NULL},
	{"SERVER_NW_V4",	"%s",	offsetof(Session, dst_route4),		'O', 		NULL},
	{"SERVER_NW_V6",	"%s",	offsetof(Session, dst_route6),		'O', 		NULL},
	{NULL, NULL, 0, '\0', NULL},
};


Message def_add_accept[] = 
{
	/* parameter name	syntax	offset of 'Session' structure		Presence	Marker */
	{"FD",			"%d",	offsetof(Session, tunfd),		'M', 		NULL,	'I'},
	{"TUNNEL_DEVIDE",	"%s",	offsetof(Session, tun_dev),		'M', 		NULL,	'S'},
	{"EBI",			"%d",	offsetof(Session, ebi),			'M', 		NULL, 	'I'},
	{"GTP-U_OWN_TEID",	"%08x",	offsetof(Session, own_gtpu_teid),	'M', 		NULL,	'U'},
	{"GTP-U_DST_IP",	"%s",	offsetof(Session, dst_gtpu_addr),	'M', 		NULL,	'S'},
	{"GTP-U_DST_TEID",	"%08x",	offsetof(Session, dst_gtpu_teid),	'M', 		NULL,	'U'},
	{"EUIPV4",		"%s",	offsetof(Session, user_addr4),		'O', 		NULL,	'S'},
	{"EUIPV6",		"%s",	offsetof(Session, user_addr6),		'O', 		NULL,	'S'},
	{"SERVER_NW_V4",	"%s",	offsetof(Session, dst_route4),		'O', 		NULL,	'S'},
	{"SERVER_NW_V6",	"%s",	offsetof(Session, dst_route6),		'O', 		NULL,	'S'},
	{NULL, NULL, 0, '\0', NULL},
};


Message def_delete_request[] = 
{
	/* parameter name	syntax	offset of 'Session' structure		Presence	Marker */
	{"EBI",			"%d",	offsetof(Session, ebi),			'M', 		NULL},
	{NULL, NULL, 0, '\0', NULL},
};

Message def_delete_accept[] = 
{
	/* parameter name	syntax	offset of 'Session' structure		Presence	Marker */
	{"TUNNEL_DEVIDE",	"%s",	offsetof(Session, tun_dev),		'M', 		NULL,	'S'},
	{NULL, NULL, 0, '\0', NULL},
};


Message def_flush_request[] = 
{
	{NULL, NULL, 0, '\0', NULL},
};

Message def_flush_accept[] = 
{
	{"TUNNEL_DEVIDE",	"%s",	offsetof(Session, tun_dev),		'M', 		NULL},
	{NULL, NULL, 0, '\0', NULL},
};







#define LINEBUFSIZE	1024
#define MSGBUFSIZE	16384


int exec_command(uchar * buf, size_t size, Environ * env, struct sockaddr_in * msg_from)
{
	int ret;
	int write_len = 0;
	char linebuf[LINEBUFSIZE];
	char msgbuf[MSGBUFSIZE];

	sgets_init((char *)buf, size);
	sgets(linebuf, sizeof(linebuf));

	DEBUGPRINT(3, ("%s %d. cmd_repy : %08x %04x %d\n", __FILE__, __LINE__, msg_from->sin_addr.s_addr, msg_from->sin_port, msg_from->sin_family));
	
	if (strcmp(linebuf, "ADD REQUEST") == 0) {
		printf("\n\nADD REQUEST recieved\n\n");
		ret = session_add_request(buf, size, env, msg_from);
	}
	else if (strcmp(linebuf, "DELETE REQUEST") == 0) {
		printf("\n\nDELETE REQUEST recieved\n\n");
		ret = session_delete_request(buf, size, env, msg_from);
	}
	else if (strcmp(linebuf, "FLUSH REQUEST") == 0) {
		printf("\n\nFLUSH REQUEST recieved\n\n");
		ret = session_flush_request(buf, size, env, msg_from);
	}
	else if (strcmp(linebuf, "DISPLAY REQUEST") == 0) {
		printf("\n\nDISPLAY REQUEST recieved\n\n");
		ret = session_display_request(buf, size, env, msg_from);
	}
	else {
		printf("unknown message received\n");

		write_len += sprintf(msgbuf + write_len, "UNKNOWN MESSAGE\n\n");
		write_len += snprintf(msgbuf + write_len, size, "%s", (char *)buf);
		if( sendto(env->command_sfd, msgbuf, write_len, 0, (struct sockaddr *)msg_from, sizeof(*msg_from)) < 0) {
		}

		return -1;
	}

	env->maxfd = maxfd(env);

	return ret;
}




int session_add_request(uchar * buf, size_t size, Environ * env, struct sockaddr_in * msg_from)
{
	int i;
	Session * sp;
	char linebuf[LINEBUFSIZE];
	char format[128];
	char msgbuf[MSGBUFSIZE];
	Message * def = def_add_request;

	int write_len;


	/* local display request message */
	write(1, buf, size);


	sgets_init((char *)buf, size);

	/* allocate session */
	for (i = 0; i < env->max_tunnel_device; i++)
		if (env->session[i].tunfd == TUNFD_UNUSE) {
			sp = &env->session[i];
			break;
		}

	if (i == env->max_tunnel_device) {
		printf("session full\n");

		write_len = 0;
		write_len += sprintf(msgbuf + write_len, "ADD REJECT\n");
		write_len += sprintf(msgbuf + write_len, "session full.\n");
        	if( sendto(env->command_sfd, msgbuf, write_len, 0, (struct sockaddr *)msg_from, sizeof(*msg_from)) < 0) {
		}

		return -1;
	}
	memset(sp, 0, sizeof(*sp) );
	
	/* paramter decode. and save to Environ structure */
	for (i = 0; def[i].param_name != NULL; i++)
		def[i].set_marker = NULL;
	
	while (sgets(linebuf, sizeof(linebuf))) {
		if (linebuf[0] == '.')
			break;
		for (i = 0; def[i].param_name != NULL; i++) {
			char * p = (char *)sp;
			p += def[i].offset;

			sprintf(format, "%s=%s", def[i].param_name, def[i].scan_syntax);
			if (sscanf(linebuf, format, p) == 1) 
				def[i].set_marker = def[i].param_name;
		}
	}

	/* parameter enough ? */
	for (i = 0; def[i].param_name != NULL; i++) {
		if ((def[i].presense == 'M') && (def[i].set_marker == NULL)) {
			printf("Illegal command. Mandatory parameter missing %s\n", def[i].param_name);
			sp->tunfd = TUNFD_UNUSE;
			sp->ebi = 0;

			write_len = 0;
			write_len += sprintf(msgbuf + write_len, "ADD REJECT\n");
			write_len += sprintf(msgbuf + write_len, "mandatory paramter missing. %s\n", def[i].param_name);
			if( sendto(env->command_sfd, msgbuf, write_len, 0, (struct sockaddr *)msg_from, sizeof(*msg_from)) < 0) {
			}

			return -1;
		}
	}

	/* check duplication */
	for (i = 0; i < env->max_tunnel_device; i++) {
		if (sp == &env->session[i])
			continue;
		if (sp->ebi == env->session[i].ebi) {
			printf("Requested EBI still exist.\n");
			
			write_len = 0;
			write_len += sprintf(msgbuf + write_len, "ADD REJECT\n");
			write_len += sprintf(msgbuf + write_len, "Requested EBI still exist.. %d\n", sp->ebi);
			if( sendto(env->command_sfd, msgbuf, write_len, 0, (struct sockaddr *)msg_from, sizeof(*msg_from)) < 0) {
			}

			sp->tunfd = TUNFD_UNUSE;
			sp->ebi = 0;
			
			return -1;
		}
		
	}

	
	/* open tunnel device */
	if (alloc_tundev(sp->tun_dev, env->base_tunnel_device, env->max_tunnel_device) < 0) {
		printf("tunnel device allocation failure\n");
		sp->tunfd = TUNFD_UNUSE;
		sp->ebi = 0;

		write_len = 0;
		write_len += sprintf(msgbuf + write_len, "ADD REJECT\n");
		write_len += sprintf(msgbuf + write_len, "tunnel device allocation failure\n");
		if( sendto(env->command_sfd, msgbuf, write_len, 0, (struct sockaddr *)msg_from, sizeof(*msg_from)) < 0) {
		}

		return -1;
	}
	if ( (sp->tunfd = tun_sock_open(sp->tun_dev)) < 0) {
		printf("tunnel device open failure: %s\n", sp->tun_dev);
		sp->tunfd = TUNFD_UNUSE;
		sp->ebi = 0;

		write_len = 0;
		write_len += sprintf(msgbuf + write_len, "ADD REJECT\n");
		write_len += sprintf(msgbuf + write_len, "tunnel device open failure: %s\n\n", sp->tun_dev);
		write_len += sprintf(msgbuf + write_len, "  * Are you root ?\n\n");
		write_len += sprintf(msgbuf + write_len, "  * TUN/TAP module installed ?\n");
		write_len += sprintf(msgbuf + write_len, "       do 'insmod tun'\n\n");
		write_len += sprintf(msgbuf + write_len, "  * device file exists?\n");
		write_len += sprintf(msgbuf + write_len, "       do 'ls /dev/net'. do 'mknod /dev/tun/tunX c 10 200'\n\n");
		write_len += sprintf(msgbuf + write_len, "  * add line 'alias tunX tun' to /etc/modprobe.conf\n\n");
		if( sendto(env->command_sfd, msgbuf, write_len, 0, (struct sockaddr *)msg_from, sizeof(*msg_from)) < 0) {
		}

		return -1;
	}

	/* set ip addresss and routing */
	setif(sp, env->own_gtpu_addr);

	/* prepare GTP-U Destination */
	sp->udp_dst.sin_addr.s_addr = inet_addr(sp->dst_gtpu_addr);
	sp->udp_dst.sin_port = htons(env->gtpu_port);
	sp->udp_dst.sin_family = AF_INET;


	/* create reply message */
	write_len = 0;
	write_len += sprintf(msgbuf + write_len, "ADD ACCEPT\n");
	for (i = 0; def_add_accept[i].param_name != NULL; i++) {
		char * p = (char *)sp;
		p += def_add_accept[i].offset;

		sprintf(format, "%s=%s\n", def_add_accept[i].param_name, def_add_accept[i].scan_syntax);
		if (def_add_accept[i].type == 'S') 
			write_len += sprintf(msgbuf + write_len, format, p);
		else if (def_add_accept[i].type == 'I') 
			write_len += sprintf(msgbuf + write_len, format, *(int *)p);
		else if (def_add_accept[i].type == 'U') 
			write_len += sprintf(msgbuf + write_len, format, *(uint32_t *)p);
	}
	write_len += sprintf(msgbuf + write_len, ".\n");

	/* local display reply message */
	write(1, msgbuf, write_len);

	/* send reply message */
        if( sendto(env->command_sfd, msgbuf, write_len, 0, (struct sockaddr *)msg_from, sizeof(*msg_from)) < 0) {
	}


	return 0;
}




int session_delete_request(uchar * buf, size_t size, Environ * env, struct sockaddr_in * msg_from)
{
	int i;
	int write_len;

	Session del_ses;
	Session * del_sp = &del_ses;
	Session * sp;

	char linebuf[LINEBUFSIZE];
	char format[128];
	char msgbuf[MSGBUFSIZE];

	/* local display request message */
	write(1, buf, size);
	
	/* paramter decode. and save to Environ structure */
	for (i = 0; def_delete_request[i].param_name != NULL; i++)
		def_delete_request[i].set_marker = NULL;
	
	while (sgets(linebuf, sizeof(linebuf))) {
		if (linebuf[0] == '.')
			break;
		for (i = 0; def_delete_request[i].param_name != NULL; i++) {
			char * p = (char *)del_sp;
			p += def_delete_request[i].offset;

			sprintf(format, "%s=%s", def_delete_request[i].param_name, def_delete_request[i].scan_syntax);
			if (sscanf(linebuf, format, p) == 1) 
				def_delete_request[i].set_marker = def_delete_request[i].param_name;
		}
	}

	/* parameter enough ? */
	for (i = 0; def_delete_request[i].param_name != NULL; i++) {
		if ((def_delete_request[i].presense == 'M') && (def_delete_request[i].set_marker == NULL)) {
			printf("Illegal command. Mandatory parameter missing %s\n", def_delete_request[i].param_name);

			write_len = 0;
			write_len += sprintf(msgbuf + write_len, "DELETE REJECT\n");
			write_len += sprintf(msgbuf + write_len, "mandatory paramter missing. %s\n", def_delete_request[i].param_name);
			if( sendto(env->command_sfd, msgbuf, write_len, 0, (struct sockaddr *)msg_from, sizeof(*msg_from)) < 0) {
			}

			return -1;
		}
	}

	/* find session */
	for (i = 0; i < env->max_tunnel_device; i++)  {
		if (del_sp->ebi == env->session[i].ebi) {
			sp = &env->session[i];
			break;
		}
	}
	if (i == env->max_tunnel_device) {
		printf("delete session not found. EBI: %d\n", del_sp->ebi);

		write_len = 0;
		write_len += sprintf(msgbuf + write_len, "DELETE REJECT\n");
		write_len += sprintf(msgbuf + write_len, "delete session not found. %s=%d\n", def_delete_request[0].param_name, del_sp->ebi);
		if( sendto(env->command_sfd, msgbuf, write_len, 0, (struct sockaddr *)msg_from, sizeof(*msg_from)) < 0) {
		}

		return -1;
	}


	/* delete interface */
	unsetif(sp, env->own_gtpu_addr);


	/* copy session, temporary */
	*del_sp = *sp;

	/* close fd */
	tun_sock_close(del_sp->tunfd);

	/* free tunnel device */
	free_tundev(del_sp->tun_dev, env->base_tunnel_device, env->max_tunnel_device);
	
	/* marking for deleted */
	sp->tunfd = TUNFD_UNUSE;
	sp->ebi   = 0;

	/* create reply message */
	write_len = 0;
	write_len += sprintf(msgbuf + write_len, "DELETE ACCEPT\n");
	for (i = 0; def_delete_request[i].param_name != NULL; i++) {
		char * p = (char *)del_sp;
		p += def_delete_accept[i].offset;

		sprintf(format, "%s=%s\n", def_delete_accept[i].param_name, def_delete_accept[i].scan_syntax);
		if (def_delete_accept[i].type == 'S') 
			write_len += sprintf(msgbuf + write_len, format, p);
		else if (def_delete_accept[i].type == 'I') 
			write_len += sprintf(msgbuf + write_len, format, *(int *)p);
		else if (def_delete_accept[i].type == 'U') 
			write_len += sprintf(msgbuf + write_len, format, *(uint32_t *)p);
	}
	write_len += sprintf(msgbuf + write_len, ".\n");

	/* local display reply message */
	write(1, msgbuf, write_len);

        if( sendto(env->command_sfd, msgbuf, write_len, 0, (struct sockaddr *)msg_from, sizeof(*msg_from)) < 0) {
	}


	return 0;
}


int session_flush_request(uchar * buf, size_t size, Environ * env, struct sockaddr_in * msg_from)
{
	int i;
	int write_len;

	Session * sp;
	char msgbuf[MSGBUFSIZE];

	/* local display request message */
	write(1, buf, size);

	write_len = 0;
	write_len += sprintf(msgbuf + write_len, "FLUSH ACCEPT\n");
	for (i = 0; i < env->max_tunnel_device; i++) {
		sp = &(env->session[i]);
		if (sp->tunfd != TUNFD_UNUSE) {
			write_len += sprintf(msgbuf + write_len, "TUNDEV=%s\n", sp->tun_dev);
			
			/* delete interface */
			unsetif(sp, env->own_gtpu_addr);
			
			/* close fd */
			tun_sock_close(sp->tunfd);
			/* free tunnel device */
			free_tundev(sp->tun_dev, env->base_tunnel_device, env->max_tunnel_device);

			/* marking for deleted */
			sp->tunfd = TUNFD_UNUSE;
			sp->ebi   = 0;
		}
	}
	write_len += sprintf(msgbuf + write_len, ".\n");

	/* local display reply message */
	write(1, msgbuf, write_len);

        if( sendto(env->command_sfd, msgbuf, write_len, 0, (struct sockaddr *)msg_from, sizeof(*msg_from)) < 0) {
	}


	return 0;
}





int session_display_request(uchar * buf, size_t size, Environ * env, struct sockaddr_in * msg_from)
{
	char msgbuf[MSGBUFSIZE];
	int i;
	Session * sp;
	static const size_t indent = 20;
	static const size_t indent_depth1= 8;
	int write_len;
	

	/* local display request message */
	write(1, buf, size);

	
	write_len = 0;
	
	
	write_len += sprintf(msgbuf + write_len, "DISPLAY ACCEPT\n");
	write_len += sprintf(msgbuf + write_len, "\n");
	
	write_len += sprintf(msgbuf + write_len, "============== Current Environment =============== \n");
	write_len += sprintf(msgbuf + write_len, "\n");
	write_len += sprintf(msgbuf + write_len, "%-*s : %d\n",	indent, "max_tunnel_device",	env->max_tunnel_device);
	write_len += sprintf(msgbuf + write_len, "%-*s : %d\n",	indent, "command_sfd",		env->command_sfd);
	write_len += sprintf(msgbuf + write_len, "%-*s : '%s'\n",	indent, "command_ip",		env->command_ip);
	write_len += sprintf(msgbuf + write_len, "%-*s : %d\n",	indent, "command_port",		env->command_port);
	write_len += sprintf(msgbuf + write_len, "%-*s : %d\n",	indent, "udpfd",		env->udpfd);
	write_len += sprintf(msgbuf + write_len, "%-*s : '%s'\n",	indent, "own_gtpu_addr",	env->own_gtpu_addr);
	write_len += sprintf(msgbuf + write_len, "%-*s : %d\n",	indent, "gtpu_port",		env->gtpu_port);
	write_len += sprintf(msgbuf + write_len, "\n");

	for (i = 0; i < env->max_tunnel_device; i++) {
		sp = &(env->session[i]);
		if (sp->tunfd != TUNFD_UNUSE) {
			write_len += sprintf(msgbuf + write_len, "%-*s%s%d%s\n",	indent_depth1, "", "--------- Current Session ", i, " -----------");

			write_len += sprintf(msgbuf + write_len, "%-*s%-*s : %d\n",	indent_depth1, "", indent, "tunfd",		env->session[i].tunfd);
			write_len += sprintf(msgbuf + write_len, "%-*s%-*s : %s\n",	indent_depth1, "", indent, "tun_dev",		env->session[i].tun_dev);

			write_len += sprintf(msgbuf + write_len, "%-*s%-*s : %d\n",	indent_depth1, "", indent, "ebi",		env->session[i].ebi);

			write_len += sprintf(msgbuf + write_len, "%-*s%-*s : %08x\n",	indent_depth1, "", indent, "own_gtpu_teid",	env->session[i].own_gtpu_teid);
			write_len += sprintf(msgbuf + write_len, "%-*s%-*s : '%s'\n",	indent_depth1, "", indent, "dst_gtpu_addr",	env->session[i].dst_gtpu_addr);
			write_len += sprintf(msgbuf + write_len, "%-*s%-*s : %08x\n",	indent_depth1, "", indent, "dst_gtpu_teid",	env->session[i].dst_gtpu_teid);

			write_len += sprintf(msgbuf + write_len, "%-*s%-*s : '%s'\n",	indent_depth1, "", indent, "user_addr4",	env->session[i].user_addr4);
			write_len += sprintf(msgbuf + write_len, "%-*s%-*s : '%s'\n",	indent_depth1, "", indent, "dst_route4",	env->session[i].dst_route4);
			write_len += sprintf(msgbuf + write_len, "%-*s%-*s : '%s'\n",	indent_depth1, "", indent, "user_addr6",	env->session[i].user_addr6);
			write_len += sprintf(msgbuf + write_len, "%-*s%-*s : '%s'\n",	indent_depth1, "", indent, "dst_route6",	env->session[i].dst_route6);

			write_len += sprintf(msgbuf + write_len, "%-*s%-*s : %11lu\n",	indent_depth1, "", indent, "trans_bytes",	env->session[i].trans_bytes);
			write_len += sprintf(msgbuf + write_len, "%-*s%-*s : %11lu\n",	indent_depth1, "", indent, "receive_bytes",	env->session[i].receive_bytes);
			write_len += sprintf(msgbuf + write_len, "\n");
		}
	}
	write_len += sprintf(msgbuf + write_len, ".\n");


        if( sendto(env->command_sfd, msgbuf, write_len, 0, (struct sockaddr *)msg_from, sizeof(*msg_from)) < 0) {
	}

	/* local display reply message */
	write(1, msgbuf, write_len);
	
	return 0;
}




