
#define	GTP_HFLAG_N_PDU		0x01
#define	GTP_HFLAG_SEQ_NUM	0x02
#define	GTP_HFLAG_EXT_HDR	0x04

#define GTP_MSGTYPE_ECHO_REQ	0x01
#define GTP_MSGTYPE_ECHO_RES	0x02
#define GTP_MSGTYPE_ERR_IND	0x1a
#define GTP_MSGTYPE_END_MARKER	0xfe
#define GTP_MSGTYPE_N_PDU	0xff



uchar * encap_udp_header(uchar * buf, ssize_t packsize, uint16_t sport, uint16_t dport)
{
	*(uint16_t *)(buf+0) = htons(sport);
	*(uint16_t *)(buf+2) = htons(dport);
	*(uint16_t *)(buf+4) = htons((uint16_t)packsize);
	
}



uchar * encap_gtp_header(uchar * buf, ssize_t packsize, uint8_t msg_type, 
			 uint32_t teid, uint16_t seq, uint32_t flags)
{
	int header_len = 8; 
	uchar * header_p;
	uchar base = 0x30;	/* GTP Header 1st octet. GTP' is not supported */
	uint32_t teid_n;

	
	/* set GTP header flags */
	base |= (flags & GTP_HFLAG_N_PDU) | (flags & GTP_HFLAG_SEQ_NUM) | (flags & GTP_HFLAG_EXT_HDR);

	/* add header length. if one or more flags is setted, all fields are present */
	if (base & 0x07)
		header_len += 4;
	header_p = buf - header_len;

	/****** GTP Header structure ******/

	/* set base(GTP Header 1st octet) */
	header_p[0] = base;

	/* set Message Type */
	header_p[1] = msg_type;

	/* set Length */
	*(uint16_t *)(&header_p[2]) = htons(packsize + (header_len-8));

	/* set TEID */
	teid_n = htonl(teid);
	memcpy(&header_p[4], (uchar *)&teid_n, 4);


	/* set Sequence Number */
	if (flags & GTP_HFLAG_SEQ_NUM)
		*(uint16_t *)&header_p[8] = htons(seq);

	/* set N_PDU Number */
	/* !!! N_PDU Number not implemented yet. always set zero */
	if (flags & GTP_HFLAG_N_PDU)
		header_p[10] = 0x00;

	/* set Extention Header */
	/* !!! Extention Header not implemented yet. always set zero */
	if (flags & GTP_HFLAG_EXT_HDR)
		header_p[11] = 0x00;

	return header_p;
}






int set_ipproto(void * p, struct in_addr ip_dst, size_t offset, int last)
{
	struct ip * ip = p;
	
	memset(ip, 0, sizeof(struct ip));
	ip->ip_v = IPVERSION;
	ip->ip_hl = sizeof(struct ip) >> 2;
	ip->ip_tos = 0;
	ip->ip_len = sizeof(struct ip);
	ip->ip_id = 0;
	ip->ip_ttl = 255;
	ip->ip_p = IPPROTO_RAW;
	ip->ip_sum = 0;	/* auto calcurate */
	
	ip->ip_off = 0x00;
	if (! last)
		ip->ip_off |= IP_MF;
	ip->ip_off |= offset;
	
	return 0;
}



int send_flagpacket()
{
	buf[8092];
	struct in_addr ip_dst;
	
	ip_dst = (struct in_addr)inet_addr(ip_dst_str);
	set_ipproto(buf, ip_dst);
	
	sendto();
}



make_gtp(unsigned char buf, uint32_t teid, size_t len)
{
	/* make gtp packet with teid */
	
	encap_udp_header(buf, len, GTP_MSGTYPE_N_PDU, teid, 0, 0);
	encap_gtp_header(buf, len, GTP_MSGTYPE_N_PDU, teid, 0, 0);
	
	
}



int make_socket(char * ifname)
{
	int sock;
	
	if((sock = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL))) < 0 ){
		perror("socket error");
		exit(1);
	}
	
	struct ifreq ifr;
	memset(&ifr, 0, sizeof(struct ifreq));
	strcpy(ifr.ifr_name, argv[1]);
	if(ioctl(sockA, SIOCGIFINDEX, &ifr) < 0 ){
		perror("ioctl SIOCGIFINDEX");
		exit(1);
	}
	
	sock_ifidx = ifr.ifr_ifindex;
	sa.sll_family = AF_PACKET;
	sa.sll_protocol = htons(ETH_P_ALL);
	sa.sll_ifindex = ifr.ifr_ifindex;
	if(bind(sockA, (struct sockaddr *)&sa, sizeof(sa)) < 0) {
		perror("bind error");
		close(sock);
		exit(0);
	}
	
	return sock;
}



int main(int argc, char ** argv)
{
	/* sendfp eth0 target_ip  teid       fragment_size ... */
	/* sendfp eth0 172.16.0.1 0x0123abcd 1400 200     */
	
	int sock;
	
	sock = make_socket(argv[1]);
	
	
	
}


