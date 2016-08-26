#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/if.h>
#include <netinet/in.h>
#include <netinet/udp.h>



#include "common.h"
#include "init.h"
#include "interface.h"


static int read_environ(Environ * env, char * filename);

void init_tundev_pool(int tundev_env_max);




int init_environ(Environ * env, char * filename) 
{
	int i;

	memset(env, 0, sizeof(*env));

	/* set all session  to unused */
	for (i = 0; i < MAX_SESSION; i++)
		env->session[i].tunfd = TUNFD_UNUSE;

	/* read environment from file */
	read_environ(env, filename);

	/* open command socket */
	env->command_sfd = udp_sock_open(env->command_ip, env->command_port);

	/* open udp socket (GTP-U) */
	env->udpfd = udp_sock_open(env->own_gtpu_addr, env->gtpu_port);

	/* initialize tun device pool */
	init_tundev_pool(env->max_tunnel_device);

	disp_environ(env);

	return 0;
}



static int read_environ(Environ * env, char * filename)
{
	char buf[1024];
	char * p;

	/* read environment from config file */
	p = "MAX_TUNNEL_DEVICE";
	if(get_initenv(filename, buf, p) < 0) {
		printf("Error: Eviron elem read error : %s\n", p);
		exit(1);
	}
	env->max_tunnel_device = strtol(buf, &p, 10);

	p = "COMMAND_IP";
	if(get_initenv(filename, buf, p) < 0) {
		printf("Error: Eviron elem read error : %s\n", p);
		exit(1);
	}
	strcpy(env->command_ip, buf);

	p = "COMMAND_PORT";
	if(get_initenv(filename, buf, p) < 0) {
		printf("Error: Eviron elem read error : %s\n", p);
		exit(1);
	}
	env->command_port = strtol(buf, &p, 10);

	p = "GTP-U_OWN_IP";
	if(get_initenv(filename, buf, p) < 0) {
		printf("Error: Eviron elem read error : %s\n", p);
		exit(1);
	}
	strcpy(env->own_gtpu_addr, buf);

	p = "GTP-U_UDP_Port";
	if(get_initenv(filename, buf, p) < 0) {
		printf("Error: Eviron elem read error : %s\n", p);
		exit(1);
	}
	env->gtpu_port = strtol(buf, &p, 10);

	return 0;
}





void disp_environ(Environ * env) 
{
	static const size_t indent = 20;
	static const size_t indent_depth1= 8;
	int i;

	printf("\n");
	printf("============== Current Environment =============== \n");

	printf("%-*s : %d\n",	indent, "max_tunnel_device",	env->max_tunnel_device);
	printf("%-*s : %d\n",	indent, "command_sfd",		env->command_sfd);
	printf("%-*s : '%s'\n",	indent, "command_ip",		env->command_ip);
	printf("%-*s : %d\n",	indent, "command_port",		env->command_port);
	printf("%-*s : %d\n",	indent, "udpfd",		env->udpfd);
	printf("%-*s : '%s'\n",	indent, "own_gtpu_addr",	env->own_gtpu_addr);
	printf("%-*s : %d\n",	indent, "gtpu_port",		env->gtpu_port);
	printf("\n");

	for (i = 0; i < MAX_SESSION; i++) {
		if (env->session[i].tunfd != TUNFD_UNUSE) {
			printf("%-*s%s%d%s\n",		indent_depth1, "", "--------- Current Session ", i, " -----------");

			printf("%-*s%-*s : %d\n",	indent_depth1, "", indent, "tunfd",		env->session[i].tunfd);
			printf("%-*s%-*s : %s\n",	indent_depth1, "", indent, "tun_dev",		env->session[i].tun_dev);

			printf("%-*s%-*s : %d\n",	indent_depth1, "", indent, "ebi",		env->session[i].ebi);

			printf("%-*s%-*s : %08x\n",	indent_depth1, "", indent, "own_gtpu_teid",	env->session[i].own_gtpu_teid);
			printf("%-*s%-*s : '%s'\n",	indent_depth1, "", indent, "dst_gtpu_addr",	env->session[i].dst_gtpu_addr);
			printf("%-*s%-*s : %08x\n",	indent_depth1, "", indent, "dst_gtpu_teid",	env->session[i].dst_gtpu_teid);

			printf("%-*s%-*s : '%s'\n",	indent_depth1, "", indent, "user_addr4",	env->session[i].user_addr4);
			printf("%-*s%-*s : '%s'\n",	indent_depth1, "", indent, "dst_route4",	env->session[i].dst_route4);
			printf("%-*s%-*s : '%s'\n",	indent_depth1, "", indent, "user_addr6",	env->session[i].user_addr6);
			printf("%-*s%-*s : '%s'\n",	indent_depth1, "", indent, "dst_route6",	env->session[i].dst_route6);

			printf("%-*s%-*s : %11lu\n",	indent_depth1, "", indent, "trans_bytes",	env->session[i].trans_bytes);
			printf("%-*s%-*s : %11lu\n",	indent_depth1, "", indent, "receive_bytes",	env->session[i].receive_bytes);
			printf("\n");
		}
	}
	printf("\n");
}






#define TUNDEV_USED	1
#define TUNDEV_UNUSED	0
#define TUNDEV_INVALID	-1
#define TUNDEV_SYSMAX	128
int tundev_pool[TUNDEV_SYSMAX];


void init_tundev_pool(int tundev_env_max)
{
	int i;

	if (TUNDEV_SYSMAX < tundev_env_max) {
		printf("max tunnel device out of bounds. system max:128\n");
		exit(1);
	}

	for (i = 0; i < TUNDEV_SYSMAX; i++) 
		tundev_pool[i] = TUNDEV_INVALID;
	for (i = 0; i < tundev_env_max; i++)
		tundev_pool[i] = TUNDEV_UNUSED;
}



int alloc_tundev(char * tun_dev, int tundev_env_max)
{
	int i;
	
	for (i = 0; i < tundev_env_max; i++)
		if (tundev_pool[i] == TUNDEV_UNUSED) {
			tundev_pool[i] = TUNDEV_USED;
			break;
		}
			
	if (i == tundev_env_max)
		return -1;

	sprintf(tun_dev, "%s%d", "tun", i);
	return 0;
}



void free_tundev(char * tun_dev, int tundev_env_max)
{
	long dev_num;

	dev_num = strtol(tun_dev+3, NULL, 10);
	if (dev_num < 0 || tundev_env_max <= dev_num)
		return;

	tundev_pool[dev_num] = TUNDEV_UNUSED;
}



