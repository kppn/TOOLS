#include <arpa/inet.h>
#include <linux/if_packet.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <net/if.h>
#include <netinet/ether.h> 
#define BUF_SIZ 4096


void dump(unsigned char * p, size_t n)
{
	int i;
	for (i = 0; i < n; i++) {
		if (i % 16 == 0)
			printf("%016x: ", i);
		printf("%02x", p[i]);
		if (i % 4 == 3)
			printf(" ");
		if (i % 16 == 15)
			printf("\n");
	}
	printf("\n");

	return;
}


size_t strtohex(unsigned char * buf, char * s)
{
	int i;
	int j;
	unsigned char digit;

	for (i = 0; s[i] != '\0'; i++) {
		if (isalpha(s[i]))
			digit = toupper(s[i]) - 'A' + 10;
		if (isdigit(s[i]))
			digit = s[i] - '0';
		
		if (i % 2 == 0)
			buf[i/2] = (digit << 4);
		else
			buf[i/2] |= digit;
	}
	
	return i / 2;
}



char * del_comment(char * s)
{
	char * p;
	
	p = strchr(s, '#');
	if (p != NULL)
		*p = '\0';
	return s;
}



char * del_newline(char * s)
{
	char * p;
	
	p = strchr(s, '\n');
	if (p != NULL)
		*p = '\0';
	return s;
}



size_t trim_blank(char * s) 
{
	int i;
	size_t len;
	char * from;
	char * to;
	
	len = strlen(s);
	from = to = s;

	while (*from) {
		if (*from == ' ')
			from++;
		else
			*to++ = *from++;
	}
	*to = '\0';
	
	return len - (from - to);
}





size_t read_packet(unsigned char * buf, size_t s, char * filename)
{
	FILE * fp;
	size_t readsize;
	size_t total;
	unsigned char linebuf[4096];
	char * p;

	fp = fopen(filename, "rb");
	if (fp == NULL) {
		fprintf(stderr, "file open failure\n");
		return -1;
	}
	
	total = 0;
	readsize = 0;
	while (fgets(linebuf, 4095, fp) != NULL) {
		del_comment(linebuf);
		trim_blank(linebuf);
		del_newline(linebuf);
		
		readsize = strlen(linebuf);
	
		memcpy(buf + total, linebuf, readsize);
		total += readsize;
	}
	buf[total] = '\0';
	
	return total;
}


int main(int argc, char *argv[])
{
	int sockfd;
	
	struct ifreq if_idx;
	struct ifreq if_mac;
	struct sockaddr_ll sll;

	int tx_len = 0;
	unsigned char sendbuf[BUF_SIZ];
	struct ether_header *eh = (struct ether_header *) sendbuf;
	struct iphdr *iph = (struct iphdr *) (sendbuf + sizeof(struct ether_header));
	struct sockaddr_ll socket_address;
	char ifName[IFNAMSIZ];
	

	if (argc < 3) {
		printf("./send_raw dev file");
		exit(1);
	}
	
	strcpy(ifName, argv[1]);

	char buf[4096];
	size_t readed = read_packet(buf, BUF_SIZ, argv[2]);
	size_t hex_len = strtohex(sendbuf, buf);
	// dump(sendbuf, hex_len);

	
	/* Open RAW socket to send on */
	if ((sockfd = socket(AF_PACKET, SOCK_RAW, IPPROTO_RAW)) == -1) {
		perror("socket open fail");
		exit(1);
	} 
	
	/* Get the index of the interface to send on */
	memset(&if_idx, 0, sizeof(struct ifreq));
	strncpy(if_idx.ifr_name, ifName, IFNAMSIZ-1);
	if (ioctl(sockfd, SIOCGIFINDEX, &if_idx) < 0) {
		perror("SIOCGIFINDEX");
		exit(1);
	}
	
	/* Get the MAC address of the interface to send on */
	memset(&if_mac, 0, sizeof(struct ifreq));
	strncpy(if_mac.ifr_name, ifName, IFNAMSIZ-1);
	if (ioctl(sockfd, SIOCGIFHWADDR, &if_mac) < 0) {
		perror("SIOCGIFHWADDR"); 
		exit(1);
	}

	memset(&sll, 0xff, sizeof(sll));
	sll.sll_family = AF_PACKET;
	sll.sll_protocol = htons(ETH_P_ALL);
	sll.sll_ifindex = if_idx.ifr_ifindex;
	if (bind(sockfd, (struct sockaddr *)&sll, sizeof(sll)) == -1) {
	perror("bind fail\n");
	exit(1);
	};


	/* Index of the network device */
	socket_address.sll_family = AF_PACKET;
	socket_address.sll_protocol = htons(ETH_P_ALL);
	socket_address.sll_ifindex = if_idx.ifr_ifindex;
	socket_address.sll_halen = ETH_ALEN;

	/* Destination MAC */
	socket_address.sll_addr[0] = sendbuf[6];
	socket_address.sll_addr[1] = sendbuf[7];
	socket_address.sll_addr[2] = sendbuf[8];
	socket_address.sll_addr[3] = sendbuf[9];
	socket_address.sll_addr[4] = sendbuf[10];
	socket_address.sll_addr[5] = sendbuf[11];

	/* Send packet */
	if (sendto(sockfd, sendbuf, hex_len, 0, (struct sockaddr*)&socket_address, sizeof(struct sockaddr_ll)) < 0) {
		printf("Send failed\n"); 
	}

	printf("sent : %d\n", hex_len);
	dump(sendbuf, hex_len);

	return 0;
} 

