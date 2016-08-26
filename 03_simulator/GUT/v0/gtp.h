#ifndef __GTP
#define __GTP

#include "common.h"


#define	GTP_HFLAG_N_PDU		0x01
#define	GTP_HFLAG_SEQ_NUM	0x02
#define	GTP_HFLAG_EXT_HDR	0x04

#define GTP_MSGTYPE_ECHO_REQ	0x01
#define GTP_MSGTYPE_ECHO_RES	0x02
#define GTP_MSGTYPE_N_PDU	0xff

int encap_gtp_header(uchar * buf, ssize_t packsize, uint8_t msg_type, uint32_t teid, uint32_t flags);
int decap_gtp_header(uchar * buf);
uchar get_gtp_msgtype(uchar * buf);


#endif	/* __GTP */

