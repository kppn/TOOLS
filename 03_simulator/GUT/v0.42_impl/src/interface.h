#ifndef __INTERFACE
#define __INTERFACE


#include <sys/types.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include "common.h"


int tun_sock_open(char *dev);
int tun_sock_close(int fd);
int udp_sock_open(const char * ip, uint16_t port);
int udp_sock_close(int fd);

int setif(Session * sp);

int read_tun(int tunfd, uchar * buf, int size, uchar ** user_p);
int write_tun(int tunfd, uchar * buf, int size);

int recv_gtp_pdu(int udpfd, uchar * buf, int size, struct sockaddr_in * udp_from,
                     uint8_t * msg_type, uint32_t * teid, uint16_t * seq, uchar ** user_p);

int send_gtp_pdu(int udpfd, uchar * buf, int size, struct sockaddr_in * udp_dst,
                 uint8_t msg_type, uint32_t teid, uint16_t seq);



uchar * encap_tunframe(uchar * user_p);
uchar * decap_tunframe(uchar * user_p);



#endif /* __INTERFACE */


