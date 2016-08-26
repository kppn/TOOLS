#ifndef __COMMON
#define __COMMON

typedef	unsigned char uchar;
typedef	unsigned short ushort;

void dump(uchar * buf, int n);
int get_initenv(char * filename, char retbuf[], const char * envname);


struct environ {
	char tun_dev[20];
	char user_addr4[20];
	char dst_route4[20];
	char user_addr6[64];
	char dst_route6[64];

	uint16_t gtpu_port;
	char own_gtpu_addr[20];
	char dst_gtpu_addr[20];
	uint32_t dst_gtpu_teid;
};

#define GTPHDROFFSET	10
#define TUNFRAMHDRSOFFSET	4

#endif	/* __COMMON */

