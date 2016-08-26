#include <stdio.h>
#include <string.h>
#include "common.h"



int main()
{
	Environ env;
	Session ses;

	ses.tunfd = 1;
	strcpy(ses.tun_dev, "tun0");
	ses.own_gtpu_teid = 0x11111111;
	strcpy(ses.dst_gtpu_addr, "172.30.127.1");
	ses.own_gtpu_teid = 0x22222222;
	strcpy(ses.user_addr4, "10.0.0.1");
	strcpy(ses.dst_route4, "10.0.0.2");
	strcpy(ses.user_addr6, "2001:0:01:1:1");
	strcpy(ses.dst_route6, "2001:0:01:1:2");
	ses.trans_bytes = 10000;
	ses.receive_bytes = 20000;


	init_environ(&env, "gut.conf");

	env.session[0] = ses;
	disp_environ(&env);

	return 0;
}



