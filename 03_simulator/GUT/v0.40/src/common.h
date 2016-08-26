#ifndef __COMMON
#define __COMMON

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdint.h>
#include <net/if.h>
#include <net/if_arp.h>
#include <arpa/inet.h>

typedef	unsigned char uchar;
typedef	unsigned short ushort;


#define MAX_SESSION	11
#define TUNFD_UNUSE	-1

typedef struct _session {
	int tunfd;	/* natural number:valid fd. minus number:unused session */
	char tun_dev[20];

	int ebi;

	uint32_t own_gtpu_teid;
	char dst_gtpu_addr[20];
	uint32_t dst_gtpu_teid;

	struct sockaddr_in udp_dst;
	uint16_t seq;

	char user_addr4[20];
	char dst_route4[20];
	char user_addr6[64];
	char dst_route6[64];

	unsigned long trans_bytes;
	unsigned long receive_bytes;
} Session;


typedef struct _environ {
	int max_tunnel_device;
	char command_ip[20];
	uint16_t command_port;
	int command_sfd;
	int udpfd;
	char own_gtpu_addr[20];
	uint16_t gtpu_port;

	int maxfd;

	Session session[MAX_SESSION];
} Environ;


void dump(uchar * buf, int n);
int maxfd(Environ * env);
int get_initenv(char * filename, char retbuf[], const char * envname);

#define GTPHDROFFSET	10
#define TUNFRAMHDRSOFFSET	4

#endif	/* __COMMON */

