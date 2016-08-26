#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <netinet/in.h>

#include "common.h"
#include "gtp.h"


static ushort sequence_num = 0;


/* Encap GTP Header */
/*
       8    7   6   5   4   3   2   1
     +---------------------------------+
  1  | version   | PT | * | E | P | PN |
     | 0   0   1 |  0 | 0 | 0 | 1 |  0 |
     |---------------------------------|
  2  | Message Type:255(G-PDU)         |
     | 1   1   1   1   1    1   1   1  |
     |---------------------------------|
  3  | Length 1st                      |
     |---------------------------------|
  4  | Length 2nd                      |
     |---------------------------------|
  5  | TEID 1st                        |
     |---------------------------------|
  6  | TEID 2nd                        |
     |---------------------------------|
  7  | TEID 3rd                        |
     |---------------------------------|
  8  | TEID 4th                        |
     |---------------------------------|
  9  | Sequence Number 1st             |
     |---------------------------------|
 10  | Sequence Number 2nd             |
     +---------------------------------+
 11  | N_PDU Number                    |
     +---------------------------------+
 12  | Next Extension Header Type      |
     +---------------------------------+
*/


/*======================================================================================*/
/* Encapsule GTP header									*/
/* 	append GTP header before buf[0] (min user 12oct)				*/
/*	Don't call this	with top of buffer.						*/
/*======================================================================================*/
int encap_gtp_header(uchar * buf, ssize_t packsize, uint8_t msg_type, 
			 uint32_t teid, uint32_t flags)
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
	if (flags & GTP_HFLAG_SEQ_NUM) {
		*(uint16_t *)&header_p[8] = htons(sequence_num);
		sequence_num++;
	}

	/* set N_PDU Number */
	/* !!! N_PDU Number not implemented yet. always set zero */
	if (flags & GTP_HFLAG_N_PDU)
		header_p[10] = 0x00;

	/* set Extention Header */
	/* !!! Extention Header not implemented yet. always set zero */
	if (flags & GTP_HFLAG_EXT_HDR)
		header_p[11] = 0x00;

	return header_len;
}




int get_gtp_ext_header_len(uchar * exthdr)
{
	uchar * exthdr_p = exthdr;
	int len;

	while(1) {
		len = *exthdr_p * 4;	/* extension header length is 4 octets multiple */
		exthdr_p += len;
		if(exthdr_p[len-1] == 0x00)
			break;
	}

	return exthdr_p - exthdr;
}



/*======================================================================================*/
/* Decapsule GTP header									*/
/* 	return GTP header size						 		*/
/*======================================================================================*/
int decap_gtp_header(uchar * buf)
{
	int header_len = 8;
	uchar flags;

	flags = buf[0] & 0x07;
	if ( (flags & GTP_HFLAG_N_PDU) | (flags & GTP_HFLAG_SEQ_NUM) | (flags & GTP_HFLAG_EXT_HDR))
		header_len += 4;
	
	if (flags & GTP_HFLAG_EXT_HDR)
		header_len += get_gtp_ext_header_len(buf+header_len);
	
	return header_len;
}



/* GTP node endpoint Message */
/* 	GTP-U Echo/GTP ErrInd */
uchar get_gtp_msgtype(uchar * buf)
{
	return buf[1];
}




