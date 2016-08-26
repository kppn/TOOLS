#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

#include "common.h"
#include "command.h"
#include "init.h"



int main(int argc, char ** argv)
{
	Environ env;
	int ret;
	int readsize;
	int sockaddr_len;
	char msgbuf[4096];
	struct sockaddr_in client;

	init_environ(&env, "gut.conf");

	sockaddr_len = sizeof(client);
	while ( readsize = recvfrom(env.command_sfd, msgbuf, 4096, 0, (struct sockaddr *)&client, &sockaddr_len) ) {
		ret = exec_command(msgbuf, readsize, &env, &client);
		disp_environ(&env);
	}

	return 0;
}



